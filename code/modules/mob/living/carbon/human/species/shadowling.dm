/datum/species/shadow/ling
	//Normal shadowpeople but with enhanced effects
	name = SPECIES_SHADOWLING
	unarmed_type = /datum/unarmed_attack/claws/shadowlings

	icobase = 'icons/mob/human_races/r_shadowling.dmi'
	deform = 'icons/mob/human_races/r_shadowling.dmi'
	blacklisted = TRUE

	blood_color = "#555555"
	flesh_color = "#222222"

	inherent_traits = list(
		TRAIT_NO_PAIN,
		TRAIT_NO_BLOOD,
		TRAIT_NO_BREATH,
		TRAIT_RADIMMUNE,
		TRAIT_VIRUSIMMUNE,
		TRAIT_NO_HUNGER,
		TRAIT_NO_SPECIES_EXAMINE,
		TRAIT_NO_GUNS,
		TRAIT_EMBEDIMMUNE,
		TRAIT_NO_SLIP_ALL,
		TRAIT_PIERCEIMMUNE,
	)
	burn_mod = 1.25
	heatmod = 1.5
	no_equip = list(ITEM_SLOT_HEAD, ITEM_SLOT_EYES, ITEM_SLOT_MASK, ITEM_SLOT_CLOTH_OUTER, ITEM_SLOT_GLOVES, ITEM_SLOT_FEET, ITEM_SLOT_CLOTH_INNER, ITEM_SLOT_SUITSTORE)
	nojumpsuit = TRUE
	silent_steps = 1
	grant_vision_toggle = 0

	warning_low_pressure = -INFINITY
	hazard_low_pressure = -INFINITY
	hazard_high_pressure = INFINITY
	warning_high_pressure = INFINITY

	cold_level_1 = -INFINITY
	cold_level_2 = -INFINITY
	cold_level_3 = -INFINITY

	heat_level_1 = INFINITY
	heat_level_2 = INFINITY
	heat_level_3 = INFINITY

	has_organ = list(
		INTERNAL_ORGAN_HEART = /obj/item/organ/internal/heart/shadowling,
		INTERNAL_ORGAN_BRAIN = /obj/item/organ/internal/brain/shadowling,
		INTERNAL_ORGAN_EYES = /obj/item/organ/internal/eyes/shadowling,
		INTERNAL_ORGAN_EARS = /obj/item/organ/internal/ears/shadowling,
	)

	has_limbs = list(
		BODY_ZONE_CHEST =  list("path" = /obj/item/organ/external/chest/unbreakable/sturdy),
		BODY_ZONE_PRECISE_GROIN = list("path" = /obj/item/organ/external/groin/unbreakable/sturdy),
		BODY_ZONE_HEAD = list("path" = /obj/item/organ/external/head/unbreakable/sturdy),
		BODY_ZONE_L_ARM = list("path" = /obj/item/organ/external/arm/unbreakable/sturdy),
		BODY_ZONE_R_ARM = list("path" = /obj/item/organ/external/arm/right/unbreakable/sturdy),
		BODY_ZONE_L_LEG = list("path" = /obj/item/organ/external/leg/unbreakable/sturdy),
		BODY_ZONE_R_LEG = list("path" = /obj/item/organ/external/leg/right/unbreakable/sturdy),
		BODY_ZONE_PRECISE_L_HAND = list("path" = /obj/item/organ/external/hand/unbreakable/sturdy),
		BODY_ZONE_PRECISE_R_HAND = list("path" = /obj/item/organ/external/hand/right/unbreakable/sturdy),
		BODY_ZONE_PRECISE_L_FOOT = list("path" = /obj/item/organ/external/foot/unbreakable/sturdy),
		BODY_ZONE_PRECISE_R_FOOT = list("path" = /obj/item/organ/external/foot/right/unbreakable/sturdy),
	)

	disliked_food = NONE

/datum/species/shadow/ling/proc/handle_light(mob/living/carbon/human/H)
	var/light_amount = 0
	if(isturf(H.loc))
		var/turf/T = H.loc
		light_amount = T.get_lumcount() * 10
		if(light_amount > LIGHT_DAM_THRESHOLD && !H.incorporeal_move) //Can survive in very small light levels. Also doesn't take damage while incorporeal, for shadow walk purposes
			H.throw_alert("lightexposure", /atom/movable/screen/alert/lightexposure)
			if(is_species(H, /datum/species/shadow/ling/lesser))
				H.take_overall_damage(0, LIGHT_DAMAGE_TAKEN/2)
			else
				H.take_overall_damage(0, LIGHT_DAMAGE_TAKEN)
			if(H.stat != DEAD)
				to_chat(H, "<span class='userdanger'>Свет жжёт вас!</span>")//Message spam to say "GET THE FUCK OUT"
				H << 'sound/weapons/sear.ogg'
		else if(light_amount < LIGHT_HEAL_THRESHOLD)
			H.clear_alert("lightexposure")
			var/obj/item/organ/internal/eyes/E = H.get_int_organ(/obj/item/organ/internal/eyes)
			if(istype(E))
				E.internal_receive_damage(-1)
			var/update = NONE
			if(is_species(H, /datum/species/shadow/ling/lesser))
				update |= H.heal_overall_damage(2, 3, updating_health = FALSE)
			else
				update |= H.heal_overall_damage(5, 7, updating_health = FALSE)
			update |= H.heal_damages(tox = 5, clone = 1, brain = 25, updating_health = FALSE)
			if(update)
				H.updatehealth()
			H.AdjustEyeBlurry(-2 SECONDS)
			H.CureNearsighted()
			H.CureBlind()
			H.SetWeakened(0)
			H.SetStunned(0)
			H.SetKnockdown(0)
		else
			if(H.health <= HEALTH_THRESHOLD_CRIT) // to finish shadowlings in rare occations
				H.adjustBruteLoss(1)

/datum/species/shadow/ling/handle_life(mob/living/carbon/human/H)
	if(!H.weakeyes)
		H.weakeyes = 1 //Makes them more vulnerable to flashes and flashbangs
	handle_light(H)

/datum/species/shadow/ling/lesser //Empowered thralls. Obvious, but powerful
	name = SPECIES_LESSER_SHADOWLING
	icobase = 'icons/mob/human_races/r_lshadowling.dmi'
	deform = 'icons/mob/human_races/r_lshadowling.dmi'
	burn_mod = 1.1
	heatmod = 1.1
