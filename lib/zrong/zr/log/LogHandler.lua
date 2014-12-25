
--- 用于将 log 信息存入文件中的 LogHandler
-- @author zrong
-- Creation: 2014-11-14

local LogHandler = class('LogHandler')

function LogHandler:ctor(showtime)
    self._showtime = showtime
end

function LogHandler:emit(fmt, args)
end

function LogHandler:flush()
end

function LogHandler:getString(fmt, args)
    local strlist = {}
    if self._showtime then
        strlist[#strlist+1] = string.format('[%.4f]', os.clock())
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
    return table.concat(strlist, ' ')
end

return LogHandler
