------------------------------------------
-- ResourceManager.lua
-- 负责管理项目中的所有资源
-- @author zrong
-- Creation: 2014-11-05
------------------------------------------

local RM = {}

local ac = cc.AnimationCache:getInstance()
local sfc = cc.SpriteFrameCache:getInstance()
local tc = cc.Director:getInstance():getTextureCache()
local FU = import('.FileUtil')

-- T_ 前缀代表 TYPE
RM.T_ANI    = 1    -- 动画定义文件
RM.T_SF     = 2    -- Sprite Frame，plist
RM.T_TEX    = 3    -- Texture，图片
RM.T_DB     = 4    -- DragonBones，骨骼动画

-- D_ 前缀代表 DIRECTORY
RM.D_ANI    = 'ani/'
RM.D_SF     = 'plst/'
RM.D_TEX    = 'pdir/'
RM.D_DB     = 'arm/'

RM._ani = {}
RM._db = {}

-- 将提供的可能不完整的 ani 定义名称文件名称转换成形如 ani/ani_def_*.lua 的路径
-- 若要获得绝对路径，可使用 FU.getFullPath()
function RM.normalizeFilePath(typ, name)
    local normalized = nil
    if typ == RM.D_ANI then
        if string.find(name, RM.D_ANI) == 1 then
            normalized =name
        elseif not string.find(name, 'ani_def_') then
            normalized = string.format('%sani_def_%s.lua', RM.D_ANI, name)
        elseif string.find(name, '.lua') ~= #name - 3 then
            normalized = string.format('%s%s.lua', RM.D_ANI, name)
        else
            normalized = string.format('%s%s', RM.D_ANI, name)
        end
    elseif typ == RM.T_SF then
        if string.find(name, RM.D_SF) == 1 then
            normalized = name
        else
            normalized = string.format('%s%s', RM.D_SF, name)
        end
    elseif typ == RM.T_TEX then
        if string.find(name, RM.D_TEX) == 1 then
            normalized = name
        else
            normalized = string.format('%s%s', RM.D_TEX, name)
        end
    elseif typ == RM.T_DB then
        normalized = RM._getDBFile(name)
    end
    return normalized
end

-- 从一个动画定义文件中载入动画配置。
-- aniDefName 动画定义文件的名称，不必包含路径和扩展名，
-- 甚至不需要包含 ani_def_ 前缀。
-- handler接受三个参数：
-- 1. 提供的aniDefName 
-- 2. 定义文件完整路径
-- 3. 定义文件的 lua  table.
function RM.addAniDef(aniDefName, handler)
    local defFile = FU.getFullPath(RM.normalizeFilePath(RM.T_ANI, aniDefName))
    local def = RM._ani[defFile]
    if def then 
        log:warning('ResourceManager.addAniDef %s(%s) 已经在缓存中了。', aniDefName, defFile)
        handler(aniDefName, defFile, def)
        return true 
    end
    def = RM._fillAniSFPath(defFile)
    RM._ani[defFile] = def
    local texNum = #def.spritesheets
    local curTex = 0
    -- 根据动画定义文件创建一个 Animation 实例并保存在 AnimationCache 中
    local fillAnimationCache = function()
        for __, ani in pairs(def.animations) do
            local frameStart = ani.range[1] 
            local frameNum = ani.range[2]-ani.range[1]+1
            local spriteFrames = display.newFrames(ani.frame_name, 
                frameStart, frameNum)
            animation = cc.Animation:createWithSpriteFrames(spriteFrames, 
                ani.delay_per_unit, ani.loops)
            ac:addAnimation(animation, ani.name)
        end
    end
    local localHandler = function()
        curTex = curTex + 1
        if curTex >= texNum then
            fillAnimationCache()
            handler(aniDefName, defFile, def)
        end
    end
    for __, ss in pairs(def.spritesheets) do
        RM.addSF(ss, localHandler)
    end
    return false
end

-- 将 ani 定义文件中的 plist 地址转换成绝对路径
function RM._fillAniSFPath(defFile)
    local def = dofile(defFile)
    for key, path in pairs(def.spritesheets) do
        def.spritesheets[key] = RM.normalizeFilePath(RM.T_ANI, path)
    end
    return def
end

-- 获取一个缓存中的 Animation 对象。
function RM.getAni(name)
    return ac:getAnimation(name)
end

