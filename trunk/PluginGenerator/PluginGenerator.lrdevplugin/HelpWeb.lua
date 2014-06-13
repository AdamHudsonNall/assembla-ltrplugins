--[[
        Help.lua
--]]

local Help, dbg = Object.register( "HelpWeb", false )



--- Shows plugin help web-page to user via browser.
--      
--  <p>Accessed directly from plugin menu.</p>
--
function Help.onTheWeb()

    LrHttp.openUrlInBrowser( app:getPluginUrl() )

end


Help.onTheWeb()
    
    

