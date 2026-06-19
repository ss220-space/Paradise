/// Natural blood regeneration size (units per 2 sec)
#define BLOOD_REGENERATION 0.1

// Blood level damage constants
/// Damage for blood volume from BLOOD_VOLUME_PALE to BLOOD_VOLUME_SAFE
#define BLOOD_PALE_DAMAGE 1
/// Damage for blood volume from BLOOD_VOLUME_OKAY to BLOOD_VOLUME_PALE
#define BLOOD_OKAY_DAMAGE 2
/// Damage for blood volume from BLOOD_VOLUME_BAD to BLOOD_VOLUME_OKAY
#define BLOOD_BAD_DAMAGE 4
/// Damage for blood volume from BLOOD_VOLUME_SURVIVE to BLOOD_VOLUME_BAD
#define BLOOD_SURVIVE_DAMAGE 8

#define BLOODLOSS_SPEED_BY_VOLUME_MAX 1
#define BLOODLOSS_SPEED_BY_VOLUME_MIN 0.5

#define BLOODLOSS_SPEED_BY_TEMP_MAX 1
#define BLOODLOSS_SPEED_BY_TEMP_MIN 0.5

// Bledding calculation constants
/// Bleeding per embedded item (units per 2 sec)
#define EMBEDDED_ITEM_BLEEDING 0.2
/// Open bodypart bleeding (units per 2 sec)
#define OPEN_BODYPART_BLEEDING 0.2
/// Internal bleeding size (units per 2 sec)
#define BODYPART_INTERNAL_BLEEDING 0.2
/// Open fracture bleeding amount (units per 2 sec)
#define BODYPART_OPEN_FRACTURE_BLEEDING 0.2
/// Decrease bleeding size if no wounds (units per 2 sec)
#define BLEEDING_DECREASE 0.025
/// Multiplyer for bleeding calculate from bodypart value
#define BLEEDING_MODIFIER 0.3
/// Oxy damage if use tourniquet on head
#define MAX_SUPPRESS_BLEEDING_BY_HAND 15

// MARK: Sybsystem
SUBSYSTEM_DEF(blood)
	name = "Blood"
	priority = FIRE_PRIORITY_MOBS
	ss_flags = SS_KEEP_TIMING | SS_NO_INIT
	runlevels = RUNLEVEL_GAME | RUNLEVEL_POSTGAME
	wait = 2 SECONDS
	/// List of current processing humans
	var/list/currentrun = list()

/datum/controller/subsystem/blood/get_metrics()
	. = ..()
	var/list/custom_data = list()
	custom_data["processing"] = length(GLOB.human_list)
	.["custom"] = custom_data

/datum/controller/subsystem/blood/get_stat_details()
	return "P:[length(GLOB.human_list)]"

/datum/controller/subsystem/blood/fire(resumed = FALSE)
	if(!resumed)
		src.currentrun = GLOB.human_list.Copy()

	var/list/currentrun = src.currentrun
	while(length(currentrun))
		var/mob/living/carbon/human/target = currentrun[length(currentrun)]
		currentrun.len--
		process_human(target)
		if(MC_TICK_CHECK)
			return

/datum/controller/subsystem/blood/proc/process_human(mob/living/carbon/human/target)
	if(HAS_TRAIT(target, TRAIT_NO_BLOOD))
		return // not process humans without blood

	restore_blood_volume(target)

	if(HAS_TRAIT(target, TRAIT_GODMODE))
		return // admin abuse

	apply_current_blood_level_effect(target)
	process_bleeding(target)

/datum/controller/subsystem/blood/proc/restore_blood_volume(mob/living/carbon/human/target)
	if(target.stat == DEAD)
		return // death human can not restore blood
	if(HAS_TRAIT(target, TRAIT_NO_BLOOD_RESTORE))
		return // specific trait for disable restore blood
	if(target.blood_volume >= BLOOD_VOLUME_NORMAL)
		return // already max blood in body
	var/regen_mod = calculate_reagents_regen_mod(target)
	target.AdjustBlood(BLOOD_REGENERATION * regen_mod)

/datum/controller/subsystem/blood/proc/calculate_reagents_regen_mod(mob/living/carbon/human/target)
	// calculate blood regeneration speed-up from reagents
	var/mod = 1
	var/iron_amount = target.reagents.get_reagent_amount(/datum/reagent/iron)
	if(iron_amount > 0)
		mod += round(clamp((iron_amount / 10), 0, 1) * 8, 0.05) // iron speeds up blood regeneration up to x9
	return mod

