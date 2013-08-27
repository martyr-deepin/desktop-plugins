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
    APPID = "dj0yJmk9QU10MlFDcUlsWEIxJmQ9WVdrOVdXbFlVbGxOTnpRbWNHbzlNQS0tJnM9Y29uc3VtZXJzZWNyZXQmeD1lZA--"
    DEG = 'c'

    constructor: ->

    get_woeid_by_place_name:(place_name,callback)->
        yql = 'select woeid from geo.places where text = "' + place_name + '"'
        xml_str = "http://query.yahooapis.com/v1/public/yql?q=" + yql + "&format=json"

        xml1 = "http://where.yahooapis.com/v1/places.q('" + place_name + "')?appid=" + APPID

        ajax(xml_str,true,(xhr)=>
            respose = JSON.parse(xhr.responseText)
            echo respose.query.count
            if respose.query.count is 0
                echo "the " + place_name + " for yahoo api return null! please retry the place_name . return!"
                return
            woeid = respose.query.results.place.woeid
            if woeid?
                localStorage.setItem("woeid",woeid)
                callback?()
            else
                echo "get_woeid_by_place_name xhr.responseText is error"
                return
        )

    get_weather_data_by_woeid:(woeid,callback)->
        echo "woeid:" + woeid
        if !woeid
            echo "woeid :" + woeid + ",return!"
            return
        xml_str = "http://weather.yahooapis.com/forecastrss?w=" + woeid + "&u=" + DEG
        ajax(xml_str,true,(xhr)=>
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
            callback?()
        )
