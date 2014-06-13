--[[
        ExternalApp.lua
        
        Base class for external application objects, like exif-tool, image-magick, and sqlite.
        
        This class and/or its derived children hopefully handle cross-platform issues as much as possible.
--]]


local ExternalApp, dbg = Object:newClass{ className = 'ExternalApp', register = true }



--- Constructor for extending class.
--
function ExternalApp:newClass( t )
    return Object.newClass( self, t )
end



--- Constructor for new instance.
--
--  @param t initialization table, with optional named elements:<br>
--           - prefName: to get exe/app name/path from local/global prefs.<br>
--           - winExeName: name of windows exe file in plugin folder.<br>
--           - macAppName: name of mac command-line executable file in plugin folder.<br>
--           - winPathedName: name of windows exe file expected to be in environment path.<br>
--           - macPathedName: name of mac command-line executable expected to be registered ala Mac OS.<br>
--
--  @usage An error is thrown if at least something hasn't been found for executable.
--  @usage Depends on initialized prefs. ###1
--
function ExternalApp:new( t )
    local o = Object.new( self, t )
    if o.prefName ~= nil then
        o.exe = app:getPref( o.prefName )
        if not str:is( o.exe ) then
            o.exe = app:getGlobalPref( o.prefName )
        end
    end
    if not str:is( o.exe ) then
        if WIN_ENV then
            if o.winExeName ~= nil then
                o.exe = LrPathUtils.child( _PLUGIN.path, o.winExeName )
                if not fso:existsAsFile( o.exe ) then
                    app:error( "Windows executable does not exist: ^1", o.exe )
                    o.exe = nil
                end
            elseif o.winPathedName ~= nil then
                o.exe = o.winPathedName
            end
        else
            if o.macAppName ~= nil then
                o.exe = LrPathUtils.child( _PLUGIN.path, o.macAppName )
                if not fso:existsAsFile( o.exe ) then
                    app:error( "Mac executable does not exist: ^1", o.exe )
                    o.exe = nil
                end
            elseif o.macPathedName ~= nil then
                o.exe = o.macPathedName
            end
        end
    end
    if not str:is( o.exe ) then
        error( "external app executable is missing" ) -- ###1
    end
    return o
end



--- execute external application via command-line.
--
--  @param params (string, default="") command-line parameters, if any.
--  @param targets (table(array), default={}) list of command-line targets, usually paths.
--  @param outPipe (outPipe, default=nil) optional output file (piped via '>'), if nil temp file will be used for output filename if warranted by out-handling.
--  @param outHandling (string, default=nil) optional output handling, 'del' or 'get' are popular choices - see app-execute-command for details.
--
function ExternalApp:execute( params, targets, outPipe, outHandling )

    if self.exe then
        local s, m = app:executeCommand( self.exe, params, targets, outPipe, outHandling )
        return s, m
    else
        app:error( "no exe" ) -- this must be filled in, if not during new object construction, sometime during init.
    end

end



return ExternalApp