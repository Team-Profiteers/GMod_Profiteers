local Player = FindMetaTable("Player")

function Player:GetPropQuota()
    return self:GetNWInt("PFPropQuota", 0)
end

function Player:SetPropQuota(i)
    self:SetNWInt("PFPropQuota", i)
end

function Player:GetMaxPropQuota()
    return GetConVar("pt_prop_quota"):GetInt()
end

function Player:RecalcPropQuota()
    if GetConVar("pt_prop_quota_disable"):GetBool() then return 0 end
    local quota = 0
    for _, ent in pairs(ents.FindByClass("prop_physics")) do
        if ent:CPPIGetOwner() == self then
            if ent:GetNWInt("PFPropMaxHealth", -1) == -1 then
                ent:CalculatePropHealth()
            end

            quota = quota + ent:GetNWInt("PFPropMaxHealth", 0)
        end
    end
    self:SetNWInt("PFPropQuota", quota)
    return quota
end

function Player:TrackPropQuota(ent)
    if ent:GetNWInt("PFPropMaxHealth", -1) == -1 then
        ent:CalculatePropHealth()
    end
    ent._trackedmaxhealth = ent:GetNWInt("PFPropMaxHealth", 0)
    self:SetPropQuota(self:GetPropQuota() + ent._trackedmaxhealth)
    GAMEMODE:HintOneTime(self, 0, "Spawning props fill up your quota depending on its health. If you fill your quota, you can't spawn any more.")

end

function Player:UnTrackPropQuota(ent)
    if not ent._trackedmaxhealth then
        self:RecalcPropQuota() -- something went wrong. Best to be absolutely sure!
        return
    end
    self:SetPropQuota(self:GetPropQuota() - ent._trackedmaxhealth)
end

hook.Add("EntityRemoved", "PropQuota", function(ent)
    if GetConVar("pt_prop_quota_disable"):GetBool() then return end
    if ent:GetClass() == "prop_physics" and IsValid(ent:CPPIGetOwner()) then
        ent:CPPIGetOwner():UnTrackPropQuota(ent)
    end
end)

hook.Add("PlayerSpawnProp", "PropQuota", function(ply, model)
    if GetConVar("pt_prop_quota_disable"):GetBool() then return end
    if ply:GetMaxPropQuota() > 0 and ply:GetPropQuota() >= ply:GetMaxPropQuota() then
        GAMEMODE:Hint(ply, 1, "You hit your prop quota! Remove some props and try again.")
        return false
    end
end)

hook.Add("PlayerSpawnedProp", "PropQuota", function(ply, model, ent)
    if GetConVar("pt_prop_quota_disable"):GetBool() then return end
    ply:TrackPropQuota(ent)
end)