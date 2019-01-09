function bearing(x1, t1, x2, t2)
	x1 = tonumber(x1)
	t1 = tonumber(t1)
	x2 = tonumber(x2)
	t2 = tonumber(t2)

	if x1 == nil or t1 == nil or x2 == nil or t2 == nil then
		return 'invalid input string', 'invalid input string'
	end

	t1 = math.rad(t1)
	t2 = math.rad(t2)

	_90 = math.pi / 2

	xt = x1 * math.cos(_90 - t1) + x2 * math.cos(_90 - t2)

	yt = x1 * math.sin(_90 - t1) + x2 * math.sin(_90 - t2)

	tf = math.deg(math.atan2(yt , xt))

	tf = (tf + 360) % 360

	return string.format('%.4f', math.sqrt(xt * xt + yt * yt)), 
			string.format('%.3fº', tf)

end
