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
            timer.Simple(0.1, function() ply:SetNWBool("pt_parachute_first", true) end)
            return
        end
    end

    ply:SetNWBool("pt_parachute", false)

    // Otherwise I guess just let them spawn normally
end)

hook.Add("SetupMove", "ProfiteersSetupMoveParachute", function(ply, mv, cmd)

    if ply:GetNWBool("pt_parachute_pending") and !ply:GetNWBool("pt_parachute") then

        local deploy = mv:KeyPressed(IN_JUMP)
        if !deploy and ply:GetNWBool("pt_parachute_first") then
            local tr = util.TraceLine({
                start = ply:GetPos(),
                endpos = ply:GetPos() - Vector(0, 0, 2048),
                mask = MASK_SOLID,
                filter = ply
            })
            if tr.Hit then deploy = true end
        end
        if deploy then
            ply:SetNWBool("pt_parachute", true)
            ply:SetNWBool("pt_parachute_first", false)
            local chute = ents.Create("pt_parachute")
            chute:SetOwner(ply)
            chute:Spawn()
            ply:EmitSound("profiteers/para_open.wav", 110)
        end
    elseif ply:GetNWBool("pt_parachute_pending") and ply:GetNWBool("pt_parachute") and mv:KeyPressed(IN_JUMP) then
        ply:SetNWBool("pt_parachute", false)
        ply:EmitSound("profiteers/para_close.wav", 110)
    end

    local eyeangles = mv:GetAngles()
    local vel = mv:GetVelocity()

    if ply:GetNWBool("pt_parachute") then
        vel.z = math.Approach(vel.z, -300, -FrameTime() * 1500)

        vel = vel + eyeangles:Forward() * 100 * FrameTime()

        local desiredmoveforward = cmd:GetForwardMove()
        local desiredmoveleft = cmd:GetSideMove()

        desiredmoveforward = math.Clamp(desiredmoveforward, -50, 150)
        desiredmoveleft = math.Clamp(desiredmoveleft, -50, 50)

        vel = vel + eyeangles:Forward() * desiredmoveforward * FrameTime()
        vel = vel + eyeangles:Right() * desiredmoveleft * FrameTime()

        mv:SetVelocity(vel)
    elseif ply:GetNWBool("pt_parachute_pending") then
        vel.z = math.max(-1500, vel.z)
        -- if vel:Cross(eyeangles:Forward()):Length() <= 1500 then
        --     vel = vel + eyeangles:Forward() * 500 * FrameTime()
        -- end

        local desiredmoveforward = cmd:GetForwardMove()
        local desiredmoveleft = cmd:GetSideMove()

        desiredmoveforward = math.Clamp(desiredmoveforward, -100, 300)
        desiredmoveleft = math.Clamp(desiredmoveleft, -100, 100)

        vel = vel + eyeangles:Forward() * desiredmoveforward * FrameTime()
        vel = vel + eyeangles:Right() * desiredmoveleft * FrameTime()

        mv:SetVelocity(vel)
    end
end)

hook.Add("PlayerPostThink", "ProfiteersPostPlayerThinkParachute", function(ply)
    if ply:GetNWBool("pt_parachute") and ply:IsOnGround() then
        ply:SetNWBool("pt_parachute", false)
        ply:SetNWBool("pt_parachute_first", false)
        ply:EmitSound("npc/combine_soldier/gear3.wav", 100, 100)
        ply:EmitSound("profiteers/para_close.wav", 110)
    end
    if ply:GetNWBool("pt_parachute_pending") and ply:IsOnGround() then
        ply:SetNWBool("pt_parachute_pending", false)
        ply:SetNWBool("pt_parachute_first", false)
    end
end)