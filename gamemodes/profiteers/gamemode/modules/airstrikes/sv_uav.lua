function Profiteers:SpawnUAVPlane(ply)
    local pos, ang = Profiteers:GetPlaneEnterPosAng(nil, 200)

    if !pos then
        ply:AddMoney(Profiteers.Buyables.pt_uav.Price)
        return
    end

    local airdrop = ents.Create("pt_plane_uav")
    airdrop:SetPos(pos)
    airdrop:SetAngles(ang)
    airdrop:SetOwner(ply)
    airdrop:Spawn()
    airdrop:Activate()
end