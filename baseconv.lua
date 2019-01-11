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

	if negative then
		if s:len() == 1 then
			return 'invalid input string'
		end

		s = s:sub(2)
	end

	local inv = {}

	for i = 1, #digits do
		inv[digits[i]] = i - 1
	end

	local baseten = 0

	for i = 1, #s do
		if inv[s:sub(i, i)] == nil then
			return 'invalid input string'
		end
		baseten = baseten * from_radix + inv[s:sub(i, i)]
	end

	local result = ''


	while baseten > 0 do
		if digits[(baseten % to_radix) + 1] == nil then
			return 'number too large'
		end
		-- 1 added because of 1-indexing
		result = digits[(baseten % to_radix) + 1] .. result
		baseten = math.floor(baseten / to_radix)
	end

	if negative then
		result = '-' .. result
	end

	return result
end
