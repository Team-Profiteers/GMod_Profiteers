AddCSLuaFile()

SWEP.PrintName          = "Pocket Teleporter"
SWEP.Slot               = 5

SWEP.ViewModel             = "models/weapons/c_slam.mdl"
SWEP.WorldModel            = "models/weapons/w_slam.mdl"

SWEP.UseHands = true

SWEP.Primary.ClipSize      = -1
SWEP.Primary.Automatic     = false
SWEP.Primary.Ammo          = "none"
SWEP.Primary.Delay         = 10

SWEP.Secondary.ClipSize    = -1
SWEP.Secondary.Automatic   = false
SWEP.Secondary.Ammo        = "none"
SWEP.Secondary.Delay       = 5

function SWEP:SetupDataTables()
    self:NetworkVar("Float", 0, "TeleEndT")
    self:NetworkVar("Int", 0, "TeleMode") -- 1: to telepad; 2: to random spot
end

function SWEP:Initialize()
    self:SetHoldType("slam")

    self:SetTeleEndT(0)
    self:SetTeleMode(0)
end

function SWEP:Deploy()
    local vm = self:GetOwner():GetViewModel()
    vm:SendViewModelMatchingSequence(vm:LookupSequence("detonator_draw"))
    vm:SetPlaybackRate(2)

    self:SetNextPrimaryFire(CurTime() + 0.5)
end

function SWEP:Holster()

    if self:GetTeleMode() > 0 then
        return false
    end

    if self.LoopSound then
        self.LoopSound:Stop()
        self.LoopSound = nil
    end
    return true
end

function SWEP:OnRemove()
    if self.LoopSound then
        self.LoopSound:Stop()
        self.LoopSound = nil
    end
end

function SWEP:CanPrimaryAttack()
    if self:GetNextPrimaryFire() > CurTime() then return end
    if self:GetTeleMode() > 0 or self:GetTeleEndT() > CurTime() then return end
    if self:GetOwner():GetNWFloat("PTNextTele") > CurTime() then return end

    local has = self:GetOwner():HasBoughtEntity("pt_telepad", true, true)
    if !has then
        GAMEMODE:Hint(self:GetOwner(), 1, "You do not have an active Telepad to teleport to.")
        self:SetNextPrimaryFire(CurTime() + 1)
        return
    end

    return true
end

function SWEP:CanSecondaryAttack()
    if self:GetNextPrimaryFire() > CurTime() then return end
    if self:GetTeleMode() > 0 or self:GetTeleEndT() > CurTime() then return end
    if self:GetOwner():GetNWFloat("PTNextTele") > CurTime() then return end

    return true
end

function SWEP:PrimaryAttack()
    if !self:CanPrimaryAttack() then return end

    if SERVER then
        self:SetTeleMode(1)
        local delay = GetConVar("pt_tele_recall_delay"):GetFloat()
        self:SetTeleEndT(CurTime() + delay)
        --GAMEMODE:Hint(self:GetOwner(), 0, math.max(2, delay - 1), "Initating teleport. Mode: Recall...")

        local vm = self:GetOwner():GetViewModel()
        vm:SendViewModelMatchingSequence(vm:LookupSequence("detonator_detonate"))
        vm:SetPlaybackRate(1)

        self.LoopSound = CreateSound(self, "ambient/energy/force_field_loop1.wav")
        self.LoopSound:PlayEx(1, 103)
    end

end

function SWEP:SecondaryAttack()
    if !self:CanSecondaryAttack() then return end

    if SERVER then
        self:SetTeleMode(2)
        local delay = GetConVar("pt_tele_disperse_delay"):GetFloat()
        self:SetTeleEndT(CurTime() + delay)
        --GAMEMODE:Hint(self:GetOwner(), 0, math.max(2, delay - 1), "Initating teleport. Mode: Disperse...")

        local vm = self:GetOwner():GetViewModel()
        vm:SendViewModelMatchingSequence(vm:LookupSequence("detonator_detonate"))
        vm:SetPlaybackRate(1)

        self.LoopSound = CreateSound(self, "ambient/energy/force_field_loop1.wav")
        self.LoopSound:PlayEx(1, 97)
    end
end

