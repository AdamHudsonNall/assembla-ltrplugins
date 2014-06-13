--[[
        GenRelCommon.lua
        
        Namespace shared by generate and release modules.
        
        Contains template substitution functions.
--]]


local GenRelCommon, dbg = Object:newClass{ className = 'GenRelCommon' }



--- Constructor for class extension.        
--
function GenRelCommon:newClass( t )
    return Object.newClass( self, t )
end



--- Constructor for new instance.
--
function GenRelCommon:new( t )
    return Object.new( self, t )
end



--- Clears existing tree, except for subversion stuff.
--      
--  <p>Does not delete tree root.</p>
--      
--  <p>Used for deleting lrdevplugin folder before generating plugin,
--  and used for deleting lrplugin folder before releasing plugin.</p>
--
--  @param      dir     path to lrdevplugin folder to be pre-deleted.
--
function GenRelCommon:deleteTree( dir )

    for file in LrFileUtils.recursiveFiles( dir ) do
        repeat
            if file:find( "svn", 1, true ) then
                break
            end
            if trash then
                fso:moveToTrash( file )
            else
                LrFileUtils.delete( file )
            end
        until true
    end

    for file in LrFileUtils.recursiveDirectoryEntries( dir ) do
        repeat        
            if file:find( "svn", 1, true ) then
                break
            end
            if trash then
                fso:moveToTrash( file )
            else
                LrFileUtils.delete( file )
            end
        until true
    end

    return true, "why not..."

end



--- Divide file contents into alternating un-named and named blocks of lines.
--      
--  <p>Unnamed blocks are the parts between END & BEGIN tags, name blocks are the
--  parts between BEGIN & END tags.</p>
--      
--  <p>Note: unnamed blocks are named nil.
--  Named blocks whose name has not been specified, are named ''.</p>
--      
--
--  @param      pfx                 Token prefix, e.g. 'GEN' or 'REL'.
--  @param      textFileContents    Text read from text file without those pesky zero bytes.
--
function GenRelCommon:tokenize( pfx, textFileContents )

    local tbl = {}
    local subtbl = {}
    local state = 0
    local name = nil
    local begMark = "*** " .. pfx .. "_BEGIN"
    local endMark = "*** " .. pfx .. "_END"

    local lineCount = 0

    for line in str:lines( textFileContents ) do -- auto eol detect.
        lineCount = lineCount + 1
        if state == 0 then
            -- subtbl[#subtbl + 1] = line
            local start, stop = line:find( begMark, 1, true )
            if start then
                tbl[#tbl + 1] = subtbl
                subtbl = {}                
                if stop < line:len() then
                    subtbl.name = LrStringUtils.trimWhitespace( line:sub( stop + 1 ) )
                    -- dbg( "parsed name: ", subtbl.name )
                    subtbl[#subtbl + 1] = line
                else
                    subtbl.name = ""
                end
                state = 1
            else
            
                subtbl[#subtbl + 1] = line

            end
        elseif state == 1 then
            subtbl[#subtbl + 1] = line
            local start, stop = line:find( endMark, 1, true )
            if start then
                tbl[#tbl + 1] = subtbl
                subtbl = {}
                state = 0
            -- else keep going in state 1
            end
        -- there is no else...
        end
    end
    
    if #subtbl > 0 then
        tbl[#tbl + 1] = subtbl
    end
            
    if lineCount > 1 then
        return tbl
    else
        error( "invalid line count: " .. lineCount )
    end

end



return GenRelCommon
