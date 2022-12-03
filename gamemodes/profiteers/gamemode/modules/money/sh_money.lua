local Player = FindMetaTable("Player")

function Player:GetMoney()
	return self:GetNWInt("pt_money", 0)
end

function Player:GetEarnings()
	return self:GetNWInt("pt_earnings", 0)
end

function Profiteers:GetMoneyRampUp()
	return 1 + (CurTime() * 0.5 / 600)
end