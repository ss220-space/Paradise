/datum/species/wryn
	name = SPECIES_WRYN
	name_plural = "Wryn"
	icobase = 'icons/mob/human_races/r_wryn.dmi'
	deform = 'icons/mob/human_races/r_wryn.dmi'
	blacklisted = TRUE
	tail = "wryntail"
	punchdamagelow = 0
	punchdamagehigh = 1
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

	inherent_traits = list(
		TRAIT_HAS_LIPS,
		TRAIT_HAS_REGENERATION,
		TRAIT_NO_BREATH,
		TRAIT_NO_SCAN,
	)
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

/datum/species/wryn/on_species_gain(mob/living/carbon/human/H)
	. = ..()
	var/datum/action/innate/wryn_sting/wryn_sting = locate() in H.actions
	if(!wryn_sting)
		wryn_sting = new
		wryn_sting.Grant(H)

/datum/species/wryn/on_species_loss(mob/living/carbon/human/H)
	. = ..()
	var/datum/action/innate/wryn_sting/wryn_sting = locate() in H.actions
	wryn_sting?.Remove(H)

/datum/species/wryn/after_equip_job(datum/job/J, mob/living/carbon/human/H)
	var/comb_deafness = H.client.prefs.speciesprefs
	if(comb_deafness)
		var/obj/item/organ/internal/wryn/hivenode/node = H.get_int_organ(/obj/item/organ/internal/wryn/hivenode)
		node.remove(H)
		qdel(node)
	else
		var/obj/item/organ/external/head/head_organ = H.get_organ(BODY_ZONE_HEAD)
		head_organ.h_style = "Antennae"
		H.update_hair()

/* Wryn Sting Action Begin */

//Define the Sting Action
/datum/action/innate/wryn_sting
	name = "Жало врина"
	desc = "Подготовка жала к ужаливанию."
	button_icon_state = "wryn_sting_off"		//Default Button State
	check_flags = AB_CHECK_LYING|AB_CHECK_CONSCIOUS|AB_CHECK_INCAPACITATED
	var/button_on = FALSE

//What happens when you click the Button?
/datum/action/innate/wryn_sting/Trigger(left_click = TRUE)
	if(!..())
		return
	var/mob/living/carbon/user = owner
	if((HAS_TRAIT(user, TRAIT_RESTRAINED) && user.pulledby) || user.buckled) //Is your Wryn restrained, pulled, or buckled? No stinging!
		to_chat(user, "<span class='notice'>Вам нужна свобода передвижения, чтобы ужалить кого-то!</span>")
		return
	if(user.wear_suit)	//Is your Wryn wearing a Hardsuit or a Laboat that's blocking their Stinger?
		to_chat(user, "<span class='notice'>Для использования жала нужно снять верхнюю одежду.</span>")
		return
	if(user.getStaminaLoss() >= 50)	//Does your Wryn have enough Stamina to sting?
		to_chat(user, "<span class='notice'>Вы слишком устали для использования жала.</span>")
		return
	else
		button_on = TRUE
		UpdateButtonIcon()
		select_target(user)

//Update the Button Icon
/datum/action/innate/wryn_sting/UpdateButtonIcon()
	if(button_on)
		button_icon_state = "wryn_sting_on"
		name = "Wryn Stinger \[READY\]"
		button.name = name
	else
		button_icon_state = "wryn_sting_off"
		name = "Wryn Stinger"
		button.name = name
	..()

//Select a Target from a List
/datum/action/innate/wryn_sting/proc/select_target(var/mob/living/carbon/human/user)
	var/list/names = list()
	for(var/mob/living/carbon/human/M in orange(1))
		names += M
	var/target = input("Select a Target: ", "Sting Target", null) as null|anything in names
	if(!target)		//No one's around!
		to_chat(user, "<span class='warning'>Вокруг некого жалить! Жало втягивается обратно.</span>")
		user.visible_message("<span class='warning'[user] втягивает своё жало.</span>")
		button_on = FALSE
		UpdateButtonIcon()
		return
	else			//Get ready, aim, fire!
		user.visible_message("<span class='warning'> [user] собирается применить жало!</span>")
		sting_target(user, target)
	return

//What does the Wryn Sting do?
/datum/action/innate/wryn_sting/proc/sting_target(mob/living/carbon/human/user, mob/living/carbon/human/target)
	button_on = FALSE					//For when we Update the Button Icon
	if(!(target in orange(1, user)))	//Dang, did they get away?
		to_chat(user, "<span class='warning'>Вы слишком далеко от [target]. Жало втягивается.</span>")
		user.visible_message("<span class='warning'[user] убирает свое жало.</span>")
		UpdateButtonIcon()
		return
	else								//Nah, that chump is still here! Sting 'em! Sting 'em good!
		var/obj/item/organ/external/organ = target.get_organ(pick(BODY_ZONE_L_LEG, BODY_ZONE_R_LEG, BODY_ZONE_PRECISE_L_FOOT, BODY_ZONE_PRECISE_R_FOOT, BODY_ZONE_PRECISE_GROIN))
		to_chat(user, "<span class='danger'> Вы жалите [target] в [organ]!</span>")
		user.visible_message("<span class='danger'>[user] жалит [target] в [organ]! </span>")
		user.adjustStaminaLoss(20)		//You can't sting infinitely, Wryn - take some Stamina loss
		var/dam = rand(3, 7)
		target.apply_damage(dam, BRUTE, organ)
		playsound(user.loc, 'sound/weapons/bladeslice.ogg', 50, 0)
		add_attack_logs(user, target, "Stung by Wryn Stinger - [dam] Brute damage to [organ].")
		if(HAS_TRAIT(target, TRAIT_RESTRAINED))			//Apply tiny BURN damage if target is restrained
			if(prob(50))
				user.apply_damage(2, BURN, target)
				to_chat(target, "<span class='danger'>Вы ощущаете небольшое жжение! Ауч!</span>")
				user.visible_message("<span class='danger'>[user] выглядит ужаленным!</span>")
		UpdateButtonIcon()
		return

/* Wryn Sting Action End */

/datum/species/wryn/handle_death(gibbed, mob/living/carbon/human/H)
	if(!(H.get_int_organ(/obj/item/organ/internal/wryn/hivenode)))
		return

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
				if(do_after(user, 25 SECONDS, target, NONE))
					node.remove(target)
					node.forceMove(get_turf(target))
					to_chat(user, "<span class='notice'>Вы слышите громкий хруст, когда безжалостно отрываете усики [target].</span>")
					to_chat(target, "<span class='danger'>Вы слышите невыносимый хруст, когда [user] вырыва[pluralize_ru(user.gender,"ет","ют")] усики из вашей головы.</span>")
					to_chat(target, "<span class='danger'><B>Стало так тихо...</B></span>")

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
