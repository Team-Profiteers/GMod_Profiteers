local PANEL = {}

local c_w, c_s = Color(255, 255, 255, 200), Color(0, 0, 0, 127)
local c_r = Color(255, 100, 100, 255)

AccessorFunc(PANEL, "m_Color", "Color")
AccessorFunc(PANEL, "m_SpawnName", "SpawnName")
AccessorFunc(PANEL, "m_NPCWeapon", "NPCWeapon")
AccessorFunc(PANEL, "m_bAdminOnly", "AdminOnly")
AccessorFunc(PANEL, "m_bIsNPCWeapon", "IsNPCWeapon")
--AccessorFunc(PANEL, "m_ItemTbl", "ItemTable")
AccessorFunc(PANEL, "m_Price", "Price", FORCE_NUMBER)

function PANEL:Init()
	self:SetPaintBackground( false )
	local sw, sh = self:GetParent():GetParent():GetParent():GetSize()
	self:SetSize( 400, 128 ) -- TODO: get real long n har. nvm
	self:SetText( "" )
	self:SetDoubleClickingEnabled( false )

	self.Image = self:Add( "DImage" )
	self.Image:SetPos( 3, 3 )
	self.Image:SetSize( 128 - 6, 128 - 6 )
	self.Image:SetVisible( false )

	self.Border = 0
end

function PANEL:GetItemTable()
	return self.m_ItemTable or {}
end

function PANEL:SetItemTable(tbl)
	self.m_ItemTable = tbl
	self:SetName(tbl.Name)
	self:SetDescription(tbl.Description, tbl.Description2)
	self:SetMaterial(tbl.Icon or "entities/" .. tbl.SpawnName .. ".png")
end

function PANEL:SetName( name )
	self:SetTooltip(name)
	self.m_NiceName = name
end

function PANEL:SetDescription( desc, desc2 )
	self:SetTooltip(self.m_NiceName .. "\n" .. desc .. (desc2 and ("\n" .. desc2) or ""))
	self.Description = desc
	self.Description2 = desc2
end

function PANEL:SetMaterial(name)
	self.m_MaterialName = name
	local mat = Material(name)

	-- Look for the old style material
	if not mat or mat:IsError() then
		name = name:Replace("entities/", "VGUI/entities/")
		name = name:Replace(".png", "")
		mat = Material(name)
	end

	-- Couldn't find any material.. just return
	if not mat or mat:IsError() then return end
	self.Image:SetMaterial(mat)
end

function PANEL:GetPrice()
	return self:GetItemTable().Price or 0
end

function PANEL:DoRightClick()
	local pCanvas = self:GetSelectionCanvas()
	if IsValid(pCanvas) and pCanvas:NumSelectedChildren() > 0 and self:IsSelected() then return hook.Run("SpawnlistOpenGenericMenu", pCanvas) end
	self:OpenMenu()
end

function PANEL:DoClick()
	RunConsoleCommand("pt_buy", self:GetSpawnName())
end

function PANEL:OpenMenu()
end

function PANEL:OnDepressionChanged(b)
end

