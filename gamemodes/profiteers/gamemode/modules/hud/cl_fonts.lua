
local bs = 3
local bs_shadow = 1

local fonts = {
	[2] = 48,
	[3] = 36,
	[4] = 30,
	[5] = 24,
	[6] = 18,
	[7] = 12,
	[8] = 10,
	[9] = 8,
	[10] = 6,
}

for k, v in pairs(fonts) do
	surface.CreateFont("CGHUD_" .. k, {
		font = "Bahnschrift",
		size = CGSS(v),
		weight = 0,
		extended = true,
	})
	surface.CreateFont("CGHUD_" .. k .. "_Glow", {
		font = "Bahnschrift",
		size = CGSS(v),
		weight = 0,
		blursize = bs,
		extended = true,
	})
	surface.CreateFont("CGHUD_" .. k .. "_Shadow", {
		font = "Bahnschrift",
		size = CGSS(v),
		weight = 0,
		blursize = bs_shadow,
		extended = true,
	})
end

surface.CreateFont("CGHUD_1", {
	font = "Cascadia Mono",
	size = CGSS(72),
	weight = 0,
	blursize = bs,
	extended = true,
})

local fonts_unscaled = {
	32,
	24,
}

for _, v in pairs(fonts_unscaled) do
	surface.CreateFont("CGHUD_" .. v .. "_Unscaled", {
		font = "Bahnschrift",
		size = v,
		weight = 0,
		extended = true,
	})
	surface.CreateFont("CGHUD_" .. v .. "_Unscaled_Glow", {
		font = "Bahnschrift",
		size = v,
		weight = 0,
		blursize = bs,
		extended = true,
	})
	surface.CreateFont("CGHUD_" .. v .. "_Unscaled_Shadow", {
		font = "Bahnschrift",
		size = v,
		weight = 0,
		blursize = bs_shadow,
		extended = true,
	})
end