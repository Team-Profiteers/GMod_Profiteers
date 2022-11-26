function GM:GhostProp(ent)
    if ent.GHOSTED then return end
    ent.GHOSTED = true

    ent._rmode = ent:GetRenderMode()
    ent._oldcolor = ent:GetColor()
    ent._colgroup = ent:GetCollisionGroup()

    ent:SetRenderMode(RENDERMODE_TRANSADD)
    ent:SetColor(Color(255, 255, 255, 100))
    ent:SetCollisionGroup(COLLISION_GROUP_INTERACTIVE_DEBRIS)
    ent:SetMoveType(MOVETYPE_NOCLIP)
end

function GM:UnGhostProp(ent, physics)
    if !ent.GHOSTED then return end
    ent.GHOSTED = false

    ent:SetRenderMode(ent._rmode)
    ent:SetColor(ent._oldcolor or color_white)
    ent:SetCollisionGroup(ent._colgroup or COLLISION_GROUP_NONE)

    if physics then
        ent:SetMoveType(MOVETYPE_VPHYSICS)
    end
end

hook.Add("PhysgunDrop", "Profiteers", function(ply, ent)
    ent.NextUnGhost = CurTime() + 10
    timer.Create("unghost_" .. ent:EntIndex(), 10, 1, function()
        if IsValid(ent) and ent.NextUnGhost <= CurTime() then
            GAMEMODE:UnGhostProp(ent)
        end
    end)
end)

hook.Add("PhysgunPickup", "Profiteers", function(ply, ent)
    GAMEMODE:GhostProp(ent)
end)