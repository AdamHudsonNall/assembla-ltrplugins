--[[
        ExtendedExport.lua
--]]


local ExtendedExport, dbg = Export:newClass{ className = 'ExtendedExport' }



--[[
        To extend special export class, which as far as I can see,
        would never be necessary, unless this came from a template,
        and plugin author did not want to change it, but extend instead.
--]]
function ExtendedExport:newClass( t )
    return Export.newClass( self, t )
end



--[[
        Called to create a new object to handle the export dialog box functionality.
--]]        
function ExtendedExport:newDialog( t )

    local o = Export.newDialog( self, t )
    return o
    
end



--[[
        Called to create a new object to handle the export functionality.
--]]        
function ExtendedExport:newExport( t )

    local o = Export.newExport( self, t )
    return o
    
end



--   E X P O R T   D I A L O G   B O X   M E T H O D S


--[[
        Export parameter change handler. This would be in base property-service class.
        
        Note: can not be method, since calling sequence is fixed.
        Probably best if derived class just overwrites this if property
        change handling is desired
--]]        
function ExtendedExport:propertyChangeHandlerMethod( props, name, value )
    app:call( Call:new{ name = "expPropChgHdlr", guard = App.guardSilent, main = function( context, props, name, value )
        -- Export.propertyChangeHandler( props, name, value ) - presently this is a no-op.
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
function ExtendedExport:startDialogMethod( props )
	-- Export.startDialogMethod( self, props ) -- presently a no-op: uncomment if that changes.
	-- props:addObserver( 'noname', Export.propertyChangeHandler )
end



--[[
        Called when dialog box is closing.
--]]        
function ExtendedExport:endDialogMethod( props )
    Export.endDialogMethod( self, props )
end



--[[
        Fetch top sections of export dialog box.
        
        Base export class replicates plugin manager top section.
        Override to change or add to sections.
--]]        
function ExtendedExport:sectionsForTopOfDialogMethod( vf, props )
    return Export.sectionsForTopOfDialogMethod( self, vf, props )
end



--[[
        Fetch bottom sections of export dialog box.
        
        Base export class returns nothing.
        Override to change or add to sections.
--]]        
function ExtendedExport:sectionsForBottomOfDialogMethod( vf, props )
    return Export.sectionsForBottomOfDialogMethod( self, vf, props )
end



--   E X P O R T   M E T H O D S



--[[
        Called immediately after creating the export object which assigns
        function-context and export-context member variables.
        
        This is the one to override if you want to change everything about
        the rendering process (preserving nothing from the base export class).
--]]        
function ExtendedExport:processRenderedPhotosMethod()
    Export.processRenderedPhotosMethod( self )
end



--[[
        Remove photos not to be rendered, or whatever.
        
        Default behavior is to do nothing except assume
        all exported photos will be rendered. Override
        for something different...
--]]
function ExtendedExport:checkBeforeRendering()
    Export.checkBeforeRendering( self )
end



--[[
        Process one rendered photo.
        
        Called in the renditions loop. This is the method to override if you
        want to do something different with the photos being rendered...
--]]
function ExtendedExport:processRenderedPhoto( rendition, photoPath )
    Export.processRenderedPhoto( self, rendition, photoPath )
end



--[[
        Process one rendering failure.
        
        process-rendered-photo or process-rendering-failure -
        one or the other will be called depending on whether
        the photo was successfully rendered or not.
        
        Default behavior is to log an error and keep on truckin'...
--]]
function ExtendedExport:processRenderingFailure( rendition, message )
    Export.processRenderingFailure( self, rendition, message )
end



--[[
        Handle special export service...
        
        Note: The base export service method essentially divides the export
        task up and calls individual methods for doing the pieces. This is
        the one to override to change what get logged at the outset of the
        service, or you the partitioning into sub-tasks is not to your liking...
--]]
function ExtendedExport:service()
    Export.service( self )
end



--[[
        Handle special export finale...
--]]
function ExtendedExport:finale( service, status, message )
    app:logInfo( str:format( "^1 finale, ^2 rendered.", name, str:plural( self.nPhotosRendered, "photo" ) ) )
    Export.finale( self, service, status, message )
end



-----------------------------------------------------------------------------------------



--[=[ Generally no need to override the static functions - override the corresponding
      methods instead... Feel free to delete this entire block...

--[[
        Export parameter change handler.
        
        Base class just calls method which is generally the function to override,
        instead of this one.
--]]        
function ExtendedExport.propertyChangeHandler( props, name, value )
    Export.propertyChangeHandler( props, name, value )
end



--[[
        Called when export dialog box is opening.
        
        Base function creates object and dispatches corresponding
        start dialog method.
        
        Generally no reason to override here - might as well override
        the method instead to do something different.
--]]
function ExtendedExport.startDialog( props )
    return Export.startDialog( props )
end



--[[
        Called when export dialog box is closing.
        
        Base class dispatches corresponding dialog method.
        
        Generally no reason to override here - might as well override
        the method instead to do something different.
--]]
function ExtendedExport.endDialog( props )
    return Export.endDialog( props )
end



--[[
        Called to fetch UI sections for top of dialog box.
        
        Base function just dispatches corresponding method.
        
        Generally no reason to override here - might as well override
        the method instead to do something different.
--]]
function ExtendedExport.sectionsForTopOfDialog( vf, props )
    return Export.sectionsForTopOfDialog( vf, props )
end



--[[
        Called to fetch UI sections for bottom of dialog box.
        
        Base function just dispatches corresponding method.
        
        Generally no reason to override here - might as well override
        the method instead to do something different.
--]]
function ExtendedExport.sectionsForBottomOfDialog( vf, props )
    return Export.sectionsForBottomOfDialog( vf, props )
end



--[[
        Called to process rendered photos.
        
        Base function just dispatches corresponding method.
        
        Generally no reason to override here - might as well override
        the method instead to do something different.
--]]
function ExtendedExport.processRenderedPhotos( fc, ec )
    Export.processRenderedPhotos( fc, ec )
end

--]=]



--   R E T U R N   E X P O R T   D E F I N I T I O N   T A B L E   T O   L I G H T R O O M

ExtendedExport.showSections = { 'exportLocation', 'postProcessing' }
-- exportSpec.hideSections = { 'exportLocation', 'postProcessing' }

ExtendedExport.allowFileFormats = { 'JPEG' }
-- exportSpec.hideFileFormats = { 'JPEG' }

ExtendedExport.allowColorSpaces = { 'sRGB' }
-- exportSpec.hideColorSpaces = { 'sRGB' }

local exportParams = {}
exportParams[#exportParams + 1] = { key = 'testMode', default = false }

ExtendedExport.exportPresetFields = exportParams

-- although these static functions seem perfectly inherited,
-- for some reason lightroom wont accept the inherited versions of these functions,
-- they must be assigned explicitly. ###2
-- No reason to override them especially, since all the base export class will do
-- is dispatch the corresponding method, which is the thing to override if desired.
ExtendedExport.startDialog = Export.startDialog
ExtendedExport.endDialog = Export.endDialog
ExtendedExport.sectionsForTopOfDialog = Export.sectionsForTopOfDialog
ExtendedExport.sectionsForBottomOfDialog = Export.sectionsForBottomOfDialog
ExtendedExport.processRenderedPhotos = Export.processRenderedPhotos

return ExtendedExport

