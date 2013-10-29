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
        woeid_data = new Array()
        ajax(woeid_url,true,(xhr)=>
            xml_str = xhr.responseText
            localStorage.setItem("yahoo_woeid_xml_str",xml_str)
            woeid_xml = localStorage.getObject("yahoo_woeid_xml_str")
            #echo woeid_xml
            #echo woeid_xml.q
            if woeid_xml.q isnt place_name
                echo "get_woeid_by_place_name xml_str  wrong!"
                return
            r = woeid_xml.r
            for dk,index in r
                value = new Array()
                value.splice(0,value.length)
                d = dk.d
                k = dk.k
                #echo k
                t = d.substring(d.indexOf(":") + 1)
                t_arr = t.split("&")
                #echo t_arr
                for pt,i in t_arr
                    value.push(pt.slice(pt.indexOf("=") + 1))
                
                arr = {index:index,k:k,iso:value[0],woeid:value[1],lon:value[2],lat:value[3],s:value[4],c:value[5],pn:value[6]}
                woeid_data.push(arr)
             
            localStorage.setObject("woeid_data",woeid_data)
            callback?()
        )

    get_weather_data_by_woeid:(woeid,callback)->
        echo "woeid:" + woeid
        if !woeid
            echo "woeid :" + woeid + ",return!"
            return
        xml_str = "http://weather.yahooapis.com/forecastrss?w=" + woeid + "&u=" + DEG
        yahoo_weather_data_now = new Array()
        yahoo_weather_data_more = new Array()
        ajax(xml_str,true,(xhr)=>
            xmlDoc =  xhr.responseXML
            # echo xmlDoc
            title = xmlDoc.getElementsByTagName("item")[0].getElementsByTagName("title")[0].childNodes[0].nodeValue
            #echo title
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
            yahoo_weather_data_now.push({city:city,region:region,country:country,temperature:temperature,text_now:text_now,code_now:code_now,temp_now:temp_now,date_now:date_now})
            localStorage.setObject("yahoo_weather_data_now",yahoo_weather_data_now)

            forecast = xmlDoc.getElementsByTagNameNS("*","forecast")
            for i in [0..forecast.length-1]
                #echo forecast[i]
                day = forecast[i].getAttribute("day")
                date = forecast[i].getAttribute("date")
                low = forecast[i].getAttribute("low")
                high = forecast[i].getAttribute("high")
                text = forecast[i].getAttribute("text")
                code = forecast[i].getAttribute("code")
                yahoo_weather_data_more.push({index:i,day:day,date:date,low:low,high:high,text:text,code:code})
            
            localStorage.setObject("yahoo_weather_data_more",yahoo_weather_data_more)
            callback?()
        )
