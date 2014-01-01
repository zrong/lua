require("pack")
require("bit")
local SocketTCP = require("net.SocketTCP")
local ByteArray = require("utils.ByteArray")
local ByteArrayVarint = require("utils.ByteArrayVarint")

local MainScene = class("MainScene", function()
    return display.newScene("MainScene")
end)

function MainScene:ctor()
	echoInfo("socket.getTime:%f", SocketTCP.getTime())
	echoInfo("os.gettime:%f", os.time())
	echoInfo("socket._VERSION: %s", SocketTCP._VERSION)

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
	local __ba1 = ByteArray.new()
		:writeBuf(__pack)
		:setPos(1)
	print("ba1.len:", __ba1:getLen())
	print("ba1.readByte:", __ba1:readByte())
	print("ba1.readInt:", __ba1:readInt())
	print("ba1.readShort:", __ba1:readShort())
	print("ba1.readString:", __ba1:readStringUShort())
	print("ba1.readString:", __ba1:readStringUShort())
	print("ba1.available:", __ba1:getAvailable())
	print("ba1.toString(16):", __ba1:toString(16))
	print("ba1.toString(10):", __ba1:toString(10))

	local __ba2 = self:getByteArray()
	print("ba2.toString(10):", __ba2:toString(10))


	local __ba3 = ByteArray.new()
	local __str = ""
	for i=1,20 do
		__str = __str.."ABCDEFGHIJ"
	end
	__ba3:writeStringSizeT(__str)
	__ba3:setPos(1)
	print("__ba3:readUInt:", __ba3:readUInt())
	--print("__ba3.readStringSizeT:", __ba3:readStringUInt())
end

function MainScene:getDataByLpack()
	local __pack = string.pack("<bihP2", 0x59, 11, 1101, "", "中文")
	return __pack
end

function MainScene:getByteArray()
	return ByteArray.new()
		:writeByte(0x59)
		:writeInt(11)
		:writeShort(1101)
		:writeStringUShort("")
		:writeStringUShort("中文")
end


function MainScene:onStatus(__event)
	echoInfo("socket status: %s", __event.name)
end

function MainScene:onData(__event)
	echoInfo("socket status: %s, partial:%s", __event.name, ByteArray.toString(__event.data))
end


function MainScene:onLuaSocketConnectClicked()
	if not self.socket then
		self.socket = SocketTCP.new("192.168.18.22", 12001, false)
		self.socket:addEventListener(SocketTCP.EVENT_CONNECTED, handler(self, self.onStatus))
		self.socket:addEventListener(SocketTCP.EVENT_CLOSE, handler(self,self.onStatus))
		self.socket:addEventListener(SocketTCP.EVENT_CLOSED, handler(self,self.onStatus))
		self.socket:addEventListener(SocketTCP.EVENT_CONNECT_FAILURE, handler(self,self.onStatus))
		self.socket:addEventListener(SocketTCP.EVENT_DATA, handler(self,self.onData))
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
