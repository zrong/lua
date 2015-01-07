--- A handler for print infomation.
-- @author zrong
-- Creation: 2014-10-31

local PrintHandler  = class('PrintHandler', import(".LogHandler"))

function PrintHandler:ctor(printfun, starttime, gettime)
    PrintHandler.super.ctor(self, starttime, gettime)
    self._printfun = printfun or print
end

function PrintHandler:emit(level, fmt, args)
    str = self:getString(level, fmt, args)
    self._printfun(str)
end

PrintHandler.printHandler = PrintHandler.new()

return PrintHandler
