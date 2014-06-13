--[[
        Info.lua
--]]

return {
    appName = "Hello World",
    author = "Rob Cole",
    authorsWebsite = "www.robcole.com",
    platforms = { 'Windows', 'Mac' },
    pluginId = "com.robcole.Hello(Gen)World",
    xmlRpcUrl = "http://www.robcole.com/Rob/_common/cfpages/XmlRpc.cfm",
    LrPluginName = "Hello (Released) World",
    LrSdkMinimumVersion = 2.0,
    LrSdkVersion = 3.0,
    LrPluginInfoUrl = "http://www.robcole.com/Rob/ProductsAndServices/HelloWorldLrPlugin",
    LrPluginInfoProvider = "SpecialManager.lua",
    LrToolkitIdentifier = "com.robcole.lightroom.Hello(Rel)World",
    LrInitPlugin = "Init.lua",
    LrShutdownPlugin = "Shutdown.lua",
    LrEnablePlugin = "Enable.lua",
    LrDisablePlugin = "Disable.lua",
    LrExportServiceProvider = {
        title = "Hello Export Service",
        file = "SpecialExport.lua",
        builtInPresetsDir = "Export Presets",
    },
    LrMetadataProvider = "Metadata.lua",
    LrHelpMenuItems = {
    {
        title = "Quick Tips",
        file = "HelpLocal.lua",
    },
    {
        title = "Web Help",
        file = "HelpWeb.lua",
    },
    {
        title = "&Reload",
        file = "Reload.lua",
    },
    },
    LrExportMenuItems = {
        title = "Hello",
        file = "FileMenuItem.lua",
    },
    LrLibraryMenuItems = {
        title = "Hello Library",
        file = "LibraryMenuItem.lua",
    },
    VERSION = { display = "1.0    Build: 2011-01-31 01:17:01" },
}
