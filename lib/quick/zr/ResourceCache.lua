------------------------------------------
-- RC.lua
-- 在 ResourceManager 的基础上提供基于场景的缓存支持
-- Author allen
-- Rewrite 2015-01-30 zrong
------------------------------------------

local RC = {}

RM = import('.ResourceManager')

local _caches = {
    -- ANI 的缓存
    [RM.T_ANI] = {},
    -- Spritesheet 的缓存
    [RM.T_SF] = {},
    -- 单张图片的缓存
    [RM.T_TEX] = {},
}

-- 记录要载入的资源到缓存中，通过比较返回实际需要载入的文件列表
-- @param type 资源类型，见 RM.T_*
-- @param sceneName 名称
-- @param list 要载入的列表
local function _record(typ,  list, sceneName)
    local cache = _caches[typ]
    assert(cache, string.format('Type [%d] is not in _caches!', typ))
    local waitLoaded = {}
    for _, item in pairs(list) do
        -- 将路径标准化，方便比对唯一值
        item = RM.normalizeFilePath(typ, item)
        if cache[item] then
           caches[item][sceneName] = true
        else
            waitLoaded[#waitLoaded+1] = item

            cache[item] = {}
            cache[item][sceneName] = true
        end
    end
    return waitLoaded
end

local function _remove(typ,  list, sceneName, force)
    local cache = _caches[typ]
    assert(cache, string.format('Type [%d] is not in _caches!', typ))
    local waitRemoved = {}

    for _, item in pairs(list) do
        -- 将路径标准化，方便比对唯一值
        item = RM.normalizeFilePath(typ, item)
        if cache[item] then
            cache[item][sceneName] = nil
            if table.nums(cache[item]) == 0 then
                waitRemoved[#waitRemoved+1] = item
                cache[item] = nil
            end
        elseif force then
            waitRemoved[#waitRemoved+1] = item
        else
            log:warning("ResourceCache._remove %s 不在缓存中！", item)
        end
    end
    return waitRemoved
end

local function _removePdir(cache, pdirPath, sceneName)
    pdirPath = RM.normalizeFilePath(RM.T_TEX, pdirPath)
    local afileCache = cache[pdirPath]
    if not afileCache then return end
    afileCache[sceneName] = nil
    if table.nums(afileCache) == 0 then
        log:info('ResourceCache.removePdir:', pdirPath)
        RM.removeTex(pdirPath)
        cache[pdirPath] = nil
    end
end

-- 判断内容是否在缓存中
function RC.inCache(typ, path, sceneName)
    path = RM.normalizeFilePath(typ, path)
    local cache = _caches[typ]
    if not cache then return false end
    if path then
        local afileCache = cache[path]
        if afileCache then
            if sceneName then
                return afileCache[sceneName]
            end
            return true
        end
        return false
    end
    return true
end

-- 重新封装 display.newSprite ，提供将单张图片按场景缓存的功能。
-- 这个封装不支持 SpriteFrameCache 中的碎图，其它参数完全相同。
function RC.newSprite(sceneName, filename, x, y, params)
    assert(string.byte(filename) ~= 35, 
        'RC.newSprite, SpriteFrame is not supported!')
    local fname = RM.normalizeFilePath(RM.T_TEX, filename)
    RC.recordPdir(sceneName, fname)
    return display.newSprite(fname, x, y, params)
end

-- 重新封装 display.newScale9Sprite ，提供将 Scale9 单张图片按场景缓存的功能。
-- 这个封装不支持 SpriteFrameCache 中的碎图，其它参数完全相同。
function RC.newScale9Sprite(sceneName, filename, x, y, size, capInsets)
    assert(string.byte(filename) ~= 35, 
        'RC.newSprite, SpriteFrame is not supported!')
    local fname = RM.normalizeFilePath(RM.T_TEX, filename)
    RC.recordPdir(sceneName, fname)
    return display.newScale9Sprite(fname, x, y, size, capInsets)
end

function RC.newFilteredSprite(sceneName, filename, filters, params)
    assert(string.byte(filename) ~= 35, 
        'RC.newSprite, SpriteFrame is not supported!')
    local fname = RM.normalizeFilePath(RM.T_TEX, filename)
    RC.recordPdir(sceneName, fname)
    return display.newFilteredSprite(fname, x, y, filters, params)
end

-- 重新封装 display.newBatchNode ，提供将图片按场景缓存的功能。
function RC.newBatchNode(sceneName, filename, capacity)
    local fname = RM.normalizeFilePath(RM.T_SF, filename)
    RC.recordPdir(sceneName, fname)
    return display.newBatchNode(fname, capacity)
end

-- 重新封装 display.newTilesSprite ，提供将图片按场景缓存的功能。
function RC.newTilesSprite(sceneName, filename, rect)
    local fname = RM.normalizeFilePath(RM.T_TEX, filename)
    RC.recordPdir(sceneName, fname)
    return display.newTilesSprite(fname, rect)
end

-- 将指定的单张图片按场景记录在缓存中
function RC.recordPdir(sceneName, pdirPath)
    local cache = _caches[RM.T_TEX]
    pdirPath = RM.normalizeFilePath(RM.T_TEX, pdirPath)
    if cache[pdirPath]  then
        cache[pdirPath][sceneName] = true
    else
        cache[pdirPath] = {}
        cache[pdirPath][sceneName] = true
    end
end

-- 将按场景记录在缓存中的指定图片移除
function RC.removePdir(sceneName, pdirPath)
    local cache = _caches[RM.T_TEX]
    if pdirPath then
        _removePdir(cache,  pdirPath, sceneName)
    else
        for k, v in pairs(cache) do
            _removePdir(cache, k, sceneName)
        end
    end
end

-- 与 ResourceManager.addAniDefList 功能相同，但基于 Scene Name 进行缓存
function RC.addAniDefList(sceneName, list, asyncHandler)
   if #list == 0 and asyncHandler then
       asyncHandler(0)
       return
   end
   RM.addAniDefList(list, asyncHandler)
end

function RC.removeAniDefList(sceneName, list, force)
    local list = _remove(RM.T_ANI,  list, sceneName, force)
    if #list > 0 then
        RM.removeAniDefList(list, true)
    end
end

-- 与 ResourceManager.addSFList 功能相同，但基于 Scene Name 进行缓存
function RC.addSFList(sceneName, list, asyncHandler)
   local list = _record(RM.T_SF,  list, sceneName) 
   if #list == 0 then
       if asyncHandler then
           asyncHandler(0)
       end
   else
       RM.addSFList(list, asyncHandler)
   end
end

function RC.removeSFList(sceneName, list, force)
    local list = _remove(RM.T_SF,  list, sceneName, force)
    if #list > 0 then
        RM.removeSFList(list)
    end
end

return RC
