if (!Limb) then
	return MsgC(Color(255,0,0), "[SHARED] Limb table not initializing!\n")
end

if (!Limb:GetCvar("system")) then
	return MsgC(Color(255,0,0), "[SHARED] Limb not enabled!\n")
end


local playerMeta = FindMetaTable("Player")

--- Returns `true` if the player is able to shoot their weapon.
-- @realm shared
-- @treturn bool Whether or not the player can shoot their weapon
function playerMeta:Limb_CanShootWeapon()
	local weapon = self:GetActiveWeapon()
	if not IsValid(weapon) then return true end
	
	local wep_tbl = Limb:GetCvar('always_can_shoot')
	local wep_stored = istable(wep_tbl) and wep_tbl[weapon:GetClass()]
	if wep_stored then
		return true
	end
	
	return self:getNetVar("limb_raised_canShoot", false)
end

local KEY_BLACKLIST = bit.bor(IN_ATTACK, IN_ATTACK2)
hook.Add("StartCommand", "Limb.StartCommand", function(player, command)
	if (!player:Limb_CanShootWeapon()) then
		command:RemoveKey(KEY_BLACKLIST)
	end
end)

if SERVER then
	hook.Add("TickLimbArmsBroken", "Limb.TickLimbArmsBroken", function(player, broken)
		if broken then
			player:setNetVar("limb_raised_canShoot", false)
		else
			player:setNetVar("limb_raised_canShoot", true)
		end
	end)
else
	local LOWERED_ANGLES = Angle(30, -30, -25)
	hook.Add('CalcViewModelView', 'Limb.CalcViewModelView', function(weapon, _, _, _, _, eyeAngles)
		if (not IsValid(weapon)) then return end

		local vm_angles = eyeAngles
		local client = LocalPlayer()
		local value = 0

		if (not client:Limb_CanShootWeapon()) then
			value = 100
		end

		local fraction = (client.RaisedFrac or 0) / 100
		local rotation = weapon.LowerAngles or LOWERED_ANGLES
		
		if (weapon.LowerAngles2) then
			rotation = weapon.LowerAngles2
		end
		
		vm_angles:RotateAroundAxis(vm_angles:Up(), rotation.p * fraction)
		vm_angles:RotateAroundAxis(vm_angles:Forward(), rotation.y * fraction)
		vm_angles:RotateAroundAxis(vm_angles:Right(), rotation.r * fraction)

		client.RaisedFrac = Lerp(
			FrameTime() * 2,
			client.RaisedFrac or 0,
			value
		)
	end)
end