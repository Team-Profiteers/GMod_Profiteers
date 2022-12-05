Profiteers.Markers = {
    ["mortar"] = {
        name = "Mortar Strike",
        mat = Material("profiteers/markers/mortar.png", "smooth mips"),
    },
    ["cruise_missile"] = {
        name = "Cruise Missile",
        mat = Material("profiteers/markers/cruise_missile.png", "smooth mips"),
    },
    ["pave_low"] = {
        name = "Cruise Missile",
        mat = Material("profiteers/markers/pave_low.png", "smooth mips"),
    },
    ["bunker_buster"] = {
        name = "Bunker Buster",
        mat = Material("profiteers/markers/bunker_buster.png", "smooth mips"),
    },
    ["fighter"] = {
        name = "Fighter Patrol",
        mat = Material("profiteers/markers/fighter.png", "smooth mips"),
    },
}

-- Fewer than 512 markers should exist at one time
-- id = 0 is reserved and no marker should have that id
Profiteers.ActiveMarkers = {
    --[[
    [id] = {
        marker = String, -- correspond to an entry in Profiteers.Markers
        owner = Player,
        pos = Vector / nil, -- if exists, place icon at 3d position, otherwise show on hud
        ent = Entity / nil, -- if exists, place icon at ent's position; otherwise use pos
        timeout = float / nil, -- if exists, remove from client after time exceeds this
    }
    ]]
}