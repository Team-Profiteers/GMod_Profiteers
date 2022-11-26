local Entity = FindMetaTable("Entity")

GM.PropDamageMultipliers = {
    [DMG_BLAST] = 1,
    [DMG_CLUB] = 1,
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
    local health = math.Clamp(math.ceil(volume ^ 0.5 / 50) * 50 + 100, 100, 5000)

    self:SetNWInt("PFPropHealth", health)
    self:SetNWInt("PFPropMaxHealth", health)
    print(volume, health)
end

hook.Add("EntityTakeDamage", "Profiteers_PropDamage", function(ent, dmginfo)
    if !ent:CanTakePropDamage() then return end

    if ent:GetNWInt("PFPropHealth", -1) == -1 then
        ent:CalculatePropHealth()
    end

    if ent:GetNWBool("Ghosted", false) then
        local eff = EffectData()
        eff:SetOrigin(ent:GetPos())
        eff:SetEntity(ent)
        util.Effect("entity_remove", eff)
        ent:Remove()
        return true
    end

    -- Special handling for when prop is on fire
    if dmginfo:GetInflictor():GetClass() == "entityflame" then
        local damage = 2 + ent:GetNWInt("PFPropMaxHealth") * 0.01
        ent:SetNWInt("PFPropHealth", ent:GetNWInt("PFPropHealth") - damage)
        print(ent:GetNWInt("PFPropHealth"), damage)
    end

    local mult = 0
    for k, v in pairs(GAMEMODE.PropDamageMultipliers) do
        if dmginfo:IsDamageType(k) then
            mult = math.max(mult, v)
        end
    end
    if ent:WithinBeacon() and mult == 0 then
        mult = 0.1
    end
    dmginfo:ScaleDamage(mult)
    ent:SetNWInt("PFPropHealth", ent:GetNWInt("PFPropHealth") - dmginfo:GetDamage())

    if ent:GetNWInt("PFPropHealth") <= 0 then
        local eff = EffectData()
        eff:SetOrigin(ent:GetPos())
        eff:SetEntity(ent)
        util.Effect("balloon_pop", eff)
        ent:Remove()
    end

    return true
end)