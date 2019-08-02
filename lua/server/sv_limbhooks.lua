if (!Limb) then
	return MsgC(Color(255,0,0), "[SERVER] Limb table not initializing!\n")
end

if (!Limb:GetCvar("system")) then
	return MsgC(Color(255,0,0), "[SERVER] Limb not enabled!\n")
end

-- # Micro-ops.
local HITGROUP_HEAD, HITGROUP_CHEST, HITGROUP_STOMACH, HITGROUP_LEFTLEG = HITGROUP_HEAD, HITGROUP_CHEST, HITGROUP_STOMACH, HITGROUP_LEFTLEG
local HITGROUP_LEFTARM, HITGROUP_RIGHTLEG, HITGROUP_RIGHTARM = HITGROUP_LEFTARM, HITGROUP_RIGHTLEG, HITGROUP_RIGHTARM
local Limb, CurTime, IsValid, math, MOVETYPE_NOCLIP, MOVETYPE_LADDER, hook = Limb, CurTime, IsValid, math, MOVETYPE_NOCLIP, MOVETYPE_LADDER, hook

if (!Limb:IsNutscript()) then
	hook.Add("PlayerInitialSpawn", "Limb.PlayerInitialSpawn", function(player)
		if (Limb:GetCvar("init_limb")) then
			if (IsValid(player) and player:IsPlayer()) then -- # No bots
				Limb:ResetLimbData(player)
			end
		end
	end)

	hook.Add("PlayerSpawn", "Limb.PlayerSpawn", function(player)
		if (IsValid(player) and player:IsPlayer()) then
			player:LimbNilSpeed()
		end
	end)

	hook.Add("PlayerDeath", "Limb.PlayerDeath", function(player)
		if (Limb:GetCvar("reset_limb")) then
			if (IsValid(player) and player:IsPlayer()) then -- # No bots
				Limb:ResetLimbData(player)
			end
		end
	end)
end

