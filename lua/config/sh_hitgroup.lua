Limb:AddHitGroup(HITGROUP_HEAD, {
	25, -- # MaxHealth
	"Head", -- # Name
	20, -- # Bone break threshold
	5, -- # Bleeding threshold
	1 -- # Base damage scale to player [Damaged limb will affect your overall damage resistance] (for nutscript 0.05 or higher recommended)
})

Limb:AddHitGroup(HITGROUP_CHEST, {
	100,
	"Chest",
	25,
	5,
	1
})

Limb:AddHitGroup(HITGROUP_STOMACH, {
	100,
	"Chest",
	25,
	5,
	1
})

Limb:AddHitGroup(HITGROUP_LEFTLEG, {
	30,
	"Left Leg",
	3,
	10,
	1
})

Limb:AddHitGroup(HITGROUP_LEFTARM, {
	30,
	"Left Arm",
	3,
	10,
	1
})

Limb:AddHitGroup(HITGROUP_RIGHTLEG, {
	30,
	"Right Leg",
	3,
	10,
	1
})

Limb:AddHitGroup(HITGROUP_RIGHTARM, {
	30,
	"Right Arm",
	3,
	10,
	1
})