// Armor penetration defines

// MARK: Armor plate slot
#define ARMOR_PLATE_SLOT_NONE 0
#define ARMOR_PLATE_SLOT_HANDMADE 1
#define ARMOR_PLATE_SLOT_LIGHT 2
#define ARMOR_PLATE_SLOT_MEDIUM 3
#define ARMOR_PLATE_SLOT_HEAVY 4
#define ARMOR_PLATE_SLOT_MAX 5


// MARK: Laser protection
/// Not exists protection
#define LASER_ARMOR_CLASS_NONE 0
/// Protect from: dominator, specter
#define LASER_ARMOR_CLASS_LIGHT 1
/// Protect from: energy gun, aeg, lr-30 and other
#define LASER_ARMOR_CLASS_MEDIUM 2
/// Protect from: accelerator
#define LASER_ARMOR_CLASS_HEAVY 3
/// Not exists protect from: annihilator
#define LASER_ARMOR_CLASS_MAX 4

GLOBAL_LIST_INIT(laser_armor_class_name, list(
		LASER_ARMOR_CLASS_NONE = "",
		LASER_ARMOR_CLASS_LIGHT = "I",
		LASER_ARMOR_CLASS_MEDIUM = "II",
		LASER_ARMOR_CLASS_HEAVY = "III",
		LASER_ARMOR_CLASS_MAX = "IV",
	))

// MARK: Ballistic protection
/// Not exists protection
#define BALLISTIC_ARMOR_CLASS_NONE 0
/// Protect from light pistols
#define BALLISTIC_ARMOR_CLASS_I 1
/// Protect from pistols
#define BALLISTIC_ARMOR_CLASS_IIA 2
/// Protect from heavy pistols
#define BALLISTIC_ARMOR_CLASS_II 3
/// Protect from light rifles
#define BALLISTIC_ARMOR_CLASS_IIIA 4
/// Protect from rifles
#define BALLISTIC_ARMOR_CLASS_III 5
/// Protect from heavy rifles
#define BALLISTIC_ARMOR_CLASS_IV 6
/// Not exists protect from high calibers. DO NOT USE FOR ARMOR (admin only)
#define BALLISTIC_ARMOR_CLASS_MAX 7

GLOBAL_LIST_INIT(ballistic_armor_class_name, list(
		BALLISTIC_ARMOR_CLASS_NONE = "",
		BALLISTIC_ARMOR_CLASS_I = "I",
		BALLISTIC_ARMOR_CLASS_IIA = "IIA",
		BALLISTIC_ARMOR_CLASS_II = "II",
		BALLISTIC_ARMOR_CLASS_IIIA = "IIIA",
		BALLISTIC_ARMOR_CLASS_III = "III",
		BALLISTIC_ARMOR_CLASS_IV = "IV",
		BALLISTIC_ARMOR_CLASS_MAX = "V",
	))


/// Default penetration for all projectiles
#define BASIC_PENETRATION 1

// MARK: Laser penetration
/// Non penetrive laser: practice laser
#define LASER_PENETRATION_NONE 0
/// Light lasers: dominator, specter
#define LASER_PENETRATION_LIGHT 1
/// Medium lasers: Energy gun, laser car, AEG, LR-30 and more regular
#define LASER_PENETRATION_MEDIUM 2
/// Heavy lasers: Accelerator
#define LASER_PENETRATION_HEAVY 3
/// Maximal lasers: Annihilator
#define LASER_PENETRATION_MAX 4

// MARK: Ballistic penetration
/// Light pistols: .38 HP, .36, 10mm HP, all rubber,
#define BALLISTIC_PENETRATION_LIGHT_PISTOL 1
/// Pistols: 9mm, .38, .257
#define BALLISTIC_PENETRATION_PISTOL 2
/// Heavy pistols: 10mm, .40N&R, .45, 7.62x25mm
#define BALLISTIC_PENETRATION_HEAVY_PISTOL 3
/// Light rifles: .357, .44, 4.6x30mm, 7.62x38, 12x70 Fleshetta
#define BALLISTIC_PENETRATION_LIGHT_RIFLE 4
/// Rifles: 5.56mm, 5.45x39mm, 10mm AP, 12x70 Slug, .50AE
#define BALLISTIC_PENETRATION_RIFLE	5
/// Heavy rifles: 5.56x45mm, 4.6x30mm AP
#define BALLISTIC_PENETRATION_HEAVY_RIFLE 6
/// High calibers: .50COMP и .50
#define BALLISTIC_PENETRATION_HIGH_CAL 7
