--[[
        Enable.lua
--]]

app:call( Call:new{ name='Enable', async=false, guard=App.guardSilent, main=function( call )
    _G.enabled = true
    dialog:showInfo( app:getAppName() .. " menu, metadata, and/or export functions are now enabled." )
end } )
