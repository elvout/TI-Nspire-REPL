PROMPT = '>>> '
lines = {PROMPT}
hist_index = 1
hist_temp = PROMPT
cursor = lines[#lines]:len()
caret = '|'
MAXLINES = 9

debug = {cursor = false}

function on.paint(gc)
	local start = math.max(#lines - MAXLINES + 1, 1)

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

	local caret_pos = gc:getStringWidth(lines[#lines]:sub(1, cursor))

	gc:setFont('sansserif', 'r', 12)
	gc:drawString(	caret,
					3 + caret_pos,
					gc:getStringHeight('') * (#lines - start + 1) - 1	)

	gc:setFont('sansserif', 'r', 10)
	gc:drawString('Compiled 2019-01-09 03:27:12 PM', 5, platform.window:height() - 1)
	gc:drawString('-h for help', platform.window:width() - gc:getStringWidth('-h for help') - 5, 
					platform.window:height() - 1)

	if debug.cursor then
		debug_cursor(gc)
	end
end

function debug_cursor(gc)
	local raw = ''
	for i = 1, lines[#lines]:len() do
		raw = raw .. lines[#lines]:byte(i) .. ' '
	end
	
	gc:setFont('sansserif', 'r', 10)
	gc:drawString(raw, 5, platform.window:height() - gc:getStringHeight('') * 2)
	gc:drawString(cursor, 5, platform.window:height() - gc:getStringHeight(''))
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
	if lines[#lines]:sub(1, PROMPT:len()) == PROMPT then
		lines[#lines] = lines[#lines]:sub(1, cursor) .. char .. lines[#lines]:sub(cursor + 1)
	else
		table.insert(lines, PROMPT .. char)
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
	if hist_index == 1 then
		return
	end

	if hist_index == #lines then
		hist_temp = lines[#lines]
	end

	hist_index = math.max(hist_index - 1, 1)
	while hist_index > 0 do
		if lines[hist_index]:sub(1, PROMPT:len()) == PROMPT then
			lines[#lines] = lines[hist_index]
			break
		end
		hist_index = hist_index - 1
	end

	cursor = lines[#lines]:len()

	platform.window:invalidate()
end

function on.arrowDown()
	if hist_index == #lines then
		return
	end

	hist_index = math.min(hist_index + 1, #lines)

	while hist_index <= #lines do
		if lines[hist_index]:sub(1, PROMPT:len()) == PROMPT then
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
	local i = cursor

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
	local i = cursor

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
	local i = cursor

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

function rtrim(s)
	s = tostring(s)
	for i = #s, 5, -1 do
		if s:byte(i) ~= 32 then
			return s:sub(1, i)
		end
	end
	return s
end

function nans(idx)
	i = tonumber(idx:sub(2))

	for j = #lines, 1, -1 do
		if lines[j]:match('[a-f0-9.º]+') == lines[j] then
			i = i - 1
		end

		if i == 0 then
			return lines[j]
		end
	end
	return '{' .. idx .. '}'
end

function convertminus(args)
	local MINUS = string.char(226) .. string.char(136) .. string.char(146)
	for i = 1, #args do
		args[i] = args[i]:gsub(MINUS, '-')
	end
	return args
end

function on.enterKey()
	if lines[#lines] == PROMPT then return end

	lines[#lines] = rtrim(lines[#lines])

	if lines[#lines]:find('=') ~= nil then
		lines[#lines] = lines[#lines]:gsub("(=%d)", nans)
	end

	local orig = lines[#lines]:sub(5):split('[, ]+') or {}
	local args = convertminus(orig)

	if args[1]:sub(1, 2) == 'ba' then
		if #args == 4 then
			table.insert(lines, baseconv(args[2], args[3], args[4]))
		elseif #args == 3 then
			table.insert(lines, baseconv(args[2], args[3], 10))
		else
			table.insert(lines, 'Usage: ba, number, from_radix, [to_radix]')
			table.insert(lines, 'to_radix (optional) defaults to 10')
		end
	elseif args[1]:sub(1, 2) == 'be' then
		if #args == 5 then
			len, angle = bearing(args[2], args[3], args[4], args[5])
			table.insert(lines, len)
			table.insert(lines, angle)
		else
			table.insert(lines, 'Usage: be, d1, θ1, d2, θ2')
			table.insert(lines, 'angles are in degrees')
		end	
	elseif args[1] == '-h' or args[1] == 'help' then
		local msg = {
			'> -c to list commands',
			'=n : (1-9) access nth last result',
			'up/down to access command history',
			'L/R/tab/shift+tab to navigate input',
			'ctrl+del to delete word'
		}

		for i = 1, #msg do
			table.insert(lines, msg[i])
		end
	elseif args[1] == '-c' then
		local msg = {
			'> ba    base conversion',
			'> be    bearing function',
			'> dd    deletes last entry',
			'> rr     clears history',
			'> ls     lists available past results',
			''
		}

		for i = 1, #msg do
			table.insert(lines, msg[i])
		end
	elseif args[1] == 'ls' then
		for i = 9, 1, -1 do 
			if nans('=' .. i):find('{') == nil then
				table.insert(lines, string.format('=%d: %20s', i, nans('=' .. i)))
			end
		end
	elseif args[1] == 'dd' then
		if #lines > 0 then
			table.remove(lines)
		end
		while #lines > 0 and table.remove(lines):find(PROMPT) == nil do end
	elseif args[1] == 'rr' then
		lines = {}
	elseif args[1] == '-v' then
		local msg = {
			_VERSION,	
			'API Level: ' .. platform.apiLevel,
			'Compiled with Luna 2.0'
		}
		
		for i = 1, #msg do
			table.insert(lines, msg[i])
		end
	elseif args[1] == '-dc' then
		debug.cursor = not debug.cursor
	elseif #args == 1 and args[1] ~= nil then
		table.insert(lines, eval(orig[1]))
	end
	
	table.insert(lines, PROMPT)
	
	hist_index = #lines
	hist_temp = PROMPT
	cursor = lines[#lines]:len()

	platform.window:invalidate()
end

function eval(expr)
	local result, err = math.eval(expr)
	if result ~= nil then
		return result
	else
		result, err = math.eval(expr .. ')')
		if result ~= nil then
			return result
		end
		return expr
	end
end

