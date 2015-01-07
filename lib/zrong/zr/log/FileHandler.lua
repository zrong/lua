--- A LogHandler for save log to a file.
-- @author zrong
-- Creation: 2014-11-14

local FileHandler = class('LogHandler', import(".LogHandler"))

-- @file A file to write info or a opened file handler. It must be a absolute path.
-- @mode A mode for opened file, it is only available when file is a file name.
-- @autoflush Default value is false。
-- @starttime A timestamp that start application. Default value is nil (Do not show time).
-- @gettime A function, return current time.
function FileHandler:ctor(file, mode, autoflush, starttime, gettime)
    FileHandler.super.ctor(self, starttime, gettime)
    mode = mode or 'w+b'
    if type(file) == 'string' then
        self.filename = filename
        self._file = io.open(file, mode)
    else
        self._file = file
    end
    self._autoflush = autoflush
end

function FileHandler:emit(level, fmt, args)
    str = self:getString(level, fmt, args)
    self._file:write(str..'\n')
    if self._autoflush then
        self:flush()
    end
end

function FileHandler:flush()
    self._file:flush()
end

return FileHandler
