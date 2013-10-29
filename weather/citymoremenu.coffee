#Copyright (c) 2011 ~ 2012 Deepin, Inc.
#              2011 ~ 2012 bluth
#
#encoding: utf-8
#Author:      bluth <yuanchenglu@linuxdeepin.com>
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

class CityMoreMenu extends Widget
    COMMON_MENU_WIDTH_MINI = 70
    BOTTOM_DISTANCE_CHOOSECITY_MINI = 200
    BOTTOM_DISTANCE_COMMONCITY_MINI = 200
    times_dist_choose = 0
    YAHOO = true
    
    constructor: (zIndex)->
        super(null)
        echo "CityMoreMenu"
        @element.style.display = "none"
        @element.style.zIndex = zIndex
        common = localStorage.getObject("common_dists_storage")
        common_dists = if !common then common_dists_init else common
        localStorage.setObject("common_dists_storage",common_dists)

    display_none:->
        @element.style.display = "none"
    display_block:->
        @element.style.display = "block"
    display_check:->
        return @element.style.display
    zIndex_check:->
        return @element.style.zIndex

    set_menu_position:(obj,bottom_distance,x1,y1,x2,y2,show = "block")->
        obj.style.display = "block"
        height = obj.clientHeight
        obj.style.display = "none"
        if bottom_distance < height
            obj.style.left = x2
            obj.style.bottom = y2
        else
            obj.style.left = x1
            obj.style.top = y1
        obj.style.display = show

    common_city_build:(bottom_distance,x1,y1,x2,y2,callback)->
        echo "common_city_build"
        @element.style.display = "block"
        @lable_choose.style.display = "none" if @lable_choose
        remove_element(@common_menu) if @common_menu
        remove_element(@search) if @search

        @common_menu = create_element("div","common_menu",@element)
        @common_menu.style.display = "none"
        common_dists = localStorage.getObject("common_dists_storage")
        @common_city(common_dists,callback)
        @add_common()
        @set_menu_position(@common_menu,bottom_distance,x1,y1,x2,y2,"block")

    common_city:(common_dists,callback)->
        if common_dists
            common_city = []
            common_city_text = []
            minus = []
            id_tmp = []
            length = common_dists.length
            i = 0
            
            while i < length
                if common_dists[i].name && common_dists[i].id
                    common_city[i] = create_element("div","common_city",@common_menu)
                    common_city[i].value = common_dists[i].name

                    common_city_text[i] = create_element("div","common_city_text",common_city[i])
                    common_city_text[i].innerText = common_dists[i].name
                    common_city_text[i].value = common_dists[i].id

                    minus[i] = create_element("div","minus",common_city[i])
                    minus[i].innerText = "-"
                    minus[i].value = common_dists[i].id

                    that = @
                    common_city_text[i].addEventListener("click",->
                        that.element.style.display = "none"
                        localStorage.setItem("cityid_storage",this.value)
                        that = null
                        callback()
                        )

                    minus[i].addEventListener("click",->
                        name = this.parentElement.value
                        id = this.value
                        remove_element(this.parentElement)
                        for tmp ,i in common_dists
                            if id == tmp.id
                                common_dists[i].name = ""
                                common_dists[i].id = ""
                                localStorage.setObject("common_dists_storage",common_dists)
                                break

                        times = localStorage.getObject("times_dist_choose_storage")
                        times-- if times > 0
                        localStorage.setObject("times_dist_choose_storage",times)
                        )
                i++
    add_common:->
        @add_common_city = create_element("div","add_common_city",@common_menu)
        plus =  create_element("div","plus",@add_common_city)
        plus.innerText = "+"

    more_city_build:(selectsize,bottom_distance,x1,y1,x2,y2,callback)->
        @add_common_city.addEventListener("click",=>
            echo "add_common_city"
            @common_menu.style.display = "none"
            @search_city_build()
            @set_menu_position(@search,bottom_distance,x1,y1,x2,y2,"block")
            )
    
    search_city_build:->
        echo "search_city_build"
        remove_element(@search) if @search
        @search = create_element("div","search",@element)
        @search_input = create_element("input","search_input",@search)
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
        if YAHOO
            yahooservice = new YahooService()
            
            get_yahoo_data_callback = ->
                echo "get yahoo weather data,and then to update_ui_callback"
                yahoo_weather_data_now = localStorage.getObject("yahoo_weather_data_now")
                #echo yahoo_weather_data_now
                yahoo_weather_data_more = localStorage.getObject("yahoo_weather_data_more")
                #echo yahoo_weather_data_more
                #update_ui_callback()
             
            selected_callback = ->
                echo "selected_callback"
                woeid_choose = localStorage.getObject("woeid_choose")
                yahooservice.get_weather_data_by_woeid(woeid_choose,get_yahoo_data_callback.bind(@))


            get_woeid_callback = ->
                echo "get_woeid_callback"
                @search_result_build()
                @search_result_choosed(selected_callback.bind(@))
            
            yahooservice.get_woeid_by_place_name(place_name,get_woeid_callback.bind(@))
            
    search_result_build:=>
        echo "search_result_build"
        woeid_data = localStorage.getObject("woeid_data")
        #echo woeid_data
        remove_element(@search_result) if @search_result
        @search_result = create_element("div","search_result",@search)
        @search_result_select = create_element("select","search_result_select",@search_result)
        #@search_result_choose.style.textAlign = "center"
        @clearOptions(@search_result_select,0)
        for data in woeid_data
            show_result_text =  data.index + ":" + data.c + "," + data.s + "," + data.k + "," + data.pn
            @search_result_select.options.add(new Option(show_result_text, data.index))

        @search_result_select.options[0].selected = "false"
        @search_result_select.autofocus = "false"
        @setMaxSize(@search_result_select,woeid_data.length)
        
    search_result_choosed:(callback)=>
        @search_result_select.addEventListener("change", =>
            woeid_data = localStorage.getObject("woeid_data")
            i = @search_result_select.selectedIndex
            woeid_choose = woeid_data[i].woeid
            echo woeid_data[i].index
            localStorage.setItem("woeid_choose",woeid_choose)
            remove_element(@search) if @search

            common = localStorage.getObject("common_dists_storage")
            common_dists = if !common then common_dists_init else common
            for tmp ,i in common_dists
                if woeid_data[i].woeid == tmp.id
                    return

            times = localStorage.getObject("times_dist_choose_storage")
            times_dist_choose = if times == null then 1 else times

            common_dists[times_dist_choose].name = woeid_data[i].k
            common_dists[times_dist_choose].id = woeid_data[i].woeid
            localStorage.setObject("common_dists_storage",common_dists)
            times_dist_choose++
            if times_dist_choose > 4 then times_dist_choose = 0
            localStorage.setItem("times_dist_choose_storage",times_dist_choose)

            callback()
        )
    

    clearOptions:(colls,first=0)->
        i = first
        colls.options.length = i

    setMaxSize:(obj,val=@selectsize)->
        obj.size = val

    create_option:(obj,data)->
        for i of data
            obj.options.add(new Option(data[i].name, i))
