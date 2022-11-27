net.Receive("pt_hint", function()
    local str = net.ReadString()
    local mode = net.ReadUInt(3)
    local dur = net.ReadFloat()
    if dur == 0 then dur = math.Clamp(string.len(str) * 0.15 + 1, 3, 10) end
    notification.AddLegacy(str, mode, dur)
end)