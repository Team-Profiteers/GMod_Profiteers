hook.Add("EntityTakeDamage", "Profiteers_Melee", function(ent, dmginfo)
    local wep = IsValid(dmginfo:GetAttacker()) and dmginfo:GetAttacker():IsPlayer() and dmginfo:GetAttacker():GetActiveWeapon()
    if IsValid(wep) and (ent:IsPlayer() or ent:IsNPC()) then
        if wep:GetClass() == "weapon_crowbar" then
            dmginfo:ScaleDamage(ent:IsPlayer() and 4 or 8)
        elseif wep:GetClass() == "weapon_stunstick" then
            dmginfo:ScaleDamage(ent:IsPlayer() and 5 or 10)
        end
    end
end)