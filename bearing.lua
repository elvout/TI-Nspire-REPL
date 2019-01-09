function bearing(d1, t1, d2, t2)
	d1 = tonumber(d1)
	t1 = tonumber(t1)
	d2 = tonumber(d2)
	t2 = tonumber(t2)

	if d1 == nil or t1 == nil or d2 == nil or t2 == nil then
		return 'invalid input string', 'invalid input string'
	end

	t1 = math.rad(t1)
	t2 = math.rad(t2)

	_90 = math.pi / 2

	xt = d1 * math.cos(_90 - t1) + d2 * math.cos(_90 - t2)

	yt = d1 * math.sin(_90 - t1) + d2 * math.sin(_90 - t2)

	tf = math.deg(math.atan2(yt , xt))

	tf = (tf + 360) % 360

	return string.format('%.4f', math.sqrt(xt * xt + yt * yt)), 
			string.format('%.3fº', tf)

end
