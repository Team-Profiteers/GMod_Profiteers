hook.Add("PlayerPostThink", "ProfiteersPostPlayerThinkParachute", function(ply)
    local usingspidermangun = ply:GetActiveWeapon():IsValid() and ply:GetActiveWeapon():GetClass() == "spiderman's_swep"

    if usingspidermangun then
        ply:SetNWBool("pt_parachute", false)
        ply:SetNWBool("pt_parachute_pending", false)
        ply:SetNWBool("pt_parachute_auto", false)
    end

    if ply:GetNWBool("pt_parachute") and (ply:IsOnGround()) then
        ply:SetNWBool("pt_parachute", false)
        ply:SetNWBool("pt_parachute_auto", false)
        if SERVER then
            ply:EmitSound("npc/combine_soldier/gear3.wav", 100, 100)
            ply:EmitSound("profiteers/para_close.wav", 110)
        end
    end
    if ply:GetNWBool("pt_parachute_pending", false) and ply:IsOnGround() then
        ply:SetNWBool("pt_parachute_pending", false)
        ply:SetNWBool("pt_parachute_auto", false)
    end
    if ply:GetNWBool("pt_parachute_manual", false) and ply:IsOnGround() then
        ply:SetNWBool("pt_parachute_manual", false)
    end

    if !ply:GetNWBool("pt_parachute_pending") and !ply:IsOnGround() and ply:GetVelocity().z < -500 then
        ply:SetNWBool("pt_parachute_manual", true)
    end
end)