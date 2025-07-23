// Accuracy datum for /obj/item/gun

/// Default accuracy for all projectile weapon
#define GUN_ACCURACY_DEFAULT new /datum/gun_accuracy(head_value = 75, chest_value = 100, arms_value = 66, legs_value = 66, hand_value = 50, foots_value = 50, other_value = 50)
/// Rifle accuracy (more than default)
#define GUN_ACCURACY_RIFLE new /datum/gun_accuracy(head_value = 90, chest_value = 100, arms_value = 80, legs_value = 80, hand_value = 66, foots_value = 66, other_value = 66)
/// Shotgun accuracy (less than default)
#define GUN_ACCURACY_SHOTGUN new /datum/gun_accuracy(head_value = 70, chest_value = 100, arms_value = 60, legs_value = 60, hand_value = 50, foots_value = 50, other_value = 50)
/// Sniper rifle accuracy (100% hit)
#define GUN_ACCURACY_SNIPER new /datum/gun_accuracy(head_value = 100, chest_value = 100, arms_value = 100, legs_value = 100, hand_value = 100, foots_value = 100, other_value = 100)

GLOBAL_DATUM_INIT(gun_accuracy_default, /datum/gun_accuracy, GUN_ACCURACY_DEFAULT)

/datum/gun_accuracy
	var/head
	var/chest
	var/arms
	var/legs
	var/hands
	var/foots
	var/other  //tail, wings

/datum/gun_accuracy/New(head_value = 100, chest_value = 100, arms_value = 100, legs_value = 100, hand_value = 100, foots_value = 100, other_value = 100)
	. = ..()
	head = head_value
	chest = chest_value
	arms = arms_value
	legs = legs_value
	hands = hand_value
	foots = foots_value
	other = other_value

/datum/gun_accuracy/proc/getList()
	return list("head" = head, "chest" = chest, "arms" = arms, "legs" = legs, "hands" = hands, "foots" = foots, "other" = other)

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

/proc/getAccuracy(head = 100, chest = 100, arms = 100, legs = 100, hands = 100, foots = 100, other = 100)
	. = new /datum/gun_accuracy(head, chest, arms, legs, hands, foots, other)


/obj/projectile/proc/calculate_hit_chance(obj/projectile/projectile, mob/living/target)
	if(forced_accuracy)
		return 100
	var/distance = get_dist(firer, target)
	if(distance < 2) //point-back shot (diagonal dist is 1.414)
		return 100
	var/obj/item/gun/gun = projectile.firer_source_atom
	var/datum/gun_accuracy/gun_accuracy = GLOB.gun_accuracy_default
	if(istype(gun))
		gun_accuracy = gun.accuracy
	var/def_zone_accuracy = gun_accuracy.get_accuracy_for(projectile.def_zone)
	var/distance_mod = accuracy_for_distance(distance) / 100
	return clamp(def_zone_accuracy * distance_mod, 0, 100)


#define FULL_ACCURACY_DISTANCE 3
#define MIN_ACCURACY_DISTANCE 10
#define MIN_ACCURACY_PERCENT 50
#define FULL_ACCURACY_PERCENT 100

/obj/projectile/proc/accuracy_for_distance(distance)
	if(distance < FULL_ACCURACY_DISTANCE)
		return FULL_ACCURACY_PERCENT
	var/distance_progress = 1 - clamp((distance - FULL_ACCURACY_DISTANCE) / MIN_ACCURACY_DISTANCE, 0, 1)
	return clamp(distance_progress * (FULL_ACCURACY_PERCENT - MIN_ACCURACY_PERCENT) + MIN_ACCURACY_PERCENT, 0, 100)
