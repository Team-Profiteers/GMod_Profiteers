-- Player health regen

hook.Add("PlayerTick", "ProfiteersPlayerTickRegen", function(ply)
    if ply:Health() < ply:GetMaxHealth() and (ply:GetNWFloat("pt_lastdamagetime", 0) + 5) <= CurTime() then
        local tps = 1 / engine.TickInterval()

        local healthpersecond = 20

        local ticksbetweenheal = tps / healthpersecond

        if engine.TickCount() % math.ceil(ticksbetweenheal) == 0 then
            ply:SetHealth(math.min(ply:Health() + 1, ply:GetMaxHealth()))
        end
    end
end)

hook.Add("EntityTakeDamage", "ProfiteersPlayerTakeDamageRegen", function(ent, dmginfo)
    if ent:IsPlayer() then
        ent:SetNWFloat("pt_lastdamagetime", CurTime())
    end
end)