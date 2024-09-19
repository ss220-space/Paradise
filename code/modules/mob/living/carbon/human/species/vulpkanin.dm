/datum/species/vulpkanin
	name = SPECIES_VULPKANIN
	name_plural = "Vulpkanin"
	icobase = 'icons/mob/human_races/r_vulpkanin.dmi'
	deform = 'icons/mob/human_races/r_vulpkanin.dmi'
	language = LANGUAGE_VULPKANIN
	primitive_form = /datum/species/monkey/vulpkanin
	tail = "vulptail"
	skinned_type = /obj/item/stack/sheet/fur
	unarmed_type = /datum/unarmed_attack/claws

	blurb = "Vulpkanin are a species of sharp-witted canine-pideds residing on the planet Altam just barely within the \
	dual-star Vazzend system. Their politically de-centralized society and independent natures have led them to become a species and \
	culture both feared and respected for their scientific breakthroughs. Discovery, loyalty, and utilitarianism dominates their lifestyles \
	to the degree it can cause conflict with more rigorous and strict authorities. They speak a guttural language known as 'Canilunzt' \
    which has a heavy emphasis on utilizing tail positioning and ear twitches to communicate intent."

	inherent_traits = list(
		TRAIT_HAS_LIPS,
		TRAIT_HAS_REGENERATION,
	)
	clothing_flags = HAS_UNDERWEAR | HAS_UNDERSHIRT | HAS_SOCKS
	bodyflags = HAS_TAIL | TAIL_WAGGING | TAIL_OVERLAPPED | HAS_HEAD_ACCESSORY | HAS_MARKINGS | HAS_SKIN_COLOR
	taste_sensitivity = TASTE_SENSITIVITY_SHARP
	reagent_tag = PROCESS_ORG

	blood_species = "Vulpkanin"
	flesh_color = "#966464"
	base_color = "#CF4D2F"
	butt_sprite = "vulp"

	scream_verb = "скул%(ит,ят)%"

	has_organ = list(
		INTERNAL_ORGAN_HEART = /obj/item/organ/internal/heart/vulpkanin,
		INTERNAL_ORGAN_LUNGS = /obj/item/organ/internal/lungs/vulpkanin,
		INTERNAL_ORGAN_LIVER = /obj/item/organ/internal/liver/vulpkanin,
		INTERNAL_ORGAN_KIDNEYS = /obj/item/organ/internal/kidneys/vulpkanin,
		INTERNAL_ORGAN_BRAIN = /obj/item/organ/internal/brain/vulpkanin,
		INTERNAL_ORGAN_APPENDIX = /obj/item/organ/internal/appendix,
		INTERNAL_ORGAN_EYES = /obj/item/organ/internal/eyes/vulpkanin,
		INTERNAL_ORGAN_EARS = /obj/item/organ/internal/ears,
	)

	meat_type = /obj/item/reagent_containers/food/snacks/meat/humanoid/vulpkanin

	has_limbs = list(
		BODY_ZONE_CHEST = list("path" = /obj/item/organ/external/chest),
		BODY_ZONE_PRECISE_GROIN = list("path" = /obj/item/organ/external/groin),
		BODY_ZONE_HEAD = list("path" = /obj/item/organ/external/head/vulpkanin),
		BODY_ZONE_L_ARM = list("path" = /obj/item/organ/external/arm),
		BODY_ZONE_R_ARM = list("path" = /obj/item/organ/external/arm/right),
		BODY_ZONE_L_LEG = list("path" = /obj/item/organ/external/leg),
		BODY_ZONE_R_LEG = list("path" = /obj/item/organ/external/leg/right),
		BODY_ZONE_PRECISE_L_HAND = list("path" = /obj/item/organ/external/hand),
		BODY_ZONE_PRECISE_R_HAND = list("path" = /obj/item/organ/external/hand/right),
		BODY_ZONE_PRECISE_L_FOOT = list("path" = /obj/item/organ/external/foot),
		BODY_ZONE_PRECISE_R_FOOT = list("path" = /obj/item/organ/external/foot/right),
		BODY_ZONE_TAIL = list("path" = /obj/item/organ/external/tail/vulpkanin),
	)

	allowed_consumed_mobs = list(/mob/living/simple_animal/mouse, /mob/living/simple_animal/lizard, /mob/living/simple_animal/chick, /mob/living/simple_animal/chicken,
								 /mob/living/simple_animal/crab, /mob/living/simple_animal/butterfly, /mob/living/simple_animal/parrot, /mob/living/simple_animal/tribble)

	suicide_messages = list(
		"пытается откусить себе язык!",
		"выдавливает когтями свои глазницы!",
		"сворачивает себе шею!",
		"задерживает дыхание!")

	disliked_food = VEGETABLES | FRUIT | GRAIN
	liked_food = MEAT | RAW | DAIRY | GROSS | EGG

/datum/species/vulpkanin/handle_death(gibbed, mob/living/carbon/human/H)
	H.stop_tail_wagging()

/datum/species/vulpkanin/on_species_gain(mob/living/carbon/human/H)
	. = ..()
	add_verb(H, /mob/living/carbon/human/proc/emote_wag)
	add_verb(H, /mob/living/carbon/human/proc/emote_swag)
	add_verb(H, /mob/living/carbon/human/proc/emote_howl)
	add_verb(H, /mob/living/carbon/human/proc/emote_growl)

/datum/species/vulpkanin/on_species_loss(mob/living/carbon/human/H)
	. = ..()
	remove_verb(H, /mob/living/carbon/human/proc/emote_wag)
	remove_verb(H, /mob/living/carbon/human/proc/emote_swag)
	remove_verb(H, /mob/living/carbon/human/proc/emote_howl)
	remove_verb(H, /mob/living/carbon/human/proc/emote_growl)
