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
		INTERNAL_ORGAN_EYES = /obj/item/organ/internal/eyes/grey, //5 darksight.
		INTERNAL_ORGAN_EARS = /obj/item/organ/internal/ears,
	)

	meat_type = /obj/item/reagent_containers/food/snacks/meat/humanoid/grey

	total_health = 90
	oxy_mod = 1.2  //greys are fragile
	stamina_mod = 1.2

	toolspeedmod = -0.2 //20% faster
	surgeryspeedmod = -0.2

	default_genes = list(/datum/dna/gene/basic/grant_spell/remotetalk)

	inherent_traits = list(
		TRAIT_HAS_LIPS,
		TRAIT_HAS_REGENERATION,
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


/datum/species/grey/on_species_gain(mob/living/carbon/human/H)
	. = ..()
	H.gene_stability += GENE_INSTABILITY_MODERATE


/datum/species/grey/on_species_loss(mob/living/carbon/human/H)
	. = ..()
	H.gene_stability -= GENE_INSTABILITY_MODERATE


/datum/species/grey/handle_dna(mob/living/carbon/human/H, remove = FALSE)
	H.force_gene_block(GLOB.remotetalkblock, !remove, TRUE, TRUE)


/datum/species/grey/water_act(mob/living/carbon/human/H, volume, temperature, source, method = REAGENT_TOUCH)
	. = ..()

	if(method == REAGENT_TOUCH)
		if(H.wear_mask)
			to_chat(H, "<span class='danger'>Ваша [H.wear_mask] защищает вас от кислоты!</span>")
			return

		if(H.head)
			to_chat(H, "<span class='danger'>Ваша [H.wear_mask] защищает вас от кислоты!</span>")
			return

		if(volume > 25)
			if(prob(75))
				H.take_organ_damage(5, 10)
				H.emote("scream")
				var/obj/item/organ/external/affecting = H.get_organ(BODY_ZONE_HEAD)
				if(affecting)
					affecting.disfigure()
			else
				H.take_organ_damage(5, 10)
		else
			H.take_organ_damage(5, 10)
	else
		to_chat(H, "<span class='warning'>Вода жжет вас[volume < 10 ? ", но она недостаточно сконцентрирована, чтобы вам навредить" : null]!</span>")
		if(volume >= 10)
			H.adjustFireLoss(min(max(4, (volume - 10) * 2), 20))
			H.emote("scream")
			to_chat(H, "<span class='warning'>Вода жжет вас[volume < 10 ? ", но она недостаточно сконцентрирована, чтобы вам навредить" : null]!</span>")

/datum/species/grey/after_equip_job(datum/job/J, mob/living/carbon/human/H)
	var/translator_pref = H.client.prefs.speciesprefs
	if(translator_pref || ((ismindshielded(H) || J.is_command || J.supervisors == "the captain") && HAS_TRAIT(H, TRAIT_WINGDINGS)))
		if(J.title == JOB_TITLE_MIME)
			return
		if(J.title == JOB_TITLE_CLOWN)
			var/obj/item/organ/internal/cyberimp/brain/speech_translator/clown/implant = new
			implant.insert(H)
		else
			var/obj/item/organ/internal/cyberimp/brain/speech_translator/implant = new
			implant.insert(H)
			if(!translator_pref)
				to_chat(H, "<span class='notice'>Имплант переводчика речи был установлен вам, из-за вашей роли на станции.</span>")

/datum/species/grey/handle_reagents(mob/living/carbon/human/H, datum/reagent/R)
	if(R.id == "sacid")
		H.reagents.remove_reagent(R.id, REAGENTS_METABOLISM)
		return FALSE
	if(R.id == "facid")
		H.reagents.remove_reagent(R.id, REAGENTS_METABOLISM)
		return FALSE
	if(R.id == "acetic_acid")
		H.reagents.remove_reagent(R.id, REAGENTS_METABOLISM)
		return FALSE
	if(R.id == "water")
		H.adjustFireLoss(1)
		return TRUE
	return ..()

/datum/species/grey/get_species_runechat_color(mob/living/carbon/human/H)
	var/obj/item/organ/internal/eyes/E = H.get_int_organ(/obj/item/organ/internal/eyes)
	return E.eye_colour
