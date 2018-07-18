--Template for addition of new protocol 'tcp'

--[[ Necessary changes to other files:
-- - packet.lua: if the header has a length member, adapt packetSetLength; 
-- 				 if the packet has a checksum, adapt createStack (loop at end of function) and packetCalculateChecksums
-- - proto/proto.lua: add PROTO.lua to the list so it gets loaded
--]]

local ffi = require "ffi"
local dpdkc = require "dpdkc"

require "utils"
require "proto.template"
local initHeader = initHeader


local ntoh, hton = ntoh, hton
local ntoh16, hton16 = ntoh16, hton16
local bor, band, bnot, rshift, lshift= bit.bor, bit.band, bit.bnot, bit.rshift, bit.lshift
local istype = ffi.istype
local format = string.format

function hton64(int)
	int = int or 0
	endianness = string.dump(function() end):byte(7)
	if endianness==0 then
		return int
	end
	low_int = lshift(hton(band(int,0xFFFFFFFFULL)),32)
	high_int = rshift(hton(band(int,0xFFFFFFFF00000000ULL)),32)
	endianness = string.dump(function() end):byte(7)
	return (high_int+low_int)
end


local ntoh64, hton64 = ntoh64, hton64

----- 24 bit address -----
ffi.cdef[[
	union __attribute__((__packed__)) bitfield_24{
		uint32_t intequiv;
	};
]]

local bitfield24 = {}
bitfield24.__index = bitfield24
local bitfield24Type = ffi.typeof("union bitfield_24")

function bitfield24:get()
	return hton(self.intequiv)
end

function bitfield24:set(addr)
	addr = addr or 0
	self.intequiv = hton(tonumber(band(addr,0xFFFFFFFFULL)))

end

----- 40 bit address -----
ffi.cdef[[
	union __attribute__((__packed__)) bitfield_40{
		uint64_t intequiv;
	};
]]

local bitfield40 = {}
bitfield40.__index = bitfield40
local bitfield40Type = ffi.typeof("union bitfield_40")

function bitfield40:get()
	return hton64(self.intequiv)
end

function bitfield40:set(addr)
	addr = addr or 0
	self.intequiv = hton64(tonumber(band(addr,0xFFFFFFFFFFFFFFFFULL)))
end

----- 48 bit address -----
ffi.cdef[[
	union __attribute__((__packed__)) bitfield_48{
		uint32_t intequiv;
	};
]]

local bitfield48 = {}
bitfield48.__index = bitfield48
local bitfield48Type = ffi.typeof("union bitfield_48")

function bitfield48:get()
	return hton64(self.intequiv)
end

function bitfield48:set(addr)
	addr = addr or 0
	self.intequiv = hton64(tonumber(band(addr,0xFFFFFFFFFFFFFFFFULL)))
end


-----------------------------------------------------
---- TCP header and constants 
-----------------------------------------------------
local TCP = {}

TCP.headerFormat = [[
	uint16_t 	 srcPort;
	uint16_t 	 dstPort;
	uint32_t 	 seqNo;
	uint32_t 	 ackNo;
	uint8_t 	 dataOffset;
	uint8_t 	 res;
	uint8_t 	 flags;
	uint16_t 	 window;
	uint16_t 	 checksum;
	uint16_t 	 urgentPtr;
]]


-- variable length fields
TCP.headerVariableMember = nil

-- Module for TCP_address struct
local TCPHeader = initHeader()
TCPHeader.__index = TCPHeader


-----------------------------------------------------
---- Getters, Setters and String functions for fields
-----------------------------------------------------
function TCPHeader:getSRCPORT()
	return hton16(self.srcPort)
end

function TCPHeader:getSRCPORTstring()
	return self:getSRCPORT()
end

function TCPHeader:setSRCPORT(int)
	int = int or 0
	self.srcPort = hton16(int)
end


function TCPHeader:getDSTPORT()
	return hton16(self.dstPort)
end

function TCPHeader:getDSTPORTstring()
	return self:getDSTPORT()
end

function TCPHeader:setDSTPORT(int)
	int = int or 0
	self.dstPort = hton16(int)
end


function TCPHeader:getSEQNO()
	return hton(self.seqNo)
end

function TCPHeader:getSEQNOstring()
	return self:getSEQNO()
end

function TCPHeader:setSEQNO(int)
	int = int or 0
	self.seqNo = hton(int)
end


function TCPHeader:getACKNO()
	return hton(self.ackNo)
end

function TCPHeader:getACKNOstring()
	return self:getACKNO()
end

function TCPHeader:setACKNO(int)
	int = int or 0
	self.ackNo = hton(int)
