--[[
        BaseClass.lua
--]]


local BaseClass, dbg = Object:newClass{ className = "BaseClass", register = true }



--- Constructor for extending class.
--
function BaseClass:newClass( t )
    return Object.newClass( self, t )
end


--- Constructor for new instance.
--
function BaseClass:new( t )
    local o = Object.new( self, t )
    return o
end



function BaseClass:one()
    app:show( self:toString() .. " one" )
end



function BaseClass:two()
    app:show( self:toString() .. " two" )
end



return BaseClass