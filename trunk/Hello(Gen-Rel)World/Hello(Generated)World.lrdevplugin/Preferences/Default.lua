--[[
        Plugin configuration file.
--]]

-- declare return table
local _t = {}

-- config subtable #1
local _p1 = {}
_p1.v1 = "Hello"

-- config subtable #2
local _p2 = {}
_p2.v1 = "World"

-- assign config subtables to return table
_t.spec1 = _p1
_t.spec2 = _p2
-- return config table
return _t