// Accuracy datum for /obj/item/gun

/// Default accuracy for all projectile weapon
#define GUN_ACCURACY_DEFAULT new /datum/gun_accuracy/default()
/// Minimal gun accuracy
#define GUN_ACCURACY_MINIMAL new /datum/gun_accuracy/minimal()
/// Shotgun accuracy (less than default)
#define GUN_ACCURACY_SHOTGUN new /datum/gun_accuracy/shotgun()
/// Pistol accuracy (near default)
#define GUN_ACCURACY_PISTOL new /datum/gun_accuracy/pistol()
/// Rifle accuracy (more than default)
#define GUN_ACCURACY_RIFLE new /datum/gun_accuracy/rifle()
/// Sniper rifle accuracy (100% hit)
#define GUN_ACCURACY_SNIPER new /datum/gun_accuracy/sniper()

GLOBAL_DATUM_INIT(gun_accuracy_sniper, /datum/gun_accuracy, GUN_ACCURACY_SNIPER)
GLOBAL_DATUM_INIT(gun_accuracy_default, /datum/gun_accuracy, GUN_ACCURACY_DEFAULT)

//MARK: Accuracy datum
/datum/gun_accuracy
	var/head = 100
	var/chest = 100
	var/arms = 100
	var/legs = 100
	var/hands = 100
	var/foots = 100
	var/other = 100
	/// Two hand gun bonus spread
	var/dual_wield_spread = 24
	/// Shot spread in ange
	var/min_spread = 0
	var/max_spread = 0


/datum/gun_accuracy/proc/getList()
	return list("head" = head, "chest" = chest, "arms" = arms, "legs" = legs, "hands" = hands, "foots" = foots, "other" = other, "min_spread" = min_spread, "max_spread" = max_spread, "dual_wield_spread" = dual_wield_spread)

/datum/gun_accuracy/proc/get_accuracy_for(def_zone)
	switch(def_zone)
		if(BODY_ZONE_CHEST, BODY_ZONE_PRECISE_GROIN)
			return chest
		if(BODY_ZONE_HEAD, BODY_ZONE_PRECISE_EYES, BODY_ZONE_PRECISE_MOUTH)
			return head
		if(BODY_ZONE_L_LEG, BODY_ZONE_R_LEG)
			return legs
		if(BODY_ZONE_L_ARM, BODY_ZONE_R_ARM)
			return arms
		if(BODY_ZONE_PRECISE_L_FOOT, BODY_ZONE_PRECISE_R_FOOT)
			return foots
		if(BODY_ZONE_PRECISE_L_HAND, BODY_ZONE_PRECISE_R_HAND)
			return hands
		else
			return other

/proc/getAccuracy(head = 75, chest = 100, arms = 66, legs = 66, hands = 50, foots = 50, other = 50, min_spread = 0, max_spread = 0, dual_wield_spread = 24)
	var/datum/gun_accuracy/acc = new /datum/gun_accuracy()
	acc.head = head
	acc.chest = chest
	acc.arms = arms
	acc.legs = legs
	acc.hands = hands
	acc.foots = foots
	acc.other = other
	acc.min_spread = min_spread
	acc.max_spread = max_spread
	acc.dual_wield_spread = dual_wield_spread
	return acc

// MARK: Accuracy
/datum/gun_accuracy/minimal
	head = 66
	chest = 85
	arms = 50
	legs = 50
	hands = 33
	foots = 33
	other = 33
	dual_wield_spread = 45
	min_spread = 15
	max_spread = 30

/datum/gun_accuracy/shotgun
	head = 70
	chest = 100
	arms = 60
	legs = 60
	hands = 40
	foots = 40
	other = 40
	dual_wield_spread = 35
	min_spread = 10
	max_spread = 20

/datum/gun_accuracy/default
	head = 75
	chest = 100
	arms = 66
	legs = 66
	hands = 50
	foots = 50
	other = 50
	dual_wield_spread = 24
	min_spread = 0
	max_spread = 0

