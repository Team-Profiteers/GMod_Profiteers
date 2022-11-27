GM.AmmoBlacklist = {
	["grenade"] = true,
	["rpg_round"] = true,
	["smg1_grenade"] = true,
	["ar2altfire"] = true,
	["slam"] = true,

	-- urban stuff
	["arccw_uo_rgd5"] = true,
}

function GM:WeaponHasInfiniteAmmo(wep)
	if wep.ArcCW then
		return wep:HasInfiniteAmmo()
	elseif wep.ARC9 then
		return wep:GetInfiniteAmmo()
	end

	return not GAMEMODE.AmmoBlacklist[string.lower(game.GetAmmoName(wep:GetPrimaryAmmoType()) or "")]
end

hook.Add("O_Hook_Override_InfiniteAmmo", "profiteers_infiniteammo", function(wep, data)
	local ammo = string.lower(wep:GetBuff_Override("Override_Ammo", wep.Primary.Ammo))
	if not GAMEMODE.AmmoBlacklist[ammo] then
		return {current = true}
	end
end)

hook.Add("ARC9_InfiniteAmmoHook", "profiteers_infiniteammo_arc9", function(wep, data)
	local ammo = string.lower(wep:GetProcessedValue("Ammo"))
	if wep:GetUBGL() then
		ammo = string.lower(wep:GetProcessedValue("UBGLAmmo"))
	end
	if not GAMEMODE.AmmoBlacklist[ammo] then
		return {current = true}
	end
end)