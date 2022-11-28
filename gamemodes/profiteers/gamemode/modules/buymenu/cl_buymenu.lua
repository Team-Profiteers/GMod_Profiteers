hook.Add("PopulateShop", "AddShopContent", function(pnlContent, tree, _)
    local categorized = {}

    for k, v in pairs(Profiteers.Buyables) do
        local Category = v.Category or "Other"

        if not isstring(Category) then
            Category = tostring(Category)
        end

        categorized[Category] = categorized[Category] or {}

        if v.EntityClass then
            if scripted_ents.Get(v.EntityClass) then
                v.Name = v.Name or scripted_ents.Get(v.EntityClass).PrintName
                v.Icon = v.Icon or scripted_ents.Get(v.EntityClass).IconOverride
            elseif weapons.Get(v.EntityClass) then
                v.Name = v.Name or weapons.Get(v.EntityClass).PrintName
                v.Icon = v.Icon or weapons.Get(v.EntityClass).IconOverride
            else
                v.Name = v.Name or v.EntityClass or "Item"
            end
        end

        v.SpawnName = k
        table.insert(categorized[Category], v)
    end

    --
    -- Add a tree node for each category
    --
    for CategoryName, v in SortedPairs(categorized) do
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

            for k, ent in SortedPairsByMemberValue(v, "Price") do
                local icon = vgui.Create("PTShopIcon", node)
                self.PropPanel:Add(icon)
                icon:SetSpawnName(ent.SpawnName)
                icon:SetItemTable(ent)
                icon:SetColor(Color(135, 206, 250, 255))
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

spawnmenu.AddCreationTab("Shop", function()
    local ctrl = vgui.Create("SpawnmenuContentPanel")
    ctrl:EnableSearch("shop", "PopulateShop")
    ctrl:CallPopulateHook("PopulateShop")

    return ctrl
end, "icon16/money.png", 20)

concommand.Add("pt_buy", function(ply, cmd, args, argStr)
    local itemtbl = Profiteers.Buyables[args[1]]
    if not itemtbl then return end

    if ply:GetMoney() < (itemtbl.Price or 0) then
        surface.PlaySound("items/medshotno1.wav")
        return
    end
    if itemtbl.EntityClass and ply:HasWeapon(itemtbl.EntityClass) and not itemtbl.AmmoOnRebuy then
        input.SelectWeapon(ply:GetWeapon(itemtbl.EntityClass))
        return
    end
    if itemtbl.CanBuy and not itemtbl:CanBuy(ply) then
        surface.PlaySound("items/medshotno1.wav")
        return
    end
    if itemtbl.EntityLimit and itemtbl.EntityLimit <= ply:CountBoughtEntities(itemclass) then
        surface.PlaySound("items/medshotno1.wav")
        return
    end

    net.Start("pt_buy")
        net.WriteString(args[1])
    net.SendToServer()
end, function(cmd, args)
    local ret = {}
    for k, _ in pairs(Profiteers.Buyables) do
        table.insert(ret, "pt_buy " .. k)
    end
    return ret
end, "Buy the specified item.")

net.Receive("pt_buy", function()
    local entindex = net.ReadUInt(16)
    local itemclass = net.ReadString()
    timer.Create("pt_buy_" .. entindex, 0.1, 50, function()
        local ent = Entity(entindex)
        if IsValid(ent) then
            LocalPlayer().BoughtEntities = LocalPlayer().BoughtEntities or {}
            LocalPlayer().BoughtEntities[itemclass] = LocalPlayer().BoughtEntities[itemclass] or {}
            table.insert(LocalPlayer().BoughtEntities[itemclass], ent)
            timer.Remove("pt_buy_" .. entindex)
        end
    end)
end)