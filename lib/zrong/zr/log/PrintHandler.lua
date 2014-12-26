--- A handler for print infomation.
-- @author zrong
-- Creation: 2014-10-31

local PrintHandler  = class('PrintHandler', import(".LogHandler"))

function PrintHandler:ctor(printfun, starttime)
    PrintHandler.super.ctor(self, starttime)
    self._printfun = printfun or print
end

function PrintHandler:emit(fmt, args)
    str = self:getString(fmt, args)
    self._printfun(str)
end

PrintHandler.printHandler = PrintHandler.new()

return PrintHandler
