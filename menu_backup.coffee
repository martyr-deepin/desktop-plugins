#------------------weather-------------------------

#new menu for 2014
    do_buildmenu: =>
        menu = []
        switch localStorage.getItem("temp_danwei")
            when "c" then menu.push([1,_("Switch to Fahrenheit")])
            when "f" then menu.push([1,_("Switch to Celsius")])
            else localStorage.setItem("temp_danwei","c")
        menu

    on_itemselected:(evt) =>
        DEG = localStorage.getItem("temp_danwei")
        id = parseInt(evt)
        switch id
            when 1
                if DEG is "f" then localStorage.setItem("temp_danwei","c")
                else if DEG is "c" then localStorage.setItem("temp_danwei","f")
                else localStorage.setItem("temp_danwei","c")
                @weathergui_refresh_Interval()


#old menu for 2013
    do_rightclick:(evt) ->
        evt.stopPropagation()
        menu = []
        switch localStorage.getItem("temp_danwei")
            when "c" then menu.push([1,_("Switch to Fahrenheit")])
            when "f" then menu.push([1,_("Switch to Celsius")])
            else localStorage.setItem("temp_danwei","c")
        @element.contextMenu = build_menu(menu)
     
    do_itemselected:(evt) =>
        DEG = localStorage.getItem("temp_danwei")
        switch evt.id
            when 1
                if DEG is "f" then localStorage.setItem("temp_danwei","c")
                else if DEG is "c" then localStorage.setItem("temp_danwei","f")
                else localStorage.setItem("temp_danwei","c")
                @weathergui_refresh_Interval()


#------------------clock-------------------------

#new menu for 2014
    do_buildmenu: ->
        menu = []
        menu.push([1,_("Change appearance")])
        menu

    on_itemselected:(evt) =>
        id = parseInt(evt)
        switch id
            when 1
                if backgroud is "clockface_circle.png" then backgroud = "clockface_rect.png"
                else if backgroud is "clockface_rect.png" then backgroud = "clockface_circle.png"
                else
                    backgroud = "clockface_circle.png"
                localStorage.setItem("clock_backgroud",backgroud)
                @face.src = "#{plugin.path}/#{backgroud}"


#old menu for 2013
    
    do_rightclick:(evt) ->
        evt.stopPropagation()
        menu = []
        menu.push([1,_("Change appearance")])
        @face.parentElement.contextMenu = build_menu(menu)
    
    do_itemselected:(evt) =>
        switch evt.id
            when 1
                if backgroud is "clockface_circle.png" then backgroud = "clockface_rect.png"
                else if backgroud is "clockface_rect.png" then backgroud = "clockface_circle.png"
                else
                    backgroud = "clockface_circle.png"
                localStorage.setItem("clock_backgroud",backgroud)
                @face.src = "#{plugin.path}/#{backgroud}"

