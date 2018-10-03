if (!Limb) then
	return MsgC(Color(255,0,0), "[CLIENT] Limb table not initializing!\n")
end

if (!Limb:GetCvar("system")) then
	return MsgC(Color(255,0,0), "[CLIENT] Limb not enabled!\n")
end

-- # Micro-ops.
local HITGROUP_HEAD, HITGROUP_CHEST, HITGROUP_STOMACH, HITGROUP_LEFTLEG = HITGROUP_HEAD, HITGROUP_CHEST, HITGROUP_STOMACH, HITGROUP_LEFTLEG
local HITGROUP_LEFTARM, HITGROUP_RIGHTLEG, HITGROUP_RIGHTARM = HITGROUP_LEFTARM, HITGROUP_RIGHTLEG, HITGROUP_RIGHTARM
local Limb, CurTime, IsValid, math, MOVETYPE_NOCLIP, MOVETYPE_LADDER, hook = Limb, CurTime, IsValid, math, MOVETYPE_NOCLIP, MOVETYPE_LADDER, hook
local LocalPlayer, vgui, surface, pairs, RunConsoleCommand, draw = LocalPlayer, vgui, surface, pairs, RunConsoleCommand, draw
local TEXT_ALIGN_CENTER = TEXT_ALIGN_CENTER

if (Limb:GetCvar("debug")) then
	concommand.Add("limb_info", function()
		for i = 1, #Limb:GetDataHigtroup() do
			--local health = Limb:GetHealth(i)
			--local color = Limb:GetColor(health)
			local health = Limb:GetHealthPercentage(i, true)
			local color = Limb:GetColor(math.floor(health))
			MsgC(color, "Name: "..Limb:GetName(i).."\n")
			MsgC(color, "Health: "..health.."\n")
			MsgC(color, "isBroken: "..tostring(Limb:IsBroken(i)).."\n")
			MsgC(color, "isBleeding: "..tostring(Limb:IsBleeding(i)).."\n")
			
			health,color = nil,nil
		end
		
		PrintTable(LocalPlayer():getNetVar("LimbData", {}))
	end)
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

-- # A function to get limb data.
function Limb:Data()
	local limbData = self:GetDataHigtroup()
	if (type(limbData) == "table" and limbData) then
		return limbData
	end
	return false
end

-- A function to get a limb's name.
function Limb:GetName(hitGroup)
	local limbData = self:Data()
	if (type(limbData) == "table") then
		if (limbData and limbData[hitGroup]) then
			return limbData[hitGroup][2] or "Generic"
		end
	end
end

-- A function to get a limb color.
function Limb:GetColor(health)
	if (health > 75) then
		return Color(166, 243, 76, 255)
	elseif (health > 50) then
		return Color(233, 225, 94, 255)
	elseif (health > 25) then
		return Color(233, 173, 94, 255)
	else
		return Color(222, 57, 57, 255)
	end
end

-- A function to get the local player's limb health.
function Limb:GetHealth(hitGroup, asFraction)
	local limbData = LocalPlayer():getNetVar("LimbData", {})
	
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

-- A function to get a player's broken limb.
function Limb:IsBroken(hitGroup)
	local limbData = LocalPlayer():getNetVar("LimbData", {})
	if (type(limbData) == "table") then
		if (limbData and limbData[hitGroup]) then
			if (self:GetHealth(hitGroup) >= self:GetDataHigtroup()[hitGroup][1]) then
				return true
			end
			
			return limbData[hitGroup].Broken
		end
	end
	
	return false
end

-- A function to get a player's bleeding limb.
function Limb:IsBleeding(hitGroup)
	local limbData = LocalPlayer():getNetVar("LimbData", {})
	if (type(limbData) == "table") then
		if (limbData and limbData[hitGroup]) then
			return limbData[hitGroup].Bleeding
		end
	end
	
	return false
end

local function GetHealthFlip(hitGroup)
	local max = Limb:GetDataHigtroup()[hitGroup][1]
	return max - Limb:GetHealth(hitGroup)
end

