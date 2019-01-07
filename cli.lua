lines = {'>>> '}
hist_index = 1
hist_temp = ''
cursor = lines[#lines]:len()
caret = '|'
MAXLINES = 9

debug = {cursor = false}

function on.paint(gc)
	start = math.max(#lines - MAXLINES + 1, 1)

	gc:setFont('sansserif', 'r', 11)
	for cur = start, #lines do
		if type(lines[cur]) ~= 'string' then
			lines[cur] = tostring(lines[cur])
		end

		if lines[cur]:sub(1, 1) == '>' then
			gc:drawString(	lines[cur],
							5, 
							gc:getStringHeight('') * (cur - start + 1)	)
		else
			gc:drawString(	lines[cur],
							platform.window:width() - 5 - gc:getStringWidth(lines[cur]),
							gc:getStringHeight('') * (cur - start + 1)	)
		end
	end

	caret_pos = gc:getStringWidth(lines[#lines]:sub(1, cursor))

	gc:setFont('sansserif', 'r', 12)
	gc:drawString(	caret,
					3 + caret_pos,
					gc:getStringHeight('') * (#lines - start + 1) - 1	)

	gc:setFont('sansserif', 'r', 10)
	gc:drawString('Compiled 2019-01-07 04:46:28 PM', 5, platform.window:height() - 1)

	if debug.cursor then
		debug_cursor(gc)
	end
end

function debug_cursor(gc)
	raw = ''
	for i = 1, lines[#lines]:len() do
		raw = raw .. lines[#lines]:byte(i) .. ' '
	end
	
	gc:setFont('sansserif', 'r', 10)
	gc:drawString(raw, 5, platform.window:height() - 24)
	gc:drawString(cursor, 5, platform.window:height() - 12)
end

function on.getFocus()
	timer.start(0.5)
end

function on.loseFocus()
	timer.stop()
end

function on.timer()
	if caret == ' ' then
		caret = '|'
	else
		caret = ' '
	end

	platform.window:invalidate()
end

function on.charIn(char)
	if lines[#lines]:sub(1, 1) == '>' then
		lines[#lines] = lines[#lines]:sub(1, cursor) .. char .. lines[#lines]:sub(cursor + 1)
	else
		table.insert(lines, '>>> ' .. char)
	end

	cursor = cursor + char:len()

	caret = '|'
	platform.window:invalidate()
end

function on.backspaceKey()
	if cursor > 4 then
		if lines[#lines]:byte(cursor) < 128 then
			lines[#lines] = lines[#lines]:sub(1, cursor - 1) .. lines[#lines]:sub(cursor + 1)
			cursor = cursor - 1
		else
			-- unicode character, uses multiple UTF-8 bytes

			while lines[#lines]:byte(cursor) < 194 do
				lines[#lines] = lines[#lines]:sub(1, cursor - 1) .. lines[#lines]:sub(cursor + 1)
				cursor = cursor - 1
			end
			lines[#lines] = lines[#lines]:sub(1, cursor - 1) .. lines[#lines]:sub(cursor + 1)
			cursor = cursor - 1
		end
	end

	caret = '|'
	platform.window:invalidate()
end

function on.arrowUp()
	if hist_index == #lines then
		hist_temp = lines[#lines]
	end

	hist_index = math.max(hist_index - 1, 1)
	while hist_index > 0 do
		if lines[hist_index]:sub(1, 1) == '>' then
			lines[#lines] = lines[hist_index]
			break
		end
		hist_index = hist_index - 1
	end

	cursor = lines[#lines]:len()

	platform.window:invalidate()
end

function on.arrowDown()
	hist_index = math.min(hist_index + 1, #lines)

	while hist_index <= #lines do
		if lines[hist_index]:sub(1, 1) == '>' then
			break
		end
		hist_index = hist_index + 1
	end

	if hist_index == #lines then
		lines[#lines] = hist_temp
	else
		lines[#lines] = lines[hist_index]
	end

	cursor = lines[#lines]:len()

	platform.window:invalidate()
end

function on.arrowLeft()
	if cursor > 4 then
		if lines[#lines]:byte(cursor) < 128 then
			cursor = cursor - 1
		else
			while lines[#lines]:byte(cursor) < 194 do
				cursor = cursor - 1
			end
			cursor = cursor - 1
		end
	end

	caret = '|'
	platform.window:invalidate()
end

function on.arrowRight()
	if cursor < lines[#lines]:len() then
		if lines[#lines]:byte(cursor + 1) < 128 then
			cursor = cursor + 1
		else
			cursor = cursor + 1
			while cursor < lines[#lines]:len() and 
					lines[#lines]:byte(cursor + 1) > 127 and 
					lines[#lines]:byte(cursor + 1) < 194 do
				cursor = cursor + 1
			end
		end
	end

	caret = '|'
	platform.window:invalidate()
end

function on.tabKey()
	i = cursor

	while i < lines[#lines]:len() and
			(lines[#lines]:byte(i + 1) == 32 or lines[#lines]:byte(i + 1) == 44) do
		i = i + 1
	end

	while i < lines[#lines]:len() and
			lines[#lines]:byte(i + 1) ~= 32 and lines[#lines]:byte(i + 1) ~= 44 do
		i = i + 1
	end

	cursor = i
	caret = '|'
	platform.window:invalidate()
end

function on.backtabKey()
	i = cursor

	while i > 4 and
			(lines[#lines]:byte(i) == 32 or lines[#lines]:byte(i) == 44) do
		i = i - 1
	end

	while i > 4 and
			lines[#lines]:byte(i) ~= 32 and lines[#lines]:byte(i) ~= 44 do
		i = i - 1
	end

	cursor = i
	caret = '|'
	platform.window:invalidate()
end

function on.clearKey()
	i = cursor

	while i > 4 and (lines[#lines]:byte(i) == 32 or lines[#lines]:byte(i) == 44) do
		i = i - 1
	end

	while i > 4 and lines[#lines]:byte(i) ~= 32 and lines[#lines]:byte(i) ~= 44 do
		i = i - 1
	end

	lines[#lines] = lines[#lines]:sub(1, i) .. lines[#lines]:sub(cursor + 1)
	cursor = i

	caret = '|'
	platform.window:invalidate()
end

function on.enterKey()
	args = lines[#lines]:sub(5):split('[, ]+')

	if args[1]:sub(1, 2) == 'ba' then
		if #args == 4 then
			table.insert(lines, baseconv(args[2], args[3], args[4]))
		else
			table.insert(lines, 'Usage: ba[se], number, from_radix, to_radix')
		end
	elseif args[1] == 'rr' then
		lines = {}
	elseif args[1] == '-v' then
		table.insert(lines, _VERSION)
		table.insert(lines, 'API Level: ' .. platform.apiLevel)
		table.insert(lines, 'Compiled with Luna 2.0')
	elseif args[1] == '-dc' then
		debug.cursor = not debug.cursor
	elseif #args == 1 then
		table.insert(lines, eval(args[1]))
	end
	
	table.insert(lines, '>>> ')
	
	hist_index = #lines
	hist_temp = ''
	cursor = lines[#lines]:len()

	platform.window:invalidate()
end

function eval(expr)
	result, err = math.eval(expr)
	if result ~= nil then
		return result
	else
		return expr
	end
end
