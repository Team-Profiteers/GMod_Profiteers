local clr_destroyed = Color(255, 0, 0)
local clr_health = Color(100, 255, 25)
local clr_ghosted = Color(120, 120, 120)
local clr_unghosting = Color(180, 180, 180)
local clr_shadow = Color(0, 0, 0)

hook.Add("HUDPaint", "PT PropDMG", function()

    local ent = LocalPlayer().PhysgunProp

    if !ent then
        local tr = util.TraceHull({
            start = LocalPlayer():EyePos(),
            endpos = LocalPlayer():EyePos() + LocalPlayer():GetAimVector() * 128,
            mins = Vector(-4, -4, -4),
            maxs = Vector(4, 4, 4),
            filter = LocalPlayer()
        })
        ent = tr.Entity
    end

    if IsValid(ent) and ent:CanTakePropDamage() then
        local ghosted = ent:GetNWBool("Ghosted")
        local frac = ghosted and (ent:GetNWFloat("PFUnGhostEnd", -1) - CurTime()) / ent:GetGhostDuration() or ent:GetNWFloat("PFPropHealth", 1) / ent:GetNWFloat("PFPropMaxHealth", 1)
        local seg = 64
        local arc = math.floor(seg * frac)
        local radius = ScreenScale(42)
        local innerradius = ScreenScale(36)

        local x = ScrW() / 2
        local y = ScrH() / 2

        local text = math.Round(ent:GetNWFloat("PFPropHealth")) .. "/" .. math.Round(ent:GetNWFloat("PFPropMaxHealth", 1))
        local clr = Color(Lerp(frac, clr_destroyed.r, clr_health.r), Lerp(frac, clr_destroyed.g, clr_health.g), Lerp(frac, clr_destroyed.b, clr_health.b), 255)
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
    end
end)