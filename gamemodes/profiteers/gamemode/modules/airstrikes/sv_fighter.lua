function Profiteers:SpawnFighterPlane(ply)
    local pos, ang = Profiteers:GetPlaneEnterPosAng(nil, 200)

    if !pos then
        ply:AddMoney(Profiteers.Buyables.pt_fighter.Price)
        return
    end

    local airdrop = ents.Create("pt_plane_fighter")
    airdrop:SetPos(pos)
    airdrop:SetAngles(ang)
    airdrop:SetOwner(ply)
    airdrop:Spawn()
    airdrop:Activate()

    airdrop.Bounty = Profiteers.Buyables.pt_fighter.Price
end