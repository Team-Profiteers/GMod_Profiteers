function Profiteers:SpawnArtillery(pos, ply)
    local tr = util.TraceHull({
        start = pos + Vector(0, 0, 32),
        endpos = pos + Vector(0, 0, 1000000),
        mins = Vector(-16, -16, 0),
        maxs = Vector(16, 16, 72),
        mask = MASK_PLAYERSOLID,
    })
    if tr.HitSky then
        for i = 1, 10 do
            timer.Simple(i * 5 + math.Rand(0, 5), function()
                local shell = ents.Create("pt_shell_artillery")
                shell:SetPos(tr.HitPos + Vector(math.Rand(-728, 728), math.Rand(-728, 728), -32))
                shell:SetAngles(Angle(90, 0, 0))
                shell:SetOwner(ply)
                shell:Spawn()
                shell:Activate()
                shell:GetPhysicsObject():SetVelocity(Vector(0, 0, -9000000))
            end)
        end
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
        mask = MASK_PLAYERSOLID,
    })
    if tr.HitSky then
        for i = 1, 5 do
            timer.Simple(i * 3 + math.Rand(0, 2), function()
                local shell = ents.Create("pt_shell_mortar")
                shell:SetPos(tr.HitPos + Vector(math.Rand(-512, 512), math.Rand(-512, 512), -32))
                shell:SetAngles(Angle(90, 0, 0))
                shell:SetOwner(ply)
                shell:Spawn()
                shell:Activate()
                shell:GetPhysicsObject():SetVelocity(Vector(0, 0, -9000000))
            end)
        end
    else
        ply:AddMoney(Profiteers.Buyables.pt_mortar.Price)
        return
    end
end