-- 将一个动画配置文件中的所有动画从缓存中移除。
-- removeOthersCache 默认为 true，它会 同时从 SpriteFrameCache
-- 和 TextureCache 中移除对应的帧缓存和纹理缓存。
function RM.removeAniDef(aniDefName, removeOthersCache)
    local defFile = FU.getFullPath(RM.normalizeFilePath(RM.T_ANI, aniDefName))
    local def = RM._ani[defFile]
    if not def then 
        log:warning('ResourceManager.removeAniDef %s(%s) 不在缓存中，不能移除。', aniDefName, defFile)
        return false 
    end

    for __, ani in pairs(def.animations) do
        ac:removeAnimation(ani.name)
    end

    RM._ani[defFile] = nil
    if removeOthersCache or removeOthersCache == nil then
        for __, ss in pairs(def.spritesheets) do
            RM.removeSF(ss)
        end
    end
    return true
end

function RM.addAniDefList(list, asyncHandler)
    local amount = #list
    if amount == 0 then
        asyncHandler(0)
        return
    end
    local localHandler = function(aniDefName, aniDefFile, def)
        log:info("ResourceManager.addAniDefList.localHandler: %s", aniDefName)
        amount = amount - 1
        asyncHandler(amount)
    end
    for __, tex in pairs(list) do
        log:info("ResourceManager.addAniDefList tex:", tex)
        RM.addAniDef(tex, localHandler)
    end
end

function RM.removeAniDefList(list, removeOthersCache)
    for __, ani in pairs(list) do
        RM.removeAniDef(ani, removeOthersCache)
    end
end

function RM.addTex(name, handler)
    name = RM.normalizeFilePath(RM.T_TEX, name)
    if handler then
        tc:addImageAsync(name, function()
            handler(name)
        end)
        return false
    end
    tc:addImage(name)
    return true
end

function RM.removeTex(name)
    name = RM.normalizeFilePath(RM.T_TEX, name)
    tc:removeTextureForKey(name)
end

function RM.addTexList(list, asyncHandler)
    local localHandler = nil
    if asyncHandler then
        local amount = #list
        if amount == 0 then
            asyncHandler(0)
            return
        end
        localHandler = function(tex)
            log:info("ResourceManager.addTexList.localHandler ", tex)
            amount = amount - 1
            asyncHandler(amount)
        end
    end
    for __, tex in pairs(list) do
        RM.addTex(tex, localHandler)
    end
end

function RM.removeTexList(list)
    for __, tex in pairs(list) do
        RM.removeTex(tex)
    end
end

function RM.addSF(name, handler)
    name = RM.normalizeFilePath(RM.T_SF, name)
    display.addSpriteFrames(name..'.plist', name..'.png', handler)
    --sfc:addSpriteFrames(name..'.plist', cc.Texture2D:new())
end

function RM.removeSF(name)
    name = RM.normalizeFilePath(RM.T_SF, name)
    display.removeSpriteFramesWithFile(name..'.plist', name..'.png')
end

function RM.addSFList(list, asyncHandler)
    local localHandler = nil
    if asyncHandler then
        local amount = #list
        if amount == 0 then
            asyncHandler(0)
            return
        end
        localHandler = function(plist, texture)
            amount = amount - 1
            log:info("ResourceManager.addSFList.localHandler", plist, texture, amount)
            asyncHandler(amount)
        end
    end
    for __, ss in pairs(list) do
        RM.addSF(ss, localHandler)
    end
end

function RM.removeSFList(list)
    for __, ss in pairs(list) do
        RM.removeSF(ss)
    end
end

