--[[
        Plugin generator configuration file.
        
        Used for generation and release both.
--]]


--   R E T U R N   T A B L E   D E C L A R A T I O N
local _p = {}




--[[
        author name
        
        for plugin manager display and general use.
--]]
_p.author = 'Rob Cole'



--[[
        Author's or other initials.
        
        I use this so all my plugins are adjacent in plugin manager or in a folder of plugins,
        and on the file menu...
        
        Its optional, and may be less obnoxious if lower case.
--]]
_p.initials = 'RC'



--[[
        domain name for URLs.
        
        Note: this may be a don't care if you don't have a website.
--]]
_p.domainId = 'robcole.com'



--[[
        domain name reversed or formal name.
        
        This is important for distinguishing plugin toolkit ID from other plugins.
        If you don't have a domain id to reverse, set it to your full name
        forwards or backwards, like:
        
        john.henry.doe, or
        doe.henry.john
        
        A unique value assures there is never a name/id collision between plugins.
--]]
_p.domainIdReversed = 'com.robcole'



--[[
        author site
        
        for plugin manager display and general use.
--]]
_p.authorsWebsite = 'www.' .. _p.domainId



--[[
        Used in web urls after domain name...
        
        Edit to match server.
        If your website is not organized as a web-app,
        then you may need to edit the urls where this is used.
--]]
_p.webAppName = 'Rob'



--[[
        application name can be same or different than plugin name.
        
        Used by application in prompts and stuff.
--]]
_p.appName = "My Plugin"



--[[
        used when a "mashed" name is appropriate...
--]]
_p.pluginMash = _p.appName:gsub( ' ', '' ) -- a no-spaces version of app-name.



