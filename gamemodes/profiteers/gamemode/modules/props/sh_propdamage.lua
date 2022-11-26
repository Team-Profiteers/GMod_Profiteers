local Entity = FindMetaTable("Entity")

GM.PropDamageMultipliers = {
    [DMG_BLAST] = 1,
    [DMG_CLUB] = 1,
    [DMG_SLASH] = 1,
}

function Entity:CanTakePropDamage()
    return self:GetClass() == "prop_physics" or self.TakePropDamage
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

    local mult = nil
    for k, v in pairs(GAMEMODE.PropDamageMultipliers) do
        if dmginfo:IsDamageType(k) then
            mult = math.max(mult or 0, v)
        end
    end
    if !mult then return end
    print(mult, ent:GetNWInt("PFPropHealth"), dmginfo:GetDamage())

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