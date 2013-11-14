--[[
PacketBuffer receive the byte stream and analyze them, then pack them into a message packet.
The method name, message metedata and message body will be splited, and return to invoker.
@see https://github.com/zrong/as3/blob/master/src/org/zengrong/net/PacketBuffer.as
@author zrong(zengrong.net)
Creation: 2013-11-14
]]

local PacketBuffer = class("PacketBuffer")
local Protocol = require("Protocol")
local ByteArrayVarint = require("utils.ByteArrayVarint")
require("bit")

PacketBuffer.ENDIAN = ByteArrayVarint.ENDIAN_LITTLE

PacketBuffer.MASK1 = 0x59
PacketBuffer.MASK2 = 0x7a
PacketBuffer.RANDOM_MAX = 10000
PacketBuffer.PACKET_MAX_LEN = 2100000000

PacketBuffer.FLAG_LEN = 2	-- package flag at start, 1byte per flag
PacketBuffer.TYPE_LEN = 1	-- type of message, 1byte
PacketBuffer.BODY_LEN = 4	-- length of message body, int
PacketBuffer.METHOD_LEN = 2	-- length of message method code, short
PacketBuffer.VER_LEN = 1	-- version of message, byte
PacketBuffer.META_NUM_LEN = 1	-- how much item in a message, 1byte

local DATA_TYPE = 
{
	R = 0,
	S = 1,
	r = 2,
	t = 3
}

local DATA_TYPE_UVINT = 0	-- how much item in a message, 1byte
local DATA_TYPE_STRING = 1	-- how much item in a message, 1byte
local DATA_TYPE_VINT = 2	-- how much item in a message, 1byte
local DATA_TYPE_LIST = 3	-- how much item in a message, 1byte

function PacketBuffer.getBaseBA()
	return ByteArrayVarint.new(PacketBuffer.ENDIAN)
end

function PacketBuffer:ctor()
	self._buf = self.getBaseBA()
end

--- Create a formated packet that to send server
-- @param __msgDef the define of message, a table
-- @param __msgBodyTable the message body with key&value, a table
function PacketBuffer:createPackets(__msgDef, __msgBodyTable)
	if self._buf:getLen()>0 then self._buf = self.getBaseBA() end
	-- write 2 flags and message type, for clent, is always 0
	self._buf:rawPack("b3ihb", 
		PacketBuffer.MASK1, 
		PacketBuffer.MASK2, 
		0,
		__LEN__,
		__METHOD_CODE__,
		0,
		unpack()
		)
end

--- metadata item description
function PacketBuffer:_getMetaDes(__metaTable)
	local __fmt = nil
	local __byteTable = {}
	for i=1,#__metaTable do
		__fmt = __metaTable[i]
		-- create a metadata description: data number(7~3bit) + data type(0~1bit)
		__byteTable[i] = bit.bor(bit.lshift(i-1, 3), DATA_TYPE[__fmt])
	end
	return __byteTable
end

function PacketBuffer:_getBody()
end

function PacketBuffer:_writeMeta()
end

function PacketBuffer:_writeBody()
end


--- Get a byte stream and analyze it, return a splited table
-- Generally, the table include a message, but if it receive 2 packets meanwhile, then it includs 2 messages.
function PacketBuffer:parsePackets(__byteString)
	local __msgs = {}
	local __pos = 0
	self._buf:setPos(self._buf:getLen()+1)
	self._buf:writeBuf(__byteString)
	self._buf:setPos(1)
	local __flag1 = nil
	local __flag2 = nil
	printf("start analyzing... buffer len: %u", self._buf:getLen())
	while self._buf:getAvailable() do
	end
end

return PacketBuffer
