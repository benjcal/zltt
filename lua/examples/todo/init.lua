-- flags
local addingTodoItem = false

-- initial todo table
local todoItems = {
	{name = 'write SDL TUI', done = false},
	{name = 'make some cool examples', done = false},
	{name = '...', done = false},
	{name = 'profit', done = false},
}

local newTodoItem = ''

-- convert the data structure into a string and print to main buffer
local function renderTodoItems()
	local buffer = 'Cool TODO List\n\n'

	for i,item in ipairs(todoItems) do
		-- calculate a letter to address the todo item by
		local letter = string.char(i+96)

		-- render the string fo(un)done
		local done = item.done and '[*]' or '[ ]'

		local text = string.format(' %s - %s %s\n', letter, done, item.name)

		buffer = buffer .. text
	end

	putMainText(buffer)
end


local function printInstructions()
	putSubText('press A to add item, press item letter to (un)mark')
end

local function keyToIndex(key)
	return key - 96
end

local newItemPrefix = 'Add New Item:'
local function newTodoItemHandleKey(key)
	-- initial run
	if key == nil then
		putSubText(string.format("%s %s", newItemPrefix, newTodoItem))

	-- ENTER save new item on enter and re-render
	elseif key == 13 then
		table.insert(todoItems, {name = newTodoItem, done = false})
		addingTodoItem = false
		renderTodoItems()
		printInstructions()
		return

	-- ESC discard
	elseif key == 27 then
		newTodoItem = ''
		addingTodoItem = false
		printInstructions()
		return

	-- BACKSPACE
	elseif key == 8 then
		newTodoItem = string.sub(newTodoItem, 0, string.len(newTodoItem)-1)
		putSubText(string.format("%s %s", newItemPrefix, newTodoItem))

	-- type
	else
		newTodoItem = newTodoItem .. string.char(key)
		putSubText(string.format("%s %s", newItemPrefix, newTodoItem))
	end

end

-- this is a callback function that is called on keydown SDL events
function handleInputEvent(key)
	-- check flags that might affect behaviour
	if addingTodoItem then
		newTodoItemHandleKey(key)
		return
	end

	-- press A to enter new item
	if key == string.byte('A') then
		addingTodoItem = true
		newTodoItemHandleKey(nil)
		return
	end


	if key == string.byte('P') then
		putSubText('Printing...')
	end

	local index = keyToIndex(key)

	local ok = todoItems[index]
	if ok then
		todoItems[index].done = not todoItems[index].done
	end

	renderTodoItems()

end


-- initial render
renderTodoItems()
printInstructions()
