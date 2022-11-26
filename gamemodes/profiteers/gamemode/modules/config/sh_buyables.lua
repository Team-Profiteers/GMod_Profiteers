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
        Price = 5000,

        Description = "Anti-Aircraft Launcher",
        Description2 = "Fire and forget",
        Category = "Explosives",
    },
    ["arc9_bo1_chinalake"] = {
        EntityClass = "arc9_bo1_chinalake",
        Price = 17500,

        Description = "Pump-Action Grenade Launcher",
        Description2 = "Good firepower",
        Category = "Explosives",
    },
    ["arc9_bo1_m202"] = {
        EntityClass = "arc9_bo1_m202",
        Price = 45000,

        Description = "Multiple Rocket Launcher",
        Description2 = "Massive burst damage",
        Category = "Explosives",
    },
    ["arc9_bo1_minigun"] = {
        EntityClass = "arc9_bo1_minigun",
        Price = 75000,

        Description = "Man-portable Minigun",
        Description2 = "Massive rate of fire",
        Category = "Special Weapons",
    },
    ["arc9_bo2_mm1"] = {
        EntityClass = "arc9_bo2_mm1",
        Price = 80000,

        Description = "Multiple Grenade Launcher",
        Description2 = "Lay down fields of fire",
        Category = "Explosives",
    },
    ["arc9_bo1_strela"] = {
        EntityClass = "arc9_bo1_strela",
        Price = 2500,

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
        Price = 1000,

        Description = "Light Anti-Tank Weapon",
        Description2 = "Inaccurate but cheap",
        Category = "Explosives",
    },
    ["arc9_bo2_m32"] = {
        EntityClass = "arc9_bo2_m32",
        Price = 60000,

        Description = "Multiple Grenade Launcher",
        Description2 = "Fast-firing, high damage",
        Category = "Explosives",
    },
    ["arc9_bo2_raygunmk2"] = {
        EntityClass = "arc9_bo2_raygunmk2",
        Price = 200000,

        Description = "Mysterious Alien Artifact",
        Description2 = "The ultimate weapon",
        Category = "Special Weapons",
    }
}

Profiteers.BuyableEntities = {}

for k, v in pairs(Profiteers.Buyables) do
    if not v.EntityClass then continue end
    Profiteers.BuyableEntities[v.EntityClass] = true
end