-- A function to get the local player's limb percentage health.
function Limb:GetHealthPercentage(hitGroup, bFlip, health)
	local maxHP = Limb:GetDataHigtroup()[hitGroup][1]
	local hp = health or Limb:GetHealth(hitGroup)
	
	if (bFlip) then
		hp = GetHealthFlip(hitGroup) -- # maxHealth - curHealth
	end
	
	local percent = hp * 100 / maxHP
	return math.ceil(percent)
end

-- A function to get the max health.
function Limb:GetMaxHealth(hitgroup)
	return Limb:GetDataHigtroup()[hitgroup][1]
end

-- A function to get scale damage.
function Limb:GetScaleDamage(hitgroup)
	return Limb:GetDataHigtroup()[hitgroup][5]
end

-- # Thanks Legera [STEAM_0:0:70897779]
local PANEL = {}
	local tickmat = Material("eft/tickmat.png")
	local damagepanel = Material("eft/damagepanel.png")
	local brokenmat = Material("eft/fracture.png")
	local bleedingmat = Material("eft/bleeding.png")
	local framemat = Material("eft/framemat.png")
	local butmat = "eft/butmat.png"
	local body  = "eft/body.png"

	function PANEL:Init()
		if (IsValid(Limb.gui)) then
			Limb.gui:Remove()
		end
		
		Limb.gui = self
		
		self:SetSize(505, 699)
		self:Center()
		self:MakePopup()
		self:ShowCloseButton(false)
		self:SetDraggable(false)
		self:SetTitle("LIMBS")
		
		self.submit = self:Add("DButton")
		self.submit:Dock(BOTTOM)
		self.submit:SetTall(30)
		self.submit.DoClick = function()
			self:Remove()
		end

		local submitmat = vgui.Create( "Material", self.submit )
		submitmat:SetPos(0, 0 )
		submitmat:SetMaterial( butmat )

		local submittext = vgui.Create( "DLabel", self.submit )
		submittext:SetPos(237, 7)
		submittext:SetText("CLOSE")
		
		self.body = vgui.Create( "Material", self )
		self.body:SetMaterial(body)
		self.body:SetSize(505, 699) 
		self.body:SetPos( 0, 0 )

		self.body.AutoSize = false
	end

	function PANEL:Paint(intW, intH)
		surface.SetDrawColor(color_white)
		surface.SetMaterial(framemat)
		surface.DrawTexturedRect(0, 0, intW, intH)
	end
	
	local limbs = { -- # I like micro-ops.
		[1] = "eft/head.png",
		[6] = "eft/left_leg.png",
		[4] = "eft/left_arm.png",
		[7] = "eft/right_leg.png",
		[5] = "eft/right_arm.png",
		[2] = "eft/chest.png"
	}
	
	local inst = { -- # I like micro-ops.
		[1] = {360, 36},
		[2] = {274, 148},
		[3] = {0, 0},
		[4] = {374, 288},
		[5] = {94, 233},
		[6] = {374, 429},
		[7] = {126, 426}
	}
	
	function PANEL:PaintOver(intW, intH)
		for k = 1, #inst do
			if (k == 3) then continue end
			self:DrawDamagedLimb(k)
			self:DrawDamagePanel(k, inst[k][1], inst[k][2])
		end
	end
	
	function PANEL:OnRemove()
		LocalPlayer().limbTickBool = nil
	end

	function PANEL:Think()
		--if ((self.nextUpdate or 0) < CurTime()) then
			self:MoveToFront()
			
			--self.nextUpdate = CurTime() + 0.1
		--end
	end

	function PANEL:DrawDamagedLimb(intLimbID)
		limbname = intLimbID
		if (Limb:GetHealthPercentage(limbname, true)) < 100 then
			local icon = limbs[intLimbID]
			surface.SetMaterial(Material(icon))
			surface.SetDrawColor(hook.Run("GetLimbAlp"))
			surface.DrawTexturedRect(0, 0, self:GetWide(),self:GetTall()) -- # 505, 699
			icon = nil
		end	
	end
	
	local font = font -- # Pre cache, bitch!
	local defColor = Color(255, 255, 255, 255)
	function PANEL:DrawDamagePanel(intLimbID, dpW, dpH)
		local dlimbname = intLimbID
		local maxHealth = Limb:GetDataHigtroup()[dlimbname][1]
		local dlimbname1 = Limb:GetName(intLimbID)
		local tick = math.Clamp(GetHealthFlip(dlimbname), 1, maxHealth) / maxHealth
		local isBroken = Limb:IsBroken(intLimbID)
		local isBleeding = Limb:IsBleeding(intLimbID)

		surface.SetMaterial(tickmat)
		surface.SetDrawColor(color_white)
		surface.DrawTexturedRect(dpW + 2, dpH + 22, 121 * tick, 10)

		surface.SetMaterial(damagepanel)
		surface.SetDrawColor(color_white)
		surface.DrawTexturedRect(dpW, dpH, 126, 33)

		draw.SimpleText(dlimbname1, font, dpW + 10, dpH + 10, defColor, TEXT_ALIGN_CENTER + 2, TEXT_ALIGN_CENTER)
		draw.SimpleText(GetHealthFlip(dlimbname).." / "..maxHealth, font, dpW + 60, dpH + 26, defColor, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)

		if isBroken then
			surface.SetMaterial(brokenmat)
			surface.SetDrawColor(color_white)
			surface.DrawTexturedRect(dpW, dpH + 35, 32, 32)
			
			dpW = dpW + 35
		end

		if isBleeding then
			surface.SetMaterial(bleedingmat)
			surface.SetDrawColor(color_white)
			surface.DrawTexturedRect(dpW, dpH + 35, 32, 32)
			
			dpW = dpW + 35
		end
	end

	hook.Add("GetLimbAlp", "LimbAlpha", function()
		local limbperc = Limb:GetHealthPercentage(limbname, true)
		local limbalp = 255
		if (limbperc) then
			limbalp = limbalp - (255 * (limbperc / 100))
		end

		return Color(255,255,255,limbalp)
	end)
