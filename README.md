A lua library by [zengrong.net][2]

# Dependences

Following libraries are dependented:

* [lpack][3]
* [BitOp][4]
* [LuaSocket][6]

# 1. For pure lua

For some reason in my server development, I moved some packages that my wrote in to **zr** package (They were in **cc** package ago).

# 2. For [quick-cocos2d-x][10]

In [quick-cocos2d-x][10], all of the dependences are included.

This library has already been merged into [quick-cocos2d-x framework][1].

In [quick-cocos2d-x framework][1], these library still use "cc" package name, but I won't update them.

# 3. Usage

You can import them by `lib.zrong.init`, it can import all of zrong's packages into a global table named `zr` , and also import some necessary global functions:

``` lua
require("lib.zrong.init")
```

or if you have had these necessary global functions, you can require them in your code selectively:

``` lua
utils = require("lib.zrong.zr.utils.init")
net = {}
net.SocketTCP = require("framework.cc.net.SocketTCP")
```

The necessary global functions are:

## In functions.lua

- class
- import
- iskindof

# 4. API list

- [zr.utils.Gettext](#Gettext)
- [zr.utils.ByteArray](#ByteArray)
- [zr.utils.ByteArrayVarint](#ByteArrayVarint)
- [zr.net.SocketTCP](#SocketTCP)
- [zr.log](#log)
	
<a name="Gettext">
## zr.utils.Gettext

A detailed example about [GNU gettext][9] and [Poedit][8] (in chinese): <http://zengrong.net/post/1986.htm>

Usage:

``` lua
local mo_data=assert(cc.utils.Gettext.loadMOFromFile("main.mo"))
print(mo_data["hello"])
-- 你好
print(mo_data["world"])
-- nil
```

Then you'll get a kind of gettext function:

``` lua
local gettext=assert(cc.utils.Gettext.gettextFromFile("main.mo"))
print(gettext("hello"))
-- 你好
print(gettext("world"))
-- world
```

With a slight modification this will be ready-to-use for the xgettext tool:

``` lua
_ = assert(cc.utils.Gettext.gettextFromFile("main.mo"))
print(_("hello"))
print(_("world"))
```

<a name="ByteArray">
## zr.utils.ByteArray

It can serialize bytes stream like ActionScript [flash.utils.ByteArray][5]

It depends on [lpack][3].

Usage:

``` lua
local ByteArray = zr.utils.ByteArray
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
```

Above codes will print like these:

![print result][51]

<a name="ByteArrayVarint">
## zr.utils.ByteArrayVarint

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
## zr.net.SocketTCP

The SocketTCP depends on [LuaSocket][6]

Usage:

``` lua
local SocketTCP = zr.net.SocketTCP
local ByteArray = zr.utils.ByteArray

socket = SocketTCP.new("127.0.0.1", 12001, false)
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
```

<a name="log">
## zr.log

`zr.log` package is very similar to python logging package.

``` lua
local logFilePath = 'log.txt'
local flogh = nil
local logFileHandler = io.open(logFilePath, 'w+b')

-- FileHandler can accept a file handler or a file name.
if logFileHandler then
    flogh = zr.log.FileHandler.new(logFileHandler, nil, true, true)
    flogh.filename = logFilePath
else
    flogh = zr.log.FileHandler.new(logFilePath, 'w+b', true, true)
end

local echo = print
-- A logger can accept one or more handler.
log = zr.log.Logger.new(zr.log.Logger.NOTSET, 
    zr.log.PrintHandler.new(echo), 
    flogh)
log:debug('You name?', 'zrong')
log:debug('My name is %s.', 'zrong')

--- Following contents will appear in console and log.txt.
[5.3278] You name?  zrong
[5.3279] My name is zrong.
```

[1]: https://github.com/chukong/quick-cocos2d-x/tree/develop/framework
[2]: http://zengrong.net
[3]: http://underpop.free.fr/l/lua/lpack/
[4]: http://bitop.luajit.org/index.html
[5]: http://help.adobe.com/en_US/FlashPlatform/reference/actionscript/3/flash/utils/ByteArray.html
[6]: http://w3.impa.br/~diego/software/luasocket/
[7]: https://developers.google.com/protocol-buffers/docs/encoding
[8]: http://www.poedit.net/
[9]: http://www.gnu.org/software/gettext/
[10]: https://github.com/chukong/quick-cocos2d-x
[51]: http://zengrong.net/wp-content/uploads/2013/11/luabytearray.png
