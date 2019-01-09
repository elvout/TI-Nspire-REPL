function baseconv(s, from_radix, to_radix)
	s = tostring(s)
	from_radix = tonumber(from_radix)
	to_radix = tonumber(to_radix)

	local digits = {'0', '1', '2', '3', '4', '5', '6', '7', '8', '9', 
					'a', 'b', 'c', 'd', 'e', 'f'}

	if from_radix == nil or to_radix == nil or
			from_radix < 2 or to_radix < 2 or 
			from_radix > 16 or to_radix > 16 or
			from_radix ~= math.floor(from_radix) or
			to_radix ~= math.floor(to_radix) 
		then return 'invalid base'
	end

	local negative = s:byte() == 45

	local baseten = 0

	if negative then
		if s:len() == 1 then
			return 'invalid input string'
		end

		baseten = tonumber(s:sub(2), from_radix) or tonumber(s:sub(4), from_radix)
	else
		baseten = tonumber(s, from_radix)
	end

	if baseten == nil or baseten ~= math.floor(baseten) then
		return 'invalid input string'
	end

	if to_radix == 10 then
		return baseten
	end

	local result = ''

	while baseten > 0 do
		-- 1 added because of 1-indexing
		result = digits[(baseten % to_radix) + 1] .. result
		baseten = math.floor(baseten / to_radix)
	end

	if negative then
		result = '-' .. result
	end

	return result
end