vgui.Register("Limb.Panel", PANEL, "DFrame")

concommand.Add("limb", function()
	vgui.Create("Limb.Panel")
	LocalPlayer().limbTickBool = true
end)

concommand.Add("limb_remove", function()
	if (IsValid(Limb.gui)) then
		Limb.gui:Remove()
	end
end)

-- # https://maurits.tv/data/garrysmod/wiki/wiki.garrysmod.com/index67df-2.html
local function fnDSP(value)
	if (value > 80) then
		return 7
	elseif (value > 60) then
		return 6
	elseif (value > 40) then
		return 5
	else
		return 1
	end
end

hook.Add("RenderScreenspaceEffects", "Limb.RenderScreenspaceEffects", function()
	local player = LocalPlayer()
	if (IsValid(player) and player:Alive()) then
		local data = {}
		local color = 1
		
		if (Limb:GetCvar("blur_damage")) then
			local percent = Limb:GetHealthPercentage(HITGROUP_HEAD)
			
			if (Limb:GetCvar("dsp_player")) then
				player:SetDSP(fnDSP(percent))
			end
			data.health = math.Clamp(1 - (percent * 0.01), 0, 1)
			
			headDamage, maxHP, percent = nil, nil, nil
		elseif (player:Health() <= 75) then
			data.health = math.Clamp(1 - ((player:GetMaxHealth() - player:Health()) * 0.01), 0, 1)
		end
		
		if (player:Alive()) then
			color = math.Clamp(color - ((player:GetMaxHealth() - player:Health()) * 0.01), 0, color)
		else
			color = 0
		end
		
		local ColorModify = {}
		ColorModify["$pp_colour_brightness"] = 0
		ColorModify["$pp_colour_contrast"] = 1
		ColorModify["$pp_colour_colour"] = color
		ColorModify["$pp_colour_addr"] = 0
		ColorModify["$pp_colour_addg"] = 0
		ColorModify["$pp_colour_addb"] = 0
		ColorModify["$pp_colour_mulr"] = 0
		ColorModify["$pp_colour_mulg"] = 0
		ColorModify["$pp_colour_mulb"] = 0
		
		local addAlpha = nil
		for k, v in pairs(data) do
			if (!addAlpha or v < addAlpha) then
				addAlpha = v
			end
		end
		
		if (addAlpha) then
			DrawMotionBlur(math.Clamp(addAlpha, 0.1, 1), 1, 0)
		end
		
		-- # Hotfix for ColorModify issues on OS X.
		if (system.IsOSX()) then
			ColorModify["$pp_colour_brightness"] = 0
			ColorModify["$pp_colour_contrast"] = 1
		end
		
		DrawColorModify(ColorModify)
		
		if (Limb:GetCvar("shake_camera_player")) then
			local leftArm = Limb:GetHealthPercentage(HITGROUP_LEFTARM) / 100
			local rightArm = Limb:GetHealthPercentage(HITGROUP_RIGHTARM) / 100
			local armDamage = math.max(leftArm, rightArm)
			if (armDamage > 0) then
				if (Limb:GetCvar("shake_camera_chest")) then
					local chest = Limb:GetHealthPercentage(HITGROUP_CHEST) / 100
					if (chest > 0) then
						armDamage = armDamage + chest
					end
					chest = nil
				end
				
				if (Limb:GetCvar("shake_camera_head")) then
					local head = Limb:GetHealthPercentage(HITGROUP_HEAD) / 100
					if (head > 0) then
						armDamage = armDamage + head
					end
					head = nil
				end
			
				local UpperP, LowerP = (1*armDamage), (-1*armDamage)
				local UpperY, LowerY = (1*armDamage), (-1*armDamage)
				
				if UpperP > 0 then
					local ShakeAngles = Angle(math.Rand(UpperP,LowerP), math.Rand(UpperY,LowerY), 0)
					player:SetEyeAngles(player:EyeAngles() + ShakeAngles)
					ShakeAngles = nil
				end
				
				UpperP, LowerP, UpperY, LowerY = nil, nil, nil, nil
			end
			leftArm, rightArm, armDamage = nil, nil, nil
		end
	end
end)

