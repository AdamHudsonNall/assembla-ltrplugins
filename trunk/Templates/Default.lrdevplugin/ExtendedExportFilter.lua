--[[
        ExtendedExportFilter.lua
        
        Unlike most classes prefixed by the name "Extended...",
        @8/Nov/2011 14:28 there is no base "export filter" class that this to extends.
        
        Still, one day there probably will be... ###3
--]]


local ExtendedExportFilter = {}

local dbg = Object.getDebugFunction( 'ExtendedExportFilter' )



--- This function will check the status of the Export Dialog to determine 
--  if all required fields have been populated.
--
function ExtendedExportFilter._updateFilterStatus( props, name, value )
    app:call( Call:new{ name="Update Filter Status", guard=App.guardSilent, main=function( context )
        local message = nil
        repeat
        	-- Initialise potential error message.
        	
        	if props.one == nil then
        	    message = "need prop one"
        	    break
        	end
        	
        	if name == 'one' then
        	--elseif
        	--else
    	    end
            
        until true	
    	if message then
    		-- Display error.
	        props.LR_cantExportBecause = message
    
    	else
    		-- All required fields and been populated so enable Export button, reset message and set error status to false.
	        props.LR_cantExportBecause = nil
	        
    	end
    end } )
end




--- This optional function adds the observers for our required fields metachoice and metavalue so we can change
--  the dialog depending if they have been populated.
--
function ExtendedExportFilter.startDialog( propertyTable )

	propertyTable:addObserver( 'one', ExtendedExportFilter._updateFilterStatus )
	ExtendedExportFilter._updateFilterStatus( propertyTable )

end




--- This function will create the section displayed on the export dialog 
--  when this filter is added to the export session.
--
function ExtendedExportFilter.sectionForFilterInDialog( f, propertyTable )
	
	return {
		title = app:getAppName(),
		f:row {
			f:static_text {
				title = "One...",
			},
		},
		f:row {
			spacing = f:control_spacing(),
			f:static_text {
				title = "Minimum Size",
				width = share 'labels',
			},
		}
    }
	
end



ExtendedExportFilter.exportPresetFields = {
	{ key = 'one', default = 1 },
}



--- This function obtains access to the photos and removes entries that don't match the metadata filter.
--
function ExtendedExportFilter.shouldRenderPhoto( exportSettings, photo )

    -- Debug.lognpp( exportSettings )
    
    local fileFormat = photo:getRawMetadata( 'fileFormat' )
    if fileFormat == 'VIDEO' then
        return false
    end

    local targetExt = LrExportSettings.extensionForFormat( exportSettings.LR_format, photo )
    if type( targetExt ) == 'table' then -- just returns photo in case of "original" format.
        return false
    else
        if LrStringUtils.lower( targetExt ) == 'jpg' then
    	    return true
    	else
    	    -- app:logWarning( app:getAppName() .. " does not support non-jpg file format." )
    	    --return false
    	    return true
    	end
    end	
    
end



--- Post process rendered photos.
--
function ExtendedExportFilter.postProcessRenderedPhotos( functionContext, filterContext )

    local exportSettings = filterContext.propertyTable

    -- Debug.lognpp( exportSettings )
    
    local one = exportSettings.one
    if exportSettings.LR_size_doConstrain then
        if exportSettings.LR_size_resizeType == "wh" then
            -- ...
        else
            -- app:error( "Invalid resize type, only 'Width & Height' supported." )
        end
    else
        -- app:logVerbose( "No resize" )
    end

    local renditionOptions = {
        filterSettings = function( renditionToSatisfy, exportSettings )
            exportSettings.LR_format = 'ORIGINAL' -- quickest export is original (forcing rendering error by using bad format takes takes 3 seconds per photo).
            return renditionToSatisfy.destinationPath -- extension will be jpg ('twas pre-checked in should-render-photo).
        end,
    }
    for sourceRendition, renditionToSatisfy in filterContext:renditions( renditionOptions ) do
        repeat
            local success, pathOrMessage = sourceRendition:waitForRender()
            if success then
                Debug.logn( "Source \"rendition\" created at " .. pathOrMessage )
                if pathOrMessage ~= renditionToSatisfy.destinationPath then
                    app:logWarning( "Destination path mixup, expected '^1', but was '^2'", renditionToSatisfy.destinationPath, pathOrMessage )
                end
            else -- problem exporting original, which in my case is due to something in metadata blocks that Lightroom does not like.
                app:logWarning( "Unable to export '^1' to original format, error message: ^2. This may not cause a problem with this export, but does indicate a problem with the source photo.", renditionToSatisfy.destinationPath, pathOrMessage )
                pathOrMessage = renditionToSatisfy.destinationPath
            end    
            app:call( Call:new{ name="Post-Process Rendered Photo", main=function( context )
            
                -- ...
            
            end, finale=function( call, status, message )
                if status then
                    --
                else
                    app:logErr( message ) -- errors are not automatically logged for base calls, just services.
                end
            end } )
        until true
    end
end



return ExtendedExportFilter
