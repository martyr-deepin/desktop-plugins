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
    
    #language = ["zh-Hans","zh-Hant","en-US"]
    
    APPID = "dj0yJmk9QU10MlFDcUlsWEIxJmQ9WVdrOVdXbFlVbGxOTnpRbWNHbzlNQS0tJnM9Y29uc3VtZXJzZWNyZXQmeD1lZA--"
    DEG = 'c'

    constructor: ->

    get_woeid_by_place_name:(place_name,callback)->
        woeid_url = "http://sugg.hk.search.yahoo.net/gossip-gl-location/?appid=weather&output=sd1&p2=cn,t,pt,z&lc=zh-Hans&command=" + place_name
        ajax(woeid_url,true,(xhr)=>
            xml_str = xhr.responseText
            localStorage.setItem("yahoo_woeid_xml_str",xml_str)
            woeid_xml = localStorage.getObject("yahoo_woeid_xml_str")
            echo woeid_xml
            echo woeid_xml.q
            if woeid_xml.q isnt place_name
                echo "get_woeid_by_place_name xml_str  wrong!"
                return
            r = woeid_xml.r
            echo r.length
            echo r
            for dk in r
                String (d)
                d = dk.d
                k = dk.k
                #d = JSON.parse(d)
                e = JSON.stringify(d)
                echo e
                echo d
                echo k
            woeid = null
            echo woeid
            localStorage.setItem("woeid",woeid)
            callback?()
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
