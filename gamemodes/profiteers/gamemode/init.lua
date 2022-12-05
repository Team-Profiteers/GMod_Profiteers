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
        ply:SetVelocity(Vector(0, 0, math.max(500, speed)))
        if !ply:IsFriendly(ply:GetGroundEntity()) then
            ply:GetGroundEntity().GoombaStomped = true
            local dmg = DamageInfo()
            dmg:SetAttacker(ply)
            dmg:SetInflictor(ply)
            dmg:SetDamage(999)
            dmg:SetDamageType(DMG_CRUSH + DMG_NEVERGIB)
            dmg:SetDamageForce(Vector(0, 0, math.min(speed / 10, 500)))
            dmg:SetDamagePosition(ply:GetPos())
            ply:GetGroundEntity():TakeDamageInfo(dmg)
            ply:EmitSound("profiteers/mario_coin.wav", 80, 100, 0.2)
            ply:AddMoney(1)
        end
        return 0
    end
    return speed / 20
end

hook.Add("PostEntityTakeDamage", "Profiteers_GoombaStomp", function(ent, dmginfo, took)
    if took and ent.GoombaStomped == true and dmginfo:GetDamageType() == DMG_CRUSH + DMG_NEVERGIB then
        if ent:Health() < 0 then
            ent:EmitSound("profiteers/mario_death.wav", 100, 100, 0.3)
        end
        ent.GoombaStomped = false
    end
end)