-- 将提供的可能不完整的 arm 定义名称文件名称转换成完整路径
function RM._getDBFile(armName)
    local armFile = nil
    if string.find(armName, RM.D_DB) == 1 then
        armFile = armName
    else
        armFile = string.format('%s%s', RM.D_DB, armName)
    end
    local fullPath = FU.getFullPath(armFile)
    -- 在windows操作系统上，无法得到一个目录的路径
    if fullPath == '' then
        local xml = '/skeleton.xml'
        armFile = armFile..xml
        fullPath = FU.getFullPath(armFile)
        fullPath = string.sub(fullPath, 1, #fullPath-#xml)
    end
    return fullPath
end

function RM.addDB(name, handler)
    local armFile = RM._getDBFile(name)
    local arm = RM._db[armFile]
    if arm then 
        log:warning('ResourceManager.addDB %s(%s) 已经在缓存中了。', name, armFile)
        handler(name, armFile, arm)
        return true 
    end
    arm = {
        path=armFile,
        armatureName=name,
        textureName=name,
        skeletonName=name,
    }
    dragonbones.loadData(arm)
    RM._db[armFile] = arm
    dump(RM._db)
    handler(name, armFile, arm)
    return true
end

function RM.removeDB(name)
    local armFile = RM._getDBFile(name)
    local arm = RM._db[armFile]
    if not arm then
        log:warning('ResourceManger.removeDB %s(%s) 不在缓存中，不能移除。', name, armFile)
        return false
    end
    dragonbones.unloadData({
        path=armFile,
        armatureName=name,
        textureName=name,
        skeletonName=name,
    })
    return true
end

function RM.getDB(name)
    local armFile = RM._getDBFile(name)
    local arm = RM._db[armFile]
    assert(arm, string.format('ResourceManager.getDB %s(%s) 还没有载入！请首先执行 addDB！', 
        name, armFile))
    return dragonbones.new({
        armatureName = arm.armatureName,
        skeletonName = arm.skeletonName,
        textureName = arm.textureName,
        animationName = arm.animationName,
        skinName = arm.skinName,
    })
end

function RM.addDBList(list, asyncHandler)
    local localHandler = nil
    if asyncHandler then
        local amount = #list
        localHandler = function(name, armFile, arm)
            amount = amount - 1
            log:info("ResourceManager.addDBList.localHandler", name, armFile, arm)
            asyncHandler(amount)
        end
    end
    for __, name in pairs(list) do
        RM.addDB(name, localHandler)
    end
end

function RM.removeDBList(list)
    for __, arm in pairs(list) do
        RM.removeDB(arm)
    end
end

function RM._checkResourceList(list)
    local amount = #list
    if amount > 0 then
       if amount%2 ~= 0 then
           log:error('ResourceManager.addResourceList: 必须同时提供列表类型！')
           return false
       else
           amounts = {}
           for i=1, amount, 2 do
               if  list[i] == RM.T_ANI then
                   amounts[RM.T_ANI] = #list[i+1]
               elseif list[i] == RM.T_SF then
                   amounts[RM.T_SF] = #list[i+1]
               elseif list[i] == RM.T_TEX then
                   amounts[RM.T_TEX] = #list[i+1]
               elseif list[i] == RM.T_DB then
                   amounts[RM.T_DB] = #list[i+1]
               else
                   log:error('ResourceManager.addResourceList: 提供的列表类型不正确！')
                   return false
               end
           end
           return true, amounts
       end
    end
    log:error('ResourceManager.addResourceList: 请提供要载入的列表！')
    return false
end

function RM.addResourceList(asyncHandler, ...)
    local list = {...}
    local checkSucc, amounts = RM._checkResourceList(list) 
    if checkSucc then

        local checkDone = function()
            return (amounts[RM.T_ANI] or 0)<=0 
                and (amounts[RM.T_SF] or 0)<=0 
                and (amounts[RM.T_TEX] or 0)<=0
                and (amounts[RM.T_DB] or 0)<=0
        end

        local updateAmount = function(amount, name)
            amounts[name] = amount
            asyncHandler(checkDone(), name, clone(amounts))
        end

        for i=1, #list, 2 do
            if list[i] == RM.T_ANI then
                RM.addAniDefList(list[i+1], function(amount)
                    updateAmount(amount, RM.T_ANI)
                end)
            elseif list[i] == RM.T_SF then
                RM.addSFList(list[i+1], function(amount)
                    updateAmount(amount, RM.T_SF)
                end)
            elseif list[i] == RM.T_TEX then
                RM.addTexList(list[i+1], function(amount)
                    updateAmount(amount, RM.T_TEX)
                end)
            elseif list[i] == RM.T_DB then
                RM.addDBList(list[i+1], function(amount)
                    updateAmount(amount, RM.T_DB)
                end)
            end
        end
    end
end

function RM.removeResourceList(...)
    local list = {...}
    if RM._checkResourceList(list) then
        local amount = #list
        for i=1, amount, 2 do
            if list[i] == RM.T_ANI then
                RM.removeAniDefList(list[i+1])
            elseif list[i] == RM.T_SF then
                RM.removeSFList(list[i+1])
            elseif list[i] == RM.T_TEX then
                RM.removeTexList(list[i+1])
            elseif list[i] == RM.T_DB then
                RM.removeDBList(list[i+1])
            end
        end
    end
end

function RM.getCachedTextureInfo(fmt)
    local info = tc:getCachedTextureInfo()
    if fmt then
        return string.format(fmt, info)
    end
    return info
end

function RM.printCachedTextureInfo(fmt)
    d(RM.getCachedTextureInfo(fmt))
end

return RM
