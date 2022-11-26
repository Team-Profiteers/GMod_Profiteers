local Entity = FindMetaTable("Entity")

GM.PropDamageMultipliers = {
    [DMG_BLAST] = 1,
    [DMG_CLUB] = 2,
    [DMG_SLASH] = 1,
}

function Entity:CanTakePropDamage()
    return self:GetClass() == "prop_physics" or self.TakePropDamage
end

function Entity:WithinBeacon()
    local owner = self:GetNWEntity("PFPropOwner")
    if !IsValid(owner) then return false end
    if !self.beaconcache or self.beaconcache[1] ~= CurTime() then
        self.beaconcache = {CurTime(), false}
        for _, ent in pairs(ents.FindByClass("pt_beacon")) do
            if ent:GetUser() == owner and ent:GetPos():Distance(self:GetPos()) <= 1024 then
                self.beaconcache[2] = true
                break
            end
        end
    end

    return self.beaconcache[2]
end

function Entity:CalculatePropHealth()
    local mins, maxs = self:GetCollisionBounds()
    local volume = (maxs.z - mins.z) * (maxs.y - mins.y) * (maxs.x - mins.x)
    local health = math.Clamp(math.ceil(volume ^ 0.5 / 50) * 50, 100, 5000)

    health = math.Clamp(health * math.Clamp(self:GetPhysicsObject():GetMass() / 500, 1, 3), 50, 5000)

    self:SetNWInt("PFPropHealth", health)
    self:SetNWInt("PFPropMaxHealth", health)
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

    -- Special handling for when prop is on fire
    if dmginfo:GetInflictor():GetClass() == "entityflame" then
        local damage = 2 + ent:GetNWInt("PFPropMaxHealth") * 0.01
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
        local eff = EffectData()
        eff:SetOrigin(ent:GetPos())
        eff:SetEntity(ent)
        util.Effect(ent:GetNWInt("PFPropMaxHealth") > 150 and "helicoptermegabomb" or "balloon_pop", eff)

        if lasteffecttick ~= CurTime() then
            lasteffecttick = CurTime()
            ent:EmitSound(explosionSounds[math.random(#explosionSounds)], 110)
        end

        ent:Remove()
    end

    return true
end)