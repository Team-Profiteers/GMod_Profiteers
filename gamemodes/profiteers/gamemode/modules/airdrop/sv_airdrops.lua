function Profiteers:SpawnAirdrop()
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
            local angle = math.Rand(0, 360)

            local winner = angle
            local entertrace = nil
            local winningdist = 0
            local winningenterpos = nil

            for j = 0, 359 do
                local vec = Vector(math.cos(math.rad(angle + j)), math.sin(math.rad(angle + j)), 0)

                entertrace = util.TraceLine({
                    start = tr.HitPos,
                    endpos = tr.HitPos + vec * 100000,
                    mask = MASK_NPCWORLDSTATIC,
                })

                if !entertrace.HitSky then continue end

                local exittrace = util.TraceLine({
                    start = tr.HitPos,
                    endpos = tr.HitPos + vec * -100000,
                    mask = MASK_NPCWORLDSTATIC,
                })

                if !exittrace.HitSky then continue end

                local nowdist = (entertrace.HitPos - exittrace.HitPos):Length()

                if nowdist > winningdist then
                    winner = angle + j
                    winningdist = nowdist
                    winningenterpos = entertrace.HitPos
                end
            end

            local enterpos = winningenterpos

            local ent = ents.Create("pt_airdrop_plane")

            local ang = Angle(0, winner + 180, 0)

            ent:SetPos(enterpos - Vector(0, 0, 512) + ang:Forward() * 1024)
            ent:SetAngles(ang)
            ent:Spawn()
            ent:Activate()

            return
        end
    end
end

-- spawn airdrops at random

timer.Create("ProfiteersAirdropTimer", 60, 0, function()

    if math.Rand(0, 1) > 0.8 then
        Profiteers:SpawnAirdrop()
    end

end)

concommand.Add("pt_admin_airdrop", function(ply, cmd, args, argStr)
    if IsValid(ply) and !ply:IsAdmin() then return end

    Profiteers:SpawnAirdrop()
    GAMEMODE:Hint(ply, 0, "Triggered an airdrop.")
end)