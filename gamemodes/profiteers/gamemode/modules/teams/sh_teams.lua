Profiteers.Teams = {}

local Player = FindMetaTable("Player")
local Entity = FindMetaTable("Entity")

-- Generic function to be used for all enemy/ally detection.
function Entity:CheckFriendly(ent)

    local override = hook.Run("Profiteers_CheckFriendly", self, ent)
    if override then return override end

    if ent:IsPlayer() and self:IsPlayer() then -- Player vs Player
        return ent == self -- TODO: Check teams
    elseif ent:IsPlayer() or self:IsPlayer()  then -- Player vs Entity
        local ply = ent:IsPlayer() and ent or self
        local other = ply == ent and self or ent
        local owner = other:CPPIGetOwner()
        return ply == owner -- TODO: Check owner teams
    else -- Entity vs Entity
        local owner = self:CPPIGetOwner()
        local entowner = ent:CPPIGetOwner()
        return owner == entowner
    end
end

function Player:GetPTTeam()
    return nil
end