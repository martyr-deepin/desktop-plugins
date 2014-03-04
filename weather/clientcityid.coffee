#Copyright (c) 2011 ~ 2014 Deepin, Inc.
#              2011 ~ 2014 bluth
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

class ClientCityId
    constructor: ->

    geoposition:->
        geo = window.navigator.geolocation
        echo geo
        if geo
            pos = geo.getCurrentPosition(@getPositionSuccess,@geoErrorMan)
        else
            echo "geolocation is not supported by this browser!"
        
    geoErrorMan:(error)->
        echo error.message
   
    getPositionSuccess:(position)->
        echo "getPositionSuccess"
        echo position
        lat = position.coords.latitude
        long = position.coords.langitude
        echo lat + "," + long

    get_client_cityid_from_freegeo: (callback)=>
        url_clientcity_json = "http://freegeoip.net/json"
        ajax(url_clientcity_json,true, (xhr)=>
            # try
                remote_ip_info = JSON.parse(xhr.responseText)

                if remote_ip_info.ip isnt null
                    yahoo = new YahooService()
                    cityname_client = remote_ip_info.city
                    yahoo.get_woeid_by_whole_name(cityname_client,=>
                        woeid_data = localStorage.getObject("woeid_data_whole_name")
                        if not woeid_data? then return
                        try
                            cityid_client = woeid_data[0].id
                        catch e
                            echo "woeid_data[0].id is error"
                            return
                        echo "cityid_client:#{cityid_client},cityname_client:#{woeid_data[0].k};"
                        localStorage.setItem("cityid_client",cityid_client)
                        localStorage.setItem("cityid",cityid_client)
                        localStorage.setItem("cityname_client",woeid_data[0].k)

                        common_dists = localStorage.getObject("common_dists")
                        client_exist = false
                        for tmp in common_dists
                            if not tmp? then continue
                            if cityid_client == tmp.id or tmp.name is cityname_client then client_exist = true
                        if client_exist is false
                            arr = {name:woeid_data[0].k,id:woeid_data[0].id}
                            common_dists.push(arr)
                            if common_dists.length > 5 then common_dists.splice(0,1)
                            localStorage.setObject("common_dists",common_dists)
                        
                        callback?()

                    )
                else
                    echo "Get_client_cityid can't find the matched location right json by ip"
                    return 0
            # catch e
                # echo "Get_client_cityid xhr.responseText error！"
        )
       
    get_client_cityid_from_ipinfo: (callback)=>
        url_clientcity_json = "http://ipinfo.io/json"
        ajax(url_clientcity_json,true, (xhr)=>
            # try
                remote_ip_info = JSON.parse(xhr.responseText)

                if remote_ip_info.ip isnt null
                    yahoo = new YahooService()
                    cityname_client = remote_ip_info.city
                    yahoo.get_woeid_by_whole_name(cityname_client,=>
                        woeid_data = localStorage.getObject("woeid_data_whole_name")
                        if not woeid_data? then return
                        try
                            cityid_client = woeid_data[0].id
                        catch e
                            echo "woeid_data[0].id is error"
                            return
                        echo "cityid_client:#{cityid_client},cityname_client:#{woeid_data[0].k};"
                        localStorage.setItem("cityid_client",cityid_client)
                        localStorage.setItem("cityid",cityid_client)
                        localStorage.setItem("cityname_client",woeid_data[0].k)

                        common_dists = localStorage.getObject("common_dists")
                        client_exist = false
                        for tmp in common_dists
                            if not tmp? then continue
                            if cityid_client == tmp.id or tmp.name is cityname_client then client_exist = true
                        if client_exist is false
                            arr = {name:woeid_data[0].k,id:woeid_data[0].id}
                            common_dists.push(arr)
                            if common_dists.length > 5 then common_dists.splice(0,1)
                            localStorage.setObject("common_dists",common_dists)
                        
                        callback?()

                    )
                else
                    echo "Get_client_cityid can't find the matched location right json by ip"
                    return 0
            # catch e
                # echo "Get_client_cityid xhr.responseText error！"
        )
 
    
    get_client_cityid_from_sinaapi: (callback)=>
        url_clientcity_json = "http://int.dpool.sina.com.cn/iplookup/iplookup.php?format=js&ip="
        ajax(url_clientcity_json,true, (xhr)=>
            # try
                eval(xhr.responseText)
                
                if remote_ip_info.ret == 1
                    localStorage.setItem("client_ipstart",remote_ip_info.start)
                    localStorage.setItem("client_ipend",remote_ip_info.end)

                    yahoo = new YahooService()
                    cityname_client = remote_ip_info.city
                    yahoo.get_woeid_by_whole_name(cityname_client,=>
                        woeid_data = localStorage.getObject("woeid_data_whole_name")
                        if not woeid_data? then return
                        try
                            cityid_client = woeid_data[0].id
                        catch e
                            echo "woeid_data[0].id is error"
                            return
                        echo "cityid_client:#{cityid_client},cityname_client:#{woeid_data[0].k};"
                        localStorage.setItem("cityid_client",cityid_client)
                        localStorage.setItem("cityid",cityid_client)
                        localStorage.setItem("cityname_client",woeid_data[0].k)

                        common_dists = localStorage.getObject("common_dists")
                        client_exist = false
                        for tmp in common_dists
                            if not tmp? then continue
                            if cityid_client == tmp.id or tmp.name is cityname_client then client_exist = true
                        if client_exist is false
                            arr = {name:woeid_data[0].k,id:woeid_data[0].id}
                            common_dists.push(arr)
                            if common_dists.length > 5 then common_dists.splice(0,1)
                            localStorage.setObject("common_dists",common_dists)
                        
                        callback?()

                    )
                else
                    echo "Get_client_cityid can't find the matched location right json by ip"
                    return 0
            # catch e
                # echo "Get_client_cityid xhr.responseText error！"
        )

