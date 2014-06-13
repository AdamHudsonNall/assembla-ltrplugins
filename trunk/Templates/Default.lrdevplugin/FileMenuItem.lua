--[[
        FileMenuItem.lua
        
        Handles file menu item.
        
        Note: this class may very well not be the base class of anything, but instead
        be cloned and renamed..., in which case the constructors can be deleted,
        and it can be downgraded to a reglar table object instead of class.
--]]

local FileMenuItem = {} -- register the name of this item in init.lua for conditional dbg support via plugin manager.

local dbg = Object.getDebugFunction( 'FileMenuItem' )



--[[
        
--]]
function FileMenuItem.main()
    app:call( Service:new{ name = "File Menu Item", async = true, guard=App.guardVocal, main = function( service ) -- Make simple Call to avoid log prompt.
        dbg( "FileMenuItem" )
    end } )
end


FileMenuItem.main()
