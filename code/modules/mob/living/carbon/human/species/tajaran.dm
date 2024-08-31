/datum/species/tajaran
	name = SPECIES_TAJARAN
	name_plural = "Tajaran"
	icobase = 'icons/mob/human_races/r_tajaran.dmi'
	deform = 'icons/mob/human_races/r_def_tajaran.dmi'
	language = LANGUAGE_TAJARAN
	tail = "tajtail"
	skinned_type = /obj/item/stack/sheet/fur
	unarmed_type = /datum/unarmed_attack/claws

	blurb = "The Tajaran race is a species of feline-like bipeds hailing from the planet of Ahdomai in the \
	S'randarr system. They have been brought up into the space age by the Humans and Skrell, and have been \
	influenced heavily by their long history of Slavemaster rule. They have a structured, clan-influenced way \
	of family and politics. They prefer colder environments, and speak a variety of languages, mostly Siik'Maas, \
	using unique inflections their mouths form."

	cold_level_1 = 240
	cold_level_2 = 180
	cold_level_3 = 100

	heat_level_1 = 340
	heat_level_2 = 380
	heat_level_3 = 440

	primitive_form = /datum/species/monkey/tajaran

	inherent_traits = list(
		TRAIT_HAS_LIPS,
		TRAIT_HAS_REGENERATION,
	)
	clothing_flags = HAS_UNDERWEAR | HAS_UNDERSHIRT | HAS_SOCKS
	bodyflags = HAS_TAIL | HAS_HEAD_ACCESSORY | HAS_MARKINGS | HAS_SKIN_COLOR | TAIL_WAGGING
	taste_sensitivity = TASTE_SENSITIVITY_SHARP
	reagent_tag = PROCESS_ORG

	blood_species = "Tajaran"
	flesh_color = "#b5a69b"
	base_color = "#424242"
	butt_sprite = "tajaran"

	has_organ = list(
		INTERNAL_ORGAN_HEART = /obj/item/organ/internal/heart/tajaran,
		INTERNAL_ORGAN_LUNGS = /obj/item/organ/internal/lungs/tajaran,
		INTERNAL_ORGAN_LIVER = /obj/item/organ/internal/liver/tajaran,
		INTERNAL_ORGAN_KIDNEYS = /obj/item/organ/internal/kidneys/tajaran,
		INTERNAL_ORGAN_BRAIN = /obj/item/organ/internal/brain/tajaran,
		INTERNAL_ORGAN_APPENDIX = /obj/item/organ/internal/appendix,
		INTERNAL_ORGAN_EYES = /obj/item/organ/internal/eyes/tajaran,
		INTERNAL_ORGAN_EARS = /obj/item/organ/internal/ears,
	)

	meat_type = /obj/item/reagent_containers/food/snacks/meat/humanoid/tajaran

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
		BODY_ZONE_TAIL = list("path" = /obj/item/organ/external/tail/tajaran),
	)

	allowed_consumed_mobs = list(/mob/living/simple_animal/mouse, /mob/living/simple_animal/chick, /mob/living/simple_animal/butterfly, /mob/living/simple_animal/parrot,
								 /mob/living/simple_animal/tribble)

	suicide_messages = list(
		"пытается откусить себе язык!",
		"вонзает когти себе в глазницы!",
		"сворачивает себе шею!",
		"задерживает дыхание!")

	disliked_food = VEGETABLES | FRUIT | GRAIN | GROSS
	liked_food = MEAT | RAW | DAIRY | EGG

/datum/species/tajaran/handle_death(gibbed, mob/living/carbon/human/H)
	H.stop_tail_wagging()

/datum/species/tajaran/handle_reagents(mob/living/carbon/human/H, datum/reagent/R)
	if(R.id == "moonlin")
		H.reagents.add_reagent("psilocybin",(0.5))
		return TRUE
	return ..()

/datum/species/tajaran/on_species_gain(mob/living/carbon/human/H)
	. = ..()
	add_verb(H, /mob/living/carbon/human/proc/emote_wag)
	add_verb(H, /mob/living/carbon/human/proc/emote_swag)
	add_verb(H, /mob/living/carbon/human/proc/emote_purr)
	add_verb(H, /mob/living/carbon/human/proc/emote_purrl)
	add_verb(H, /mob/living/carbon/human/proc/emote_hiss_tajaran)

/datum/species/tajaran/on_species_loss(mob/living/carbon/human/H)
	. = ..()
	remove_verb(H, /mob/living/carbon/human/proc/emote_wag)
	remove_verb(H, /mob/living/carbon/human/proc/emote_swag)
	remove_verb(H, /mob/living/carbon/human/proc/emote_purr)
	remove_verb(H, /mob/living/carbon/human/proc/emote_purrl)
	remove_verb(H, /mob/living/carbon/human/proc/emote_hiss_tajaran)
