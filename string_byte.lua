local string = require "string"
local string_byte = assert(string.byte)
local type = type
local function _byte(x, ...)
	if type(x) == "table" and type(x.byte)=="function" then
		return x:byte(...)
	end
	return string_byte(x, ...)
end
return _byte
