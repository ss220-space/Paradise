/datum/species/skrell
	name = SPECIES_SKRELL
	name_plural = "Skrell"
	icobase = 'icons/mob/human_races/r_skrell.dmi'
	deform = 'icons/mob/human_races/r_def_skrell.dmi'
	language = LANGUAGE_SKRELL
	primitive_form = /datum/species/monkey/skrell

	blurb = "An amphibious species, Skrell come from the star system known as Qerr'Vallis, which translates to 'Star of \
	the royals' or 'Light of the Crown'.<br/><br/>Skrell are a highly advanced and logical race who live under the rule \
	of the Qerr'Katish, a caste within their society which keeps the empire of the Skrell running smoothly. Skrell are \
	herbivores on the whole and tend to be co-operative with the other species of the galaxy, although they rarely reveal \
	the secrets of their empire to their allies."

	tox_mod = 0.75
	bonefragility = 0.8

	inherent_traits = list(
		TRAIT_HAS_LIPS,
		TRAIT_HAS_REGENERATION,
		TRAIT_NO_FAT,
		TRAIT_WATERBREATH,
	)
	blacklisted_disabilities = DISABILITY_FLAG_WINGDINGS|DISABILITY_FLAG_OBESITY
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
		INTERNAL_ORGAN_HEART = /obj/item/organ/internal/heart/skrell,
		INTERNAL_ORGAN_LUNGS = /obj/item/organ/internal/lungs/skrell,
		INTERNAL_ORGAN_LIVER = /obj/item/organ/internal/liver/skrell,
		INTERNAL_ORGAN_KIDNEYS = /obj/item/organ/internal/kidneys/skrell,
		INTERNAL_ORGAN_BRAIN = /obj/item/organ/internal/brain/skrell,
		INTERNAL_ORGAN_APPENDIX = /obj/item/organ/internal/appendix,
		INTERNAL_ORGAN_EYES = /obj/item/organ/internal/eyes/skrell,	//Default darksight of 5.
		INTERNAL_ORGAN_EARS = /obj/item/organ/internal/ears,
		INTERNAL_ORGAN_HEADPOCKET = /obj/item/organ/internal/headpocket,
	)

	meat_type = /obj/item/reagent_containers/food/snacks/meat/humanoid/skrell

	suicide_messages = list(
		"пытается откусить себе язык!",
		"выдавливает большими пальцами свои глазницы!",
		"сворачивает себе шею!",
		"задыхается словно рыба!",
		"душит себя собственными усиками!")

	speech_sounds = list('sound/voice/skrell/talk1.ogg', 'sound/voice/skrell/talk2.ogg', 'sound/voice/skrell/talk3.ogg' )
	speech_chance = 20
	male_scream_sound = list('sound/voice/skrell/scream1.ogg', 'sound/voice/skrell/scream2.ogg', 'sound/voice/skrell/scream3.ogg')
	female_scream_sound = list('sound/voice/skrell/scream1.ogg', 'sound/voice/skrell/scream2.ogg', 'sound/voice/skrell/scream3.ogg')
	female_laugh_sound = list('sound/voice/skrell/laugh1.ogg', 'sound/voice/skrell/laugh2.ogg', 'sound/voice/skrell/laugh3.ogg')
	male_laugh_sound = list('sound/voice/skrell/laugh1.ogg', 'sound/voice/skrell/laugh2.ogg', 'sound/voice/skrell/laugh3.ogg')
	male_moan_sound = list('sound/voice/skrell/moan1.ogg', 'sound/voice/skrell/moan2.ogg', 'sound/voice/skrell/moan3.ogg')
	female_moan_sound = list('sound/voice/skrell/moan1.ogg', 'sound/voice/skrell/moan2.ogg', 'sound/voice/skrell/moan3.ogg')
	male_giggle_sound = list('sound/voice/skrell/giggle1.ogg', 'sound/voice/skrell/giggle2.ogg')
	female_giggle_sound = list('sound/voice/skrell/giggle1.ogg', 'sound/voice/skrell/giggle2.ogg')
	female_snore_sound = list('sound/voice/skrell/snore1.ogg', 'sound/voice/skrell/snore2.ogg', 'sound/voice/skrell/snore3.ogg')
	male_snore_sound = list('sound/voice/skrell/snore1.ogg', 'sound/voice/skrell/snore2.ogg', 'sound/voice/skrell/snore3.ogg')
	whistle_sound = list('sound/voice/skrell/whistling1.ogg', 'sound/voice/skrell/whistling2.ogg')

