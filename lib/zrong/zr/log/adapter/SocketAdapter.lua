local SocketAdapter = class('SocketAdapter')

function SocketAdapter:ctor()
    
end

function SocketAdapter:log(msg)
    return true
end

function SocketAdapter:flush()
end

return SocketAdapter
