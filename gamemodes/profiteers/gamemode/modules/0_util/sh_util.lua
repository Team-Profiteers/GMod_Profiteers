local CLR_B = Color(0, 0, 0, 255)

function GM:ShadowText(text, font, x, y, color, color2, t, l, glow)
	draw.SimpleText(text, font .. "_Shadow", x + CGSS(4), y + CGSS(4), color2, t, l)

	if glow then
		draw.SimpleText(text, font .. "_Glow", x, y, CLR_B, t, l)
		draw.SimpleText(text, font .. "_Glow", x, y, CLR_B, t, l)
	end

	draw.SimpleText(text, font, x, y, color, t, l)
end

local threshold = {
	{1e12, "t", 1e12},
	{1e9, "b", 1e9},
	{1e6, "m", 1e6},
	{1e5, "k", 1e3},
}
local threshold_short = {
	{1e11, "t", 1e12},
	{1e8, "b", 1e9},
	{1e5, "m", 1e6},
	{1e3, "k", 1e3}
}

function GM:FormatMoney(amt, short)
	for _, v in ipairs(short and threshold_short or threshold) do
		if math.Round(amt / v[3]) >= v[1] / v[3] then
			return "$" .. math.Round(amt / v[3], short and 1 or 2) .. v[2]
		end
	end
	return "$" .. amt
end

function CGSS(size)
	return size * (ScrH() / 720)
end