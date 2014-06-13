--[[
        Release.lua
        
        Release plugin from develop mode in lrdevplugin folder,
        to release mode in lrplugin folder, possibly zipped up
        with related release files.
--]]


local Release, dbg = Object:newClass{ className = 'Release' }


local pluginMash
local templateDir
local templatePluginFolder
local devPluginDir
local spec
local prjDir  -- project directory.
local pkgDir -- package directory
local distDir -- distribution directory
local relPluginDir
local pluginFilesToCopy
local projectFilesToCopy
local version
local zipName



function Release:newClass( t )
    return Object.newClass( self, t )
end



function Release:new( t )
    local o = Object.new( self, t )
    o.genRel = GenRelCommon:new() -- modify to use new-object method of object-factory if need arises to extend.
    return o
end



---     Get version number as string, repressing insiginficant trailing .0s
--      excludes build string.
--
function Release:getVerNumStr()
    if spec.version then
        app:logWarn( "version number string in config file is deprecated - use plugin manager instead." )
        return spec.version
    end
    local verMajor = app:getPref( 'verMajor' )
    local verMinor = app:getPref( 'verMinor' )
    local revision = app:getPref( 'revision' )
    local build = app:getPref( 'build' )
    assert( verMajor and verMinor and revision and build, "need all 4 version number components" )
    local ver = '' .. verMajor .. "." .. verMinor -- auto convert arguments to string.
    if ('' .. revision) ~= '0' or ('' .. build) ~= '0' then
        ver = ver .. '.' .. revision
    end
    if ('' .. build) ~= '0' then
        ver = ver .. '.' .. build
    end
    return ver
end



function Release:isToBeOmitted( filePath )
    if filePath:find( "svn" ) or filePath:find( "/_" ) or filePath:find( "\\_" ) then
        return true
    else
        return false
    end
end



