// Armor penetration defines

// MARK: Armor plate slot
#define ARMOR_PLATE_SLOT_NONE 		0
#define ARMOR_PLATE_SLOT_HANDMADE 	1
#define ARMOR_PLATE_SLOT_LIGHT 		2
#define ARMOR_PLATE_SLOT_MEDIUM 	3
#define ARMOR_PLATE_SLOT_HEAVY 		4
#define ARMOR_PLATE_SLOT_MAX 		5


// MARK: Laser protection
/// Not exists protection
#define LASER_ARMOR_CLASS_NONE		0

/// Protect from: dominator, specter
#define LASER_ARMOR_CLASS_LIGHT		1

/// Protect from: energy gun, aeg, lr-30 and other
#define LASER_ARMOR_CLASS_MEDIUM	2

/// Protect from: accelerator
#define LASER_ARMOR_CLASS_HEAVY		3

/// Not exists protect from: annihilator
#define LASER_ARMOR_CLASS_MAX		4


// MARK: Ballisti protection
/// Not exists protection
#define BALLISTIC_ARMOR_CLASS_NONE 		0

/// Protect from: weak bullets, .38 HP, .36, 10mm HP, all rubber,
#define BALLISTIC_ARMOR_CLASS_I 		1

/// Protect from: 9mm, .38, .257
#define BALLISTIC_ARMOR_CLASS_IIA 		2

/// Protect from: 10mm, .40N&R, .45, 7.62x25mm,
#define BALLISTIC_ARMOR_CLASS_II 		3

/// Protect from: .357, .44, 4.6x30mm, 7.62x38, 12x70 Fleshetta
#define BALLISTIC_ARMOR_CLASS_IIIA 		4

/// Protect from: 5.56mm, 5.45x39mm, 10mm AP, 12x70 Slug, .50AE
#define BALLISTIC_ARMOR_CLASS_III 		5

/// Protect from: 5.56x45mm, 4.6x30mm AP
#define BALLISTIC_ARMOR_CLASS_IV 		6

/// Not exists protect from: .50COMP и .50. DO NOT USE FOR ARMOR (admin only)
#define BALLISTIC_ARMOR_CLASS_MAX 		7
