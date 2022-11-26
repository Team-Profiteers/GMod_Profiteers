// Prevent NPCs from dropping any weapons
hook.Add("OnNPCKilled", "RemoveNPCWeapons", function(npc, attacker, inflictor)
    for k, v in pairs(npc:GetWeapons()) do
        v:Remove()
    end
end)

// NPCs do more damage based on their NPC.DamageMult

hook.Add("EntityTakeDamage", "NPCDamageMult", function(target, dmginfo)
    local attacker = dmginfo:GetAttacker()

    if attacker:IsNPC() then
        dmginfo:ScaleDamage(attacker.DamageMult or 1)
    end
end)

// Prevent zombies from spawning headcrabs on death

hook.Add("OnEntityCreated", "RemoveNPCHeadcrabs", function(ent)
    if !ent.ProfiteersSpawned and ent:GetClass() == "npc_headcrab" then
        ent:Remove()
    end
end)