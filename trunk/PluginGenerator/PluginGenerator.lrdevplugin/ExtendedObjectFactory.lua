--[[
        ExtendedObjectFactory.lua
        
        Creates objects used in the guts of the framework.
        Serves as a hook for apps to be able to control the classes of objects that get created,
        without having to override gobs of stuff to get to them.
--]]

local ExtendedObjectFactory, dbg = ObjectFactory:newClass{ className = 'ExtendedObjectFactory', register = false }


--- Constructor for extending class.
--
function ExtendedObjectFactory:newClass( t )
    return ObjectFactory.newClass( self, t )
end



--- Constructor for new instance of special object factory.
--
function ExtendedObjectFactory:new( t )
    local o = ObjectFactory.new( self, t )
    return o
end



--- Creates new object based on name.
--
--  @param      className       Could be anything as long as requestor and provider agree, but full base class-name is recommended.
--  @param      ...             passed to instance constructor.
--
--  @usage      Throws error if object not creatable (e.g. name not recognized).
--
--  @return     Specified object.
--
function ExtendedObjectFactory:newObject( class, ... )
    if type( class ) == 'table' then
        --if class == Manager then
        --    return ExtendedManager:new( ... )
        --end
    elseif type( class ) == 'string' then
        if class == 'Manager' then
            return ExtendedManager:new( ... )
        elseif class == 'ExportDialog' then
            return ExtendedExport:newDialog( ... )
        elseif class == 'Export' then
            return ExtendedExport:newExport( ... )
        end
    end
    return ObjectFactory.newObject( self, class, ... )
end



return ExtendedObjectFactory