/datum/species/skrell/on_species_gain(mob/living/carbon/human/H)
	. = ..()
	add_verb(H, list(
		/mob/living/carbon/human/proc/emote_warble,
		/mob/living/carbon/human/proc/emote_sad_trill,
		/mob/living/carbon/human/proc/emote_joyfull_trill,
		/mob/living/carbon/human/proc/emote_croaking,
		/mob/living/carbon/human/proc/emote_discontent,
		/mob/living/carbon/human/proc/emote_relax,
		/mob/living/carbon/human/proc/emote_excitement,
		/mob/living/carbon/human/proc/emote_confusion,
		/mob/living/carbon/human/proc/emote_understand))
	remove_verb(H, list(
		/mob/living/carbon/human/verb/emote_grin,
		/mob/living/carbon/human/verb/emote_wink,
		/mob/living/carbon/human/verb/emote_eyebrow,
		/mob/living/carbon/human/verb/emote_glare,
		/mob/living/carbon/human/verb/emote_chuckle,
		/mob/living/carbon/human/verb/emote_frown,
		/mob/living/carbon/human/verb/emote_snuffle))

/datum/species/skrell/on_species_loss(mob/living/carbon/human/H)
	. = ..()
	remove_verb(H, list(
		/mob/living/carbon/human/proc/emote_warble,
		/mob/living/carbon/human/proc/emote_sad_trill,
		/mob/living/carbon/human/proc/emote_joyfull_trill,
		/mob/living/carbon/human/proc/emote_croaking,
		/mob/living/carbon/human/proc/emote_discontent,
		/mob/living/carbon/human/proc/emote_relax,
		/mob/living/carbon/human/proc/emote_excitement,
		/mob/living/carbon/human/proc/emote_confusion,
		/mob/living/carbon/human/proc/emote_understand))
	add_verb(H, list(
		/mob/living/carbon/human/verb/emote_grin,
		/mob/living/carbon/human/verb/emote_wink,
		/mob/living/carbon/human/verb/emote_eyebrow,
		/mob/living/carbon/human/verb/emote_glare,
		/mob/living/carbon/human/verb/emote_chuckle,
		/mob/living/carbon/human/verb/emote_frown,
		/mob/living/carbon/human/verb/emote_snuffle))


/datum/species/skrell/water_act(mob/living/carbon/human/M, volume, temperature, source, method)
	. = ..()
	if(method == REAGENT_TOUCH)
		var/update = NONE
		if(M.getFireLoss() < 25 && M.getBruteLoss() < 25 && M.health != 100)
			update |= M.heal_overall_damage(4, 4, updating_health = FALSE)
			to_chat(M, "<span class='notice'>Освежающая вода закрывает ваши мелкие раны!</span>")
		update |= M.heal_damage_type(5, OXY, updating_health = FALSE)
		if(update)
			M.updatehealth()


/datum/species/skrell/handle_reagents(mob/living/carbon/human/H, datum/reagent/R)
	if(R.id == "water")
		var/update = NONE
		if(H.getFireLoss() < 25 && H.getBruteLoss() < 25)
			update |= H.heal_overall_damage(1, 1, updating_health = FALSE)
		update |= H.heal_damage_type(1, TOX, updating_health = FALSE)
		return TRUE
	return ..()

