function Profiteers:SpawnAttackerPlane(ply, droppos)
    local pos, ang = Profiteers:GetPlaneEnterPosAng(droppos, 200)

    if !pos then
        ply:AddMoney(Profiteers.Buyables.pt_attacker.Price)
        return
    end

    local airdrop = ents.Create("pt_attack_plane")
    airdrop:SetPos(pos)
    airdrop:SetAngles(ang)
    airdrop:SetOwner(ply)
    airdrop.DropPos = droppos
    airdrop:Spawn()
    airdrop:Activate()
end