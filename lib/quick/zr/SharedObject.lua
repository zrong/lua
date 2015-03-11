----------------------------------------
-- SharedObject
-- 提供对本地缓存的写入和读取功能
--
-- @author zrong
-- 创建日期：2015-01-23
-- 最后修改：2015-03-11
----------------------------------------
local SO = {}

local FU = import('.FileUtil')

-- 从 SO 中获取一个表
function SO.getSO(fname)
    if not SO.exists(fname) then
		local err = string.format('文件 %s 不存在！', fname or 'nil')
		log:error(err)
        return nil, err
    end

    local fun, err = loadfile(SO.getPath(fname))

	if not fun then
		local err = string.format('文件 %s 的格式错误：%s 。', fname or 'nil', err)
		log:error(err)
        SO.setEmptySO(fname)
		return nil, err
	end
	return fun()
end

-- 向 SO 中保存一个表
function SO.setSO(fname, atable)
    if not atable then
        SO.setEmptySO(fname)
        return
    end
    local at = dump(atable, 10, 'table')
    table.insert(at, 1, 'local data =' )
    table.insert(at, 'return data')

    SO.setString(fname, table.concat(at, '\n'))
end

-- 向 SO 中保存一个空表
function SO.setEmptySO(fname)
    SO.setString(fname, "local data = {}\nreturn data")
end

-- 获取 SO 信息（以字符串形式）
function SO.getString(fname)
    return FU.readFile(SO.getPath(fname))
end

-- 写入 SO 信息（以字符串形式）
function SO.setString(fname, content)
    if not content then content = "" end
    return FU.writeFile(SO.getPath(fname), content)
end

-- 判断 SO 是否存在
function SO.exists(fname)
    return FU.exists(SO.getPath(fname))
end

-- 获取 SO 的完整路径
function SO.getPath(fname)
    return FU.getWritablePath(fname)
end

return SO
