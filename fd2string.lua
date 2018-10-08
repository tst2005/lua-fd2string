local class = require "mini.class.pico" -- see https://github.com/tst2005/lua-mini/blob/dev/mini/class/pico.lua

local fd2string = class()

function fd2string:init(fd)
	local current = fd:seek("cur") -- backup the original position
	assert(current, "unable to seek")

	assert(current == 0, "not supported yet")
	-- try to get the end of file
	local ok, eof = pcall(function() return fd:seek("end", 0) end)
	assert(ok, "unable to seek")
	-- restore original position
	ok, restored = pcall(function() return fd:seek("set", current) end) --
	assert(ok, "unable to seek back")

	local size = eof+1 - current
	self._ = {}
	self._.fd = fd
	self._.fdsize = size
	self._.size = size
	self._.rdata = ""
	local mt = getmetatable(self)
	if not mt then
		mt = {}
		setmetatable(self, mt)
	end
	mt.__len = fd2string.__len
	mt.__concat = fd2string.__concat
	return self
end

local function new(fd)
	local self = fd2string()
	return self:init(fd)
end

function fd2string:__len()
	return self._.size
end

function fd2string:__concat(str2)
	if type(str2)=="string" then
		local wantedsize = #self + #str2
		local _ = self._
		local fd = _.fd
		local rdata = _.rdata
		fd:seek("set", 0)

		local r = new(fd) -- TODO: self:clone() ?
		_  = r._
		_.rdata = rdata .. str2
		_.size = _.size + #rdata + #str2
		return r
	end
	error("unable to concat", 2)
end
	

function fd2string:byte(i,j)
--print("fd2string:byte",i, j)
	assert(i>0) assert(j>0)
	local _ = self._
	if i > _.size then return end

	local fd = _.fd
	fd:seek("set", i-1)
	j = j or i
	local len = j-i+1
	local substr = fd:read(len) or ""
	local fdsize = _.fdsize
	if j > fdsize then
		-- ...fd:read("*a")........
		--                        ^--------------------- fdsize
		--                        ^--------------------- size
		--
		-- Now we concat rdata
		--                         ....rdata.........
		--                                          ^--- size (updated, after concat)
		--                        ^--------------------- fdsize (no change)
		--                         ....rdata.........
		--                            i     j
		--                            <-len->
		-- if j > original_size    [here............]

		--local rdatastart = math.max(i, fdsize+1)-fdsize
		local rdatastart = math.max(i, fdsize)-fdsize+1

		local rsubstr = (_.rdata):sub(rdatastart, rdatastart+len-#substr-1)
		substr = substr .. rsubstr
		print(rdatastart)
		print(#substr, len, rsubstr, i, j, _.size)
		assert(#substr==len)
	end
	--return string.byte(substr, 1, -1)
	return string.byte(substr, 1, len)
end

function fd2string:sub(i,j)
	return string.char(self:byte(i,j))
end

return new

