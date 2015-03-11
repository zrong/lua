--- A base class for log handler.
-- @author zrong
-- Creation: 2014-11-14

local LogHandler = class('LogHandler')

local function _isfmt(fmt)
    return type(fmt) == 'string' and string.find(fmt, "%%")
end

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
    local argsnum = #args
    if argsnum > 0 and _isfmt(fmt) then
        local fmtnum = select(2, string.gsub(fmt, '%%[%a%.]', ''))
        if fmtnum ~= argsnum then
            strlist[#strlist+1] = string.format('LogHandler WARNING -- [%s] Cannot get a nil value between arguments OR you give a bad amout of arguments.', fmt)
        else
			-- Avoid error in lua 5.2
			local succ, err = pcall(string.format, fmt, unpack(args))
			if succ then
				strlist[#strlist+1] = string.format(fmt, unpack(args))
			else
				strlist[#strlist+1] = string.format('LogHandler WARNING -- [%s] %s.', fmt, err)
			end
        end
    elseif _isfmt(fmt) then
        fmt = string.gsub(fmt, '%%%a', 'nil')
        strlist[#strlist+1] = fmt
    else
        strlist[#strlist+1] = tostring(fmt)
        for i=1, argsnum do
            strlist[#strlist+1] = tostring(args[i])
        end
    end
    return table.concat(strlist, '\t')
end

return LogHandler
