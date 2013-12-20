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

class ClientCityId
    constructor: ->
        #@geoposition()

    geoposition:->
        geo = window.navigator.geolocation
        echo geo
        pos = geo.getCurrentPosition(@getPositionSuccess)
        
        
    getPositionSuccess:(position)->
        echo position
        lat = position.coords.latitude
        long = position.coords.langitude
        echo lat + "," + long

    get_client_cityid: (callback)=>
        url_clientcity_json = "http://int.dpool.sina.com.cn/iplookup/iplookup.php?format=js&ip="
        ajax(url_clientcity_json,true, (xhr)=>
            # try
                eval(xhr.responseText)
                # echo remote_ip_info
                
                if remote_ip_info.ret == 1
                    localStorage.setItem("client_ipstart",remote_ip_info.start)
                    localStorage.setItem("client_ipend",remote_ip_info.end)

                    yahoo = new YahooService()
                    cityname_client = remote_ip_info.city
                    yahoo.get_woeid_by_place_name(cityname_client,=>
                        woeid_data = localStorage.getObject("woeid_data")
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
                        for tmp in common_dists
                            if not tmp? then continue
                            if woeid_choose == tmp.id then return
                        arr = {name:woeid_data[0].k,id:woeid_data[0].id}
                        common_dists.push(arr)
                        if common_dists.length > 5 then common_dists.splice(0,1)
                        localStorage.setObject("common_dists",common_dists)
                        
                        callback()

                    )
                else
                    echo "Get_client_cityid can't find the matched location right json by ip"
                    return 0
            # catch e
                # echo "Get_client_cityid xhr.responseText error！"
        )

