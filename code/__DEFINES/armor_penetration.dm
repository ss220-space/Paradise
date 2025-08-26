// Armor penetration defines

// MARK: Armor classes

#define ARMOR_CLASS_EXTREMELY_HEAVY 5
#define ARMOR_CLASS_HEAVY 			4
#define ARMOR_CLASS_MEDIUM 			3
#define ARMOR_CLASS_LIGHT 			2
#define ARMOR_CLASS_ULTRA_LIGHT 	1
#define ARMOR_CLASS_NONE 			0



// MARK: Ballistic protection
#define BALLISTIC_ARMOR_CLASS_NONE 		0

/// Protect from: weak bullets, .38 HP, .36, 10mm HP, all rubber,
#define BALLISTIC_ARMOR_CLASS_I 		1

/// Protect from: 9mm, .38, .257
#define BALLISTIC_ARMOR_CLASS_IIA 		1.5

/// Protect from: 10mm, .40N&R, .45, 7.62x25mm,
#define BALLISTIC_ARMOR_CLASS_II 		2

/// Protect from: .357, .44, 4.6x30mm, 7.62x38, 12x70 Fleshetta
#define BALLISTIC_ARMOR_CLASS_IIIA 		2.5

/// Protect from: 5.56mm, 5.45x39mm, 10mm AP, 12x70 Slug, .50AE
#define BALLISTIC_ARMOR_CLASS_III 		3

/// Protect from: 5.56x45mm, 4.6x30mm AP
#define BALLISTIC_ARMOR_CLASS_IV 		4

/// Not exists protect from: .50COMP и .50. DO NOT USE FOR ARMOR (admin only)
#define BALLISTIC_ARMOR_CLASS_MAX 		5


// MARK: Laser protection

#define LASER_ARMOR_CLASS_NONE 		0

/// Protect from: electrode
#define LASER_ARMOR_CLASS_I 		1

/// Protect from: low-energy
#define LASER_ARMOR_CLASS_II 		2

/// Protect from: energy
#define LASER_ARMOR_CLASS_III 		3

/// Protect from: high-energy
#define LASER_ARMOR_CLASS_IV 		4

/// Not exists protect from: extremely-energy. DO NOT USE FOR ARMOR (admin only)
#define LASER_ARMOR_CLASS_MAX 		5
