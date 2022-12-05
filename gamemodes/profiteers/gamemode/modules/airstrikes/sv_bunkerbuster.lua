function Profiteers:SpawnBunkerBusterPlane(ply, droppos)
    local pos, ang = Profiteers:GetPlaneEnterPosAng(droppos, 500)

    if !pos then
        ply:AddMoney(Profiteers.Buyables.pt_bomb_marker.Price)
        return
    end

    local airdrop = ents.Create("pt_plane_bomber")
    airdrop:SetPos(pos)
    airdrop:SetAngles(ang)
    airdrop:SetOwner(ply)
    airdrop.DropPos = droppos
    airdrop:Spawn()
    airdrop:Activate()

    local eta = (droppos - pos):Length() / 1300
    local id = Profiteers:CreateMarker("bunker_buster", ply, droppos, nil, eta)
    Profiteers:SendMarker(id, ply)

    airdrop.MarkerID = id

    airdrop.Bounty = Profiteers.Buyables.pt_bomb_marker.Price
end