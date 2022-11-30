function Profiteers:SpawnBunkerBusterPlane(droppos, ply)
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

    airdrop.Bounty = Profiteers.Buyables.pt_bomb_marker.Price
end