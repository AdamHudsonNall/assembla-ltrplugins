--[[
        Info.lua
--]]

return {
    appName = "Hello World",
    author = "John Doe",
    authorsWebsite = "www.johndoe.con",
    donateUrl = "http://www.robcole.com/Rob/Donate",
    platforms = { 'Windows', 'Mac' },
    pluginId = "con.johndoe.lightroom.HelloWorld",
    xmlRpcUrl = "http://www.robcole.com/Rob/_common/cfpages/XmlRpc.cfm",
    LrPluginName = "JD Hello World (Dev)",
    LrSdkMinimumVersion = 3.0,
    LrSdkVersion = 3.0,
    LrPluginInfoUrl = "http://www.robcole.com/Rob/ProductsAndServices/",
    LrPluginInfoProvider = "ExtendedManager.lua",
    LrToolkitIdentifier = "con.johndoe.lrdevplugin.HelloWorld",
    LrInitPlugin = "Init.lua",
    LrShutdownPlugin = "Shutdown.lua",
    LrEnablePlugin = "Enable.lua",
    LrDisablePlugin = "Disable.lua",
    LrTagsetProvider = "Tagsets.lua",
    LrHelpMenuItems = {
    {
        title = "Quick Tips",
        file = "HelpLocal.lua",
    },
    },
    LrExportMenuItems = {
        title = "Hello World",
        file = "FileMenuItem.lua",
    },
    VERSION = { major=1, minor=0, revision=0, build=0, },
}
