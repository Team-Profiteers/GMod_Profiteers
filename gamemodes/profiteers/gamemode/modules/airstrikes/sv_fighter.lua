function Profiteers:SpawnFighterPlane(ply)
    local pos, ang = Profiteers:GetPlaneEnterPosAng(nil, 200)

    if !pos then return end

    local airdrop = ents.Create("pt_fighter_plane")
    airdrop:SetPos(pos)
    airdrop:SetAngles(ang)
    airdrop:SetOwner(ply)
    airdrop:Spawn()
    airdrop:Activate()
end