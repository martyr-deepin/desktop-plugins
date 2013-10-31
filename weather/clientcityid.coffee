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
        @url_clientcity_json = "http://int.dpool.sina.com.cn/iplookup/iplookup.php?format=js&ip="

    Get_client_cityid: (callback)->
        ajax(@url_clientcity_json,true, (xhr)=>
            try
                client_cityjsonstr = xhr.responseText
                remote_ip_info = JSON.parse(client_cityjsonstr.slice(21,client_cityjsonstr.length))
                if remote_ip_info.ret == 1
                    yahoo = new YahooService()
                    cityname_client = remote_ip_info.city
                    echo "cityname_client:" + cityname_client
                    yahoo.get_woeid_by_place_name(cityname_client,=>
                        woeid_data = localStorage.getObject("woeid_data")
                        if not woeid_data? then return
                        cityid_client = woeid_data[0].woeid
                        echo "cityid_client:#{cityid_client},cityname_client:#{cityname_client};"
                        localStorage.setItem("cityid_client_storage",cityid_client)
                        localStorage.setItem("cityid_storage",cityid_client)
                        localStorage.setItem("cityname_client_storage",woeid_data[0].k)

                        common_dists = localStorage.getObject("common_dists")
                        for tmp in common_dists
                            if not tmp? then continue
                            if woeid_choose == tmp.id then return
                        arr = {name:woeid_data[0].k,id:woeid_data[0].woeid}
                        common_dists.push(arr)
                        if common_dists.length > 5 then common_dists.splice(0,1)
                        localStorage.setObject("common_dists",common_dists)
                        
                        callback()

                    )
                else
                    echo "Get_client_cityid can't find the matched location right json by ip"
                    return 0
            catch e
                echo "Get_client_cityid error"
        )

