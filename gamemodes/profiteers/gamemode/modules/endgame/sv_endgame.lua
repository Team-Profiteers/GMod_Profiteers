util.AddNetworkString("pt_nuke")
util.AddNetworkString("pt_gameover")

Profiteers.NukeIsICBM = false

hook.Add("PlayerDeathThink", "ProfiteersPlayerDeathThinkEndgame", function(ply)
    if Profiteers.GameOver then return false end
end)

function Profiteers:SyncNuke(isicbm)
    Profiteers.NukeIsICBM = isicbm

    local armed = IsValid(Profiteers.ActiveNuke) and (isicbm or Profiteers.ActiveNuke:GetArmed())

    net.Start("pt_nuke")
        net.WriteBool(armed)
        if armed then
            net.WriteEntity(Profiteers.ActiveNuke) -- Not guaranteed to exist on client due to PVS nands
            net.WriteString(isicbm and Profiteers.ActiveNuke:GetOwner():Nick() or Profiteers.ActiveNuke:CPPIGetOwnerName())
            net.WriteVector(Profiteers.ActiveNuke:GetPos())
            net.WriteFloat(isicbm and 0 or Profiteers.ActiveNuke:GetArmTime())
            net.WriteBool(Profiteers.NukeIsICBM)
        end
    net.Broadcast()
end


function Profiteers:SetGameOver()
    Profiteers.GameOver = true
    net.Start("pt_gameover")
        net.WriteBool(true)
    net.Broadcast()
end

timer.Create("Profiteers_NukeSync", 3, 0, function()
    if IsValid(Profiteers.ActiveNuke) and (Profiteers.NukeIsICBM or Profiteers.ActiveNuke:GetArmed()) then
        Profiteers:SyncNuke(Profiteers.NukeIsICBM)
    end
end)