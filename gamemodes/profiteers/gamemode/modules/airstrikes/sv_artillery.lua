function Profiteers:SpawnArtillery(pos, ply)
    local tr = util.TraceHull({
        start = pos + Vector(0, 0, 32),
        endpos = pos + Vector(0, 0, 1000000),
        mins = Vector(-16, -16, 0),
        maxs = Vector(16, 16, 72),
        mask = MASK_NPCWORLDSTATIC,
    })
    if tr.HitSky then
        for i = 1, 10 do
            timer.Simple(i * 5 + math.Rand(0, 3), function()
                local spread = 256 + ((10 - i) / 10) * 512
                local shell = ents.Create("pt_shell_artillery")
                shell:SetPos(tr.HitPos + Vector(math.Rand(-spread, spread), math.Rand(-spread, spread), -32))
                shell:SetAngles(Angle(90, 0, 0))
                shell:SetOwner(ply)
                shell:Spawn()
                shell:Activate()
                shell:GetPhysicsObject():SetVelocity(Vector(0, 0, -9000000))
            end)
        end

        local id = Profiteers:CreateMarker("artillery", ply, pos, nil, 60)
        Profiteers:SendMarker(id, ply)
    else
        ply:AddMoney(Profiteers.Buyables.pt_artillery.Price)
        return
    end
end

function Profiteers:SpawnMortar(pos, ply)
    local tr = util.TraceHull({
        start = pos + Vector(0, 0, 32),
        endpos = pos + Vector(0, 0, 1000000),
        mins = Vector(-16, -16, 0),
        maxs = Vector(16, 16, 72),
        mask = MASK_NPCWORLDSTATIC,
    })
    if tr.HitSky then
        for i = 1, 5 do
            timer.Simple(i * 3 + math.Rand(0, 1), function()
                local spread = (i / 5) * 512
                local shell = ents.Create("pt_shell_mortar")
                shell:SetPos(tr.HitPos + Vector(math.Rand(-spread, spread), math.Rand(-spread, spread), -32))
                shell:SetAngles(Angle(90, 0, 0))
                shell:SetOwner(ply)
                shell:Spawn()
                shell:Activate()
                shell:GetPhysicsObject():SetVelocity(Vector(0, 0, -8000000))
            end)
        end

        local id = Profiteers:CreateMarker("mortar", ply, pos, nil, 20)
        Profiteers:SendMarker(id, ply)
    else
        ply:AddMoney(Profiteers.Buyables.pt_mortar.Price)
        return
    end
end