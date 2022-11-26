Profiteers.Buyables = {
    // ["arccw_ud_m79"] = {
    // 	Name = nil, -- auto-generate from EntityClass
    // 	EntityClass = "arccw_ud_m79",
    // 	Price = 750,

    // 	Description = "Break action grenade launcher",
    // 	Description2 = "Multiple payload types",
    // 	Category = "Explosives",
    // 	Icon = nil, -- taken from EntityClass
    // 	CanBuy = nil, -- function(self, ply)
    // 	OnBuy = nil, -- function(self, ply)
    // },

    ["arc9_bo2_stinger"] = {
        EntityClass = "arc9_bo2_stinger",
        Price = 12000,

        Description = "Anti-Aircraft Launcher",
        Description2 = "Fire and forget",
        Category = "Explosives",
    },
    ["arc9_bo1_chinalake"] = {
        EntityClass = "arc9_bo1_chinalake",
        Price = 40000,

        Description = "Pump-Action Grenade Launcher",
        Description2 = "Good firepower",
        Category = "Explosives",
    },
    ["arc9_bo1_m202"] = {
        EntityClass = "arc9_bo1_m202",
        Price = 100000,

        Description = "Multiple Rocket Launcher",
        Description2 = "Massive burst damage",
        Category = "Explosives",
    },
    ["arc9_bo1_minigun"] = {
        EntityClass = "arc9_bo1_minigun",
        Price = 110000,

        Description = "Man-portable Minigun",
        Description2 = "Massive rate of fire",
        Category = "Special Weapons",
    },
    ["arc9_bo2_mm1"] = {
        EntityClass = "arc9_bo2_mm1",
        Price = 90000,

        Description = "Multiple Grenade Launcher",
        Description2 = "Lay down fields of fire",
        Category = "Explosives",
    },
    ["arc9_bo1_strela"] = {
        EntityClass = "arc9_bo1_strela",
        Price = 10000,

        Description = "Anti-Aircraft Launcher",
        Description2 = "Powerful, needs constant lock",
        Category = "Explosives",
    },
    ["arc9_bo1_rpg7"] = {
        EntityClass = "arc9_bo1_rpg7",
        Price = 10000,

        Description = "Anti-Tank Rocket Launcher",
        Description2 = "Dumb-fire rocket launcher",
        Category = "Explosives",
    },
    ["arc9_bo1_law"] = {
        EntityClass = "arc9_bo1_law",
        Price = 5000,

        Description = "Light Anti-Tank Weapon",
        Description2 = "Inaccurate but cheap",
        Category = "Explosives",
    },
    ["arc9_bo2_m32"] = {
        EntityClass = "arc9_bo2_m32",
        Price = 85000,

        Description = "Multiple Grenade Launcher",
        Description2 = "Fast-firing, high damage",
        Category = "Explosives",
    },
    ["arc9_bo2_raygunmk2"] = {
        EntityClass = "arc9_bo2_raygunmk2",
        Price = 250000,

        Description = "Mysterious Alien Artifact",
        Description2 = "The ultimate weapon",
        Category = "Special Weapons",
    },
    ["arc9_waw_flamethrower"] = {
        EntityClass = "arc9_waw_flamethrower",
        Price = 70000,

        Description = "Flamethrower",
        Description2 = "Napalm sweet as wine",
        Category = "Special Weapons",
    },
    ["arc9_bo1_raygun"] = {
        EntityClass = "arc9_bo1_raygun",
        Price = 250000,

        Description = "Mysterious Alien Artifact",
        Description2 = "The ultimate weapon",
        Category = "Special Weapons",
    },

    ["item_rpg_round"] = {
        Name = "Rocket",
        EntityClass = "item_rpg_round",
        Price = 1000,

        Description = "For use with rocket launchers",
        Category = "Ammunition",
    },
    ["item_ammo_smg1_grenade"] = {
        Name = "Rifle Grenade",
        EntityClass = "item_ammo_smg1_grenade",
        Price = 750,

        Description = "For use with grenade launchers",
        Category = "Ammunition",
    },

    ["item_healthkit"] = {
        Name = "Health Kit",
        EntityClass = "item_healthkit",
        Price = 1000,

        Description = "Restores 25 health",
        Category = "Utility",
    },
    ["item_healthvial"] = {
        Name = "Health Vial",
        EntityClass = "item_healthvial",
        Price = 500,

        Description = "Restores 10 health",
        Category = "Utility",
    },
    ["item_battery"] = {
        Name = "Armor Battery",
        EntityClass = "item_battery",
        Price = 1500,

        Description = "Provides 15 points of armor",
        Category = "Utility",
    }
}

Profiteers.BuyableEntities = {}

for k, v in pairs(Profiteers.Buyables) do
    if not v.EntityClass then continue end
    Profiteers.BuyableEntities[v.EntityClass] = true
end