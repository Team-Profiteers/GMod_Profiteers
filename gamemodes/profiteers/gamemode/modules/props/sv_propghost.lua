function GM:GhostProp(ent)
    if ent:GetNWBool("Ghosted") then return end
    ent:SetNWBool("Ghosted", true)

    ent._rmode = ent:GetRenderMode()
    ent._oldcolor = ent:GetColor()
    ent._colgroup = ent:GetCollisionGroup()
    ent._material = ent:GetMaterial()

    ent:SetMaterial("models/shadertest/shader4")
    ent:SetRenderMode(RENDERMODE_TRANSALPHA)
    ent:SetColor(Color(255, 255, 255, 255))
    ent:SetCollisionGroup(COLLISION_GROUP_WORLD)
end

function GM:UnGhostProp(ent, physics)
    if !ent:GetNWBool("Ghosted") then return end
    ent:SetNWBool("Ghosted", false)

    ent:SetMaterial(ent._material)
    ent:SetRenderMode(ent._rmode)
    ent:SetColor(ent._oldcolor or color_white)
    ent:SetCollisionGroup(ent._colgroup or COLLISION_GROUP_INTERACTIVE)
end

function GM:FreezeProp(ent, bool)
    if !ent:GetPhysicsObject():IsValid() then return end
    ent:GetPhysicsObject():EnableMotion(!bool)
end

-- Doesn't really work?
function GM:UnGhostCheck(ent)
    local tr = util.TraceEntity({
        start = ent:GetPos(),
        endpos = ent:GetPos(),
        filter = ent,
    }, ent)
    if tr.Hit then return false end
    return true
end

hook.Add("PhysgunDrop", "Profiteers", function(ply, ent)
    if !GetConVar("pt_prop_ghost"):GetBool() then return end
    GAMEMODE:FreezeProp(ent, true)
    ent.NextUnGhost = CurTime() + 2.5
    timer.Create("unghost_" .. ent:EntIndex(), 2.5, 1, function()
        if IsValid(ent) then
            GAMEMODE:UnGhostProp(ent)
            --[[]
            if GAMEMODE:UnGhostCheck(ent) then
                timer.Create("unghost_repeat_" .. ent:EntIndex(), 0.5, 6, function()
                    if GAMEMODE:UnGhostCheck(ent) then
                        GAMEMODE:UnGhostProp(ent)
                    end
                end)
            else
                GAMEMODE:UnGhostProp(ent)
            end
            ]]
        end
    end)
end)

hook.Add("PhysgunPickup", "Profiteers", function(ply, ent)
    if !GetConVar("pt_prop_ghost"):GetBool() then return end
    GAMEMODE:GhostProp(ent)
end)

hook.Add("PlayerSpawnedProp", "Profiteers", function(ply, model, ent)
    GAMEMODE:GhostProp(ent)
    GAMEMODE:FreezeProp(ent, true)
    ent.NextUnGhost = CurTime() + 2.5
    ent:CalculatePropHealth()
    timer.Create("unghost_" .. ent:EntIndex(), 2.5, 1, function()
        if IsValid(ent) then
            GAMEMODE:UnGhostProp(ent)
        end
    end)
end)

hook.Add("CanPlayerUnfreeze", "Profiteers", function(ply, ent, phys)
    if GetConVar("pt_prop_ghost"):GetBool() and ent:GetNWBool("Ghosted") then return false end
end)