Limb.Include("plugins/raised/sh_raised.lua")

if (Limb:IsNutscript()) then
	MsgC(color_white, "[LIMB] Nutscript supported\n")
	Limb.Include("plugins/nutscript/sv_nutscript.lua")
	Limb.Include("plugins/nutscript/cl_nutscript.lua")
end

Limb.Include("plugins/config_menu/sv_config_menu.lua")
Limb.Include("plugins/config_menu/cl_config_menu.lua")