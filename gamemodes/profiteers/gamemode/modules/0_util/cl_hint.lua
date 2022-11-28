function GM:Hint(ply, mode, dur, msg)
    if ply ~= LocalPlayer() then return end
    if isstring(dur) and msg == nil then
        msg = dur
        dur = nil
    end

    if !dur or dur == 0 then dur = math.Clamp(string.len(msg) * 0.15 + 1, 3, 10) end
    notification.AddLegacy(msg, mode or 0, dur)
end

net.Receive("pt_hint", function()
    local msg = net.ReadString()
    local mode = net.ReadUInt(3)
    local dur = net.ReadFloat()
    GAMEMODE:Hint(LocalPlayer(), mode, dur, msg)
end)