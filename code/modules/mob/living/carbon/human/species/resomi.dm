#define RESOMI_CLOTHING_BODY_SCALE 0.8
#define RESOMI_CLOTHING_HEAD_SCALE 0.85
#define RESOMI_CLOTHING_HEAD_OFFSET_Y -1

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
	inhand_sprite_offset_y = -4
	inhand_sprite_scale = 0.8
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
	clothing_icon_sheets = list(
		DEFAULT_ICON_LEFT_EAR = 'icons/mob/clothing/species/resomi/ears.dmi',
		DEFAULT_ICON_BELT = 'icons/mob/clothing/species/resomi/belt.dmi',
		DEFAULT_ICON_BACK = 'icons/mob/clothing/species/resomi/back.dmi',
		DEFAULT_ICON_OUTER_SUIT = 'icons/mob/clothing/species/resomi/suit.dmi',
		DEFAULT_ICON_JUMPSUIT = 'icons/mob/clothing/species/resomi/uniform.dmi',
		DEFAULT_ICON_GLOVES = 'icons/mob/clothing/species/resomi/hands.dmi',
		DEFAULT_ICON_GLASSES = 'icons/mob/clothing/species/resomi/eyes.dmi',
		DEFAULT_ICON_WEAR_MASK = 'icons/mob/clothing/species/resomi/mask.dmi',
		DEFAULT_ICON_HEAD = 'icons/mob/clothing/species/resomi/head.dmi',
		DEFAULT_ICON_SHOES = 'icons/mob/clothing/species/resomi/feet.dmi',
		DEFAULT_ICON_NECK = 'icons/mob/clothing/species/resomi/neck.dmi',
		DEFAULT_ICON_ACCESSORY = 'icons/mob/clothing/species/resomi/accessories.dmi',
	)
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

