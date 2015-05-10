local d = db
local DBCCArmatureNode = d.DBCCArmatureNode

-- 返回所有可用的动画名称的字符串列表。
function DBCCArmatureNode:getAnimationList()
    return self:getAnimation():getAnimationList()
end

function DBCCArmatureNode:hasAnimation(animationName)
    return self:getAnimation():hasAnimation(animatioinName)
end

function DBCCArmatureNode:getIsPlaying()
    return self:getAnimation():getIsPlaying()
end

function DBCCArmatureNode:getIsComplete()
    return self:getAnimation():getIsComplete()
end

-- 返回指定名称的 AnimationState 对象。
-- 注意只有当这个名称正在播放，才可能返回。否则返回 nil。
function DBCCArmatureNode:getState(name, layer)
    local layer = layer or 0
    return self:getAnimation():getState(name, layer)
end

-- 返回最后播放的 AnimationState 对象。
function DBCCArmatureNode:getLastAnimationState()
    return self:getAnimation():getLastAnimationState()
end

-- 开始播放某个动画，返回一个 AnimationState 对象。
-- 参数很多，参见 C++ 源码。
function DBCCArmatureNode:gotoAndPlay(...)
    return self:getAnimation():gotoAndPlay(...)
end

-- 停止播放某个动画，返回一个 AnimationState 对象。
function DBCCArmatureNode:gotoAndStop(...)
    return self:getAnimation():gotoAndStop(...)
end

-- 开始播放当前动画。
function DBCCArmatureNode:play()
    self:getAnimation():play()
    return self
end

-- 停止播放当前动画。
function DBCCArmatureNode:stop()
    self:getAnimation():stop()
    return self
end

-- 2015-05-08 zrong
-- getBoundingBox 已经导出，不必再处理
-- 为了计算相对位置，应该使用 getInnerBoundingBox
--[[ 获取包围盒，返回一个 Rect 对象。
function DBCCArmatureNode:getBoundingBox()
    return tolua.getcfunction(self, 'getBoundingBox')(self)
end
]]

-- 获取一个动画的 scale 值，单位秒。
function DBCCArmatureNode:getAnimationScale(name)
    local scale = tolua.getcfunction(self, 'getAnimationScale')(self, name)
    if scale < 0 then return nil end
    return scale
end

-- 获取一个动画的 duration 值，单位秒。
function DBCCArmatureNode:getAnimationDuration(name)
    local dur = tolua.getcfunction(self, 'getAnimationDuration')(self, name)
    if dur < 0 then return nil end
    return dur*0.001
end
