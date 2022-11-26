function GM:ContextMenuOpen()
	return GetConVar("pt_sandbox"):GetBool()
end

SPAWN_Destroy = {
	["#spawnmenu.category.dupes"] = true,
	["#spawnmenu.category.saves"] = true,
	["#spawnmenu.category.npcs"] = true,
	["#spawnmenu.category.vehicles"] = true,
	["#spawnmenu.category.entities"] = true,
	["#spawnmenu.category.postprocess"] = true,
	// ["#spawnmenu.content_tab"] = true,
	["simfphys"] = true,
}

SPAWN_Save = {
}

hook.Add("SpawnMenuEnabled", "TDM_SpawnMenuEnabled", function()
		for item, destroy in pairs(SPAWN_Destroy) do
			print( "item: ", item )
			if !GetConVar("pt_sandbox"):GetBool() then
				print("\t- item destroying")
				if spawnmenu.GetCreationTabs()[item] then
					print("\t- save: success")
					SPAWN_Save[item] = spawnmenu.GetCreationTabs()[item]
				else
					print("\t- save: failure")
				end
				spawnmenu.GetCreationTabs()[item] = nil
			else
				print("\t- item restoring")
				if spawnmenu.GetCreationTabs()[item] then
					print("\t- restore: not missing, saved")
					SPAWN_Save[item] = spawnmenu.GetCreationTabs()[item]
				elseif SPAWN_Save[item] then
					print("\t- restore: successful")
					spawnmenu.GetCreationTabs()[item] = SPAWN_Save[item]
				else
					print("\t- restore: failure")
				end
			end
		end
end)

hook.Add("PopulateWeapons", "AddWeaponContent", function(pnlContent, tree, node)
	-- Loop through the weapons and add them to the menu
	local Weapons = list.Get("Weapon")
	local Categorised = {}

	-- Build into categories
	for k, weapon in pairs(Weapons) do
		if not weapon.Spawnable or (!GetConVar("pt_sandbox"):GetBool() and not Profiteers:IsSpawnableWeapon(weapon.ClassName)) then continue end
		local Category = weapon.Category or "Other2"

		if not isstring(Category) then
			Category = tostring(Category)
		end

		Categorised[Category] = Categorised[Category] or {}
		table.insert(Categorised[Category], weapon)
	end

	Weapons = nil

	-- Loop through each category
	for CategoryName, v in SortedPairs(Categorised) do
		-- Add a node to the tree
		local node = tree:AddNode(CategoryName, "icon16/gun.png")

		-- When we click on the node - populate it using this function
		node.DoPopulate = function(self)
			-- If we've already populated it - forget it.
			if self.PropPanel then return end
			-- Create the container panel
			self.PropPanel = vgui.Create("ContentContainer", pnlContent)
			self.PropPanel:SetVisible(false)
			self.PropPanel:SetTriggerSpawnlistChange(false)

			for k, ent in SortedPairsByMemberValue(v, "PrintName") do
				spawnmenu.CreateContentIcon(ent.ScriptedEntityType or "weapon", self.PropPanel, {
					nicename = ent.PrintName or ent.ClassName,
					spawnname = ent.ClassName,
					material = ent.IconOverride or "entities/" .. ent.ClassName .. ".png",
					admin = ent.AdminOnly
				})
			end
		end

		-- If we click on the node populate it and switch to it.
		node.DoClick = function(self)
			self:DoPopulate()
			pnlContent:SwitchPanel(self.PropPanel)
		end
	end

	-- Select the first node
	local FirstNode = tree:Root():GetChildNode(0)

	if IsValid(FirstNode) then
		FirstNode:InternalDoClick()
	end
end)