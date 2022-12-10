hook.Add("SetupMove", "Profiteers_Drive_SetupMove", function(ply, mv, cmd)
    if !IsValid(ply:GetVehicle()) then return end
    local seat = ply:GetVehicle()
    local veh = seat:GetParent()
    if !veh.ProfiteersPredictedVehicle then return end

    veh:PTPV_SetupMove(ply, mv, cmd)
end)

hook.Add("VehicleMove", "Profiteers_Drive_VehicleMove", function(ply, seat, mv)
    local veh = seat:GetParent()
    if !veh.ProfiteersPredictedVehicle then return end

    veh:PTPV_Move(ply, mv)
end)

hook.Add("FinishMove", "Profiteers_Drive_FinishMove", function(ply, mv)
    if !IsValid(ply:GetVehicle()) then return end
    local seat = ply:GetVehicle()
    local veh = seat:GetParent()
    if !veh.ProfiteersPredictedVehicle then return end

    veh:PTPV_FinishMove(ply, mv)
end)