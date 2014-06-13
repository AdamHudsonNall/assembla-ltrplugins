--[[
        Init.lua (plugin initialization module)
--]]


-- Unstrictify _G
local mt = getmetatable( _G ) or {}
mt.__newIndex = function( t, n, v )
    rawset( t, n, v )
end
mt.__index = function( t, n )
    return rawget( t, n )
end
setmetatable( _G, mt )



--   I N I T I A L I Z E   L O A D E R
do
    -- *** REL_BEGIN frameworkDir
    local LrPathUtils = import 'LrPathUtils'
    local frameworkDir = LrPathUtils.makeAbsolute( "../../Framework", "X:\\Dev\\LightroomPlugins\\lrdevplugin\\trunk\\Hello(Gen-Rel)World\\Hello(Generated)World.lrdevplugin" )
    -- *** REL_END
    local loadFile = frameworkDir .. "/System/Require.lua"
    local status, result = pcall( dofile, loadFile ) -- gives good "file-not-found" error - no reason to check first (and is ok with forward slashes).
    if status then
        _G.Require = result
        _G.load = Require.require -- synonym: helps remind that its not vanilla 'require'.
    else
        import( 'LrErrors' ).throwUserError( result ) -- we can trust pcall+dofile to return a non-nil error message.
    end
    if _PLUGIN.path:sub( -12 ) == '.lrdevplugin' then
        Require.path( frameworkDir )
    else
        assert( _PLUGIN.path:sub( -9 ) == '.lrplugin', "Invalid plugin extension" )
        Require.path( 'Framework' ) -- relative to lrplugin dir.
    end
end



--   S E T   S T R I C T   G L O B A L   P O L I C Y
_G.Globals = load( 'System/Globals' )
assert( Debug, "no debug" ) -- first "require" is supposed to load it.
_G.gbl = Globals:new{ strict = true }



--   I N I T I A L I Z E   F R A M E W O R K
_G.Object = load( 'System/Object' )
_G.ObjectFactory = load( 'System/ObjectFactory' )
_G.Init = load( 'System/InitFramework' )
_G.SpecialObjectFactory = load( 'SpecialObjectFactory' )
_G.objectFactory = SpecialObjectFactory:new()
_G.init = objectFactory:newObject( 'Init' ) -- create initializer object.
init:framework()



--   P L U G I N   S P E C I F I C   I N I T
_G.LrExportSession = import 'LrExportSession'
_G.LrExportSettings = import 'LrExportSettings'
_G.LrFtp = import 'LrFtp'
_G.LrXml = import 'LrXml'
_G.LrMD5 = import 'LrMD5'
_G.Background = load( 'System/Background' )
_G.Export = load( 'ExportAndPublish/Export' )
_G.Ftp = load( 'Communication/Ftp' )
_G.Preferences = load( 'System/Preferences' )
_G.XmlRpc = load( 'Communication/XmlRpc' )
_G.Common = load( 'Common' )
_G.SpecialBackground = load( 'SpecialBackground' )
_G.SpecialExport = load( 'SpecialExport' )



--   I N I T I A T E   A S Y N C H R O N O U S   I N I T   A N D   B A C K G R O U N D   T A S K
app:initGlobalPref( 'autostartBackground', false )
app:initDone()
if app:getGlobalPref( 'autostartBackground' ) and (background ~= nil) then
    background:start() -- by default just does init then quits - consider using pref to enable/disable background if optional, else force continuation into background processing...
end



-- the end.