/datum/game_mode
	/// A list of all demon minds spawned via event or wizard artefact.
	var/list/datum/mind/demons = list()

/mob/living/simple_animal/demon
	name = "a generic demon"
	desc = "you shouldnt be reading this, file a github report"
	speak_emote = list("gurgles")
	emote_hear = list("wails","screeches")
	tts_seed = "Mannoroth"
	response_help  = "thinks better of touching"
	response_disarm = "flails at"
	response_harm   = "punches"
	speed = 1
	a_intent = INTENT_HARM
	stop_automated_movement = TRUE
	status_flags = CANPUSH
	attack_sound = 'sound/misc/demon_attack1.ogg'
	death_sound = 'sound/misc/demon_dies.ogg'
	atmos_requirements = list("min_oxy" = 0, "max_oxy" = 0, "min_tox" = 0, "max_tox" = 0, "min_co2" = 0, "max_co2" = 0, "min_n2" = 0, "max_n2" = 0)
	minbodytemp = 0
	maxbodytemp = INFINITY
	faction = list(ROLE_DEMON)
	attacktext = "неистово терзает"
	maxHealth = 200
	health = 200
	environment_smash = ENVIRONMENT_SMASH_STRUCTURES
	obj_damage = 50
	melee_damage_lower = 30
	melee_damage_upper = 30
	nightvision = 8
	lighting_alpha = LIGHTING_PLANE_ALPHA_MOSTLY_INVISIBLE
	del_on_death = TRUE
	dirslash_enabled = TRUE
	var/vialspawned = FALSE
	var/playstyle_string
	var/datum/action/innate/demon/whisper/whisper_action


/mob/living/simple_animal/demon/Initialize(mapload)
	. = ..()
	whisper_action = new()
	whisper_action.Grant(src)
	addtimer(CALLBACK(src, PROC_REF(attempt_objectives)), 5 SECONDS)


/mob/living/simple_animal/demon/Destroy()
	if(mind)
		SSticker.mode.demons -= mind
	if(whisper_action)
		whisper_action = null
	return ..()


/datum/action/innate/demon/whisper
	name = "Demonic Whisper"
	button_icon_state = "cult_comms"
	background_icon_state = "bg_demon"


/datum/action/innate/demon/whisper/proc/choose_targets(mob/user = usr)//yes i am copying from telepathy..hush...
	var/list/validtargets = list()
	for(var/mob/living/target in (view(user.client.view, get_turf(user)) - user))
		if(target && target.mind && target.stat != DEAD)
			validtargets += target

	if(!length(validtargets))
		to_chat(usr, span_warning("There are no valid targets!"))
		return

	var/mob/living/target = tgui_input_list(user, "Choose the target to talk to", "Targeting", validtargets)
	return target


/datum/action/innate/demon/whisper/Activate()
	var/mob/living/choice = choose_targets()
	if(!choice)
		return

	var/msg = stripped_input(usr, "What do you wish to tell [choice]?", null, "")
	if(!(msg))
		return

	add_say_logs(usr, msg, choice, "SLAUGHTER")
	to_chat(usr, span_info("<b>You whisper to [choice]: </b>[msg]"))
	to_chat(choice, "[span_deadsay("<b>Suddenly a strange, demonic voice resonates in your head... </b>")][span_danger("<i> [msg]</i>")]")
	for(var/mob/dead/observer/G in GLOB.player_list)
		G.show_message("<i>Demonic message from <b>[usr]</b> ([ghost_follow_link(usr, ghost=G)]) to <b>[choice]</b> ([ghost_follow_link(choice, ghost=G)]): [msg]</i>")


/obj/item/organ/internal/heart/demon
	name = "demon heart"
	desc = "Still it beats furiously, emanating an aura of utter hate."
	icon = 'icons/obj/surgery.dmi'
	icon_state = "demon_heart"
	origin_tech = "combat=5;biotech=7"


/obj/item/organ/internal/heart/demon/update_icon_state()
	return //always beating visually


/obj/item/organ/internal/heart/demon/prepare_eat()
	return // Just so people don't accidentally waste it


/obj/item/organ/internal/heart/demon/Stop()
	return // Always beating.


/obj/item/organ/internal/heart/demon/attack_self(mob/living/user)
	user.visible_message(span_warning("[user] raises [src] to [user.p_their()] mouth and tears into it with [user.p_their()] teeth!"), \
						 span_danger("An unnatural hunger consumes you. You raise [src] to your mouth and devour it!"))
	playsound(user, 'sound/misc/demon_consume.ogg', 50, TRUE)


/mob/living/simple_animal/demon/proc/attempt_objectives()
	return !isnull(mind)

