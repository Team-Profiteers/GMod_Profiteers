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

hook.Add("PlayerGiveSWEP", "SWEPBuy", function(ply, class, swep)
    if not ply:IsAdmin() and (not Profiteers:IsSpawnableWeapon(class)) then return false end

    local cost = GetConVar("pt_money_guncost"):GetInt()
    if not ply:HasWeapon(class) and not Profiteers:HasArsenal(ply) then
        if not ply.ArsenalWarning then
            ply.ArsenalWarning = true
            GAMEMODE:Hint(ply, 1, 15, "Spawning weapons will cost $" .. cost .. " because you do not have an active Arsenal. Spawn again to dismiss this hint.")
            ply:EmitSound("friends/message.wav", 55)
            return false
        end
        if ply:GetMoney() <= cost then
            ply:EmitSound("common/wpn_denyselect.wav", 55)
            GAMEMODE:Hint(ply, 3, "You can't afford to spawn a weapon ($" .. cost .. ").")
            return false
        end
        -- Give our best attempt at ensuring the player got the weapon before charging them (we don't have a post hook)
        timer.Simple(0, function()
            if ply:HasWeapon(class) then ply:AddMoney(-cost) end
        end)
    elseif Profiteers:HasArsenal(ply) then
        ply.ArsenalWarning = false
    end
end)

hook.Add("PlayerSpawnSWEP", "SWEPBuy", function(ply, class, swep)
    if not ply:IsAdmin() and (not Profiteers:IsSpawnableWeapon(class)) then return false end

    local cost = GetConVar("pt_money_guncost"):GetInt()
    if not Profiteers:HasArsenal(ply) then
        if not ply.ArsenalWarning then
            ply.ArsenalWarning = true
            GAMEMODE:Hint(ply, 1, 15, "Spawning weapons will cost $" .. cost .. " because you do not have an active Arsenal. Spawn again to dismiss this hint.")
            ply:EmitSound("friends/message.wav", 55)
            return false
        end
        if ply:GetMoney() <= cost then
            ply:EmitSound("common/wpn_denyselect.wav", 55)
            GAMEMODE:Hint(ply, 3, "You can't afford to spawn a weapon ($" .. cost .. ").")
            return false
        end
        -- Don't have to assume because we have a post hook
    elseif Profiteers:HasArsenal(ply) then
        ply.ArsenalWarning = false
    end
end)

hook.Add("PlayerSpawnedSWEP", "SWEPBuy", function(ply, ent)
    local cost = GetConVar("pt_money_guncost"):GetInt()
    if not Profiteers:HasArsenal(ply) then
        ply:AddMoney(-cost)
    end
end)

function GM:PlayerNoClip(pl, on)
    -- Admin check this
    if not on then return true end
    -- Allow noclip if we're in single player and living

    return IsValid(pl) and pl:Alive() and pl:IsAdmin()
end