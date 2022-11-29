local nukemat = Material("profiteers/nuke.png", "smooth nomips")

net.Receive("pt_nuke", function()
    Profiteers.HasNuke = net.ReadBool()
    if Profiteers.HasNuke then
        Profiteers.ActiveNuke = net.ReadEntity()
        Profiteers.NukeOwnerName = net.ReadString()
        Profiteers.NukePos = net.ReadVector()
        Profiteers.NukeArmTime = net.ReadFloat()
    end
end)

net.Receive("pt_gameover", function()
    Profiteers.GameOver = net.ReadBool()
end)

local lastnuke = false
local nukedisarmedt = 0
local timeleft_disarm = 0
local r = 0
hook.Add("HUDPaint", "Profiteers Nuke Warning", function()

    if Profiteers.GameOver then
        local name = string.upper(Profiteers.NukeOwnerName or "SOMEONE")
        GAMEMODE:ShadowText("GAME OVER", "CGHUD_2", ScrW() / 2, ScrH() / 3, Color(255, 0, 0), Color(0, 0, 0, 100), TEXT_ALIGN_CENTER, TEXT_ALIGN_BOTTOM)
        GAMEMODE:ShadowText(name .. " SUCCESSFULLY DETONATED THE NUCLEAR DEVICE", "CGHUD_4", ScrW() / 2, ScrH() / 3 + ScreenScale(2), Color(255, 0, 0), Color(0, 0, 0, 100), TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP)
        return
    end

    local nuke = Profiteers.ActiveNuke

    if !Profiteers.HasNuke then
        if lastnuke then
            nukedisarmedt = CurTime() + 5
            timeleft_disarm = math.max(0, GetConVar("pt_nuke_time"):GetFloat() - (CurTime() - (IsValid(nuke) and nuke:GetArmTime() or Profiteers.NukeArmTime)))
            lastnuke = false
        end

        if nukedisarmedt > CurTime() then
            local left = nukedisarmedt - CurTime()
            local a = Lerp(left / 2, 0, 255)

            surface.SetDrawColor(255, 255, 255, a)
            surface.SetMaterial(nukemat)
            surface.DrawTexturedRectRotated(ScreenScale(24), ScreenScale(24), ScreenScale(32), ScreenScale(32), r)
            r = (r + FrameTime() * Lerp((left - 2) / (5 - 2), 0, 360)) % 360

            local text = "T-" .. tostring(math.ceil(timeleft_disarm))

            surface.SetTextColor(50, 255, 50, a)
            surface.SetFont("CGHUD_2")
            surface.SetTextPos(ScreenScale(48), ScreenScale(12))
            surface.DrawText(text)

            surface.SetTextColor(50, 255, 50, a)
            surface.SetFont("CGHUD_6")
            surface.SetTextPos(ScreenScale(48), ScreenScale(36))
            surface.DrawText("NUCLEAR DEVICE DISARMED")

            surface.SetTextColor(50, 255, 50, a)
            surface.SetFont("CGHUD_6")
            surface.SetTextPos(ScreenScale(48), ScreenScale(4))
            surface.DrawText("CRISIS AVERTED")
        end
        return
    end
    lastnuke = true

    local timeleft = math.max(0, GetConVar("pt_nuke_time"):GetFloat() - (CurTime() - (IsValid(nuke) and nuke:GetArmTime() or Profiteers.NukeArmTime)))

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
    surface.DrawTexturedRectRotated(ScreenScale(24), ScreenScale(24), ScreenScale(32), ScreenScale(32), r)
    r = (r + FrameTime() * 360) % 360

    cam.Start3D()
        local toscreen = (IsValid(nuke) and nuke:GetPos() or Profiteers.NukePos):ToScreen()
    cam.End3D()

    local x, y = toscreen.x, toscreen.y
    local s = ScreenScale(24)

    surface.SetMaterial(nukemat)
    surface.SetDrawColor(255, 255, 255, 35 * (math.sin(CurTime() * 5) + 1))
    surface.DrawTexturedRect(x - (s / 2), y - (s / 2), s, s)
end)