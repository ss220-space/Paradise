/datum/species/skrell
	name = "Skrell"
	name_plural = "Skrell"
	icobase = 'icons/mob/human_races/r_skrell.dmi'
	deform = 'icons/mob/human_races/r_def_skrell.dmi'
	language = "Skrellian"
	primitive_form = /datum/species/monkey/skrell

	blurb = "An amphibious species, Skrell come from the star system known as Qerr'Vallis, which translates to 'Star of \
	the royals' or 'Light of the Crown'.<br/><br/>Skrell are a highly advanced and logical race who live under the rule \
	of the Qerr'Katish, a caste within their society which keeps the empire of the Skrell running smoothly. Skrell are \
	herbivores on the whole and tend to be co-operative with the other species of the galaxy, although they rarely reveal \
	the secrets of their empire to their allies."

	tox_mod = 0.75
	bonefragility = 0.8

	species_traits = list(LIPS, NO_OBESITY)
	clothing_flags = HAS_UNDERWEAR | HAS_UNDERSHIRT | HAS_SOCKS
	bodyflags = HAS_SKIN_COLOR | HAS_BODY_MARKINGS
	taste_sensitivity = TASTE_SENSITIVITY_DULL
	flesh_color = "#8CD7A3"

	heat_level_1 = 350 //Default 370 - Higher is better
	heat_level_2 = 380 //Default 400
	heat_level_3 = 440 //Default 460
	heatmod = 1.5

	blood_species = "Skrell"
	blood_color = "#1D2CBF"
	base_color = "#38b661" //RGB: 56, 182, 97.
	default_hair_colour = "#38b661"
	eyes = "skrell_eyes_s"
	//Default styles for created mobs.
	default_hair = "Skrell Male Tentacles"
	reagent_tag = PROCESS_ORG
	butt_sprite = "skrell"

	disliked_food = MEAT | RAW | EGG
	liked_food = VEGETABLES | FRUIT

	has_organ = list(
		"heart" =    /obj/item/organ/internal/heart/skrell,
		"lungs" =    /obj/item/organ/internal/lungs/skrell,
		"liver" =    /obj/item/organ/internal/liver/skrell,
		"kidneys" =  /obj/item/organ/internal/kidneys/skrell,
		"brain" =    /obj/item/organ/internal/brain/skrell,
		"appendix" = /obj/item/organ/internal/appendix,
		"eyes" =     /obj/item/organ/internal/eyes/skrell, //Default darksight of 5.
		"headpocket" = /obj/item/organ/internal/headpocket
		)

	suicide_messages = list(
		"пытается откусить себе язык!",
		"выдавливает большими пальцами свои глазницы!",
		"сворачивает себе шею!",
		"задыхается словно рыба!",
		"душит себя собственными усиками!")

/datum/species/skrell/on_species_gain(mob/living/carbon/human/H)
	..()
	ADD_TRAIT(H, TRAIT_WATERBREATH, "species")
	H.verbs |= /mob/living/carbon/human/proc/emote_warble

/datum/species/skrell/on_species_loss(mob/living/carbon/human/H)
	..()
	REMOVE_TRAIT(H, TRAIT_WATERBREATH, "species")
	H.verbs -= /mob/living/carbon/human/proc/emote_warble


/datum/species/skrell/water_act(mob/living/carbon/human/M, volume, temperature, source, method)
	. = ..()
	if(method == REAGENT_TOUCH)
		if(M.getFireLoss() < 25 && M.getBruteLoss() < 25 && M.health != 100)
			M.adjustBruteLoss(-4)
			M.adjustFireLoss(-4)
			to_chat(M, "<span class='notice'>Освежающая вода закрывает ваши мелкие раны!</span>")
		M.adjustOxyLoss(-5)

/datum/species/skrell/handle_reagents(mob/living/carbon/human/H, datum/reagent/R)
	if(R.id == "water")
		H.adjustToxLoss(-1)

		if(H.getFireLoss() < 25 && H.getBruteLoss() < 25)
			H.adjustBruteLoss(-1)
			H.adjustFireLoss(-1)
		return TRUE
	return ..()

