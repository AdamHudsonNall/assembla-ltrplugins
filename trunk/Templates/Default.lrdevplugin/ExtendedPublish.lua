--[[
        ExtendedPublish.lua
--]]


local ExtendedPublish, dbg = Publish:newClass{ className = 'ExtendedPublish' }



--[[
        To extend special publish class, which as far as I can see,
        would never be necessary, unless this came from a template,
        and plugin author did not want to change it, but extend instead.
--]]
function ExtendedPublish:newClass( t )
    return Publish.newClass( self, t )
end



--[[
        Called to create a new object to handle the export dialog box functionality.
--]]        
function ExtendedPublish:newDialog( t )

    local o = Publish.newDialog( self, t )
    return o
    
end



--[[
        Called to create a new object to handle the export functionality.
--]]        
function ExtendedPublish:newPublish( t )

    local o = Publish.newPublish( self, t )
    return o
    
end



--   E X P O R T   D I A L O G   B O X   M E T H O D S


--[[
        Publish parameter change handler. This would be in base property-service class.
        
        Note: can not be method, since calling sequence is fixed.
        Probably best if derived class just overwrites this if property
        change handling is desired
--]]        
function ExtendedPublish:propertyChangeHandlerMethod( props, name, value )
    app:call( Call:new{ name = "pubPropChgHdlr", guard = App.guardSilent, main = function( context, props, name, value )
        -- Publish.propertyChangeHandler( props, name, value ) - presently this is a no-op.
        dbg( "Property change" )
    end }, props, name, value )
end



--[[
        Called when dialog box is opening.
        
        Maybe derived type just overwrites this one, since property names must be hardcoded
        per export.
        
        Another option would be to just add all properties to the change handler, then derived
        function can just ignore changes, or not.
--]]        
function ExtendedPublish:startDialogMethod( props )
	-- Publish.startDialogMethod( self, props ) -- presently a no-op: uncomment if that changes.
	-- props:addObserver( 'noname', Publish.propertyChangeHandler )
end



--[[
        Called when dialog box is closing.
--]]        
function ExtendedPublish:endDialogMethod( props )
    Publish.endDialogMethod( self, props )
end



--[[
        Fetch top sections of export dialog box.
        
        Base export class replicates plugin manager top section.
        Override to change or add to sections.
--]]        
function ExtendedPublish:sectionsForTopOfDialogMethod( vf, props )
    return Publish.sectionsForTopOfDialogMethod( self, vf, props )
end



--[[
        Fetch bottom sections of export dialog box.
        
        Base export class returns nothing.
        Override to change or add to sections.
--]]        
function ExtendedPublish:sectionsForBottomOfDialogMethod( vf, props )
    return Publish.sectionsForBottomOfDialogMethod( self, vf, props )
end



--   E X P O R T   M E T H O D S



--[[
        Called immediately after creating the export object which assigns
        function-context and export-context member variables.
        
        This is the one to override if you want to change everything about
        the rendering process (preserving nothing from the base export class).
--]]        
function ExtendedPublish:processRenderedPhotosMethod()
    Publish.processRenderedPhotosMethod( self )
end



--[[
        Remove photos not to be rendered, or whatever.
        
        Default behavior is to do nothing except assume
        all exported photos will be rendered. Override
        for something different...
--]]
function ExtendedPublish:checkBeforeRendering()
    Publish.checkBeforeRendering( self )
end



--[[
        Process one rendered photo.
        
        Called in the renditions loop. This is the method to override if you
        want to do something different with the photos being rendered...
--]]
function ExtendedPublish:processRenderedPhoto( rendition, photoPath )
    Publish.processRenderedPhoto( self, rendition, photoPath )
end



--[[
        Process one rendering failure.
        
        process-rendered-photo or process-rendering-failure -
        one or the other will be called depending on whether
        the photo was successfully rendered or not.
        
        Default behavior is to log an error and keep on truckin'...
--]]
function ExtendedPublish:processRenderingFailure( rendition, message )
    Publish.processRenderingFailure( self, rendition, message )
