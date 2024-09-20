/datum/species/diona
	name = SPECIES_DIONA
	name_plural = "Dionaea"
	icobase = 'icons/mob/human_races/r_diona.dmi'
	deform = 'icons/mob/human_races/r_def_plant.dmi'
	language = LANGUAGE_DIONA
	speech_sounds = list('sound/voice/dionatalk1.ogg') //Credit https://www.youtube.com/watch?v=ufnvlRjsOTI [0:13 - 0:16]
	speech_chance = 20
	unarmed_type = /datum/unarmed_attack/diona
	remains_type = /obj/effect/decal/cleanable/ash

	burn_mod = 1.25
	heatmod = 1.5
	var/pod = FALSE //did they come from a pod? If so, they're stronger than normal Diona.

	blurb = "Commonly referred to (erroneously) as 'plant people', the Dionaea are a strange space-dwelling collective \
	species hailing from Epsilon Ursae Minoris. Each 'diona' is a cluster of numerous cat-sized organisms called nymphs; \
	there is no effective upper limit to the number that can fuse in gestalt, and reports exist	of the Epsilon Ursae \
	Minoris primary being ringed with a cloud of singing space-station-sized entities.<br/><br/>The Dionaea coexist peacefully with \
	all known species, especially the Skrell. Their communal mind makes them slow to react, and they have difficulty understanding \
	even the simplest concepts of other minds. Their alien physiology allows them survive happily off a diet of nothing but light, \
	water and other radiation."

	inherent_traits = list(
		TRAIT_NO_BLOOD_RESTORE,
		TRAIT_NO_DNA,
		TRAIT_PLANT_ORIGIN,
		TRAIT_NO_GERMS,
		TRAIT_NO_DECAY,
		TRAIT_NO_ROBOPARTS,
		TRAIT_NO_BIOCHIPS,
		TRAIT_NO_CYBERIMPLANTS,
		TRAIT_SPECIES_LIMBS,
	)
	clothing_flags = HAS_SOCKS
	default_hair_colour = "#000000"
	has_gender = FALSE
	taste_sensitivity = TASTE_SENSITIVITY_DULL
	skinned_type = /obj/item/stack/sheet/wood

	blood_species = "Diona"
	blood_color = "#004400"
	flesh_color = "#907E4A"
	butt_sprite = "diona"

	reagent_tag = PROCESS_ORG

	has_organ = list(
		INTERNAL_ORGAN_LIVER = /obj/item/organ/internal/liver/diona,
		INTERNAL_ORGAN_KIDNEYS = /obj/item/organ/internal/kidneys/diona,
		INTERNAL_ORGAN_BRAIN = /obj/item/organ/internal/brain/diona,
		INTERNAL_ORGAN_EYES = /obj/item/organ/internal/eyes/diona, //Default darksight of 2.
		INTERNAL_ORGAN_EARS = /obj/item/organ/internal/ears/diona,
		INTERNAL_ORGAN_LUNGS = /obj/item/organ/internal/lungs/diona,
		INTERNAL_ORGAN_APPENDIX = /obj/item/organ/internal/appendix/diona,
		INTERNAL_ORGAN_HEART = /obj/item/organ/internal/heart/diona,
	)

	meat_type = /obj/item/reagent_containers/food/snacks/meat/humanoid/diona

	has_limbs = list(
		BODY_ZONE_CHEST = list("path" = /obj/item/organ/external/chest/diona),
		BODY_ZONE_PRECISE_GROIN = list("path" = /obj/item/organ/external/groin/diona),
		BODY_ZONE_HEAD = list("path" = /obj/item/organ/external/head/diona),
		BODY_ZONE_L_ARM = list("path" = /obj/item/organ/external/arm/diona),
		BODY_ZONE_R_ARM = list("path" = /obj/item/organ/external/arm/right/diona),
		BODY_ZONE_L_LEG = list("path" = /obj/item/organ/external/leg/diona),
		BODY_ZONE_R_LEG = list("path" = /obj/item/organ/external/leg/right/diona),
		BODY_ZONE_PRECISE_L_HAND = list("path" = /obj/item/organ/external/hand/diona),
		BODY_ZONE_PRECISE_R_HAND = list("path" = /obj/item/organ/external/hand/right/diona),
		BODY_ZONE_PRECISE_L_FOOT = list("path" = /obj/item/organ/external/foot/diona),
		BODY_ZONE_PRECISE_R_FOOT = list("path" = /obj/item/organ/external/foot/right/diona),
	)

	suicide_messages = list(
		"теряет ветви!",
		"вытаскивает из тайника бутыль с гербицидом и делает большой глоток!",
		"разваливается на множество нимф!")

	disliked_food = MEAT | RAW | EGG
	liked_food = VEGETABLES | FRUIT

/datum/species/diona/can_understand(mob/other)
	if(istype(other, /mob/living/simple_animal/diona))
		return 1
	return 0

/datum/species/diona/on_species_gain(mob/living/carbon/human/H)
	. = ..()
	H.gender = NEUTER
	add_verb(H, /mob/living/carbon/human/proc/emote_creak)


/datum/species/diona/on_species_loss(mob/living/carbon/human/H)
	. = ..()
	remove_verb(H, /mob/living/carbon/human/proc/emote_creak)
	H.clear_alert("nolight")


/datum/species/diona/handle_reagents(mob/living/carbon/human/H, datum/reagent/R)

	switch(R.id)

		if("glyphosate", "atrazine")
			H.adjustToxLoss(3) //Deal additional damage
			return TRUE
		if("iron")
			H.reagents.remove_reagent(R.id, R.metabolization_rate * H.metabolism_efficiency * H.digestion_ratio)
			return FALSE
		if("salglu_solution")
			if(prob(33))
				H.adjustBruteLoss(-1)
				H.adjustFireLoss(-1)
			H.reagents.remove_reagent(R.id, R.metabolization_rate * H.metabolism_efficiency * H.digestion_ratio)
			return FALSE

	return ..()

/datum/species/diona/handle_life(mob/living/carbon/human/H)
	var/light_amount = 0 //how much light there is in the place, affects receiving nutrition and healing
	var/is_vamp = isvampire(H)
	if(isturf(H.loc)) //else, there's considered to be no light
		var/turf/T = H.loc
		light_amount = min(1, T.get_lumcount()) - 0.1
		if(light_amount > 0)
			H.clear_alert("nolight")
		else
			H.throw_alert("nolight", /atom/movable/screen/alert/nolight)

		if(!is_vamp)
			H.adjust_nutrition(light_amount * 10)
			if(H.nutrition > NUTRITION_LEVEL_ALMOST_FULL)
				H.set_nutrition(NUTRITION_LEVEL_ALMOST_FULL)

		if(light_amount > 0.2 && !H.suiciding) //if there's enough light, heal
			if(!pod && H.health <= 0)
				return
			var/update = NONE
			update |= H.heal_overall_damage(1, 1, updating_health = FALSE)
			update |= H.heal_damages(tox = 1, oxy = 1, updating_health = FALSE)
			if(update)
				H.updatehealth()
			if(H.blood_volume < BLOOD_VOLUME_NORMAL)
				H.blood_volume += 0.4
		else if(light_amount < 0.2)
			H.blood_volume -= 0.1

	if(!is_vamp && H.nutrition < NUTRITION_LEVEL_STARVING + 50)
		H.adjustBruteLoss(2)
	..()

/datum/species/diona/pod //Same name and everything; we want the same limitations on them; we just want their regeneration to kick in at all times and them to have special factions
	pod = TRUE
	inherent_factions = list("plants", "vines")
