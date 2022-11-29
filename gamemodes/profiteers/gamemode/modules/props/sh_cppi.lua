-- Implement the CPPI interface: http://ulyssesmod.net/archive/CPPI_v1-1.pdf
CPPI = {}

local Entity = FindMetaTable("Entity")

CPPI_DEFER = "deferdeezballs"
CPPI_NOTIMPLEMENTED = "sugma"

CPPI.UIDToName = {}

-- For each UID, a list of entities they may potentially own
-- Entities are not removed from the list if ownership changes, so double checking is necessary
CPPI.UIDEntities = {}

function CPPI.GetName()
    return "Profiteers Prop Protection"
end

function CPPI.GetVersion()
    return "v0.1"
end

function CPPI.GetInterfaceVersion()
    return 1.1
end

function CPPI.GetNameFromUID(uid)
    return CPPI.UIDToName[uid]
end

function Entity:CPPIGetOwner()
    return self:GetNWEntity("PFPropOwner"), self:GetNWString("PFPropOwnerID")
end

function Entity:CPPIGetOwnerName()
    local owner, uid = self:CPPIGetOwner()
    if IsValid(owner) then
        return owner:GetName()
    else
        return uid or "nobody"
    end
end

if SERVER then
    function Entity:CPPISetOwner(ply)
        local id = ply:UniqueID()

        self:SetNWEntity("PFPropOwner", ply)
        self:SetNWString("PFPropOwnerID", id)
        CPPI.UIDToName[id] = ply:GetName()
        CPPI.UIDEntities[id] = CPPI.UIDEntities[id] or {}
        table.insert(CPPI.UIDEntities[id], self)
    end

    function Entity:CPPISetOwnerUID(uid)
        self:SetNWString("PFPropOwnerID", uid)
    end

    function Entity:CPPICanTool(ply, toolname)
        if self:CPPIGetOwner() ~= ply and not ply:IsAdmin() then return false end

        if self:GetClass() ~= "prop_physics" and CPPI.EntityToolBlacklist[toolname] then return false end

        return true
    end

    function Entity:CPPICanPhysgun(ply)
        return (self:CPPIGetOwner() == ply or ply:IsSuperAdmin()) and (self:GetClass() == "prop_physics" or self.AllowPhysgun)
    end

    function Entity:CPPICanPickup(ply)
        return true
    end

    function Entity:CPPICanPunt(ply)
        return true
    end
end

CPPI.PropertyBlacklist = {
}

CPPI.ToolBlacklist = {
    ["dynamite"] = true,
    ["duplicator"] = true, -- need to figure out a way to prevent duping entities
    ["colour"] = true, -- can make invisible
}
CPPI.EntityToolBlacklist = {
    ["remover"] = true,
    ["material"] = true,
}

hook.Add("CanProperty", "PropProtection", function(ply, prop, ent)
    if CPPI.PropertyBlacklist[prop] and not ply:IsAdmin() then return false end

    if ent:CPPIGetOwner() ~= ply and not ply:IsAdmin() then return false end

    if ent:GetClass() ~= "prop_physics" and not ply:IsAdmin() then return false end
end)

hook.Add("CanTool", "PropProtection", function(ply, tr, toolname, tool, button)
    if CPPI.ToolBlacklist[toolname] and not ply:IsAdmin() then return false end
    if not IsValid(tr.Entity) then return end

    if tr.Entity:CPPIGetOwner() ~= ply and not ply:IsAdmin() then return false end
    if tr.Entity:GetClass() ~= "prop_physics" and CPPI.EntityToolBlacklist[toolname] then return false end
end)

hook.Add("CanDrive", "PropProtection", function(ply, ent)
    return false
end)

hook.Add("PlayerAuthed", "PropProtection", function(ply, steamid, uniqueid)
    local id = uniqueid
    if CPPI.UIDEntities[id] then
        -- Give back ownership of previous entities
        for _, ent in pairs(CPPI.UIDEntities[id]) do
            local _, entid = ent:CPPIGetOwner()
            if entid == id then
                ent:CPPISetOwner(ply)
            end
        end
        ply:RecalcPropQuota()
    end
end)