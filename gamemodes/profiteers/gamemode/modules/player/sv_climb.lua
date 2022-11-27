hook.Add("SetupMove", "ProfiteersSetupMoveClimb", function(ply, mv, cmd)
    if mv:KeyPressed(IN_JUMP) then
        if ply:IsOnGround() then return end
        if ply:GetNWFloat("pt_nextclimb", 0) > CurTime() then return end

        local tr = util.TraceHull({
            start = ply:GetPos(),
            endpos = ply:GetPos() + (ply:EyeAngles():Forward() * 16),
            mins = Vector(-16, -16, -16),
            maxs = Vector(16, 16, 16),
            filter = ply
        })

        if !tr.Hit then return end
        if tr.HitSky then return end

        // apply up and forward force

        local ang = ply:GetAngles()

        local up = ang:Up()
        local forward = ang:Forward()

        local upforce = 400
        local forwardforce = 100

        local vel = mv:GetVelocity()

        vel = vel + up * upforce
        vel = vel + forward * forwardforce

        vel.z = math.min(vel.z, 400)

        mv:SetVelocity(vel)

        ply:SetNWFloat("pt_nextclimb", CurTime() + 0.25)
    end
end)