//MARK: Gun defines
/// Muzzle slot identifier
#define ATTACHMENT_SLOT_MUZZLE "muzzle"
/// Rail slot identifier
#define ATTACHMENT_SLOT_RAIL "rail"
/// Under slot identifier
#define ATTACHMENT_SLOT_UNDER "under"
/// Sibyl slot identifier
#define ATTACHMENT_SLOT_SIBYL "sibyl"

// Keys for attachment X/Y offset values
#define ATTACHMENT_OFFSET_X "x"
#define ATTACHMENT_OFFSET_Y "y"

//MARK: Modules type flags
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
#define GUN_MODULE_CLASS_ENERGY_WEAPON (1 << 12)

GLOBAL_LIST_INIT(gun_module_slot_ru_name, list(
	ATTACHMENT_SLOT_MUZZLE = "ствол",
	ATTACHMENT_SLOT_RAIL = "верхняя планка",
	ATTACHMENT_SLOT_UNDER = "цевьё",
	ATTACHMENT_SLOT_SIBYL = "курок"
))
//MARK: Firemodes
/// Single shot firemode
#define GUN_SINGLE_MODE 0
/// Burst fire mode
#define GUN_BURST_MODE 1
/// Full auto firemode
#define GUN_AUTO_MODE 2

#define GUN_MODE_SINGLE_ONLY 1
#define GUN_MODE_SINGLE_BURST 2
#define GUN_MODE_SINGLE_BURST_AUTO 3

//MARK: Calibers

// Pistol cartridges
/// Used in Soviet type pistols and SMG (TT, PPSh)
#define CALIBER_7_DOT_62X25MM "7,62x25 мм"
/// Used in most standart SMG and pistols
#define CALIBER_9MM "9x19 мм"
/// Used in Stechkin pistol
#define CALIBER_10MM "10x25 мм"
/// Used in SP-8 pistol
#define CALIBER_40NR ".40 N&R"
/// Used in M1911 pistol, C-20r SMG
#define CALIBER_DOT_45 ".45"
/// Used in Colt-type revolvers and pistols (maybe merge it with .45?)
#define CALIBER_DOT_45_COLT ".45 Colt"
/// Used in .45 N&R specialized weapons (maybe merge it with .45?)
#define CALIBER_45NR ".45 N&R"
/// Used in Desert Eagle pistol
#define CALIBER_DOT_50AE ".50 AE"

// Revolver cartridges
/// Used in heavy revolvers like Unica-6
#define CALIBER_DOT_357 ".357 Magnum"
/// Used in small caliber revolvers
#define CALIBER_DOT_38 ".38"
/// Used in Gatfruit revolver
#define CALIBER_DOT_36 ".36"
/// Used in improvised revolver
#define CALIBER_DOT_257 ".257"
/// Used in Nagant revolver
#define CALIBER_7_DOT_62X38MM "7,62x38 мм"
/// Used in RSh-12 revolver
#define CALIBER_12_DOT_7X55MM "12.7x55 мм"

// Intermediate cartridges
/// Used in AR-15 type rifles (TSF)
#define CALIBER_5_DOT_56X45MM "5,56x45 мм"
/// Used in AK-74 type rifles (USSP)
#define CALIBER_5_DOT_45X39MM "5,45x39 мм"
/// Used in PDWs like WT-550
#define CALIBER_4_DOT_6X30MM "4,6x30 мм"

// Heavy cartridges
/// Used in Soviet type heavy guns like Mosin rifle
#define CALIBER_7_DOT_62X54MM "7,62x54 мм"
/// Used in NATO type heavy guns like 'L6 SAW' lmg
#define CALIBER_7_DOT_62X51MM "7,62x51 мм"
/// Used in Syndicate sniper rifle
#define CALIBER_DOT_50 ".50"
/// Used in Compact Syndicate sniper rifle
#define CALIBER_DOT_50L ".50 L"
/// Used in AXMC sniper rifle
#define CALIBER_DOT_338 ".338"

// Shotgun cartridges
/// Used in all shotguns
#define CALIBER_12G "12g"

// Grenade launcher cartridges
/// Used in underbarrel grenade launchers and Bombarda
#define CALIBER_40MM "40 мм"
/// Used in heavy grenade launchers like PML-9
#define CALIBER_84MM "84 мм"

// Rocket systems
/// Used in rocket launchers
#define CALIBER_ROCKET "rocket"

// Special ammunition
/// Used in speargun
#define CALIBER_SPEAR "spear"
/// Used in bows and crossbows
#define CALIBER_ARROW "arrow"
/// Used in Specter pistol
#define CALIBER_SPECTER "specter"

// Energy weapons
/// Used in laser weapons
#define CALIBER_LASER "\"лазер\""

// Foam force weapons
/// Used in foam guns
#define CALIBER_FOAM_FORCE "\"пенопластовый\""
/// Used in sniper foam gun
#define CALIBER_FOAM_FORCE_SNIPER "\"пенопластовый снайперский\""

// Blank cartridges
/// Used in toy cap guns
#define CALIBER_CAP "\"холостой\""

// Heavy weapons
/// Used in high-caliber rocket launchers
#define CALIBER_DOT_75 ".75"

#define FAKE_CALIBER_40MM_IMP "импровизированный 40 мм"
#define FAKE_CALIBER_80MM_MORTAR "80 мм миномётный"

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
/// Enforcer accuracy
#define GUN_ACCURACY_PISTOL_ENFORCER new /datum/gun_accuracy/pistol/enforcer()
/// Uplink pistol accuracy (better than normal pistols)
#define GUN_ACCURACY_PISTOL_UPLINK new /datum/gun_accuracy/pistol/uplink()
/// Stechkin accuracy
#define GUN_ACCURACY_PISTOL_STECHKIN new /datum/gun_accuracy/pistol/stechkin()
/// Rifle accuracy (more than default)
#define GUN_ACCURACY_RIFLE new /datum/gun_accuracy/rifle()
/// Laser rifle accuracy (default but lesser spread)
#define GUN_ACCURACY_RIFLE_LASER new /datum/gun_accuracy/rifle/laser()
/// Uplink rifles accuracy (better than default rifles)
#define GUN_ACCURACY_RIFLE_UPLINK new /datum/gun_accuracy/rifle/uplink()
/// Sniper rifle accuracy (100% hit)
#define GUN_ACCURACY_SNIPER new /datum/gun_accuracy/sniper()

// Bullet type overlays
#define BULLET_TYPE_PLAIN "plain_bullet"
#define BULLET_TYPE_RUBBER "rubber"
#define BULLET_TYPE_ARMOR_PIERCING "armor_piercing"
#define BULLET_TYPE_EXPANSIVE "expansive"
#define BULLET_TYPE_FIRE "fire"
#define BULLET_TYPE_LASER "laser"
#define BULLET_TYPE_DISABLER "disabler"

/// Magazine reload duration
#define GUN_MAGAZINE_RELOAD_DURATION (1 SECONDS)

// Chrono beam stuff
#define CHRONO_BEAM_RANGE 3
#define CHRONO_FRAME_COUNT 22