/datum/controller/subsystem/blood/proc/apply_current_blood_level_effect(mob/living/carbon/human/target)
	if(target.stat == DEAD)
		return // dead humans can not have low blood effect

	switch(target.blood_volume)
		if(BLOOD_VOLUME_PALE to BLOOD_VOLUME_SAFE)
			target.adjust_blood_loss_damage(BLOOD_PALE_DAMAGE)

		if(BLOOD_VOLUME_OKAY to BLOOD_VOLUME_PALE)
			target.adjust_blood_loss_damage(BLOOD_OKAY_DAMAGE)
			if(prob(5))
				target.Confused(2 SECONDS)
				var/symptom = pick("слабость",
					"лёгкое головокружение",
					"небольшую тошноту")
				to_chat(target, span_warning("Вы чувствуете [symptom]."))

		if(BLOOD_VOLUME_BAD to BLOOD_VOLUME_OKAY)
			target.adjust_blood_loss_damage(BLOOD_BAD_DAMAGE)
			if(prob(5))
				target.EyeBlurry(12 SECONDS)
				target.Confused(12 SECONDS)
				var/symptom = pick("сильную слабость",
					"сильное головокружение",
					"нарастающую тошноту",
					"спутанность сознания")
				to_chat(target, span_warning("Вы чувствуете [symptom]."))

		if(BLOOD_VOLUME_SURVIVE to BLOOD_VOLUME_BAD)
			target.adjust_blood_loss_damage(BLOOD_SURVIVE_DAMAGE)
			if(prob(15))
				target.Confused(10 SECONDS)
				target.Slowed(15 SECONDS)
				target.Paralyse(rand(2 SECONDS, 6 SECONDS))
				var/symptom = pick("крайнюю слабость",
					"очень сильное головокружение",
					"невыносимую тошноту",
					"полную дезориентацию")
				to_chat(target, span_warning("Вы чувствуете [symptom]."))

		if(1 to BLOOD_VOLUME_SURVIVE)
			if(!target.undergoing_cardiac_arrest())
				target.set_heartattack(TRUE)
			if(!target.incapacitated())
				target.Stun(30 SECONDS)

		if(-INFINITY to 1)
			target.death()

/datum/controller/subsystem/blood/proc/process_bleeding(mob/living/carbon/human/target, seconds)
	if(target.stat == DEAD)
		return // dead bodies do not pump blood, so they neither bleed nor cough it up.

	if(target.bodytemperature < TCRYO || HAS_TRAIT(target, TRAIT_NO_CLONE))
		return // cryosleep or husked people do not pump the blood.

	var/current_bleed = 0
	var/internal_bleeding_rate = 0
	var/has_arterial_bleed = FALSE
	// calculate total bleeding from bodyparts
	var/list/bleeding_bodyparts_cache = target.bleeding_bodyparts
	for(var/obj/item/organ/external/bodypart as anything in bleeding_bodyparts_cache)
		if(bodypart.is_robotic())
			target.bleeding_bodyparts -= bodypart
			continue

		if(bodypart.tourniquet) //all bloodloss suppressed
			continue

		if(bodypart.has_internal_bleeding())
			internal_bleeding_rate += BODYPART_INTERNAL_BLEEDING

		if(bodypart.has_fracture() && bodypart.fracture == FRACTURE_TYPE_OPEN && !bodypart.is_splinted())
			current_bleed += BODYPART_OPEN_FRACTURE_BLEEDING

		if(bodypart.has_arterial_bleeding() && target.left_hand_bleed_suppress_lib != bodypart && target.right_hand_bleed_suppress_lib != bodypart)
			has_arterial_bleed = TRUE

		if(bodypart.bleeding_amount > 0)
			bodypart.bleeding_amount = max(0, bodypart.bleeding_amount - BLEEDING_DECREASE)
			if(bodypart.bleedsuppress > bodypart.bleeding_amount)
				bodypart.bleedsuppress = bodypart.bleeding_amount

		var/bodypart_bleeding = max(bodypart.bleeding_amount - bodypart.bleedsuppress, 0)
		bodypart_bleeding = bodypart_bleeding * BLEEDING_MODIFIER * bodypart.bleeding_mod

		// suppress bleeding by hands
		if(target.left_hand_bleed_suppress_lib == bodypart)
			bodypart_bleeding = max(0, bodypart_bleeding - MAX_SUPPRESS_BLEEDING_BY_HAND)

		if(target.right_hand_bleed_suppress_lib == bodypart)
			bodypart_bleeding = max(0, bodypart_bleeding - MAX_SUPPRESS_BLEEDING_BY_HAND)

		current_bleed += bodypart_bleeding
		var/embedded_length = length(bodypart.embedded_objects)

		if(embedded_length && bodypart.bleedsuppress > 0)
			current_bleed += EMBEDDED_ITEM_BLEEDING * embedded_length

		if(bodypart.open)
			current_bleed += OPEN_BODYPART_BLEEDING

		if(bodypart.bleeding_amount <= 0 && !bodypart.has_internal_bleeding() && !embedded_length && !bodypart.open)
			target.bleeding_bodyparts -= bodypart

	// calculate bleed rate with regenretion and current bleed
	var/prev_bleed_rate = target.bleed_rate
	target.bleed_rate = current_bleed
	//manage alert
	if(prev_bleed_rate <= 0 && target.bleed_rate > 0)
		target.throw_alert(ALERT_BLEEDING, /atom/movable/screen/alert/bleeding)

	if(prev_bleed_rate > 0 && target.bleed_rate <= 0)
		target.clear_alert(ALERT_BLEEDING)

	var/reagents_bleed_mod = calculate_reagents_bleed_mod(target)
	var/speed_by_volume = get_bloodloss_speed_mod_by_volume(target)
	var/speed_by_bodytemperature = get_bloodloss_speed_mod_by_temperature(target)
	var/total_bleed_mod = reagents_bleed_mod * speed_by_volume * speed_by_bodytemperature

	// apply internal bleeding
	if(internal_bleeding_rate)
		target.bleed_internal(internal_bleeding_rate * total_bleed_mod)

	// apply bleeding
	if(current_bleed)
		target.bleed(current_bleed * total_bleed_mod)

	// make bloodsplatter for arterial bleeding
	if(has_arterial_bleed)
		create_arterial_bleeding_splatter(target)

