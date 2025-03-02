#define GREYS_ADDITIONAL_GENE_STABILITY		20
#define GREYS_WATER_DAMAGE		0.6 // 0.6 burn per unit

/datum/species/grey
	name = SPECIES_GREY
	name_plural = "Greys"
	icobase = 'icons/mob/human_races/r_grey.dmi'
	deform = 'icons/mob/human_races/r_def_grey.dmi'
	language = LANGUAGE_GREY
	eyes = "grey_eyes_s"
	butt_sprite = "grey"

	has_organ = list(
		INTERNAL_ORGAN_HEART = /obj/item/organ/internal/heart/grey,
		INTERNAL_ORGAN_LUNGS = /obj/item/organ/internal/lungs/grey,
		INTERNAL_ORGAN_LIVER = /obj/item/organ/internal/liver/grey,
		INTERNAL_ORGAN_KIDNEYS = /obj/item/organ/internal/kidneys/grey,
		INTERNAL_ORGAN_BRAIN = /obj/item/organ/internal/brain/grey,
		INTERNAL_ORGAN_APPENDIX = /obj/item/organ/internal/appendix,
		INTERNAL_ORGAN_EYES = /obj/item/organ/internal/eyes/grey, // 3 darksight.
		INTERNAL_ORGAN_EARS = /obj/item/organ/internal/ears/grey,
	)

	meat_type = /obj/item/reagent_containers/food/snacks/meat/humanoid/grey

	total_health = 80 // Greys are fragile
	oxy_mod = 1.3
	stamina_mod = 1.2
	clone_mod = 0.7

	toolspeedmod = -0.5 // 50% faster
	surgeryspeedmod = -0.5

	default_genes = list(/datum/dna/gene/basic/grant_spell/remotetalk)

	inherent_traits = list(
		TRAIT_WEAK_PULLING,
		TRAIT_NO_VOCAL_CORDS,
		TRAIT_HAS_LIPS,
		TRAIT_HAS_REGENERATION,
		TRAIT_ADVANCED_CYBERIMPLANTS,
		TRAIT_ACID_PROTECTED,
	)

	blacklisted_disabilities = NONE
	clothing_flags = HAS_UNDERWEAR | HAS_UNDERSHIRT | HAS_SOCKS
	bodyflags =  HAS_BODY_MARKINGS
	has_gender = FALSE
	reagent_tag = PROCESS_ORG
	flesh_color = "#a598ad"
	blood_species = "Grey"
	blood_color = "#A200FF"

	disliked_food = SUGAR | FRIED
	liked_food = VEGETABLES | GRAIN | MEAT

	age_sheet = list(
		SPECIES_AGE_MIN = 3,
		SPECIES_AGE_MAX = 150,
		JOB_MIN_AGE_HIGH_ED = 13,
		JOB_MIN_AGE_COMMAND = 13,
	)


/datum/species/grey/on_species_gain(mob/living/carbon/human/H)
	. = ..()
	H.gene_stability += GREYS_ADDITIONAL_GENE_STABILITY
	RegisterSignal(H, COMSIG_SINK_ACT, PROC_REF(sink_act))


/datum/species/grey/on_species_loss(mob/living/carbon/human/H)
	. = ..()
	H.gene_stability -= GREYS_ADDITIONAL_GENE_STABILITY
	UnregisterSignal(H, COMSIG_SINK_ACT)


/datum/species/grey/handle_dna(mob/living/carbon/human/H, remove = FALSE)
	H.force_gene_block(GLOB.remotetalkblock, !remove, TRUE, TRUE)


/datum/species/grey/water_act(mob/living/carbon/human/H, volume, temperature, source, method = REAGENT_TOUCH)
	. = ..()

	if(method == REAGENT_TOUCH)
		var/water_damage = (GREYS_WATER_DAMAGE * volume * H.get_permeability_protection())

		H.adjustFireLoss(min(water_damage, 80))

		if(H.has_pain())
			H.emote("scream")
			to_chat(H, span_danger("[water_damage > 30 ? "Вы чувствуете ужасающую боль после контакта с водой!" : "Вода жжёт вас!"]"))

		if(volume > 24)
			var/obj/item/organ/external/affecting = H.get_organ(BODY_ZONE_HEAD)
			if(affecting)
				affecting.disfigure()

	else // IV bags and etc
		H.adjustFireLoss(min((GREYS_WATER_DAMAGE * volume * 0.5), 80))

		if(volume < 10)
			return

		if(prob(75)) // Prevent emote and chat spam
			return

		if(H.has_pain())
			H.emote("scream")

		to_chat(H, span_danger("Вы чувствуете острое жжение!"))


/datum/species/grey/after_equip_job(datum/job/J, mob/living/carbon/human/H)
	var/obj/item/organ/internal/cyberimp/mouth/translator/grey_retraslator/retranslator = new
	retranslator.insert(H)

	var/translator_pref = H.client.prefs.speciesprefs

	if(!HAS_TRAIT(H, TRAIT_WINGDINGS))
		return handle_loadout_chip(H, retranslator)

	var/command_roles = FALSE

	if(ismindshielded(H) || J.is_command || J.supervisors == "the captain")
		command_roles = TRUE

	if(!translator_pref && !command_roles) // Not command and didn't want wingdings chip, so..
		return handle_loadout_chip(H, retranslator)

	var/obj/item/translator_chip/wingdings/chip = new
	if(retranslator.install_chip(H, chip, ignore_lid = TRUE))
		to_chat(H, span_notice("В связи с ваш[translator_pref ? "им недугом" : "ей ответственной работой"], у вас уже есть установленный чип Вингдингс."))

	handle_loadout_chip(H, retranslator)


/datum/species/grey/proc/handle_loadout_chip(mob/living/carbon/human/H, obj/item/organ/internal/cyberimp/mouth/translator/grey_retraslator/retranslator)
	var/obj/item/translator_chip/chip = locate() in H.contents // we can take only one chip from loadout
	retranslator.install_chip(H, chip, ignore_lid = TRUE)


/datum/species/grey/handle_reagents(mob/living/carbon/human/H, datum/reagent/R)
	if(R.id == "water")
		H.adjustFireLoss(1)
		return TRUE

	return ..()


/datum/species/grey/get_species_runechat_color(mob/living/carbon/human/H)
	var/obj/item/organ/internal/eyes/E = H.get_int_organ(/obj/item/organ/internal/eyes)
	return E.eye_colour


/datum/species/grey/proc/sink_act(mob/living/carbon/human/source)
	SIGNAL_HANDLER

	var/grey_message = pick("Вы не ожидали, что в раковине окажется вода!", "Вы слишком поздно понимаете, что совершили ошибку!", "Вы чувствуете адскую боль по всему телу!")
	source.adjustFireLoss(30 * source.get_permeability_protection())
	to_chat(source, span_danger("[grey_message]"))
	if(source.has_pain())
		source.emote("scream")

	return COMSIG_SINK_ACT_SUCCESS


#undef GREYS_ADDITIONAL_GENE_STABILITY
#undef GREYS_WATER_DAMAGE
