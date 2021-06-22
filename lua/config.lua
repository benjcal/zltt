
font_face = "stuff"
font_size = 16

buffer = ""

puttext('hello there!! <BFFFFFF> asdfkjhdf')

function event(key)
	print(key)
	if key == 13 then
		buffer = buffer .. '|'
	elseif key == 8 then
		buffer = ''
	else
		buffer = buffer .. string.char(key)
	end

	puttext(buffer)
end
