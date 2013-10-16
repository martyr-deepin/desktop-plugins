class Clock extends Widget
    backgroud = null
    
    constructor: (@id)->
        super
        if localStorage.getItem("clock_backgroud")
            backgroud = localStorage.getItem("clock_backgroud")
        else
            backgroud = "clockface_circle.png"
            localStorage.setItem("clock_backgroud",backgroud)
            
        @face = create_img("ClockFace", "#{plugin.path}/#{backgroud}", @element)
        @sec = create_img("HandleSec", "#{plugin.path}/sechand.png", @element)
        @min= create_img("HandleMin", "#{plugin.path}/minhand.png", @element)
        @hour = create_img("HandleHour", "#{plugin.path}/hourhand.png", @element)
            
        @update_look()
        setInterval(=>
            @update_look()
        , 1000)

    update_look: ->
        date = new Date()
        srotate = "rotate(#{date.getSeconds() * 6}deg)"
        mrotate = "rotate(#{date.getMinutes() * 6}deg)"
        hrotate = "rotate(#{date.getHours() * 30 + date.getMinutes() / 2}deg)"

        @sec.style.webkitTransform = srotate
        @min.style.webkitTransform = mrotate
        @hour.style.webkitTransform = hrotate
    
    do_rightclick:(evt) ->
        evt.stopPropagation()
        menu = []
        menu.push([1,_("Change clock skin")])
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

plugin = PluginManager.get_plugin("clock")
plugin.inject_css("clock")
plugin.wrap_element(new Clock(plugin.id).element)
