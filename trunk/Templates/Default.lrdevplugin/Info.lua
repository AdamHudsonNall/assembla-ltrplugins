--[[
        Info.lua
--]]

return {
-- *** GEN_BEGIN main
    appName = "Template Default",
    author = "Rob Cole",
    authorsWebsite = "www.robcole.com",
    platforms = { 'Windows', 'Mac' },
    -- pluginId = , - same as toolkit id
    xmlRpcUrl = "http://localhost",
    LrPluginName = "Template Default",
    LrSdkMinimumVersion = 2.0,
    LrSdkVersion = 3.0,
    LrPluginInfoUrl = "file://X:/Dev/LightroomPlugins/lrdevplugin/trunk/Templates/Default.lrdevplugin",
    LrPluginInfoProvider = "ExtendedManager.lua",
    LrToolkitIdentifier = "com.robcole.templates.default",
    LrInitPlugin = "Init.lua",
    LrShutdownPlugin = "Shutdown.lua",
    LrEnablePlugin = "Enable.lua",
    LrDisablePlugin = "Disable.lua",
    LrExportServiceProvider = {
        title = "Template Default Export",
        file = "ExtendedExport.lua",
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
    },
    LrExportMenuItems = {
        title = "Template Default File",
        file = "FileMenuItem.lua",
    },
    LrLibraryMenuItems = {
        title = "Template Default Library",
        file = "LibraryMenuItem.lua",
    },
    VERSION = { major=0, minor=0, revision=0, build=0, },
-- *** GEN_END
}
