--[[--
@author zrong
@creation 2014-12-25

zrong framework initialization
]]

print("===========================================================")
print("              LOAD ZRONG FRAMEWORK")

local CURRENT_MODULE_NAME = ...

zr = zr or {}
zr.PACKAGE_NAME = string.sub(CURRENT_MODULE_NAME, 1, -6)

require(zr.PACKAGE_NAME .. ".debug")
require(zr.PACKAGE_NAME .. ".functions")
require(zr.PACKAGE_NAME .. ".zr.init")
print("                    DONE")
print("===========================================================")
