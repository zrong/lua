local RestyAdapter = class('RestyAdapter', import('.SocketAdapter'))

function RestyAdapter:ctor(conf)
    RestyAdapter.super.ctor(self)
    local logger = require "resty.logger.socket"

    if not logger.initted() then
        local ok, err = logger.init(conf)
        if not ok then
            error("failed to initialize the RestyAdapter: ".. err)
            return
        end
    end
    self._logger = logger
end

function RestyAdapter:log(msg)
    local bytes, err = self._logger.log(msg)
    if err then
        return false, err
    end
    return true
end

function RestyAdapter:flush()
    self._logger:flush()
end

return RestyAdapter
