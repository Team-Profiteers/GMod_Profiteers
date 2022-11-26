local Entity = FindMetaTable("Entity")


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

hook.Add("PhysgunPickup", "Profiteers_PropTrack", function(ply, ent)
    ply.PhysgunProp = ent
end)