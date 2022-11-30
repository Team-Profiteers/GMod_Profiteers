function Profiteers:SpawnBunkerBusterPlane(droppos, ply)
    local pos, ang = Profiteers:GetPlaneEnterPosAng(droppos)

    if !pos then return end

    local airdrop = ents.Create("pt_bomber_plane")
    airdrop:SetPos(pos)
    airdrop:SetAngles(ang)
    airdrop:SetOwner(ply)
    airdrop:Spawn()
    airdrop:Activate()

    airdrop.DropPos = droppos
end