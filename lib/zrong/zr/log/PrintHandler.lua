--- 用于 print 信息的 LogHandler
-- @author zrong
-- Creation: 2014-10-31

local PrintHandler  = class('PrintHandler', import(".LogHandler"))

function PrintHandler:ctor(printfun, showtime)
    PrintHandler.super.ctor(self, showtime)
    self._printfun = printfun or print
end

function PrintHandler:emit(fmt, args)
    str = self:getString(fmt, args)
    self._printfun(str)
end

PrintHandler.printHandler = PrintHandler.new()

return PrintHandler
