function Profiteers:SpawnPaveLowPlane(ply)
    local pos, ang = Profiteers:GetPlaneEnterPosAng()

    if !pos then return end

    local airdrop = ents.Create("pt_pavelow_plane")
    airdrop:SetPos(pos)
    airdrop:SetAngles(ang)
    airdrop:SetOwner(ply)
    airdrop:Spawn()
    airdrop:Activate()
end