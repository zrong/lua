--[[
	SocketTcp lua
	@author zrong (zengrong.net)
	Creation: 2013-11-12
	from: http://cn.quick-x.com/?topic=quickkydsocketfzl
]]
local SOCKET_TICK_TIME = 0.1 			-- check socket data interval
local SOCKET_RECONNECT_TIME = 5			-- socket reconnect try interval
local SOCKET_CONNECT_FAIL_TIMEOUT = 3	-- socket failure timeout

local STATUS_CLOSED = "closed"
local STATUS_NOT_CONNECTED = "Socket is not connected"
local STATUS_TIMEOUT = "timeout"

local scheduler = require("framework.scheduler")
local socket = require "socket"

local SocketTcp = class("SocketTcp")

SocketTcp.EVENT_DATA = "SOCKET_TCP_DATA"
SocketTcp.EVENT_CLOSE = "SOCKET_TCP_CLOSE"
SocketTcp.EVENT_CLOSED = "SOCKET_TCP_CLOSED"
SocketTcp.EVENT_CONNECTED = "SOCKET_TCP_CONNECTED"
SocketTcp.EVENT_CONNECT_FAILURE = "SOCKET_TCP_CONNECT_FAILURE"

SocketTcp._VERSION = socket._VERSION
SocketTcp._DEBUG = socket._DEBUG

require("framework.api.EventProtocol").extend(SocketTcp)

function SocketTcp:ctor(__host, __port, __retryConnectWhenFailure)
    self.host = __host
    self.port = __port
	self.tickScheduler = nil			-- timer for data
	self.reconnectScheduler = nil		-- timer for reconnect
	self.connectTimeTickScheduler = nil	-- timer for connect timeout
	self.lastHeartbeatTime = os.time()
	self.name = 'SocketTcp'
	self.tcp = nil
	self.isRetryConnect = __retryConnectWhenFailure
	self.isConnected = false
end

function SocketTcp:setName( name )
	self.name = name
end

function SocketTcp:getTime()
	return socket.gettime()
end

function SocketTcp:connect(__host, __port, __retryConnectWhenFailure)
	if __host then self.host = __host end
	if __port then self.port = __port end
	if __retryConnectWhenFailure ~= nil then self.isRetryConnect = __retryConnectWhenFailure end
	assert(self.host or self.port, "Host and port are necessary!")
	--echoInfo("%s.connect(%s, %d)", self.name, self.host, self.port)
	self.tcp = socket.tcp()
	self.tcp:settimeout(0)

	self.tcp:connect(self.host, self.port)
	-- check whether connection is success
	-- the connection is failure if socket isn't connected after SOCKET_CONNECT_FAIL_TIMEOUT seconds
	local __connectTimeTick = function ()
		--echoInfo("%s.connectTimeTick", self.name)
		if self.isConnected then return end
		self.waitConnect = self.waitConnect or 0
		self.waitConnect = self.waitConnect + SOCKET_TICK_TIME
		if self.waitConnect >= SOCKET_CONNECT_FAIL_TIMEOUT then
			self.waitConnect = nil
	    	self:close()
			self:_connectFailure()
		end
		-- send a "1" to server per SOCKET_TICK_TIME seconds, if send success, then connection is success.
		-- bug, we can't use this way, because sever will cache this "1", and add it in front of next received data, so next protocol won't return any value.
		-- local __succ, __status = self.tcp:send(1)
		-- thus, I shall use "*l" to receive data
		local __body, __status, __partial = self.tcp:receive("*l")
		--print("receive:", __body, __status, string.len(__partial))
		if __status == STATUS_TIMEOUT then
			self:_onConnected()
		end
	end
	self.connectTimeTickScheduler = scheduler.scheduleGlobal(__connectTimeTick, SOCKET_TICK_TIME)
end

function SocketTcp:send(__data)
	assert(self.isConnected, self.name .. " is not connected.")
	self.tcp:send(__data)
end

function SocketTcp:close( ... )
	--echoInfo("%s.close", self.name)
	self.tcp:close();
	if self.connectTimeTickScheduler then scheduler.unscheduleGlobal(self.connectTimeTickScheduler) end
	if self.tickScheduler then scheduler.unscheduleGlobal(self.tickScheduler) end
	if self.connectTimeTickScheduler then scheduler.unscheduleGlobal(self.connectTimeTickScheduler) end
	self:dispatchEvent({name=SocketTcp.EVENT_CLOSE})
end

-- disconnect on user's own initiative.
function SocketTcp:disconnect()
	self:_disconnect()
	self.isRetryConnect = false -- initiative to disconnect, no reconnect.
end

--------------------
-- private
--------------------

function SocketTcp:_disconnect()
	self.isConnected = false
	self.tcp:shutdown()
	self:dispatchEvent({name=SocketTcp.EVENT_CLOSED})
end

function SocketTcp:_onDisconnect()
	--echoInfo("%s._onDisConnect", self.name);
	self.isConnected = false
	self:dispatchEvent({name=SocketTcp.EVENT_CLOSED})
	self:_reconnect();
end

-- connecte success, cancel the connection timerout timer
function SocketTcp:_onConnected()
	--echoInfo("%s._onConnectd", self.name)
	self.isConnected = true
	self:dispatchEvent({name=SocketTcp.EVENT_CONNECTED})
	if self.connectTimeTickScheduler then scheduler.unscheduleGlobal(self.connectTimeTickScheduler) end

	local __tick = function()
		while true do
			local __body, __status, __partial = self.tcp:receive("*l")	-- read the package body
			print("body:", __body, "__status:", __status, "__partial:", __partial)
    	    if __status == STATUS_CLOSED or __status == STATUS_NOT_CONNECTED then -- 如果读取失败 则跳出
		    	self:close()
		    	if self.isConnected then
		    		self:_onDisconnect()
		    	else 
		    		self:_connectFailure()
		    	end
		   		return
	    	end
		    if 	(__body and string.len(__body) == 0) or
				(__partial and string.len(__partial) == 0)
			then return end
			self:dispatchEvent({name=SocketTcp.EVENT_DATA, data=(__partial or __body), partial=__partial, body=__body})
		end
	end

	--开始读取TCP数据
	self.tickScheduler = scheduler.scheduleGlobal(__tick, SOCKET_TICK_TIME)
end

-- 连接失败
function SocketTcp:_connectFailure(status)
	--echoInfo("%s._connectFailure", self.name);
	self:dispatchEvent({name=SocketTcp.EVENT_CONNECT_FAILURE})
	self:_reconnect();
end

-- 重连 
-- 非主动性断开 SOCKET_RECONNECT_TIME 秒后重连
--主动性断开不重连
function SocketTcp:_reconnect()
	if not self.isRetryConnect then return end -- 不允许重连
	--echoInfo("%s._reconnect", self.name)
	if self.reconnectScheduler then scheduler.unscheduleGlobal(self.reconnectScheduler) end
	local __doReConnect = function ()
		self:connect()
	end
	self.reconnectScheduler = scheduler.performWithDelayGlobal(__doReConnect, SOCKET_RECONNECT_TIME)
end

return SocketTcp