if (Limb:GetCvar("prone") and prone) then
	hook.Add("prone.CanExit", "Limb.prone.CanExit", function(player)
		if (IsValid(player) and player:Alive()) then
			local legBroken = Limb:IsBroken(HITGROUP_LEFTLEG) and Limb:IsBroken(HITGROUP_RIGHTLEG)
			if (legBroken) then
				return false
			end
		end
	end)
end

local key = Limb.default_bind_key
local bindkey_key = CreateClientConVar("limb_bindkey_key", tostring(key), true, false, "Don't directly change this convar. Use the command limb_config.")
local limbPanel = nil
concommand.Add("limb_config", function()
	if (IsValid(limbPanel)) then
		limbPanel:Remove()
	end
	
	limbPanel = vgui.Create("DFrame")
	limbPanel:SetSize(200, 110)
	limbPanel:Center()
	limbPanel:SetTitle("Limb Config")
	limbPanel:MakePopup()

	local bindkey_desc = vgui.Create("DLabel", limbPanel)
	bindkey_desc:SetText("Limb bind key:")
	bindkey_desc:SizeToContents()
	bindkey_desc:SetPos(10, 30)

	local binder = vgui.Create("DBinder", limbPanel)
	binder:SetSize(150, 50)
	binder:SetPos(10, 50)
	binder:CenterHorizontal()
	binder:SetValue(bindkey_key:GetInt())
	function binder:OnChange(num)
		RunConsoleCommand("limb_bindkey_key", num)
		self:SetText(input.GetKeyName(num))
	end
end)

-- # Micro-ops
local UIVis, ConsoleVis, getFocus, keyDown = gui.IsGameUIVisible, gui.IsConsoleVisible, vgui.GetKeyboardFocus, input.IsKeyDown
local function isValidPanel(player)
	if (player:IsTyping() or player:getNetVar("typing") or ConsoleVis() or UIVis() or IsValid(fpnl) and fpnl:GetClassName():find("TextEntry", nil, true)) then
		return false
	end
	
	return true
end

hook.Add("Tick", "Limb.Tick", function()
	local player = LocalPlayer()
	if (!IsValid(player) or !player:Alive()) then
		return
	end
	
	if (ConsoleVis()) then
		RunConsoleCommand("limb_remove")
	end
	
	if (keyDown(bindkey_key:GetInt()) and isValidPanel(player) and (player.limbTick or 0) < CurTime()) then
		if (player.limbTickBool) then
			player.limbTickBool = nil
			RunConsoleCommand("limb_remove")
		else
			RunConsoleCommand("limb")
		end
		player.limbTick = CurTime() + .45
	end
end)