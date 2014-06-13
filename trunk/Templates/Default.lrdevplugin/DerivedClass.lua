--[[
        Derived=Class.lua
--]]


local DerivedClass, dbg = BaseClass:newClass{ className = "DerivedClass", register = true }



--- Constructor for extending class.
--
function DerivedClass:newClass( t )
    return BaseClass.newClass( self, t )
end


--- Constructor for new instance.
--
function DerivedClass:new( t )
    local o = BaseClass.new( self, t )
    return o
end



function DerivedClass:one()
    app:show( self:toString() .. " one" )
end



function DerivedClass:two()
    app:show( self:toString() .. " two" )
end



return DerivedClass