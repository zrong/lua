A lua library by [zengrong.net][2]

This library has been merged into [quick-cocos2d-x framework][1].

Following libraries are dependent on:

* [lpack][3] (already in quick-cocos2d-x)
* [BitOp][4] (already in quick-cocos2d-x)
* [LuaSocket][6] (already in quick-cocos2d-x)

## Usage

You can require them in your scripts, the library will **NOT** be imported in framework automatically:

	cc.utils = require("framework.cc.utils.init")
	cc.net = {}
	cc.net.SocketTCP = require("framework.cc.net.SocketTCP")

or import them in `cc.init` :
	
	-- init net library
	cc.net = import(".net.init") 
	-- init utils library
	cc.utils = import(".utils.init") 

* [cc.utils.Gettext](#Gettext)
* [cc.utils.ByteArray](#ByteArray)
* [cc.utils.ByteArrayVarint](#ByteArrayVarint)
* [cc.net.SocketTCP](#SocketTCP)
	
<a name="Gettext">
## cc.utils.Gettext

A detailed example about [GNU gettext][9] and [Poedit][8] (in chinese): <http://zengrong.net/post/1986.htm>

Usage:

	local mo_data=assert(cc.utils.Gettext.loadMOFromFile("main.mo"))
	print(mo_data["hello"])
	-- 你好
	print(mo_data["world"])
	-- nil

Then you'll get a kind of gettext function:

	local gettext=assert(cc.utils.Gettext.gettextFromFile("main.mo"))
	print(gettext("hello"))
	-- 你好
	print(gettext("world"))
	-- world

With a slight modification this will be ready-to-use for the xgettext tool:

	_ = assert(cc.utils.Gettext.gettextFromFile("main.mo"))
	print(_("hello"))
	print(_("world"))

<a name="ByteArray">
## cc.utils.ByteArray

It can serialize bytes stream like ActionScript [flash.utils.ByteArray][5]

It depends on [lpack][3].

Usage:

	-- use lpack to write a pack
	local __pack = string.pack("<bihP2", 0x59, 11, 1101, "", "中文")

	-- create a ByteArray
	local __ba = cc.utils.ByteArray.new()

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
	local __ba2 = cc.utils.ByteArray.new()

	-- you can write some values like actionscript
	-- also, you can use chaining calls.
	__ba2:writeByte(0x59)
		:writeInt(11)
		:writeShort(1101)
	-- write a empty string
	__ba2:writeStringUShort("")
	-- write some chinese string
	__ba2:writeStringUShort("中文")

	-- dump it
	print("ba2.toString(10):", __ba2:toString(10))

Above codes will print like these:

![print result][51]

<a name="ByteArrayVarint">
## cc.utils.ByteArrayVarint

ByteArrayVarint depends on [BitOP][4].

ByteArrayVarint implements [the Varint encoding in google protocol buffer][7].

See following:

>To understand your simple protocol buffer encoding, you first need to understand varints. Varints are a method of serializing integers using one or more bytes. Smaller numbers take a smaller number of bytes.
>
>Each byte in a varint, except the last byte, has the most significant bit (msb) set – this indicates that there are further bytes to come. The lower 7 bits of each byte are used to store the two's complement representation of the number in groups of 7 bits, least significant group first.

Your can use these methods(and all ByteArray methods) in ByteArrayVarint:

|Method Name|Description|
|----|----|
|ByteArrayVarint.readUVInt()|read a unsigned varint int|
|ByteArrayVarint.writeUVInt()|write a unsigned varint int|
|ByteArrayVarint.readVInt()|read varint int|
|ByteArrayVarint.writeVInt()|write varint int|
|ByteArrayVarint.readStringUVInt()|read a string preceding a unsigned varint int|
|ByteArrayVarint.writeStringUVInt()|write a string preceding a unsigned varint int|

On account of a [BitOP][4] limitation, ByteArrayVarint will read a unsigned int as a **minus**.

<a name="SocketTCP">
## cc.net.SocketTCP

The SocketTCP depends on [LuaSocket][6]

Usage:

		socket = cc.net.SocketTCP.new("192.168.18.22", 12001, false)
		socket:addEventListener(SocketTCP.EVENT_CONNECTED, onStatus)
		socket:addEventListener(SocketTCP.EVENT_CLOSE, onStatus)
		socket:addEventListener(SocketTCP.EVENT_CLOSED, onStatus)
		socket:addEventListener(SocketTCP.EVENT_CONNECT_FAILURE, onStatus)
		socket:addEventListener(SocketTCP.EVENT_DATA, onData)
		
		socket:send(ByteArray.new():writeByte(0x59):getPack())

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
[8]: http://www.poedit.net/
[9]: http://www.gnu.org/software/gettext/
[51]: http://zengrong.net/wp-content/uploads/2013/11/luabytearray.png
