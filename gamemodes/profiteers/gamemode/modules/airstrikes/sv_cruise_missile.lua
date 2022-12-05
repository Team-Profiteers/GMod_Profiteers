function Profiteers:SpawnCruiseMissilePlane(droppos, ply)
    local pos, ang = Profiteers:GetPlaneEnterPosAng(droppos, 20)

    if !pos then
        ply:AddMoney(Profiteers.Buyables.pt_cruise_missile.Price)
        return
    end

    local airdrop = ents.Create("pt_cruise_missile")
    airdrop:SetPos(pos)
    airdrop:SetAngles(ang)
    airdrop:SetOwner(ply)
    airdrop.ShootEntData.Target = droppos
    airdrop:Spawn()
    airdrop:Activate()

    local eta = ((droppos + Vector(0, 0, 5000)) - pos):Length() / 3000 + 0.25
    local id = Profiteers:CreateMarker("cruise_missile", ply, droppos, nil, eta)
    Profiteers:SendMarker(id, ply)

    airdrop.MarkerID = id

    airdrop.Bounty = Profiteers.Buyables.pt_cruise_missile.Price
end