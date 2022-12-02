function Profiteers:SpawnCruiseMissilePlane(droppos, ply)
    local pos, ang = Profiteers:GetPlaneEnterPosAng(droppos, 20)

    if !pos then
        ply:AddMoney(Profiteers.Buyables.pt_cruise_missile.Price)
        return
    end

    local airdrop = ents.Create("pt_cruise_missile")
    airdrop:SetPos(pos)
    airdrop:SetAngles(ang)
    airdrop:SetOwner(ply)
    airdrop.ShootEntData.Target = droppos
    airdrop:Spawn()
    airdrop:Activate()

    airdrop.Bounty = Profiteers.Buyables.pt_cruise_missile.Price
end