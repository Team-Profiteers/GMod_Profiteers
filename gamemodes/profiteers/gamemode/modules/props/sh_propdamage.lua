local Entity = FindMetaTable("Entity")

GM.PropDamageMultipliers = {
    [DMG_BLAST] = 1,
    [DMG_CLUB] = 2,
    [DMG_SLASH] = 1,
}

function Entity:CanTakePropDamage()
    return self:GetClass() == "prop_physics" or self.TakePropDamage
end

function Entity:CalculatePropHealth()
    // local mins, maxs = self:GetCollisionBounds()
    // local volume = (maxs.z - mins.z) * (maxs.y - mins.y) * (maxs.x - mins.x)
    // local health = math.Clamp(math.ceil(volume ^ 0.5 / 50) * 50 + 100, 100, 5000)
    local health = 500
    local phys = self:GetPhysicsObject()

    health = health * phys:GetMass() / 100

    self:SetNWInt("PFPropHealth", health)
    self:SetNWInt("PFPropMaxHealth", health)

    print(health)
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
    dmginfo:ScaleDamage(mult)
    ent:SetNWInt("PFPropHealth", ent:GetNWInt("PFPropHealth") - dmginfo:GetDamage())

    if ent:GetNWInt("PFPropHealth") <= 0 then
        local eff = EffectData()
        eff:SetOrigin(ent:GetPos())
        eff:SetEntity(ent)
        util.Effect("helicoptermegabomb", eff)

        ent:EmitSound(explosionSounds[math.random(#explosionSounds)], 110)
        ent:Remove()
    end

    return true
end)