end


function TCPHeader:getDATAOFFSET()
	return (self.dataOffset)
end

function TCPHeader:getDATAOFFSETstring()
	return self:getDATAOFFSET()
end

function TCPHeader:setDATAOFFSET(int)
	int = int or 0
	self.dataOffset = (int)
end


function TCPHeader:getRES()
	return (self.res)
end

function TCPHeader:getRESstring()
	return self:getRES()
end

function TCPHeader:setRES(int)
	int = int or 0
	self.res = (int)
end


function TCPHeader:getFLAGS()
	return (self.flags)
end

function TCPHeader:getFLAGSstring()
	return self:getFLAGS()
end

function TCPHeader:setFLAGS(int)
	int = int or 0
	self.flags = (int)
end


function TCPHeader:getWINDOW()
	return hton16(self.window)
end

function TCPHeader:getWINDOWstring()
	return self:getWINDOW()
end

function TCPHeader:setWINDOW(int)
	int = int or 0
	self.window = hton16(int)
end


function TCPHeader:getCHECKSUM()
	return hton16(self.checksum)
end

function TCPHeader:getCHECKSUMstring()
	return self:getCHECKSUM()
end

function TCPHeader:setCHECKSUM(int)
	int = int or 0
	self.checksum = hton16(int)
end


function TCPHeader:getURGENTPTR()
	return hton16(self.urgentPtr)
end

function TCPHeader:getURGENTPTRstring()
	return self:getURGENTPTR()
end

function TCPHeader:setURGENTPTR(int)
	int = int or 0
	self.urgentPtr = hton16(int)
end



-----------------------------------------------------
---- Functions for full header
-----------------------------------------------------
-- Set all members of the PROTO header
function TCPHeader:fill(args,pre)
	args = args or {}
	pre = pre or 'TCP'

	self:setSRCPORT(args[pre .. 'SRCPORT'])
	self:setDSTPORT(args[pre .. 'DSTPORT'])
	self:setSEQNO(args[pre .. 'SEQNO'])
	self:setACKNO(args[pre .. 'ACKNO'])
	self:setDATAOFFSET(args[pre .. 'DATAOFFSET'])
	self:setRES(args[pre .. 'RES'])
	self:setFLAGS(args[pre .. 'FLAGS'])
	self:setWINDOW(args[pre .. 'WINDOW'])
	self:setCHECKSUM(args[pre .. 'CHECKSUM'])
	self:setURGENTPTR(args[pre .. 'URGENTPTR'])
end

-- Retrieve the values of all members
function TCPHeader:get(pre)
	pre = pre or 'TCP'

	local args = {}
	args[pre .. 'SRCPORT'] = self:getSRCPORT()
	args[pre .. 'DSTPORT'] = self:getDSTPORT()
	args[pre .. 'SEQNO'] = self:getSEQNO()
	args[pre .. 'ACKNO'] = self:getACKNO()
	args[pre .. 'DATAOFFSET'] = self:getDATAOFFSET()
	args[pre .. 'RES'] = self:getRES()
	args[pre .. 'FLAGS'] = self:getFLAGS()
	args[pre .. 'WINDOW'] = self:getWINDOW()
	args[pre .. 'CHECKSUM'] = self:getCHECKSUM()
	args[pre .. 'URGENTPTR'] = self:getURGENTPTR()

	return args
end

function TCPHeader:getString()
	return 'TCP \n'
		.. 'SRCPORT' .. self:getSRCPORTString() .. '\n'
		.. 'DSTPORT' .. self:getDSTPORTString() .. '\n'
		.. 'SEQNO' .. self:getSEQNOString() .. '\n'
		.. 'ACKNO' .. self:getACKNOString() .. '\n'
		.. 'DATAOFFSET' .. self:getDATAOFFSETString() .. '\n'
		.. 'RES' .. self:getRESString() .. '\n'
		.. 'FLAGS' .. self:getFLAGSString() .. '\n'
		.. 'WINDOW' .. self:getWINDOWString() .. '\n'
		.. 'CHECKSUM' .. self:getCHECKSUMString() .. '\n'
		.. 'URGENTPTR' .. self:getURGENTPTRString() .. '\n'
end

-- Dictionary for next level headers
local nextHeaderResolve = {
}
function TCPHeader:resolveNextHeader()
	return nil
end


-----------------------------------------------------
---- Metatypes
-----------------------------------------------------
ffi.metatype('union bitfield_24',bitfield24)
ffi.metatype('union bitfield_40',bitfield40)
ffi.metatype('union bitfield_48',bitfield48)TCP.metatype = TCPHeader

return TCP