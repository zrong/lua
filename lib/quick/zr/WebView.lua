----------------------------------------
-- 对 ccexp.WebView 进行必要的封装
-- quick/zr/WebView.lua
--
-- 作者：zrong
-- 创建日期：2015-04-01
----------------------------------------

local isWebView = nil
if device.platform == 'android' or device.platform == 'ios' then
	if ccexp.WebView then
		isWebView = true
	end
else
	isWebView = false
end

local loadURL, loadFile, loadHTMLString, reload
if isWebView then
	loadURL = ccexp.WebView.loadURL
	loadFile = ccexp.WebView.loadFile
	loadHTMLString = ccexp.WebView.loadHTMLString
	reload = ccexp.WebView.reload
end

local WebView = class('WebView', function()
	if isWebView then
		return ccexp.WebView:create()
	end
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

function WebView:loadURL(url)
	if loadURL then
		loadURL(self, url)
	end
	return self
end

function WebView:loadFile(file)
	if loadFile then
		loadFile(self, file)
	end
	return self
end

function WebView:loadHTMLString(str)
	if loadHTMLString then
		loadHTMLString(self, str)
	end
	return self
end

function WebView:reload()
	if reload then
		reload(self)
	end
	return self
end

return WebView
