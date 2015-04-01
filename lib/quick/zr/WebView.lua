----------------------------------------
-- 对 ccexp.WebView 进行必要的封装
-- quick/zr/WebView.lua
--
-- 作者：zrong
-- 创建日期：2015-04-01
----------------------------------------

local isWebView = ccexp.WebView and true or false

local WebView = class('WebView', function()
	if device.platform == 'android' or device.platform == 'ios' then
		if isWebView then
			return ccexp.WebView:create()
		end
	end
	isWebView = false
	return display.newNode()
end)

function WebView:ctor()
	d('WebView:ctor(), isWebView:', tostring(isWebView))
	if isWebView then
		self:setScalesPageToFit(true)
	end
end

-- 返回自己是否是 WebView
function WebView:isWebView()
	return isWebView
end

local loadURL = nil
if isWebView then
	loadURL = ccexp.WebView.loadURL
end
function WebView:loadURL(url)
	if loadURL then
		loadURL(self, url)
	end
end

return WebView
