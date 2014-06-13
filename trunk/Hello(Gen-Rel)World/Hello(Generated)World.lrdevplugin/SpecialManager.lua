--[[
        SpecialManager.lua
--]]


local SpecialManager, dbg = Manager:newClass{ className='SpecialManager' }



--[[
        Constructor for extending class.
--]]
function SpecialManager:newClass( t )
    return Manager.newClass( self, t )
end



--[[
        Constructor for new instance object.
--]]
function SpecialManager:new( t )
    return Manager.new( self, t )
end



function SpecialManager:startDialogMethod( props )
    app:initPref( 'testData', "" )
    Manager.startDialogMethod( self, props )
end



function SpecialManager:sectionsForBottomOfDialogMethod( vf, props)

    local appSection = {}
    if app.prefMgr then
        appSection.bind_to_object = props
    else
        appSection.bind_to_object = prefs
    end
    
	appSection.title = app:getAppName() .. " Settings"
	appSection.synopsis = bind{ key='presetName', object=prefs }

	appSection.spacing = vf:label_spacing()

	appSection[#appSection + 1] = 
		vf:row {
			vf:edit_field {
				value = bind( "testData" ),
			},
			vf:static_text {
				title = str:format( "Test data" ),
			},
		}
	appSection[#appSection + 1] = 
		vf:row {
			vf:push_button {
				title = "Test",
				action = function( button )
				    app:call( Call:new{ name='Test', main = function( call )
                        app:showInfo( str:format( "^1: ^2", str:to( app:getGlobalPref( 'presetName' ) ), app:getPref( 'testData' ) ) )
                    end } )
				end
			},
			vf:static_text {
				title = str:format( "Perform tests." ),
			},
		}
		
    local sections = Manager.sectionsForBottomOfDialogMethod ( self, vf, props ) -- fetch base manager sections.
    tab:appendArray( sections, { appSection } ) -- put app-specific prefs after.
    return sections
end



return SpecialManager
