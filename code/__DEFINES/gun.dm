// Gun defines
/// Muzzle slot identifier
#define ATTACHMENT_SLOT_MUZZLE "muzzle"
/// Rail slot identifier
#define ATTACHMENT_SLOT_RAIL "rail"
/// Under slot identifier
#define ATTACHMENT_SLOT_UNDER "under"

#define GUN_MODULE_CLASS_NONE 0
// Rail slot types flags
#define GUN_MODULE_CLASS_PISTOL_RAIL (1<<0)
#define GUN_MODULE_CLASS_SHOTGUN_RAIL (1<<1)
#define GUN_MODULE_CLASS_RIFLE_RAIL (1<<2)
#define GUN_MODULE_CLASS_SNIPER_RAIL (1<<3)

// Muzzle slot types flags
#define GUN_MODULE_CLASS_PISTOL_MUZZLE (1<<4)
#define GUN_MODULE_CLASS_SHOTGUN_MUZZLE (1<<5)
#define GUN_MODULE_CLASS_RIFLE_MUZZLE (1<<6)
#define GUN_MODULE_CLASS_SNIPER_MUZZLE (1<<7)
#define GUN_MODULE_CLASS_ANY_MUZZLE (GUN_MODULE_CLASS_PISTOL_MUZZLE | GUN_MODULE_CLASS_SHOTGUN_MUZZLE | GUN_MODULE_CLASS_RIFLE_MUZZLE | GUN_MODULE_CLASS_SNIPER_MUZZLE)

// Under slot types flags
#define GUN_MODULE_CLASS_PISTOL_UNDER (1<<8)
#define GUN_MODULE_CLASS_SHOTGUN_UNDER (1<<9)
#define GUN_MODULE_CLASS_RIFLE_UNDER (1<<10)
#define GUN_MODULE_CLASS_SNIPER_UNDER (1<<11)

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

//Calibers
#define CALIBER_9MM "9mm"
#define CALIBER_9MM_TE "9mm TE"
#define CALIBER_DOT_357 ".357"
#define CALIBER_DOT_257 ".257"
#define CALIBER_40NR "40nr"
#define CALIBER_7_DOT_62X54MM "7.62x54mm"
#define CALIBER_7_DOT_62X51MM "7.62x51mm"
#define CALIBER_7_DOT_62X25MM "7.62x25mm"
#define CALIBER_7_DOT_62X38MM "7.62x38mm"
#define CALIBER_DOT_338 ".338"
#define CALIBER_DOT_50 ".50"
#define CALIBER_DOT_50L ".50L"
#define CALIBER_DOT_50AE ".50ae"
#define CALIBER_DOT_38 ".38"
#define CALIBER_DOT_36 ".36"
#define CALIBER_10MM "10mm"
#define CALIBER_4_DOT_6X30MM "4.6x30mm"
#define CALIBER_DOT_45 ".45"
#define CALIBER_SPEAR "spear"
#define CALIBER_84MM "84mm"
#define CALIBER_12X70 "12х70"
#define CALIBER_SPECTER "specter"
#define CALIBER_5_DOT_56X45MM "5.56x45mm"
#define CALIBER_5_DOT_45X39MM "5.45x39mm"
#define CALIBER_ROCKET "rocket"
#define CALIBER_DOT_75 ".75"
#define CALIBER_40MM "40mm"
#define CALIBER_FOAM_FORCE "foam force"
#define CALIBER_FOAM_FORCE_SNIPER "foam force sniper"
#define CALIBER_CAP "cap"
#define CALIBER_LASER "laser"
#define CALIBER_ARROW "arrow"

#define FAKE_CALIBER_40MM_IMP "improvised 40mm"
#define FAKE_CALIBER_80MM_MORTAR "80mm mortar"

/// Minimal recoil
#define GUN_RECOIL_MIN new /datum/gun_recoil/minimal()
/// Low recoil
#define GUN_RECOIL_LOW new /datum/gun_recoil/low()
/// Medium recoil
#define GUN_RECOIL_MEDIUM new /datum/gun_recoil/medium()
/// High recoil
#define GUN_RECOIL_HIGH new /datum/gun_recoil/high()
/// Mega recoil
#define GUN_RECOIL_MEGA new /datum/gun_recoil/mega()

/// Default accuracy for all projectile weapon
#define GUN_ACCURACY_DEFAULT new /datum/gun_accuracy/default()
/// Minimal gun accuracy
#define GUN_ACCURACY_MINIMAL new /datum/gun_accuracy/minimal()
/// Shotgun accuracy (less than default)
#define GUN_ACCURACY_SHOTGUN new /datum/gun_accuracy/shotgun()
/// Pistol accuracy (near default)
#define GUN_ACCURACY_PISTOL new /datum/gun_accuracy/pistol()
/// Uplink pistol accuracy (better than normal pistols)
#define GUN_ACCURACY_PISTOL_UPLINK new /datum/gun_accuracy/pistol/uplink()
/// Rifle accuracy (more than default)
#define GUN_ACCURACY_RIFLE new /datum/gun_accuracy/rifle()
/// Laser rifle accuracy (default but lesser spread)
#define GUN_ACCURACY_RIFLE_LASER new /datum/gun_accuracy/rifle/laser()
/// Uplink rifles accuracy (better than default rifles)
#define GUN_ACCURACY_RIFLE_UPLINK new /datum/gun_accuracy/rifle/uplink()
/// Sniper rifle accuracy (100% hit)
#define GUN_ACCURACY_SNIPER new /datum/gun_accuracy/sniper()
