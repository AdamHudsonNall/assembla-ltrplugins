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
    LrPluginName = "Hello (Generated) World - Dev",
    LrSdkMinimumVersion = 2.0,
    LrSdkVersion = 3.0,
    LrPluginInfoUrl = "file://X:/Dev/LightroomPlugins/lrdevplugin/trunk/Hello(Gen-Rel)World/Hello(Generated)World.lrdevplugin",
    LrPluginInfoProvider = "SpecialManager.lua",
    LrToolkitIdentifier = "com.robcole.develop.Hello(Gen)World",
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
    VERSION = { major=0, minor=0, revision=0, build=0, },
}
