/mob/living/silicon/decoy
	name = "AI"
	icon = 'icons/mob/ai.dmi'
	icon_state = "ai-core"
	anchored = TRUE // -- TLE
	a_intent = INTENT_HARM // This is apparently the only thing that stops other mobs walking through them as if they were thin air.
	silicon_subsystems = list(
		VERB_META(/mob/living/silicon, subsystem_law_manager),
	)
	var/display_icon_override = "ai"

/mob/living/silicon/decoy/Initialize(mapload)
	. = ..()
	update_icon(UPDATE_OVERLAYS)

/mob/living/silicon/decoy/update_overlays()
	. = ..()
	var/screen_state = display_icon_override
	var/mutable_appearance/screen_overlay = mutable_appearance(icon, screen_state)
	screen_overlay.layer = FLOAT_LAYER + 0.1
	screen_overlay.appearance_flags = RESET_COLOR | KEEP_APART
	. += screen_overlay
	. += emissive_appearance(icon, screen_state, src)

/mob/living/silicon/decoy/attackby(obj/item/I, mob/user, params)
	if(istype(I, /obj/item/aicard))
		to_chat(user, span_warning("You cannot find an intellicard slot on [src]."))
		return ATTACK_CHAIN_PROCEED_NO_AFTERATTACK
	return ..()

/mob/living/silicon/decoy/welder_act()
	return

/mob/living/silicon/decoy/syndicate
	faction = list("syndicate")
	bubble_icon = "syndibot"
	name = "R.O.D.G.E.R"
	desc = "Red Operations, Depot General Emission Regulator"
	display_icon_override = "ai-magma"

/mob/living/silicon/decoy/syndicate/depot
	universal_speak = TRUE
	universal_understand = TRUE
	var/raised_alert = FALSE

/mob/living/silicon/decoy/syndicate/depot/proc/raise_alert()
	raised_alert = TRUE
	var/area/syndicate_depot/core/depotarea = get_area(src) // Cannot use myArea as it wont be defined for this mob type
	if(istype(depotarea))
		depotarea.increase_alert("AI Unit Offline")
	else
		say("Connection failure!")

/mob/living/silicon/decoy/syndicate/depot/death(gibbed)
	if(!raised_alert)
		raise_alert()
	. = ..()

/mob/living/silicon/decoy/syndicate/depot/ex_act(severity, target)
	adjustBruteLoss(250)
