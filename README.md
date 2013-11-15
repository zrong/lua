A lua library by [zengrong.net][2]

This library depend on [quick-cocos2d-x framework][1] .

Other depedence:

* [lpack][3] (already in quick-cocos2d-x)
* [BitOp][4] (already in quick-cocos2d-x)

## utils.ByteArray

It can serialize bytes stream like ActionScript [flash.utils.ByteArray][5]
It depends on [lpack][3].

This is a sample:

	local __pack = string.pack("<b3ihP", 0x59, 0x7a, 0, 11, 1101, "中文")
	local __ba = ByteArray.new()
	__ba:writeBuf(__pack)
	__ba:setPos(1)
	print("ba.len:", __ba:getLen())
	print("ba.readb:", __ba:readByte())
	print("ba.readb:", __ba:readByte())
	print("ba.readb:", __ba:readByte())
	print("ba.readInt:", __ba:readInt())
	print("ba.readShort:", __ba:readShort())
	print("ba.readString:", __ba:readStringUShort())
	print("ba.available:", __ba:getAvailable())
	print("ba.toString(16):", __ba:toString(16))

	local __ba2 = ByteArray.new()
	__ba2:writeByte(0x59)
	__ba2:writeByte(0x7a)
	__ba2:writeByte(0)
	__ba2:writeInt(11)
	__ba2:writeShort(1101)
	__ba2:writeStringUShort("中文")
	print("ba2.toString(16):", __ba2:toString(16))

Above codes will print like these:

![print result][51]

## net.SocketTcp

to be continued

[1]: https://github.com/dualface/quick-cocos2d-x/tree/develop/framework
[2]: http://zengrong.net
[3]: http://underpop.free.fr/l/lua/lpack/
[4]: http://bitop.luajit.org/index.html
[5]: http://help.adobe.com/en_US/FlashPlatform/reference/actionscript/3/flash/utils/ByteArray.html
[51]: http://zengrong.net/wp-content/uploads/2013/11/luabytearray.png
