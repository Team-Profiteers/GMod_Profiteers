-- Implement the CPPI interface: http://ulyssesmod.net/archive/CPPI_v1-1.pdf
CPPI = {}

local Entity = FindMetaTable("Entity")

CPPI_DEFER = "deferdeezballs"
CPPI_NOTIMPLEMENTED = "sugma"

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
    return CPPI_DEFER
end

function Entity:CPPIGetOwner()
    return self:GetNWEntity("PFPropOwner"), CPPI_NOTIMPLEMENTED
end

if SERVER then
    function Entity:CPPISetOwner(ply)
        self:SetNWEntity("PFPropOwner", ply)
    end

    function Entity:CPPISetOwnerUID(uid)
        return CPPI_NOTIMPLEMENTED
    end

    function Entity:CPPICanTool(ply, toolmode)
        return self:CPPIGetOwner() == ply or ply:IsSuperAdmin()
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
    ["dynamite"] = true
}

hook.Add("CanProperty", "PropProtection", function(ply, prop, ent)
    if CPPI.PropertyBlacklist[prop] and not ply:IsAdmin() then return false end

    if ent:CPPIGetOwner() ~= ply and not ply:IsAdmin() then return false end
end)

hook.Add("CanTool", "PropProtection", function(ply, tr, toolname, tool, button)
    if CPPI.ToolBlacklist[toolname] and not ply:IsAdmin() then return false end

    local ent = tr.Entity
    if IsValid(ent) and ent:CPPIGetOwner() ~= ply and not ply:IsAdmin() then return false end
end)