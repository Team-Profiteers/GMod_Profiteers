local Entity = FindMetaTable("Entity")

function Entity:WithinBeacon()
    local owner = self:IsPlayer() and self or self:CPPIGetOwner()
    if !IsValid(owner) then return false end
    local radius = GetConVar("pt_beacon_radius"):GetFloat()
    if !self.beaconcache or self.beaconcache[1] ~= CurTime() then
        self.beaconcache = {CurTime(), false}

        for _, ent in pairs(ents.FindByClass("pt_beacon")) do
            if ent:CPPIGetOwner() == owner and ent:GetAnchored() and ent:GetPos():Distance(self:GetPos()) <= radius then
                self.beaconcache[2] = true
                break
            end
        end
        if !self.beaconcache[2] then
            radius = GetConVar("pt_beacon_mobile_radius"):GetFloat()
            for _, ent in pairs(ents.FindByClass("pt_beacon_mobile")) do
                if ent:CPPIGetOwner() == owner and ent:GetPos():Distance(self:GetPos()) <= radius then
                    self.beaconcache[2] = true
                    break
                end
            end
        end
    end

    return self.beaconcache[2]
end

function Entity:GetGhostDuration()
    if !self.ghostdur then
        self.ghostdur = math.Clamp(math.ceil(self:GetNWInt("PFPropMaxHealth", 100) ^ 0.5 / 8), 2, 10)
    end
    if !self:WithinBeacon() then
        return math.max(self.ghostdur + 10, self.ghostdur * 2)
    else
        return self.ghostdur
    end
end

hook.Add("PhysgunDrop", "Profiteers_PropTrack", function(ply, ent)
    ply.PhysgunProp = nil
end)

hook.Add("OnPhysgunPickup", "Profiteers_PropTrack", function(ply, ent)
    ply.PhysgunProp = ent
end)

hook.Add("OnEntityCreated", "Profiteers_NoEntityDuping", function(ent)
    if ent:GetClass() == "prop_physics" then return end

    ent.DisableDuplicator = true
    ent.DoNotDuplicate = true
end)