end



--[[
        Handle special export service...
        
        Note: The base export service method essentially divides the export
        task up and calls individual methods for doing the pieces. This is
        the one to override to change what get logged at the outset of the
        service, or you the partitioning into sub-tasks is not to your liking...
--]]
function ExtendedPublish:service()
    Publish.service( self )
end



--[[
        Handle special export finale...
--]]
function ExtendedPublish:finale( service, status, message )
    app:logInfo( str:format( "^1 finale, ^2 rendered.", name, str:plural( self.nPhotosRendered, "photo" ) ) )
    Publish.finale( self, service, status, message )
end



-----------------------------------------------------------------------------------------



--[=[ Generally no need to override the static functions - override the corresponding
      methods instead... Feel free to delete this entire block...

--[[
        Publish parameter change handler.
        
        Base class just calls method which is generally the function to override,
        instead of this one.
--]]        
function ExtendedPublish.propertyChangeHandler( props, name, value )
    Publish.propertyChangeHandler( props, name, value )
end



--[[
        Called when export dialog box is opening.
        
        Base function creates object and dispatches corresponding
        start dialog method.
        
        Generally no reason to override here - might as well override
        the method instead to do something different.
--]]
function ExtendedPublish.startDialog( props )
    return Publish.startDialog( props )
end



--[[
        Called when export dialog box is closing.
        
        Base class dispatches corresponding dialog method.
        
        Generally no reason to override here - might as well override
        the method instead to do something different.
--]]
function ExtendedPublish.endDialog( props )
    return Publish.endDialog( props )
end



--[[
        Called to fetch UI sections for top of dialog box.
        
        Base function just dispatches corresponding method.
        
        Generally no reason to override here - might as well override
        the method instead to do something different.
--]]
function ExtendedPublish.sectionsForTopOfDialog( vf, props )
    return Publish.sectionsForTopOfDialog( vf, props )
end



--[[
        Called to fetch UI sections for bottom of dialog box.
        
        Base function just dispatches corresponding method.
        
        Generally no reason to override here - might as well override
        the method instead to do something different.
--]]
function ExtendedPublish.sectionsForBottomOfDialog( vf, props )
    return Publish.sectionsForBottomOfDialog( vf, props )
end



--[[
        Called to process rendered photos.
        
        Base function just dispatches corresponding method.
        
        Generally no reason to override here - might as well override
        the method instead to do something different.
--]]
function ExtendedPublish.processRenderedPhotos( fc, ec )
    Publish.processRenderedPhotos( fc, ec )
end

--]=]



--   R E T U R N   E X P O R T   D E F I N I T I O N   T A B L E   T O   L I G H T R O O M

ExtendedPublish.showSections = { 'exportLocation', 'postProcessing' }
-- exportSpec.hideSections = { 'exportLocation', 'postProcessing' }

ExtendedPublish.allowFileFormats = { 'JPEG' }
-- exportSpec.hideFileFormats = { 'JPEG' }

ExtendedPublish.allowColorSpaces = { 'sRGB' }
-- exportSpec.hideColorSpaces = { 'sRGB' }

local exportParams = {}
exportParams[#exportParams + 1] = { key = 'testMode', default = false }

ExtendedPublish.exportPresetFields = exportParams

-- although these static functions seem perfectly inherited,
-- for some reason lightroom wont accept the inherited versions of these functions,
-- they must be assigned explicitly. ###2
-- No reason to override them especially, since all the base export class will do
-- is dispatch the corresponding method, which is the thing to override if desired.
ExtendedPublish.startDialog = Publish.startDialog
ExtendedPublish.endDialog = Publish.endDialog
ExtendedPublish.sectionsForTopOfDialog = Publish.sectionsForTopOfDialog
ExtendedPublish.sectionsForBottomOfDialog = Publish.sectionsForBottomOfDialog
ExtendedPublish.processRenderedPhotos = Publish.processRenderedPhotos

return ExtendedPublish

