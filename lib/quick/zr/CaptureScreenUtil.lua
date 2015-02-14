------------------------------------------
-- CaptureScreenUtil.lua
-- 负责管理截图
-- @author zrong
-- Creation 2015-02-05
------------------------------------------

local CSU = {}
local _cache = {}

local FU = import('.FileUtil')
local RC = import('.ResourceCache')

function _retain(filename, filepath, scenename, sp)
	log:info('CaptureScreenUtil._retain filename: %s, filepath: %s, scenename: %s, sp: %s', filename, filepath, scenename, sp)
	--_release(filename)

	-- 保持 Sprite 避免由于没有加到舞台中而被回收
	sp:retain()
	local c = {}
	c.sprite = sp
	c.scenename = scenename
	c.filepath = filepath
	c.filename = filename
	_cache[filename] = c
end

function _release(filename)
    local c = _cache[filename]
    if c and c.sprite and c.sprite.getReferenceCount then
        log:info('CaptureScreenUtil._release filename: %s, sprite: %s', 
			filename, tolua.type(c.sprite))
		log:info('before release getReferenceCount %d', c.sprite:getReferenceCount())
		c.sprite:release()
		log:info('after release c.sprite %s', c.sprite)
		log:info('after release c.sprite.getReferenceCount %s', c.sprite.getReferenceCount)
		log:info('after release getReferenceCount %d', c.sprite:getReferenceCount())
    end
	return c
end

-- 截取当前屏幕，保存到 filename
-- @param asyncHandler 回调函数中包含两个参数 asyncHandler(filename, sprite)
-- @param filename 保存的文件名称
-- @param scenename 若提供场景名称，则会建立一个 Sprite 实例，
-- 	在 asyncHandler 回调的时候通过第二个参数返回，
-- 	且会对此 Sprite 实例进行 retain 操作，
-- 	对此截屏用完后必须执行 clear 否则会引起内存泄露。
function CSU.capture(asyncHandler, filename, scenename, filter)
    display.captureScreen(function(succ, filepath)
		-- log:info('CSU.captureScreen handler', succ, filepath)
		if succ then
			if scenename then
				local sp = nil
				if filter then
					sp = RC.newFilteredSprite(scenename, 
						filepath, filter.filters, filter.params)
				else
					sp = RC.newSprite(scenename, filepath)
				end
				_retain(filename, filepath, scenename, sp)
				asyncHandler(filepath, sp)
			else
				asyncHandler(filepath, nil)
			end
		else
			asyncHandler(nil, nil)
			log:error('CaptureScreenUtil.capture 截屏失败！')
		end
	end, filename)
end

function CSU.get(filename)
    local c = _cache[filename]
	if c then
		return c.sprite, c.filename, c.filepath, c.scenename
	end
	return nil, nil, nil, nil
end

function CSU.clear(filename)
	local c = _release(filename)
	RC.removePdir(c.scenename, c.filepath)
	_cache[filename] = nil
end

return CSU
