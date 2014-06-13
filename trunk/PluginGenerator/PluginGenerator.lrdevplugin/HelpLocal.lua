--[[
        Help.lua
--]]

local Help, dbg = Object.register( 'HelpLocal', false )


--- Shows help text to user as quick tips.
--      
--  <p>Accessed directly from plugin menu.</p>
--      
function Help.tips()

    app:call( Call:new{ name="Help Local", async=true, main=function( call )
    
        local p = {}
        p[#p + 1] = "Nuthin to see here..."
        
        dialog:quickTips( p )
        
    end } )
end


Help.tips()
    
    

