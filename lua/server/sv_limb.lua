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

-- A function to take damage a player's limb.
function Limb:TakeDamage(player, hitGroup, dmgInfo)
	local damage, dmgType = dmgInfo:GetDamage(), dmgInfo:GetDamageType()
	if (hitGroup > 0 and damage > 0) then -- # HITGROUP_GENERIC = 0
		if (Limb:GetCvar("armor_damage")) then
			if (player:Armor() - damage < 0) then
				damage = damage * Limb:GetCvar("armor_inc_damage")
			else
				damage = damage / Limb:GetCvar("armor_dec_damage")
			end
		end
		
		self:SetHealth(player, hitGroup, damage)
		local newVal = self:GetHealth(player, hitGroup)
		
		if (dmgType) then
			local maxHealth = self:GetDataHigtroup()[hitGroup][1]
			if (self.tbl_DmgStartsBleeding[dmgType]) then
				local bleed = self:Data()[hitGroup][4] -- # Bleeding threshold
				if (bleed > 0 and damage >= bleed or newVal >= maxHealth) then -- # bleeding
					self:SetBleeding(player, hitGroup, true)
				end
				bleed = nil
			end
			
			if (self.tbl_DmgBreakBones[dmgType]) then
				local broken = self:Data()[hitGroup][3] -- # Bone break threshold
				if (broken > 0 and damage >= broken or newVal >= maxHealth) then -- # break bones
					self:SetBroken(player, hitGroup, true)
				end
				broken = nil
			end
			
			maxHealth = nil
		end
		
		hook.Run("LimbTakeDamage", player, hitGroup, damage, newVal, dmgInfo) -- # Called when a player takes damage limb.
		newVal = nil
	end
	
	damage, dmgType = nil, nil -- # Memory.
end

-- A function to reset a player's limb data.
function Limb:ResetLimbData(player)
	player:setNetVar("LimbData", {})
	local r = {}
	
	local data = Limb:GetDataHigtroup()
	for i = 1, #data do
		r[i] = {
			health = 0, 
			Bleeding = false, 
			Broken = false,
			BleedingTick = CurTime(),
			BleedingDmg = 0
		}
	end
	data = nil
	
	player:setNetVar("LimbData", r)
	r = nil
end

-- # A function to set bleeding player data.
function Limb:SetBleedingData(player, hitGroup, amount, bIsTick)
	local data = player:LimbData()
	if (data) then
		if (bIsTick) then
			data[hitGroup].BleedingTick = amount
		else
			data[hitGroup].BleedingDmg = amount
		end
		
		player:setNetVar("LimbData", data)
	end
end

-- A function to get a player's limb health.
function Limb:GetHealth(player, hitGroup, asFraction)
	local limbData = player:getNetVar("LimbData", {})
	
	if (type(limbData) == "table") then
		if (limbData and limbData[hitGroup]) then
			if (asFraction) then
				return limbData[hitGroup].health / 100
			else
				return limbData[hitGroup].health
			end
		end
	end
	
	return 0
end

-- # A function to get a limb's name.
function Limb:GetName(hitGroup)
	local limbData = self:Data()
	if (type(limbData) == "table") then
		if (limbData and limbData[hitGroup]) then
			return limbData[hitGroup][2] or "Generic"
		end
	end
end

-- A function to get a player's broken limb.
function Limb:IsBroken(player, hitGroup)
	local limbData = player:getNetVar("LimbData", {})
	if (type(limbData) == "table") then
		if (limbData and limbData[hitGroup]) then
			if (self:GetHealth(player, hitGroup) >= self:GetDataHigtroup()[hitGroup][1]) then
				return true
			end
			
			return limbData[hitGroup].Broken
		end
	end
	
	return false
end

-- A function to get a player's bleeding limb.
function Limb:IsBleeding(player, hitGroup)
	local limbData = player:getNetVar("LimbData", {})
	if (type(limbData) == "table") then
		if (limbData and limbData[hitGroup]) then
			return limbData[hitGroup].Bleeding
		end
	end
	
	return false
end

-- A function to set a player's broken limb.
function Limb:SetBroken(player, hitGroup, bBroken)
	local limbData = player:getNetVar("LimbData", {})
	if (type(limbData) == "table") then
		if (limbData and limbData[hitGroup]) then
			limbData[hitGroup].Broken = bBroken
			player:setNetVar("LimbData", limbData)
		end
	end
