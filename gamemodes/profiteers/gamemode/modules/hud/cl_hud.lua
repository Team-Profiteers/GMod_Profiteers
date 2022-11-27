-- HUD
local C_W = Color(255, 255, 255, 255)
local C_B = Color(0, 0, 0, 127)

function CGHUD_FT(text, font, x, y, ax, ay)
	surface.SetFont(font)
	local zx, zy = surface.GetTextSize(text)
	local tx, ty = Lerp(ax, x, y - zx), Lerp(ay, y, y - zy)
	--surface.SetDrawColor( 0, 0, 0, 127)
	--surface.DrawRect(tx, ty, zx, zy)
	surface.SetTextPos(tx, ty)
	surface.DrawText(text)
end

local CLR_R = Color(255, 200, 200, 255)
local CLR_B = Color(0, 0, 0, 255)
local CLR_B2 = Color(0, 0, 0, 100)
local CLR_B3 = Color(0, 0, 0, 200)

local CLR_W = Color(255, 255, 255, 255)
local CLR_W2 = Color(255, 255, 255, 255)
local CLR_R2 = Color(255, 150, 150, 150)

local CLR_FUEL = Color(255, 255, 150, 255)

local mat_vhp = Material("tdm/vehiclehealth.png", "smooth")
local mat_vlock = Material("tdm/vehiclelock.png", "smooth")
local mat_vunlock = Material("tdm/vehicleunlock.png", "smooth")

local mat_v = {
	driver = Material("tdm/vehicle_driver.png", "smooth"),
	gunner = Material("tdm/vehicle_gunner.png", "smooth"),
	passenger = Material("tdm/vehicle_passenger.png", "smooth"),
}

local spawnpro = Material("tdm/spawnpro.png", "smooth")

local am_he = Material("tdm/flame.png", "smooth")

local diamond = Material("tdm/diamond.png", "smooth")
local skull = Material("tdm/skull.png", "smooth")

local money_updates = {}

local toop = {

	["frag"] = {
		Texture = Material("tdm/frag.png", "smooth mips"),
		gap_hor = 12,
		gap_ver = 32,
		rep = 30,
		size = 32,
	},

	["pistol"] = {
		Texture = Material("tdm/ammo/pistol.png", "smooth mips"),
		gap_hor = 10,
		gap_ver = 24,
		rep = 20,
		size = 24,
	},
	["357"] = {
		Texture = Material("tdm/ammo/pistol.png", "smooth mips"),
		gap_hor = 14,
		gap_ver = 32,
		rep = 10,
		size = 32,
	},
	["smg1"] = {
		Texture = Material("tdm/ammo/smg1.png", "smooth mips"),
		gap_hor = 8,
		gap_ver = 32,
		rep = 15,
		size = 32,
	},
	["ar2"] = {
		Texture = Material("tdm/ammo/ar2.png", "smooth mips"),
		gap_hor = 7,
		gap_ver = 33,
		rep = 15,
		size = 32,
	},
	["buckshot"] = {
		Texture = Material("tdm/ammo/buckshot.png", "smooth mips"),
		gap_hor = 14,
		gap_ver = 32,
		rep = 10,
		size = 32,
	},
	["smg1_grenade"] = {
		Texture = Material("tdm/ammo/smg1_grenade.png", "smooth mips"),
		gap_hor = 14,
		gap_ver = 32,
		rep = 10,
		size = 32,
	},

	-- vehicles
	["veh_gun"] = {
		Texture = Material("tdm/ammo/ar2.png", "smooth mips"),
		gap_hor = 4,
		gap_ver = 16,
		rep = 50,
		size = 16,
	},
	["missile"] = {
		Texture = Material("tdm/missile.png", "smooth mips"),
		gap_hor = 14,
		gap_ver = 32,
		rep = 5,
		size = 32,
	},
	["rocket"] = {
		Texture = Material("tdm/rocket.png", "smooth mips"),
		gap_hor = 10,
		gap_ver = 32,
		rep = 20,
		size = 32,
	},
	["cannon"] = {
		Texture = Material("tdm/cannon.png", "smooth mips"),
		gap_hor = 9,
		gap_ver = 32,
		rep = 40,
		size = 32,
	},
}

