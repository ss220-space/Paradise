GLOBAL_LIST_EMPTY(all_robolimbs)
GLOBAL_LIST_EMPTY(chargen_robolimbs)
GLOBAL_LIST_EMPTY(selectable_robolimbs)
GLOBAL_DATUM(basic_robolimb, /datum/robolimb)

///Model = This iconset contains ONLY a monitor and is a subtypeof a Brand
#define MODEL        0
///Brand = This iconset contains all body parts (including a monitor) and there are other monitor Models for this type/Brand
#define BRAND        1
//Childless = This iconset contains all body parts (including a monitor). There are no other monitor Models for this type
#define CHILDLESS    2

/datum/robolimb
	///The name shown when selecting the limb(s) from a menu.
	var/company = "Unbranded"
	///The description of the limb(s) that appears when you examine one.
	var/desc = "A generic unbranded robotic prosthesis."
	///The .dmi file path of the icon base.
	var/icon = 'icons/mob/human_races/robotic.dmi'
	///Whether the robolimb is unavailable when setting up a character. Defaults to FALSE.
	var/unavailable_at_chargen = FALSE
	///Which Species can choose these Robolimbs at CharGen
	var/list/species_allowed = list(
		SPECIES_GREY,
		SPECIES_HUMAN,
		SPECIES_KIDAN,
		SPECIES_MACNINEPERSON,
		SPECIES_DIONA,
		SPECIES_DRASK,
		SPECIES_MOTH,
		SPECIES_NUCLEATION,
		SPECIES_PLASMAMAN,
		SPECIES_SKRELL,
		SPECIES_SLIMEPERSON,
		SPECIES_TAJARAN,
		SPECIES_UNATHI,
		SPECIES_VOX,
		SPECIES_VULPKANIN
		)
	///Whether the limb type is available for selection via attack_self with a robolimb - see robo_parts Defaults to TRUE.
	var/selectable = TRUE
	///Does this iconset contain a head sprite with a screen? If TRUE, head sprite cannot use hair and instead uses ipc_face.
	var/is_monitor
	///Which of the following types is this robolimb: model, brand, or childless?
	var/has_subtypes = CHILDLESS
	///The list of body parts that are contained in the iconset
	var/parts = list(
		BODY_ZONE_CHEST,
		BODY_ZONE_HEAD,
		BODY_ZONE_L_ARM,
		BODY_ZONE_PRECISE_L_HAND,
		BODY_ZONE_R_ARM,
		BODY_ZONE_PRECISE_R_HAND,
		BODY_ZONE_R_LEG,
		BODY_ZONE_PRECISE_R_FOOT,
		BODY_ZONE_L_LEG,
		BODY_ZONE_PRECISE_L_FOOT,
		BODY_ZONE_PRECISE_GROIN,
		BODY_ZONE_TAIL,
		BODY_ZONE_WING,
	)

/* Bishop */
//Main
/datum/robolimb/bishop
	company = "Bishop Cybernetics"
	desc = "This limb has a white polymer casing with blue holo-displays."
	icon = 'icons/mob/human_races/cyberlimbs/bishop/bishop_main.dmi'
	has_subtypes = BRAND

/datum/robolimb/bishop/monitor
	company = "Bishop Knight"
	icon = 'icons/mob/human_races/cyberlimbs/bishop/bishop_alt1.dmi'
	parts = list(BODY_ZONE_HEAD)
	selectable = 0
	has_subtypes = MODEL
	is_monitor = TRUE
	selectable = FALSE

//Rook
/datum/robolimb/rook
	company = "Bishop Rook"
	desc = "This limb has a polished metallic casing."
	icon = 'icons/mob/human_races/cyberlimbs/bishop/bishop_rook.dmi'
	has_subtypes = BRAND

/datum/robolimb/rook/monitor
	company = "Bishop Castle"
	icon = 'icons/mob/human_races/cyberlimbs/bishop/bishop_monitor.dmi'
	parts = list(BODY_ZONE_HEAD)
	has_subtypes = MODEL
	is_monitor = TRUE
	selectable = FALSE

/* Hesphiastos */
//Main

