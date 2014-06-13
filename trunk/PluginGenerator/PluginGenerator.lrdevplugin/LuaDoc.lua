--[[
        LuaDoc.lua
        
        Class for object that converts function header format and runs lua-doc.
--]]

local LuaDoc, dbg = Object:newClass{ className = 'LuaDoc' }

local spec
local destDir



--- Constructor for class extension.        
--
function LuaDoc:newClass( t )
    return Object.newClass( self, t )
end



--- Constructor for new instance.
--
function LuaDoc:new( t )
    return Object.new( self, t )
end



--- Replace lines in new from start to stop (legacy function comment) with luadoc compatible comment.
--
--  @param      new         array of lines containing entire lua file under construction.
--  @param      start       line number (new index) of top line of legacy function comment.
--  @param      stop        line number (new index) of bottom line of legacy function comment.
--
--  @usage      Presently just finds first non empty line and prefixes it with '---', then puts '--'
--              <br>in front of all subsequent lines until it gets to the function def.
--
function LuaDoc:replace( new, start, stop )
    local rpl = {}
    local state = 0
    local index = start
    local diff = 0
    for i = start + 1, stop - 1 do -- omit open-close lines.
        local line = new[i]
        if state == 0 then
            local stuff = LrStringUtils.trimWhitespace( line )
            if str:is( stuff ) then
                local other
                if line:len() > 3 then
                    local s = line:sub( 1, 3 )
                    if s == '   ' then
                        other = '---' .. line:sub( 4 )
                    else
                        other = '---' .. line
                    end                    
                else
                    other = '---' .. line
                end
                new[index] = other
                index = index + 1
                state = 1
            else -- ignore blank lines.
                diff = diff + 1
            end
        elseif state == 1 then
            local other
            if line:len() > 2 then
                local s = line:sub( 1, 2 )
                if s == '  ' then
                    other = '--' .. line:sub( 3 )
                else
                    other = '--' .. line
                end
            else
                other = '--' .. line
            end
            new[index] = other
            index = index + 1
        end
    end
    if index > start then
        new[index] = '--'         -- finish with a blank line for aesthetics
        return diff + 1
    else
        return 0
    end
end



--- Formats all function headers in one file, for luadoc.
--
function LuaDoc:formatFile( file )

    local content, orNot = fso:readTextFile( file )
    if not content then
        app:logError( "No content from: " .. file .. ", error message: " .. orNot )
        return
    end
    local new = {}
    local buf = {}
    local start
    local stop
    local count = 0
    local state = 0
    for line in str:lines( content ) do
        count = count + 1
        new[count] = line
        if state == 0 then
            local beg = line:sub( 1, 4 )
            if beg == '--[[' then
                state = 1
                start = count
            else
            end
        elseif state == 1 then
            local beg = line:sub( 1, 4 )
            if beg == '--]]' then
                state = 2
                stop = count
            elseif line:find( '--]]', 1, true ) then
                state = 0
            end
        elseif state == 2 then
            local beg = line:sub( 1, 8 ) -- function
            if beg == 'function' then
                -- bingo
                local diff = self:replace( new, start, stop )
                count = count - diff
                new[count] = line
                state = 0
            else
                state = 0
            end
                
        end
    end

    local newStr = table.concat( new, '\n' )
    local answer = app:show( { info="file: " .. file .. "\r\n" .. newStr, actionPrefKey="Rewrite for Lua doc", buttons={{label='Save (Overwrite)',verb='ok'}, {label='Skip (Keep Original)',verb='cancel',memorable=true}} } )
    if answer == 'ok' then
        local yes, no = fso:writeFile( file, newStr )
        if yes then
            app:logInfo( "Rewritten: " .. file )
        else
            app:logError( str:format( "Error writing ^1: ^2", file, no ) )
        end
    elseif answer == 'cancel' then
        app:logInfo( "Skipped: " .. file )
    else
        error( "Aborted" ) -- ###2 should set and check service-abort, instead of throwing an error.
    end

end



--- Formats all files in specified dest-dir for luadoc.
--
function LuaDoc:format()

    for file in LrFileUtils.recursiveFiles( destDir ) do

        repeat
            -- skip svn stuff
            if file:find( "\.svn" ) then
                break
            end
            -- skip non-lua files.
            local ext = LrPathUtils.extension( file )
            if ext ~= 'lua' then
                break
            end
            -- skip underscore-hidden stuff.
            local leaf = LrPathUtils.leafName( file )
            if str:getFirstChar( leaf ) == '_' then
                break
            end
            
            self:formatFile( file )
            
        until true
    end
end



--- Create lua doc - format comments first if necessary.
--
function LuaDoc:luaDoc( t )
    -- dbg( str:to( self ) )
    app:call( Service:new{ name='Lua Doc', async=true, guard=App.guardVocal, main=function( service )
    
        spec = app:getPref( 'pluginSpec' )
        destDir = LrPathUtils.standardizePath( spec.destDir )
        if fso:existsAsDirectory( destDir ) then
            -- good
        else
            error( "Not existing: " .. destDir )
        end
    
        local format = app:getPref( 'format' )
        if format then
            if dialog:isOk( str:format( "Format ^1 first, overwriting originals? ***Hint: backup first!!!", destDir ) ) then
                self:format()
            else
                app:logInfo( "Not preformatting.." )
                -- dbg( "No pre-format." )
            end
        -- else nuthin
        end
        
        app:show( "luadoc not working from plugin yet - run bat file with luadoc_start call for now." )
        --[[local d = LrPathUtils.parent( destDir )
        local s,m = app:executeCommand( "luadoc_start", '-d "' .. d .. '"', { destDir } )
        if s then
            app:logInfo( "Gen'd using command: " .. str:to( m ) )
        else
            app:logError( "No go: " .. m )
        end--]]
        
    end } )
end



return LuaDoc