function Release:rewriteInfoLua( src, dest )

    if fso:existsAsFile( src ) then
        -- good
    else
        error( "nope: " .. src )
    end
    local info = fso:readTextFile( src )
    if str:is( info ) then
        -- fso:moveToTrash( path )
    else
        error( "no info" )
    end
    
    local newLines = {}
    for line in str:lines( info ) do -- auto-eol-detection.
        line = line:gsub( 'LrPluginName ?= ?\"[^\"]+\"', 'LrPluginName = "' .. spec.relPluginName .. '"' )
        line = line:gsub( 'LrPluginInfoUrl ?= ?\"[^\"]+\"', 'LrPluginInfoUrl = "' .. spec.pluginUrl .. '"' )
        line = line:gsub( 'LrToolkitIdentifier ?= ?\"[^\"]+\"', 'LrToolkitIdentifier = "' .. spec.relToolkitId .. '"' )
        if line:find( 'VERSION' ) then
            local datetime = LrDate.currentTime()
            local dateTimeFormatted = LrDate.timeToUserFormat( datetime, "%Y-%m-%d %H:%M:%S" )
            line = '    VERSION = { display = "' .. version .. '    Build: ' .. dateTimeFormatted .. '" },'
        end
        newLines[#newLines + 1] = line -- I think windows is happy to read it like this, as is mac.
    end
    local contents = table.concat( newLines, "\n" )
    
    local status, message = fso:writeFile( dest, contents )
    if not status then
        error( message )
    end

end

function Release:rewriteInitLua( src, dest )

    if fso:existsAsFile( src ) then
        -- good
    else
        error( "nope: " .. src )
    end
    local init = fso:readTextFile( src )
    if str:is( init ) then
        -- fso:moveToTrash( path )
    else
        error( "no init lua content" )
    end
    local blksToDo = {}
    blksToDo.frameworkDir = true
    local lines = {}
    local lineTbl = self.genRel:tokenize( 'REL', init )
    for i, subTbl in ipairs( lineTbl ) do
    
        local name = subTbl.name
        
        if name == nil then
            -- dbg( "nil" )
            tab:appendArray( lines, subTbl )
        elseif name == 'frameworkDir' then
        
            -- dbg( "rel-fmwk-dir" )
            blksToDo[name] = nil -- done
            lines[#lines + 1] = "    local LrPathUtils = import 'LrPathUtils'"
            lines[#lines + 1] = '    local frameworkDir = LrPathUtils.child( _PLUGIN.path, "Framework" )'
        
        else
        
            app:logWarning( str:format( "Not programmed for block named '^1' in rel-init-lua rewrite, carrying unmodified. ", name ) )
            tab:appendArray( lines, subTbl )
            
        end
    
    end
    
    if not tab:isEmpty( blksToDo ) then
        error( "Missing init blocks for re-write" )
    end
    
    local out = table.concat( lines, '\n' )
    -- dbg( out:sub( 1, 500 ) )
    local status, message = fso:writeFile( dest, out )
    if not status then
        error( message )
    end

end



---     Starting with boiler plate, replaces common tokens if present.
--
function Release:rewriteAccessory( auxFile, auxName )
    local src = LrPathUtils.child( templateDir, auxFile )
    local dest = LrPathUtils.child( distDir, auxName )
    local lines = {}
    for srcLine in io.lines( src ) do
        local outLine = self:_replaceLineTokens( srcLine, version )
        lines[#lines + 1] = outLine
    end
    local out = table.concat( lines, '\n' )
    local status, message = fso:writeFile( dest, out )
    if status then
       app:logInfo( "Created: " .. dest .. " from " .. src )
    else
        error( message )
    end
end



--  Replace tokens in line table.
--
--  @return new table of lines with replaced tokens and optionally the beg/end envelop removed.
--
function Release:_replaceLineTokens( srcLine, ver )
    local outLine = srcLine
    outLine = outLine:gsub( "\${PLUGIN_NAME}", spec.relPluginName )
    if pluginMash then
        outLine = outLine:gsub( "\${PLUGIN_MASH}", pluginMash )
    end
    outLine = outLine:gsub( "\${ZIP_NAME}", zipName )
    outLine = outLine:gsub( "\${LRPLUGIN_FOLDERNAME}", relPluginDir )
    outLine = outLine:gsub( "\${AUTHOR}", spec.author )
    outLine = outLine:gsub( "\${MAC_INSTALLER_NAME}", spec.macInstallerName )
    outLine = outLine:gsub( "\${WINDOWS_INSTALLER_NAME}", spec.winInstallerName )
    outLine = outLine:gsub( "\${MAC_UNINSTALLER_NAME}", spec.macUninstallerName )
    outLine = outLine:gsub( "\${WINDOWS_UNINSTALLER_NAME}", spec.winUninstallerName )
    outLine = outLine:gsub( "\${AUTHORS_WEBSITE}", spec.authorsWebsite )
    outLine = outLine:gsub( "\${PLUGIN_URL}", spec.pluginUrl )
    outLine = outLine:gsub( "\${COPYRIGHT}", spec.copyright )
    outLine = outLine:gsub( "\${VERSION}", ver )
    return outLine
end



--  Replace tokens in line table.
--
--  @return new table of lines with replaced tokens and optionally the beg/end envelop removed.
--
function Release:_replaceLineTokensInTable( tbl, omitEnvelope )
    local lines = {}
    local start, stop = 1, #tbl
    if omitEnvelope then
        start, stop = 2, #tbl - 1
    end
    for i = start, stop do
        local outLine = self:_replaceLineTokens( tbl[i], version )
        lines[#lines + 1] = outLine
    end
    return lines
end



--- Starting with readme template, allows section customization, plus token replacement.
--
function Release:rewriteReadme( readmeFile, readmeName  )
    local src = LrPathUtils.child( templateDir, readmeFile )
    local dest = LrPathUtils.child( distDir, readmeName )
    if fso:existsAsFile( src ) then
        -- good
    else
        error( "nope: " .. src )
    end
    local info = fso:readTextFile( src )
    if str:is( info ) then
        -- fso:moveToTrash( path )
    else
        error( "no info" )
    end
    local blksToDo = {}
    blksToDo["metadata"] = true
    local lines = {}
    local lineTbl = self.genRel:tokenize( 'REL', info )
    for i, subTbl in ipairs( lineTbl ) do
    
        local name = subTbl.name
        
        if name == nil then
            -- dbg( "nil" )
            tab:appendArray( lines, self:_replaceLineTokensInTable( subTbl ) )
        elseif name == 'metadata' then -- 
        
            blksToDo[name] = nil -- done
            if spec.metadata then
                tab:appendArray( lines, self:_replaceLineTokensInTable( subTbl, true ) ) -- true => omit envelope.
            else -- omit entirely
                app:logInfo( "metadata clause omitted in readme" )
            end
        
        else
        
            app:logWarning( str:format( "Not programmed for block named '^1' in rel-init-lua rewrite, carrying unmodified. ", name ) )
            tab:appendArray( lines, subTbl ) -- omit first & last lines in sub-tbl
            
        end
    
    end
    
    if not tab:isEmpty( blksToDo ) then
        error( "Missing init blocks for re-write" )
    end
    
    local contents = table.concat( lines, "\n" )
    
    local status, message = fso:writeFile( dest, contents )
    if not status then
        error( message )
    end

end



--- Upload AND validate uploaded zip.
--
function Release:uploadZip( zip )
    self.service.scope:setCaption( str:fmt( "Uploading ^1", LrPathUtils.leafName( zip ) ) )
    self.service.scope:setCancelable( false ) -- put-file can not be canceled, so don't give illusion that it can - it even continues when plugin reloaded, since ftp is async in Lightroom,
        -- otherwise count on errors (e.g. trying to zip again before upload finished will fail).
    local ftpSettings = app:getPref( 'ftpSettings' )
    local ftpSubPath = app:getPref( 'ftpSubPath' )
    assert( ftpSettings and ftpSettings.server, "no ftp settings" )
    assert( ftpSubPath, "no subpath" )
    ftpSubPath = str:replaceBackSlashesWithForwardSlashes( ftpSubPath )
    local ftp = Ftp:new{ ftpSettings=ftpSettings, autoNegotiate=true }
    local s, m = ftp:connect()
    if not s then
        return false, m
    end
    local remoteZip
    if str:getLastChar( ftpSubPath ) == '/' then
        remoteZip = ftpSubPath .. zipName
    else
        remoteZip = ftpSubPath .. '/' .. zipName
    end
    s, m = ftp:calibrateClock( LrPathUtils.getStandardFilePath( 'temp' ), ftpSubPath ) -- clock calibration is required for getting directory contents which is required for validating upload.
    -- (history: original dir-content gathering was all about the date-time, which is only accurate if the remote clock is calibrated. I could conceivably laxify this requirement,
    -- but its not so bad to make sure calibraion works before attempting the file upload anyway, since a lot of the same pieces are used for validation...
    if s then
        s, m = ftp:putFile( zip, remoteZip, true ) -- true => overwrite-ok. this handles leading slash in remote-zip appropriately.
        if s then
            s, m = ftp:isFileSame( zip, remoteZip )
            if s ~= nil then
                if s then
                    app:log( "uploaded zip validated" )
                else
                    app:logError( "uploaded zip NOT validated" )
                end
            elseif m then
                app:logError( "Error validating uploaded zip" )
            else
                app:logWarning( "Unable to validate uploaded zip" )
            end
        end
    end
    ftp:disconnect()
    return s, m
end



--- Release a plugin.
--
--  @usage      Starts with lrdevplugin and support template files like license & readme.
--  @usage      Puts result in zip file containing modified license, readme, and compiled lrplugin folder.
--
function Release:release()
    app:call( Service:new{ name = "Release Plugin", async=true, guard=App.guardVocal, main=function( service )

        self.service = service
        spec = app:getPref( 'pluginSpec' )
        -- assert( pluginMash, "no pluginMash" ) - optional
        assert( spec, "no plugin spec for releasing" )
        pluginMash = spec.pluginMash or 'MyPlugin'
    
        local frameworkDir = LrPathUtils.makeAbsolute( "../../Framework", _PLUGIN.path ) -- this needs to be the real deal framework source dir,
            -- which at present is a sibling of the generator plugin.
        assert( fso:existsAsDirectory( frameworkDir ), "framework-dir not existing: " .. frameworkDir )
        assert( spec.projectDir, "need project-dir" )
        assert( spec.relPluginDir == nil, "rel-plugin-dir no longer supported" )
        assert( spec.relPluginName, "need rel-plugin-name" )
        assert( spec.relPluginFolder, "need rel-plugin-folder" )
        version = self:getVerNumStr()
        prjDir = LrPathUtils.standardizePath( spec.projectDir ) -- typically parent of lrplugin folder.
        pkgDir = LrPathUtils.child( prjDir, 'ReleasePackageContents' ) -- could be configurable too...
        if spec.zipName then
            zipName = spec.zipName:gsub( '\${VERSION}', version )
        end
        -- consider in the future, having separate packaging specs for windows and mac. ###3
        -- I could easily see different contents (e.g. executable support) as well as different packaging (e.g. zip subfolder).
        -- Actually, this could be handled now using a different named preset for each - as long as the rest of the items
        -- are kept in sync...
        if spec.distFolder == nil then -- use default dist subfolder
            if zipName ~= nil then -- default is zip base
                local distFolder = LrPathUtils.removeExtension( zipName )
                distDir = LrPathUtils.child( pkgDir, distFolder ) -- IMO this is ideal for Windows (which by default unzips contents into dir specified).
            else -- default is no dist subfolder
                distDir = pkgDir
            end
        elseif spec.distFolder == "" then -- "no folder" specified as distribution folder
            distDir = pkgDir -- and this is ideal for Mac (which automatically unzips into folder of same base name as zip).
        else -- dist-subfolder specified explicitly.
            distDir = LrPathUtils.child( pkgDir, spec.distFolder ) -- use dist subfolder specified.
        end
        relPluginDir = LrPathUtils.child( distDir, spec.relPluginFolder )
        local relExt = LrPathUtils.extension( relPluginDir )
        assert( relExt == "lrdevplugin" or relExt == 'lrplugin', "bad rel name - needs standard extension" )
        pluginFilesToCopy = spec.pluginFilesToCopy or {}
        projectFilesToCopy = spec.projectFilesToCopy or {}
        local licenseFile = spec.licenseFile or error( "Please specify license-file" ) -- no default license.
        assert( spec.copyright, "Please specify copyright, even if empty string" ) -- no default copyright notice.
        local licenseName = spec.licenseName or 'LICENSE.txt'
        local readmeFile = spec.readmeFile or 'Default_README.txt'
        local readmeName = spec.readmeName or 'README.txt'
        local winUninstallerFile = spec.winUninstallerFile -- or 'Default_WindowsUninstaller.wsf'
        local winUninstallerName = spec.winUninstallerName -- or 'WindowsUninstaller.wsf'
        local winInstallerFile = spec.winInstallerFile -- or 'Default_InstallOnWindows.wsf'
        local winInstallerName = spec.winInstallerName -- or 'InstallOnWindows.wsf'
        local macInstallerFile = spec.macInstallerFile -- or 'Default_InstallOnMac.applescript'
        local macInstallerName = spec.macInstallerName -- or 'InstallOnMac.applescript'
        local macUninstallerFile = spec.macUninstallerFile -- or 'Default_MacUninstaller.applescript'
        local macUninstallerName = spec.macUninstallerName -- or 'MacUninstaller.applescript'
        local readmeName = spec.readmeName or 'README.txt'
        if spec.compile then
            error( "use checkbox for compile" )
        end
        local compile = app:getPref( 'doCompile' )
        assert( compile ~= nil, "no compile pref" )
        local compiler
        if compile then
            if spec.compiler then
                error( "Compiler specification is done in plugin manager now." )
            else
                compiler = app:getPref( 'luaCompiler' )
                assert( str:is( compiler ), "need lua compiler" )
                compiler = LrPathUtils.standardizePath( compiler )
            end
        end
        if spec.zip then
            error( "use checkbox for zip" )
        end
        local zip = app:getPref( 'doZip' )
        assert( zip ~= nil, "no zip pref" )
        local zipPath
        local zipParms
        local zipSpecTbl
        local zipper
        if zip then
            assert( zipName, "no zip name" )
            assert( spec.zipSpecTbl == nil, "zip-spec-tbl obsolete" )
            assert( spec.zipParms == nil, "no more zip parms" )
            if spec.zipper then
                error( "Zipper must now be specified in plugin manager." )
            else
                zipper = app:getPref( 'zipper' )
                assert( str:is( zipper ), "need zipper" )
            end
            zipPath = LrPathUtils.child( prjDir, zipName )
            zipParms = '-p -r "' .. zipPath .. '"'
            zipSpecTbl = { LrPathUtils.child( pkgDir, "*.*" ) } 
        end
    
        if LrPathUtils.isAbsolute( spec.templateDir ) then
            templateDir = LrPathUtils.standardizePath( spec.templateDir )
        else
            templateDir = LrPathUtils.child( LrPathUtils.parent( _PLUGIN.path ), spec.templateDir )
        end
        templatePluginFolder = LrPathUtils.child( templateDir, spec.templatePluginFolder )
        if fso:existsAsDirectory( templateDir ) then
            app:logInfo( "Template dir: " .. templateDir )
        else
            error( "template dir does not exist: " .. templateDir )
        end
        if fso:existsAsDirectory( templatePluginFolder ) then
            app:logInfo( "Source plugin dir: " .. templatePluginFolder )
        else
            error( "source dev plugin dir does not exist: " .. templatePluginFolder )
        end
        devPluginDir = LrPathUtils.standardizePath( spec.devPluginDir )
        if fso:existsAsDirectory( devPluginDir ) then
            -- good
        else
            error( "Not existing: " .. devPluginDir )
        end
        local file = app.prefMgr:getPrefSupportFile()
        if not dialog:isOk( str:format( "Release plugin based on settings in ^1?", file ) ) then
            service:cancel()
            return
        end
        if LrPathUtils.isAbsolute( pkgDir ) then
            if fso:existsAsDirectory( pkgDir ) then
                local yes, no
                local answer = app:show( { info="Delete ^1 so everythings fresh?", buttons={{label='Yes',verb='ok'},{label='No',verb='no'}} }, pkgDir )
                if answer == 'ok' then
                    yes, no = self.genRel:deleteTree( pkgDir ) -- I think this protects from deletion of any root directories. ###1
                elseif answer == 'no' then
                    -- continue
                elseif answer == 'cancel' then
                    service:cancel()
                    return
                else
                    error( "bad answer" )
                end
                if yes then
                    app:logInfo( "Pre-deleted " .. pkgDir )
                elseif no then
                    error( "Unable to pre-delete, error message: " .. no )
                end
            else
                app:logInfo( "not existing / to-be created: " .. pkgDir )
                fso:assureAllDirectories( pkgDir )
            end
        else
            error( "Not sure where this would end up: " .. pkgDir )
        end
    
        service.scope = LrProgressScope {
            title = "Releasing " .. spec.relPluginName,
            functionContext = service.context,
            indeterminate = true,
        }
        
        --   D O   F R A M E W O R K   F I L E S        
        
        for filePath in LrFileUtils.recursiveFiles( frameworkDir ) do
        
            service.scope:setCaption( "Doing framework" )
            
            repeat
            
                if self:isToBeOmitted( filePath ) then
                    break
                end
            
                local subPath = LrPathUtils.child( "Framework", LrPathUtils.makeRelative( filePath, frameworkDir ) )
                local targPath = LrPathUtils.child( relPluginDir, subPath )
                local targDir = LrPathUtils.parent( targPath )
                local leaf = LrPathUtils.leafName( subPath )
                local ext = LrPathUtils.extension( leaf )
        
                fso:assureAllDirectories( targDir )
                if compile and ext == 'lua' then
                    local status, message = app:executeCommand( compiler, '-o "' .. targPath .. '"', { filePath } )                     
                    if status then
                        app:logInfo( "compiled " .. targPath )
                        -- fso:moveToTrash( tempFile )
                    else
                        app:logError( "Unable to compile " .. targPath .. ", error message: " .. str:to( message ) )
                    end
                else
                    fso:copyFile( filePath, targPath, true, true )
                    app:logInfo( "Copied " .. targPath )
                end
                
            until true
        end
    
    
        --   D O   P L U G I N   F I L E S   ( S A N S   ' _ ' )
        for filePath in LrFileUtils.recursiveFiles( devPluginDir ) do
        
            service.scope:setCaption( "Doing plugin files" )
            
            repeat
                local subPath = LrPathUtils.makeRelative( filePath, devPluginDir )
                local targPath = LrPathUtils.child( relPluginDir, subPath )
                local leaf = LrPathUtils.leafName( subPath )
                local dir = LrPathUtils.leafName( LrPathUtils.parent( filePath ) )
                local ext = LrPathUtils.extension( leaf )
                
                if self:isToBeOmitted( filePath ) then -- presently folders or files beginning with '_', or having 'svn' in the path.
                    break
                end
                
                if compile then
                    if leaf == 'Info.lua' then
                        local infoPath = filePath
                        local infoRelPath = LrPathUtils.child( LrPathUtils.parent( filePath ), "_Info-Rel.lua" )
                        if fso:existsAsFile( infoRelPath ) then
                            infoPath = infoRelPath
                        end
                        local tempFile = LrPathUtils.child( LrPathUtils.parent( targPath ), 'Info_.lua' )
                        self:rewriteInfoLua( infoPath, tempFile )
                        local status, message = app:executeCommand( compiler, '-o "' .. targPath .. '"', { tempFile } )
                        if status then
                            app:logInfo( "compiled " .. targPath .. "using " .. message )
                            if app:isAdvDbgEna() then
                                app:logInfo( "*** Not deleting " .. tempFile )
                            else
                                fso:moveToTrash( tempFile )
                                app:logVerbose( "Moved to trash: " .. tempFile )
                            end
                        else
                            app:logError( "Unable to compile " .. targPath .. ", error message: " .. str:to( message ) )
                        end
                    elseif leaf == 'Init.lua' then
                        local tempFile = LrPathUtils.child( LrPathUtils.parent( targPath ), 'Init_.lua' )
                        self:rewriteInitLua( filePath, tempFile )
                        local status, message = app:executeCommand( compiler, '-o "' .. targPath .. '"', { tempFile } )                     
                        if status then
                            app:logInfo( "compiled " .. targPath .. "using " .. message )
                            if app:isAdvDbgEna() then
                                app:logInfo( "*** Not deleting " .. tempFile )
                            else
                                fso:moveToTrash( tempFile )
                                app:logVerbose( "Moved to trash: " .. tempFile )
                            end
                        else
                            app:logError( "Unable to compile " .. targPath .. ", error message: " .. str:to( message ) )
                        end
                    elseif ext == 'lua' and dir ~= 'Preferences' then
                        local status, message = app:executeCommand( compiler, '-o "' .. targPath .. '"', { filePath } )                     
                        if status then
                            app:logInfo( "compiled " .. targPath .. "using " .. message )
                        else
                            app:logError( "Unable to compile " .. targPath .. ", error message: " .. str:to( message ) )
                        end
                    else
                        fso:copyFile( filePath, targPath, true, true )
                        app:logInfo( "Copied " .. targPath )
                    end
                else
                    if leaf == 'Info.lua' then
                        local infoPath = filePath
                        local infoRelPath = LrPathUtils.child( LrPathUtils.parent( filePath ), "_Info-Rel.lua" )
                        if fso:existsAsFile( infoRelPath ) then
                            infoPath = infoRelPath
                        end
                        self:rewriteInfoLua( infoPath, targPath )
                        app:logInfo( "Re-wrote info-lua " .. targPath )
                    elseif leaf == 'Init.lua' then
                        self:rewriteInitLua( filePath, targPath )
                        app:logInfo( "Re-wrote init-lua " .. targPath )
                    else
                        -- local sts, msg = fso:copyFile( filePath, targPath, true, true )
                        assert( filePath, "no source file path" )
                        assert( fso:existsAsFile( filePath ), "source file not existing" )
                        assert( str:is( targPath ), "no targ file path" )
                        app:logInfoToBeContinued( "Copying " .. filePath .. " to " .. targPath )
                        local sts, msg = fso:copyFile( filePath, targPath, true, true )
                        if sts then
                            app:logInfo( " - copied." )
                        else
                            app:logInfo( " - NOT copied." )
                            app:logError( msg )
                        end
                    end
                end
            until true
        end
    
    
        --   D O   P L U G I N   F I L E S   S P E C I F I E D   E X P L I C T L Y
        --   (lrdevplugin to lrplugin, specified by subpath)
    
        for i, v in ipairs( pluginFilesToCopy ) do
        
            service.scope:setCaption( "Doing plugin extras" )
            
            local srcSubPath = v[1]
            local srcPath = LrPathUtils.child( devPluginDir, srcSubPath )
            local destSubPath = v[2] or srcSubPath
            local destPath = LrPathUtils.child( relPluginDir, destSubPath )
            
            fso:copyFile( srcPath, destPath, true, true )
            app:logInfo( str:fmt( "Copied as specified, from ^1 to ^2", srcPath, destPath ) )
        end

    
        --   D O   P R O J E C T   F I L E S   S P E C I F I E D   E X P L I C T L Y
        --   (prjoect dir to distribution dir, specified by subpath)
    
        for i, v in ipairs( projectFilesToCopy ) do
        
            service.scope:setCaption( "Doing project extras" )
            
            local srcSubPath = v[1]
            local srcPath = LrPathUtils.child( prjDir, srcSubPath )
            local destSubPath = v[2] or srcSubPath
            local destPath = LrPathUtils.child( distDir, destSubPath )
            
            fso:copyFile( srcPath, destPath, true, true )
            app:logInfo( str:fmt( "Copied as specified, from ^1 to ^2", srcPath, destPath ) )
        end

    
        --   A C C E S S O R Y   F I L E S

        service.scope:setCaption( "Doing accessories" )
        
        self:rewriteReadme( readmeFile, readmeName )
        self:rewriteAccessory( licenseFile, licenseName )
        if winInstallerFile and winInstallerName then
            self:rewriteAccessory( winInstallerFile, winInstallerName )
        end
        if winUninstallerFile and winUninstallerName then
            self:rewriteAccessory( winUninstallerFile, winUninstallerName )
        end
        if macInstallerFile and macInstallerName then
            self:rewriteAccessory( macInstallerFile, macInstallerName )
        end
        if macUninstallerFile and macUninstallerName then
            self:rewriteAccessory( macUninstallerFile, macUninstallerName )
        end



        --   Z I P   F I L E
        
        if zip then
        
            service.scope:setCaption( "Doing zip" )
            
            local targZip = LrPathUtils.child( prjDir, zipName )
            if fso:existsAsFile( targZip ) then
                local status, message = fso:moveToTrash( targZip )
                local status = true
                if status then
                    app:log( 'Previous "build" moved to trash: ' .. targZip )
                else
                    error( message )
                end
            end
            local status, message = app:executeCommand( zipper, zipParms, zipSpecTbl )
            if status then
                app:logInfo( message )
                if fso:existsAsFile( targZip ) then
                    if app:getPref( 'uploadZip' ) then
                        local s, m = self:uploadZip( targZip )
                        if s then
                            app:log( "zip uploaded" )
                        else
                            app:logError( m )
                            app:show( { error="unable to upload zip" } )
                        end
                    else
                        LrShell.revealInShell( targZip )
                    end
                end
            else
                error( str:to( message ) )
            end
        else
            app:logInfo( "No zip" )
        end
        
        service.scope:setCaption( "Done" )
        
    end, finale=function( call, status, message)
        if status then
            -- app:show{ info="Released" }
        else
            -- app:show{ error="Problem: ^1", message }
        end
    end } )
end

return Release