end

-- A function to set a player's bleeding limb.
function Limb:SetBleeding(player, hitGroup, bBleeding)
	local limbData = player:getNetVar("LimbData", {})
	if (type(limbData) == "table") then
		if (limbData and limbData[hitGroup]) then
			limbData[hitGroup].Bleeding = bBleeding
			player:setNetVar("LimbData", limbData)
			
			if (bBleeding == false) then
				self:SetBleedingData(player, hitGroup, CurTime(), true)
				self:SetBleedingData(player, hitGroup, 0)
			end
		end
	end
end

-- A function to get the local player's limb percentage health.
function Limb:GetHealthPercentage(player, hitGroup, health)
	local maxHP = self:GetDataHigtroup()[hitGroup][1]
	local hp = health or self:GetHealth(player, hitGroup)
	local percent = hp * 100 / maxHP
	return math.ceil(percent)
end

-- A function to get the max health.
function Limb:GetMaxHealth(hitgroup)
	if (self:GetDataHigtroup() and self:GetDataHigtroup()[hitgroup]) then
		return self:GetDataHigtroup()[hitgroup][1]
	end
	
	return 0
end

-- A function to get scale damage.
function Limb:GetScaleDamage(hitgroup)
	if (self:GetDataHigtroup() and self:GetDataHigtroup()[hitgroup]) then
		return self:GetDataHigtroup()[hitgroup][5]
	end
	
	return 0
end

function Limb:DisabilitySpeed(player)
	player:LimbSaveSpeed()
	local runSpeed, walkSpeed, jumpPower = player:LimbGetSpeed("runSpeed"), player:LimbGetSpeed("walkSpeed"), player:LimbGetSpeed("jumpPower")
	if (player:LimbStuff()) then
		local legBroken = self:IsBroken(player, HITGROUP_LEFTLEG) and self:IsBroken(player, HITGROUP_RIGHTLEG)
		
		local leftLeg = self:GetHealthPercentage(player, HITGROUP_LEFTLEG) / 100
		local rightLeg = self:GetHealthPercentage(player, HITGROUP_RIGHTLEG) / 100
		local legDamage = math.max(leftLeg, rightLeg)

		if (legDamage > 0) then
			runSpeed = player:LimbGetSpeed("runSpeed") / (1 + legDamage)
			walkSpeed = player:LimbGetSpeed("walkSpeed") / (1 + legDamage)
			jumpPower = player:LimbGetSpeed("jumpPower") / (1 + legDamage)
		end
		
		if (runSpeed < walkSpeed) then
			runSpeed = walkSpeed
		end

		player:SetRunSpeed(math.max(runSpeed, 0))
		player:SetWalkSpeed(math.max(walkSpeed, 0))
		player:SetJumpPower(math.max(jumpPower, 0))
		
		if (self:GetCvar("prone") and prone) then
			if (legBroken and !player:IsProne()) then
				player:ConCommand("prone")
			end
		end
		
		leftLeg, rightLeg, legDamage = nil, nil, nil
		legBroken = nil
	end
	
	runSpeed, jumpPower, walkSpeed = nil, nil, nil
end

-- # A function to add/take a player's health limb.
-- # Ex: SetHealth(player, HITGROUP_HEAD, 10) -- Take
-- # Ex: SetHealth(player, HITGROUP_HEAD, -10) -- Add
function Limb:SetHealth(player, hitGroup, damage)
	local limbData = player:getNetVar("LimbData", {})
	if (istable(limbData) and limbData and limbData[hitGroup]) then
		limbData[hitGroup].health = math.Clamp((limbData[hitGroup].health or 0) + math.ceil(damage), 0, Limb:GetDataHigtroup()[hitGroup][1])
		player:setNetVar("LimbData", limbData)
	end
end

-- # A function to heal a player's body.
function Limb:HealBody(player, amount)
	local limbData = player:getNetVar("LimbData", {})
	
	if (limbData) then
		for i = 1, #self:GetDataHigtroup() do
			self:SetHealth(player, i, -amount)
		end
	end
end

