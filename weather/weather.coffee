#Copyright (c) 2011 ~ 2012 Deepin, Inc.
#              2011 ~ 2012 bluth
#
#encoding: utf-8
#Author:      bluth <\yuanchenglu@linuxdeepin.com>
#Maintainer:  bluth <yuanchenglu@linuxdeepin.com>
#
#This program is free software; you can redistribute it and/or modify
#it under the terms of the GNU General Public License as published by
#the Free Software Foundation; either version 3 of the License, or
#(at your option) any later version.
#
#This program is distributed in the hope that it will be useful,
#but WITHOUT ANY WARRANTY; without even the implied warranty of
#MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#GNU General Public License for more details.
#
#You should have received a copy of the GNU General Public License
#along with this program; if not, see <http://www.gnu.org/licenses/>.
_ = (s) ->
    DCore.dgettext('weather', s)

class Weather extends Widget
    common_dists = new Array()
    testInternet_url = "http://weather.yahooapis.com/forecastrss?w=2151330&u=c"

    constructor: ->
        super(null)
        dist = localStorage.getObject("common_dists")
        if not dist? then localStorage.setObject("common_dists",common_dists)

        @weather_now_build()
        @weather_more_build()

        ajax(testInternet_url,true,@testInternet_connect.bind(@),@testInternet_noconnect.bind(@))

    testInternet_connect:=>
        echo "testInternet_connect ok"
        cityid = localStorage.getItem("cityid") if localStorage.getItem("cityid")
        if cityid < 1000
            cityid = 0
            localStorage.setItem("cityid",cityid)

        if !cityid
            Clientcityid = new ClientCityId()
            Clientcityid.Get_client_cityid(@weathergui_refresh_Interval.bind(@))
        else @weathergui_refresh_Interval()

    testInternet_noconnect:=>
        echo "testInternet_noconnect"
        @city_now.textContent = _("No network connection")
        @weathergui_refresh_by_localStorage()

    do_buildmenu:->
        []
    
    lost_focus:->
        @more_weather_menu.style.display = "none" if @more_weather_menu
        @more_city_menu.style.display = "none" if @more_city_menu
        @global_desktop.style.display = "none" if @global_desktop
        remove_element(@more_city_tmp) if @more_city_tmp
        remove_element(@search) if @search

    weather_now_build: ->
        @img_url_first = "#{plugin.path}/img/"
        img_now_url_init = @img_url_first + "yahoo_api/48/" + "26" + "n.png"
        temp_now_init = "00°"

        left_div = create_element("div", "left_div", @element)
        @weather_now_pic = create_img("weather_now_pic", img_now_url_init, left_div)

        #new ToolTip(@weather_now_pic,text)
        right_div = create_element("div","right_div",@element)
        temperature_now = create_element("div", "temperature_now", right_div)
        @temperature_now_minus = create_element("div", "temperature_now_minus", temperature_now)
        @temperature_now_minus.textContent = "-"
        @temperature_now_number = create_element("div", "temperature_now_number", temperature_now)
        @temperature_now_number.textContent = temp_now_init
        # @temperature_now_number.style.opacity = 0.0

        city_and_date = create_element("div","city_and_date",right_div)
        city = create_element("div","city",city_and_date)
        @city_now = create_element("div", "city_now", city)
        @city_now.textContent = _("choose city")
        @more_city_img = create_img("more_city_img", @img_url_first + "ar.png", city)
        @date = create_element("div", "date", city_and_date)
        @date.textContent =  _("loading") + ".........."

        remove_element(@more_weather_menu) if @more_weather_menu
        @more_weather_menu = create_element("div", "more_weather_menu", @element)
        @more_weather_menu.style.display = "none"
        
        remove_element(@more_city_menu) if @more_city_menu
        @more_city_menu = create_element("div","more_city_menu",@element)
        @more_city_menu.style.display = "none"

        @global_desktop = create_element("div","global_desktop",@element)
        @global_desktop.style.display = "none"
        @global_desktop.style.height = window.screen.height
        @global_desktop.style.width = window.screen.width

        city.addEventListener("click", =>
            remove_element(@search) if @search
            @more_weather_menu.style.display = "none"
            @city_more_build()
            if @more_city_menu.style.display == "none"
                
                @more_city_menu.style.display = "block"
                height = @more_city_menu.clientHeight
                @more_city_menu.style.display = "none"
                bottom_distance =  window.screen.availHeight - @element.getBoundingClientRect().bottom
                @more_city_menu.style.left = 160
                if bottom_distance < height
                    @more_city_menu.style.top = -145
                else
                    @more_city_menu.style.top = 60
                @more_city_menu.style.display = "block"

                @global_desktop.style.display = "block"
            else
                @more_city_menu.style.display = "none"
                @global_desktop.style.display = "none"
            )
        @date.addEventListener("click", =>
            @more_city_menu.style.display = "none"

            if @more_weather_menu.style.display == "none"
                
                @more_weather_menu.style.display = "block"
                height = @more_weather_menu.clientHeight
                @more_weather_menu.style.display = "none"
                bottom_distance =  window.screen.availHeight - @element.getBoundingClientRect().bottom
                if bottom_distance < height
                    @more_weather_menu.style.top = -160
                    @more_weather_menu.style.borderRadius = "6px 6px 0 0"
                else
                    @more_weather_menu.style.top = 91
                    @more_weather_menu.style.borderRadius = "0 0 6px 6px"
                @more_weather_menu.style.display = "block"

                @global_desktop.style.display = "block"
            else
                @global_desktop.style.display = "none"
                @more_weather_menu.style.display = "none"
            )
        @global_desktop.addEventListener("click",=>
            @lost_focus()
            )

    weather_more_build: ->
        img_now_url_init = @img_url_first + "yahoo_api/48/" + "26" + "n.png"
        img_more_url_init = @img_url_first + "yahoo_api/24/" + "26" + "n.png"
        week_init = _("Sun")
        temp_init = "00~00℃"

        remove_element(@weather_more_tmp) if @weather_more_tmp
        @weather_more_tmp = create_element("div","weather_more_tmp",@more_weather_menu)
        @weather_data = []
        @tooltip = []
        @week = []
        @pic = []
        @temperature = []
        for i in [0...5]
            @weather_data[i] = create_element("div", "weather_data", @weather_more_tmp)
            @tooltip[i] = new ToolTip(@weather_data[i],"")
            @week[i] = create_element("a", "week", @weather_data[i])
            @week[i].textContent = week_init
            @pic[i] = create_img("pic", img_more_url_init, @weather_data[i])
            @temperature[i] = create_element("a", "temperature", @weather_data[i])
            @temperature[i].textContent = temp_init
    
    city_more_build:->
        remove_element(@search) if @search

        remove_element(@more_city_tmp) if @more_city_tmp
        @more_city_tmp = create_element("div","more_city_tmp",@more_city_menu)
        common_dists = localStorage.getObject("common_dists")
        i = 0
        common_city = []
        common_city_text = []
        minus = []
        for dist,i in common_dists
            if not dist? then continue
            common_city[i] = create_element("div","common_city",@more_city_tmp)
            common_city[i].value = dist.name
            common_city[i].title = dist.name

            common_city_text[i] = create_element("div","common_city_text",common_city[i])
            common_city_text[i].innerText = dist.name
            common_city_text[i].value = dist.id

            minus[i] = create_element("div","minus",common_city[i])
            minus[i].innerText = "-"
            minus[i].value = dist.id

            that = @
            common_city_text[i].addEventListener("click",->
                that.more_city_menu.style.display = "none"
                id =  this.value
                localStorage.setItem("cityid",JSON.parse(this.value))
                that.weathergui_refresh_Interval()
                that = null
                )

            minus[i].addEventListener("click",->
                name = this.parentElement.value
                id = this.value
                remove_element(this.parentElement)
                for tmp ,i in common_dists
                    if not tmp? then continue
                    if id == tmp.id
                        common_dists.splice(i,1)
                        localStorage.setObject("common_dists",common_dists)
                        break
                )

        @add_common_city = create_element("div","add_common_city",@more_city_tmp)
        plus =  create_element("div","plus",@add_common_city)
        plus.innerText = "+"
        @add_common_city.addEventListener("click",=>
            @more_city_menu.style.display = "none"
            @search_city_build()
        )


    search_city_build:->
        remove_element(@search) if @search
        @search = create_element("div","search",@element)
        @search_input = create_element("input","search_input",@search)
        @search_input.type = "text"
        @search_input.addEventListener("keypress", @search_input_keypress)
        @search_input.addEventListener("keyup", @search_input_keyup)

        @global_desktop.style.display = "block"
        # more_weather_menu height = 175
        height = 200
        @search.style.display = "none"
        bottom_distance =  window.screen.availHeight - @element.getBoundingClientRect().bottom
      
        if bottom_distance < height
            @search.style.top = -10
            @search.style.borderRadius = "6px 6px 0 0"
        else
            @search.style.top = 91
            @search.style.borderRadius = "0 0 6px 6px"
        @search.style.display = "block"
        @search_input.focus()

    search_input_keypress: (evt) =>
        evt.stopPropagation()
        switch evt.keyCode
            when 13   # enter
                evt.preventDefault()
                woeid_data = localStorage.getObject("woeid_data")
                i = 0
                woeid_choose = woeid_data[i].id
                localStorage.setItem("cityid",woeid_data[i].id)

                for tmp in common_dists
                    if not tmp? then continue
                    if woeid_choose == tmp.id then return
                arr = {name:woeid_data[i].k,id:woeid_data[i].id}
                common_dists.push(arr)
                echo woeid_data[i].index + "choosed:"
                echo arr
                if common_dists.length > 5 then common_dists.splice(0,1)
                localStorage.setObject("common_dists",common_dists)
                
                @weathergui_refresh_Interval()
            when 27   # esc
                evt.preventDefault()
                @lost_focus()
            when 47   # /
                evt.preventDefault()
        return
    
    search_input_keyup: (evt) =>
        evt.stopPropagation()
        place_name = @search_input.value
        
        yahooservice = new YahooService()
        yahooservice.get_woeid_by_place_name(place_name,@search_result_build.bind(@))
  
    search_result_build: () =>
        # echo "search_result_build"
        woeid_data = localStorage.getObject("woeid_data")
        if not woeid_data? then return
        remove_element(@search_result) if @search_result
        @search_result = create_element("div","search_result",@search)
        @search_result_select = create_element("select","search_result_select",@search_result)
        clearOptions(@search_result_select,0)
        for data in woeid_data
            show_result_text =  data.index + ":" + data.k + "," + data.s + "," + data.c
            @search_result_select.options.add(new Option(show_result_text, data.index))

        if @search_result_select.options.length < 1 then return
        #for option in @search_result_select.opitions
            #option.style.width = "162px"
        setMaxSize(@search_result_select,woeid_data.length)
        @search_input.focus()
        @search_result_select.options[0].selected = "selected"
        @search_result_select.options[0].addEventListener("click",=>
            woeid_data = localStorage.getObject("woeid_data")
            i = @search_result_select.selectedIndex
            woeid_choose = woeid_data[i].id
            localStorage.setItem("cityid",woeid_choose)

            for tmp in common_dists
                if not tmp? then continue
                if woeid_choose == tmp.id then return
            arr = {name:woeid_data[i].k,id:woeid_data[i].id}
            echo woeid_data[i].index + "choosed:"
            echo arr
            common_dists.push(arr)
            if common_dists.length > 5 then common_dists.splice(0,1)
            localStorage.setObject("common_dists",common_dists)
            
            @weathergui_refresh_Interval()
        )

        @search_result_select.addEventListener("change", =>
            woeid_data = localStorage.getObject("woeid_data")
            i = @search_result_select.selectedIndex
            woeid_choose = woeid_data[i].id
            localStorage.setItem("cityid",woeid_choose)

            for tmp in common_dists
                if not tmp? then continue
                if woeid_choose == tmp.id then return
            arr = {name:woeid_data[i].k,id:woeid_data[i].id}
            echo woeid_data[i].index + "choosed:"
            echo arr
            common_dists.push(arr)
            if common_dists.length > 5 then common_dists.splice(0,1)
            localStorage.setObject("common_dists",common_dists)
            
            @weathergui_refresh_Interval()
        )

    weathergui_refresh_Interval: =>
            @weathergui_refresh()
            that = @
            clearInterval(auto_weathergui_refresh)
            auto_weathergui_refresh = setInterval(->
                that.weathergui_refresh()
            ,600000)# ten minites


    weathergui_refresh: =>
        @lost_focus()
        cityid = localStorage.getItem("cityid")
        if cityid < 100
            cityid = 0
            localStorage.setItem("cityid",cityid)
        if cityid
            yahooservice = new YahooService()
            yahooservice.get_weather_data_by_woeid(cityid,@weathergui_refresh_by_localStorage.bind(@))
        else
            echo "cityid isnt ready"


    weathergui_refresh_by_localStorage : =>
        echo "weathergui_refresh_by_localStorage"
        weather_data_now = localStorage.getObject("yahoo_weather_data_now")
        weather_data_more = localStorage.getObject("yahoo_weather_data_more")
        if not weather_data_now? then return
        if not weather_data_more? then return
        #echo weather_data_now
        #echo weather_data_more
        temp_now = weather_data_now.temp
        temp_danwei = "°" + weather_data_now.temp_danwei
        @city_now.textContent = weather_data_now.city_name
        code  = weather_data_now.code
        if code is "3200" then code = weather_data_more[0].code
        yahooservice = new YahooService()
        text = yahooservice.yahoo_img_code_to_en(code)
        @weather_now_pic.src = @img_url_first + "yahoo_api/48/" + code + "n.png"
        @weather_now_pic.title = text
        str = weather_data_now.date
        date_tmp = str.substring(0,str.indexOf("201") - 1)
        day_tmp = date_tmp.substring(0,date_tmp.indexOf(","))
        day = yahooservice.day_en_zh(day_tmp)
        riqi = date_tmp.substring(date_tmp.indexOf(" ") + 1)
        ri = riqi.substring(0,riqi.indexOf(" "))
        month_tmp = riqi.substring(riqi.indexOf(" ") + 1)
        month = yahooservice.month_en_num(month_tmp)
        year = "2013"
        date_text = year + "." + month + "." + ri + " " + day
        # echo date_text
        @date.textContent = date_text
        echo weather_data_now.city_name + ":" + weather_data_now.temp + temp_danwei + "," + text + ",code:" + weather_data_now.code

        @temperature_now_number.style.fontSize = 36
        if temp_now < -10
            @temperature_now_minus.style.opacity = 0.8
            @temperature_now_number.textContent = -temp_now + "°"
        else
            @temperature_now_minus.style.opacity = 0
            @temperature_now_number.style.opacity = 1.0
            @temperature_now_number.textContent = temp_now + "°"

        if @weather_data is undefined then return
        for data , i in weather_data_more
            if not @weather_data[i] then continue
            @tooltip[i].text = yahooservice.yahoo_img_code_to_en(data.code)
            @week[i].textContent = yahooservice.day_en_zh(data.day)
            @pic[i].src = @img_url_first + "yahoo_api/24/" + data.code + "n.png"
            @temperature[i].textContent = data.low + " ~ " + data.high + temp_danwei

plugin = PluginManager.get_plugin("weather")
plugin.inject_css("weather")
plugin.wrap_element(new Weather(plugin.id).element)
