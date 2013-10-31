#Copyright (c) 2012 ~ 2013 Deepin, Inc.
#              2012 ~ 2013 bluth
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

set_menu_position2 = (obj,bottom_distance,x1,y1,x2,y2,show = "block")->
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

set_menu_position = (obj,bottom_distance,y1,y2,show = "block")->
    obj.style.display = "block"
    height = obj.clientHeight
    obj.style.display = "none"
    if bottom_distance < height
        obj.style.top = y2
        obj.style.borderRadius = "6px 6px 0 0"
    else
        obj.style.top = y1
        obj.style.borderRadius = "0 0 6px 6px"
    obj.style.display = show

clearOptions = (colls,first=0)->
    i = first
    colls.options.length = i

setMaxSize = (obj,val=@selectsize)->
    obj.size = val

create_option = (obj,data)->
    for i of data
        obj.options.add(new Option(data[i].name, i))

day_en_zh = (day) ->
    switch(day)
        when "Sun" then return _("Sun")
        when "Mon" then return _("Mon")
        when "Tue" then return _("Tue")
        when "Wed" then return _("Wed")
        when "Thu" then return _("Thu")
        when "Fri" then return _("Fri")
        when "Sat" then return _("Sat")
        else echo "no this day:" + day
