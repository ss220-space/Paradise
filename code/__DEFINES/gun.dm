// Gun defines
/// Muzzle slot identifier
#define ATTACHMENT_SLOT_MUZZLE "muzzle"
/// Rail slot identifier
#define ATTACHMENT_SLOT_RAIL "rail"
/// Under slot identifier
#define ATTACHMENT_SLOT_UNDER "under"

#define GUN_MODULE_CLASS_NONE 			0
// Rail slot types flags
#define GUN_MODULE_CLASS_PISTOL_RAIL 	(1<<0)
#define GUN_MODULE_CLASS_SHOTGUN_RAIL 	(1<<1)
#define GUN_MODULE_CLASS_RIFLE_RAIL 	(1<<2)
#define GUN_MODULE_CLASS_SNIPER_RAIL 	(1<<3)

// Muzzle slot types flags
#define GUN_MODULE_CLASS_PISTOL_MUZZLE 	(1<<4)
#define GUN_MODULE_CLASS_SHOTGUN_MUZZLE (1<<5)
#define GUN_MODULE_CLASS_RIFLE_MUZZLE 	(1<<6)
#define GUN_MODULE_CLASS_SNIPER_MUZZLE 	(1<<7)
#define GUN_MODULE_CLASS_ANY_MUZZLE (GUN_MODULE_CLASS_PISTOL_MUZZLE | GUN_MODULE_CLASS_SHOTGUN_MUZZLE | GUN_MODULE_CLASS_RIFLE_MUZZLE | GUN_MODULE_CLASS_SNIPER_MUZZLE)

// Under slot types flags
#define GUN_MODULE_CLASS_PISTOL_UNDER 	(1<<8)
#define GUN_MODULE_CLASS_SHOTGUN_UNDER 	(1<<9)
#define GUN_MODULE_CLASS_RIFLE_UNDER 	(1<<10)
#define GUN_MODULE_CLASS_SNIPER_UNDER 	(1<<11)


GLOBAL_LIST_INIT(gun_module_slot_ru_name, list(
	ATTACHMENT_SLOT_MUZZLE = "ствол",
	ATTACHMENT_SLOT_RAIL = "верхняя планка",
	ATTACHMENT_SLOT_UNDER = "цевьё"
))

/// Single shot firemode
#define GUN_SINGLE_MODE 0
/// Burst fire mode
#define GUN_BURST_MODE 1
/// Full auto friemode
#define GUN_AUTO_MODE 2

#define GUN_MODE_SINGLE_ONLY 1
#define GUN_MODE_SINGLE_BURST 2
#define GUN_MODE_SINGLE_BURST_AUTO 3
