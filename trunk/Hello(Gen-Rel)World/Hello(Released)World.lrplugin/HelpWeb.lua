--[[
        HelpWeb.lua
--]]


local Help = {}


local dbg = Object.getDebugFunction( 'HelpWeb' ) -- Usually not registered for conditional dbg support via plugin-manager, but can be (in Init.lua).



--[[
        Synopsis:           Provides help text as quick tips.
        
        Notes:              Accessed directly from plugin menu.
        
        Returns:            X
--]]        
function Help.onTheWeb()

    app:call( Call:new{ name = "Web Help", main=function( call )

        LrHttp.openUrlInBrowser( app:getPluginUrl() ) -- get-plugin-url returns a proper url for plugin else site home.
        
    end } )
end


Help.onTheWeb()    
    

