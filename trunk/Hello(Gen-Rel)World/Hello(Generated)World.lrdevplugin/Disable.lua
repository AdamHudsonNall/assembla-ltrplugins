--[[
        Disable.lua
--]]

app:call( Call:new{ name='Disable', async=false, guard=App.guardSilent, main=function( call )
    _G.enabled = false
    dialog:showInfo( app:getAppName() .. " is disabled - it must be enabled for menu, metadata, and/or export functionality..." )
end } )