local refer = {
	["AR2"] = toop["ar2"],
	["SMG1"] = toop["smg1"],
	["SniperPenetratedRound"] = toop["ar2"],
	["SniperRound"] = toop["ar2"],
	["plinking"] = toop["pistol"],
	["Pistol"] = toop["pistol"],
	["RPG_Rocket"] = toop["rocket"],
	["357"] = toop["357"],
	["Buckshot"] = toop["buckshot"],
	["Grenade"] = toop["frag"],
	["SMG1_Grenade"] = toop["smg1_grenade"],
}

local HUToM = 0.0254
local c = CGSS(1)

local function drawbullets(info, x, y, count, count_max)
	surface.SetMaterial(info.Texture)

	local rep = info.rep
	for i = 30, 10, -5 do
		if i % count_max == 0 then
			rep = i
			break
		end
	end

	local li = 1
	local hi = 1
	local s = c * info.size
	local oops = 0
	local limit = math.min(count_max, rep)

	for i = 1, math.max(count, count_max) do
		if i > count then
			surface.SetDrawColor(CLR_B3)
		else
			surface.SetDrawColor(CLR_B2)
		end
		surface.DrawTexturedRect(x - (c * li * info.gap_hor) + c * 2, y - (c * hi * info.gap_ver) + c * 2, s, s)

		if hi == 1 and i >= limit and count + oops > count_max then
			oops = oops - 1
			if oops == -1 then li = li + 1 end
		elseif (i + oops) % rep == 0 then
			hi = hi + 1
			li = 0
		end

		li = li + 1
	end

	local height = hi
	if li == 1 then height = height - 1 end

	li = 1
	hi = 1
	oops = 0
	for i = 1, count do
		if hi == 1 and i > limit and count > count_max then
			surface.SetDrawColor(CLR_R)
		elseif (count - i) % 3 == 0 then
			surface.SetDrawColor(CLR_W)
		else
			surface.SetDrawColor(CLR_W2)
		end

		surface.DrawTexturedRect(x - (c * li * info.gap_hor), y - (c * hi * info.gap_ver), s, s)

		if hi == 1 and i >= limit and count + oops > count_max then
			oops = oops - 1
			if oops == -1 then li = li + 1 end
		elseif (i + oops) % rep == 0 then
			hi = hi + 1
			li = 0
		end

		li = li + 1
	end

	return height * info.gap_ver * c, (limit + 0.5) * info.gap_hor * c
end

