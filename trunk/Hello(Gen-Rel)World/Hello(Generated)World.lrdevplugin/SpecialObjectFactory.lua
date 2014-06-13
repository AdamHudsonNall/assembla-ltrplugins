--[[
        SpecialObjectFactory.lua
        
        Creates special objects used in the guts of the framework.
        
        This is what you edit to change the classes of framework objects
        that you have extended.
--]]

local SpecialObjectFactory, dbg = ObjectFactory:newClass{ className = 'SpecialObjectFactory', register = false }



--- Constructor for extending class.
--
--  @usage  I doubt this will be necessary, since there is generally
--          only one special object factory per plugin, mostly present
--          for the sake of completeness...
--
function SpecialObjectFactory:newClass( t )
    return ObjectFactory.newClass( self, t )
end



--- Constructor for new instance.
--
function SpecialObjectFactory:new( t )
    local o = ObjectFactory.new( self, t )
    return o
end



--- Creates instance object of specified class.
--
--  @param      class       class object OR string specifying class.
--  @param      ...         initial table params forwarded to 'new' constructor.
--
function SpecialObjectFactory:newObject( class, ... )
    if type( class ) == 'table' then
    elseif type( class ) == 'string' then
        if class == 'SpecialManager' then
            return SpecialManager:new( ... )
        elseif class == 'ExportDialog' then
            return SpecialExport:newDialog( ... )
        elseif class == 'Export' then
            return SpecialExport:newExport( ... )
        end
    end
    return ObjectFactory.newObject( self, class, ... )
end



return SpecialObjectFactory 