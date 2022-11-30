function Profiteers:SpawnPaveLowPlane(ply)
    local pos, ang = Profiteers:GetPlaneEnterPosAng(nil, 500)

    if !pos then return end

    local airdrop = ents.Create("pt_pavelow_plane")
    airdrop:SetPos(pos)
    airdrop:SetAngles(ang)
    airdrop:SetOwner(ply)
    airdrop.LoiterPos = Vector(ply:GetPos().x, ply:GetPos().y, pos.z)
    airdrop:Spawn()
    airdrop:Activate()
end