require("pack")
require("bit")
local SocketTcp = require("net.SocketTcp")
local ByteArray = require("utils.ByteArray")
local ByteArrayVarint = require("utils.ByteArrayVarint")

local MainScene = class("MainScene", function()
    return display.newScene("MainScene")
end)

function MainScene:ctor()
	echoInfo("socket.getTime:%f", SocketTcp.getTime())
	echoInfo("os.gettime:%f", os.time())
	echoInfo("socket._VERSION: %s", SocketTcp._VERSION)

	local __luaSocketLabel = ui.newTTFLabelMenuItem({
		text = "lua socket connect",
		size = 32,
		x = display.cx,
		y = display.top - 128,
		listener = handler(self, self.onLuaSocketConnectClicked),
	})

	local __luaSocketSendLabel = ui.newTTFLabelMenuItem({
		text = "lua socket send",
		size = 32,
		x = display.cx,
		y = display.top - 160,
		listener = handler(self, self.onLuaSocketSendClicked),
	})

    self:addChild(ui.newMenu({__luaSocketLabel, __luaSocketSendLabel}))

	self:testByteArray()
end

function MainScene:testByteArray()
	local __pack = self:getDataByLpack()
	local __ba = ByteArray.new()
	__ba:writeBuf(__pack)
	__ba:setPos(1)
	print("ba.len:", __ba:getLen())
	print("ba.readByte:", __ba:readByte())
	print("ba.readByte:", __ba:readByte())
	print("ba.readByte:", __ba:readByte())
	print("ba.readInt:", __ba:readInt())
	print("ba.readShort:", __ba:readShort())
	print("ba.readByte:", __ba:readByte())
	print("ba.readByte:", __ba:readByte())
	print("ba.readByte:", __ba:readByte())
	print("ba.readString:", __ba:readStringUShort())
	print("ba.available:", __ba:getAvailable())
	print("ba.toString(16):", __ba:toString(16))

	local __ba2 = self:getByteArray()
	print("ba2.toString(16):", __ba2:toString(16))

end

function MainScene:getDataByLpack()
	local __pack = string.pack("<b3ihb3P", 0x59, 0x7a, 0, 11, 1101,
		bit.bor(0,0), 
		bit.bor(bit.lshift(1,3), 0), 
		bit.bor(bit.lshift(2,3), 0),
		"中文")
	return __pack
end

function MainScene:getByteArray()
	local __ba = ByteArray.new()
	__ba:writeByte(0x59)
	__ba:writeByte(0x7a)
	__ba:writeByte(0)
	__ba:writeInt(11)
	__ba:writeShort(1101)
	__ba:writeByte(bit.bor(0,0))
	__ba:writeByte(bit.bor(bit.lshift(1,3), 0))
	__ba:writeByte(bit.bor(bit.lshift(2,3), 0))
	__ba:writeStringUShort("中文")
	return __ba
end


function MainScene:onStatus(__event)
	echoInfo("socket status: %s", __event.name)
end

function MainScene:onData(__event)
	echoInfo("socket status: %s, partial:%s", __event.name, ByteArray.toString(__event.data))
end


function MainScene:onLuaSocketConnectClicked()
	if not self.socket then
		self.socket = SocketTcp.new("192.168.18.22", 12001, false)
		self.socket:addEventListener(SocketTcp.EVENT_CONNECTED, handler(self, self.onStatus))
		self.socket:addEventListener(SocketTcp.EVENT_CLOSE, handler(self,self.onStatus))
		self.socket:addEventListener(SocketTcp.EVENT_CLOSED, handler(self,self.onStatus))
		self.socket:addEventListener(SocketTcp.EVENT_CONNECT_FAILURE, handler(self,self.onStatus))
		self.socket:addEventListener(SocketTcp.EVENT_DATA, handler(self,self.onData))
	end
	self.socket:connect()
end

function MainScene:onLuaSocketSendClicked()
	if not self.socket then return end
	local __pack = self:getDataByLpack()
	--local __pack = self:getByteArray():getPack()
	self.socket:send(__pack)
	print("__pack: ", string.len(__pack))
end

return MainScene
