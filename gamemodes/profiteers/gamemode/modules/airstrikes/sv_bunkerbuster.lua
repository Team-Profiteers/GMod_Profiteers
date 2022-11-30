function Profiteers:SpawnBunkerBusterPlane(droppos, ply)
    local pos, ang = Profiteers:GetPlaneEnterPosAng(droppos, 500)

    if !pos then return end

    local airdrop = ents.Create("pt_bomber_plane")
    airdrop:SetPos(pos)
    airdrop:SetAngles(ang)
    airdrop:SetOwner(ply)
    airdrop.DropPos = droppos
    airdrop:Spawn()
    airdrop:Activate()
end