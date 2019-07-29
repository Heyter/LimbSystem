Limb:AddCvar("debug", false) -- # Only if your needing debug
Limb:AddCvar("system", true) -- # Enable or disable limb system [true/[false or nil]]

Limb:AddCvar("disability", true) -- # Limb disability

Limb:AddCvar("reset_limb", true) -- # Reset limb's data when player death.
Limb:AddCvar("init_limb", true) -- # Init limb when player init spawn

Limb:AddCvar("Bleeding", true) -- # Enable bleeding
Limb:AddCvar("BleedInterval", 30) -- # Every tick bleed
Limb:AddCvar("BleedDamage", 2) -- # Damage player
Limb:AddCvar("BleedLimbDamage", 2) -- # Limb damage.
Limb:AddCvar("BleedIntervalLimb", 60) -- # Every tick bleed limb.

Limb:AddCvar("pain_sound", true) -- # Playing pain sound when player get damage.
Limb:AddCvar("blood_effect", true) -- # Blood effect when player get damage.

Limb:AddCvar("blur_damage", true) -- # Enable blur effect (CLIENT)

Limb:AddCvar("limp_broken", true) -- # Limp when player broken leg

Limb:AddCvar("prone", true) -- # Need addon "Prone". (When player broken legs)

Limb:AddCvar("raised_weapon_system", true) -- # Enable system raised weapon. (nutscript use own raised system, but work with limb)
Limb:AddCvar("hold_raised_weapon", true) -- # Hold R to raise weapon (false = disabled) (Don't worked for nutscript)
Limb:AddCvar("raised_weapon", false) -- # Always raise weapon? (true = always) (Don't worked for nutscript)
Limb.ALWAYS_RAISED = {} -- Or add in SWEP = SWEP.IsAlwaysRaised = true (Don't worked for nutscript)
Limb.ALWAYS_RAISED["weapon_physgun"] = true
Limb.ALWAYS_RAISED["gmod_tool"] = true
Limb.ALWAYS_RAISED["weapon_crowbar"] = true

Limb:AddCvar("unlock_time", 3) -- # The time that a player has to wait to unlock a door (seconds)
Limb:AddCvar("lock_time", 3) -- # The time that a player has to wait to lock a door (seconds).

Limb:AddCvar("fire_spread", true) -- # Called every time a bullet is fired from an weapon. Weapon spread. (hook EntityFireBullets)
Limb:AddCvar("spread_only_arms", false) -- # Will count only broken arms.

Limb:AddCvar("broken_arms_drop", true) -- # If player arm broken then he will drop weapon when somebody shooting in him.

Limb:AddCvar("scale_damage_player", true) -- # Damaged limb will affect your overall damage resistance. (only health player) [settings in sh_hitgroup.lua]

Limb:AddCvar("dsp_player", true) -- # Adds an effect to the player's sound (CLIENT)
Limb:AddCvar("shake_camera_player", true) -- # Shake the player's camera, if arms or chest or head damaged. (Worked if arms damaged. arms > chest > head)
Limb:AddCvar("shake_camera_head", false) -- # Multiply shake camera if head damaged (arms + head) [true = enabled]
Limb:AddCvar("shake_camera_chest", false) -- # Multiply shake camera if chest damaged (arms + chest) [true = enabled]

Limb:AddCvar("save_limbdata", true) -- # Save player limbData in Database. (Working only on nutscript!)

Limb.default_bind_key = KEY_L -- # What is the default bind key set by the server. (See http://wiki.garrysmod.com/page/Enums/KEY)

Limb:AddCvar("armor_damage", true) -- # Damage player if has armor.
Limb:AddCvar("armor_inc_damage", 2) -- # On how many to increase a damage, if player doesn't have armor. (1 = disabled)
Limb:AddCvar("armor_dec_damage", 2) -- # On how many to decrease a damage, if player has armor. (1 = disabled)

/* Limb.RESTRICTED = { -- # Who will not get damage limb. (player:Team() or player:SteamID() or player:GetUserGroup())
	["STEAM_0:0:1"] = true, -- # SteamID
	["user"] = true, -- # GetUserGroup
	[TEAM_BANNED] = true -- # Team
} */ -- uncomment, if needed

Limb.SupGamemodes = {
	["darkrp"] = {
		dropweapon = function(player)
			player:ConCommand("say /drop")
		end
	},
	
	["nutscript"] = {
		dropweapon = function(player)
			Limb:nutDropWeapon(player)
		end
	},
	
	["ttt"] = {
		dropweapon = function(player)
			player:ConCommand("ttt_dropweapon")
		end
	}
}

Limb.tbl_DmgBreakBones = { -- # Type damage when player get broken limb
	[DMG_CRUSH] = true, 
	[DMG_VEHICLE] = true, 
	[DMG_FALL] = true, 
	[DMG_BLAST] = true, 
	[DMG_CLUB] = true
}

Limb.tbl_DmgStartsBleeding = { -- # Type damage when player get bleeding limb
	[DMG_BULLET] = true, 
	[DMG_BUCKSHOT] = true, 
	[DMG_SLASH] = true, 
	[DMG_BLAST] = true, 
	[DMG_BURN] = true
}