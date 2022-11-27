hook.Add("PlayerDeathThink", "ProfiteersPlayerDeathThinkEndgame", function(ply)
    if Profiteers.GameOver then return false end
end)