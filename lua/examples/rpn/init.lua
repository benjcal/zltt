local title = 'Lazy RPN Calculator\n\n'

local history = ''
local currentLine = ''

local function calculate(str)
	local op = string.sub(str, 0, 1)
	str = string.gsub(str, op, '', 1)

	local firstNum = string.match(str, "%d+")
	str = string.gsub(str, firstNum, '', 1)

	local secondNum = string.match(str, "%d+")
	str = string.gsub(str, secondNum, '', 1)

	if op == '+' then
		return tonumber(firstNum) + tonumber(secondNum)
	elseif op == '-' then
		return tonumber(firstNum) - tonumber(secondNum)
	elseif op == '*' then
		return tonumber(firstNum) * tonumber(secondNum)
	elseif op == '/' then
		return tonumber(firstNum) / tonumber(secondNum)
	elseif op == '%' then
		return tonumber(firstNum) % tonumber(secondNum)
	end
end

function handleInputEvent(key)
	-- ENTER
	if key == 13 then
		local res = calculate(currentLine)
		history = history .. currentLine .. '\n' ..  res .. '\n\n'
		currentLine = ''

	-- ESC
	elseif key == 27 then
		print('clear current line')

	-- BACKSPACE
	elseif key == 8 then
		currentLine = string.sub(currentLine, 0, string.len(currentLine)-1)
	else
		currentLine = currentLine .. string.char(key)
	end

	putMainText(title .. history .. currentLine)
end

-- initial render
putMainText(title)
