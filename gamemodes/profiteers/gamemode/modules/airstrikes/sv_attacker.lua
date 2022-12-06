function Profiteers:SpawnAttackerPlane(ply, droppos)
    local pos, ang = Profiteers:GetPlaneEnterPosAng(droppos, 200, ply:GetAngles().y + 90)

    if !pos then
        ply:AddMoney(Profiteers.Buyables.pt_attacker.Price)
        return
    end

    debugoverlay.Sphere(droppos, 128, 30, Color(255, 255, 255, 0), true)

    local approach2d = pos - droppos
    approach2d.z = 0
    approach2d:Normalize()
    debugoverlay.Line(droppos, droppos + approach2d * 128, 30, Color(0, 255, 0), true)

    local d = math.abs(pos.z - droppos.z) / math.sqrt(5)
    local diagonal = util.TraceHull({
        start = droppos,
        endpos = droppos + approach2d * d + Vector(0, 0, d * 2),
        mask = MASK_SOLID_BRUSHONLY,
        mins = Vector(-32, -32, 0),
        maxs = Vector(32, 32, 32),
    })
    debugoverlay.Line(diagonal.StartPos, diagonal.HitPos, 30, Color(255, 0, 0), true)
    debugoverlay.Sphere(diagonal.HitPos, 64, 30, Color(255, 255, 0, 0), true)

    local airdrop = ents.Create("pt_plane_attack")
    airdrop:SetPos(pos)
    airdrop:SetAngles(ang)
    airdrop:SetOwner(ply)
    airdrop.Bounty = Profiteers.Buyables.pt_attacker.Price

    local eta = (droppos - pos):Length() / 3000 + (pos.z - droppos.z) / 4000
    local id = Profiteers:CreateMarker("bomber", ply, droppos, nil, eta)
    Profiteers:SendMarker(id, ply)
    airdrop.MarkerID = id

    airdrop.DropPos = droppos
    if !diagonal.Hit then
        airdrop.DiagonalDrop = diagonal.HitPos
        debugoverlay.Sphere(diagonal.HitPos, 128, 30, Color(255, 0, 0, 0), true)
    end

    airdrop:Spawn()
    airdrop:Activate()
end

-- local approachangles = {90, -90, 90 - 30, 90 + 30, -90 - 30, -90 + 30}

function Profiteers:SpawnGunRunPlane(ply, droppos)
    local pos, ang = Profiteers:GetPlaneEnterPosAng(droppos, 200, ply:GetAngles().y + 90)

    if !pos then
        ply:AddMoney(Profiteers.Buyables.pt_gunrun.Price)
        return
    end

    debugoverlay.Sphere(droppos, 128, 15, Color(255, 255, 255, 0), true)

    local airdrop = ents.Create("pt_plane_gunrun")
    airdrop:SetPos(pos)
    airdrop:SetAngles(ang)
    airdrop:SetOwner(ply)
    airdrop.DropPos = droppos
    airdrop:Spawn()
    airdrop:Activate()

    airdrop.Bounty = Profiteers.Buyables.pt_gunrun.Price

    local eta = (droppos - pos):Length() / 3000
    local id = Profiteers:CreateMarker("gun_run", ply, droppos, nil, eta)
    Profiteers:SendMarker(id, ply)

    airdrop.MarkerID = id

    --[[]
    local done = false
    for i = 1, #approachangles do
        local pos, ang = Profiteers:GetPlaneEnterPosAng(droppos, 200, ply:GetAngles().y + approachangles[i])
        if !pos then continue end
        local approach2d = pos - droppos
        approach2d.z = 0
        approach2d:Normalize()
        debugoverlay.Line(droppos, droppos + approach2d * 128, 15, Color(0, 255, 0), true)

        local d = math.abs(pos.z - droppos.z) / math.sqrt(5)
        local diagonal = util.TraceHull({
            start = droppos,
            endpos = droppos + approach2d * d + Vector(0, 0, d * 2),
            mask = MASK_SOLID_BRUSHONLY,
            mins = Vector(-32, -32, 0),
            maxs = Vector(32, 32, 32),
        })

        debugoverlay.Line(diagonal.StartPos, diagonal.HitPos, 15, Color(255, 0, 0), true)
        debugoverlay.Sphere(diagonal.HitPos, 128, 15, Color(255, 255, 0, 0), true)
        if diagonal.Hit and !diagonal.HitSky then
            continue
        end

        local airdrop = ents.Create("pt_plane_gunrun")
        airdrop:SetPos(pos)
        airdrop:SetAngles(ang)
        airdrop:SetOwner(ply)
        airdrop.DropPos = diagonal.HitPos
        airdrop:Spawn()
        airdrop:Activate()
        done = true
        break
    end


    if !done then
        ply:AddMoney(Profiteers.Buyables.pt_gunrun.Price)
        return
    end
    ]]
end