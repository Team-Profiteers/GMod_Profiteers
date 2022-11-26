util.AddNetworkString("pt_updatemoney")

hook.Add("Initialize", "pt_money", function()
	sql.Query([[CREATE TABLE IF NOT EXISTS `pt_money` (
		sid64 BIGINT unsigned,
		balance BIGINT,
		earnings BIGINT,
		PRIMARY KEY (`sid64`)
	);]])
end)

local Player = FindMetaTable("Player")

function Player:SaveMoney()
	local sid64 = tostring(self:SteamID64() or 0)
	local amt = math.floor(self:GetNWInt("pt_money", 0))
	local earnings = math.floor(self:GetNWInt("pt_earnings", 0))

	local data = sql.Query("SELECT * FROM pt_money WHERE sid64 = " .. sid64 .. ";")
	if data then
		sql.Query("UPDATE pt_money SET balance = " .. amt .. ", earnings = " .. earnings .. " WHERE sid64 = " .. sid64 .. ";")
	else
		sql.Query("INSERT INTO pt_money ( sid64, balance, earnings ) VALUES ( " .. sid64 .. ", " .. amt .. "," .. earnings .. " )")
	end
end

function Player:LoadMoney()
	local sid64 = tostring(self:SteamID64() or 0)

	local data = sql.QueryRow("SELECT * FROM pt_money WHERE sid64 = " .. sid64 .. ";")
	if data then
		self:SetNWInt("pt_money", tonumber(data.balance))
		self:SetNWInt("pt_earnings", tonumber(data.earnings))
	else
		self:SetNWInt("pt_money", GetConVar("pt_money_starting"):GetInt())
		self:SetNWInt("pt_earnings", 0)
		sql.Query("INSERT INTO pt_money ( sid64, balance, earnings ) VALUES ( " .. sid64 .. ", " .. self:GetNWInt("pt_money", 0) .. "," .. "0" .. " )")
	end
end

hook.Add("PlayerInitialSpawn", "pt_money", function(ply)
	ply:LoadMoney()
end)

hook.Add("PlayerDisconnected", "pt_money", function(ply)
	ply:SaveMoney()
end)

hook.Add("ShutDown", "pt_money", function()
	for _, ply in ipairs(player.GetAll()) do
		ply:SaveMoney()
	end
end)

timer.Create("pt_money", 60, 0, function()
	for _, ply in ipairs(player.GetAll()) do
		if ply._money_dirty then
			ply:SaveMoney()
			ply._money_dirty = false
		end
	end
end)

function Player:SetMoney(amt)
	self._money_dirty = true
	self:SetNWInt("pt_money", math.floor(amt))
end

function Player:AddMoney(amt, no_notify, not_earnings)
	self._money_dirty = true

	if not no_notify then
		net.Start("pt_updatemoney")
			net.WriteInt(amt, 32)
			net.WriteInt(self:GetNWInt("pt_money", 0), 32) -- write anyways because we want to know the old amount (nwint refresh may not catch up)
		net.Send(self)
	end

	self:SetNWInt("pt_money", self:GetNWInt("pt_money", 0) + math.floor(amt))

	if not not_earnings and amt > 0 then
		self:SetNWInt("pt_earnings", self:GetNWInt("pt_earnings", 0) + math.floor(amt))
	end
end

hook.Add("DoPlayerDeath", "pt_money", function(ply, attacker, dmginfo)
	if attacker:IsPlayer() and attacker ~= ply and attacker:Team() ~= ply:Team() and GetConVar("pt_money_per_kill"):GetInt() > 0 then
		local reward = GetConVar("pt_money_per_kill"):GetInt()
		local class = dmginfo:GetInflictor():IsWeapon() and dmginfo:GetInflictor():GetClass() or attacker:GetActiveWeapon():GetClass()

		reward = reward * (Profiteers.WeaponRewardMultipliers[class] or 1)

		attacker:AddMoney(reward)
	end

	// Drop money
	local loss = math.Round(ply:GetMoney() * 0.5)

	if loss > 0 then
		ply:AddMoney(-loss)

		local ent = ents.Create("pt_money")
		ent:SetPos(ply:GetPos() + Vector(0, 0, 20))
		ent:SetAmount(loss)
		ent:Spawn()
	end
end)