/datum/species/wryn
	name = "Wryn"
	name_plural = "Wryn"
	icobase = 'icons/mob/human_races/r_wryn.dmi'
	deform = 'icons/mob/human_races/r_wryn.dmi'
	blacklisted = TRUE
	language = LANGUAGE_WRYN
	tail = "wryntail"
	speed_mod = 1
	warning_low_pressure = -300
	hazard_low_pressure = 1
	blurb = "The wryn (r-in, singular r-in) are a humanoid race that possess many bee-like features. Originating from Alveare they \
	have adapted extremely well to cold environments though have lost most of their muscles over generations.\
	In order to communicate and work with multi-species crew Wryn were forced to take on names. Wryn have tended towards using only \
	first names, these names are generally simplistic and easy to pronounce. Wryn have rarely had to communicate using their mouths, \
	so in order to integrate with the multi-species crew they have been taught broken sol?."

	cold_level_1 = 200 //Default 260 - Lower is better
	cold_level_2 = 150 //Default 200
	cold_level_3 = 115 //Default 120

	heat_level_1 = 300 //Default 360 - Higher is better
	heat_level_2 = 310 //Default 400
	heat_level_3 = 317 //Default 1000

	body_temperature = 286

	has_organ = list(
		INTERNAL_ORGAN_HEART = /obj/item/organ/internal/heart,
		INTERNAL_ORGAN_BRAIN = /obj/item/organ/internal/brain,
		INTERNAL_ORGAN_EYES = /obj/item/organ/internal/eyes/wryn, //3 darksight.
		INTERNAL_ORGAN_EARS = /obj/item/organ/internal/ears,
		INTERNAL_ORGAN_APPENDIX = /obj/item/organ/internal/appendix,
		INTERNAL_ORGAN_HIVENODE = /obj/item/organ/internal/wryn/hivenode,
		INTERNAL_ORGAN_WAX_GLANDS = /obj/item/organ/internal/wryn/glands,
	)

	meat_type = /obj/item/reagent_containers/food/snacks/meat/humanoid/wryn

	has_limbs = list(
		BODY_ZONE_CHEST = list("path" = /obj/item/organ/external/chest/wryn),
		BODY_ZONE_PRECISE_GROIN =  list("path" = /obj/item/organ/external/groin/wryn),
		BODY_ZONE_HEAD = list("path" = /obj/item/organ/external/head/wryn),
		BODY_ZONE_L_ARM = list("path" = /obj/item/organ/external/arm),
		BODY_ZONE_R_ARM = list("path" = /obj/item/organ/external/arm/right),
		BODY_ZONE_L_LEG = list("path" = /obj/item/organ/external/leg),
		BODY_ZONE_R_LEG = list("path" = /obj/item/organ/external/leg/right),
		BODY_ZONE_PRECISE_L_HAND = list("path" = /obj/item/organ/external/hand),
		BODY_ZONE_PRECISE_R_HAND = list("path" = /obj/item/organ/external/hand/right),
		BODY_ZONE_PRECISE_L_FOOT = list("path" = /obj/item/organ/external/foot),
		BODY_ZONE_PRECISE_R_FOOT = list("path" = /obj/item/organ/external/foot/right),
		BODY_ZONE_TAIL = list("path" = /obj/item/organ/external/tail/wryn),
	)

	species_traits = list(LIPS, IS_WHITELISTED, NO_BREATHE, NO_SCAN, HIVEMIND)
	clothing_flags = HAS_UNDERWEAR | HAS_UNDERSHIRT | HAS_SOCKS
	bodyflags = HAS_SKIN_COLOR

	dies_at_threshold = TRUE

	reagent_tag = PROCESS_ORG
	base_color = "#704300"
	flesh_color = "#704300"
	blood_color = "#FFFF99"
	blood_species = "Wryn"
	//Default styles for created mobs.
	default_hair = "Antennae"

/datum/species/wryn/New()
	if(!available_attacks)
		available_attacks = list(
			"sting" = new /datum/unarmed_attack/wryn_sting,
			"fists" = new /datum/unarmed_attack/punch/wryn,
			)
	. = ..()

/datum/species/wryn/handle_death(gibbed, mob/living/carbon/human/H)
	for(var/mob/living/carbon/C in GLOB.alive_mob_list)
		if(C.get_int_organ(/obj/item/organ/internal/wryn/hivenode))
			to_chat(C, "<span class='danger'><B>Ваши усики дрожат, когда вас одолевает боль...</B></span>")
			to_chat(C, "<span class='danger'>Такое ощущение, что часть вас умерла.</span>") // This is bullshit -- Да, согласен.

/datum/species/wryn/harm(mob/living/carbon/human/user, mob/living/carbon/human/target, datum/martial_art/attacker_style)
	var/obj/item/organ/internal/wryn/hivenode/node = target.get_int_organ(/obj/item/organ/internal/wryn/hivenode)
	if(target.handcuffed && node && user.zone_selected == BODY_ZONE_HEAD)
		switch(alert(user, "Вы хотите вырвать усики этому существу?", "OH SHIT", "Да", "Нет"))
			if("Да")
				user.visible_message("<span class='notice'>[user] начина[pluralize_ru(user.gender,"ет","ют")] яростно отрывать усики [target].</span>")
				to_chat(target, "<span class='danger'><B>[user] схватил[genderize_ru(user.gender,"","а","о","и")] ваши усики и яростно тян[pluralize_ru(user.gender,"ет","ут")] их!<B></span>")
				if(do_mob(user, target, 250))
					target.remove_language(LANGUAGE_WRYN)
					node.remove(target)
					node.forceMove(get_turf(target))
					to_chat(user, "<span class='notice'>Вы слышите громкий хруст, когда безжалостно отрываете усики [target].</span>")
					to_chat(target, "<span class='danger'>Вы слышите невыносимый хруст, когда [user] вырыва[pluralize_ru(user.gender,"ет","ют")] усики из вашей головы.</span>")
					to_chat(target, "<span class='danger'><B>Стало так тихо...</B></span>")
					var/obj/item/organ/external/head/head_organ = target.get_organ(BODY_ZONE_HEAD)
					head_organ.h_style = "Bald"
					target.update_hair()

					add_attack_logs(user, target, "Antennae removed")
				return 0
			if("Нет")
				..()
	else
		..()

/mob/living/carbon/human/proc/adjustWax(amount)
 	var/obj/item/organ/internal/wryn/glands/glands = get_int_organ(/obj/item/organ/internal/wryn/glands)
 	if(!glands) return
 	glands.wax = clamp(glands.wax + amount, 0, 75)
 	return 1

/mob/living/carbon/human/proc/getWax()
 	var/obj/item/organ/internal/wryn/glands/glands = get_int_organ(/obj/item/organ/internal/wryn/glands)
 	if(!glands) return 0
 	return glands.wax

/mob/living/carbon/human/proc/toggle_producing()
	var/obj/item/organ/internal/wryn/glands/glands = get_int_organ(/obj/item/organ/internal/wryn/glands)
	if(glands)
		to_chat(usr, "<span class='notice'>Вы [glands.producing ? "расслабляете" : "напрягаете"] восковые железы</span>")
		glands.producing = !glands.producing

/mob/living/carbon/human/proc/get_producing()
 	var/obj/item/organ/internal/wryn/glands/glands = get_int_organ(/obj/item/organ/internal/wryn/glands)
 	return glands ? glands.producing : FALSE
