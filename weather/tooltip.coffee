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


tooltip_hide_id = null
class ToolTip extends Widget
    @tooltip: null
    @should_show_id: -1
    constructor: (@element, @text, @parent=document.body)->
        ToolTip.tooltip ?= create_element("div", "tooltip", @parent)
        ToolTip.tooltip.style.position = "fixed"
        ToolTip.tooltip.style.zIndex = 65530
        @event_bind('dragstart', =>
            @hide()
        )
        @event_bind('dragenter', =>
            @hide()
        )
        @event_bind('dragover', =>
            @hide()
        )
        @event_bind('dragleave', =>
            @hide()
        )
        @event_bind('dragend', =>
            @hide()
        )
        @event_bind('contextmenu', =>
            @hide()
        )
        @event_bind('mouseout', =>
            @hide()
        )
        @event_bind('mouseover', =>
            @show()
            #ToolTip.should_show_id = setTimeout(=>
                #@show()
            #, 500)
        )
        @event_bind('click', =>
            @hide()
        )

    event_bind: (evt_name, callback) ->
        @element.addEventListener(evt_name, (e) ->
            callback()
        )

    show: ->
        ToolTip.tooltip.innerText = @text
        ToolTip.tooltip.style.display = "block"
        @_move_tooltip()
    hide: ->
        #clearTimeout(ToolTip.should_show_id)
        ToolTip.tooltip?.style.display = "none"
    @move_to: (self, x, y) ->
        if y <= 0
            self.hide()
            return
        ToolTip.tooltip.style.left = "#{x}px"
        ToolTip.tooltip.style.bottom = "#{y}px"
    _move_tooltip: ->
        page_xy= get_page_xy(@element, 0, 0)
        offset = (@element.clientWidth - ToolTip.tooltip.clientWidth) / 2

        x = page_xy.x + offset + 4  # 4 for subtle adapt
        x = 0 if x < 0
        ToolTip.move_to(@, x.toFixed(), document.body.clientHeight - page_xy.y)
