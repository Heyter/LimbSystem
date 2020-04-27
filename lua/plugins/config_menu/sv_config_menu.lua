netstream.Hook('LCM_DataChanged', function(player, data)
	if not player:IsSuperAdmin() then return end
	
	file.CreateDir("limbsystem/")
	
	local contents = file.Read('limbsystem/cvars.txt', "DATA")
	if (contents and contents != "") then
		local status, decoded = pcall(pon.decode, contents)
		
		if (status and decoded) then
			local file_data = decoded[1]
			
			if file_data then
				for cvar, value in pairs(data) do
					if file_data[cvar] then
						file_data[cvar] = value
					end
				end
				
				table.Merge(data, file_data)
				file_data = nil
			end
		end
	end
	
	file.Write('limbsystem/cvars.txt', pon.encode({data}))
	
	for cvar, value in pairs(data) do
		Limb:AddCvar(cvar, value)
	end
	
	netstream.Start(nil, "LCM_DataChanged", data)
	
	player:ChatPrint("Settings saved. (Optional) Reboot the server.")
end)