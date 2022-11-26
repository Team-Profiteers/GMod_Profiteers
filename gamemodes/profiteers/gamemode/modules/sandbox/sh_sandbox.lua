Profiteers.EntityBlacklist = {["arccw_uo_m67"] = true }

function Profiteers:IsSpawnableWeapon(class)

	if Profiteers.EntityBlacklist[class] then return false end
	if Profiteers.BuyableEntities[class] then return false end

	if not (weapons.IsBasedOn(class, "arccw_base") or
		weapons.IsBasedOn(class, "bobs_gun_base") or
		weapons.IsBasedOn(class, "bobs_scoped_base") or
		weapons.IsBasedOn(class, "bobs_shotty_base") or
		weapons.IsBasedOn(class, "arccw_base_melee") or
		weapons.IsBasedOn(class, "arccw_base_nade") or
		weapons.IsBasedOn(class, "arccw_uo_grenade_base") or
		weapons.IsBasedOn(class, "arc9_base")) then
		return false
	end

	return true
end

Profiteers.DenySpawningCats = {
	["dynamite"] = true,
	["sents"] = true,
	["item_ammo_crates"] = true,
	["item_item_crates"] = true,
	["vehicles"] = true,
	["ragdolls"] = true,
	["npcs"] = true,
}

hook.Add("PlayerCheckLimit", "ArcCWTDM_PlayerCheckLimit", function(ply, name, cur, max)
	-- This disables spawning or using anything else
	if Profiteers.AllowSpawningCats[name] then return end

	if not ply:IsAdmin() then return false end
end)

hook.Add("PlayerGiveSWEP", "BlockPlayerSWEPs", function(ply, class, swep)
	if not ply:IsAdmin() and (not Profiteers:IsSpawnableWeapon(class)) then return false end
end)

function GM:PlayerNoClip(pl, on)
	-- Admin check this
	if not on then return true end
	-- Allow noclip if we're in single player and living

	return IsValid(pl) and pl:Alive() and pl:IsAdmin()
end