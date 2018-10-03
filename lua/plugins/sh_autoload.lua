if (Limb:GetCvar("raised_weapon_system") and !Limb:IsNutscript()) then
	util.Include("plugins/raised/sh_raised.lua")
end

if (Limb:IsNutscript()) then
	MsgC(color_white, "[LIMB] Nutscript supported\n")
	util.Include("plugins/nutscript/sv_nutscript.lua")
	util.Include("plugins/nutscript/cl_nutscript.lua")
end