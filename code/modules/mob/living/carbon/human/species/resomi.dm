#define RESOMI_CLOTHING_BODY_SCALE 0.8
#define RESOMI_CLOTHING_HEAD_SCALE 0.85
#define RESOMI_CLOTHING_HEAD_OFFSET_Y -1

/datum/species/resomi
	name = SPECIES_RESOMI
	name_plural = "Resomi"
	icobase = 'icons/mob/human_races/r_resomi.dmi'
	deform = 'icons/mob/human_races/r_def_resomi.dmi'
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

/datum/species/resomi/on_species_loss(mob/living/carbon/human/target)
	. = ..()
	target.mob_size = initial(target.mob_size)
	target.holder_type = initial(target.holder_type)
	target.pass_flags &= ~PASSTABLE

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
			"charcoal_suit_s",
			"dress_green_s",
			"hop_s",
			"kilt_s",
			"qm_s",
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
			"ert_uniform_s" = "blueshift",
			"brig_phys_s" = "security_medic_turtleneck",
			"scrubsblack_s" = "paradise_scrubsblack",
			"intern_s" = "medical",
			"trainee_s" = "engine",
			"genetics_s" = "medical",
			"hop_alt_s" = "hop_casual",
			"internalaffairs_s" = "lawyer_black",
			"mechanic_s" = "nri_engineer",
			"mining_medic_s" = "paramedic-dark",
			"navy_gold_s" = "official",
			"blackops_s" = "syndicate_combat",
			"pod_pilot_s" = "peacekeeper",
			"student_s" = "science",
			"prison_s" = "prisoner",
			"chief_s" = "chiefengineer",
			"chieff_s" = "chiefengineer_skirt",
			"enginef_s" = "engine_skirt",
			"atmosf_s" = "atmos_skirt",
			"virologyf_s" = "virologywhite_skirt",
			"chemistryf_s" = "chemistrywhite_skirt",
			"medicalf_s" = "medical_skirt",
			"cmof_s" = "cmo_skirt",
			"director_f_s" = "director_skirt",
			"roboticsf_s" = "robotics_skirt",
			"sciencef_s" = "science_skirt",
			"qmf_s" = "qm_skirt",
			"cargof_s" = "cargo_skirt",
			"security_s" = "rsecurity",
			"warden_s" = "rwarden",
			"wardenf_s" = "rwarden_skirt",
			"hos_s" = "rhos",
			"hosf_s" = "rhos_skirt",
			"ba_suit_s" = "barman",
			"cadet_s" = "policecadetalt",
			"paramedic_s" = "paramedic-dark",
			"paramedicf_s" = "paramedic-dark_skirt",
		),
		'icons/mob/clothing/species/resomi/suit.dmi' = list(
			"blueshield" = "blueshift",
			"ia_jacket" = "tan_jacket_open",
			"suspenders" = "webbing",
			"ntrep" = "ntr",
			"bombersec" = "jacket_white_t",
			"dress_capjacket_black" = "centcom_formal",
			"bladerunner_coat" = "paratrench_black",
			"jacket_syndie" = "syndievest_t",
			"chef" = "apronchef",
			"bluza" = "apronchef",
			"fr_jacket" = "med_dep_jacket",
			"labcoat_tox" = "labcoat_sci",
			"labcoat_mort" = "labcoat",
			"mining_labcoat" = "labcoat",
			"wintercoat_atmos" = "coatatmos",
			"wintercoat_captain" = "coatcaptain",
			"wintercoat_cargo" = "coatcargo",
			"wintercoat_hydro" = "coathydro",
			"wintercoat_miner" = "coatminer",
			"wintercoat_medical" = "coatmedical",
			"wintercoat_paramedic" = "coatparamed",
			"wintercoat_chemistry" = "coatchemistry",
			"wintercoat_virology" = "coatviro",
			"wintercoat_security" = "coatsecurity",
			"wintercoat_hos" = "coathos",
			"wintercoat_cmo" = "coatcmo",
			"wintercoat_science" = "coatscience",
			"wintercoat_rd" = "coatrd",
			"wintercoat_genetics" = "coatgenetics",
			"wintercoat_robotics" = "coatrobotics",
			"wintercoat_engineering" = "coatengineer",
			"wintercoat_ce" = "coatce",
			"wintercoat_qm" = "coatqm",
			"wintercoat_hop" = "coathop",
			"wintercoat_janitor" = "coatjanitor",
			"wintercoat_bartender" = "coatbar",
		),
		'icons/mob/clothing/species/resomi/head.dmi' = list(
			"tophat" = "paradise_tophat",
			"pwig" = "paradise_pwig",
			"cowboyhat_tan" = "cowboyhat",
			"prison_hat" = "orangesoft",
			"helmet_sec" = "helmet",
			"bullethelmet" = "helmetalt",
			"beret_hos_black" = "beret_black",
			"paramedicsoft" = "emtsoft",
		),
		'icons/mob/clothing/species/resomi/hands.dmi' = list(
			"bgloves" = "blackgloves",
			"nt_swat_gl" = "combat",
			"syndicate_swat_gl" = "combat",
			"orangegloves" = "ygloves",
			"black" = "blackgloves",
			"white" = "wgloves",
			"yellow" = "ygloves",
			"latex" = "nitrilegloves",
			"swat_gloves" = "combat",
			"syndicate_swat" = "combat",
		),
		'icons/mob/clothing/species/resomi/feet.dmi' = list(
			"black" = "laceups",
			"clown" = "paradise_clown_shoes",
			"prison_boots" = "orange1",
		),
		'icons/mob/clothing/species/resomi/eyes.dmi' = list(
			"aviators" = "aviator",
			"sunhud" = "sunhudsec",
			"sunhudcap" = "aviator_sec",
			"sunhudskill" = "sunhudsci",
			"sunthermal" = "thermal",
			"mesonhealth" = "nvgmeson",
		),
		'icons/mob/clothing/species/resomi/mask.dmi' = list(
			"happymask" = "paradise_mime",
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
