--[[
        ExtendedManager.lua
--]]

local ExtendedManager, dbg = Manager:newClass{ className='ExtendedManager' }



--- Constructor for extending class.
--
function ExtendedManager:newClass( t )
    return Manager.newClass( self, t )
end



--- Constructor for new instance object.
--
function ExtendedManager:new( t )
    local o = Manager.new( self, t )
    o.gen = Generate:new()
    o.rel = Release:new()
    o.doc = LuaDoc:new()
    return o
end



--- Initialize plugin prefs.
--
function ExtendedManager.initPrefs()
    app:initPref( 'luaCompiler', "C:/Programs/Lua5.1.4/luac5.1.exe" )
    app:initPref( 'doCompile', false )
    app:initPref( 'zipper', "C:/Program Files (x86)/WinZip/WZZIP.EXE" )
    app:initPref( 'doZip', false )
    app:initPref( 'verMajor', 1 )
    app:initPref( 'verMinor', 0 )
    app:initPref( 'revision', 0 )
    app:initPref( 'build', 0 )
    app:initPref( 'uploadZip', false )
    app:initPref( 'ftpSettings', {} )
    app:initPref( 'ftpItems', {} )
    app:initPref( 'ftpSubPath', "" )
    app:initPref( 'format', false )
    Manager.initPrefs()
end



--- Initialize incoming plugin-manager dialog.
--
function ExtendedManager:startDialogMethod( props)

    Manager.startDialogMethod( self, props )

end



