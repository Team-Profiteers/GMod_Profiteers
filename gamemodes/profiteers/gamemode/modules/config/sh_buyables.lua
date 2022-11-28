local WarpRequired = function(self, ply)
    if !ply:WithinBeacon() and !ply:HasBoughtEntity("pt_supply_warp", true, true) then
        if CLIENT then GAMEMODE:Hint(ply, 1 ,"This can only be bought if you are near a Beacon or own a Supply Warp.") end
        return false
    end
    return true
end

Profiteers.Buyables = {
    -- ["arccw_ud_m79"] = {
    -- 	Name = nil, -- auto-generate from EntityClass
    -- 	EntityClass = "arccw_ud_m79",
    -- 	Price = 750,

    -- 	Description = "Break action grenade launcher",
    -- 	Description2 = "Multiple payload types",
    -- 	Category = "Explosives",
    -- 	Icon = nil, -- taken from EntityClass
    -- 	CanBuy = nil, -- function(self, ply)
    -- 	OnBuy = nil, -- function(self, ply)
    -- },

    ["arc9_bo2_stinger"] = {
        EntityClass = "arc9_bo2_stinger",
        Price = 15000,

        Description = "Anti-Aircraft Launcher",
        Description2 = "Fire and forget",
        Category = "Explosives",
    },
    ["arc9_bo1_chinalake"] = {
        EntityClass = "arc9_bo1_chinalake",
        Price = 5000,

        Description = "Pump-Action Grenade Launcher",
        Description2 = "Poor firepower but cheap",
        Category = "Explosives",
    },
    ["arc9_bo1_m202"] = {
        EntityClass = "arc9_bo1_m202",
        Price = 80000,

        Description = "Multiple Rocket Launcher",
        Description2 = "Massive incendiary damage",
        Category = "Explosives",
    },
    ["arc9_bo1_minigun"] = {
        EntityClass = "arc9_bo1_minigun",
        Price = 100000,

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
        Price = 7500,

        Description = "Anti-Aircraft Launcher",
        Description2 = "Powerful, needs constant lock",
        Category = "Explosives",
    },
    ["arc9_bo1_rpg7"] = {
        EntityClass = "arc9_bo1_rpg7",
        Price = 6000,

        Description = "Anti-Tank Rocket Launcher",
        Description2 = "Dumb-fire rocket launcher",
        Category = "Explosives",
    },
    ["arc9_bo1_law"] = {
        EntityClass = "arc9_bo1_law",
        Price = 2000,

        Description = "Light Anti-Tank Weapon",
        Description2 = "Inaccurate but cheap",
        Category = "Explosives",
    },
    ["arc9_bo2_m32"] = {
        EntityClass = "arc9_bo2_m32",
        Price = 10000,

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
        Price = 75000,

        Description = "Extreme close range \"fire\"power",
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
        Description2 = "Requires nearby Beacon or a Warp",
        Category = "Supplies",

        CanBuy = WarpRequired,
    },
    ["item_ammo_smg1_grenade"] = {
        Name = "Rifle Grenade",
        EntityClass = "item_ammo_smg1_grenade",
        Price = 500,

        Description = "For use with grenade launchers",
        Description2 = "Requires nearby Beacon or a Warp",
        Category = "Supplies",

        CanBuy = WarpRequired,
    },

    ["item_healthkit"] = {
        Name = "Health Kit",
        EntityClass = "item_healthkit",
        Price = 500,

        Description = "Restores 25 health",
        Description2 = "Requires nearby Beacon or a Warp",
        Category = "Supplies",

        CanBuy = WarpRequired,
    },
    ["item_healthvial"] = {
        Name = "Health Vial",
        EntityClass = "item_healthvial",
        Price = 200,

        Description = "Restores 10 health",
        Description2 = "Requires nearby Beacon or a Warp",
        Category = "Supplies",

        CanBuy = WarpRequired,
    },
    ["item_battery"] = {
        Name = "Armor Battery",
        EntityClass = "item_battery",
        Price = 750,

        Description = "Provides 15 points of armor",
        Description2 = "Requires nearby Beacon or a Warp",
        Category = "Supplies",

        CanBuy = WarpRequired,
    },
    -- ["spiderman's_swep"] = {
    --     Name = "Spiderman's Gun",
    --     EntityClass = "spiderman's_swep",
    --     Price = 200,

    --     Description = "Swing around the map",
    --     Description2 = "Critical vertical mobility tool",

    --     Category = "Utility"
    -- },

    ["pt_nuke"] = {
        Name = "Nuclear Device",
        EntityClass = "pt_nuke",
        Price = 1000000,
        PlaceEntity = true,

        Description = "1.2mt fission bomb",
        Description2 = "End it all and watch it burn",

        Category = "Basebuilding"
    },
    ["pt_beacon"] = {
        Name = "Base Beacon",
        EntityClass = "pt_beacon",
        Price = 1000,
        EntityLimit = 1,
        PlaceEntity = true,

        Description = "Reinforces nearby props",
        Description2 = "Required for most buildings",

        Category = "Basebuilding"
    },
    ["pt_spawn"] = {
        Name = "Deployable Spawn",
        EntityClass = "pt_spawn",
        Price = 1500,
        PlaceEntity = true,

        Description = "Respawn at your base",
        Description2 = "Must be deployed near a Beacon",

        Category = "Basebuilding"
    },
    ["pt_alarm"] = {
        Name = "Motion Sensor",
        EntityClass = "pt_alarm",
        Price = 500,
        PlaceEntity = true,

        Description = "Alarm when enemies get near",
        Description2 = "Helps stop intruders",

        Category = "Basebuilding"
    },
    ["pt_minelayer"] = {
        Name = "Cluster Mine",
        EntityClass = "pt_minelayer",
        Price = 5000,
        PlaceEntity = true,

        Description = "Creates a field of mines",
        Description2 = "Tread carefully",

        Category = "Basebuilding"
    },
    ["pt_safe"] = {
        Name = "Safe Storage Box",
        EntityClass = "pt_safe",
        Price = 1000,
        PlaceEntity = true,

        Description = "Stores money safely",
        Description2 = "Sprint + use to withdraw 10k",

        Category = "Basebuilding"
    },

    ["pt_arsenal"] = {
        Name = "Arsenal",
        EntityClass = "pt_arsenal",
        Price = 3000,
        PlaceEntity = true,

        Description = "Free global weapon spawning",
        Description2 = "Must be deployed near a Beacon",

        Category = "Basebuilding"
    },
    -- ["pt_cart_health"] = {
    --     Name = "Health Station",
    --     EntityClass = "pt_cart_health",
    --     Price = 1500,
    --     PlaceEntity = true,

    --     Description = "Restores your health",
    --     Description2 = "Place near Beacon to use",

    --     Category = "Basebuilding"
    -- },
    ["pt_sentry"] = {
        Name = "Sentry Turret",
        EntityClass = "pt_sentry",
        Price = 12500,
        PlaceEntity = true,

        Description = "Attacks enemies automatically",
        Description2 = "Place near Beacon to use",

        Category = "Basebuilding"
    },
    ["pt_cart_armor"] = {
        Name = "Armor Station",
        EntityClass = "pt_cart_armor",
        Price = 2500,
        PlaceEntity = true,

        Description = "Grants armor",
        Description2 = "Place near Beacon to use",

        Category = "Basebuilding"
    },
    ["pt_cart_smg_grenade"] = {
        Name = "Grenade Autolathe",
        EntityClass = "pt_cart_smg_grenade",
        Price = 3000,
        PlaceEntity = true,

        Description = "Produces Rifle Grenades",
        Description2 = "Place near Beacon to use",

        Category = "Basebuilding"
    },
    ["pt_cart_rpg_rocket"] = {
        Name = "Rocket Autolathe",
        EntityClass = "pt_cart_rpg_rocket",
        Price = 5000,
        PlaceEntity = true,

        Description = "Produces Rockets",
        Description2 = "Place near Beacon to use",

        Category = "Basebuilding"
    },
    ["pt_regen_boost"] = {
        Name = "Nanite Booster",
        EntityClass = "pt_regen_boost",
        Price = 15000,
        PlaceEntity = true,

        Description = "Nanomachines improve regen",
        Description2 = "Place near Beacon to use",

        Category = "Basebuilding"
    },
    ["pt_supply_warp"] = {
        Name = "Supply Warp",
        EntityClass = "pt_supply_warp",
        Price = 12000,
        PlaceEntity = true,

        Description = "Buy supplies outside your base",
        Description2 = "Place near Beacon to use",

        Category = "Basebuilding"
    },
    ["pt_telepad"] = {
        Name = "Telepad",
        EntityClass = "pt_telepad",
        Price = 10000,
        PlaceEntity = true,
        EntityLimit = 1,

        Description = "WIP NOT FUNCTIONAL",
        --Description = "Teleport from anywhere to here",
        --Description2 = "Must be deployed near a Beacon",

        Category = "Basebuilding"
    },
    ["pt_launchpad"] = {
        Name = "Launchpad",
        EntityClass = "pt_launchpad",
        Price = 5500,
        PlaceEntity = true,

        Description = "Launch yourself into the air",
        Description2 = "Must be deployed near a Beacon",

        Category = "Basebuilding"
    },
}

Profiteers.BuyableEntities = {}

for k, v in pairs(Profiteers.Buyables) do
    if not v.EntityClass then continue end
    Profiteers.BuyableEntities[v.EntityClass] = true
end