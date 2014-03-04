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

include_js = (src) ->
    js_el = inject_js(src,document.body)
    swap_element(document.scripts[1],js_el)
    echo document.scripts

#include_js("plugin/weather/weatherParser.js")

clearOptions = (colls,first=0)->
    i = first
    colls.options.length = i

setMaxSize = (obj,val=@selectsize)->
    obj.size = val

array_clear = (arr) ->
    arr.splice(0,arr.length)

