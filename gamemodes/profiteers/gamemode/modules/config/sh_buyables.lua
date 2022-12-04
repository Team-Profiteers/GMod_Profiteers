local WarpRequired = function(self, ply)
    if !ply:WithinBeacon() and !ply:HasBoughtEntity("pt_supply_warp", true, false) then
        if CLIENT then GAMEMODE:Hint(ply, 1 ,"This can only be bought if you are near a Beacon or own a Supply Warp.") end
        return false
    end
    return true
end

Profiteers.BuyableCategoryIcons = {
    ["Construction"]    = "icon16/house.png",
    ["Equipment"]       = "icon16/wrench.png",
    ["Explosives"]      = "icon16/bomb.png",
    ["Fire Support"]    = "icon16/find.png",
    ["Special Weapons"] = "icon16/wand.png",
    ["Supplies"]        = "icon16/box.png",
    ["Vehicles"]        = "icon16/car.png",
}

Profiteers.Buyables = {
    -- ["arccw_ud_m79"] = {
    --  Name = nil, -- auto-generate from EntityClass
    --  EntityClass = "arccw_ud_m79",
    --  Price = 750,
    --  EntityLimit = nil,
    --  CannotSell = false,
    --  Cooldown = 300,

    -- 	Description = "Break action grenade launcher",
    --  Description2 = "Multiple payload types",
    --  Category = "Explosives",
    --  Icon = nil, -- taken from EntityClass
    --  CanBuy = nil, -- function(self, ply)
    --  OnBuy = nil, -- function(self, ply)
    --  OnPlaceEntity = nil, -- function(self, ply, tr)
    --  GetCooldown = nil, -- function(self, ply)
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
        Price = 4000,

        Description = "Pump-Action Grenade Launcher",
        Description2 = "Slow, loads multiple rounds",
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
        Description2 = "Powerful and accurate, no lock",
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
        Price = 40000,

        Description = "Multiple Grenade Launcher",
        Description2 = "Fast-firing, slow to load",
        Category = "Explosives",
    },
    ["arc9_waw_flamethrower"] = {
        EntityClass = "arc9_waw_flamethrower",
        Price = 80000,

        Description = "Extreme close range \"fire\"power",
        Description2 = "Napalm sweet as wine",
        Category = "Special Weapons",
    },
    ["arc9_bo2_raygunmk2"] = {
        EntityClass = "arc9_bo2_raygunmk2",
        Price = 250000,

        Description = "Mysterious Alien Artifact",
        Description2 = "The ultimate weapon",
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
    ["pt_pocket_tele"] = {
        EntityClass = "pt_pocket_tele",
        Price = 500,

        Description = "Go to Telepad or random spot",
        Description2 = "Long cooldown after use",
        Category = "Equipment",
    },
    ["pt_wrangler"] = {
        EntityClass = "pt_wrangler",
        Price = 2500,

        Description = "Manually target sentries",
        Description2 = "M1 for guns, M2 for rockets",
        Category = "Equipment",
    },

    ["pt_nuke"] = {
        Name = "Nuclear Device",
        EntityClass = "pt_nuke",
        Price = 1000000,
        PlaceEntity = true,
        CannotSell = true,
        EntityLimit = 1,

        Description = "1.2mt fission bomb",
        Description2 = "End it all and watch it burn",

        Category = "Explosives"
    },
    ["pt_beacon"] = {
        Name = "Base Beacon",
        EntityClass = "pt_beacon",
        Price = 1000,
        EntityLimit = 1,
        PlaceEntity = true,

        Description = "Reinforces nearby props",
        Description2 = "Required for most buildings",

        Category = "Construction"
    },
    ["pt_spawn"] = {
        Name = "Deployable Spawn",
        EntityClass = "pt_spawn",
        Price = 1500,
        PlaceEntity = true,

        Description = "Respawn at your base",
        Description2 = "Must be deployed near a Beacon",

        Category = "Construction"
    },
    ["pt_alarm"] = {
        Name = "Motion Sensor",
        EntityClass = "pt_alarm",
        Price = 500,
        PlaceEntity = true,

        Description = "Alarm when enemies get near",
        Description2 = "Helps stop intruders",

        Category = "Construction"
    },
    ["pt_minelayer"] = {
        Name = "Cluster Mine",
        EntityClass = "pt_minelayer",
        Price = 50000,
        PlaceEntity = true,
        EntityLimit = 2,

        Description = "Creates a field of mines",
        Description2 = "Tread carefully",

        Category = "Explosives"
    },
    ["pt_safe"] = {
        Name = "Safe Storage Box",
        EntityClass = "pt_safe",
        Price = 4000,
        PlaceEntity = true,
        EntityLimit = 1,

        Description = "Stores money safely",
        Description2 = "Sprint + use to withdraw 10k",

        Category = "Construction"
    },

    ["pt_arsenal"] = {
        Name = "Arsenal",
        EntityClass = "pt_arsenal",
        Price = 3000,
        PlaceEntity = true,

        Description = "Free global weapon spawning",
        Description2 = "Must be deployed near a Beacon",

        Category = "Construction"
    },
    -- ["pt_cart_health"] = {
    --     Name = "Health Station",
    --     EntityClass = "pt_cart_health",
    --     Price = 1500,
    --     PlaceEntity = true,

    --     Description = "Restores your health",
    --     Description2 = "Place near Beacon to use",

    --     Category = "Construction"
    -- },
    ["pt_sentry"] = {
        Name = "Briefcase Sentry",
        EntityClass = "pt_sentry",
        Price = 12500,
        PlaceEntity = true,
        EntityLimit = 3,

        Description = "Close range area denial",
        Description2 = "Lightweight emplacement",

        Category = "Construction"
    },
    ["pt_sentry_hmg"] = {
        Name = "HMG Sentry",
        EntityClass = "pt_sentry_hmg",
        Price = 35000,
        PlaceEntity = true,
        EntityLimit = 2,

        Description = "High firepower area denial",
        Description2 = "Lightweight emplacement",

        Category = "Construction"
    },
    ["pt_sentry_missile"] = {
        Name = "Missile Sentry",
        EntityClass = "pt_sentry_missile",
        Price = 25000,
        PlaceEntity = true,
        EntityLimit = 2,

        Description = "Locks onto planes and enemies",
        Description2 = "Lightweight emplacement",

        Category = "Construction"
    },
    ["pt_sentry_advanced"] = {
        Name = "Air Defense Turret",
        EntityClass = "pt_sentry_advanced",
        Price = 70000,
        PlaceEntity = true,
        EntityLimit = 2,

        Description = "Anti-aircraft rotary flak cannon",
        Description2 = "Durable, cannot target ground",

        Category = "Construction"
    },
    ["pt_sentry_rocket"] = {
        Name = "Rocket Battery",
        EntityClass = "pt_sentry_rocket",
        Price = 120000,
        PlaceEntity = true,
        EntityLimit = 1,

        Description = "Launches multi-rocket barrages",
        Description2 = "Durable, has minimum distance",

        Category = "Construction"
    },
    ["pt_cart_armor"] = {
        Name = "Armor Station",
        EntityClass = "pt_cart_armor",
        Price = 2500,
        PlaceEntity = true,

        Description = "Grants armor",
        Description2 = "Place near Beacon to use",

        Category = "Construction"
    },
    ["pt_cart_smg_grenade"] = {
        Name = "Grenade Autolathe",
        EntityClass = "pt_cart_smg_grenade",
        Price = 3000,
        PlaceEntity = true,

        Description = "Produces Rifle Grenades",
        Description2 = "Place near Beacon to use",

        Category = "Construction"
    },
    ["pt_cart_rpg_rocket"] = {
        Name = "Rocket Autolathe",
        EntityClass = "pt_cart_rpg_rocket",
        Price = 5000,
        PlaceEntity = true,

        Description = "Produces Rockets",
        Description2 = "Place near Beacon to use",

        Category = "Construction"
    },
    ["pt_regen_boost"] = {
        Name = "Nanite Booster",
        EntityClass = "pt_regen_boost",
        Price = 15000,
        PlaceEntity = true,

        Description = "Nanomachines improve regen",
        Description2 = "Place near Beacon to use",

        Category = "Construction"
    },
    ["pt_supply_warp"] = {
        Name = "Supply Warp",
        EntityClass = "pt_supply_warp",
        Price = 12000,
        PlaceEntity = true,

        Description = "Buy supplies outside your base",
        Description2 = "Place near Beacon to use",

        Category = "Construction"
    },
    ["pt_telepad"] = {
        Name = "Telepad",
        EntityClass = "pt_telepad",
        Price = 10000,
        PlaceEntity = true,
        EntityLimit = 1,

        Description = "Pocket Teleporter destination",
        Description2 = "Must be deployed near a Beacon",

        Category = "Construction"
    },
    ["pt_launchpad"] = {
        Name = "Launchpad",
        EntityClass = "pt_launchpad",
        Price = 2000,
        PlaceEntity = true,

        Description = "Launch yourself into the air",
        Description2 = "Must be deployed near a Beacon",

        Category = "Construction"
    },
    ["pt_beacon_mobile"] = {
        Name = "Mobile Beacon",
        EntityClass = "pt_beacon_mobile",
        Price = 10000,
        EntityLimit = 1,
        PlaceEntity = true,

        Description = "Beacon effect without anchoring",
        Description2 = "Significantly smaller radius",

        Category = "Construction"
    },
    ["pt_c4"] = {
        Name = "C4",
        EntityClass = "pt_c4",
        Price = 10000,
        PlaceEntity = true,
        EntityLimit = 1,

        Description = "Long-fuse explosive charge",
        Description2 = "Extremely good against bases",

        Category = "Explosives"
    },
    ["pt_bomb_marker"] = {
        Name = "Bunker Buster",
        EntityClass = "pt_marker_bomber",
        Price = 35000,
        Cooldown = 120,

        Description = "Bomber drops anti-structure bomb",
        Description2 = "Penetrates surfaces, high damage",

        Category = "Fire Support"
    },
    ["pt_uav_light"] = {
        Name = "UAV",
        Price = 10000,
        Cooldown = 120,

        Description = "Spots NPCs only",
        Description2 = "Slow and fragile",

        Category = "Fire Support",

        OnBuy = function(self, ply)
            Profiteers:SpawnUAVLightPlane(ply)
        end
    },
    ["pt_uav"] = {
        Name = "Advanced UAV",
        Price = 50000,
        Cooldown = 180,

        Description = "Spots players, NPCs, and bases",
        Description2 = "Slow and fragile",

        Category = "Fire Support",

        OnBuy = function(self, ply)
            Profiteers:SpawnUAVPlane(ply)
        end
    },
    ["pt_gunrun"] = {
        Name = "Gun Run",
        EntityClass = "pt_gunrun_marker",
        Price = 8000,
        Cooldown = 60,

        Description = "Attack jet strafes target area",
        Description2 = "Fast anti-personnel strike",

        Category = "Fire Support",
    },
    ["pt_attacker"] = {
        Name = "CAS Bomber",
        EntityClass = "pt_rocket_marker",
        Price = 12000,
        Cooldown = 60,

        Description = "Attack jet drops a pair of bombs",
        Description2 = "Fast all-purpose strike",

        Category = "Fire Support",
    },
    ["pt_cruise_missile"] = {
        Name = "Cruise Missile",
        EntityClass = "pt_cruise_missile_marker",
        Price = 25000,
        Cooldown = 120,

        Description = "Launch a cruise missile",
        Description2 = "Hard to shoot down",

        Category = "Fire Support",
    },
    ["pt_fighter"] = {
        Name = "Fighter Patrol",
        Price = 75000,
        Cooldown = 30,

        Description = "Fighter jet eliminates air targets",
        --Description2 = "",

        Category = "Fire Support",

        OnBuy = function(self, ply)
            Profiteers:SpawnFighterPlane(ply)
        end
    },
    ["pt_pavelow"] = {
        Name = "Pave Low",
        Price = 200000,
        Cooldown = 300,

        Description = "Call in a helicopter gunship",
        Description2 = "Loiters and fires missiles",

        Category = "Fire Support",

        OnBuy = function(self, ply)
            Profiteers:SpawnPaveLowPlane(ply)
        end
    },
    ["pt_icbm"] = {
        Name = "ICBM",
        Price = 10000000,

        Description = "Intercontinental ballistic missile",
        Description2 = "Guaranteed instant victory",

        Category = "Fire Support",

        OnBuy = function(self, ply)
            Profiteers:SpawnICBMPlane(ply)
        end
    },
    ["pt_flyable_littlebird"] = {
        Name = "Little Bird",
        Price = 50000,
        EntityClass = "pt_flyable_littlebird",
        PlaceEntity = true,
        EntityLimit = 1,

        Description = "Flyable light helicopter",

        Category = "Vehicles"
    },
    ["pt_artillery"] = {
        Name = "Artillery Strike",
        EntityClass = "pt_signal_artillery",
        Price = 15000,
        Cooldown = 300,

        Description = "Signals a slow artillery barrage",
        Description2 = "Cost-effective but inaccurate",

        Category = "Fire Support",
    },
    ["pt_mortar"] = {
        Name = "Mortar Strike",
        EntityClass = "pt_signal_mortar",
        Price = 4000,
        Cooldown = 180,

        Description = "Signals a light mortar bombardment",
        Description2 = "Cheap and fast, low firepower",

        Category = "Fire Support",
    },
    ["pt_seat_jeep"] = {
        Name = "Jeep Seat",
        Price = 100,
        EntityClass = "prop_vehicle_prisoner_pod",
        PlaceEntity = true,
        EntityLimit = 1,

        Description = "Sit in it",

        Seat_Model = "models/nova/jeep_seat.mdl",
        Seat_KeyValues = {
            vehiclescript = "scripts/vehicles/prisoner_pod.txt",
            limitview = "0"
        },
        Seat_Members = nil,

        CreateEntity = function(self, ply, tr)
            local ent = ents.Create(self.EntityClass or "prop_vehicle_prisoner_pod")
            if !IsValid(ent) then return NULL end
            ent:SetModel(self.Seat_Model)

            -- Fill in the keyvalues if we have them
            for k, v in pairs(Seat_KeyValues or {}) do
                local kLower = string.lower(k)

                if kLower == "vehiclescript" or kLower == "limitview" or kLower == "vehiclelocked" or kLower == "cargovisible" or kLower == "enablegun" then
                    ent:SetKeyValue(k, v)
                end
            end

            ent:SetAngles(ply:EyeAngles())
            ent:SetPos(tr.HitPos)
            DoPropSpawnedEffect(ent)
            ent:Spawn()
            ent:Activate()
            -- Some vehicles reset this in Spawn()
            -- if ( data and data.ColGroup ) then ent:SetCollisionGroup( data.ColGroup ) end
            -- if ( ent.SetVehicleClass && VName ) then ent:SetVehicleClass( VName ) end
            -- ent.VehicleName = VName
            -- ent.VehicleTable = VTable
            -- We need to override the class in the case of the Jeep, because it
            -- actually uses a different class than is reported by GetClass
            ent.ClassOverride = self.EntityClass

            ent.TakePropDamage = true
            ent.AllowPhysgun = true

            ent:CalculatePropHealth()

            return ent
        end,

        Category = "Vehicles",
    },
}

Profiteers.BuyableEntities = {}

for k, v in pairs(Profiteers.Buyables) do
    if !v.EntityClass then continue end
    Profiteers.BuyableEntities[v.EntityClass] = k
end