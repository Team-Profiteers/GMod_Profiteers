util.AddNetworkString("pt_buy")
util.AddNetworkString("pt_vehicle")

net.Receive("pt_buy", function(len, ply)
	local itemtbl = Profiteers.Buyables[net.ReadString()]
	if not itemtbl then return end

	if ply:GetMoney() < (itemtbl.Price or 0) then
		return
	end
	if itemtbl.EntityClass and ply:HasWeapon(itemtbl.EntityClass) and not itemtbl.AmmoOnRebuy then
		return
	end
	if itemtbl.CanBuy and itemtbl:CanBuy(ply) then
		return
	end

	ply:AddMoney(-itemtbl.Price)
	ply:EmitSound("items/ammopickup.wav", 70)

	if itemtbl.EntityClass and not ply:HasWeapon(itemtbl.EntityClass) then
		ply:Give(itemtbl.EntityClass) -- this actually also works for entities (places it at user's position)
	elseif itemtbl.AmmoOnRebuy then
		ply:GiveAmmo(itemtbl.AmmoOnRebuyAmount, itemtbl.AmmoOnRebuy)
	end

	if itemtbl.OnBuy then
		itemtbl:OnBuy(ply)
	end
end)