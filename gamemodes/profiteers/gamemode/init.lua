DEFINE_BASECLASS("gamemode_base")
AddCSLuaFile("shared.lua")
include("shared.lua")

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
    if IsValid(ply:GetGroundEntity()) and ply:GetGroundEntity():IsValidCombatTarget() then
        ply:SetVelocity(Vector(0, 0, speed))
        if !ply:IsFriendly(ply:GetGroundEntity()) then
            local dmg = DamageInfo()
            dmg:SetDamage(math.min(speed / 5, 1000))
            dmg:SetDamageType(DMG_CRUSH + DMG_NEVERGIB)
            dmg:SetDamageForce(Vector(0, 0, math.min(speed / 10, 1000) * -5))
            dmg:SetDamagePosition(ply:GetPos())
            ply:GetGroundEntity():TakeDamageInfo(dmg)
            ply:EmitSound("profiteers/mario_coin.wav", 80, 100, 0.5)
            ply:GetGroundEntity().GoombaStomp = CurTime()
        end
        return 0
    end
    return speed / 20
end

hook.Add("PostEntityTakeDamage", "Profiteers_GoombaStomp", function(ent, dmginfo, took)
    if took and ent.GoombaStomp == CurTime() and dmginfo:GetDamageType() == DMG_CRUSH + DMG_NEVERGIB and ent:Health() < 0 then
        ent:EmitSound("profiteers/mario_death.wav", 80, 100, 0.5)
    end
end)