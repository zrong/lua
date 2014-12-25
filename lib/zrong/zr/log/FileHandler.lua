
--- 用于将 log 信息存入文件中的 LogHandler
-- @author zrong
-- Creation: 2014-11-14

local FileHandler = class('LogHandler', import(".LogHandler"))

-- file 提供一个用于写入的文件，必须使用绝对路径。
-- file 也可以是一个已经正确打开的文件。
-- mode 文件的打开模式，仅当传入文件名的时候有用。
-- autoflush 是否自动刷新，默认为 false。
-- showtime 是否显示 log 时间，默认为 false。
function FileHandler:ctor(file, mode, autoflush, showtime)
    FileHandler.super.ctor(self, showtime)
    mode = mode or 'w+b'
    if type(file) == 'string' then
        self.filename = filename
        self._file = io.open(file, mode)
    else
        self._file = file
    end
    self._autoflush = autoflush
end

function FileHandler:emit(fmt, args)
    str = self:getString(fmt, args)
    self._file:write(str..'\n')
    if self._autoflush then
        self:flush()
    end
end

function FileHandler:flush()
    self._file:flush()
end

return FileHandler
