----------------------------------------
-- Common lua library by zrong.
--
-- Creation 2015-02-09
----------------------------------------

-- As same as cc.ui.init.makeUIControl_
-- but remove EventProtocol:exportMethods
function makeUIControlWithoutEvent(control)
    cc(control)
    control:addComponent("components.ui.LayoutProtocol"):exportMethods()

    control:setCascadeOpacityEnabled(true)
    control:setCascadeColorEnabled(true)
end

--- only export EventProtocol to view
function makeEventDispatcher(view)
    cc(view)
    view:addComponent("components.behavior.EventProtocol"):exportMethods()
    if view.addNodeEventListener then
        view:addNodeEventListener(cc.NODE_EVENT, function(event)
            if event.name == "cleanup" then
                view:removeAllEventListeners()
            end
        end)
    end
end

local _zr = zr or {}

_zr.FileUtil            = import('.FileUtil')
_zr.ResourceManager     = import('.ResourceManager')
_zr.ResourceCache       = import('.ResourceCache')
_zr.CaptureScreenUtil  	= import('.CaptureScreenUtil')
_zr.dragonbones         = import('.dragonbones')
_zr.UILabelButton       = import('.UILabelButton')
_zr.UILabelButtonGroup  = import('.UILabelButtonGroup')
_zr.UIProgressBar  		= import('.UIProgressBar')

import(".DBCCArmatureNodeEx")
import(".FilterSpriteEx")

return _zr
