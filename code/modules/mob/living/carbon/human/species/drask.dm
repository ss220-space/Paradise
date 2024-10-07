#define DRASK_COOLINGSTARTTEMP 280
#define ENVIRONMENT_COOLINGSTOPTEMP 400

/datum/species/drask
	name = SPECIES_DRASK
	name_plural = "Drask"
	icobase = 'icons/mob/human_races/r_drask.dmi'
	deform = 'icons/mob/human_races/r_drask.dmi'
	language = LANGUAGE_DRASK
	eyes = "drask_eyes_s"

	speech_sounds = list('sound/voice/drasktalk.ogg')
	speech_chance = 20
	male_scream_sound = list('sound/voice/drasktalk2.ogg')
	female_scream_sound = list('sound/voice/drasktalk2.ogg')
	male_cough_sounds = list('sound/voice/draskcough.ogg')
	female_cough_sounds = list('sound/voice/draskcough.ogg')
	male_sneeze_sound = list('sound/voice/drasksneeze.ogg')
	female_sneeze_sound = list('sound/voice/drasksneeze.ogg')

	burn_mod = 1.5
	oxy_mod = 2
	exotic_blood = "cryoxadone"
	body_temperature = 273
	toolspeedmod = 0.2 //20% slower
	surgeryspeedmod = 0.2
	bonefragility = 0.8
	punchdamagelow = 5
	punchdamagehigh = 12
	punchstunthreshold = 12
	obj_damage = 10

	blurb = "Hailing from Hoorlm, planet outside what is usually considered a habitable \
	orbit, the Drask evolved to live in extreme cold. Their strange bodies seem \
	to operate better the colder their surroundings are, and can regenerate rapidly \
	when breathing supercooled gas. <br/><br/> On their homeworld, the Drask live long lives \
	in their labyrinthine settlements, carved out beneath Hoorlm's icy surface, where the air \
	is of breathable density."

	suicide_messages = list(
		"трёт себя до возгорания!",
		"давит пальцами на свои большие глаза!",
		"втягивает теплый воздух!",
		"задерживает дыхание!")

	inherent_traits = list(
		TRAIT_EXOTIC_BLOOD,
		TRAIT_HAS_LIPS,
	)
	clothing_flags = HAS_UNDERWEAR | HAS_UNDERSHIRT
	bodyflags = HAS_SKIN_TONE | HAS_BODY_MARKINGS
	has_gender = FALSE

	cold_level_1 = 260 //Default 260 - Lower is better
	cold_level_2 = 200 //Default 200
	cold_level_3 = 120 //Default 120
	coldmod = -1

	heat_level_1 = 310 //Default 370 - Higher is better
	heat_level_2 = 340 //Default 400
	heat_level_3 = 400 //Default 460
	heatmod = 3

	flesh_color = "#a3d4eb"
	reagent_tag = PROCESS_ORG
	base_color = "#a3d4eb"
	blood_species = "Drask"
	blood_color = "#a3d4eb"
	butt_sprite = "drask"

	has_organ = list(
		INTERNAL_ORGAN_HEART = /obj/item/organ/internal/heart/drask,
		INTERNAL_ORGAN_LUNGS = /obj/item/organ/internal/lungs/drask,
		INTERNAL_ORGAN_LIVER = /obj/item/organ/internal/liver/drask,
		INTERNAL_ORGAN_EYES = /obj/item/organ/internal/eyes/drask, //5 darksight.
		INTERNAL_ORGAN_EARS = /obj/item/organ/internal/ears,
		INTERNAL_ORGAN_BRAIN = /obj/item/organ/internal/brain/drask,
	)

	meat_type = /obj/item/reagent_containers/food/snacks/meat/humanoid/drask

	disliked_food = SUGAR | GROSS
	liked_food = DAIRY
	special_diet = MATERIAL_CLASS_SOAP

/datum/species/drask/get_species_runechat_color(mob/living/carbon/human/H)
	var/obj/item/organ/internal/eyes/E = H.get_int_organ(/obj/item/organ/internal/eyes)
	return E.eye_colour

/datum/species/drask/on_species_gain(mob/living/carbon/human/H)
	. = ..()
	add_verb(H, /mob/living/carbon/human/proc/emote_hum)

/datum/species/drask/on_species_loss(mob/living/carbon/human/H)
	. = ..()
	remove_verb(H, /mob/living/carbon/human/proc/emote_hum)

/datum/species/drask/handle_life(mob/living/carbon/human/H)
	..()
	if(H.stat == DEAD)
		return
	var/datum/gas_mixture/environment = H.return_air()
	if(environment && H.bodytemperature > DRASK_COOLINGSTARTTEMP && environment.temperature <= ENVIRONMENT_COOLINGSTOPTEMP)
		H.adjust_bodytemperature(-5)
	if(H.bodytemperature < TCRYO)
		var/update = NONE
		update |= H.heal_overall_damage(2, 4, updating_health = FALSE)
		update |= H.heal_damages(tox = 0.5, oxy = 2, clone = 1, updating_health = FALSE)
		if(update)
			H.updatehealth()
		var/obj/item/organ/external/head/head = H.get_organ(BODY_ZONE_HEAD)
		head?.undisfigure()

/datum/species/drask/handle_reagents(mob/living/carbon/human/H, datum/reagent/R)
	switch(R.id)
		if("iron")
			H.reagents.remove_reagent(R.id, REAGENTS_METABOLISM * H.metabolism_efficiency * H.digestion_ratio)
			return FALSE
		if("salglu_solution")
			if(prob(33))
				H.heal_overall_damage(1, 1, updating_health = FALSE)
			H.reagents.remove_reagent(R.id, REAGENTS_METABOLISM * H.metabolism_efficiency * H.digestion_ratio)
			return FALSE
	return ..()

#undef DRASK_COOLINGSTARTTEMP
#undef ENVIRONMENT_COOLINGSTOPTEMP
