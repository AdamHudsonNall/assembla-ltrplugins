--[[
        SpecialBackground.lua
--]]

local SpecialBackground, dbg = Background:newClass{ className = 'SpecialBackground' }



--- Constructor for extending class.
--
function SpecialBackground:newClass( t )
    return Background.newClass( self, t )
end



--- Constructor for new instance.
--
function SpecialBackground:new( t )
    local o = Background.new( self, { interval = .5, minInitTime = nil } ) -- default min-init-time is 10-15 seconds or so.
    return o
end



--- Initialize background task.
--
--  @param      call object - usually not needed, but its got the name, and context... just in case.
--
function SpecialBackground:init( call )
    local s, m = true, nil -- initialize stuff common to on-demand services as well as background task.
    if s then    
        self.initStatus = true
        if not app:getPref( 'background' ) then -- check preference that determines if background task should start.
            self:quit() -- indicate to base class that background processing should not continue past init.
        end
    else
        self.initStatus = false
        app:logError( "Unable to initialize due to error: " .. str:to( m ) )
        app:showError( "Unable to initialize." )
    end
end



--- Background processing method.
--
--  @param      call object - usually not needed, but its got the name, and context... just in case.
--
function SpecialBackground:process( call )

    local photo = catalog:getTargetPhoto() -- most-selected.
    if photo == nil then
        return
    end
    
end



return SpecialBackground