function Limb:TickBleeding()
	local time = CurTime()
	if (self.m_intLastBleedTick or 0) > time then return end
	self.m_intLastBleedTick = time + 1
	
	local plyData = player.GetHumans()
	for i = 1, #plyData do
		local player = plyData[i]
		local isValid = IsValid(player) and player:Alive()
		
		if (self:IsNutscript()) then
			isValid = IsValid(player) and player:Alive() and player:getChar()
		end
		
		if (isValid) then
			local data = player:LimbData()
			local counts = 0 -- # Counter bleedings
			for i2 = 1, #self:GetDataHigtroup() do
				local limbData = data[i2]
				if (self:IsBleeding(player, i2)) then
					counts = counts + 1
					self:SetBleedingData(player, i2, limbData.BleedingTick or time, true)
					
					local d = (1 - math.Clamp(CurTime() - limbData.BleedingTick, 0, 1))
					if (d <= 0) then
						self:SetBleedingData(player, i2, CurTime() + math.random() * self:GetCvar("BleedIntervalLimb"), true)
						self:SetBleedingData(player, i2, (limbData.BleedingDmg or 0) + math.random() * self:GetCvar("BleedLimbDamage"))
						self:SetHealth(player, i2, limbData.BleedingDmg) -- # Limb
						
						hook.Run("DamageLimbBleedTick", player, i2, counts) -- # Called when limb get bleed
					end
					d = nil
				end
				limbData = nil
			end

			if ((player.lastBleedingTick or 0) < time and counts > 0) then
				if (self:GetCvar("blood_effect")) then
					self:CreateBloodEffects(player:GetPos(), counts, player)
				end
				
				if (self:GetCvar("pain_sound")) then
					self:PlayerEmitSound(player, math.random(counts))
				end
				
				local damage = self:GetCvar("BleedDamage") * counts
				player:ViewPunch(Angle(-1 * damage, 0, 0))
				
				local new_hp = player:Health() - damage
				if new_hp <= 0 then
					player:Kill()
				else
					player:SetHealth(math.Max(new_hp, 0))
				end
				
				player.lastBleedingTick = CurTime() + self:GetCvar("BleedInterval") - counts
			end
			data, counts = nil, nil
		end
		player, isValid = nil, nil
	end
	plyData = nil
end

function Limb:TickLimbBroken()
	local curTime = CurTime()

	for k = 1, player.GetCount() do
		local player = player.GetHumans()[k]
		local isValid = IsValid(player) and player:Alive()
		
		if (self:IsNutscript()) then
			isValid = isValid and player:getChar()
		end
		
		if (isValid) then
			if (!player.nextTick) then
				player.nextTick = curTime + 0.1
			end
			
			if (curTime >= player.nextTick) then
				local weapon = player:GetActiveWeapon()
				if (IsValid(weapon)) then
					local broken = self:IsBroken(player, HITGROUP_LEFTARM) and self:IsBroken(player, HITGROUP_RIGHTARM)
					
					hook.Run("TickLimbArmsBroken", player, broken)
					broken = nil
				end
				weapon = nil
			end
		end
		player, isValid = nil, nil
	end
end

function Limb:PlayerPlayPainSound(gender, hitGroup)
	if (math.random() <= 0.5) then
		if (hitGroup == HITGROUP_HEAD) then
			return "vo/npc/"..gender.."01/ow0"..math.random(1, 2)..".wav"
		elseif (hitGroup == HITGROUP_CHEST or hitGroup == HITGROUP_GENERIC) then
			return "vo/npc/"..gender.."01/hitingut0"..math.random(1, 2)..".wav"
		elseif (hitGroup == HITGROUP_LEFTLEG or hitGroup == HITGROUP_RIGHTLEG) then
			return "vo/npc/"..gender.."01/myleg0"..math.random(1, 2)..".wav"
		elseif (hitGroup == HITGROUP_LEFTARM or hitGroup == HITGROUP_RIGHTARM) then
			return "vo/npc/"..gender.."01/myarm0"..math.random(1, 2)..".wav"
		elseif (hitGroup == HITGROUP_GEAR) then
			return "vo/npc/"..gender.."01/startle0"..math.random(1, 2)..".wav"
		end
	end
	
	return "vo/npc/"..gender.."01/pain0"..math.random(1, 9)..".wav"
end

