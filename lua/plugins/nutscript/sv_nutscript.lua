-- # Author: STEAM_0:1:29606990

-- # Micro-ops.
local HITGROUP_HEAD, HITGROUP_CHEST, HITGROUP_STOMACH, HITGROUP_LEFTLEG = HITGROUP_HEAD, HITGROUP_CHEST, HITGROUP_STOMACH, HITGROUP_LEFTLEG
local HITGROUP_LEFTARM, HITGROUP_RIGHTLEG, HITGROUP_RIGHTARM = HITGROUP_LEFTARM, HITGROUP_RIGHTLEG, HITGROUP_RIGHTARM
local Limb, CurTime, IsValid, math, MOVETYPE_NOCLIP, MOVETYPE_LADDER, hook, pairs = Limb, CurTime, IsValid, math, MOVETYPE_NOCLIP, MOVETYPE_LADDER, hook, pairs

local function item2world(inv, item, pos, player)
	item.invID = 0
	
	player:StripWeapon(item.class)
	player:EmitSound("items/ammo_pickup.wav", 80)

	inv:remove(item.id, false, true)
	nut.db.query("UPDATE nut_items SET _invID = 0 WHERE _itemID = "..item.id)

	local ent = item:spawn(pos)	
	
	if (IsValid(ent)) then
		timer.Simple(0, function()
			local phys = ent:GetPhysicsObject()
			
			if (IsValid(phys)) then
				phys:EnableMotion(true)
				phys:Wake()
			end
		end)
	end

	return ent
end

function Limb:nutDropWeapon(player)
	if (IsValid(player) and player:IsPlayer() and player:Alive()) then
		local weapon = player:GetActiveWeapon()
		if (IsValid(weapon)) then
			local char = player:getChar()
			local inv = char:getInv()
			local items = inv:getItems()
			
			for k, v in pairs(items) do
				if (v.isWeapon and v:getData("equip") and v.class == weapon:GetClass()) then
					v:setData("equip", nil)
					
					local ent = item2world(inv, v, player:GetPos() + Vector(0, 0, 10), player)
					break
				end
			end
		end
	end
end

if (Limb:GetCvar("raised_weapon_system")) then
	-- # Called when player broken arms.
	hook.Add("TickLimbArmsBroken", "Limb.TickLimbArmsBroken", function(player, broken)
		if (broken) then
			player:setWepRaised(false)
		end
	end)
	
	-- # Called when player broken arms and wants raise weapon.
	hook.Add("CanToggleWepRaise", "Limb.CanToggleWepRaise", function(player)
		if (Limb:IsBroken(player, HITGROUP_LEFTARM) and Limb:IsBroken(player, HITGROUP_RIGHTARM)) then
			return true
		else
			return false
		end
	end)
end

if (Limb:GetCvar("save_limbdata")) then
	hook.Add("CharacterPreSave", "Limb.CharacterPreSave", function(char)
		local data = char.player:LimbData()
		
		if (data) then
			for k = 1, #data do
				if (!data[k].Bleeding) then continue end
				data[k].BleedingTick = CurTime() - data[k].BleedingTick
			end
			char:setData("LimbData", data)
		end
	end)
end

local function brokenProne(player)
	if (Limb:GetCvar("prone") and prone) then
		local br = Limb:IsBroken(player, HITGROUP_LEFTLEG) and Limb:IsBroken(player, HITGROUP_RIGHTLEG)
		if (!br and player:IsProne()) then
			player:ConCommand("prone")
		end
		br = nil
	end
end
	
hook.Add("PlayerLoadedChar", "Limb.PlayerLoadedChar", function(player, char)
	if (Limb:GetCvar("save_limbdata")) then
		local data = char:getData("LimbData")
		if (data) then
			for k = 1, #data do
				if (!data[k].Bleeding) then continue end
				data[k].BleedingTick = CurTime() - data[k].BleedingTick
			end
			player:setNetVar("LimbData", data)
		else
			Limb:ResetLimbData(player)
		end
		data = nil
	end
	
	brokenProne(player)
end)

hook.Add("PlayerSpawn", "Limb.PlayerSpawn", function(player)
	if (IsValid(player) and player:IsPlayer()) then
		player:LimbNilSpeed()
		
		if (Limb:GetCvar("save_limbdata")) then
			if (player.resetLimbData) then
				Limb:ResetLimbData(player)
				brokenProne(player)
				
				player.resetLimbData = nil
			end
		else
			Limb:ResetLimbData(player)
			brokenProne(player)
		end
	end
end)

hook.Add("PlayerDeath", "Limb.PlayerDeath", function(player)
	if (Limb:GetCvar("reset_limb")) then
		if (IsValid(player) and player:IsPlayer()) then -- # No bots
			player.resetLimbData = true
		end
	end
end)

if (Limb:GetCvar("disability")) then
	hook.Add("Move", "Limb.Move", function(player)
		if (IsValid(player) and player:IsPlayer() and player:Alive() and player:getChar()) then
			Limb:DisabilitySpeed(player)
		end
	end)
end