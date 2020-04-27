local type_to_convar = {
	['number'] = 'Integer',
	['string'] = 'Generic',
	['boolean'] = 'Boolean'
}

local function table_to_str(data)
	if not istable(data) then return data end
	
	local str = ""
	local i = 0
	local last_iter = table.Count(data)
	
	for k, v in pairs(data) do
		str = str .. "" .. k .. ""
		i = i + 1
		
		if last_iter ~= i then
			str = str .. ", "
		end
	end
	
	return str
end

local PANEL = {}

function PANEL:Init()
	self.PanelRows = {}
	self.CvarsSave = {}
	
	self:SetSize(ScrW() * 0.9, ScrH() * 0.9)
	self:Center()
	self:SetTitle("LimbSystem => Config Menu")
	self:MakePopup()
	
	self.props = self:Add('DProperties')
	self.props:Dock(FILL)
	
	for cvar, value in pairs(Limb.config) do -- Cvars
		local TYPE = type(value)
		local LONG_TYPE = type_to_convar[TYPE] or TYPE
		
		self.PanelRows[cvar] = self.props:CreateRow(LONG_TYPE, cvar)
		
		if TYPE == 'number' then
			self.PanelRows[cvar]:Setup(LONG_TYPE, {max = 999, min = 0})
		elseif TYPE == 'table' then
			self.PanelRows[cvar]:Setup(LONG_TYPE)
		else
			self.PanelRows[cvar]:Setup(LONG_TYPE)
		end
		
		if TYPE == 'table' then
			local convert = table_to_str(value)
			self.PanelRows[cvar]:SetValue(convert)
			self.CvarsSave[cvar] = convert
			convert = nil
		else
			self.PanelRows[cvar]:SetValue(value)
			self.CvarsSave[cvar] = value
		end
		
		self.PanelRows[cvar].DataChanged = function(row, value)
			if TYPE == 'boolean' then
				self.CvarsSave[cvar] = tobool(value)
			else
				self.CvarsSave[cvar] = value
			end
		end
		
		local desc = Limb.desc_config[cvar]
		if desc then
			self.PanelRows[cvar]:SetTooltip(desc)
		end
	end
	
	self.submit = self:Add("DButton")
	self.submit:SetText("Save cvars")
	self.submit:Dock(BOTTOM)
	self.submit.DoClick = function()
		if table.Count(self.CvarsSave) > 0 then
			for cvar, value in pairs(self.CvarsSave) do
				if cvar == 'dmg_break_bones' or cvar == 'dmg_starts_bleeding' or cvar == 'always_can_shoot' then
					local new = {}
					local split = string.Explode(', ', value)
					for k, v in ipairs(split) do
						new[v] = true
					end
					self.CvarsSave[cvar] = new
					split, new = nil, nil
				end
			end
		
			netstream.Start("LCM_DataChanged", self.CvarsSave)
		end
	end
end

vgui.Register("limb_cvars_menu", PANEL, "DFrame")

local config_menu
concommand.Add("limb_cvars", function()
	if not LocalPlayer():IsSuperAdmin() then return end
	
	if IsValid(config_menu) then
		config_menu:Remove()
	end
	
	config_menu = vgui.Create('limb_cvars_menu')
end)

netstream.Hook('LCM_DataChanged', function(data)
	for cvar, value in pairs(data) do
		Limb.config[cvar] = value
	end
end)