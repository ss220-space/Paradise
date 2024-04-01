GLOBAL_LIST_EMPTY(all_robolimbs)
GLOBAL_LIST_EMPTY(chargen_robolimbs)
GLOBAL_LIST_EMPTY(selectable_robolimbs)
GLOBAL_DATUM(basic_robolimb, /datum/robolimb)

/datum/robolimb
	var/company = "Unbranded"                            // Shown when selecting the limb.
	var/desc = "A generic unbranded robotic prosthesis." // Seen when examining a limb.
	var/icon = 'icons/mob/human_races/robotic.dmi'       // Icon base to draw from.
	var/unavailable_at_chargen                           // If set, not available at chargen.
	var/selectable = 1									 // If set, is it available for selection on attack_self with a robo limb?
	var/is_monitor										 // If set, limb is a monitor and should be getting monitor styles.
	var/has_subtypes = 2								 // If null, object is a model. If 1, object is a brand (that serves as the default model) with child models. If 2, object is a brand that has no child models and thus also serves as the model..
	/// Defines what parts said brand can replace on a body.
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

/datum/robolimb/bishop
	company = "Bishop Cybernetics"
	desc = "This limb has a white polymer casing with blue holo-displays."
	icon = 'icons/mob/human_races/cyberlimbs/bishop/bishop_main.dmi'
	has_subtypes = 1

/datum/robolimb/bishop/alt1
	company = "Bishop Cybernetics alt."
	icon = 'icons/mob/human_races/cyberlimbs/bishop/bishop_alt1.dmi'
	parts = list(BODY_ZONE_HEAD)
	selectable = 0
	has_subtypes = null

/datum/robolimb/bishop/monitor
	company = "Bishop Cybernetics mtr."
	icon = 'icons/mob/human_races/cyberlimbs/bishop/bishop_monitor.dmi'
	parts = list(BODY_ZONE_HEAD)
	is_monitor = 1
	selectable = 0
	has_subtypes = null

/datum/robolimb/hesphiastos
	company = "Hesphiastos Industries"
	desc = "This limb has a militaristic black and green casing with gold stripes."
	icon = 'icons/mob/human_races/cyberlimbs/hesphiastos/hesphiastos_main.dmi'
	has_subtypes = 1

/datum/robolimb/hesphiastos/alt1
	company = "Hesphiastos Industries alt."
	icon = 'icons/mob/human_races/cyberlimbs/hesphiastos/hesphiastos_alt1.dmi'
	parts = list(BODY_ZONE_HEAD)
	is_monitor = 1
	selectable = 0
	has_subtypes = null

/datum/robolimb/hesphiastos/monitor
	company = "Hesphiastos Industries mtr."
	icon = 'icons/mob/human_races/cyberlimbs/hesphiastos/hesphiastos_monitor.dmi'
	parts = list(BODY_ZONE_HEAD)
	is_monitor = 1
	selectable = 0
	has_subtypes = null

/datum/robolimb/morpheus
	company = "Morpheus Cyberkinetics"
	desc = "This limb is simple and functional; no effort has been made to make it look human."
	icon = 'icons/mob/human_races/cyberlimbs/morpheus/morpheus_main.dmi'
	unavailable_at_chargen = 1
	is_monitor = 1
	has_subtypes = 1

/datum/robolimb/morpheus/alt1
	company = "Morpheus Cyberkinetics alt."
	icon = 'icons/mob/human_races/cyberlimbs/morpheus/morpheus_alt1.dmi'
	parts = list(BODY_ZONE_HEAD)
	unavailable_at_chargen = null
	is_monitor = null
	selectable = 0
	has_subtypes = 2 //Edge case. We want to be able to pick this one, and if we had it left as null for has_subtypes we'd be assuming it'll be chosen as a child model,
					 //and since the parent is unavailable at chargen, we wouldn't be able to see it in the list anyway. Now, we'll be able to select the Morpheus Ckt. Alt. head as a solo-model.

/datum/robolimb/wardtakahashi
	company = "Ward-Takahashi"
	desc = "This limb features sleek black and white polymers."
	icon = 'icons/mob/human_races/cyberlimbs/wardtakahashi/wardtakahashi_main.dmi'
	has_subtypes = 1

/datum/robolimb/wardtakahashi/alt1
	company = "Ward-Takahashi alt."
	icon = 'icons/mob/human_races/cyberlimbs/wardtakahashi/wardtakahashi_alt1.dmi'
	parts = list(BODY_ZONE_HEAD)
	selectable = 0
	has_subtypes = null

/datum/robolimb/wardtakahashi/monitor
	company = "Ward-Takahashi mtr."
	icon = 'icons/mob/human_races/cyberlimbs/wardtakahashi/wardtakahashi_monitor.dmi'
	parts = list(BODY_ZONE_HEAD)
	is_monitor = 1
	selectable = 0
	has_subtypes = null

/datum/robolimb/xion
	company = "Xion Manufacturing Group"
	desc = "This limb has a minimalist black and red casing."
	icon = 'icons/mob/human_races/cyberlimbs/xion/xion_main.dmi'
	has_subtypes = 1

/datum/robolimb/xion/alt1
	company = "Xion Manufacturing Group alt."
	icon = 'icons/mob/human_races/cyberlimbs/xion/xion_alt1.dmi'
	parts = list(BODY_ZONE_HEAD)
	selectable = 0
	has_subtypes = null

/datum/robolimb/xion/monitor
	company = "Xion Manufacturing Group mtr."
	icon = 'icons/mob/human_races/cyberlimbs/xion/xion_monitor.dmi'
	parts = list(BODY_ZONE_HEAD)
	is_monitor = 1
	selectable = 0
	has_subtypes = null

/datum/robolimb/zenghu
	company = "Zeng-Hu Pharmaceuticals"
	desc = "This limb has a rubbery fleshtone covering with visible seams."
	icon = 'icons/mob/human_races/cyberlimbs/zenghu/zenghu_main.dmi'
	has_subtypes = 2

/datum/robolimb/shellguard
	company = "Shellguard Munitions Standard Series"
	desc = "This limb features exposed robust steel and paint to match Shellguards motifs."
	icon = 'icons/mob/human_races/cyberlimbs/shellguard/shellguard_main.dmi'
	has_subtypes = 1

/datum/robolimb/shellguard/alt1
	company = "Shellguard Munitions Elite Series"
	icon = 'icons/mob/human_races/cyberlimbs/shellguard/shellguard_alt1.dmi'
	parts = list(BODY_ZONE_HEAD)
	selectable = 0
	has_subtypes = null

/datum/robolimb/shellguard/monitor
	company = "Shellguard Munitions Monitor Series"
	icon = 'icons/mob/human_races/cyberlimbs/shellguard/shellguard_monitor.dmi'
	parts = list(BODY_ZONE_HEAD)
	is_monitor = 1
	selectable = 0
	has_subtypes = null
