/datum/species/resomi
	name = SPECIES_RESOMI
	name_plural = "Resomi"
	icobase = 'icons/mob/human_races/r_resomi.dmi'
	deform = 'icons/mob/human_races/r_def_resomi.dmi'
	damage_mask = 'icons/mob/human_races/masks/dam_mask_resomi.dmi'
	language = LANGUAGE_RESOMI
	unarmed_type = /datum/unarmed_attack/claws
	blurb = "Резоми — небольшие пернатые рапторы, приспособленные к жизни в холоде. Они быстро передвигаются, обладают ускоренным метаболизмом и настолько легки, что их можно переносить на руках."
	speed_mod = -0.2
	toolspeedmod = -0.2
	hunger_drain_mod = 2
	cold_level_1 = 180
	cold_level_2 = 130
	cold_level_3 = 70
	heat_level_1 = 320
	heat_level_2 = 370
	heat_level_3 = 600
	body_temperature = 314.15
	taste_sensitivity = TASTE_SENSITIVITY_SHARP
	total_health = 75
	bodyflags = HAS_SKIN_COLOR | HAS_BODY_MARKINGS | HAS_BODY_ACCESSORY
	eyes = "resomi_eyes_s"
	default_hair = "Resomi Ears"
	default_bodyacc = "Spiky tail"
	optional_body_accessory = FALSE
	inherent_traits = list(
		TRAIT_HAS_LIPS,
		TRAIT_HAS_REGENERATION,
		TRAIT_DWARF,
		TRAIT_NO_ROBOPARTS,
		TRAIT_SMALL_MOB,
	)
	blood_species = "Resomi"
	blood_color = "#d514f7"
	flesh_color = "#5f7bb0"
	base_color = "#001144"
	reagent_tag = ORGANIC
	scream_verb = "визж%(ит,ат)%"
	male_scream_sound = list('sound/voice/resomiscream.ogg')
	female_scream_sound = list('sound/voice/resomiscream.ogg')
	male_laugh_sound = list('sound/voice/resomilaugh.ogg')
	female_laugh_sound = list('sound/voice/resomilaugh.ogg')
	male_cough_sounds = list('sound/voice/resomicough.ogg')
	female_cough_sounds = list('sound/voice/resomicough.ogg')
	male_sneeze_sound = list('sound/voice/resomisneeze.ogg')
	female_sneeze_sound = list('sound/voice/resomisneeze.ogg')
	butt_sprite = "resomi"
	disliked_food = VEGETABLES | FRUIT | GRAIN
	liked_food = MEAT | RAW | EGG
	has_organ = list(
		INTERNAL_ORGAN_HEART = /obj/item/organ/internal/heart/resomi,
		INTERNAL_ORGAN_LUNGS = /obj/item/organ/internal/lungs/resomi,
		INTERNAL_ORGAN_LIVER = /obj/item/organ/internal/liver/resomi,
		INTERNAL_ORGAN_KIDNEYS = /obj/item/organ/internal/kidneys/resomi,
		INTERNAL_ORGAN_BRAIN = /obj/item/organ/internal/brain/resomi,
		INTERNAL_ORGAN_APPENDIX = /obj/item/organ/internal/appendix/resomi,
		INTERNAL_ORGAN_EYES = /obj/item/organ/internal/eyes/resomi,
		INTERNAL_ORGAN_EARS = /obj/item/organ/internal/ears/resomi,
	)
	has_limbs = list(
		BODY_ZONE_CHEST = list("path" = /obj/item/organ/external/chest),
		BODY_ZONE_PRECISE_GROIN = list("path" = /obj/item/organ/external/groin),
		BODY_ZONE_HEAD = list("path" = /obj/item/organ/external/head),
		BODY_ZONE_L_ARM = list("path" = /obj/item/organ/external/arm),
		BODY_ZONE_R_ARM = list("path" = /obj/item/organ/external/arm/right),
		BODY_ZONE_L_LEG = list("path" = /obj/item/organ/external/leg),
		BODY_ZONE_R_LEG = list("path" = /obj/item/organ/external/leg/right),
		BODY_ZONE_PRECISE_L_HAND = list("path" = /obj/item/organ/external/hand),
		BODY_ZONE_PRECISE_R_HAND = list("path" = /obj/item/organ/external/hand/right),
		BODY_ZONE_PRECISE_L_FOOT = list("path" = /obj/item/organ/external/foot),
		BODY_ZONE_PRECISE_R_FOOT = list("path" = /obj/item/organ/external/foot/right),
		BODY_ZONE_TAIL = list("path" = /obj/item/organ/external/tail),
	)

/datum/species/resomi/on_species_gain(mob/living/carbon/human/target)
	. = ..()
	target.mob_size = MOB_SIZE_SMALL
	target.holder_type = /obj/item/holder/humanoid
	target.pass_flags |= PASSTABLE
	add_verb(target, list(
		/mob/living/carbon/human/proc/emote_resomi_click_beak,
		/mob/living/carbon/human/proc/emote_resomi_fluff_feathers,
		/mob/living/carbon/human/proc/emote_resomi_shake_feathers,
		/mob/living/carbon/human/proc/emote_resomi_trill,
		/mob/living/carbon/human/proc/emote_resomi_warbles,
		/mob/living/carbon/human/proc/emote_resomi_wurble,
	))

/datum/species/resomi/on_species_loss(mob/living/carbon/human/target)
	. = ..()
	target.mob_size = initial(target.mob_size)
	target.holder_type = initial(target.holder_type)
	target.pass_flags &= ~PASSTABLE
	remove_verb(target, list(
		/mob/living/carbon/human/proc/emote_resomi_click_beak,
		/mob/living/carbon/human/proc/emote_resomi_fluff_feathers,
		/mob/living/carbon/human/proc/emote_resomi_shake_feathers,
		/mob/living/carbon/human/proc/emote_resomi_trill,
		/mob/living/carbon/human/proc/emote_resomi_warbles,
		/mob/living/carbon/human/proc/emote_resomi_wurble,
	))

/datum/species/resomi/gain_muscles(mob/living/target, default, max_level, can_become_stronger)
	return ..(target, STRENGTH_LEVEL_WEAK, STRENGTH_LEVEL_STRONG, can_become_stronger)
