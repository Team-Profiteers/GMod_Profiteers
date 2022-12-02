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
            ply:SetPos(tr.HitPos - Vector(0, 0, 72))
            ply:SetEyeAngles(Angle(0, math.Rand(-180, 180), 0))

            ply:SetNWBool("pt_parachute_pending", true)
            timer.Simple(0.1, function() ply:SetNWBool("pt_parachute_auto", true) end)
            return
        end
    end

    ply:SetNWBool("pt_parachute", false)

    -- Otherwise I guess just let them spawn normally
end)