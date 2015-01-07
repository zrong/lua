--- A lua log implement.
-- @author zrong(zengrong.net)
-- Creation: 2014-10-31

local Logger = class('Logger')

Logger.CRITICAL = 50
Logger.ERROR = 40
Logger.WARNING = 30
Logger.INFO = 20
Logger.DEBUG = 10
Logger.NOTSET = 0

function Logger:ctor(level, ...)
    self:setLevel(level or Logger.NOTSET)
    self._handlers = {...}
end

function Logger:setLevel(level)
    self._level = level
end

function Logger:getLevel(level)
    return self._level
end

function Logger:addHandler(logHandler)
    self._handlers[#self._handlers+1] = logHandler
end

function Logger:clearHandler()
    self._handlers = {}
end

function Logger:flush()
    for __, logHandler in pairs(self._handlers) do
        logHandler:flush()
    end
end

function Logger:log(level, fmt, ...)
    if level < self._level then return end
    args = {...}
    for __, logHandler in pairs(self._handlers) do
        logHandler:emit(level, fmt, args)
    end
end

function Logger:debug(fmt, ...)
    self:log(Logger.DEBUG, fmt, ...)
end

function Logger:info(fmt, ...)
    self:log(Logger.INFO, fmt, ...)
end

function Logger:warning(fmt, ...)
    self:log(Logger.WARNING, fmt, ...)
end

function Logger:error(fmt, ...)
    self:log(Logger.ERROR, fmt, ...)
end

function Logger:critical(fmt, ...)
    self:log(Logger.CRITICAL, fmt, ...)
end

return Logger
