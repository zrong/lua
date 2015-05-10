--- DragonBones
-- @author zrong(zengrong.net)
-- Creation 2014-07-24
-- Modification 2015-05-08

local dragonbones = {}

dragonbones.EventType = 
{
    Z_ORDER_UPDATED = 0,
    ANIMATION_FRAME_EVENT = 1,
    BONE_FRAME_EVENT = 2,
    SOUND = 3,
    FADE_IN = 4, 
    FADE_OUT = 5, 
    START = 6, 
    COMPLETE = 7, 
    LOOP_COMPLETE = 8, 
    FADE_IN_COMPLETE = 9, 
    FADE_OUT_COMPLETE = 10,
    _ERROR = 11,
}

local dbFactory = db.DBCCFactory:getInstance()

--- 创建一个 DBCCArmatureNode 对象
-- @author zrong(zengrong.net)
-- Creation：2014-10-28
-- @param params
-- {
--      skeleton="dragon/skeleton.xml",
--      texture="dragon/texture.xml",
--      armatureName="Dragon",
--      animationName="walk",
--      skeletonName="Dragon",
--      skinName=""
--  }
--  下面的参数将在 dragon 文件夹中搜索 skeleton.xml 和 texture.xml
-- {
--      path="dragon",
--      armatureName="Dragon",
--      animationName="",
--      skeletonName="Dragon",
--  }
--  下面的参数直接在缓存中查找必要的骨骼动画数据（数据必须已经载入）
-- {
--      armatureName="Dragon",
--      animationName="walk",
--      skeletonName="Dragon",
--      skinName = ""
--  }
function dragonbones.new(params)
    print('dragonbones.new params')
    dump(params)
    args = dragonbones._initParam(params)
    print('dragonbones.new args')
    dump(args)
    dragonbones.loadData(args)
    return dbFactory:buildArmatureNode(args.armatureName, args.skinName, 
        args.animationName, args.skeletonName, args.textureName)
end

function dragonbones.setFactory(factory)
	dbFactory = factory
end

function dragonbones._initParam(params)
    if not params.animationName then
        params.animationName = ''
    end
    if not params.skeletonName then
        params.skeletonName = params.armatureName
    end
    if not params.textureName then
        params.textureName = params.skeletonName
    end
    if not params.skinName then
        params.skinName = ''
    end
    assert(params.armatureName and params.skeletonName, 
        "armatureName and skeletonName are necessary!")
    return params
end

function dragonbones.loadData(params, initParam)
    local args = params
    if initParam then
        args = dragonbones._initParam(params)
    end
    if args.path then
        dbFactory:loadDataByDir(args.path, args.skeletonName, args.textureName)
    elseif args.skeleton and args.texture then
        dbFactory:loadData(args.skeleton, args.texture, 
            args.skeletonName, args.textureName)
    end
end

function dragonbones.unloadData(params, initParam)
    local args = params
    if initParam then
        args = dragonbones._initParam(params)
    end
    dbFactory:unloadData(args.skeletonName, args.textureName)
end

return dragonbones