-- # Thansk mate [https://forum.facepunch.com/u/qtoq/Wunce/]
-- # I really bad in math.
local function FindAttackLocation(player, dmgInfo)
	local pi = 3.141592654													--	a
	local a = player:GetAimVector()											--	\	This angle between is found through the equation:
	local b = (dmgInfo:GetDamageForce()):GetNormalized() 					--	 \	
	local theta = math.acos(Vector(a.x,a.y):DotProduct(Vector(b.x,b.y)))	--	  \_______b		arccos(a . b)
	local sign = Vector(a.x,a.y):Cross(Vector(b.x,b.y))						--    
	if sign.z < 0 and theta > (pi / 6) and theta < (5*pi / 6) then 			-- then the side in which the angle is on is found by the cross product
		return 1 -- LEFT SIDE													-- of the x and y components (which produces positive number in the z direction
	elseif sign.z > 0 and theta > (pi / 6) and theta < (5*pi / 6) then		-- for anti-clockwise and negative z for clockwise. This is then used to
		return 3 -- RIGHT SIDE													-- determine which side the angle is on and therefore where the attack came
	else																	-- from. This can be applied to more than just attacks, as long as you have
		return 2 -- CENTRE														-- two normalised vectors :D
	end
end

hook.Add("EntityTakeDamage", "Limb.EntityTakeDamage", function(entity, dmgInfo)
	local inflictor, attacker = dmgInfo:GetInflictor(), dmgInfo:GetAttacker()
	
	if (dmgInfo:GetDamage() == 0) then
		return
	end

	if (IsValid(entity) and entity:IsPlayer()) then
		local player = entity
		local lastHitGroup = entity:LastHitGroup()
		
		if (dmgInfo:GetDamage() > 0) then
			if (player:LimbRestricted()) then
				return
			end

			if (dmgInfo:IsFallDamage()) then
				Limb:TakeDamage(player, HITGROUP_RIGHTLEG, dmgInfo)
				Limb:TakeDamage(player, HITGROUP_LEFTLEG, dmgInfo)
			elseif (dmgInfo:IsExplosionDamage()) then
				/*for k = 1, #player:LimbData() do
					if (k == 3) then continue end
					Limb:TakeDamage(player, k, dmgInfo) -- # Can't think of a better way to pick the limb in this case
				end*/
				if (math.random(1,3) == 1) then
					Limb:TakeDamage(player, HITGROUP_HEAD, dmgInfo)
				end
				Limb:TakeDamage(player, HITGROUP_CHEST, dmgInfo)
				local randy = FindAttackLocation(player, dmgInfo)
				if (randy == 3) then -- # RIGHT SIDE
					Limb:TakeDamage(player, HITGROUP_RIGHTLEG, dmgInfo)
					Limb:TakeDamage(player, HITGROUP_RIGHTARM, dmgInfo)
				elseif (randy == 2) then -- # CENTRE
					Limb:TakeDamage(player, HITGROUP_RIGHTLEG, dmgInfo)
					Limb:TakeDamage(player, HITGROUP_RIGHTARM, dmgInfo)
					Limb:TakeDamage(player, HITGROUP_LEFTLEG, dmgInfo)
					Limb:TakeDamage(player, HITGROUP_LEFTARM, dmgInfo)
				elseif (randy == 1) then -- # LEFT SIDE
					Limb:TakeDamage(player, HITGROUP_LEFTLEG, dmgInfo)
					Limb:TakeDamage(player, HITGROUP_LEFTARM, dmgInfo)
				end
				randy = nil
			else
				Limb:TakeDamage(player, lastHitGroup, dmgInfo)
			end

			if (dmgInfo:IsBulletDamage()) then		
				if (Limb:GetCvar("blood_effect")) then
					Limb:CreateBloodEffects(dmgInfo:GetDamagePosition(), 1, player)
				end
				
				if (Limb:GetCvar("pain_sound")) then
					Limb:PlayerEmitSound(player, lastHitGroup)
				end
			end
			
			if (Limb:GetCvar("scale_damage_player") and lastHitGroup > 0) then
				local hit = Limb:GetHealthPercentage(player, lastHitGroup) / 100
				if (hit > 0) then
					local scale = Limb:GetScaleDamage(lastHitGroup)
					dmgInfo:ScaleDamage(scale + hit) -- # Damage to player.
					scale = nil
				end
				hit = nil
			end
		end
		
		player = nil
		lastHitGroup = nil
	end
	
	inflictor = nil
	attacker = nil
end)

hook.Add("LimbTakeDamage", "Limb.LimbTakeDamage", function(player, hitGroup, damage, newHealth, dmgInfo)
	if (Limb:GetCvar("broken_arms_drop")) then
		if (dmgInfo:IsBulletDamage() and math.random() >= 0.7 and (Limb:IsBroken(player, HITGROUP_LEFTARM) or Limb:IsBroken(player, HITGROUP_RIGHTARM))) then
			if ((player.dropWepTime or 0) < CurTime()) then
				local callback = Limb.SupGamemodes[Limb:GetGamemode()]
				if (callback) then
					callback.dropweapon(player)
				else
					local weapon = player:GetActiveWeapon()
					if (IsValid(weapon)) then
						player:DropWeapon(weapon)
					end
				end
				
				player.dropWepTime = CurTime() + 2 -- # Anti double chance.
			end
		end
	end
end)

if (Limb:GetCvar("disability") and !Limb:IsNutscript()) then
	hook.Add("Move", "Limb.Move", function(player)
		if (IsValid(player) and player:IsPlayer() and player:Alive()) then
			Limb:DisabilitySpeed(player)
		end
	end)
end

if (Limb:GetCvar("limp_broken")) then
	local legBroken = { 
		[0] = {HITGROUP_LEFTLEG, -1},
		[1] = {HITGROUP_RIGHTLEG, 1}
	}
	
	hook.Add("PlayerFootstep", "Limb.PlayerFootstep", function(player, pos, foot)
		if (IsValid(player) and player:IsPlayer() and player:Alive() and player:LimbStuff()) then
			if (Limb:IsBroken(player, legBroken[foot][1])) then
				player:ViewPunch(Angle(0, legBroken[foot][2], legBroken[foot][2]))
			end
		end
	end)
end

if (Limb:GetCvar("prone") and prone) then
	hook.Add("prone.CanExit", "Limb.prone.CanExit", function(player)
		if (IsValid(player) and player:Alive()) then
			local legBroken = Limb:IsBroken(player, HITGROUP_LEFTLEG) and Limb:IsBroken(player, HITGROUP_RIGHTLEG)
			if (legBroken) then
				return false
			end
		end
	end)
end

hook.Add("Tick", "Limb.PlayerTick", function()
	if (Limb:GetCvar("Bleeding")) then
		Limb:TickBleeding()
	end

	Limb:TickLimbBroken()
end)

if (Limb:GetCvar("fire_spread")) then
	hook.Add("EntityFireBullets", "PlayerEntityFireBullets", function(player, data)
		if (IsValid(player) and player:IsPlayer()) then
			local weapon = player:GetActiveWeapon()
			if (IsValid(weapon)) then
				local leftArm = Limb:GetHealthPercentage(player, HITGROUP_LEFTARM) / 100
				local rightArm = Limb:GetHealthPercentage(player, HITGROUP_RIGHTARM) / 100
				local armDamage = math.max(leftArm, rightArm)
				
				if (armDamage > 0) then
					data.Spread = data.Spread * (1 + armDamage)
				end
				
				rightArm, rightArm, armDamage = nil, nil, nil
				
				if (!Limb:GetCvar("spread_only_arms")) then
					if Limb:IsBroken(player, HITGROUP_CHEST) then
						local chest = Limb:GetHealthPercentage(player, HITGROUP_CHEST) / 100
						data.Spread = data.Spread * (1 + chest)
						chest = nil
					end
					
					if Limb:IsBroken(player, HITGROUP_HEAD) then
						local head = Limb:GetHealthPercentage(player, HITGROUP_CHEST) / 100
						data.Spread = data.Spread * (1 + head)
						head = nil
					end
				end
				
				hook.Run("LimbWeaponSpread", player, data)
				return true
			end
		end
	end)
end

hook.Add("DamageLimbBleedTick", "Limb.DamageLimbBleedTick", function(player, hitgroup, counts)
	if (IsValid(player) and player:Alive() and (player.lastLimbTickBleed or 0) <= CurTime()) then
		if (Limb:GetCvar("blood_effect")) then
			Limb:CreateBloodEffects(player:GetPos(), counts, player)
		end
		
		if (Limb:GetCvar("pain_sound")) then
			Limb:PlayerEmitSound(player, hitgroup)
		end
		
		player.lastLimbTickBleed = CurTime() + 3
	end
end)