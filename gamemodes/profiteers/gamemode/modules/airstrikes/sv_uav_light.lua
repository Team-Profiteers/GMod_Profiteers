function Profiteers:SpawnUAVLightPlane(ply)
    local pos, ang = Profiteers:GetPlaneEnterPosAng(nil, 200)

    if !pos then
        ply:AddMoney(Profiteers.Buyables.pt_uav_light.Price)
        return
    end

    local airdrop = ents.Create("pt_plane_uav_light")
    airdrop:SetPos(pos)
    airdrop:SetAngles(ang)
    airdrop:SetOwner(ply)
    airdrop:Spawn()
    airdrop:Activate()

    airdrop.Bounty = Profiteers.Buyables.pt_uav_light.Price
end