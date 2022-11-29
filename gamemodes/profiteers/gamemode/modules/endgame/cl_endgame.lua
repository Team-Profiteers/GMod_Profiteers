local nukemat = Material("profiteers/nuke.png", "smooth nomips")

net.Receive("pt_nuke", function()
    Profiteers.HasNuke = net.ReadBool()
    if Profiteers.HasNuke then
        Profiteers.ActiveNuke = net.ReadEntity()
        Profiteers.NukeOwnerName = net.ReadString()
        Profiteers.NukePos = net.ReadVector()
        Profiteers.NukeArmTime = net.ReadFloat()
    else
        Profiteers.ActiveNuke = nil
        Profiteers.NukeOwnerName = nil
        Profiteers.NukePos = nil
        Profiteers.NukeArmTime = nil
    end
end)

hook.Add("HUDPaint", "Profiteers Nuke Warning", function()
    if !Profiteers.HasNuke then return end

    local nuke = Profiteers.ActiveNuke

    local armtime = IsValid(nuke) and nuke:GetArmTime() or Profiteers.NukeArmTime
    local dettime = GetConVar("pt_nuke_time"):GetFloat()

    local timeleft = dettime - (CurTime() - armtime)

    local text = "T-" .. tostring(math.ceil(timeleft))

    surface.SetTextColor(255, 50, 50)
    surface.SetFont("CGHUD_2")
    surface.SetTextPos(ScreenScale(48), ScreenScale(12))
    surface.DrawText(text)

    surface.SetTextColor(255, 50, 50)
    surface.SetFont("CGHUD_6")
    surface.SetTextPos(ScreenScale(48), ScreenScale(4))
    surface.DrawText("ALERT ALERT ALERT")

    local name = string.upper(IsValid(nuke) and nuke:CPPIGetOwnerName() or Profiteers.NukeOwnerName or "UNKNOWN")

    surface.SetTextColor(255, 50, 50)
    surface.SetFont("CGHUD_6")
    surface.SetTextPos(ScreenScale(48), ScreenScale(36))
    surface.DrawText(name .. " ARMED NUCLEAR DEVICE")

    surface.SetDrawColor(255, 255, 255)
    surface.SetMaterial(nukemat)
    surface.DrawTexturedRectRotated(ScreenScale(24), ScreenScale(24), ScreenScale(32), ScreenScale(32), CurTime() * 360)

    cam.Start3D()
        local toscreen = (IsValid(nuke) and nuke:GetPos() or Profiteers.NukePos):ToScreen()
    cam.End3D()

    local x, y = toscreen.x, toscreen.y
    local s = ScreenScale(24)

    surface.SetMaterial(nukemat)
    surface.SetDrawColor(255, 255, 255, 35 * (math.sin(CurTime() * 5) + 1))
    surface.DrawTexturedRect(x - (s / 2), y - (s / 2), s, s)
end)