function PANEL:Paint(w, h)

	local itemtbl = self:GetItemTable()

	if self.Depressed and not self.Dragging then
		if self.Border ~= 8 then
			self.Border = 8
			self:OnDepressionChanged(true)
		end
	else
		if self.Border ~= 0 then
			self.Border = 0
			self:OnDepressionChanged(false)
		end
	end

	surface.SetDrawColor(255, 255, 255, 255)

	if not dragndrop.IsDragging() and (self:IsHovered() or self.Depressed or self:IsChildHovered()) then
		surface.SetMaterial(Material("entities/uchover.png"))
		surface.DrawTexturedRect(self.Border, self.Border, w, h)
	end

	-- Name
	if assert(self.m_NiceName, "Holy balls no weapon name??") then
		surface.SetFont("PTShopicon")
		surface.SetTextPos((128 + 16) + 2, 14 + 2)
		surface.SetTextColor(c_s)
		surface.DrawText(self.m_NiceName or "idk")
		surface.SetTextPos(128 + 16, 14)
		surface.SetTextColor(color_white)
		surface.DrawText(self.m_NiceName or "idk")
	end

	-- Price
	local textprice
	if itemtbl.EntityClass and LocalPlayer():HasWeapon(itemtbl.EntityClass) and not itemtbl.AmmoOnRebuy then
		textprice = "OWNED"
		surface.SetFont("PTShopicon2")
		surface.SetTextPos((128 + 16) + 2, (14 + 32) + 2)
		surface.SetTextColor(c_s)
		surface.DrawText(textprice)
		surface.SetTextPos(128 + 16, 14 + 32)
		surface.SetTextColor(color_white)
		surface.DrawText(textprice)
	else
		textprice = GAMEMODE:FormatMoney(self:GetPrice() or 0)
		surface.SetFont("PTShopicon2")
		surface.SetTextPos((128 + 16) + 2, (14 + 32) + 2)
		surface.SetTextColor(c_s)
		surface.DrawText(textprice)
		surface.SetTextPos(128 + 16, 14 + 32)
		surface.SetTextColor(LocalPlayer():GetMoney() > self:GetPrice() and color_white or c_r)
		surface.DrawText(textprice)
	end

	if itemtbl.EntityLimit then
		local cur = LocalPlayer():CountBoughtEntities(self:GetSpawnName())
		local wprice = surface.GetTextSize(textprice)
		local textlimit = "(Limit " .. cur .. "/" .. itemtbl.EntityLimit .. ")"
		surface.SetFont("PTShopicon2")
		surface.SetTextPos((128 + 16) + 2 + wprice + 32, (14 + 32) + 2)
		surface.SetTextColor(c_s)
		surface.DrawText(textlimit)
		surface.SetTextPos(128 + 16 + wprice + 32, 14 + 32)
		surface.SetTextColor(LocalPlayer():GetMoney() > self:GetPrice() and color_white or c_r)
		surface.DrawText(textlimit)
	end

	if self.Description then
		surface.SetFont("PTShopicon3")
		surface.SetTextPos((128 + 16) + 2, (14 + 50 + 8) + 2)
		surface.SetTextColor(c_s)
		surface.DrawText(self.Description)
		surface.SetTextPos(128 + 16, 14 + 50 + 8)
		surface.SetTextColor(c_w)
		surface.DrawText(self.Description)
	end
	if self.Description2 then
		surface.SetFont("PTShopicon3")
		surface.SetTextPos((128 + 16) + 2, (14 + 50 + 8 + 20) + 2)
		surface.SetTextColor(c_s)
		surface.DrawText(self.Description2)
		surface.SetTextPos(128 + 16, 14 + 50 + 8 + 20)
		surface.SetTextColor(c_w)
		surface.DrawText(self.Description2)
	end

	render.PushFilterMag(TEXFILTER.ANISOTROPIC)
	render.PushFilterMin(TEXFILTER.ANISOTROPIC)
	self.Image:PaintAt(3 + self.Border, 3 + self.Border, 128 - 8 - self.Border * 2, 128 - 8 - self.Border * 2)
	render.PopFilterMin()
	render.PopFilterMag()

	--surface.DrawTexturedRect( self.Border, self.Border, w-self.Border*2, h-self.Border*2 )
end

function PANEL:ScanForNPCWeapons()
	if self.HasScanned then return end
	self.HasScanned = true

	for _, v in pairs(list.Get("NPCUsableWeapons")) do
		if v.class == self:GetSpawnName() then
			self:SetIsNPCWeapon(true)
			break
		end
	end
end

function PANEL:PaintOver(w, h)
	self:DrawSelections()
end

function PANEL:ToTable(bigtable)
	local tab = {}
	tab.nicename = self.m_NiceName
	tab.material = self.m_MaterialName
	tab.admin = self:GetAdminOnly()
	tab.spawnname = self:GetSpawnName()
	tab.weapon = self:GetNPCWeapon()
	table.insert(bigtable, tab)
end

function PANEL:Copy()
	local copy = vgui.Create("ContentIcon", self:GetParent())
	copy:SetSpawnName(self:GetSpawnName())
	copy:SetItemTable(self:GetItemTable())
	copy:CopyBase(self)
	copy.DoClick = self.DoClick
	copy.OpenMenu = self.OpenMenu
	copy.OpenMenuExtra = self.OpenMenuExtra

	return copy
end

vgui.Register("PTShopIcon", PANEL, "DButton")


surface.CreateFont( "PTShopicon", {
	font = "Bahnschrift",
	size = 36,
	weight = 0,
	blursize = 0,
	antialias = true,
} )

surface.CreateFont( "PTShopicon2", {
	font = "Bahnschrift Light",
	size = 24,
	weight = 0,
	blursize = 0,
	antialias = true,
} )

surface.CreateFont( "PTShopicon3", {
	font = "Bahnschrift Light",
	size = 20,
	weight = 0,
	blursize = 0,
	antialias = true,
} )