/datum/robolimb/hesphiastos
	company = "Hesphiastos Industries"
	desc = "This limb has a militaristic black-and-green casing with gold stripes."
	icon = 'icons/mob/human_races/cyberlimbs/hesphiastos/hesphiastos_main.dmi'
	has_subtypes = BRAND

/datum/robolimb/hesphiastos/monitor
	company = "Industrial Revolution"
	icon = 'icons/mob/human_races/cyberlimbs/hesphiastos/hesphiastos_monitor.dmi'
	parts = list(BODY_ZONE_HEAD)
	has_subtypes = MODEL
	is_monitor = TRUE
	selectable = FALSE

//Titan
/datum/robolimb/titan
	company = "Hesphiastos Titan"
	desc = "This limb has an olive drab casing, providing a reinforced housing look."
	icon = 'icons/mob/human_races/cyberlimbs/hesphiastos/hesphiastos_titan.dmi'
	has_subtypes = BRAND
	species_allowed = list(SPECIES_MACNINEPERSON)

/datum/robolimb/titan/monitor
	company = "Titan Enforcer"
	icon = 'icons/mob/human_races/cyberlimbs/hesphiastos/hesphiastos_alt1.dmi'
	parts = list(BODY_ZONE_HEAD)
	has_subtypes = MODEL
	is_monitor = TRUE
	selectable = FALSE


/* Morpheus */
//Main
/datum/robolimb/morpheus
	// This is the Default IPC loadout
	company = "Morpheus Cyberkinetics"
	desc = "This limb is simple and functional; no effort has been made to make it look human."
	icon = 'icons/mob/human_races/cyberlimbs/morpheus/morpheus_main.dmi'
	has_subtypes = BRAND
	is_monitor = TRUE

/datum/robolimb/morpheus/monitor
	company = "Cyberkinetics Sport"
	icon = 'icons/mob/human_races/cyberlimbs/morpheus/morpheus_alt1.dmi'
	parts = list(BODY_ZONE_HEAD)
	has_subtypes = MODEL
	is_monitor = TRUE
	selectable = TRUE	// Both the parent (brand) and the child (model) have monitors with screens, therefore this "head" should be selectable.

//Mantis
/datum/robolimb/mantis
	company = "Morpheus Mantis"
	desc = "This limb has a sleek black metal casing with an innovative insectile design."
	icon = 'icons/mob/human_races/cyberlimbs/morpheus/morpheus_mantis.dmi'
	has_subtypes = BRAND

/datum/robolimb/mantis/monitor
	company = "Morpheus Blitz"
	icon = 'icons/mob/human_races/cyberlimbs/morpheus/morpheus_blitz.dmi'
	parts = list(BODY_ZONE_HEAD)
	has_subtypes = MODEL
	is_monitor = TRUE
	selectable = FALSE

/* Nanotrasen */
/datum/robolimb/nanotrasen
	company = "Nanotrasen Modular Mechanics"
	desc = "This limb is made from a cheap polymer."
	icon = 'icons/mob/human_races/cyberlimbs/nanotrasen/nanotrasen_main.dmi'
	has_subtypes = CHILDLESS
	is_monitor = TRUE

/*Robo Vox */
//Main
/datum/robolimb/robovox
	company = "Vox"
	desc = "This limb is cybernetic and looks like like it would only fit a Vox Primalis."
	icon = 'icons/mob/human_races/cyberlimbs/robovox/main.dmi'
	has_subtypes = CHILDLESS
	selectable = FALSE
	// The only robolimbs for Vox at Chargen
	species_allowed = list(SPECIES_VOX)

/* Shellguard */
//Main
/datum/robolimb/shellguard
	company = "Shellguard Munitions"
	desc = "This limb features exposed robust steel, painted to match Shellguard's motifs."
	icon = 'icons/mob/human_races/cyberlimbs/shellguard/shellguard_main.dmi'
	has_subtypes = BRAND

/datum/robolimb/shellguard/monitor
	company = "Shellguard Munitions Standard Series"
	icon = 'icons/mob/human_races/cyberlimbs/shellguard/shellguard_monitor.dmi'
	parts = list(BODY_ZONE_HEAD)
	has_subtypes = MODEL
	is_monitor = TRUE
	selectable = FALSE

