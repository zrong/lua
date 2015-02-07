-- Please set LUA_PATH to '../lib' in absolute path.
print(package.path)

require('zrong.init')
local Logger = zr.log.Logger
local PrintHandler = zr.log.PrintHandler
local log = zr.log.Logger.new(Logger.NOTSET, PrintHandler.new(print))

function d(fmt, ...)
    log:debug(fmt, ...)
end

local t = {1, 2, 3, 4}
local n = nil

local args = {nil,nil,nil}
print(#args)
for k,v in ipairs(args) do
    print(k,v)
end

-- print(string.format('abc %s', unpack({nil})))

d('abc %s %d -- %f', nil, 3)
d(t)

do return end

p = 'abc %s %d -- %f'
print(string.gsub(p, '%%%a', ''))

local function getArgs(...)
    print(...)
    local args = {...}
    print(#args)
    dump(args)
    for k,v in ipairs(args) do
        print('-', k,v)
    end
    print(unpack(args))
end

getArgs('a', 1, false, 3)
getArgs('a', 1, nil, 3)

for k,v in ipairs{'a', 1, nil, 3} do
    print('-', k,v)
end
