--[[
        Generate.lua
--]]

local Generate, dbg = Object:newClass{ className = 'Generate' }

local lrLoad = {}
local fmwkLoad = {}
local pluginLoad = {}

local spec
local templateDir
local templatePluginDir
local devPluginDir
local relSpec
local prjDir
local pluginDir
local overwrite



--- Constructor for extending class.
--
function Generate:newClass( t )
    return Object.newClass( self, t )
end



--- Constructor for new instance.
--
function Generate:new( t )
    local o = Object.new( self, t )
    o.genRel = GenRelCommon:new() -- use new-object method of object-factory if extension of common object is desired.
    return o
end



--- Copy file from src (template) dir to dest (plugin-dir).
--
function Generate:copyTemplateFile( file )

    assert( overwrite ~= nil, "overwrite uninit" )

    local src = LrPathUtils.child( templatePluginDir, file )
    
    if fso:existsAsFile( src ) then
        -- cool
    else
        error( "No file: " .. src ) -- gotta fix copy-file up with distinguishing errors.
    end
    
    local dest = LrPathUtils.child( devPluginDir, file )
    if fso:existsAsFile( dest ) and not overwrite then
        app:logInfo( "Not overwriting " .. dest )
        return
    end
    local s, m = fso:copyFile( src, dest, false, overwrite ) -- create dirs false (already created), overwrite true.
    if s then
        app:logInfo( str:format( "Copied ^1", file ) ) -- filename is enough since src & dest dirs already logged.
    else
        error( m )
    end

end



