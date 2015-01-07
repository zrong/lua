--- A base class for log handler.
-- @author zrong
-- Creation: 2014-11-14

local LogHandler = class('LogHandler')

-- @starttime 
-- @gettime A function, return current time.
function LogHandler:ctor(starttime, gettime)
    self._gettime = nil
    self._starttime = nil
    if starttime then
        self._gettime = gettime or os.time
        self._starttime = (starttime == 0 and self._gettime()) or starttime
    end
end

function LogHandler:emit(level, fmt, args)
end

function LogHandler:flush()
end

function LogHandler:getString(level, fmt, args)
    local strlist = {}
    if self._starttime then
        strlist[#strlist+1] = string.format('[%.4f]', self._gettime()-self._starttime)
    end
    if #args > 0 and 
        type(fmt) == 'string' and
        string.find(fmt, "%%") then
        strlist[#strlist+1] = string.format(fmt, unpack(args))
    else
        strlist[#strlist+1] = fmt
        for i=1, #args do
            strlist[#strlist+1] = tostring(args[i])
        end
    end
    return table.concat(strlist, '\t')
end

return LogHandler
