--[[
        Disable.lua
--]]

-- under unusual circumstances, app may not yet created when this is called.
if rawget( _G, 'app' ) then
    app:call( Call:new{ name='Disable', async=false, guard=App.guardSilent, main=function( call )
        app:log( "^1 is disabled - it must be enabled for menu, metadata, and/or export functionality...", app:getAppName() )
    end } )
end