/datum/gun_accuracy/pistol
	head = 75
	chest = 100
	arms = 66
	legs = 66
	hands = 50
	foots = 50
	other = 50
	dual_wield_spread = 15 // less spread with dual wield, pistol are small item
	min_spread = 6
	max_spread = 15


/datum/gun_accuracy/rifle
	head = 90
	chest = 120
	arms = 80
	legs = 80
	hands = 66
	foots = 66
	other = 66
	dual_wield_spread = 24
	min_spread = 3
	max_spread = 10

// min accuracy on range 12 is 50%, summary accuracy = 50% * 200% = 100%
/datum/gun_accuracy/sniper
	head = 200
	chest = 200
	arms = 200
	legs = 200
	hands = 200
	foots = 200
	other = 200
	///Additional spread when dual wielding.
	dual_wield_spread = 24
	min_spread = 0
	max_spread = 0


// MARK: Specific accuracy

/datum/gun_accuracy/rifle/extend_spread
	min_spread = 5
	max_spread = 20

/datum/gun_accuracy/minimal/gatling
	min_spread = 10
	max_spread = 45

/datum/gun_accuracy/pistol/extends_spread
	min_spread = 7
	max_spread = 20

// MARK: Procs

/datum/gun_accuracy/proc/randomize_spread(bonus_spread)
	if(!max_spread)
		return round((rand() - 0.5) * bonus_spread)
	var/random_angle = round(rand(min_spread / 2, max_spread / 2 + bonus_spread / 2))
	return pick(1, -1) * random_angle


/obj/projectile/proc/calculate_hit_chance(obj/projectile/projectile, mob/living/target)
	if(forced_accuracy)
		return 100
	var/distance = get_dist(starting, target)
	if(distance < 2) //point-back shot (diagonal dist is 1.414)
		return 100
	var/obj/item/gun/gun = projectile.firer_source_atom
	var/datum/gun_accuracy/gun_accuracy = GLOB.gun_accuracy_sniper
	if(istype(gun))
		gun_accuracy = gun.accuracy
	var/def_zone_accuracy = gun_accuracy.get_accuracy_for(projectile.def_zone)
	var/distance_mod = accuracy_for_distance(distance) / 100
	return clamp(def_zone_accuracy * distance_mod, 0, 100)


#define FULL_ACCURACY_DISTANCE 3
#define MIN_ACCURACY_DISTANCE 20
#define MIN_ACCURACY_PERCENT 50
#define FULL_ACCURACY_PERCENT 100

/obj/projectile/proc/accuracy_for_distance(distance)
	if(distance < FULL_ACCURACY_DISTANCE)
		return FULL_ACCURACY_PERCENT
	var/distance_progress = 1 - clamp((distance - FULL_ACCURACY_DISTANCE) / (MIN_ACCURACY_DISTANCE - FULL_ACCURACY_DISTANCE), 0, 1)
	return clamp(distance_progress * (FULL_ACCURACY_PERCENT - MIN_ACCURACY_PERCENT) + MIN_ACCURACY_PERCENT, 0, 100)

/obj/projectile/proc/calculate_randomize_def_zone_chance(obj/projectile/projectile, distance)
	var/obj/item/gun/gun = projectile.firer_source_atom
	var/datum/gun_accuracy/gun_accuracy = GLOB.gun_accuracy_sniper
	if(istype(gun))
		gun_accuracy = gun.accuracy
	var/def_zone_accuracy = gun_accuracy.get_accuracy_for(projectile.def_zone)
	return clamp(def_zone_accuracy * (max(100 - 3*distance, 33) / 100), 0, 100)

#undef FULL_ACCURACY_DISTANCE
#undef MIN_ACCURACY_DISTANCE
#undef MIN_ACCURACY_PERCENT
#undef FULL_ACCURACY_PERCENT
