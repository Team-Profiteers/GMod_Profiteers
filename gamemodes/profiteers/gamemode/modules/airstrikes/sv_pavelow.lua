function Profiteers:SpawnPaveLowPlane(ply)
    local pos, ang = Profiteers:GetPlaneEnterPosAng(nil, 500)

    if !pos then
        ply:AddMoney(Profiteers.Buyables.pt_pavelow.Price)
        return
    end

    local airdrop = ents.Create("pt_plane_pavelow")
    airdrop:SetPos(pos)
    airdrop:SetAngles(ang)
    airdrop:SetOwner(ply)
    airdrop.LoiterPos = Vector(ply:GetPos().x, ply:GetPos().y, pos.z)
    airdrop:Spawn()
    airdrop:Activate()

    airdrop.Bounty = Profiteers.Buyables.pt_pavelow.Price
end