hook.Add("PlayerSpawn", "ProfiteersPlayerSpawn", function(ply, trans)
    if trans then return end

    if !Profiteers.Nodes or table.Count(Profiteers.Nodes) == 0 then
        ParseNodeFile()
    end

    local montecarlotries = {}

    for i = 1, table.Count(Profiteers.Nodes) do
        table.insert(montecarlotries, i)
    end

    table.Shuffle(montecarlotries)

    for i, k in pairs(montecarlotries) do
        local pos = Profiteers.Nodes[k]

        local tr = util.TraceHull({
            start = pos + Vector(0, 0, 32),
            endpos = pos + Vector(0, 0, 1000000),
            mins = Vector(-16, -16, 0),
            maxs = Vector(16, 16, 72),
            mask = MASK_PLAYERSOLID,
        })

        if tr.HitSky then
            ply:SetPos(tr.HitPos)
            ply:SetEyeAngles(Angle(0, math.Rand(-180, 180), 0))

            ply:SetNWBool("pt_parachute_pending", true)
            --ply:SetNWBool("pt_parachute", true)

            --[[]
            local chute = ents.Create("pt_parachute")
            chute:SetOwner(ply)
            chute:Spawn()
            ]]
            return
        end
    end

    ply:SetNWBool("pt_parachute", false)

    // Otherwise I guess just let them spawn normally
end)

hook.Add("SetupMove", "ProfiteersSetupMoveParachute", function(ply, mv, cmd)

    if ply:GetNWBool("pt_parachute_pending") then

        local deploy = mv:KeyPressed(IN_JUMP)
        if !deploy then
            local tr = util.TraceLine({
                start = ply:GetPos(),
                endpos = ply:GetPos() - Vector(0, 0, 2048),
                mask = MASK_SOLID,
                filter = ply
            })
            if tr.Hit then deploy = true end
        end
        if deploy then
            ply:SetNWBool("pt_parachute_pending", false)
            ply:SetNWBool("pt_parachute", true)
            local chute = ents.Create("pt_parachute")
            chute:SetOwner(ply)
            chute:Spawn()
        end
    end

    local eyeangles = mv:GetAngles()
    local vel = mv:GetVelocity()

    if ply:GetNWBool("pt_parachute") then
        vel.z = -400

        vel = vel + eyeangles:Forward() * 100 * FrameTime()

        local desiredmoveforward = cmd:GetForwardMove()
        local desiredmoveleft = cmd:GetSideMove()

        desiredmoveforward = math.Clamp(desiredmoveforward, -50, 150)
        desiredmoveleft = math.Clamp(desiredmoveleft, -50, 50)

        vel = vel + eyeangles:Forward() * desiredmoveforward * FrameTime()
        vel = vel + eyeangles:Right() * desiredmoveleft * FrameTime()

        mv:SetVelocity(vel)
    elseif ply:GetNWBool("pt_parachute_pending") then
        vel.z = math.max(-2000, vel.z)
        vel = vel + eyeangles:Forward() * 100 * FrameTime()

        local desiredmoveforward = cmd:GetForwardMove()
        local desiredmoveleft = cmd:GetSideMove()

        desiredmoveforward = math.Clamp(desiredmoveforward, -50, 150)
        desiredmoveleft = math.Clamp(desiredmoveleft, -50, 50)

        vel = vel + eyeangles:Forward() * desiredmoveforward * FrameTime()
        vel = vel + eyeangles:Right() * desiredmoveleft * FrameTime()

        mv:SetVelocity(vel)
    end
end)

hook.Add("PlayerPostThink", "ProfiteersPostPlayerThinkParachute", function(ply)
    if ply:GetNWBool("pt_parachute") and ply:IsOnGround() then
        ply:SetNWBool("pt_parachute", false)
        ply:EmitSound("npc/combine_soldier/gear3.wav", 100, 100)
    end
    if ply:GetNWBool("pt_parachute_pending") and ply:IsOnGround() then
        ply:SetNWBool("pt_parachute_pending", false)
    end
end)