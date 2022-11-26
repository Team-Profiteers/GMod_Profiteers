hook.Add("HUDPaint", "PT PropDMG", function()
    local tr = util.TraceHull({
        start = LocalPlayer():EyePos(),
        endpos = LocalPlayer():EyePos() + LocalPlayer():GetAimVector() * 48,
        mins = Vector(-4, -4, -4),
        maxs = Vector(4, 4, 4),
        filter = LocalPlayer()
    })

    if IsValid(tr.Entity) and tr.Entity:CanTakePropDamage() then
        local frac = tr.Entity:GetNWFloat("PFPropHealth", 1) / tr.Entity:GetNWFloat("PFPropMaxHealth", 1)
        local seg = 64
        local arc = math.floor(seg * frac)
        local radius = ScreenScale(42)
        local innerradius = ScreenScale(36)

        local x = ScrW() / 2
        local y = ScrH() / 2

        local col1 = Color(255, 0, 0)
        local col2 = Color(100, 255, 25)

        local text = math.Round(tr.Entity:GetNWFloat("PFPropHealth")) .. "/" .. math.Round(tr.Entity:GetNWFloat("PFPropMaxHealth", 1))

        surface.SetFont("CGHUD_7")
        x = x - (surface.GetTextSize(text) / 2)
        surface.SetTextColor(Color(0, 0, 0))
        surface.SetTextPos(x + 1, y + 1)
        surface.DrawText(text)
        surface.SetTextColor(Color(Lerp(frac, col1.r, col2.r), Lerp(frac, col1.g, col2.g), Lerp(frac, col1.b, col2.b), 255))
        surface.SetTextPos(x, y)
        surface.DrawText(text)

        for i = 1, arc do
            local ang = Angle( 0, (-360 * i / seg) - 90, 0 )

            local vec = ang:Forward()

            local inner = (vec * innerradius) + Vector(ScrW() / 2, ScrH() / 2, 0)
            local outer = (vec * radius) + Vector(ScrW() / 2, ScrH() / 2, 0)

            surface.SetDrawColor(Color(0, 0, 0))
            surface.DrawLine(inner.x + 1, inner.y + 1, outer.x + 1, outer.y + 1)

            surface.SetDrawColor(Color(Lerp(frac, col1.r, col2.r), Lerp(frac, col1.g, col2.g), Lerp(frac, col1.b, col2.b), 255))
            surface.DrawLine(inner.x, inner.y, outer.x, outer.y)
        end
    end
end)