function Limb:PlayerEmitSound(player, hitGroup)
	local male = "male"
	if (self:IsNutscript()) then
		if (player:isFemale()) then
			male = "female"
		end
	else
		local model = player:GetModel():lower()
		if model:find("female") or model:find("alyx") or model:find("mossman") then
			male = "female"
		end
	end
	
	local sound = self:PlayerPlayPainSound(male, hitGroup)
	if (sound) then
		timer.Simple(FrameTime(), function()
			if (IsValid(player)) then
				player:EmitSound(tostring(sound))
			end
		end)
	end
end

function Limb:CreateBloodEffects(position, decals, entity, fScale)
	if (!entity.limbNextBlood or CurTime() >= entity.limbNextBlood) then
		local effectData = EffectData()
			effectData:SetOrigin(position)
			effectData:SetEntity(entity)
			effectData:SetStart(position)
			effectData:SetScale(fScale or 0.5)
		util.Effect("BloodImpact", effectData, true, true)
		
		for i = 1, decals do
			local trace = {}
				trace.start = position
				trace.endpos = trace.start
				trace.filter = entity
			trace = util.TraceLine(trace)
			
			util.Decal("Blood", trace.HitPos + trace.HitNormal, trace.HitPos - trace.HitNormal)
		end
		
		entity.limbNextBlood = CurTime() + 0.5
	end
end

-- # A function when a player's lock info is needed.
function Limb:GetLockTime(player, time)
	local lockTime = time or self:GetCvar("lock_time")
	
	local leftArm = self:GetHealthPercentage(player, HITGROUP_LEFTARM) / 100
	local rightArm = self:GetHealthPercentage(player, HITGROUP_RIGHTARM) / 100
	local armDamage = math.max(leftArm, rightArm)
	
	if (armDamage > 0) then
		lockTime = lockTime * (1 + armDamage)
	end
	
	return lockTime
end

-- # A function when a player's unlock info is needed.
function Limb:GetUnlockTime(player, time)
	local unlockTime = time or self:GetCvar("unlock_time")
	
	local leftArm = self:GetHealthPercentage(player, HITGROUP_LEFTARM) / 100
	local rightArm = self:GetHealthPercentage(player, HITGROUP_RIGHTARM) / 100
	local armDamage = math.max(leftArm, rightArm)
	
	if (armDamage > 0) then
		unlockTime = unlockTime * (1 + armDamage)
	end
	
	return unlockTime
end

-- # A function to get limb data.
function Limb:Data()
	local limbData = self:GetDataHigtroup()
	if (type(limbData) == "table" and limbData) then
		return limbData
	end
	return false
end

local playerMeta = FindMetaTable("Player")

-- # A function to get limb a player data.
function playerMeta:LimbData()
	local limbData = self:getNetVar("LimbData", {})
	if (type(limbData) == "table" and limbData) then
		return limbData
	end
	return false
end

function playerMeta:LimbSaveSpeed()
	if (!self.defSpeed) then
		self.defSpeed = {}
	else
		return
	end
	
	local run, walk, jump = "runSpeed", "walkSpeed", "jumpPower"
	
	if (self.defSpeed[run] or self.defSpeed[walk] or self.defSpeed[jump]) then return end
	
	self.defSpeed[run] = self:GetRunSpeed()
	self.defSpeed[jump] = self:GetJumpPower()
	self.defSpeed[walk] = self:GetWalkSpeed()

	run, walk, jump = nil, nil, nil
end

function playerMeta:LimbGetSpeed(key)
	if (self.defSpeed and self.defSpeed[key]) then
		return self.defSpeed[key]
	end
	
	return 0
end

function playerMeta:LimbNilSpeed()
	self.defSpeed = {}
	self.defSpeed = nil
end

function playerMeta:LimbStuff()
	if (self:GetMoveType() != MOVETYPE_NOCLIP and self:GetMoveType() != MOVETYPE_LADDER) then
		return true
	end
	
	return false
end

function playerMeta:LimbRestricted()
	if (self:HasGodMode()) then
		return true
	end
	
	if (Limb.RESTRICTED) then
		if (Limb.RESTRICTED[self:SteamID()] or Limb.RESTRICTED[self:GetUserGroup()] or Limb.RESTRICTED[self:Team()]) then
			return true
		end
	end
	
	return false
end