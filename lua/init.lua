setMainBGColor(40, 44, 52)
setSubBGColor(44, 50, 61)
setMainTextColor(170, 178, 191)
setSubTextColor(170, 178, 191)

local mainTextBuffer = [[
Hello There from lua/init.lua

use putMainText(text) to print text to this area
use handleInputEvent(key) to react to keydown events
]]

function handleInputEvent(key)
	mainTextBuffer = mainTextBuffer .. string.char(key)
	putMainText(mainTextBuffer)
end

putMainText(mainTextBuffer)
putSubText('use putSubText(text) to print text in this area')