--[[
        Project directory.
        
        Generally plugin sources are in subdirectory of this (although that's not required),
        and released package will be put in a subdirectory of this.
--]]
_p.projectDir = str:fmt( "X:/Dev/LightroomPlugins/^1_^2", _p.initials, _p.pluginMash ) -- e.g. .../RC_MyPlugin



--[[
        plugin name added to info.lua and also available for general use.
        
        initials prefix added so one author's plugins are grouped together in plugin manager and in metadata viewer...
        
        Note: I think Lightroom is smart enough to detect a same name and may ignore the ID for some things.
        I couldn't back this up, but I'd suggest a different name for dev version as well as toolkit ID
        if you plan to have both installed simultaneously.
        
        (Dev) may be used to distinguish development plugin from other installed test copies.
        
        Note2: The method for creating a "plugin collection" will look for and strip off the ' (Dev)' if present,
        to avoid having duplicate collections and/or sets when running both dev and release copies.
--]]
_p.relPluginName = str:fmt( "^1 ^2", _p.initials, _p.appName )
_p.devPluginName = str:fmt( "^1 (Dev)", _p.relPluginName ) -- (Dev) distinguishes development plugin from other installed test copies.



--[[
        Plugin ID for the purpose of checking for newer version on server via xml-rpc. Must be same for both develop and release edition
        for checking to work same on both.
        
        *** Note: this is NOT the toolkit ID, although its format is compatible and maybe assigned to dev or rel toolkit Id.
--]]
_p.pluginId = str:fmt( "^1.lightroom.^2", _p.domainIdReversed, _p.pluginMash )



--[[
        Lr Toolkit Identifiers.
        
        Lightroom plugin ID. Developer edition must be different from released edition if they are to be enabled simultaneously,
        or for develop version to have different metadata ( thus the '.lrdevplugin.' ).
        Likewise, Ids must be the same to share metadata.
--]]
_p.devToolkitId = _p.pluginId -- str:fmt( "^1.lrdevplugin.^2", _p.domainIdReversed, _p.pluginMash )
_p.relToolkitId = _p.pluginId



--[[
        plugin url
        
        displayed in plugin manager by default
        also used as web help link by default
        
        Edit to match your website.
--]]
_p.pluginUrl = str:fmt( "http://^1/^2/ProductsAndServices/^3LrPlugin", _p.authorsWebsite, _p.webAppName, _p.pluginMash )



--[[
        donate url
        
        serves as flag to indicate donate button should be displayed, and then what to launch when clicked.
        
        Edit to match your website, or nil for no donate button.
--]]
_p.donateUrl = str:fmt( "http://^1/^2/Donate", _p.authorsWebsite, _p.webAppName )



--[[
        xml-rpc url
        
        Used for update checking.
        
        Edit to match your server, or nil if not implemented on your server.
--]]
_p.xmlRpcUrl = str:fmt( "http://^1/^2/_common/cfpages/XmlRpc.cfm", _p.authorsWebsite, _p.webAppName )



--[[
        platform compatibility
        
        for plugin manager display and general use.
        
        if platform is not on this list, then a warning will be issued to the user
        if they try and run it on an unsupported platform.
--]]
_p.platforms = "{ 'Windows', 'Mac' }" -- this is a string representation of a table/array.



--[[
        Lr SDK minimum version
        
        so far, this has always tracked major version of Lightroom proper.
        
        Used to set lr-sdk-minimum-version in info-lua
        
        Note: Framework has never been tested on Lr2, and there's a good chance not all functions work there.
--]]
_p.lrSdkMin = '3.0'



--[[
        Lr SDK maximum version
        
        so far, this has always tracked major version of Lightroom proper.
        
        Used to set lr-sdk-version in info-lua
        
        If Lightroom (proper) version is greater than this value, a warning
        will be issued to the user.
--]]
_p.lrSdkMax = '3.0'



--[[
        Module repository from which plugin modules will be obtained...
        
        Template dir can be absolute, or relative to plugin generator.
        template plugin folder is considered relative to template dir.
--]]
_p.templateDir = '../Templates'
_p.templatePluginFolder = 'Default.lrdevplugin'



--[[
        Destination directory for develop-mode plugin generation.
--]]
_p.devPluginDir = str:fmt( "^1/^2.lrdevplugin", _p.projectDir, _p.pluginMash )




--[[
        Framework directory.
        
        Used during development to find loader and other framework files - must be absolute.
        In release edition, its expected to be relative to plugin directory.
--]]
_p.frameworkDir = 'X:/Dev/LightroomPlugins/lrdevplugin/trunk/Framework'






--   O P T I O N S


--[[
        Resources
        
        Set to true to have an empty resources directory created for your plugin to use for picture resources...
        Set to false or nil if you do not plan on using custom resources in your plugin.
--]]
_p.resources = false



--[[
        Enable.
        
        Set to true to have plugin enable function.
--]]
_p.enable = false



--[[
        Disable.
        
        Set to true to have plugin disable function.
--]]
_p.disable = false



--[[
        Utility functions module (non object oriented).
        
        Set to true if you anticipate creating utility functions to be used in more than one plugin module.
        Typicall utility module contains static functions only, but you can do what you want with it.
        
        *** Present "best practice" is to use objects for everything.
        Reason being there is no real down side, and if you decide to
        take better advantage of object orient programming,
        then everything's ready.
--]]
_p.utils = false



--[[
        Base/Derived pair of classes.
        
        Set to true if you anticipate creating a class object and optionally derived class.
        
        It is recommended to go ahead and include at least the base class if you are unsure, then delete if it turns out you won't need.
--]]
_p.baseClass = true
_p.derivedClass = false



--[[
        Ftp communications.
        
        Set to true for ftp support.
--]]
_p.ftp = false



--[[
        Background task and initialization.
        
        Set to true for background initialization and/or task support.
--]]
_p.background = false



--[[
        File menu.
        
        Set to string to be on file menu - module name presently hard-coded.
--]]
_p.fileMenu = nil -- "File Menu Item"




--[[
        Library menu.
        
        Set to string to be on file menu - module name presently hard-coded.
        
        I recommend ONLY using library menu if invoking in other modules would be a problem.
        Otherwise, might as well have it available in any module via file menu.
--]]
_p.libMenu = nil -- "Library Menu Item"



--[[
        Configuration file(s).
        
        Configuration files can be used in lieu of creating UIs in the plugin manager, or as a supplement.
        They benefit from being customizable on a per-user basis (plugin manager preferences are not (without some work)).
        Now that I think about it, I'm going to change preferences to always be prefixed by username if supplied. - Good idea.
        Still, config files can be useful for specifying things before plugin-manager UI is complete, or if plugin is targeted at authors
        (like this one), or for escoteric or undocumented features accessible to advanced users, or with coaching...
        
        Set to table of all usernames for which a configuration will be associated.
        
        Note: Non-public config files will be prefixed with '_', since that prefix is reserved for "do not publish" files.
                
        _Anonymous_ username is reserved for user whose name has not been specified.
        
        The idea here is that the end-user can conceibly create different configs for different users. I use this for testing with my
        private configuration vs. public/anonymous config.
        
        Depends on preference/preset manager.
--]]
_p.config = { 'Default' } -- file backing.



--[[
        Preference/Preset Manager
        
        *** This is required for config file backing.
        
        Adds preset management section to plugin manager, and associated code to support
        preference presets, optionally backed by lua config files.
--]]
_p.prefMngr = true



--[[
        Extended Manager.
        
        If plugin will have anything additional to add to the UI in plugin manager.
        In general, I recommend leaving this true, in case you think of something
        before dev fini...
--]]
_p.extendedManager = true



--[[
        Export option.
        
        Set to export service name if export functionality desired.
        
        Module filename is hardcoded to "Export.lua", export tablename is hardcoded "Export".
        Presets directory is hardcoded to "Export Presets"
        
        All other export options are defined by template.
--]]        
_p.export = nil -- _p.appName .. " Export Service"



--[[
        Export filter specs.
        
        Set export filter name / id if export filter functionality desired.

        Example:
        
            _p.exportFilterName = "Export Middler"        
            _p.exportFilterId = "com.janedoe.exportfilter.MyPlugin"        
        
--]]        
_p.exportFilterName = nil -- _p.appName .. " Export Filter"
_p.exportFilterId = str:fmt( "^1.exportfilter.^2", _p.domainIdReversed, _p.pluginMash ) -- a "don't care" if name not set.



--[[
        Metdata options.
        
        Presently this is go/no-go and you are on your own to specify metadata as you see fit.
        
        Module filename is "Metadata.lua"
        
        The reason it defaults to false, is in case you forget, it won't be asking
        to update a catalog in order to put no metadata in it.
--]]                
_p.metadata = false



--[[
        Tagset option.
        
        Presently this is go/no-go and you are on your own to specify tagsets as you see fit.
        
        Module filename is "Tagsets.lua"
        
        Hint: this is a good way to get plugin-init to run upon Lightroom startup.
        The other way, is to have metadata, but then Lr will prompt for catalog update
        when loading plugin. - tagset return value can be empty table, metadata return value can not.
--]]                
_p.tagsets = true



--[[
        Shutdown options.
        
        Presently this is go/no-go and you are on your own to specify shutdown behavior as you see fit.
        
        Module filename is "Shutdown.lua"
        
        Primary usefulness so far has been to shutdown background tasks, although
        could easily shutdown any other running tasks too, in case user decides to
        reload while its still doing something.
--]]                
_p.shutdown = true





--[[ 
        H E L P   O P T I O N S
        
        Note: Present scheme allows for one local help and one web help.
        
        If you want more options, then you are on your own.
        
        You can still specify a local and/or web help to get you started, then replicate/modify as desired...
--]]


--[[
        Local Help options.
        
        You pick the help menu name, associated module name is hardcoded: HelpLocal.lua
        You can modify the module contents as desired.
        
        Personally, I like forcing user to go through quick tips to get to web help,
        since often times the answer is easiest to find right there in the quick tips.
--]]        
_p.helpLocal = nil -- "Quick Tips"



--[[
        Web Help options.
        
        You pick the menu name, associated module name is hardcoded: HelpWeb.lua
        You can modify the module contents as desired.
        Default behavior of web-help module is to launch the plugin-url in browser.
--]]        
_p.helpWeb = nil -- "Web Help" - no longer defaulting to web-help.



--[[
        Enter pref name for exiftool,
        and a global exifTool object will be created that
        is tied to the specified preference first (looks for local pref
        first, and if not found tries global pref), and looks
        for exiftool with plugin if not specified as a preference.
        
        Examples:
        
            _p.exifToolPref = 'exifToolApp' -- include support for exiftool, and get custom exiftool executable option as pref/global-pref.
            _p.exifToolPref = nil           -- plugin does not need exif-tool.
--]]
-- _p.exifToolPref = 'exifToolApp'
_p.exifToolPref = nil



--[[
        Explicit specification of Lr modules that would not otherwise be loaded.
        
        Consider:
        
            - LrMD5
            - Lr
        
        expressly specified Lr modules will be added directly to global namespace.
--]]
_p.addLightroom = {} --  'LrMD5' }



