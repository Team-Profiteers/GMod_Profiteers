function Profiteers:SpawnAttackerPlane(ply, droppos)
    local pos, ang = Profiteers:GetPlaneEnterPosAng(droppos, 200)

    if !pos then
        ply:AddMoney(Profiteers.Buyables.pt_attacker.Price)
        return
    end

    debugoverlay.Sphere(droppos, 128, 15, Color(255, 255, 255, 0), true)

    local approach2d = pos - droppos
    approach2d.z = 0
    approach2d:Normalize()
    debugoverlay.Line(droppos, droppos + approach2d * 128, 15, Color(0, 255, 0), true)

    local d = math.abs(pos.z - droppos.z) / math.sqrt(5)

    local diagonal = util.TraceHull({
        start = droppos,
        endpos = droppos + approach2d * d + Vector(0, 0, d * 2),
        mask = MASK_SOLID_BRUSHONLY,
        mins = Vector(-32, -32, -32),
        maxs = Vector(32, 32, 32),
    })
    debugoverlay.Line(diagonal.StartPos, diagonal.HitPos, 15, Color(255, 0, 0), true)
    debugoverlay.Sphere(diagonal.HitPos, 64, 15, Color(255, 255, 0, 0), true)

    local airdrop = ents.Create("pt_plane_attack")
    airdrop:SetPos(pos)
    airdrop:SetAngles(ang)
    airdrop:SetOwner(ply)

    airdrop.DropPos = droppos
    if !diagonal.Hit then
        airdrop.DiagonalDrop = diagonal.HitPos
        debugoverlay.Sphere(diagonal.HitPos, 128, 15, Color(255, 0, 0, 0), true)
    end

    airdrop:Spawn()
    airdrop:Activate()
end