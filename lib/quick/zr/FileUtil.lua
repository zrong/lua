-- FileUtil
-- 对C++提供的 FileUtils 进行封装，项目中必须统一使用 lua 版本。
-- @author zrong
--  创建日期：2014-11-14

local FU = {}

local fu = cc.FileUtils:getInstance()

FU.WRITEABLE_PATH = fu:getWritablePath()

function FU.isDir(filename)
    -- char 47 = '/'
    return string.byte(filename, -1) == 47
end

function FU.isAbsolutePath(filename)
    return fu:isAbsolutePath(filename)
end

function FU.getWritablePath(filename)
    if filename then
        return FU.WRITEABLE_PATH .. filename
    end
    return FU.WRITEABLE_PATH
end

-- 获取一个相对路径文件的绝对路径。
-- 这个文件必须相对于 res 文件夹。
-- 若不提供值，则返回 res  文件夹的绝对路径。
function FU.getFullPath(filename)
    if filename then
        return fu:fullPathForFilename(filename)
    end
    local resinfo = 'resinfo.lua'
    filename = fu:fullPathForFilename(resinfo)
    return string.sub(filename, 1, #filename - #resinfo)
end

-- 读取文件内容
function FU.readFile(filename)
    --fullpath = RM.getFullPath(filename)
    local data = cc.HelperFunc:getFileData(filename)
    return data
end

-- 写入文件内容
function FU.writeFile(filename, content, mode)
    return io.writefile(filename, content, mode)
end

-- filaname 可以是相对或绝对路径，目录必须以 / 结尾。
function FU.exists(filename)
    if FU.isDir(filename) then
        return fu:isDirectoryExist(filename)
    end
    return fu:isFileExist(filename)
end

-- dirname 必须是绝对路径。目录必须以 / 结尾。
function FU.mkdir(dirname)
    return fu:createDirectory(dirname)
end

-- filename 必须是绝对路径。目录必须以 / 结尾。
function FU.rm(filename)
    if FU.isDir(filename) then
        fu:removeDirectory(filename)
    end
    return fu:removeFile(filename)
end

-- parent 是父文件夹路径，必须是绝对路径。
function FU.rename(parent, old, new)
    return fu:renameFile(parent, old, new)
end

function FU.getFileSize(filename)
    return fu:getFileSize(filename)
end

return FU
