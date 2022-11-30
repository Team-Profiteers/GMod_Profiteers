function Profiteers:SpawnUAVPlane(ply)
    local pos, ang = Profiteers:GetPlaneEnterPosAng()

    if !pos then return end

    local airdrop = ents.Create("pt_uav_plane")
    airdrop:SetPos(pos)
    airdrop:SetAngles(ang)
    airdrop:SetOwner(ply)
    airdrop:Spawn()
    airdrop:Activate()

    ply:SetNWEntity("pt_uav", airdrop)
end