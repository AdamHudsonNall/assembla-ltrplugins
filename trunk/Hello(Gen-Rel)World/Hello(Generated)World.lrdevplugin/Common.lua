--[[
        Common.lua
        
        Namespace shared by more than one plugin module.
        
        This can be upgraded to be a class if you prefer methods to static functions.
        Its generally not necessary though unless you plan to extend it, or create more
        than one...
--]]


local Common, dbg = Object.register( "SpecialCommon" )



--[[
        
--]]
function Common.func()


    dbg( str:format( "Common Func" ) )


end


return Common