/datum/controller/subsystem/blood/proc/calculate_reagents_bleed_mod(mob/living/carbon/human/target)
	// calculate addition bleeding from reagents
	var/mod = 1
	var/heparin_amount = target.reagents.get_reagent_amount(/datum/reagent/heparin)
	if(heparin_amount > 0)
		mod += round(clamp((heparin_amount / 20), 0, 1) * 0.75, 0.05) //heparin worsens existing bleeding

	var/traneksam_amount = target.reagents.get_reagent_amount(/datum/reagent/medicine/traneksam_acid)
	if(traneksam_amount > 0)
		mod -= round(clamp((traneksam_amount / 10), 0, 1) * 0.75, 0.05) //traneksam acid suppress existing bleeding

	return mod

/datum/controller/subsystem/blood/proc/get_bloodloss_speed_mod_by_volume(mob/living/carbon/human/target)
	var/blood_volume_percent = clamp(target.blood_volume / BLOOD_VOLUME_NORMAL, 0, 1)
	return BLOODLOSS_SPEED_BY_VOLUME_MIN + (BLOODLOSS_SPEED_BY_VOLUME_MAX - BLOODLOSS_SPEED_BY_VOLUME_MIN) * blood_volume_percent

/datum/controller/subsystem/blood/proc/get_bloodloss_speed_mod_by_temperature(mob/living/carbon/human/target)
	if(target.bodytemperature >= BODYTEMP_NORMAL * 0.75)
		return BLOODLOSS_SPEED_BY_TEMP_MAX

	if(target.bodytemperature <= T0C)
		return BLOODLOSS_SPEED_BY_TEMP_MIN

	var/temperature_percent = clamp((target.bodytemperature - T0C) / (BODYTEMP_NORMAL * 0.75 - T0C), 0, 1)
	return BLOODLOSS_SPEED_BY_TEMP_MIN + (BLOODLOSS_SPEED_BY_TEMP_MAX - BLOODLOSS_SPEED_BY_TEMP_MIN) * temperature_percent

/datum/controller/subsystem/blood/proc/create_arterial_bleeding_splatter(mob/living/carbon/human/target)
	var/splatter_color = target.get_blood_color()
	if(!splatter_color)
		return
	new /obj/effect/temp_visual/dir_setting/bloodsplatter(get_turf(target), rand(0, 360), splatter_color)

#undef BLOOD_REGENERATION
#undef BLOOD_PALE_DAMAGE
#undef BLOOD_OKAY_DAMAGE
#undef BLOOD_BAD_DAMAGE
#undef BLOOD_SURVIVE_DAMAGE
#undef BLOODLOSS_SPEED_BY_VOLUME_MAX
#undef BLOODLOSS_SPEED_BY_VOLUME_MIN
#undef BLOODLOSS_SPEED_BY_TEMP_MAX
#undef BLOODLOSS_SPEED_BY_TEMP_MIN
#undef EMBEDDED_ITEM_BLEEDING
#undef OPEN_BODYPART_BLEEDING
#undef BLEEDING_DECREASE
#undef BLEEDING_MODIFIER
#undef BODYPART_INTERNAL_BLEEDING
#undef BODYPART_OPEN_FRACTURE_BLEEDING
#undef MAX_SUPPRESS_BLEEDING_BY_HAND
