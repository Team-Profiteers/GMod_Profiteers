DEFINE_BASECLASS("gamemode_base")
AddCSLuaFile("shared.lua")
include("shared.lua")
include("sv_events.lua")
include("sh_maps.lua")
AddCSLuaFile("sh_maps.lua")

function GM:PlayerSpawn(pl, transiton)
    player_manager.SetPlayerClass(pl, "player_pf")

    pl.DeathTime2 = CurTime()
    pl:UnSpectate()
    pl:SetupHands()
    player_manager.OnPlayerSpawn(pl, transiton)
    player_manager.RunClass(pl, "Spawn")
    hook.Call("PlayerLoadout", GAMEMODE, pl)
    hook.Call("PlayerSetModel", GAMEMODE, pl)
end

function GM:PlayerLoadout(pl)
    player_manager.RunClass(pl, "Loadout")
end

function GM:PlayerDeathSound(ply)
    return true
end

function GM:GetFallDamage(ply, speed)
    return speed / 20
end

function GM:PostGamemodeLoaded()
    BaseClass.PostGamemodeLoaded(self)
    GAMEMODE:GenerateRandomWeaponLists()
end