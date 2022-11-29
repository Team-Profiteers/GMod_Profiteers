local clr_destroyed = Color(255, 0, 0)
local clr_health = Color(25, 100, 255)
local clr_health2 = Color(100, 255, 25)

local clr_ghosted = Color(120, 120, 120)
local clr_unghosting = Color(180, 180, 180)
local clr_shadow = Color(0, 0, 0)
local clr_shadow2 = Color(0, 0, 0, 100)

local lastquotachange = 0
local last_quota_mult = 0
local c = CGSS(1)

hook.Add("HUDPaint", "PropHud", function()
    local dzx, dzy = GetConVar("pt_hud_deadzone_x"):GetFloat() * 0.25, GetConVar("pt_hud_deadzone_y"):GetFloat() * 0.25
    local w, h = ScrW() * (1 - dzx * 2), ScrH() * (1 - dzy * 2)
    local ox, oy = ScrW() * dzx, ScrW() * dzy

    if !GetConVar("pt_prop_quota_disable"):GetBool() and LocalPlayer():GetMaxPropQuota() > 0 then
        local quota_mult = LocalPlayer():GetPropQuota() / LocalPlayer():GetMaxPropQuota()
        if quota_mult > 0 and quota_mult < 1 then quota_mult = math.Clamp(quota_mult, 0.01, 0.99) end

        if last_quota_mult ~= quota_mult then
            last_quota_mult = quota_mult
            lastquotachange = CurTime()
        end

        if CurTime() - lastquotachange <= 10 then
            --local a = surface.GetAlphaMultiplier()
            --surface.SetAlphaMultiplier(Lerp((CurTime() - lastquotachange - 7) / (10 - 7), 1, 0))
            local shift = Lerp(math.Clamp((CurTime() - lastquotachange - 7) / (10 - 7), 0, 1) ^ 3, 0, c * -64 - ox)
            -- Prop Quota
            surface.SetDrawColor(clr_shadow2)
            surface.DrawOutlinedRect(ox + shift + (c * 16) + (c * 4), h / 2 - (c * 200) + (c * 4), c * 24, c * 400, c * 4)

            if quota_mult < 1 then
                surface.SetDrawColor(clr_shadow2)
                surface.DrawRect(ox + shift + (c * 18) + (c * 4), h / 2 + (c * 200) - (c * 400 * math.Clamp(quota_mult, 0, 1)) + (c * 4), c * 18, c * 400 * math.Clamp(quota_mult, 0, 1))
            end

            local clr_w = team.GetColor(LocalPlayer():Team())
            clr_w.r = (clr_w.r * 0.5) + (255 * 0.5)
            clr_w.g = (clr_w.g * 0.5) + (255 * 0.5)
            clr_w.b = (clr_w.b * 0.5) + (255 * 0.5)

            local clr_w2 = Color(clr_w.r, clr_w.g, clr_w.b)
            if quota_mult == 1 then
                clr_w2.g = Lerp(math.abs(math.sin(SysTime() * 10)), 0, 255)
                clr_w2.b = Lerp(math.abs(math.sin(SysTime() * 10)), 0, 255)
            end

            surface.SetDrawColor(clr_w)
            surface.DrawOutlinedRect(ox + shift + (c * 16), h / 2 - (c * 200), c * 24, c * 400, c * 4)
            surface.SetDrawColor(clr_w2)
            surface.DrawRect(ox + shift + (c * 18), h / 2 + (c * 200) - (c * 400 * math.Clamp(quota_mult, 0, 1)), c * 18, c * 400 * math.Clamp(quota_mult, 0, 1))

            GAMEMODE:ShadowText("PROP", "CGHUD_6", ox + shift + (c * 16) + c * 12, h / 2 - (c * 200) - c * 16, clr_w2, clr_shadow2, TEXT_ALIGN_CENTER, TEXT_ALIGN_BOTTOM)
            GAMEMODE:ShadowText("QUOTA", "CGHUD_6", ox + shift + (c * 16) + c * 12, h / 2 - (c * 200) - c * 20, clr_w2, clr_shadow2, TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP)
            GAMEMODE:ShadowText(math.floor(quota_mult * 100) .. "%", "CGHUD_5", ox + shift + (c * 16) + c * 12, h / 2 + (c * 200) + c * 4, clr_w2, clr_shadow2, TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP)

            --surface.SetAlphaMultiplier(a)
        end
    end

    local ent = LocalPlayer().PhysgunProp

    if !ent then
        local tr = LocalPlayer():GetEyeTraceNoCursor()
        if tr.HitPos:DistToSqr(tr.StartPos) <= 256 * 256 then
            ent = tr.Entity
        end
    end

    if IsValid(ent) and ent:CanTakePropDamage() then
        local ghosted = ent:GetNWBool("Ghosted")
        local frac = ghosted and (ent:GetNWFloat("PFUnGhostEnd", -1) - CurTime()) / ent:GetGhostDuration() or ent:GetNWFloat("PFPropHealth", 1) / ent:GetNWFloat("PFPropMaxHealth", 1)
        local seg = 64
        local arc = math.floor(seg * frac)
        local radius = ScreenScale(42)
        local innerradius = ScreenScale(36)

        local x = ScrW() / 2
        local y = ScrH() / 2 + ScreenScale(4)

        local c1 = ent:IsVulnerableProp() and clr_health2 or clr_health

        local text = math.Round(ent:GetNWFloat("PFPropHealth")) .. "/" .. math.Round(ent:GetNWFloat("PFPropMaxHealth", 1))
        local clr = Color(Lerp(frac, clr_destroyed.r, c1.r), Lerp(frac, clr_destroyed.g, c1.g), Lerp(frac, clr_destroyed.b, c1.b), 255)
        if ghosted and ent:GetNWFloat("PFUnGhostEnd", -1) == -1 then
            clr = clr_ghosted
            text = "GHOSTED"
        elseif ghosted then
            clr = clr_unghosting
            text = string.format("%2.2f", math.max(0, ent:GetNWFloat("PFUnGhostEnd", -1) - CurTime()))
        end

        surface.SetFont("CGHUD_7")
        x = x - (surface.GetTextSize(text) / 2)
        surface.SetTextColor(clr_shadow)
        surface.SetTextPos(x + 1, y + 1)
        surface.DrawText(text)

        surface.SetTextColor(clr)
        surface.SetTextPos(x, y)
        surface.DrawText(text)

        for i = 1, arc do
            local ang = Angle( 0, (-360 * i / seg) - 90, 0 )

            local vec = ang:Forward()

            local inner = (vec * innerradius) + Vector(ScrW() / 2, ScrH() / 2, 0)
            local outer = (vec * radius) + Vector(ScrW() / 2, ScrH() / 2, 0)

            surface.SetDrawColor(clr_shadow)
            surface.DrawLine(inner.x + 1, inner.y + 1, outer.x + 1, outer.y + 1)

            surface.SetDrawColor(clr)
            surface.DrawLine(inner.x, inner.y, outer.x, outer.y)
        end

        local text2 = ent:CPPIGetOwnerName()
        x = ScrW() / 2 - (surface.GetTextSize(text2) / 2)
        y = y + ScreenScale(12)
        surface.SetTextColor(clr_shadow)
        surface.SetTextPos(x + 1, y + 1)
        surface.DrawText(text2)

        surface.SetTextColor(clr)
        surface.SetTextPos(x, y)
        surface.DrawText(text2)
    end
end)