return {
    appName = "Plugin Generator",
    author = "Rob Cole",
    authorsWebsite = "www.robcole.com",
    platforms = { 'Windows', 'Mac' },
    buyUrl = false,
    donateUrl = false,
	pluginId = "com.robcole.PluginGenerator",
    -- xmlRpcUrl = 

	LrSdkVersion = 3.0,
	LrSdkMinimumVersion = 3.0, -- minimum SDK version required by this plugin

    LrPluginName = "Plugin Generator - Dev",
	LrToolkitIdentifier = "com.robcole.develop.PluginGenerator",
	
	LrPluginInfoProvider = 'ExtendedManager.lua',
	LrPluginInfoUrl = "file://X:/Dev/LightroomPlugins/lrdevplugin/trunk/PluginGenerator",
	LrMetadataProvider = 'Metadata.lua',
	
	LrInitPlugin = 'Init.lua',
	-- LrShutdownPlugin = 'Shutdown.lua',
	
	LrHelpMenuItems = {
	    {
    		title = "Quick Tips",
    		file = "HelpLocal.lua",
        },
	    {
    		title = "Web Help",
    		file = "HelpWeb.lua",
        },
    },
	
	
    VERSION = { major=0, minor=0, revision=0, build=0, },

}
