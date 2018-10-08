local string_byte = require "string_byte"
string.byte = string_byte

local fd2string = require "fd2string"
local str = fd2string(assert(io.open("hello.data","r")))
--local str = fd2string(assert(io.stdin))
print(#str)
print( str:sub(1,4) )
print( str:byte(1,4) )
print( string.byte(str, 1, 4) )

local str = str .. "ABC"
local str = str .. "def"
print("size", #str)
print("----")
for i=1,#str+4,4 do
	local j = i+3
	--print(str:byte(i,j))
	local x = str:sub(i,j)
	print(#x, x)
end