function Generate:_includeModule( array, name, subPath )
    array[#array + 1] = { name=name, subPath=subPath }
end
function Generate:frameworkModule( name, subPath )
    self:_includeModule( fmwkLoad, name, subPath )
end
function Generate:pluginModule( name, subPath ) -- include plugin module
    if subPath == nil then
        subPath = name
    end
    self:_includeModule( pluginLoad, name, subPath )
end



--- Generate init-lua file.
--
--  <p>Replaces marked blocks in template with something (hopefully) better.</p>
--  <p>Markers: GEN_BEGIN {block-name} / GEN_END</p>
--  <p>Blocks:</p><ul>
--      <li>frameworkDir
--      <li>globals
--      <li>finale</ul>
--
--  @usage      Throws error if trouble.
--
function Generate:writeInitLua( lineBuf, dest )

    local src = LrPathUtils.child( templatePluginDir, "Init.lua" )
    local initLuaBefore, orNot = fso:readTextFile( src )
    if not str:is( initLuaBefore ) then
        error( orNot )
    end
    local initTbl = self.genRel:tokenize( "GEN", initLuaBefore )
    if tab:isEmpty( initTbl ) then
        error( "No init tbl" )
    end
    local blksToDo = {}
    blksToDo.frameworkDir = true
    blksToDo.globals = true
    -- blksToDo.finale = true - optional
    
    local lines = {}
    for i,subTbl in ipairs( initTbl ) do
    
        local name = subTbl.name
        
        if name == nil then
            -- dbg( "nil" )
            tab:appendArray( lines, subTbl )
        elseif name == 'frameworkDir' then
        
            -- dbg( "fmwk" )
            blksToDo[name] = nil
            if LrPathUtils.isAbsolute( spec.frameworkDir ) then
                lines[#lines + 1] = str:format( '    local frameworkDir = "^1"', spec.frameworkDir )
            else
                local _destDir = devPluginDir:gsub( "\\", "\\\\" ) -- standardized windows path needs backslashes escaped.
                lines[#lines + 1] = str:format( "    local LrPathUtils = import 'LrPathUtils'" )
                lines[#lines + 1] = str:format( '    local frameworkDir = LrPathUtils.makeAbsolute( "^1", "^2" )', spec.frameworkDir, _destDir )
            end
            -- lines[#lines + 1] = subTbl[#subTbl]
        
        elseif name == 'globals' then
            -- dbg( "globals" )
            blksToDo[name] = nil
            local gblBuf = {}
            for k,v in tab:sortedPairs( lrLoad ) do
                gblBuf[#gblBuf + 1] = "_G." .. k .. " = import '" .. k .. "'"
            end
            if not tab:isEmpty( spec.addLightroom ) then
                for i,k in tab:sortedPairs( spec.addLightroom ) do -- Lightorom modules are in alphabetical order.
                    gblBuf[#gblBuf + 1] = "_G." .. k .. " = import '" .. k .. "'"
                end
            end
            for i, v in ipairs( fmwkLoad ) do
                gblBuf[#gblBuf + 1] = str:fmt( '_G.^1 = require( "^2" )', v.name, v.subPath )
            end
            if not tab:isEmpty( spec.addFramework ) then -- make array? ###1
                for k,v in tab:sortedPairs( spec.addFramework ) do
                    gblBuf[#gblBuf + 1] = "_G." .. k .. " = require( '" .. v .. "' )"
                end
            end
            for i, v in ipairs( pluginLoad ) do
                gblBuf[#gblBuf + 1] = str:fmt( '_G.^1 = require( "^2" )', v.name, v.subPath )
            end
            if not tab:isEmpty( spec.addPlugin ) then -- make array? ###1
                for i,k in tab:sortedPairs( spec.addPlugin ) do
                    gblBuf[#gblBuf + 1] = "_G." .. k .. " = require( '" .. k .. "' )"
                end
            end

            tab:appendArray( lines, gblBuf )
            -- lines[#lines + 1] = subTbl[#subTbl]
            
        elseif name == 'finale' then

            blksToDo[name] = nil
            if not tab:isEmpty( lineBuf ) then
                tab:appendArray( lines, lineBuf )
                -- lines[#lines + 1] = subTbl[#subTbl]
            end
    
        else
                    
            app:logWarning( str:format( "Not programmed for block named '^1' in init-lua, carrying unmodified. ", name ) )
            tab:appendArray( lines, subTbl )
            
        end

    end
    
    if not tab:isEmpty( blksToDo ) then
        error( "Missing init blocks" )
    end
    
    local out = table.concat( lines, '\n' )
    -- dbg( out:sub( 1, 500 ) )
    local status, message = fso:writeFile( dest, out )
    if not status then
        error( message )
    end
    
end



--- Generate info-lua file.
--
--  <p>Replaces marked blocks in template with something (hopefully) better.</p>
--  <p>Markers: GEN_BEGIN {block-name} / GEN_END</p>
--  <p>Blocks:</p><ul>
--      <li>main</ul>
--
--  @usage      Throws error if trouble.
--
function Generate:writeInfoLua( lineBuf, dest )

    local src = LrPathUtils.child( templatePluginDir, "Info.lua" )
    local infoLuaBefore, orNot = fso:readTextFile( src )
    if not str:is( infoLuaBefore ) then
        error( orNot )
    end
    local infoTbl = self.genRel:tokenize( "GEN", infoLuaBefore )
    if tab:isEmpty( infoTbl ) then
        error( "No info tbl" )
    end
    local blksToDo = {}
    blksToDo.main = true
    local lines = {}
    for i,subTbl in ipairs( infoTbl ) do
    
        local name = subTbl.name
        
        if name == nil then
            -- dbg( "info" )
            tab:appendArray( lines, subTbl )
        elseif name == 'main' then
            -- dbg( "info-main" )
            blksToDo[name] = nil
            tab:appendArray( lines, lineBuf )
            -- lines[#lines + 1] = subTbl[#subTbl]
        else
            app:logWarning( str:format( "Not programmed for block named '^1' in info-lua, carrying unmodified. ", name ) )
            tab:appendArray( lines, subTbl )
        end            

    end

    if not tab:isEmpty( blksToDo ) then
        error( "Missing info blocks" )
    end
    
    local out = table.concat( lines, '\n' )
    -- dbg( out:sub( 1, 500 ) )
    local status, message = fso:writeFile( dest, out )
    if not status then
        error( message )
    end
    
end



--- Generate plugin.
--
--  <p>Called as button handler from plugin manager - self wrapped.</p>
--
--  @usage starts with template plugin files, and combined with spec in config file - creates and populates lrdevplugin folder.
--
function Generate:generate()

    app:call( Service:new{ name = "Generate Plugin", async=true, guard=App.guardVocal, main=function( service )

        overwrite = false

        spec = app:getPref( 'pluginSpec' )
        assert( spec, "no spec" )

        if LrPathUtils.isAbsolute( spec.templateDir ) then
            templateDir = LrPathUtils.standardizePath( spec.templateDir )
        else
            templateDir = LrPathUtils.child( LrPathUtils.parent( _PLUGIN.path ), spec.templateDir )
        end
        templatePluginDir = LrPathUtils.child( templateDir, spec.templatePluginFolder )
        if fso:existsAsDirectory( templateDir ) then
            app:logInfo( "Template dir: " .. templateDir )
        else
            error( "template dir does not exist: " .. templatePluginDir )
        end
        if fso:existsAsDirectory( templatePluginDir ) then
            app:logInfo( "Source plugin dir: " .. templatePluginDir )
        else
            error( "template plugin dir does not exist: " .. templatePluginDir )
        end
        devPluginDir = LrPathUtils.standardizePath( spec.devPluginDir )
        if LrPathUtils.isAbsolute( devPluginDir ) then
            if fso:existsAsDirectory( devPluginDir ) then
                local answer
                answer = app:show( { info="*** WARNING: YOU ARE ABOUT TO DELETE A PLUGIN'S SOURCE CODE DIRECTORY!!!\n\nAre you sure you want to delete ^1 and re-fill with skeleton files?", buttons={{label="Yes - Delete",verb='ok'},{label="Cancel Generation",verb='cancel'},{label="No - Do Not Delete",verb='other'}} }, devPluginDir )
                if answer == 'ok' then
                    local deleted, errm = self.genRel:deleteTree( devPluginDir )
                    if deleted then
                        app:logInfo( "Pre-deleted " .. devPluginDir )
                    else
                        error( "Unable to pre-delete, error message: " .. str:to( errm ) )
                    end
                elseif answer == 'cancel' then
                    app:logInfo( "User canceled plugin generation due to pre-existing plugin source directory..." )
                    return
                elseif answer=='other' then
                    answer = app:show( { info="*** WARNING: YOU ARE ABOUT TO OVERWRITE SOURCE FILES IN A PRE-EXISTING PLUGIN DIRECTORY!!!\n\nAre you sure you want to overwrite source files in ^1?", buttons={{label="Yes - Overwrite",verb='ok'},{label="Cancel Generation",verb='cancel'},{label="No - Do Not Overwrite",verb='other'}} }, devPluginDir )
                    if answer == 'ok' then
                        -- ok, proceed
                        overwrite = true
                        app:logInfo( "*** Overwrite enabled." )
                    elseif answer == 'cancel' then
                        app:logInfo( "User canceled plugin generation due to pre-existing plugin source files..." )
                        return
                    elseif answer == 'other' then
                        -- proceed, but no files will be overwritten.
                        -- this is valuable for being able to regenerate a plugin in order to add options that were not there before.
                        app:logInfo( "*** Overwrite disabled." )
                    else
                        error( "bad answer" )
                    end
                else
                    error( "bad answer" )
                end
            else
                app:logInfo( "Generating plugin into non-existing directory." )
            end
        else
            error( "Not sure where this is going to end up: " .. devPluginDir )
        end
        
        local file = app.prefMgr:getPrefSupportFile()
        if not dialog:isOk( str:format( "Generate plugin based on '^1' settings?", file ) ) then
            service:abort( "User aborted." )
            return
        end
        
        local status, qual, created = fso:assureAllDirectories( devPluginDir )
        if status then
            -- assert( fso:existsAsDirectory( devPluginDir ), "No dest dir: " .. devPluginDir )
            assert( LrFileUtils.exists( devPluginDir ), "No dev plugin dir: " .. devPluginDir )
            app:logInfo( "Dest: " .. devPluginDir )
        else
            error( str:to( qual ) )
        end    
        
        if spec.resources then
            local resourceDir = LrPathUtils.child( devPluginDir, 'Resources' ) -- presently not populated, thus 'local'.
            local status, qual, created = fso:assureAllDirectories( resourceDir )
            if status then
                assert( LrFileUtils.exists( resourceDir ), "No resource dir: " .. resourceDir )
                app:logInfo( "Resource dir created: " .. resourceDir )
            else
                error( str:to( qual ) )
            end    
        end                
        
        -- initialize buffers
        local initBuf = {} -- only used in finale section at the moment.
        local infoBuf = {}
        
        infoBuf[#infoBuf + 1] = '    appName = "' .. spec.appName .. '",'
        infoBuf[#infoBuf + 1] = '    author = "' .. spec.author .. '",'
        infoBuf[#infoBuf + 1] = '    authorsWebsite = "' .. spec.authorsWebsite .. '",'
        if spec.donateUrl then
            infoBuf[#infoBuf + 1] = '    donateUrl = "' .. spec.donateUrl .. '",'
        -- else donate-url = nil
        end
        infoBuf[#infoBuf + 1] = '    platforms = ' .. spec.platforms .. ','
        if spec.pluginId then
            infoBuf[#infoBuf + 1] = '    pluginId = "' .. spec.pluginId .. '",'
        end
        if spec.xmlRpcUrl then
            -- info
            infoBuf[#infoBuf + 1] = '    xmlRpcUrl = "' .. spec.xmlRpcUrl .. '",'
        end
        infoBuf[#infoBuf + 1] = '    LrPluginName = "' .. spec.devPluginName .. '",'
        infoBuf[#infoBuf + 1] = '    LrSdkMinimumVersion = ' .. spec.lrSdkMin .. ','
        infoBuf[#infoBuf + 1] = '    LrSdkVersion = ' .. spec.lrSdkMax .. ','
        infoBuf[#infoBuf + 1] = '    LrPluginInfoUrl = "' .. spec.pluginUrl .. '",'
        
        if spec.extendedManager then
            self:copyTemplateFile( "ExtendedManager.lua" )
            self:pluginModule( "ExtendedManager" )
            initBuf[#initBuf + 1] = "ExtendedManager.initPrefs() -- remember to include all dependent plugin prefs (plugin generator is not helping in this regard, yet)"
            infoBuf[#infoBuf + 1] = '    LrPluginInfoProvider = "ExtendedManager.lua",'
        else
            initBuf[#initBuf + 1] = "Manager.initPrefs()"
        end
        
        infoBuf[#infoBuf + 1] = '    LrToolkitIdentifier = "' .. spec.devToolkitId .. '",'
        infoBuf[#infoBuf + 1] = '    LrInitPlugin = "Init.lua",'
        if spec.shutdown then
            infoBuf[#infoBuf + 1] = '    LrShutdownPlugin = "Shutdown.lua",'
            self:copyTemplateFile( "Shutdown.lua" )
        end
        if spec.enable then
            infoBuf[#infoBuf + 1] = '    LrEnablePlugin = "Enable.lua",'
            self:copyTemplateFile( "Enable.lua" )
        end
        if spec.disable then
            infoBuf[#infoBuf + 1] = '    LrDisablePlugin = "Disable.lua",'
            self:copyTemplateFile( "Disable.lua" )
        end
        
        if spec.export then
            lrLoad["LrExportSession"] = true
            lrLoad["LrExportSettings"] = true
            self:frameworkModule( "Export", "ExportAndPublish/Export" ) -- load as global.
            self:copyTemplateFile( "ExtendedExport.lua" )
            self:pluginModule( "ExtendedExport" )
            fso:assureAllDirectories( LrPathUtils.child( devPluginDir, "Export Presets" ) ) -- export presets are not being copied, nor publish presets: they are unique to extended export (no templates).
            infoBuf[#infoBuf + 1] = "    LrExportServiceProvider = {"
            infoBuf[#infoBuf + 1] = '        title = "' .. spec.export .. '",'
            infoBuf[#infoBuf + 1] = '        file = "ExtendedExport.lua",'
            infoBuf[#infoBuf + 1] = '        builtInPresetsDir = "Export Presets",' -- no-op if no presets.
            infoBuf[#infoBuf + 1] = "    },"
        end
        
        if spec.exportFilterName then
            assert( str:is( spec.exportFilterId ), "need export filter id along with name" )
            self:copyTemplateFile( "ExtendedExportFilter.lua" )
            self:pluginModule( "ExtendedExportFilter" )
            infoBuf[#infoBuf + 1] = "    LrExportFilterProvider = {"
            infoBuf[#infoBuf + 1] = '        title = "' .. spec.exportFilterName .. '",'
            infoBuf[#infoBuf + 1] = '        file = "ExtendedExportFilter.lua",'
            infoBuf[#infoBuf + 1] = '        id = "' .. spec.exportFilterId .. '",'
            infoBuf[#infoBuf + 1] = "    },"
        end
        
        if spec.publish then
            lrLoad["LrExportSession"] = true
            lrLoad["LrExportSettings"] = true
            self:frameworkModule( "Publish", "ExportAndPublish/Publish" ) -- load as global.
            self:copyTemplateFile( "ExtendedPublish.lua" )
            self:pluginModule( "ExtendedPublish" )
            fso:assureAllDirectories( LrPathUtils.child( devPluginDir, "Publish Presets" ) )
            infoBuf[#infoBuf + 1] = "    LrExportServiceProvider = {"
            infoBuf[#infoBuf + 1] = '        title = "' .. spec.publish .. '",'
            infoBuf[#infoBuf + 1] = '        file = "ExtendedPublish.lua",' -- no presets.
            infoBuf[#infoBuf + 1] = "    },"
        end
        
        if spec.tagsets then
            spec.catalog = true
            infoBuf[#infoBuf + 1] = '    LrTagsetProvider = "Tagsets.lua",'
            self:copyTemplateFile( "Tagsets.lua" )
        end
        
        if spec.metadata then
            spec.catalog = true
            -- Note: metadata manager comes for free unless excluded via object factory framework module loader method.
            infoBuf[#infoBuf + 1] = '    LrMetadataProvider = "Metadata.lua",'
            self:copyTemplateFile( "Metadata.lua" )
        end

        if spec.exifToolPref or spec.mogrifyPref or spec.sqlitePref then
            self:frameworkModule( "ExternalApp", "System/ExternalApp" )
        end

        if spec.exifToolPref then
            self:frameworkModule( "ExifTool", "ExternalApps/ExifTool" )
            initBuf[#initBuf + 1] = str:fmt( '_G.exifTool = ExifTool:new{ prefName="^1" }', spec.exifToolPref )
            self:copyTemplateFile( "exiftool.exe" )
        end
        
        if spec.catalog then -- 
            -- catalog may be too general a category... ###3
        end
        
        if spec.xmlRpcUrl then
            lrLoad["LrXml"] = true
            self:frameworkModule( "XmlRpc", "Communication/XmlRpc" )
        end
        
        if spec.background then
            self:frameworkModule( "Background", "System/Background" )
            self:pluginModule( "ExtendedBackground" )
            self:copyTemplateFile( "ExtendedBackground.lua" )
            initBuf[#initBuf + 1] = 'background = ExtendedBackground:new()'
        end
        
        if spec.helpLocal or spec.helpWeb or spec.reload then
            infoBuf[#infoBuf + 1] = "    LrHelpMenuItems = {"
            if spec.helpLocal then
                self:copyTemplateFile( "HelpLocal.lua" )
                infoBuf[#infoBuf + 1] = "    {"
                infoBuf[#infoBuf + 1] = '        title = "' .. spec.helpLocal .. '",'
                infoBuf[#infoBuf + 1] = '        file = "HelpLocal.lua",'
                infoBuf[#infoBuf + 1] = "    },"
            end
            if spec.helpWeb then
                self:copyTemplateFile( "HelpWeb.lua" )
                infoBuf[#infoBuf + 1] = "    {"
                infoBuf[#infoBuf + 1] = '        title = "' .. spec.helpWeb .. '",'
                infoBuf[#infoBuf + 1] = '        file = "HelpWeb.lua",'
                infoBuf[#infoBuf + 1] = "    },"
            end
            if spec.reload then
                self:copyTemplateFile( "Reload.lua" )
                infoBuf[#infoBuf + 1] = "    {"
                infoBuf[#infoBuf + 1] = '        title = "' .. spec.reload .. '",'
                infoBuf[#infoBuf + 1] = '        file = "Reload.lua",'
                infoBuf[#infoBuf + 1] = "    },"
            end
            infoBuf[#infoBuf + 1] = "    },"
        end
        
        if spec.ftp then
            lrLoad["LrFtp"] = true
            self:frameworkModule( "Ftp", "Communication/Ftp" )
        end
        
        if spec.utils then
            self:copyTemplateFile( "Utils.lua" )
            self:pluginModule( "Utils" )
        end
        
        if spec.baseClass then
            self:copyTemplateFile( "BaseClass.lua" )
            self:pluginModule( "BaseClass" )
            if spec.derivedClass then
                self:copyTemplateFile( "DerivedClass.lua" )
                self:pluginModule( "DerivedClass" )
            end
        elseif self.derivedClass then
            app:error( "Derived class requires base class." )
        end
        
        if spec.develop then
            -- if there's some template support for develop settings:
               -- self:copyTemplateFile( "Develop.lua" ) - functionality may be within export module or file menu...
               -- self:pluginModule( "Develop" ) - 
            -- self:frameworkModule( "Develop", "Develop/Develop" ) - load as global, if there is framework support for develop settings.
        end
        
        if spec.fileMenu then
            self:copyTemplateFile( "FileMenuItem.lua" )
            infoBuf[#infoBuf + 1] = "    LrExportMenuItems = {"
            infoBuf[#infoBuf + 1] = "        {"
            infoBuf[#infoBuf + 1] = '            title = "' .. spec.fileMenu .. '",'
            infoBuf[#infoBuf + 1] = '            file = "FileMenuItem.lua",'
            infoBuf[#infoBuf + 1] = "        },"
            infoBuf[#infoBuf + 1] = "    },"
        end
        
        if spec.libMenu then
            if dialog:isOk( "Are you sure you don't want " .. spec.libMenu .. " on the file menu instead (click 'OK' to go ahead and put on Library Menu)?" ) then
                self:copyTemplateFile( "LibraryMenuItem.lua" )
                infoBuf[#infoBuf + 1] = "    LrLibraryMenuItems = {"
                infoBuf[#infoBuf + 1] = "        {"
                infoBuf[#infoBuf + 1] = '            title = "' .. spec.libMenu .. '",'
                infoBuf[#infoBuf + 1] = '            file = "LibraryMenuItem.lua",'
                infoBuf[#infoBuf + 1] = "        },"
                infoBuf[#infoBuf + 1] = "    },"
            else
                error( "Library Menu items should be on File Menu" )
            end
        end
        
        if spec.config then
            local prefSrcDir = LrPathUtils.child( templatePluginDir, "Preferences" )
            local prefDestDir = LrPathUtils.child( devPluginDir, "Preferences" )
            for i,v in ipairs( spec.config ) do
                repeat
                    local srcFilename = v .. ".lua" -- template files are still using .lua extension.
                    local destFilename = v .. ".txt"
                    local srcPath = LrPathUtils.child( prefSrcDir, srcFilename )
                    local destPath = LrPathUtils.child( prefDestDir, destFilename )
                    if fso:existsAsFile( srcPath ) then
                        if fso:existsAsFile( destPath ) and not overwrite then
                            app:logInfo( "Not overwriting " .. destPath )
                            break
                        end
                        local s,m = fso:copyFile( srcPath, destPath, true, overwrite )   
                        if s then
                            app:logInfo( "Copied preference support file: " .. destPath )
                        else
                            app:logError( m )
                        end                         
                    else
                        app:logError( "Pref file not existing: " .. srcPath )
                    end
                until true
            end
            spec.prefMngr = true
        end
        
        if spec.prefMngr then
            fmwkLoad["Preferences"] = 'System/Preferences'
        end
        
        -- include lr modules that aren't tied to anything, e.g.:
        -- lrLoad["LrMD5"] = true
        
        -- include framwwork modules that aren't tied to anything, e.g.:
        -- self:frameworkModule( "Xml", "Data/Xml" )
        
        -- include sibling modules that aren't tied to anything, e.g.:
        -- self:pluginModule( "{name}" )
        
        infoBuf[#infoBuf + 1] = "    VERSION = { major=0, minor=0, revision=0, build=0, },"
        self:copyTemplateFile( "ExtendedObjectFactory.lua" ) -- Extended plugins always get this, to use or not use as dev ensues...

        local initLuaDest = LrPathUtils.child( devPluginDir, "Init.lua" )
        if not fso:existsAsFile( initLuaDest ) or overwrite then
            app:logInfo( "Writing Init.lua at " .. initLuaDest )
            self:writeInitLua( initBuf, initLuaDest ) -- based on load-tbl(s) - always overwrites.
        else
            app:logInfo( "Not overwriting Init.lua at " .. initLuaDest )
        end
        local infoLuaDest = LrPathUtils.child( devPluginDir, "Info.lua" )
        if not fso:existsAsFile( infoLuaDest ) or overwrite then
            app:logInfo( "Writing Info.lua at " .. infoLuaDest )
            self:writeInfoLua( infoBuf, infoLuaDest ) -- always overwrites.
        else
            app:logInfo( "Not overwriting Info.lua at " .. infoLuaDest )
        end
        
    end } )
end


return Generate