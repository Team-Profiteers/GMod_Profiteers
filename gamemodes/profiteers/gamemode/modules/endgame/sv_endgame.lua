util.AddNetworkString("pt_nuke")
util.AddNetworkString("pt_gameover")

hook.Add("PlayerDeathThink", "ProfiteersPlayerDeathThinkEndgame", function(ply)
    if Profiteers.GameOver then return false end
end)

function Profiteers:SyncNuke()
    local armed = IsValid(Profiteers.ActiveNuke) and Profiteers.ActiveNuke:GetArmed()
    net.Start("pt_nuke")
        net.WriteBool(armed)
        if armed then
            net.WriteEntity(Profiteers.ActiveNuke) -- Not guaranteed to exist on client due to PVS nands
            net.WriteString(Profiteers.ActiveNuke:CPPIGetOwnerName())
            net.WriteVector(Profiteers.ActiveNuke:GetPos())
            net.WriteFloat(Profiteers.ActiveNuke:GetArmTime())
        end
    net.Broadcast()
end


function Profiteers:GameOver()
    Profiteers.GameOver = true
    net.Start("pt_gameover")
        net.WriteBool(true)
    net.Broadcast()
end

timer.Create("Profiteers_NukeSync", 3, 0, function()
    if IsValid(Profiteers.ActiveNuke) and Profiteers.ActiveNuke:GetArmed() then
        Profiteers:SyncNuke()
    end
end)