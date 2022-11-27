hook.Add("PlayerSpawn", "ProfiteersPlayerSpawn", function(ply, trans)
    if trans then return end

    local spawns = {}
    for _, ent in pairs(ents.FindByClass("pt_spawn")) do
        if ent:CPPIGetOwner() == ply and ent:GetAnchored() and ent:WithinBeacon() then
            table.insert(spawns, ent)
        end
    end
    if #spawns > 0 then
        local spawn = spawns[math.random(#spawns)]
        ply:SetPos(spawn:GetPos() + Vector(0, 0, 12))
        ply:SetAngles(Angle(0, spawn:GetAngles().y, 0))
        local eff = EffectData()
        eff:SetOrigin(ply:GetPos())
        eff:SetNormal(ply:GetUp())
        eff:SetScale(32)
        eff:SetEntity(ply)
        util.Effect("cball_explode", eff)
        util.Effect("ThumperDust", eff)

        return
    end

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
            timer.Simple(0.1, function() ply:SetNWBool("pt_parachute_auto", true) end)
            return
        end
    end

    ply:SetNWBool("pt_parachute", false)

    // Otherwise I guess just let them spawn normally
end)

hook.Add("SetupMove", "ProfiteersSetupMoveParachute", function(ply, mv, cmd)

    if ply:GetNWBool("pt_parachute_pending") and !ply:GetNWBool("pt_parachute") then

        local deploy = mv:KeyPressed(IN_JUMP)
        if !deploy and ply:GetNWBool("pt_parachute_auto") then
            local tr = util.TraceLine({
                start = ply:GetPos(),
                endpos = ply:GetPos() - Vector(0, 0, 2048),
                mask = MASK_SOLID,
                filter = ply
            })
            if tr.Hit then
                deploy = true
                ply:EmitSound("buttons/blip1.wav", 80, 115)
                ply:SetNWBool("pt_parachute_auto", false)
            end
        end
        if deploy then

            local tr = util.TraceHull({
                start = ply:GetPos(),
                endpos = ply:GetPos() + (ply:EyeAngles():Forward() * 16),
                mins = Vector(-16, -16, -16),
                maxs = Vector(16, 16, 16),
                filter = ply
            })

            if tr.Hit and !tr.HitSky then return end

            ply:SetNWBool("pt_parachute", true)
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
    local usingspidermangun = ply:GetActiveWeapon():IsValid() and ply:GetActiveWeapon():GetClass() == "spiderman's_swep"

    if usingspidermangun then
        ply:SetNWBool("pt_parachute", false)
        ply:SetNWBool("pt_parachute_pending", false)
        ply:SetNWBool("pt_parachute_auto", false)
    end

    if ply:GetNWBool("pt_parachute") and (ply:IsOnGround()) then
        ply:SetNWBool("pt_parachute", false)
        ply:SetNWBool("pt_parachute_auto", false)
        ply:EmitSound("npc/combine_soldier/gear3.wav", 100, 100)
        ply:EmitSound("profiteers/para_close.wav", 110)
    end
    if ply:GetNWBool("pt_parachute_pending") and ply:IsOnGround() then
        ply:SetNWBool("pt_parachute_pending", false)
        ply:SetNWBool("pt_parachute_auto", false)
    end

    if !ply:GetNWBool("pt_parachute_pending") and !ply:IsOnGround() then
        if ply:GetVelocity().z < -300 then
            ply:SetNWBool("pt_parachute_pending", true)
        end
    end
end)