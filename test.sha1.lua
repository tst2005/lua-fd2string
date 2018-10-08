local string_byte = require "string_byte"
local orig_string_byte = string.byte
string.byte = string_byte

local sha1 = require "sha1"

local fd2string = require "fd2string"



--print(sha1(str))

if false then

assert(sha1("hello\n")=="f572d396fae9206628714fb2ce00f72e94f2258f")

local fakefd = {read=function() return nil end, seek=function() return 0 end}
local str = fd2string( fakefd )
str = str .. "hello\n"
--print(#str)
assert(sha1(str)=="f572d396fae9206628714fb2ce00f72e94f2258f")

end

--local str = fd2string(assert(io.open("hello.data","r")))
local str = fd2string( io.open("/etc/passwd","r") )
print(sha1(str))