/datum/species/resomi/get_clothing_icon_state(obj/item/item, icon_file, requested_state)
	var/static/list/state_overrides = list(
		'icons/mob/clothing/species/resomi/uniform.dmi' = list(
			"clown_s" = "paradise_clown",
		),
		'icons/mob/clothing/species/resomi/head.dmi' = list(
			"beret" = "beret_black",
			"hardhat0_atmos" = "paradise_hardhat_yellow",
			"hardhat1_atmos" = "paradise_hardhat_yellow",
			"hardhat0_red" = "paradise_hardhat_red",
			"hardhat1_red" = "paradise_hardhat_red",
			"hardhat0_yellow" = "paradise_hardhat_yellow",
			"hardhat1_yellow" = "paradise_hardhat_yellow",
			"hardhat0_orange" = "paradise_hardhat_orange",
			"hardhat1_orange" = "paradise_hardhat_orange",
			"hardhat0_purple" = "paradise_hardhat_purple",
			"hardhat1_purple" = "paradise_hardhat_purple",
			"hardhat0_white" = "paradise_hardhat_white",
			"hardhat1_white" = "paradise_hardhat_white",
			"hardhat0_dblue" = "paradise_hardhat_dblue",
			"hardhat1_dblue" = "paradise_hardhat_dblue",
		),
		'icons/mob/clothing/species/resomi/mask.dmi' = list(
			"clown" = "paradise_clown",
			"mime" = "paradise_mime",
		),
	)
	var/static/list/paradise_direct_state_overrides = list(
		'icons/mob/clothing/species/resomi/suit.dmi' = list(
			"hardsuit-sec",
			"space",
			"hardsuit-rd",
			"durathread",
			"hardsuit-ancient",
			"rad",
		),
		'icons/mob/clothing/species/resomi/head.dmi' = list(
			"beret_blue",
			"hardsuit0-blueshield",
			"syndicate-helm-orange",
			"syndicate",
			"space",
			"hardsuit1-hos",
			"bluesoft_flipped",
			"bluesoft",
			"beretdurathread",
			"bio_janitor",
			"hardhat0_yellow",
			"mimesoft_flipped",
			"paramedic-eva-helmet",
			"redwizard",
			"hardhat1_dblue",
			"beret_engineering",
			"capcap",
			"chef",
			"hardhat1_red",
			"hardsuit1-sec",
			"bucket",
			"cargosoft_flipped",
			"helmet",
			"hardsuit1-blueshield",
			"hardhat1_yellow",
			"hardsuit1-syndi",
			"hardsuit1-white",
			"hardhat0_dblue",
			"hardsuit1-rd",
			"hardsuit1-contractor",
			"hardsuit0-ancient",
			"greensoft",
			"beret_med",
		),
		'icons/mob/clothing/species/resomi/feet.dmi' = list(
			"jetboots",
		),
		'icons/mob/clothing/species/resomi/eyes.dmi' = list(
			"glasses",
		),
		'icons/mob/clothing/species/resomi/back.dmi' = list(
			"satchel-gen",
			"satchel-hyd",
			"satchel-chem",
			"satchel-vir",
		),
		'icons/mob/clothing/species/resomi/neck.dmi' = list(
			"cecloak",
		),
	)
	var/list/paradise_direct_states = paradise_direct_state_overrides[icon_file]
	if(paradise_direct_states && requested_state in paradise_direct_states)
		var/paradise_direct_state = "paradise_direct_[requested_state]"
		if(icon_exists(icon_file, paradise_direct_state))
			return paradise_direct_state
	var/list/icon_state_overrides = state_overrides[icon_file]
	var/overridden_state = icon_state_overrides?[requested_state]
	if(overridden_state && icon_exists(icon_file, overridden_state))
		return overridden_state
	if(icon_file == 'icons/mob/clothing/species/resomi/uniform.dmi' && istype(item, /obj/item/clothing/under/color))
		var/static/list/colored_jumpsuit_states = list(
			"#3f3f3f" = "paradise_black",
			"#52aecc" = "paradise_blue",
			"#9ed63a" = "paradise_green",
			"#b3b3b3" = "paradise_grey",
			"#ff8c19" = "paradise_orange",
			"#ff8300" = "paradise_orange",
			"#ffa69b" = "paradise_pink",
			"#eb0c07" = "paradise_red",
			"#ffffff" = "paradise_white",
			"#ffe14d" = "paradise_yellow",
			"#6eb6ff" = "paradise_lightblue",
			"#00ffff" = "paradise_aqua",
			"#800080" = "paradise_purple",
			"#9f70cc" = "paradise_lightpurple",
			"#90ee90" = "paradise_lightgreen",
			"#c59431" = "paradise_lightbrown",
			"#a17229" = "paradise_brown",
			"#9acd32" = "paradise_yellowgreen",
			"#3285ba" = "paradise_darkblue",
			"#ff6b6b" = "paradise_lightred",
			"#8b0000" = "paradise_darkred",
		)
		var/colored_state = colored_jumpsuit_states[item.greyscale_colors]
		if(colored_state && endswith(requested_state, "_d_s") && icon_exists(icon_file, "[colored_state]_d"))
			return "[colored_state]_d"
		if(colored_state && icon_exists(icon_file, colored_state))
			return colored_state
	var/static/list/paradise_fallback_states = list(
		'icons/mob/clothing/species/resomi/uniform.dmi' = list(
			"blackskirt_s",
			"burgundy_suit_s",
			"cargo_s",
			"cargof_s",
			"charcoal_suit_s",
			"dress_green_s",
			"hop_s",
			"kilt_s",
			"qm_s",
			"roboticsf_s",
		),
		'icons/mob/clothing/species/resomi/suit.dmi' = list(
			"hazard",
		),
		'icons/mob/clothing/species/resomi/head.dmi' = list(
			"crown",
			"golhood",
			"hostile_env_glass",
			"rad",
		),
		'icons/mob/clothing/species/resomi/mask.dmi' = list(
			"balaclava_up",
			"fake-moustache",
			"horsehead",
			"sechailer",
		),
	)
	var/list/icon_fallback_states = paradise_fallback_states[icon_file]
	if(icon_fallback_states && requested_state in icon_fallback_states)
		return
	return ..()