hook.Add("HUDPaint", "HUDPaint_DrawABox", function()
	local dzx, dzy = GetConVar("pt_hud_deadzone_x"):GetFloat() * 0.25, GetConVar("pt_hud_deadzone_y"):GetFloat() * 0.25
	local w, h = ScrW() * (1 - dzx * 2), ScrH() * (1 - dzy * 2)
	local ox, oy = ScrW() * dzx, ScrW() * dzy

	local ply = LocalPlayer()

	if not IsValid(ply) or not ply:Alive() then return end

	local wep = ply:GetActiveWeapon()
	local veh, vtyp = nil, nil -- ply:GetTDMVehicle()
	local t = ply:Team()

	local health_mult = ply:Health() / ply:GetMaxHealth()

	CLR_W = team.GetColor(t)
	CLR_W.r = (CLR_W.r * 0.5) + (255 * 0.5)
	CLR_W.g = (CLR_W.g * 0.5) + (255 * 0.5)
	CLR_W.b = (CLR_W.b * 0.5) + (255 * 0.5)
	GAMEMODE:ShadowText("+ " .. ply:Health(), "CGHUD_2", ox + (c * 16), h - (c * 16), CLR_W, CLR_B2, TEXT_ALIGN_LEFT, TEXT_ALIGN_BOTTOM)

	surface.SetDrawColor(CLR_B2)
	surface.DrawOutlinedRect(ox + (c * 128) + (c * 4), h - (c * 46) + (c * 4), c * 200, c * 18, c * 4)

	if health_mult < 1 then
		surface.SetDrawColor(CLR_B2)
		surface.DrawRect(ox + (c * 128) + (c * 4), h - (c * 46) + (c * 8), (c * 200) * math.min(health_mult, 1), c * 10)
	end

	surface.SetDrawColor(CLR_W)
	surface.DrawOutlinedRect(ox + c * 128, h - (c * 46), c * 200, c * 18, c * 4)
	surface.SetDrawColor(CLR_W)
	surface.DrawRect(ox + c * 128, h - (c * 46), (c * 200) *  math.min(health_mult, 1), c * 18)

	if ply:Armor() > 0 then
		surface.SetDrawColor(CLR_B2)
		surface.DrawRect(ox + (c * 128) + (c * 4), h - (c * 46) + (c * 22) + (c * 4), c * 200, c * 4)
		surface.SetDrawColor(CLR_W)
		surface.DrawRect(ox + c * 128, h - (c * 46) + (c * 22), (c * 200) * (ply:Armor() / ply:GetMaxArmor()), c * 4)
	end

	if IsValid(veh) then
		local cur_health, max_health
		local class = veh:GetClass()
		if vtyp == "simfphys" then
			cur_health, max_health = veh:GetCurHealth(), veh:GetMaxHealth()
			class = veh:GetSpawn_List()
		elseif vtyp == "lfs" then
			cur_health, max_health = veh:GetHP(), veh:GetMaxHP()
			-- LFS has shields. Maybe draw it somewhere?
		end

		local vtbl = GAMEMODE.Vehicles[class]

		local mult_h = cur_health / max_health

		GAMEMODE:ShadowText("   " .. math.Round(mult_h * 100), "CGHUD_2", (c * 16), (c * 48) + (c * 16), CLR_W, CLR_B2, TEXT_ALIGN_LEFT, TEXT_ALIGN_BOTTOM)
		surface.SetMaterial(mat_vhp)
		surface.SetDrawColor(CLR_B2)
		surface.DrawTexturedRect( (c * 14) + (c * 4), (c * 29) + (c * 4), (c * 26), (c * 26) ) -- wrench
		surface.DrawOutlinedRect((c * 128) + (c * 4), (c * 36) + (c * 4), c * 200, c * 18, c * 4)

		if mult_h ~= 1 then
			surface.SetDrawColor(CLR_B2)
			surface.DrawRect((c * 128) + (c * 4), (c * 36) + (c * 8), (c * 200) * mult_h, c * 10)
		end

		surface.SetDrawColor(CLR_W)
		surface.DrawTexturedRect( (c * 14), (c * 29), (c * 26), (c * 26) ) -- wrench
		surface.DrawOutlinedRect(c * 128, (c * 36), c * 200, c * 18, c * 4)
		surface.SetDrawColor(CLR_W)
		surface.DrawRect(c * 128, (c * 36), (c * 200) * mult_h, c * 18)

		GAMEMODE:ShadowText( math.Round( veh:GetVelocity():Length() * HUToM / 0.277778 ) .. "km/h", "CGHUD_2", (c * 16), (c * 48) + (c * 16) + (c * 48), CLR_W, CLR_B2, TEXT_ALIGN_LEFT, TEXT_ALIGN_BOTTOM)
		GAMEMODE:ShadowText( math.Round( veh:GetVelocity():Length() ) .. "hU/s", "CGHUD_4", (c * 16), (c * 48) + (c * 16) + (c * 48) + (c * 24), CLR_W, CLR_B2, TEXT_ALIGN_LEFT, TEXT_ALIGN_BOTTOM)

		-- Fuel
		-- GAMEMODE:ShadowText( math.Round( (veh:GetFuel() / veh:GetMaxFuel())*100 ) .. "%", "CGHUD_7", (c * 128), (c * 36) - (c * 10), CLR_FUEL, CLR_B2, TEXT_ALIGN_LEFT, TEXT_ALIGN_BOTTOM)
		if vtyp == "simfphys" then
			surface.SetDrawColor(CLR_B2)
			surface.DrawRect((c * 128) + (c * 4), (c * 36) - (c * 8) + (c * 4), (c * 200) * (veh:GetFuel() / veh:GetMaxFuel()), c * 4)
			surface.SetDrawColor(CLR_FUEL)
			surface.DrawRect(c * 128, (c * 36) - (c * 8), (c * 200) * (veh:GetFuel() / veh:GetMaxFuel()), c * 4)

			surface.SetMaterial(veh:GetIsVehicleLocked() and mat_vlock or mat_vunlock)
			surface.SetDrawColor(CLR_B2)
			surface.DrawTexturedRect((c * 14) + (c * 4), (c * 142) + (c * 4), c * 26, c * 26)
			surface.SetDrawColor(CLR_W)
			surface.DrawTexturedRect(c * 14, c * 142, c * 26, c * 26)
			GAMEMODE:ShadowText(veh:GetIsVehicleLocked() and "LOCKED" or "UNLOCKED", "CGHUD_5", c * 42, c * 154, CLR_W, CLR_B2, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)

			local pSeats = veh:GetPassengerSeats()
			local SeatCount = table.Count( pSeats )
			local seatinfo = vtbl.Seats or {}

			local realseats = {}
			table.insert( realseats, { seat = veh, task = seatinfo[0] or "driver" } )

			for i, v in SortedPairs(pSeats, true) do
				local task = seatinfo[#realseats] or "passenger"
				if task == "gunner" and GetConVar("pt_simfphys_arcade"):GetBool() then
					task = "passenger"
				end
				table.insert( realseats, { seat = v, task = task } )
			end

			for i, v in ipairs(realseats) do
				local pla = v.seat:GetDriver()
				local naame = ""
				local teeam = -1
				if IsValid(pla) then
					naame = pla:Nick()
					teeam = pla:Team()
				else
					pla = false
				end

				surface.SetMaterial(mat_v[v.task])

				--print(veh.pSeat[1])
				local siiiize = 20
				local tc = Color( CLR_W.r, CLR_W.g, CLR_W.b, CLR_W.a )
				if teeam > 0 and t != teeam then
					tc = team.GetColor(teeam)
					tc.r = (tc.r * 0.5) + (255 * 0.5)
					tc.g = (tc.g * 0.5) + (255 * 0.5)
					tc.b = (tc.b * 0.5) + (255 * 0.5)
				end
				if !pla then
					tc.a = tc.a * 0.25
				end
				surface.SetDrawColor(CLR_B2)
				surface.DrawTexturedRect( (c * 36) + (c * 4), (c * 172) + (c * (i-1) * 22) + (c * 3) + (c * 4), (c * siiiize), (c * siiiize) )
				surface.SetDrawColor(tc)
				surface.DrawTexturedRect( (c * 36), (c * 172) + (c * (i-1) * 22) + (c * 3), (c * siiiize), (c * siiiize) )
	
				GAMEMODE:ShadowText( i, "CGHUD_5", (c * 24), (c * 172) + (c * (i-1) * 22), tc, CLR_B2, TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP)
				GAMEMODE:ShadowText( naame, "CGHUD_5", (c * 64), (c * 172) + (c * (i-1) * 22), tc, CLR_B2, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
			end
		end
	end

	local iClip1
	local iClip2
	local iMaxClip1
	local iMaxClip2
	local iAmmoType1
	local iAmmoType2
	local iAmmoCount1
	local iAmmoCount2
	local iFiremode

	local iSimpleClip1 = GetConVar("pt_hud_simpleammo"):GetInt() >= 1
	local iSimpleClip2 = GetConVar("pt_hud_simpleammo"):GetInt() >= 2

	if vtyp == "simfphys" then
		iClip1		= veh:GetNWInt( "CurWPNAmmo", -1 )
		iClip2		= veh:GetNWInt( "CurWPNAmmo2", -1 )
		-- wtfsimfphys = math.max( wtfsimfphys, veh:GetNWInt( "CurWPNAmmo", -1 ) )
		iMaxClip1	= veh:GetNWInt( "MaxWPNAmmo", 0 ) -- wtfsimfphys
		iMaxClip2	= veh:GetNWInt( "MaxWPNAmmo2", -1 )
		iAmmoType1	= 13
		iAmmoType2	= 13
		iAmmoCount1	= 13
		iAmmoCount2	= 13
		iFiremode = veh:GetNWString( "WeaponMode" )
		iAmmoIcon1 = veh:GetNWString( "WPNType", "veh_gun" )
		iAmmoIcon2 = veh:GetNWString( "WPNType2", "veh_gun" )
	elseif vtyp == "lfs" then
		iClip1		= veh:GetAmmoPrimary()
		iClip2		= veh:GetAmmoSecondary()
		iMaxClip1	= veh:GetMaxAmmoPrimary()
		iMaxClip2	= veh:GetMaxAmmoSecondary()
		iAmmoType1	= 13
		iAmmoType2	= 13
		iAmmoCount1	= 13
		iAmmoCount2	= 13
		iFiremode = veh:GetNWString( "WeaponMode" )
		iAmmoIcon1 = veh:GetNWString( "WPNType", "veh_gun" )
		iAmmoIcon2 = veh:GetNWString( "WPNType2", "rocket" )

		iSimpleClip1 = iSimpleClip1 or (math.max(iClip1, iMaxClip1) >= 100)

	elseif IsValid(wep) then
		iClip1		= wep:Clip1()
		iClip2		= wep:Clip2()
		iMaxClip1	= wep:GetMaxClip1()
		iMaxClip2	= wep:GetMaxClip2()
		iAmmoType1	= wep:GetPrimaryAmmoType()
		iAmmoType2	= wep:GetSecondaryAmmoType()
		iAmmoCount1	= ply:GetAmmoCount(iAmmoType1)
		iAmmoCount2	= ply:GetAmmoCount(iAmmoType2)
		if wep.GetFiremodeName then
			iFiremode = wep:GetFiremodeName()
		end
	end


	if IsValid(wep) or veh then
		local offset = 0
		local ax, ay = w - (c * 36), h - (c * 16)

		if iFiremode then
			surface.SetFont("CGHUD_5")
			GAMEMODE:ShadowText(iFiremode, "CGHUD_5", w - c * 24, ay, CLR_W, CLR_B2, TEXT_ALIGN_RIGHT, TEXT_ALIGN_BOTTOM)
			offset = offset + c * 26
		end

		if not iSimpleClip1 then
			local dat = (veh and toop[iAmmoIcon1 or ""]) or refer[game.GetAmmoName(iAmmoType1)] or toop.frag
			local bh, bw = drawbullets(dat, ax, ay - offset, iClip1, iMaxClip1)
			if not GAMEMODE:WeaponHasInfiniteAmmo(wep) then
				GAMEMODE:ShadowText(iAmmoCount1, "CGHUD_3", ax - bw - (c * 12), ay - offset - bh / 2, CLR_W, CLR_B2, TEXT_ALIGN_RIGHT, TEXT_ALIGN_CENTER)
				GAMEMODE:ShadowText("+", "CGHUD_3", ax - (c * -8) - bw, ay - offset - bh / 2, CLR_W, CLR_B2, TEXT_ALIGN_RIGHT, TEXT_ALIGN_CENTER)
			end
			offset = offset + bh
		else
			local str = iClip1 .. " / " .. iMaxClip1
			GAMEMODE:ShadowText(str, "CGHUD_2", w - c * 24, ay - offset, CLR_W, CLR_B2, TEXT_ALIGN_RIGHT, TEXT_ALIGN_BOTTOM)
			if not GAMEMODE:WeaponHasInfiniteAmmo(wep) then
				surface.SetFont("CGHUD_2")
				local tw, th = surface.GetTextSize(str)
				GAMEMODE:ShadowText(iAmmoCount1, "CGHUD_3", ax - c * 24 - tw, ay - offset - th / 2, CLR_W, CLR_B2, TEXT_ALIGN_RIGHT, TEXT_ALIGN_CENTER)
				GAMEMODE:ShadowText("+", "CGHUD_3", ax - tw, ay - offset - th / 2, CLR_W, CLR_B2, TEXT_ALIGN_RIGHT, TEXT_ALIGN_CENTER)
			end

			offset = offset + c * 48
		end

		if not iSimpleClip2 then
			offset = offset + c * 8
			local dat2 = (veh and toop[iAmmoIcon2]) or refer[game.GetAmmoName(iAmmoType2)] or toop.pistol
			local bh2, bw2 = drawbullets(dat2, ax, ay - offset, iClip2, iMaxClip2)
			offset = offset + bh2 / 2
			if iMaxClip2 > 0 and iAmmoType2 ~= -1 and GAMEMODE.AmmoBlacklist[string.lower(game.GetAmmoName(iAmmoType2))] then
				GAMEMODE:ShadowText(iAmmoCount2, "CGHUD_5", ax - bw2 - c * 8, ay - offset, CLR_W, CLR_B2, TEXT_ALIGN_RIGHT, TEXT_ALIGN_CENTER)
				GAMEMODE:ShadowText("+", "CGHUD_5", ax - bw2 - c * -8, ay - offset, CLR_W, CLR_B2, TEXT_ALIGN_RIGHT, TEXT_ALIGN_CENTER)
			end
			offset = offset + bh2 / 2
		else
			GAMEMODE:ShadowText(iClip1, "CGHUD_2", w - c * 24, ay - offset, CLR_W, CLR_B2, TEXT_ALIGN_RIGHT, TEXT_ALIGN_BOTTOM)
			offset = offset + c * 48
		end

			-- if wep.HeatEnabled and wep:HeatEnabled() then
			-- 	local f = (wep:GetHeat() / wep:GetMaxHeat())
			-- 	surface.SetMaterial(am_he)

			-- 	surface.SetDrawColor(CLR_B2)
			-- 	surface.DrawTexturedRect(w - (c * 72) + (c * 4), h - (c * 108) - offset + (c * 4), c * 48, c * 48)

			-- 	surface.SetDrawColor(255, 200 - 150 * f ^ 2, 200 - 150 * f ^ 2, 255)
			-- 	surface.DrawTexturedRectUV(w - (c * 72), h - (c * 108) - offset + (c * 48 * (1-f)), c * 48, c * 48 * f, 0, 1 - f, 1, 1)
			-- 	offset = offset + c * 1.2
			-- end

	end

	local ally_positions = {}
	local vehicle_positions = {}
	cam.Start3D()
	for _, p in pairs(player.GetAll()) do
		if p ~= ply and p:Team() == ply:Team() and p:Team() != TEAM_UNASSIGNED then
			table.insert(ally_positions, {p, (p:GetPos() + Vector(0, 0, 80)):ToScreen()})
		end
	end
	for _, t in pairs(GAMEMODE.SpawnedVehicles or {}) do
		local v = t.Entity
		if not IsValid(v) then continue end
		if ply:GetSimfphys() == v then continue end
		class = t.VehicleName

		local cur_team, occupied = GAMEMODE:GetVehicleTeam(v, true)
		if GAMEMODE.Vehicles[class] and cur_team == ply:Team() then --(hasally or (not occupied and t.Team == ply:Team())) then
			table.insert(vehicle_positions, {v, (v:GetPos() + Vector(0, 0, 100)):ToScreen(), GAMEMODE.VehiclePadTypes[GAMEMODE.Vehicles[class].Type].Icon, class, occupied})
		end
	end
	cam.End3D()

	for k, v in pairs(ally_positions) do
		local ply_dist = EyePos():DistToSqr(v[1]:GetPos() + Vector(0, 0, 80))
		local s = math.Clamp(1 - ply_dist / 4096 ^ 2, 0.5, 1) * 32
		local x, y = v[2].x, v[2].y

		local mouse_dist = math.sqrt(math.abs(ScrW() * 0.5 - x) ^ 2 + math.abs(ScrH() * 0.5 - y) ^ 2)
		local mouse_range = CGSS(math.Clamp(1 - ply_dist / 2048 ^ 2, 0.1, 1) * 256)
		if mouse_dist < mouse_range then
			GAMEMODE:ShadowText(v[1]:GetName(), "CGHUD_24_Unscaled", x, y - s / 2, CLR_W, CLR_B2, TEXT_ALIGN_CENTER, TEXT_ALIGN_BOTTOM, true)
		end

		surface.SetDrawColor(CLR_W.r, CLR_W.g, CLR_W.b, 150)
		surface.SetMaterial(v[1]:Alive() and diamond or skull)
		surface.DrawTexturedRect(x - s * 0.5, y - s * 0.5, s, s)
	end

	for k, v in pairs(vehicle_positions) do
		local ply_dist = EyePos():DistToSqr(v[1]:GetPos() + Vector(0, 0, 80))
		local s = math.Clamp(1 - ply_dist / 4096 ^ 2, 0.5, 1) * 64
		local x, y = v[2].x, v[2].y

		if v[5] then
			surface.SetDrawColor(CLR_W.r, CLR_W.g, CLR_W.b, 200)
		else
			surface.SetDrawColor(255, 255, 255, 200)
		end

		surface.SetMaterial(v[3])
		surface.DrawTexturedRect(x - s * 0.5, y - s * 0.5, s, s)
	end

	local display_money
	for k, v in pairs(money_updates) do
		if v[1] + 2 > CurTime() then
			if not display_money then display_money = v[3] end
			local f = 1 - math.Clamp((CurTime() - v[1] - 0.5) / 1.5, 0, 1)
			CLR_W.a = f * 255
			CLR_B2.a = f * 127
			local str = (v[2] > 0 and "+" or "-") .. GAMEMODE:FormatMoney(v[2])
			GAMEMODE:ShadowText(str, "CGHUD_4", 0 + CGSS(16), h - CGSS(80) - f ^ 2 * CGSS(16), CLR_W, CLR_B2, TEXT_ALIGN_LEFT, TEXT_ALIGN_BOTTOM)
		else
			table.remove(money_updates, k)
		end
	end
	display_money = display_money or ply:GetNWInt("pt_money", 0)

	local a = 1
	CLR_W.a = a * 255
	CLR_B2.a = a * 127
	GAMEMODE:ShadowText(GAMEMODE:FormatMoney(display_money), "CGHUD_3", 0 + CGSS(16), h - CGSS(64), CLR_W, CLR_B2, TEXT_ALIGN_LEFT, TEXT_ALIGN_BOTTOM)

	CLR_W.a = 255
	CLR_B2.a = 127
end)

net.Receive("pt_updatemoney", function()
	local t = CurTime()
	if money_updates[#money_updates] and t - money_updates[#money_updates][1] <= 0.5 then
		money_updates[#money_updates] = {t, money_updates[#money_updates][2] + net.ReadInt(32), money_updates[#money_updates][3]}
	else
		table.insert(money_updates, {t, net.ReadInt(32), net.ReadInt(32)})
	end
	if money_updates[#money_updates][2] > 0 then
		LocalPlayer():EmitSound("profiteers/money_pickup.wav", 70, math.Rand(95, 105), 0.75)
	end
end)

local hide = {
	["CHudHealth"] = true,
	["CHudBattery"] = false,
	["CHudDamageIndicator"] = true,
	["CHudAmmo"] = true,
	["CHudSecondaryAmmo"] = true,
	["CHudBattery"] = true
}

hook.Add("HUDShouldDraw", "CG_HUDShouldDraw", function(name)
	if hide[name] then return false end
end)

function GM:HUDDrawTargetID()
	local tr = util.GetPlayerTrace(LocalPlayer())
	local trace = util.TraceLine(tr)
	if not trace.Hit then return end
	if not trace.HitNonWorld then return end
	local text = "ERROR"
	local font = "CGHUD_32_Unscaled"

	if trace.Entity:IsPlayer() and trace.Entity:Team() == LocalPlayer():Team() then
		text = trace.Entity:Nick()
	else
		return
	end

	--text = trace.Entity:GetClass()
	surface.SetFont(font)
	local w, h = surface.GetTextSize(text)
	local MouseX, MouseY = gui.MousePos()

	if MouseX == 0 and MouseY == 0 then
		MouseX = ScrW() / 2
		MouseY = ScrH() / 2
	end

	local x = MouseX
	local y = MouseY
	x = x - w / 2
	y = y + 64

	local clr = self:GetTeamColor(trace.Entity)
	clr.a = 255

	GAMEMODE:ShadowText(text, font, x, y, clr, CLR_B2, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP, true)

	local f = trace.Entity:Health() / trace.Entity:GetMaxHealth()

	surface.SetDrawColor(CLR_B2)
	surface.DrawOutlinedRect(MouseX - 64, MouseY + 100, 128, 8, 2)

	if trace.Entity:Health() ~= 100 then
		surface.SetDrawColor(CLR_B2)
		surface.DrawRect(MouseX - 64, MouseY + 100, 128 * f, 8)
	end

	surface.SetDrawColor(clr)
	surface.DrawOutlinedRect(MouseX - 64, MouseY + 100, 128, 8, 2)
	surface.SetDrawColor(clr)
	surface.DrawRect(MouseX - 64, MouseY + 100, 128 * f, 8)
end