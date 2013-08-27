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
                # echo "woeid:" + woeid
                localStorage.setItem("woeid",woeid)
                return woeid
            else
                echo "get_woeid_by_place_name xhr.responseText is error"
                return
        )

    get_weather_data_by_woeid:(woeid)->
        echo "woeid:" + woeid
        if !woeid
            echo "woeid :" + woeid + ",return!"
            return
        xml_str = "http://weather.yahooapis.com/forecastrss?w=" + woeid + "&u=c"
        ajax(xml_str,false,(xhr)=>
            xmlDoc =  xhr.responseXML
            # echo xmlDoc
            title = xmlDoc.getElementsByTagName("item")[0].getElementsByTagName("title")[0].childNodes[0].nodeValue
            echo title
            if title is "City not found"
                echo "title:" + title + ",the return data is error ,return!"
                return
            location = xmlDoc.getElementsByTagNameNS("*","location")
            city = location[0].getAttribute("city")
            region = location[0].getAttribute("region")
            country = location[0].getAttribute("country")
            item  = xmlDoc.getElementsByTagName("title")

            units = xmlDoc.getElementsByTagNameNS("*","units")
            temperature = units[0].getAttribute("temperature")

            condition = xmlDoc.getElementsByTagNameNS("*","condition")
            text_now = condition[0].getAttribute("text")
            code_now = condition[0].getAttribute("code")
            temp_now = condition[0].getAttribute("temp")
            date_now = condition[0].getAttribute("date")

            forecast = xmlDoc.getElementsByTagNameNS("*","forecast")
            day = []
            date = []
            low = []
            high = []
            text = []
            code = []
            for i in [0..forecast.length-1]
                # echo forecast[i]
                day[i] = forecast[i].getAttribute("day")
                date[i] = forecast[i].getAttribute("date")
                low[i] = forecast[i].getAttribute("low")
                high[i] = forecast[i].getAttribute("high")
                text[i] = forecast[i].getAttribute("text")
                code[i] = forecast[i].getAttribute("code")
            return true
        )