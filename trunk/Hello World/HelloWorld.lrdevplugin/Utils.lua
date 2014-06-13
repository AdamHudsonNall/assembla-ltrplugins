--[[
        Utils.lua
        
        Namespace shared by more than one plugin module.
        
        This can be upgraded to be a class if you prefer methods to static functions.
        Its generally not necessary though unless you plan to extend it, or create more
        than one...
--]]


local Utils, dbg = Object.register( "Utils" )



--[[
        
--]]
function Utils.func()


    dbg( str:format( "Utils Func" ) )


end


return Utils
