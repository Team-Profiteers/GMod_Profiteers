function Profiteers:SpawnICBMPlane(ply)
    local droppos = ply:GetPos() + Vector(0, 0, 64)

    local pos, ang = Profiteers:GetPlaneEnterPosAng(droppos, 20)

    if !pos then
        ply:AddMoney(Profiteers.Buyables.pt_icbm.Price)
        return
    end

    local airdrop = ents.Create("pt_icbm")
    airdrop:SetPos(pos - Vector(0, 0, 1000))
    airdrop:SetAngles(ang)
    airdrop:SetOwner(ply)
    airdrop.ShootEntData.Target = droppos
    airdrop:Spawn()
    airdrop:Activate()
end