/datum/species/resomi/get_clothing_state_alias(requested_state, icon_file)
	var/static/list/state_aliases = list(
		'icons/mob/clothing/species/resomi/uniform.dmi' = list(
			"ert_uniform_s" = "paradise_uniform_ert_uniform",
			"brig_phys_s" = "paradise_uniform_brig_phys",
			"scrubsblack_s" = "paradise_uniform_scrubsblack",
			"intern_s" = "paradise_uniform_intern",
			"trainee_s" = "paradise_uniform_trainee",
			"genetics_s" = "paradise_uniform_genetics",
			"hop_alt_s" = "paradise_uniform_hop_alt",
			"internalaffairs_s" = "paradise_uniform_internalaffairs",
			"mechanic_s" = "paradise_uniform_mechanic",
			"mining_medic_s" = "paradise_uniform_mining_medic",
			"navy_gold_s" = "paradise_uniform_navy_gold",
			"blackops_s" = "paradise_uniform_blackops",
			"pod_pilot_s" = "paradise_uniform_pod_pilot",
			"student_s" = "paradise_uniform_student",
			"prison_s" = "paradise_uniform_prison",
			"chief_s" = "paradise_uniform_chief",
			"chieff_s" = "paradise_uniform_chieff",
			"enginef_s" = "paradise_uniform_enginef",
			"atmosf_s" = "paradise_uniform_atmosf",
			"virologyf_s" = "paradise_uniform_virologyf",
			"chemistryf_s" = "paradise_uniform_chemistryf",
			"medicalf_s" = "paradise_uniform_medicalf",
			"cmof_s" = "paradise_uniform_cmof",
			"director_f_s" = "paradise_uniform_director",
			"sciencef_s" = "paradise_uniform_sciencef",
			"qmf_s" = "paradise_uniform_qmf",
			"security_s" = "paradise_uniform_security",
			"warden_s" = "paradise_uniform_warden",
			"wardenf_s" = "paradise_uniform_wardenf",
			"hos_s" = "paradise_uniform_hos",
			"hosf_s" = "paradise_uniform_hosf",
			"ba_suit_s" = "paradise_uniform_ba_suit",
			"cadet_s" = "paradise_uniform_cadet",
			"paramedic_s" = "paradise_uniform_paramedic",
			"paramedicf_s" = "paradise_uniform_paramedicf",
		),
		'icons/mob/clothing/species/resomi/suit.dmi' = list(
			"blueshield" = "paradise_suit_blueshield",
			"ia_jacket" = "paradise_suit_ia_jacket",
			"suspenders" = "paradise_suit_suspenders",
			"ntrep" = "paradise_suit_ntrep",
			"bombersec" = "paradise_suit_bombersec",
			"dress_capjacket_black" = "paradise_suit_dress_capjacket_black",
			"bladerunner_coat" = "paradise_suit_bladerunner_coat",
			"jacket_syndie" = "paradise_suit_jacket_syndie",
			"chef" = "paradise_suit_chef",
			"bluza" = "paradise_suit_bluza",
			"fr_jacket" = "paradise_suit_fr_jacket",
			"labcoat_tox" = "paradise_suit_labcoat_tox",
			"labcoat_mort" = "paradise_suit_labcoat_mort",
			"mining_labcoat" = "paradise_suit_mining_labcoat",
			"wintercoat_atmos" = "paradise_suit_wintercoat_atmos",
			"wintercoat_captain" = "paradise_suit_wintercoat_captain",
			"wintercoat_cargo" = "paradise_suit_wintercoat_cargo",
			"wintercoat_hydro" = "paradise_suit_wintercoat_hydro",
			"wintercoat_miner" = "paradise_suit_wintercoat_miner",
			"wintercoat_medical" = "coatmedical",
			"wintercoat_paramedic" = "coatparamed",
			"wintercoat_chemistry" = "coatchemistry",
			"wintercoat_virology" = "coatviro",
			"wintercoat_security" = "coatsecurity",
			"wintercoat_hos" = "paradise_suit_wintercoat_hos",
			"wintercoat_cmo" = "paradise_suit_wintercoat_cmo",
			"wintercoat_science" = "coatscience",
			"wintercoat_rd" = "paradise_suit_wintercoat_rd",
			"wintercoat_genetics" = "coatgenetics",
			"wintercoat_robotics" = "coatrobotics",
			"wintercoat_engineering" = "coatengineer",
			"wintercoat_ce" = "paradise_suit_wintercoat_ce",
			"wintercoat_qm" = "paradise_suit_wintercoat_qm",
			"wintercoat_hop" = "paradise_suit_wintercoat_hop",
			"wintercoat_janitor" = "coatjanitor",
			"wintercoat_bartender" = "coatbar",
		),
		'icons/mob/clothing/species/resomi/head.dmi' = list(
			"tophat" = "paradise_head_tophat",
			"cowboyhat_tan" = "paradise_head_cowboyhat_tan",
			"prison_hat" = "paradise_head_prison_hat",
			"helmet_sec" = "paradise_head_helmet_sec",
			"bullethelmet" = "paradise_head_bullethelmet",
			"beret_hos_black" = "paradise_head_beret_hos_black",
			"paramedicsoft" = "paradise_head_paramedicsoft",
		),
		'icons/mob/clothing/species/resomi/hands.dmi' = list(
			"bgloves" = "paradise_hands_bgloves",
			"nt_swat_gl" = "paradise_hands_nt_swat_gl",
			"syndicate_swat_gl" = "paradise_hands_syndicate_swat_gl",
			"orangegloves" = "paradise_hands_orangegloves",
			"black" = "blackgloves",
			"white" = "wgloves",
			"yellow" = "ygloves",
			"latex" = "nitrilegloves",
			"swat_gloves" = "combat",
			"syndicate_swat" = "combat",
		),
		'icons/mob/clothing/species/resomi/feet.dmi' = list(
			"black" = "paradise_feet_black",
			"clown" = "paradise_feet_clown",
			"prison_boots" = "paradise_feet_prison_boots",
		),
		'icons/mob/clothing/species/resomi/eyes.dmi' = list(
			"aviators" = "paradise_eyes_aviators",
			"sunhud" = "paradise_eyes_sunhud",
			"sunhudcap" = "paradise_eyes_sunhudcap",
			"sunhudskill" = "paradise_eyes_sunhudskill",
			"sunthermal" = "paradise_eyes_sunthermal",
			"mesonhealth" = "paradise_eyes_mesonhealth",
		),
		'icons/mob/clothing/species/resomi/mask.dmi' = list(
			"happymask" = "paradise_mask_happymask",
		),
		'icons/mob/clothing/species/resomi/ears.dmi' = list(
			"prisoner_headset" = "headset",
		),
	)
	var/list/icon_aliases = state_aliases[icon_file]
	return icon_aliases?[requested_state]

/datum/species/resomi/transform_clothing_fallback(mutable_appearance/clothing_appearance, obj/item/item)
	var/clothing_scale = RESOMI_CLOTHING_BODY_SCALE
	if(item.slot_flags & (ITEM_SLOT_HEAD|ITEM_SLOT_MASK|ITEM_SLOT_EYES|ITEM_SLOT_EARS|ITEM_SLOT_NECK))
		clothing_scale = RESOMI_CLOTHING_HEAD_SCALE
		clothing_appearance.pixel_z += RESOMI_CLOTHING_HEAD_OFFSET_Y
	clothing_appearance.transform = matrix().Scale(clothing_scale, clothing_scale)

#undef RESOMI_CLOTHING_BODY_SCALE
#undef RESOMI_CLOTHING_HEAD_SCALE
#undef RESOMI_CLOTHING_HEAD_OFFSET_Y