function SWEP:Think()
    if SERVER and self:GetTeleMode() > 0 and self:GetTeleEndT() < CurTime() then
        if self:GetTeleMode() == 1 then
            local has, ent = self:GetOwner():HasBoughtEntity("pt_telepad", true, true)
            if has and IsValid(ent) then
                self:GetOwner():SetPos(ent:GetPos() + Vector(0, 0, 16))
                self:GetOwner():SetAngles(Angle(0, ent:GetAngles().y - 90, 0))
                GAMEMODE:Hint(self:GetOwner(), 0, "Teleport successful. Welcome home.")
                self:GetOwner():SetNWFloat("PTNextTele", CurTime() + GetConVar("pt_tele_recall_cooldown"):GetFloat())

                self:GetOwner():EmitSound("ambient/energy/whiteflash.wav", 100)
                self:GetOwner():EmitSound("ambient/energy/weld1.wav", 100)
            else
                GAMEMODE:Hint(self:GetOwner(), 1, "Teleport failed: No active Telepad.")
            end
        elseif self:GetTeleMode() == 2 then
            if !Profiteers.Nodes or table.Count(Profiteers.Nodes) == 0 then
                ParseNodeFile()
            end

            local good = false
            for i = 1, 20 do
                local a = Profiteers.Nodes[math.random(#Profiteers.Nodes)]
                if !a then continue end
                local pos = a + VectorRand() * 512
                local tr = util.TraceLine({
                    start = pos,
                    endpos = pos - Vector(0, 0, 1024),
                    mask = MASK_PLAYERSOLID,
                })
                if !tr.Hit then continue end
                pos = tr.HitPos
                local tr2 = util.TraceHull({
                    start = pos,
                    endpos = pos,
                    mins = Vector(-20, -20, 0),
                    maxs = Vector(20, 20, 64),
                    mask = MASK_PLAYERSOLID,
                })
                if tr2.Hit then continue end

                self:GetOwner():SetPos(pos)
                self:GetOwner():SetAngles(Angle(0, math.Rand(0, 360), 0))
                GAMEMODE:Hint(self:GetOwner(), 0, "Teleport successful. Good luck.")
                self:GetOwner():SetNWFloat("PTNextTele", CurTime() + GetConVar("pt_tele_disperse_cooldown"):GetFloat())

                self:GetOwner():EmitSound("ambient/energy/whiteflash.wav", 100)
                self:GetOwner():EmitSound("ambient/energy/weld1.wav", 100)

                good = true
                break
            end

            if !good then
                GAMEMODE:Hint(self:GetOwner(), 1, "Teleport failed: Cannot find valid spot.")
            end
        end

        self:SetNextPrimaryFire(CurTime() + 0.2)
        self:SetTeleEndT(0)
        self:SetTeleMode(0)
        if self.LoopSound then
            self.LoopSound:Stop()
            self.LoopSound = nil
        end
    end
end

if CLIENT then
    local shadow = Color(0, 0, 0, 150)
    function SWEP:DrawHUD()

        if self:GetTeleMode() == 0 then
            if self:GetNextPrimaryFire() < CurTime() and self:GetOwner():GetNWFloat("PTNextTele") < CurTime() then
                GAMEMODE:ShadowText("TELEPORT READY", "CGHUD_5", ScrW() / 2, ScrH() - ScreenScale(72), Color(150, 255, 100), shadow, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)

                GAMEMODE:ShadowText("PRIMARY: Recall to Telepad", "CGHUD_6", ScrW() / 2, ScrH() - ScreenScale(50), color_white, shadow, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
                GAMEMODE:ShadowText("SECONDARY: Disperse to random location", "CGHUD_6", ScrW() / 2, ScrH() - ScreenScale(40), color_white, shadow, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
            elseif self:GetOwner():GetNWFloat("PTNextTele") >= CurTime() then
                GAMEMODE:ShadowText("RECHARGING", "CGHUD_5", ScrW() / 2, ScrH() - ScreenScale(72), Color(255, 100, 100), shadow, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
                GAMEMODE:ShadowText(string.ToMinutesSeconds(math.max(0, self:GetOwner():GetNWFloat("PTNextTele") - CurTime())), "CGHUD_6", ScrW() / 2, ScrH() - ScreenScale(62), Color(255, 100, 100), shadow, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
            else
                GAMEMODE:ShadowText("WAIT", "CGHUD_5", ScrW() / 2, ScrH() - ScreenScale(72), Color(150, 150, 150), shadow, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
            end
        else
            local str = self:GetTeleMode() == 1 and "RECALL" or "DISPERSE"
            local frac = math.Clamp(1 - (self:GetTeleEndT() - CurTime()) / (self:GetTeleMode() == 1 and GetConVar("pt_tele_recall_delay"):GetFloat() or GetConVar("pt_tele_disperse_delay"):GetFloat()), 0, 1)
            GAMEMODE:ShadowText(str, "CGHUD_5", ScrW() / 2, ScrH() - ScreenScale(72), Color(255, 255, 255), shadow, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)

            surface.SetDrawColor(0, 0, 0, 220)
            surface.DrawRect(ScrW() / 2 - ScreenScale(64), ScrH() - ScreenScale(65), ScreenScale(128), ScreenScale(6), ScreenScale(1))

            surface.SetDrawColor(255, 255, 255)
            surface.DrawRect(ScrW() / 2 - ScreenScale(64), ScrH() - ScreenScale(65), ScreenScale(128) * frac, ScreenScale(6), ScreenScale(1))

            local f = (math.sin(SysTime() * 10) * 0.5 + 0.5)
            surface.SetDrawColor(50 + f * 205, 50 + f * 205, 50)
            surface.DrawOutlinedRect(ScrW() / 2 - ScreenScale(64), ScrH() - ScreenScale(65), ScreenScale(128), ScreenScale(6), ScreenScale(1))
        end


    end
end