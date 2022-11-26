GM.Buyables = {
	["arccw_ud_m79"] = {
		Name = nil, -- auto-generate from EntityClass
		EntityClass = "arccw_ud_m79",
		Price = 750,

		Description = "Break action grenade launcher",
		Description2 = "Multiple payload types",
		Category = "Explosives",
		Icon = nil, -- taken from EntityClass
		CanBuy = nil, -- function(self, ply)
		OnBuy = nil, -- function(self, ply)
	},
	["arccw_uo_rgd5"] = {
		EntityClass = "arccw_uo_rgd5",
		Price = 200,

		Description = "Fragmentation grenade",
		Description2 = "3.4 second timed fuse",
		Category = "Explosives",

		AmmoOnRebuy = "arccw_uo_rgd5", -- if player has weapon, give this ammo type
		AmmoOnRebuyAmount = 1, -- of this amount
	},
	["arccw_ammo_smg1_grenade"] = {
		EntityClass = "arccw_ammo_smg1_grenade",
		Price = 150,

		Description = "Single round explosive ordnance",
		Description2 = "Use with grenade launchers",
		Category = "Explosives",
	},

	-- M9K
	["m9k_minigun"] = {
		EntityClass = "m9k_minigun",
		Price = 3000,

		Description = "Rotary barrel minigun",
		Description2 = "High recoil",
		Category = "M9K",
	},
	["m9k_barret_m82"] = {
		EntityClass = "m9k_barret_m82",
		Price = 1000,

		Description = "Powerful sniper",
		Description2 = "One shot one kill",
		Category = "M9K",
	},
	["m9k_dragunov"] = {
		EntityClass = "m9k_dragunov",
		Price = 1000,

		Description = "Powerful sniper",
		Description2 = "Deadly",
		Category = "M9K",
	},
	["m9k_svu"] = {
		EntityClass = "m9k_svu",
		Price = 1000,

		Description = "Powerful sniper",
		Description2 = "Deadly",
		Category = "M9K",
	},
	["m9k_usas"] = {
		EntityClass = "m9k_usas",
		Price = 800,

		Description = "Automatic shotgun",
		Description2 = "Extreme lethality",
		Category = "M9K",
	},
	["m9k_striker12"] = {
		EntityClass = "m9k_striker12",
		Price = 700,

		Description = "Semi-automatic shotgun",
		Description2 = "Long reload",
		Category = "M9K",
	},
	["m9k_jackhammer"] = {
		EntityClass = "m9k_jackhammer",
		Price = 700,

		Description = "Magazine-fed shotgun",
		Description2 = "",
		Category = "M9K",
	},
	["m9k_browningauto5"] = {
		EntityClass = "m9k_browningauto5",
		Price = 600,

		Description = "Autoloading shotgun",
		Description2 = "",
		Category = "M9K",
	},
	["m9k_spas12"] = {
		EntityClass = "m9k_spas12",
		Price = 600,

		Description = "Semi-automatic shotgun",
		Description2 = "",
		Category = "M9K",
	},
}

GM.BuyableEntities = {}

for k, v in pairs(GM.Buyables) do
	if not v.EntityClass then continue end
	GM.BuyableEntities[v.EntityClass] = true
end