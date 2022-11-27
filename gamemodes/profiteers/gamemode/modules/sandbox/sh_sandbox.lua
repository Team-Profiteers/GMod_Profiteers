Profiteers.EntityBlacklist = {["arccw_uo_m67"] = true }

function Profiteers:IsSpawnableWeapon(class)

    if Profiteers.EntityBlacklist[class] then return false end
    if Profiteers.BuyableEntities[class] then return false end

    if not (weapons.IsBasedOn(class, "arccw_base") or
        weapons.IsBasedOn(class, "bobs_gun_base") or
        weapons.IsBasedOn(class, "bobs_scoped_base") or
        weapons.IsBasedOn(class, "bobs_shotty_base") or
        weapons.IsBasedOn(class, "arccw_base_melee") or
        weapons.IsBasedOn(class, "arccw_base_nade") or
        weapons.IsBasedOn(class, "arccw_uo_grenade_base") or
        weapons.IsBasedOn(class, "arc9_base")) then
        return false
    end

    return true
end

function Profiteers:HasArsenal(ply)
    if GetConVar("pt_money_guncost"):GetInt() == 0 then return true end
    for _, ent in pairs(ents.FindByClass("pt_arsenal")) do
        if ent:CPPIGetOwner() == ply and ent:WithinBeacon() then
            return true
        end
    end
    return false
end

Profiteers.DenySpawningCats = {
    ["dynamite"] = true,
    ["sents"] = true,
    ["item_ammo_crates"] = true,
    ["item_item_crates"] = true,
    ["vehicles"] = true,
    ["ragdolls"] = true,
    ["npcs"] = true,
}

hook.Add("PlayerCheckLimit", "ArcCWTDM_PlayerCheckLimit", function(ply, name, cur, max)
    -- This disables spawning or using anything else
    if Profiteers.DenySpawningCats[name] and not ply:IsAdmin() then return false end
end)

hook.Add("PlayerGiveSWEP", "BlockPlayerSWEPs", function(ply, class, swep)
    if not ply:IsAdmin() and (not Profiteers:IsSpawnableWeapon(class)) then return false end
end)

-- This overwrites the sandbox concommand (hopefully)
CCGiveSWEP = function(ply, command, arguments)
    -- We don't support this command from dedicated server console
    if not IsValid(ply) then return end
    if arguments[1] == nil then return end
    if not ply:Alive() then return end
    -- Make sure this is a SWEP
    local swep = list.Get("Weapon")[arguments[1]]
    if swep == nil then return end

    if ply:HasWeapon(swep.ClassName) then
        ply:SelectWeapon(swep.ClassName)
        return
    end

    -- You're not allowed to spawn this!
    local isAdmin = ply:IsAdmin() or game.SinglePlayer()
    if (not swep.Spawnable and not isAdmin) or (swep.AdminOnly and not isAdmin) then return end
    if not ply:IsAdmin() and (not Profiteers:IsSpawnableWeapon(arguments[1])) then return false end
    if not gamemode.Call("PlayerGiveSWEP", ply, arguments[1], swep) then return end

    local cost = GetConVar("pt_money_guncost"):GetInt()
    if not Profiteers:HasArsenal(ply) then
        if not ply.ArsenalWarning then
            ply.ArsenalWarning = true
            GAMEMODE:Hint(ply, 1, 15, "Spawning weapons will cost $" .. cost .. " because you do not have an active Arsenal. Spawn again to dismiss this hint.")
            ply:EmitSound("friends/message.wav", 55)
            return
        end
        if ply:GetMoney() <= cost then
            ply:EmitSound("common/wpn_denyselect.wav", 55)
            GAMEMODE:Hint(ply, 3, "You can't afford to spawn a weapon ($" .. cost .. ").")
            return
        end
        ply:AddMoney(-cost)
    else
        ply.ArsenalWarning = false
    end

    MsgAll("Giving " .. ply:Nick() .. " a " .. swep.ClassName .. "\n")
    ply:Give(swep.ClassName)

    -- And switch to it
    ply:SelectWeapon(swep.ClassName)
end
concommand.Add( "gm_giveswep", CCGiveSWEP )
function Spawn_Weapon(ply, wepname, tr)
    -- We don't support this command from dedicated server console
    if not IsValid(ply) then return end
    if wepname == nil then return end
    local swep = list.Get("Weapon")[wepname]
    -- Make sure this is a SWEP
    if swep == nil then return end
    -- You're not allowed to spawn this!
    local isAdmin = ply:IsAdmin() or game.SinglePlayer()
    if (not swep.Spawnable and not isAdmin) or (swep.AdminOnly and not isAdmin) then return end
    if not gamemode.Call("PlayerSpawnSWEP", ply, wepname, swep) then return end

    if not tr then
        tr = ply:GetEyeTraceNoCursor()
    end
    if not tr.Hit then return end

    local entity = ents.Create(swep.ClassName)
    if not IsValid(entity) then return end

    local cost = GetConVar("pt_money_guncost"):GetInt()
    if not Profiteers:HasArsenal(ply) then
        if not ply.ArsenalWarning then
            ply.ArsenalWarning = true
            GAMEMODE:Hint(ply, 1, 15, "Spawning weapons will cost $" .. cost .. " because you do not have an active Arsenal. Spawn again to dismiss this hint.")
            ply:EmitSound("friends/message.wav", 55)
            entity:Remove()
            return
        end
        if ply:GetMoney() <= cost then
            ply:EmitSound("common/wpn_denyselect.wav", 55)
            GAMEMODE:Hint(ply, 3, "You can't afford to spawn a weapon ($" .. cost .. ").")
            entity:Remove()
            return
        end
        ply:AddMoney(-cost)
    else
        ply.ArsenalWarning = false
    end


    DoPropSpawnedEffect(entity)
    local SpawnPos = tr.HitPos + tr.HitNormal * 32

    -- Make sure the spawn position is not out of bounds
    local oobTr = util.TraceLine({
        start = tr.HitPos,
        endpos = SpawnPos,
        mask = MASK_SOLID_BRUSHONLY
    })

    if oobTr.Hit then
        SpawnPos = oobTr.HitPos + oobTr.HitNormal * (tr.HitPos:Distance(oobTr.HitPos) / 2)
    end

    entity:SetPos(SpawnPos)
    entity:Spawn()

    -- Throw it into SENTs category
    ply:AddCleanup("sents", entity)

    TryFixPropPosition(ply, entity, tr.HitPos)

    gamemode.Call("PlayerSpawnedSWEP", ply, entity)
end

concommand.Add("gm_spawnswep", function(ply, cmd, args)
    Spawn_Weapon(ply, args[1])
end)


function GM:PlayerNoClip(pl, on)
    -- Admin check this
    if not on then return true end
    -- Allow noclip if we're in single player and living

    return IsValid(pl) and pl:Alive() and pl:IsAdmin()
end