--[[
        Explicit specification of Our modules that would not otherwise be loaded.
        
        expressly specified framework modules will be added to global namespace.
--]]
_p.addFramework = {}



--[[
        Explicit specification of plugin "sibling" modules that would not otherwise be loaded.
        
        expressly specified plugin modules will be added directly to global namespace.
--]]
_p.addPlugin = {}



--[[
        Other important but not well documented stuff:
--]]
_p.relPluginFolder = str:fmt( "^1.lrplugin", _p.pluginMash ) -- e.g. MyPlugin.lrplugin
_p.copyright = str:fmt( "Copyright (c) 2010-2011, ^1", _p.domainId )
_p.licenseFile = str:fmt( "Artistic_2.0_LICENSE.txt" )
_p.licenseName = str:fmt( "^1.LICENSE.txt", _p.pluginMash ) -- e.g. MyPlugin.LICENSE.txt
_p.readmeFile = nil -- accept default.
_p.readmeName = str:fmt( "^1.README.txt", _p.pluginMash ) -- e.g. MyPlugin.README.txt
_p.distFolder = nil -- Optional: 'ReleasePackageContents' is the default distribution subfolder of project dir. should be simple subdir name.
_p.zipName = str:fmt( "^1_^2_LrPlugin_${VERSION}.zip", _p.initials, _p.pluginMash ) -- e.g. RC_MyPlugin_LrPlugin_1.0.zip (releasor will replace version)
_p.pluginFilesToCopy = nil -- specified explicitly using source subpath, and optional dest subpath, e.g. { { "Resources/_normallyOmitted.a", "Resources/normal.b" }, { "_abbyNormal.z" } }
    -- Note: since all plugin files are copied by default, except for programmed omissions, this is the way to get otherwise omitted files over.
_p.projectFilesToCopy = nil -- can be used for other-wise omissions, but also, project files are not copied by default (same format: src sub-path + optional dest sub-path.


return { pluginSpec=_p }