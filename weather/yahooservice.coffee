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

class YahooService
    APPID = "YiXRYM74"
    DEG = 'c'
    # latitude = 37.42
    # longitude = -122.12

    # http://query.yahooapis.com/v1/public/yql?q=select%20woeid%20from%20geo.places%20where%20text%20=%20%22wuhan%22&format=json
    # woeid_url = "http://where.yahooapis.com/geocode?location= " + latitude + "," + longitude + "&flags=J&gflags=R&appid=" +  APPID

    constructor: ->

    get_woeid_by_place_name:(place_name)->
        yql = 'select woeid from geo.places where text = "' + place_name + '"'
        xml_str = "http://query.yahooapis.com/v1/public/yql?q=" + yql + "&format=json"
        ajax(xml_str,false,(xhr)=>
            respose = JSON.parse(xhr.responseText)
            woeid = respose.query.results.place.woeid
            if woeid
                echo "woeid:" + woeid
                localStorage.setItem("woeid",woeid)
                return woeid
            else
                echo "get_woeid_by_place_name xhr.responseText is error"
                return
        )

    get_weather_data_by_woeid:(woeid)->
        xml_str = "http://weather.yahooapis.com/forecastrss?w=" + woeid + "&u=c"
        ajax(xml_str,false,(xhr)=>
            xml =  xhr.responseXML

            # selectNodeList()
            condition = selectSingleNode('rss/channel/item/yweather:condition')
            
            weather_condition_ele = xml.getElementsByTagName("yweather:condition")[0].childNodes.getAttribute("code")
            echo weather_condition_ele
            # weather_condition = {}
            # weather_condition["code"] = weather_condition_ele.childNodes.getAttribute("code")

            # weather_condition["text"] = code_icon_dict[int(weather_condition["code"])][1]
            # weather_condition["temp"] = weather_condition_ele.getAttribute("temp") + "\u2103"
            # weather_condition["pic"] = code_icon_dict[int(weather_condition["code"])][0]
            # echo weather_condition["code"]


            # weather_forecast = xml.getElementsByTagName("yweather:forecast")
            # # echo weather_forecast.toString()
            # # weather_condition = []
            # location = xml.getElementsByTagName("yweather:location")
            # echo location.nodeName
            # lat = xml.getElementsByTagName("geo:lat")
            # echo lat
            # # city = location.getAttribute("city")
            # # echo city

            # for element,i of weather_forecast
            #     ele = weather_forecast.item[i]
            #     day = ele.getAttribute("day")
            #     date = ele.getAttribute("date")
            #     low = ele.getAttribute("low")
            #     high = ele.getAttribute("high")
            #     text = ele.getAttribute("text")
            #     code = ele.getAttribute("code")
            #     echo day + "," + date + "," + low + "," + high + "," + text + ","  + code + "."
            #     weather_condition["forecast" + index] = {}
            #     weather_condition["forecast" + index]["low"] = ele.getAttribute("low") + "~"
            #     weather_condition["forecast" + index]["high"] = ele.getAttribute("high") + u"\u2103"
            #     weather_condition["forecast" + index]["code"] = ele.getAttribute("code")
            #     weather_condition["forecast" + index]["day"] = ele.getAttribute("day")
            #     weather_condition["forecast" + index]["text"] = code_icon_dict[int(ele.getAttribute("code"))][1]
            #     weather_condition["forecast" + index]["pic"] = code_icon_dict[int(ele.getAttribute("code"))][0]
        )