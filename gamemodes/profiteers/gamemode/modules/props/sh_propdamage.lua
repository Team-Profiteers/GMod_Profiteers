local Entity = FindMetaTable("Entity")

GM.PropDamageMultipliers = {
    [DMG_BLAST] = 1,
    [DMG_BURN] = 10,
    [DMG_CLUB] = 1,
    [DMG_SLASH] = 1,
    [DMG_AIRBOAT] = 0.5,
}

function Entity:CanTakePropDamage()
    return self:GetClass() == "prop_physics" or self.TakePropDamage
end

function Entity:CalculatePropHealth()
    local mins, maxs = self:GetCollisionBounds()
    local volume = (maxs.z - mins.z) * (maxs.y - mins.y) * (maxs.x - mins.x)
    local health = math.Clamp(math.ceil(volume ^ 0.5 / 50) * 50, 100, 5000)

    health = math.Clamp(health * math.Clamp(self:GetPhysicsObject():GetMass() / 500, 1, 3), 50, 5000)

    self:SetNWInt("PFPropHealth", health)
    self:SetNWInt("PFPropMaxHealth", health)
    self.ghostdur = nil
end

local explosionSounds = {
    "phx/explode00.wav",
    "phx/explode01.wav",
    "phx/explode02.wav",
    "phx/explode03.wav",
    "phx/explode04.wav",
    "phx/explode05.wav",
    "phx/explode06.wav",
 }

local lasteffecttick = 0
hook.Add("EntityTakeDamage", "Profiteers_PropDamage", function(ent, dmginfo)
    if !ent:CanTakePropDamage() then return end

    if ent:GetNWInt("PFPropHealth", -1) == -1 then
        ent:CalculatePropHealth()
    end

    if ent:GetNWBool("Ghosted", false) then
        local eff = EffectData()
        eff:SetOrigin(ent:GetPos())
        eff:SetEntity(ent)
        util.Effect("entity_remove", eff, true, true)

        -- Remover tool does this so...
        ent:SetNotSolid( true )
        ent:SetMoveType( MOVETYPE_NONE )
        ent:SetNoDraw( true )
        SafeRemoveEntityDelayed(ent, 1)

        return true
    end

    if dmginfo:GetInflictor():IsPlayer() and IsValid(dmginfo:GetInflictor():GetActiveWeapon()) and dmginfo:GetInflictor():GetActiveWeapon():GetClass() == "weapon_stunstick" and dmginfo:GetDamageType() == DMG_CLUB then
        -- Stunstick heals instead of hurts
        local heal = 100 + ent:GetNWInt("PFPropMaxHealth") * 0.05
        if ent:IsOnFire() then
            heal = 25 + ent:GetNWInt("PFPropMaxHealth") * 0.025
        end
        ent:SetNWInt("PFPropHealth", math.min(ent:GetNWInt("PFPropHealth") + heal, ent:GetNWInt("PFPropMaxHealth")))
        ent:EmitSound("buttons/lever7.wav", 80, 105, 0.75)
        return true
    elseif dmginfo:GetInflictor():IsPlayer() and IsValid(dmginfo:GetInflictor():GetActiveWeapon()) and dmginfo:GetInflictor():GetActiveWeapon():GetClass() == "weapon_crowbar" and dmginfo:GetDamageType() == DMG_CLUB then
        -- Crowbar does extra prop damage
        local damage = 30 + ent:GetNWInt("PFPropMaxHealth") * 0.005
        if !ent:WithinBeacon() then
            damage = 75 + ent:GetNWInt("PFPropMaxHealth") * 0.015
        end
        dmginfo:SetDamage(damage)
    elseif dmginfo:GetInflictor():GetClass() == "entityflame" then
        -- Special handling for props on fire
        local damage = 5 + ent:GetNWInt("PFPropMaxHealth") * 0.01
        ent:SetNWInt("PFPropHealth", ent:GetNWInt("PFPropHealth") - damage)
    end

    local mult = 0
    for k, v in pairs(GAMEMODE.PropDamageMultipliers) do
        if dmginfo:IsDamageType(k) then
            mult = math.max(mult, v)
        end
    end
    if mult == 0 and !ent:WithinBeacon() then
        mult = 0.25
        local eff = EffectData()
        eff:SetOrigin(dmginfo:GetDamagePosition())
        eff:SetNormal(dmginfo:GetDamageForce():GetNormalized())
        eff:SetMagnitude(1)
        eff:SetScale(2)
        eff:SetRadius(4)
        util.Effect("Sparks", eff)
    end
    dmginfo:ScaleDamage(mult)
    ent:SetNWInt("PFPropHealth", ent:GetNWInt("PFPropHealth") - dmginfo:GetDamage())

    if ent:GetNWInt("PFPropHealth") <= 0 then
        if ent.OnPropDestroyed then
            ent:OnPropDestroyed(dmginfo)
        else
            local eff = EffectData()
            eff:SetOrigin(ent:GetPos())
            eff:SetEntity(ent)
            util.Effect(ent:GetNWInt("PFPropMaxHealth") > 150 and "helicoptermegabomb" or "balloon_pop", eff)

            if lasteffecttick ~= CurTime() then
                lasteffecttick = CurTime()
                ent:EmitSound(explosionSounds[math.random(#explosionSounds)], 110)
            end
        end

        ent:Remove()
    elseif IsValid(ent:GetPhysicsObject()) and !ent:GetPhysicsObject():IsMotionEnabled() and ent:GetNWInt("PFPropHealth") <= ent:GetNWInt("PFPropMaxHealth") * 0.15 then
        -- unfreeze
        ent:GetPhysicsObject():EnableMotion(true)
        local eff = EffectData()
        eff:SetOrigin(dmginfo:GetDamagePosition())
        eff:SetNormal(dmginfo:GetDamageForce():GetNormalized())
        eff:SetMagnitude(4)
        eff:SetScale(4)
        eff:SetRadius(16)
        util.Effect("Sparks", eff)
        ent:GetPhysicsObject():Wake()
        ent:GetPhysicsObject():ApplyForceOffset(dmginfo:GetDamageForce():GetNormalized() * ent:GetPhysicsObject():GetMass() ^ 0.6 * 2000, dmginfo:GetDamagePosition())
    end

    return true
end)