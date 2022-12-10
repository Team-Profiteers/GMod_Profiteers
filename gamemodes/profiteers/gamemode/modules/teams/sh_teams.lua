Profiteers.Teams = {}
local Player = FindMetaTable("Player")
local Entity = FindMetaTable("Entity")

-- Check if we are a combatant for sentry lock-on / enemy detection purposes
function Entity:IsValidCombatTarget()
    return (self:IsPlayer() and self:Alive()) or (self:IsNPC() and self:Health() > 0) or (self.IsCombatTarget and self:GetNWInt("PFPropHealth", -1) > 0)
end

function Player:SameTeam(ply)
    return IsValid(ply) and ply:IsPlayer() and (ply == self or (ply:Team() == self:Team() and self:Team() ~= TEAM_UNASSIGNED))
end

-- Generic function to be used for all enemy/ally detection.
-- This should return the same value if self and ent switches!
function Entity:IsFriendly(ent)
    if not IsValid(ent) then return false end
    local override = hook.Run("Profiteers_IsFriendly", self, ent)
    if override ~= nil then return override end
    -- Never trust an NPC.
    if (self:IsPlayer() and ent:IsNPC()) or (ent:IsNPC() and self:IsPlayer()) then return false end
    local ent1 = self
    local ent2 = ent
    local ply1 = NULL
    local ply2 = NULL
    local team1 = nil
    local team2 = nil

    if not ent1:IsPlayer() then
        ply1 = ent1:GetOwner()

        if not IsValid(ply1) then
            ply1 = ent1:CPPIGetOwner()
        end
    else
        ply1 = ent1
    end

    if not ent2:IsPlayer() then
        ply2 = ent2:GetOwner()

        if not IsValid(ply2) then
            ply2 = ent2:CPPIGetOwner()
        end
    else
        ply2 = ent2
    end

    if IsValid(ent2) and ent2:IsPlayer() then
        team2 = ent2:Team()
    end

    if ply1 == ply2 then return true end

    if team1 == TEAM_UNASSIGNED or team2 == TEAM_UNASSIGNED or team1 == nil or team2 == nil then
        return false
    else
        return team1 == team2
    end
    -- if ent:IsPlayer() and self:IsPlayer() then -- Player vs Player
    --     return self:SameTeam(ent)
    -- elseif ent:IsPlayer() or self:IsPlayer()  then -- Player vs Entity
    --     local ply = ent:IsPlayer() and ent or self
    --     local other = ply == ent and self or ent
    --     local owner = other:CPPIGetOwner()
    --     if !IsValid(owner) then owner = other:GetOwner() end
    --     return ply:SameTeam(owner)
    -- else -- Entity vs Entity
    --     local ply = self:CPPIGetOwner()
    --     local owner = ent:CPPIGetOwner()
    --     if !IsValid(ply) then ply = self:GetOwner() end
    --     if !IsValid(owner) then owner = ent:GetOwner() end
    --     return ply:SameTeam(owner)
    -- end
end

-- Check if we are considered an air asset for anti-air/air-to-air purposes
-- A weight of 0 means no new locks may be made, but existing locks will not cancel
function Entity:IsValidAirAsset(count_zero)
    return self.IsAirAsset and not self.Dead and not self.Defused and ((count_zero and (self.AirAssetWeight or 1) >= 0) or (not count_zero and (self.AirAssetWeight or 1) > 0))
end