--[[
        ExtendedBackground.lua
--]]

local ExtendedBackground, dbg = Background:newClass{ className = 'ExtendedBackground' }



--- Constructor for extending class.
--
--  @usage      Although theoretically possible to have more than one background task,
--              <br>its never been tested, and its recommended to just use different intervals
--              <br>for different background activities if need be.
--
function ExtendedBackground:newClass( t )
    return Background.newClass( self, t )
end



--- Constructor for new instance.
--
--  @usage      Although theoretically possible to have more than one background task,
--              <br>its never been tested, and its recommended to just use different intervals
--              <br>for different background activities if need be.
--
function ExtendedBackground:new( t )
    local interval
    local minInitTime
    local idleThreshold
    if app:getUserName() == '_AuthorsName_' and app:isAdvDbgEna() then
        interval = .1
        idleThreshold = 1
        minInitTime = 3
    else
        interval = .5
        idleThreshold = 2 -- (every other cycle) appx 1/sec.
        -- default min-init-time is 10-15 seconds or so.
    end    
    local o = Background.new( self, { interval=interval, minInitTime=minInitTime, idleThreshold=idleThreshold } )
    return o
end



--- Initialize background task.
--
--  @param      call object - usually not needed, but its got the name, and context... just in case.
--
function ExtendedBackground:init( call )
    local s, m = true, nil -- initialize stuff common to on-demand services as well as background task.
    if s then    
        self.initStatus = true
        -- this pref name is not assured nor sacred - modify at will.
        if not app:getPref( 'background' ) then -- check preference that determines if background task should start.
            self:quit() -- indicate to base class that background processing should not continue past init.
        end
    else
        self.initStatus = false
        app:logError( "Unable to initialize due to error: " .. str:to( m ) )
        app:show( { error="Unable to initialize." } )
    end
end



--- Perform processing when Lr/plugin seems more-or-less idle.
--
function ExtendedBackground:idleProcess( target, call )
    self:process( call, target ) -- be careful to avoid infinite recursion.
end



--- Background processing method.
--
--  @param      call object - usually not needed, but its got the name, and context... just in case.
--
function ExtendedBackground:process( call, target )

    local photo
    if not target then
        photo = catalog:getTargetPhoto() -- most-selected.
        if photo == nil then
            self:considerIdleProcessing( call )
            return
        end
    else
        photo = target
    end
    
    -- see if there is anything to do,
    if "not doing anything" then
        if not target then -- avoid infinite recursion
            self:considerIdleProcessing( call )
            return
        end
    end
    
end



return ExtendedBackground
