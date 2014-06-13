--[[
        LibraryMenuItem.lua
        
        Feel free to downgrade from class to reglar table object and delete constructors
        if not taking advantage of class methods...
--]]


local LibraryMenuItem = {}


local dbg = Object.getDebugFunction( 'LibraryMenuItem' ) -- Register for conditional dbg support via plugin-manager, if desired (in Init.lua).



--[[
        
--]]
function LibraryMenuItem.main()
    app:call( Service:new{ name = "Perform Test", async = true, guard=App.guardVocal, main = function( call )
        dbg( "LibraryMenuItem" )
    end } )
end



LibraryMenuItem.main()
