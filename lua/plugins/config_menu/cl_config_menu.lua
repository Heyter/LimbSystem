local type_to_convar = {
	['boolean'] = 'Boolean',
	['number'] = 'Int',
	['string'] = 'Generic',
}

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
		local TYPE = type_to_convar[type(value)]
		
		self.PanelRows[cvar] = self.props:CreateRow(TYPE, cvar)
		
		if TYPE == 'Int' then
			self.PanelRows[cvar]:Setup(TYPE, {max = 999, min = 0})
		else
			self.PanelRows[cvar]:Setup(TYPE)
		end
		
		self.PanelRows[cvar]:SetValue(value)
		
		self.PanelRows[cvar].DataChanged = function(row, value)
			if TYPE == 'Boolean' then
				self.CvarsSave[cvar] = tobool(value)
			else
				self.CvarsSave[cvar] = value
			end
		end
	end
	
	self.submit = self:Add("DButton")
	self.submit:SetText("Save cvars")
	self.submit:Dock(BOTTOM)
	self.submit.DoClick = function()
		if table.Count(self.CvarsSave) > 0 then
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