--- Initialize sections for bottom of dialog.
--
function ExtendedManager:sectionsForBottomOfDialogMethod( vf, props)

    local pluginSpec = app:getPref( 'pluginSpec' )
    if pluginSpec then
        local lrdevpluginDir = pluginSpec.devPluginDir
        if lrdevpluginDir then
            local infoLuaFile = LrPathUtils.child( lrdevpluginDir, "Info.lua" )
            if fso:existsAsFile( infoLuaFile ) then
                local status, infoLua = pcall( dofile, infoLuaFile )
                if status and infoLua then
                    if infoLua.VERSION.major then
                        props['verMajor'] = infoLua.VERSION.major
                        props['verMinor'] = infoLua.VERSION.minor
                        props['revision'] = infoLua.VERSION.revision
                        props['build'] = infoLua.VERSION.build
                    else
                        Debug.pause( "No ver major" )
                    end
                else
                    Debug.pause( "no info-lua: " .. infoLua )
                end
            else
                Debug.pause( "no info-lua file: " .. infoLuaFile )
            end
        else
            Debug.pause( "No devPluginDir" )
        end            
    else
        Debug.pause( "No plugin spec" )
    end            

    local appSection = { bind_to_object = props }
    
	appSection.title = app:getAppName() .. " Settings"
	appSection.synopsis = bind{ key='presetName', object=prefs }

	appSection.spacing = vf:label_spacing()
	
	appSection[#appSection + 1] = 
		vf:row {
			vf:static_text {
				title = "Release Format",
				width = share( "label_width" ),
			},
			vf:checkbox {
			    title = 'Compiled',
			    value = bind 'doCompile',
			},
			vf:checkbox {
			    title = 'Zipped',
			    value = bind 'doZip',
			},
		}
		
	appSection[#appSection + 1] = 
		vf:row {
			vf:static_text {
				title = "Lua Compiler",
				width = share( "label_width" ),
			},
			vf:edit_field {
			    value = bind 'luaCompiler',
			    width_in_chars = 35,
			    enabled = bind 'doCompile',
			},
		}	
	appSection[#appSection + 1] = 
		vf:row {
			vf:static_text {
				title = "Zipper (only wzzip so far)",
				width = share( "label_width" ),
			},
			vf:edit_field {
			    value = bind 'zipper',
			    width_in_chars = 35,
			    enabled = bind 'doZip',
			},
		}
		
	appSection[#appSection + 1] = vf:spacer{ height=5 }

	appSection[#appSection + 1] = 
		vf:row {
			vf:static_text {
				title = "verMajor, verMinor, revision, build",
				width = share( "label_width" ),
			},
			vf:edit_field {
			    value = bind 'verMajor',
			    width_in_chars = 3,
			    precision = 0,
			    min = 0,
			    max = 9999,
			},
			vf:edit_field {
			    value = bind 'verMinor',
			    width_in_chars = 3,
			    precision = 0,
			    min = 0,
			    max = 9999,
			},
			vf:edit_field {
			    value = bind 'revision',
			    width_in_chars = 3,
			    precision = 0,
			    min = 0,
			    max = 9999,
			},
			vf:edit_field {
			    value = bind 'build',
			    width_in_chars = 3,
			    precision = 0,
			    min = 0,
			    max = 9999,
			},
			--vf:static_text {
			--	title = "'build' will be a timestamp",
			--},
		}
		
	appSection[#appSection + 1] = vf:spacer{ height=5 }
	appSection[#appSection + 1] = vf:separator{ fill_horizontal=1 }
	appSection[#appSection + 1] = vf:spacer{ height=5 }

	appSection[#appSection + 1] = 
		vf:row {
			vf:checkbox {
			    title = 'Upload Released Zip To:',
			    value = bind 'uploadZip',
			    width = share 'label_width',
			    enabled = bind 'doZip',
			},
			vf:edit_field {
			    title = 'Upload Subpath',
			    value = bind 'ftpSubPath',
			    width_in_chars = 30,
			    width = share 'wid',
			    enabled = bind 'uploadZip',
			},
			vf:static_text {
			    title = 'subpath on server',
			},
        }

	appSection[#appSection + 1] = 
		vf:row {
			vf:static_text {
			    title = 'FTP Server/Settings',
			    width = share 'label_width',
			},
			LrFtp.makeFtpPresetPopup { 
			    factory = vf,
			    properties = props,
			    valueBinding = 'ftpSettings',
			    itemsBinding = 'ftpItems',
			    enabled = bind 'uploadZip',
			    width = share 'wid',
			},
        }

	appSection[#appSection + 1] = vf:spacer{ height=5 }
	appSection[#appSection + 1] = vf:separator{ fill_horizontal=1 }
	appSection[#appSection + 1] = vf:spacer{ height=5 }

	appSection[#appSection + 1] = 
		vf:row {
			vf:push_button {
				title = "Generate Plugin",
				width = share( "button_width" ),
				action = function( button )
				    self.gen:generate() -- wrapped within
				end
			},
			vf:static_text {
				title = "Generate lrdevplugin..."
			},
		}	
   
	appSection[#appSection + 1] = 
		vf:row {
			vf:push_button {
				title = "Release Plugin",
				width = share( "button_width" ),
				action = function( button )
			        self.rel:release()
				end
			},
			vf:static_text {
				title = "Release lrplugin..."
			},
		}	
		
    appSection[#appSection + 1] = 
		vf:row {
			vf:push_button {
				title = "Generate luaDoc",
				width = share( "button_width" ),
				action = function( button )
				    -- dbg( "doc" )
				    self.doc:luaDoc() -- wrapped within
				end
			},
			vf:static_text {
				title = "Generate luaDoc for lrdevplugin...",
			},
			vf:checkbox {
			    value = bind( 'format' ),
				title = "Convert Function Headers",
				tooltip = 'Convert function headers from long-comment to lua-doc compatible format - only needs to be done once.',
			},
		}
		
	appSection[#appSection + 1] = 
		vf:row {
			vf:push_button {
				title = "Open Project Dir",
				width = share( "button_width" ),
				action = function( button )
				    app:call( Call:new{ name = button.title, async=false, main=function( call )
    				    local spec = app:getPref( "pluginSpec" )
    				    if spec then
    				        local prjDir = spec.projectDir
    				        if prjDir then
    				            if fso:existsAsDirectory( prjDir ) then
    				                LrShell.revealInShell( prjDir )
    				            else
    				                app:show( { error="prj dir not found: ^1" }, prjDir )
    				            
    				            end
    				        else
    				            app:show( { error="no prj dir" } )
    				        end
    				    else
  				            app:show( { error="no plugin spec" } )
    				    end
    				end } )
				end
			},
			vf:static_text {
				title = "Reveal project directory in " .. app:getShellName(),
			},
		}	
		
	appSection[#appSection + 1] = vf:spacer{ height=5 }
		
    appSection[#appSection + 1] = 
		vf:row {
			vf:push_button {
				title = "Test Something",
				width = share( "button_width" ),
				action = function( button )
				    --app:call( Service:new{ name=button.title, async = true, main = function( service )
                    --end } )				    
				end
			},
			vf:static_text {
				title = "For general dynamic testing...",
			},
		}
		
    local sections = Manager.sectionsForBottomOfDialogMethod ( self, vf, props )
    tab:appendArray( sections, { appSection } )
    return sections
end



return ExtendedManager
