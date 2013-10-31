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
    ZINDEX_MENU = 5001
    ZINDEX_GLOBAL_DESKTOP = 5000
    ZINDEX_DOWNEST = 0

    BOTTOM_DISTANCE_MINI = 215

    TOP_MORE_WEATHER_MENU1 = 91
    TOP_MORE_WEATHER_MENU2 = -191

    LEFT_COMMON_CITY_MENU1 = 160
    TOP_COMMON_CITY_MENU1 = 57
    LEFT_COMMON_CITY_MENU2 = 160
    BOTTOM_COMMON_CITY_MENU2 = -35

    LEFT_MORE_CITY_MENU1 = 10
    TOP_MORE_CITY_MENU1 = 90
    LEFT_MORE_CITY_MENU2 = 10
    BOTTOM_MORE_CITY_MENU2 = -22
    common_dists = new Array()
    testInternet_url = "http://weather.yahooapis.com/forecastrss?w=2151330&u=c"
    constructor: ->
        super(null)
        @weather_style_build()
        @more_weather_build()
        dist = localStorage.getObject("common_dists")
        if not dist? then localStorage.setObject("common_dists",common_dists)
        
        ajax(testInternet_url,true,@testInternet_connect.bind(@),@testInternet_noconnect.bind(@))

    testInternet_connect:=>
        cityid = localStorage.getObject("cityid_storage") if localStorage.getObject("cityid_storage")
        if cityid < 1000
            cityid = 0
            localStorage.setItem("cityid_storage",cityid)

        if !cityid
            Clientcityid = new ClientCityId()
            Clientcityid.Get_client_cityid(@weathergui_update.bind(@))
        else @weathergui_update()

    testInternet_noconnect:=>
        @weathergui_refresh_by_localStorage()

    do_buildmenu:->
        []
    weather_style_build: ->
        @img_url_first = "#{plugin.path}/img/"
        img_now_url_init = @img_url_first + "48/T" + "0\u6674" + ".png"
        temp_now_init = "00"

        left_div = create_element("div", "left_div", @element)
        @weather_now_pic = create_img("weather_now_pic", img_now_url_init, left_div)

        right_div = create_element("div","right_div",@element)
        temperature_now = create_element("div", "temperature_now", right_div)
        @temperature_now_minus = create_element("div", "temperature_now_minus", temperature_now)
        @temperature_now_minus.textContent = "-"
        @temperature_now_number = create_element("div", "temperature_now_number", temperature_now)
        @temperature_now_number.textContent = temp_now_init
        @temperature_now_number.style.opacity = 0.0

        city_and_date = create_element("div","city_and_date",right_div)
        city = create_element("div","city",city_and_date)
        @city_now = create_element("div", "city_now", city)
        @city_now.textContent = _("choose city")
        @more_city_img = create_img("more_city_img", @img_url_first + "ar.png", city)
        @date = create_element("div", "date", city_and_date)
        @date.textContent =  _("loading") + ".........."

        @more_city_menu = create_element("div","more_city_menu",@element)
        @more_city_menu.style.zIndex = ZINDEX_MENU
        @global_desktop = create_element("div","global_desktop",@element)
        @global_desktop.style.height = window.screen.height
        @global_desktop.style.width = window.screen.width
        @global_desktop.style.zIndex = ZINDEX_GLOBAL_DESKTOP

        city.addEventListener("click", =>
            @more_weather_menu.style.display = "none"

            if @more_city_menu.style.display == "none"
                @more_city_menu.style.display = "block"
                @global_desktop.style.display = "block"
            else
                @more_city_menu.style.display = "none"
                @global_desktop.style.display = "none"

            @common_city_build()
            )
        @date.addEventListener("click", =>
            @more_city_menu.style.display = "none"

            if @more_weather_menu.style.display == "none"
                @global_desktop.style.display = "block"
                bottom_distance =  window.screen.availHeight - @element.getBoundingClientRect().bottom
                set_menu_position(@more_weather_menu,bottom_distance,TOP_MORE_WEATHER_MENU1,TOP_MORE_WEATHER_MENU2,"block")
            else
                @global_desktop.style.display = "none"
                @more_weather_menu.style.display = "none"
            )
        @global_desktop.addEventListener("click",=>
            @more_weather_menu.style.display = "none"
            @more_city_menu.style.display = "none"
            @global_desktop.style.display = "none"
            )



    more_weather_build: ->

        img_now_url_init = @img_url_first + "48/T" + "0\u6674" + ".png"
        img_more_url_init = @img_url_first + "24/T" + "0\u6674" + ".png"
        week_init = _("Sun")
        temp_init = "00℃~00℃"

        @more_weather_menu = create_element("div", "more_weather_menu", @element)
        @more_weather_menu.style.display = "none"

        @weather_data = []
        @week = []
        @pic = []
        @temperature = []
        for i in [0...6]
            @weather_data[i] = create_element("div", "weather_data", @more_weather_menu)
            @week[i] = create_element("a", "week", @weather_data[i])
            @week[i].textContent = week_init
            @pic[i] = create_img("pic", img_more_url_init, @weather_data[i])
            @temperature[i] = create_element("a", "temperature", @weather_data[i])
            @temperature[i].textContent = temp_init

    lost_focus:->
        @more_weather_menu.style.display = "none"
        @more_city_menu.style.display = "none"
        @global_desktop.style.display = "none"



    common_city_build:->
        echo "common_city_build"
        remove_element(@common_menu) if @common_menu
        remove_element(@search) if @search

        @common_menu = create_element("div","common_menu",@more_city_menu)
        common_dists = localStorage.getObject("common_dists")
        i = 0
        common_city = []
        common_city_text = []
        minus = []
        for dist,j in common_dists
            if not dist? then continue
            i++
            common_city[i] = create_element("div","common_city",@common_menu)
            common_city[i].value = dist.name

            common_city_text[i] = create_element("div","common_city_text",common_city[i])
            common_city_text[i].innerText = dist.name
            common_city_text[i].value = dist.id

            minus[i] = create_element("div","minus",common_city[i])
            minus[i].innerText = "-"
            minus[i].value = dist.id

            that = @
            common_city_text[i].addEventListener("click",->
                echo "click"
                that.more_city_menu.style.display = "none"
                localStorage.setItem("cityid_storage",this.value)
                # that.selected_callback()
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

        @add_common_city = create_element("div","add_common_city",@common_menu)
        plus =  create_element("div","plus",@add_common_city)
        plus.innerText = "+"
        @add_common_city.addEventListener("click",=>
            echo "add_common_city"
            @common_menu.style.display = "none"
            @search_city_build()
            )
        bottom_distance =  window.screen.availHeight - @element.getBoundingClientRect().bottom
        # set_menu_position(@common_menu,bottom_distance,LEFT_COMMON_CITY_MENU1,TOP_COMMON_CITY_MENU1,LEFT_COMMON_CITY_MENU2,BOTTOM_COMMON_CITY_MENU2,"block")
        @common_menu.style.display = "block"


    search_city_build:->
        echo "search_city_build"
        remove_element(@search) if @search
        @search = create_element("div","search",@more_city_menu)
        @search_input = create_element("input","search_input",@search)
        @search.style.display = "block"
        @search_input.type = "text"
        @search_input.focus()
        @search_input.addEventListener("keypress", @search_input_keypress)
        @search_input.addEventListener("keyup", @search_input_keyup)


    search_input_keypress: (evt) =>
        evt.stopPropagation()
        switch evt.keyCode
            when 13   # enter
                evt.preventDefault()
                #@search_input_complete()
            when 27   # esc
                evt.preventDefault()
                remove_element(@search) if @search
            when 47   # /
                evt.preventDefault()
        return


    
    search_input_keyup: (evt) =>
        evt.stopPropagation()
        place_name = @search_input.value
        echo place_name
        
        get_woeid_callback = =>
            echo "get_woeid_callback finsh"
            @search_result_build(@weathergui_update.bind(@))
        
        yahooservice = new YahooService()
        yahooservice.get_woeid_by_place_name(place_name,get_woeid_callback.bind(@))
  
        
            
    search_result_build: (callback) =>
        # echo "search_result_build"
        woeid_data = localStorage.getObject("woeid_data")
        if not woeid_data? then return
        remove_element(@search_result) if @search_result
        @search_result = create_element("div","search_result",@search)
        @search_result_select = create_element("select","search_result_select",@search_result)
        clearOptions(@search_result_select,0)
        for data in woeid_data
            show_result_text =  data.index + ":" + data.c + "," + data.s + "," + data.k
            @search_result_select.options.add(new Option(show_result_text, data.index))

        if @search_result_select.options.length < 1 then return
        @search_result_select.options[0].selected = "false"
        @search_result_select.autofocus = "false"
        setMaxSize(@search_result_select,woeid_data.length)
        
        @search_result_select.addEventListener("change", =>
            woeid_data = localStorage.getObject("woeid_data")
            i = @search_result_select.selectedIndex
            woeid_choose = woeid_data[i].woeid
            echo woeid_data[i].index
            localStorage.setItem("cityid_storage",woeid_choose)
            remove_element(@search) if @search

            #if not (localStorage.getObject("common_dists"))? then common_dists = localStorage.getObject("common_dists")
            for tmp in common_dists
                if not tmp? then continue
                if woeid_choose == tmp.id then return
            arr = {name:woeid_data[i].k,id:woeid_data[i].woeid}
            echo arr
            common_dists.push(arr)
            if common_dists.length > 5 then common_dists.splice(0,1)
            localStorage.setObject("common_dists",common_dists)
            
            callback()?
        )
    











    weathergui_update: =>
            @global_desktop.style.display = "none"

            cityid = localStorage.getObject("cityid_storage")
            @weathergui_refresh(cityid)
            that = @
            clearInterval(auto_weathergui_refresh)
            auto_weathergui_refresh = setInterval(->
                cityid = localStorage.getObject("cityid_storage")
                that.weathergui_refresh(cityid)
            ,600000)# ten minites

    weathergui_refresh_by_localStorage : =>
        weather_data_now = localStorage.getObject("yahoo_weather_data_now")
        @update_weathernow(weather_data_now)
        weather_data_more = localStorage.getObject("yahoo_weather_data_more")
        @update_weathermore(weather_data_more)

    weathergui_refresh: (cityid)=>
        echo "refresh"
        if cityid < 100
            cityid = 0
            localStorage.setItem("cityid_storage",cityid)
        if cityid
            yahooservice = new YahooService()
            yahooservice.get_weather_data_by_woeid(cityid,@weathergui_refresh_by_localStorage.bind(@))
        else
            echo "cityid isnt ready"

    update_weathernow: (weather_data_now)->
        temp_now = weather_data_now.weatherinfo.temp
        @time_update = weather_data_now.weatherinfo.time
        @city_now.textContent = weather_data_now.weatherinfo.city

        if temp_now == "\u6682\u65e0\u5b9e\u51b5"
            temp_str = _(" sorry, \n China Meteorological Administration \n don't provide the live weather data for this city.")
            @temperature_now_number.style.fontSize = 18
            @temperature_now_number.textContent = _("None")
            @temperature_now_number.title = temp_str
            # new ToolTip(@temperature_now_number,temp_str)
        else
            @temperature_now_number.style.fontSize = 36
            if temp_now < -10
                @temperature_now_minus.style.opacity = 0.8
                @temperature_now_number.textContent = -temp_now
            else
                @temperature_now_minus.style.opacity = 0
                @temperature_now_number.style.opacity = 1.0
                @temperature_now_number.textContent = temp_now

    update_weathermore: (weather_data_more)->
        @week_n = @weatherdata.weather_more_week()
        @img_front = @weatherdata.weather_more_img_front()
        @img_behind = @weatherdata.weather_more_img_behind()
        week_show = [_("Sun"), _("Mon"), _("Tue"), _("Wed"), _("Thu"), _("Fri"), _("Sat")]
        str_data = weather_data_more.weatherinfo.date_y
        @date.textContent = str_data.substring(0,str_data.indexOf("\u5e74")) + "." + str_data.substring(str_data.indexOf("\u5e74")+1,str_data.indexOf("\u6708"))+ "." + str_data.substring(str_data.indexOf("\u6708") + 1,str_data.indexOf("\u65e5")) + " " + week_show[@week_n%7]
        @weather_now_pic.src = @img_url_first + "48/T" + weather_data_more.weatherinfo.img_single + weather_data_more.weatherinfo.img_title_single + ".png"

        @weather_now_pic.title = weather_data_more.weatherinfo['weather' + 1]
        # new ToolTip(@weather_now_pic,weather_data_more.weatherinfo['weather' + 1])

        for i in [0...6]
            j = i + 1
            @weather_data[i].title = weather_data_more.weatherinfo['weather' + j]
            # new ToolTip(@weather_data[i],weather_data_more.weatherinfo['weather' + j])
            @week[i].textContent = week_show[(@week_n + i) % 7]
            @pic[i].src = @weather_more_pic_src(j)
            @temperature[i].textContent = weather_data_more.weatherinfo['temp' + j]


plugin = PluginManager.get_plugin("weather")
plugin.inject_css("weather")
plugin.wrap_element(new Weather(plugin.id).element)
