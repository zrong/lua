A lua library by [zengrong.net][2]

This library depend on [quick-cocos2d-x framework][1] .

Other depedence:

* [lpack][3] (already in quick-cocos2d-x)
* [BitOp][4] (already in quick-cocos2d-x)
* [LuaSocket][6] (already in quick-cocos2d-x)

## utils.ByteArray

It can serialize bytes stream like ActionScript [flash.utils.ByteArray][5]

It depends on [lpack][3].

This is a sample:

	-- use lpack to write a pack
	local __pack = string.pack("<bihP2", 0x59, 11, 1101, "", "中文")

	-- create a ByteArray
	local __ba = ByteArray.new()

	-- ByteArray can write a lpack buffer directly
	__ba:writeBuf(__pack)

	-- remember, lua array started from 1
	__ba:setPos(1)

	-- now, you can read it like actionscript
	print("ba.len:", __ba:getLen())
	print("ba.readByte:", __ba:readByte())
	print("ba.readInt:", __ba:readInt())
	print("ba.readShort:", __ba:readShort())
	print("ba.readString:", __ba:readStringUShort())
	print("ba.available:", __ba:getAvailable())
	-- dump it
	print("ba.toString(16):", __ba:toString(16))

	-- create a ByteArray
	local __ba2 = ByteArray.new()

	-- you can write some values like actionscript
	__ba2:writeByte(0x59)
	__ba2:writeInt(11)
	__ba2:writeShort(1101)
	-- write a empty string
	__ba2:writeStringUShort("")
	__ba2:writeStringUShort("中文")

	-- dump it
	print("ba2.toString(10):", __ba2:toString(10))

Above codes will print like these:

![print result][51]

## utils.ByteArrayVarint

ByteArrayVarint implements [the Varint encoding in google protocol buffer][7].

See following:

>To understand your simple protocol buffer encoding, you first need to understand varints. Varints are a method of serializing integers using one or more bytes. Smaller numbers take a smaller number of bytes.
>
>Each byte in a varint, except the last byte, has the most significant bit (msb) set – this indicates that there are further bytes to come. The lower 7 bits of each byte are used to store the two's complement representation of the number in groups of 7 bits, least significant group first.

Your can use these methods in ByteArrayVarint:

|Method Name|Description|
|----|----|
|ByteArrayVarint.readUVInt()|read a unsigned varint int|
|ByteArrayVarint.writeUVInt()|write a unsigned varint int|
|ByteArrayVarint.readVInt()|read varint int|
|ByteArrayVarint.writeVInt()|write varint int|
|ByteArrayVarint.readStringUVInt()|read a string preceding a unsigned varint int|
|ByteArrayVarint.writeStringUVInt()|write a string preceding a unsigned varint int|

On account of a [BitOP][4] limitation, ByteArrayVarint will read a unsigned int as a **minus**.

## net.SocketTcp

The SocketTCP depends on [LuaSocket][6]

		socket = SocketTCP.new("192.168.18.22", 12001, false)
		socket:addEventListener(SocketTCP.EVENT_CONNECTED, onStatus)
		socket:addEventListener(SocketTCP.EVENT_CLOSE, onStatus)
		socket:addEventListener(SocketTCP.EVENT_CLOSED, onStatus)
		socket:addEventListener(SocketTCP.EVENT_CONNECT_FAILURE, onStatus)
		socket:addEventListener(SocketTCP.EVENT_DATA, onData)
		
		local __ba = ByteArray.new()
		__ba:writeByte(0x59)
		socket:send(__ba:getPack())

		function onStatus(__event)
			echoInfo("socket status: %s", __event.name)
		end

		function onData(__event)
			echoInfo("socket status: %s, data:%s", __event.name, ByteArray.toString(__event.data))
		end

[1]: https://github.com/dualface/quick-cocos2d-x/tree/develop/framework
[2]: http://zengrong.net
[3]: http://underpop.free.fr/l/lua/lpack/
[4]: http://bitop.luajit.org/index.html
[5]: http://help.adobe.com/en_US/FlashPlatform/reference/actionscript/3/flash/utils/ByteArray.html
[6]: http://w3.impa.br/~diego/software/luasocket/
[7]: https://developers.google.com/protocol-buffers/docs/encoding
[51]: http://zengrong.net/wp-content/uploads/2013/11/luabytearray.png
