local clr_ghost = Color(255, 180, 100, 200)
local clr_ghost2 = Color(255, 255, 255, 200)

function GM:FreezeProp(ent, bool)
    if !ent:GetPhysicsObject():IsValid() then return end
    ent:GetPhysicsObject():EnableMotion(!bool)
end

function GM:UnGhostCheck(ent)
    -- not very reliable since it doesn't rotate
    --[[]
    local tr = util.TraceEntity({
        start = ent:GetPos(),
        endpos = ent:GetPos(),
        filter = ent,
        ignoreworld = true,
    }, ent)
    if tr.Hit then return false end
    ]]
    return true
end

function GM:GhostProp(ent)
    if ent:GetNWBool("Ghosted") then return end
    ent:SetNWBool("Ghosted", true)

    ent._rmode = ent:GetRenderMode()
    ent._rfx = ent:GetRenderFX()
    ent._oldcolor = ent:GetColor()
    ent._colgroup = ent:GetCollisionGroup()
    ent._material = ent:GetMaterial()

    --ent:SetMaterial("models/shadertest/shader4")
    ent:SetRenderMode(RENDERMODE_TRANSALPHA)
    ent:SetColor(Color(50, 50, 50, 200))
    ent:SetCollisionGroup(COLLISION_GROUP_WORLD)
end

function GM:UnGhostProp(ent, physics)
    if !ent:GetNWBool("Ghosted") then return end
    ent:SetNWBool("Ghosted", false)

    --ent:SetMaterial(ent._material)
    ent:SetRenderMode(ent._rmode)
    ent:SetColor(ent._oldcolor or color_white)
    ent:SetCollisionGroup(ent._colgroup or COLLISION_GROUP_INTERACTIVE)
    ent:SetRenderFX(ent._rfx or kRenderFxNone)
end

function GM:StartUnGhost(ent)
    local t = ent:GetGhostDuration()
    ent:SetColor(ent:WithinBeacon() and clr_ghost2 or clr_ghost)
    ent:SetRenderFX(ent:WithinBeacon() and kRenderFxPulseFast or kRenderFxPulseSlow)
    ent:SetNWFloat("PFUnGhostEnd", CurTime() + t)
    timer.Remove("unghost_" .. ent:EntIndex())
    timer.Create("unghost_" .. ent:EntIndex(), t, 1, function()
        if IsValid(ent) then
            if !GAMEMODE:UnGhostCheck(ent) then
                timer.Create("unghost_repeat_" .. ent:EntIndex(), 0.5, 10, function()
                    if GAMEMODE:UnGhostCheck(ent) then
                        GAMEMODE:UnGhostProp(ent)
                    else
                        ent:SetNWFloat("PFUnGhostEnd", CurTime() + 0.5)
                    end
                end)
            else
                GAMEMODE:UnGhostProp(ent)
            end
        end
    end)
end


hook.Add("PhysgunDrop", "Profiteers", function(ply, ent)
    if !GetConVar("pt_prop_ghost"):GetBool() then return end
    GAMEMODE:FreezeProp(ent, true)
    ply:AddFrozenPhysicsObject(ent, ent:GetPhysicsObject())
    GAMEMODE:StartUnGhost(ent)
end)


hook.Add("OnPhysgunPickup", "ProfiteersOnPhysgunPickupGhostProps", function(ply, ent)
    if !GetConVar("pt_prop_ghost"):GetBool() then return end
    GAMEMODE:GhostProp(ent)
    ent:SetColor(Color(50, 50, 50, 200))
    ent:SetNWFloat("PFUnGhostEnd", -1)
    timer.Remove("unghost_" .. ent:EntIndex())
end)

hook.Add("PlayerSpawnedProp", "Profiteers", function(ply, model, ent)
    ent:CalculatePropHealth()
    ent:CPPISetOwner(ply)
    GAMEMODE:GhostProp(ent)
    GAMEMODE:FreezeProp(ent, true)
    ply:AddFrozenPhysicsObject(ent, ent:GetPhysicsObject())
    GAMEMODE:StartUnGhost(ent)
end)

hook.Add("CanPlayerUnfreeze", "Profiteers", function(ply, ent, phys)
    if !ent:CPPICanPhysgun(ply) then return false end
    if GetConVar("pt_prop_ghost"):GetBool() and ent:GetNWBool("Ghosted") then return false end
end)