//Elite
/datum/robolimb/shellguard/alt1
	company = "Shellguard Munitions Elite Series"
	icon = 'icons/mob/human_races/cyberlimbs/shellguard/shellguard_alt1.dmi'
	parts = list(BODY_ZONE_HEAD)
	has_subtypes = MODEL
	is_monitor = TRUE
	selectable = FALSE

/* Vey-Med */
//Main
/datum/robolimb/veymed
	company = "Vey-Med"
	desc = "This replacement human limb is nearly indistringuishable from an organic one; maybe it was grown in a lab?"
	icon = 'icons/mob/human_races/cyberlimbs/veymed/veymed_main.dmi'
	has_subtypes = CHILDLESS
	selectable = FALSE
	// Only available for Humans and at Chargen
	species_allowed = list(SPECIES_HUMAN)

/datum/robolimb/wardtakahashi
	company = "Ward-Takahashi"
	desc = "This limb features sleek black and white polymers."
	icon = 'icons/mob/human_races/cyberlimbs/wardtakahashi/wardtakahashi_main.dmi'
	has_subtypes = BRAND

/datum/robolimb/wardtakahashi/monitor
	company = "Ward-Takahashi Classic"
	icon = 'icons/mob/human_races/cyberlimbs/wardtakahashi/wardtakahashi_monitor.dmi'
	parts = list(BODY_ZONE_HEAD)
	has_subtypes = MODEL
	is_monitor = TRUE
	selectable = FALSE

//Economy
/datum/robolimb/wardeconomy
	company = "Ward-Takahashi Efficiency"
	desc = "This simple, robotic limb with a retro design seems rather stiff."
	icon = 'icons/mob/human_races/cyberlimbs/wardtakahashi/wardtakahashi_economy.dmi'
	has_subtypes = BRAND

/datum/robolimb/wardeconomy/monitor
	company = "Alternative Efficiency"
	icon = 'icons/mob/human_races/cyberlimbs/wardtakahashi/wardtakahashi_alt1.dmi'
	parts = list(BODY_ZONE_HEAD)
	has_subtypes = MODEL
	is_monitor = TRUE
	selectable = FALSE

/* Xion */
//Main
/datum/robolimb/xion
	company = "Xion Manufacturing Group"
	desc = "This limb has a minimalist black and red casing."
	icon = 'icons/mob/human_races/cyberlimbs/xion/xion_main.dmi'
	has_subtypes = BRAND

/datum/robolimb/xion/monitor
	company = "Xion Original"
	icon = 'icons/mob/human_races/cyberlimbs/xion/xion_monitor.dmi'
	parts = list(BODY_ZONE_HEAD)
	has_subtypes = MODEL
	is_monitor = TRUE
	selectable = FALSE

//Economy
/datum/robolimb/xioneconomy
	company = "Xion Economy"
	desc = "This mechanical limb is skeletal and has a minimalistic black-and-red casing."
	icon = 'icons/mob/human_races/cyberlimbs/xion/xion_econo.dmi'
	has_subtypes = BRAND

/datum/robolimb/xioneconomy/monitor
	company = "Economy Standard"
	icon = 'icons/mob/human_races/cyberlimbs/xion/xion_alt1.dmi'
	parts = list(BODY_ZONE_HEAD)
	has_subtypes = MODEL
	is_monitor = TRUE
	selectable = FALSE

/* Zenghu */
//Zenghu - Main
/datum/robolimb/zenghu
	company = "Zeng-Hu Pharmaceuticals"
	desc = "This limb has a rubbery fleshtone covering with visible seams."
	icon = 'icons/mob/human_races/cyberlimbs/zenghu/zenghu_main.dmi'
	has_subtypes = CHILDLESS

//Zenghu - Spirit
/datum/robolimb/spirit
	company = "Zeng-Hu Spirit"
	desc = "This limb has a sleek black-and-white polymer finish."
	icon = 'icons/mob/human_races/cyberlimbs/zenghu/zenghu_spirit.dmi'
	has_subtypes = CHILDLESS
	selectable = FALSE
	// Only available for IPCs and at Chargen
	species_allowed = list(SPECIES_MACNINEPERSON)

#undef MODEL
#undef BRAND
#undef CHILDLESS
