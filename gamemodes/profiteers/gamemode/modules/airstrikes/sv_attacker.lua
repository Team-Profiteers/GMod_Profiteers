function Profiteers:SpawnAttackerPlane(ply)
    local pos, ang = Profiteers:GetPlaneEnterPosAng(nil, 200)

    if !pos then return end

    local airdrop = ents.Create("pt_attack_plane")
    airdrop:SetPos(pos)
    airdrop:SetAngles(ang)
    airdrop:SetOwner(ply)
    airdrop:Spawn()
    airdrop:Activate()
end