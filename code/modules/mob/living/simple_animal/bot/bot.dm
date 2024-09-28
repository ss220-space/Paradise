//Defines for bots are now found in code\__DEFINES\bots.dm

// AI (i.e. game AI, not the AI player) controlled bots
/mob/living/simple_animal/bot
	icon = 'icons/obj/aibots.dmi'
	layer = MOB_LAYER - 0.1
	light_range = 3
	stop_automated_movement = TRUE
	wander = FALSE
	healable = FALSE
	damage_coeff = list(BRUTE = 1, BURN = 1, TOX = 0, CLONE = 0, STAMINA = 0, OXY = 0)
	atmos_requirements = list("min_oxy" = 0, "max_oxy" = 0, "min_tox" = 0, "max_tox" = 0, "min_co2" = 0, "max_co2" = 0, "min_n2" = 0, "max_n2" = 0)
	minbodytemp = 0
	has_unlimited_silicon_privilege = TRUE
	sentience_type = SENTIENCE_ARTIFICIAL
	status_flags = NONE //no default canpush
	pass_flags = PASSFLAPS
	AI_delay_max = 0 SECONDS

	speak_emote = list("states")
	tts_seed = null
	friendly = "boops"
	bubble_icon = "machine"
	faction = list("neutral", "silicon")

	light_system = MOVABLE_LIGHT

	var/obj/machinery/bot_core/bot_core = null
	var/bot_core_type = /obj/machinery/bot_core
	var/list/users = list() //for dialog updates
	var/window_id = "bot_control"
	var/window_name = "Protobot 1.0" //Popup title
	/// 0 for default size
	var/window_width = 0
	var/window_height = 0
	/// Inserted pai card.
	var/obj/item/paicard/paicard
	/// Are we even allowed to insert a pai card.
	var/allow_pai = TRUE
	var/bot_name

	var/disabling_timer_id = null
	var/list/player_access = list()
	var/emagged = 0
	/// The ID card that the bot "holds".
	var/obj/item/card/id/access_card
	/// All access ID holder
	var/static/obj/item/card/id/all_access
	var/list/prev_access = list()
	var/on = TRUE
	/// Maint panel
	var/open = FALSE
	var/locked = TRUE
	/// Used to differentiate between being hacked by silicons and emagged by humans.
	var/hacked = FALSE
	/// Custom text returned to a silicon upon hacking a bot.
	var/text_hack = ""
	/// Being hijacked by a pulse demon?
	var/hijacked = FALSE
	/// Text shown when resetting a bots hacked status to normal.
	var/text_dehack = ""
	/// Shown when a silicon tries to reset a bot emagged with the emag item, which cannot be reset.
	var/text_dehack_fail = ""
	/// What the bot will display to the HUD user.
	var/declare_message = ""
	/// Used by some bots for tracking failures to reach their target.
	var/frustration = 0
	/// The speed at which the bot moves, or the number of times it moves per process() tick.
	var/base_speed = 2
	/// The end point of a bot's path, or the target location.
	var/turf/ai_waypoint
	/// List of turfs through which a bot 'steps' to reach the waypoint.
	var/list/path = list()
	var/pathset = FALSE
	/// List of unreachable targets for an ignore-list enabled bot to ignore.
	var/list/ignore_list = list()
	/// Standardizes the vars that indicate the bot is busy with its function.
	var/mode = BOT_IDLE
	/// Number of times the bot tried and failed to move.
	var/tries = 0
	/// If enabled, the AI cannot *Remotely* control a bot. It can still control it through cameras.
	var/remote_disabled = FALSE
	/// Links a bot to the AI calling it.
	var/mob/living/silicon/ai/calling_ai
	/// The bot's radio, for speaking to people.
	var/obj/item/radio/bot/Radio
	/// Which channels can the bot listen to.
	var/list/radio_config = null
	/// The bot's default radio channel.
	var/radio_channel = "Common"
	/// Set to `TRUE` make bot automatically patrol.
	var/auto_patrol = FALSE
	/// This is turf to navigate to (location of beacon).
	var/turf/patrol_target
	/// The turf of a user summoning a bot.
	var/turf/summon_target
	/// Pending new destination (waiting for beacon response).
	var/new_destination
	/// Destination description tag.
	var/destination
	/// Next destination in the patrol route.
	var/next_destination
	/// This ticks up every automated action, at 300 we clean the ignore list
	var/ignorelistcleanuptimer = 1
	var/robot_arm = /obj/item/robot_parts/r_arm

	/// Number of times retried a blocked path.
	var/blockcount = 0
	/// Count of pticks awaiting a beacon response.
	var/awaiting_beacon	= 0

	/// The nearest beacon's tag.
	var/nearest_beacon
	/// The nearest beacon's location.
	var/turf/nearest_beacon_loc

	/// The type of bot it is.
	var/model = ""
	var/bot_purpose = "improve the station to the best of your ability"
	/// Bot control frequency
	var/control_freq = BOT_FREQ
	/// The radio filter the bot uses to identify itself on the network.
	var/bot_filter
	/// The type of bot it is, for radio control.
	var/bot_type = NONE
	/// The type of data HUD the bot uses. Diagnostic by default.
	var/data_hud_type = DATA_HUD_DIAGNOSTIC
	/// This holds text for what the bot is mode doing, reported on the remote bot control interface.
	var/list/mode_name = list("In Pursuit","Preparing to Arrest", "Arresting", \
	"Beginning Patrol", "Patrolling", "Summoned by PDA", \
	"Cleaning", "Repairing", "Proceeding to work site", "Healing", \
	"Responding", "Navigating to Delivery Location", "Navigating to Home", \
	"Waiting for clear path", "Calculating navigation path", "Pinging beacon network", "Unable to reach destination")

	var/datum/atom_hud/data/bot_path/path_hud = new /datum/atom_hud/data/bot_path()
	var/path_image_icon = 'icons/obj/aibots.dmi'
	var/path_image_icon_state = "path_indicator"
	var/path_image_color = "#FFFFFF"

	var/reset_access_timer_id

	hud_possible = list(DIAG_STAT_HUD, DIAG_BOT_HUD, DIAG_HUD, DIAG_PATH_HUD = HUD_LIST_LIST)//Diagnostic HUD views


/obj/item/radio/headset/bot
	requires_tcomms = FALSE
	canhear_range = 0


/obj/item/radio/headset/bot/recalculateChannels()
	var/mob/living/simple_animal/bot/B = loc
	if(istype(B))
		if(!B.radio_config)
			B.radio_config = list("AI Private" = 1)
			if(!(B.radio_channel in B.radio_config)) // put it first so it's the :h channel
				B.radio_config.Insert(1, "[B.radio_channel]")
				B.radio_config["[B.radio_channel]"] = 1
		config(B.radio_config)


/mob/living/simple_animal/bot/proc/get_mode()
	if(client) //Player bots do not have modes, thus the override. Also an easy way for PDA users/AI to know when a bot is a player.
		if(paicard)
			return "<b>pAI Controlled</b>"
		else
			return "<b>Autonomous</b>"
	else if(!on)
		return span_bad("Inactive")
	else if(hijacked)
		return "<span class='bad'>ERROR</span>"
	else if(!mode)
		return span_good("Idle")
	else
		return span_average("[mode_name[mode]]")


/mob/living/simple_animal/bot/proc/turn_on()
	if(disabling_timer_id || stat)
		return FALSE
	on = TRUE
	set_light_on(TRUE)
	update_icon()
	update_controls()
	diag_hud_set_botstat()
	return TRUE


/mob/living/simple_animal/bot/proc/turn_off()
	on = FALSE
	set_light_on(FALSE)
	bot_reset() //Resets an AI's call, should it exist.
	update_icon()
	update_controls()


/mob/living/simple_animal/bot/Initialize(mapload)
	. = ..()

	GLOB.bots_list += src
	icon_living = icon_state
	icon_dead = icon_state
	access_card = new /obj/item/card/id(src)
	access_card.access += ACCESS_ROBOTICS	// This access is so bots can be immediately set to patrol and leave Robotics, instead of having to be let out first.
	set_custom_texts()
	Radio = new/obj/item/radio/headset/bot(src)
	Radio.follow_target = src
	add_language(LANGUAGE_GALACTIC_COMMON, TRUE)
	add_language(LANGUAGE_SOL_COMMON, TRUE)
	add_language(LANGUAGE_TRADER, TRUE)
	add_language(LANGUAGE_GUTTER, TRUE)
	add_language(LANGUAGE_TRINARY, TRUE)
	default_language = GLOB.all_languages[LANGUAGE_GALACTIC_COMMON]

	bot_core = new bot_core_type(src)
	addtimer(CALLBACK(src, PROC_REF(add_bot_filter)), 3 SECONDS)

	prepare_huds()
	for(var/datum/atom_hud/data/diagnostic/diag_hud in GLOB.huds)
		diag_hud.add_to_hud(src)
		diag_hud.add_hud_to(src)
	diag_hud_set_bothealth()
	diag_hud_set_botstat()
	diag_hud_set_botmode()
	// give us the hud too!
	if(path_hud)
		path_hud.add_to_hud(src)
		path_hud.add_hud_to(src)



/mob/living/simple_animal/bot/proc/add_bot_filter()
	if(QDELETED(src) || !SSradio || !bot_filter)
		return
	SSradio.add_object(bot_core, control_freq, bot_filter)

/mob/living/simple_animal/bot/can_strip()
	return FALSE

/mob/living/simple_animal/bot/med_hud_set_health()
	return diag_hud_set_bothealth() //we use a different hud


/mob/living/simple_animal/bot/med_hud_set_status()
	return diag_hud_set_botstat() //we use a different hud


/mob/living/simple_animal/bot/Destroy()
	if(paicard)
		ejectpai()
	set_path(null)

	if(path_hud)
		QDEL_NULL(path_hud)
		path_hud = null

 	GLOB.bots_list -= src

	QDEL_NULL(path)
	QDEL_NULL(Radio)
	QDEL_NULL(access_card)

	if(reset_access_timer_id)
		deltimer(reset_access_timer_id)
		reset_access_timer_id = null

	if(SSradio && bot_filter)
		SSradio.remove_object(bot_core, control_freq)

	QDEL_NULL(bot_core)

	return ..()


/mob/living/simple_animal/bot/death(gibbed)
	// Only execute the below if we successfully died
	. = ..()
	if(!.)
		return FALSE
	explode()


/mob/living/simple_animal/bot/proc/explode()
	qdel(src)


/mob/living/simple_animal/bot/emag_act(mob/user)
	if(locked) //First emag application unlocks the bot's interface. Apply a screwdriver to use the emag again.
		locked = FALSE
		emagged = 1
		if(user)
			to_chat(user, span_notice("You bypass [src]'s controls."))
		return

	if(!locked && open) //Bot panel is unlocked by ID or emag, and the panel is screwed open. Ready for emagging.
		if(user)
			add_attack_logs(user, src, "emagged")
		emagged = 2
		remote_disabled = TRUE //Manually emagging the bot locks out the AI built in panel.
		locked = TRUE //Access denied forever!
		bot_reset()
		turn_on() //The bot automatically turns on when emagged, unless recently hit with EMP.
		to_chat(src, span_userdanger("(#$*#$^^( OVERRIDE DETECTED"))
		show_laws()
		return

	if(user) //Bot is unlocked, but the maint panel has not been opened with a screwdriver yet.
		to_chat(user, span_warning("You need to open maintenance panel first!"))


/mob/living/simple_animal/bot/examine(mob/user)
	. = ..()
	if(health < maxHealth)
		if(health > maxHealth/3)
			. += span_notice("[src]'s parts look loose.")
		else
			. += span_warning("[src]'s parts look very loose!")
	else
		. += span_notice("[src] is in pristine condition.")


/mob/living/simple_animal/bot/adjustHealth(
	amount = 0,
	updating_health = TRUE,
	blocked = 0,
	damage_type = BRUTE,
	forced = FALSE,
)
	. = ..()
	if(. && amount > 0 && prob(10))
		new /obj/effect/decal/cleanable/blood/oil(loc)


/mob/living/simple_animal/bot/handle_automated_action()
	diag_hud_set_botmode()

	if(ignorelistcleanuptimer % 300) // Every 300 actions, clean up the ignore list from old junk
		ignorelistcleanuptimer++
	else
		for(var/uid in ignore_list)
			var/atom/referredatom = locateUID(uid)
			if(QDELETED(referredatom))
				ignore_list -= uid
		ignorelistcleanuptimer = 1

	if(!on)
		return
	if(hijacked)
		return


	switch(mode) //High-priority overrides are processed first. Bots can do nothing else while under direct command.
		if(BOT_RESPONDING)	//Called by the AI.
			call_mode()
			return
		if(BOT_SUMMON)		//Called by PDA
			bot_summon()
			return
	return TRUE //Successful completion. Used to prevent child process() continuing if this one is ended early.


/mob/living/simple_animal/bot/attack_alien(mob/living/carbon/alien/user)
	user.changeNext_move(CLICK_CD_MELEE)
	user.do_attack_animation(src)
	apply_damage(user.attack_damage, BRUTE)
	visible_message(span_danger("[user] has slashed [src]!"))
	playsound(loc, 'sound/weapons/slice.ogg', 25, 1, -1)
	if(prob(10))
		new /obj/effect/decal/cleanable/blood/oil(loc)


/mob/living/simple_animal/bot/attack_animal(mob/living/simple_animal/user)
	user.do_attack_animation(src)
	if(user.melee_damage_upper == 0)
		return
	apply_damage(user.melee_damage_upper, BRUTE)
	visible_message(span_danger("[user] has [user.attacktext] [src]!"))
	add_attack_logs(user, src, "Animal attacked", ATKLOG_ALL)
	if(prob(10))
		new /obj/effect/decal/cleanable/blood/oil(loc)


/mob/living/simple_animal/bot/attack_hand(mob/living/carbon/human/user)
	if(user.a_intent == INTENT_HELP)
		interact(user)
	else
		return ..()


/mob/living/simple_animal/bot/attack_ghost(mob/M)
	interact(M)


/mob/living/simple_animal/bot/attack_ai(mob/user)
	if(!topic_denied(user))
		interact(user)
	else
		to_chat(user, span_warning("[src]'s interface is not responding!"))


/mob/living/simple_animal/bot/proc/interact(mob/user)
	show_controls(user)


/mob/living/simple_animal/bot/attackby(obj/item/I, mob/user, params)
	if(user.a_intent == INTENT_HARM)	// NOT IN COMBAT
		return ..()

	if(I.GetID() || is_pda(I))
		add_fingerprint(user)
		if(emagged)
			to_chat(user, span_danger("ERROR##?"))
			return ATTACK_CHAIN_PROCEED
		if(open)
			to_chat(user, span_warning("Please close the access panel before locking it."))
			return ATTACK_CHAIN_PROCEED
		if(!bot_core.allowed(user))
			to_chat(user, span_warning("Access denied."))
			return ATTACK_CHAIN_PROCEED
		locked = !locked
		to_chat(user, "Controls are now [locked ? "locked." : "unlocked."]")
		return ATTACK_CHAIN_PROCEED_SUCCESS

	if(istype(I, /obj/item/paicard))
		add_fingerprint(user)
		var/obj/item/paicard/card = I
		if(locked || open || hijacked)
			to_chat(user, span_warning("The personality slot is locked."))
			return ATTACK_CHAIN_PROCEED
		if(paicard)
			to_chat(user, span_warning("The [paicard.name] is already inserted."))
			return ATTACK_CHAIN_PROCEED
		if(!card.pai || !card.pai.mind)
			to_chat(user, span_warning("The [card.name] is inactive]."))
			return ATTACK_CHAIN_PROCEED
		if(key || (!allow_pai && !card.pai.syndipai))
			to_chat(user, span_warning("The [name] is not compatible with [card]."))
			return ATTACK_CHAIN_PROCEED
		if(!card.pai.ckey || jobban_isbanned(card.pai, ROLE_SENTIENT))
			to_chat(user, span_warning("The [card.name] is unable to establish a connection to [src]."))
			return ATTACK_CHAIN_PROCEED
		if(!user.drop_transfer_item_to_loc(card, src))
			return ..()
		paicard = card
		user.visible_message(
			span_notice("[user] has inserted [card] into [src]."),
			span_notice("You have inserted [card] into [src]."),
		)
		paicard.pai.mind.transfer_to(src)
		to_chat(src, span_notice("You sense your form change as you are uploaded into [src]."))
		bot_name = name
		name = paicard.pai.name
		faction = user.faction
		tts_seed = paicard.pai.tts_seed
		add_attack_logs(user, paicard.pai, "Uploaded to [bot_name]")
		return ATTACK_CHAIN_BLOCKED_ALL

	if(istype(I, /obj/item/hemostat))
		if(open)
			to_chat(user, span_warning("Please close the access panel before manipulating with the personality slot."))
			return ATTACK_CHAIN_PROCEED
		if(!paicard)
			to_chat(user, span_warning("The [name] has no personality card installed."))
			return ATTACK_CHAIN_PROCEED
		to_chat(user, span_notice("You attempt to pull [paicard] free..."))
		if(!do_after(user, 3 SECONDS * I.toolspeed, src, category = DA_CAT_TOOL) || open || !paicard)
			return ATTACK_CHAIN_PROCEED
		user.visible_message(
			span_notice("[user] has pulled [paicard] out of [bot_name]!"),
			span_notice("You have pulled [paicard] out of [bot_name]."),
		)
		ejectpai(user)
		return ATTACK_CHAIN_PROCEED_SUCCESS

	return ..()


/mob/living/simple_animal/bot/screwdriver_act(mob/living/user, obj/item/I)
	if(user.a_intent == INTENT_HARM)
		return FALSE
	. = TRUE
	if(locked)
		to_chat(user, span_warning("The maintenance panel is locked."))
		return . // must be true or we attempt to stab the bot
	if(!I.use_tool(src, user, volume = I.tool_volume))
		return .
	open = !open
	to_chat(user, span_notice("The maintenance panel is now [open ? "opened" : "closed"]."))


/mob/living/simple_animal/bot/welder_act(mob/user, obj/item/I)
	if(user.a_intent == INTENT_HARM)
		return FALSE
	if(user == src) //No self-repair dummy
		return FALSE
	. = TRUE
	if(health >= maxHealth)
		to_chat(user, span_warning("[src] does not need a repair!"))
		return
	if(!open)
		to_chat(user, span_warning("Unable to repair with the maintenance panel closed!"))
		return
	if(!I.use_tool(src, user, volume = I.tool_volume))
		return
	adjustBruteLoss(-10)
	add_fingerprint(user)
	user.visible_message("[user] repairs [src]!", span_notice("You repair [src]."))


/mob/living/simple_animal/bot/bullet_act(obj/item/projectile/Proj)
	if(Proj && (Proj.damage_type == BRUTE || Proj.damage_type == BURN))
		if(prob(75) && Proj.damage > 0)
			do_sparks(5, 1, src)
	return ..()


/mob/living/simple_animal/bot/emp_act(severity)
	var/was_on = on
	stat |= EMPED
	var/obj/effect/overlay/pulse2 = new/obj/effect/overlay(loc)
	pulse2.icon = 'icons/effects/effects.dmi'
	pulse2.icon_state = "empdisable"
	pulse2.name = "emp sparks"
	pulse2.set_anchored(TRUE)
	pulse2.dir = pick(GLOB.cardinal)
	QDEL_IN(pulse2, 10)

	if(paicard)
		paicard.emp_act(severity)
		visible_message("[paicard] is flies out of [bot_name]!",
						span_warning("You are forcefully ejected from [bot_name]!"))
		ejectpai()
	if(on)
		turn_off()

	addtimer(CALLBACK(src, PROC_REF(un_emp), was_on), severity * 30 SECONDS)


/mob/living/simple_animal/bot/proc/un_emp(was_on)
	stat &= ~EMPED
	if(was_on)
		turn_on()


/mob/living/simple_animal/bot/proc/disable(time)
	if(!time)
		return
	if(disabling_timer_id)
		deltimer(disabling_timer_id) // if we already have disabling timer, lets replace it with new one
	if(on)
		turn_off()
	disabling_timer_id = addtimer(CALLBACK(src, PROC_REF(enable)), time, TIMER_STOPPABLE)


/mob/living/simple_animal/bot/proc/enable()
	if(disabling_timer_id)
		deltimer(disabling_timer_id)
		disabling_timer_id = null
	if(!on)
		turn_on()


/mob/living/simple_animal/bot/rename_character(oldname, newname)
	if(!..(oldname, newname))
		return FALSE

	set_custom_texts()
	return TRUE


/mob/living/simple_animal/bot/proc/set_custom_texts() //Superclass for setting hack texts. Appears only if a set is not given to a bot locally.
	text_hack = "You hack [name]."
	text_dehack = "You reset [name]."
	text_dehack_fail = "You fail to reset [name]."


/mob/living/simple_animal/bot/proc/speak(message, channel) //Pass a message to have the bot say() it. Pass a frequency to say it on the radio.
	if(!on || !message)
		return
	if(channel)
		Radio.autosay(message, name, channel == "headset" ? null : channel)
	else
		say(message)


//Generalized behavior code, override where needed!

/*
scan() will search for a given type (such as turfs, human mobs, or objects) in the bot's view range, and return a single result.
Arguments: The object type to be searched (such as "/mob/living/carbon/human"), the old scan result to be ignored, if one exists,
and the view range, which defaults to 7 (full screen) if an override is not passed.
If the bot maintains an ignore list, it is also checked here.

Example usage: patient = scan(/mob/living/carbon/human, oldpatient, 1)
The proc would return a human next to the bot to be set to the patient var.
Pass the desired type path itself, declaring a temporary var beforehand is not required.
*/
/mob/living/simple_animal/bot/proc/scan(atom/scan_type, atom/old_target, scan_range = DEFAULT_SCAN_RANGE)
	var/final_result
	for(var/scan in shuffle(view(scan_range, src))) //Search for something in range!
		var/atom/A = scan
		if(!istype(A, scan_type)) //Check that the thing we found is the type we want!
			continue //If not, keep searching!
		if((A.UID() in ignore_list) || (A == old_target) ) //Filter for blacklisted elements, usually unreachable or previously processed oness
			continue
		var/scan_result = process_scan(A) //Some bots may require additional processing when a result is selected.
		if(scan_result)
			final_result = scan_result
		else
			continue //The current element failed assessment, move on to the next.
		return final_result


/**
 * When the scan finds a target, run bot specific processing to select it for the next step. Empty by default.
 */
/mob/living/simple_animal/bot/proc/process_scan(atom/scan_target)
	return scan_target


/mob/living/simple_animal/bot/proc/add_to_ignore(atom/subject)
	if(ignore_list.len < 50) //This will help keep track of them, so the bot is always trying to reach a blocked spot.
		ignore_list += subject.UID()
	else  //If the list is full, insert newest, delete oldest.
		ignore_list.Cut(1, 2)
		ignore_list += subject.UID()


/**
 * Movement proc for stepping a bot through a path generated through A-star.
 * Pass a positive integer as an argument to override a bot's default speed.
 */
/mob/living/simple_animal/bot/proc/bot_move(dest, move_speed)
	if(!dest || !path || !length(path)) //Pathfinder failed or a path/destination was not set.
		set_path(null)
		return FALSE

	dest = get_turf(dest) //We must always compare turfs, so get the turf of the dest var if dest was originally something else.
	var/turf/last_node = get_turf(path[length(path)]) //This is the turf at the end of the path, it should be equal to dest.
	if(get_turf(src) == dest) //We have arrived, no need to move again.
		return TRUE

	else if(dest != last_node) //The path should lead us to our given destination. If this is not true, we must stop.
		set_path(null)
		return FALSE

	var/step_count = move_speed ? move_speed : base_speed //If a value is passed into move_speed, use that instead of the default speed var.

	if(step_count >= 1 && tries < BOT_STEP_MAX_RETRIES)
		for(var/step_number in 1 to step_count)
			// Hopefully this wont fill the buckets too much
			addtimer(CALLBACK(src, PROC_REF(bot_step)), BOT_STEP_DELAY * (step_number - 1))
	else
		return FALSE
	return TRUE


/mob/living/simple_animal/bot/proc/bot_step() //Step,increase tries if failed
	if(!length(path))
		return FALSE

	set_glide_size(DELAY_TO_GLIDE_SIZE(BOT_STEP_DELAY))
	if(!step_towards(src, path[1]))
		tries++
		return FALSE

	increment_path()
	tries = 0
	return TRUE


/mob/living/simple_animal/bot/proc/check_bot_access()
	if(mode != BOT_SUMMON && mode != BOT_RESPONDING)
		access_card.access = prev_access


/mob/living/simple_animal/bot/proc/call_bot(caller, turf/waypoint, message = TRUE)
	if(isAI(caller) && calling_ai && calling_ai != src) //Prevents an override if another AI is controlling this bot.
		return FALSE

	bot_reset() //Reset a bot before setting it to call mode.

	//For giving the bot temporary all-access. This method is bad and makes me feel bad. Refactoring access to a component is for another PR.
	//Easier then building the list ourselves. I'm sorry.
	if(!all_access)
		all_access = new /obj/item/card/id
		all_access.access = get_all_accesses()

	set_path(get_path_to(src, waypoint, max_distance = 200, access = all_access.GetAccess()))
	calling_ai = caller //Link the AI to the bot!
	ai_waypoint = waypoint

	if(path && length(path)) //Ensures that a valid path is calculated!
		var/area/end_area = get_area(waypoint)
		if(!on)
			turn_on() //Saves the AI the hassle of having to activate a bot manually.
		access_card.access = all_access.GetAccess() //Give the bot all-access while under the AI's command.
		if(client)
			reset_access_timer_id = addtimer(CALLBACK(src, PROC_REF(bot_reset)), 60 SECONDS, TIMER_UNIQUE|TIMER_OVERRIDE|TIMER_STOPPABLE) //if the bot is player controlled, they get the extra access for a limited time
			to_chat(src, span_notice("[span_big("Priority waypoint set by [calling_ai] <b>[caller]</b>. Proceed to <b>[end_area.name]</b>.")]<br>[path.len-1] meters to destination. You have been granted additional door access for 60 seconds."))
		if(message)
			to_chat(calling_ai, span_notice("[bicon(src)] [name] called to [end_area.name]. [length(path)-1] meters to destination."))
		pathset = TRUE
		mode = BOT_RESPONDING
		tries = 0
	else
		if(message)
			to_chat(calling_ai, span_danger("Failed to calculate a valid route. Ensure destination is clear of obstructions and within range."))
		calling_ai = null
		access_card.access = prev_access // Don't forget to reset it
		set_path(null)


/mob/living/simple_animal/bot/proc/call_mode() //Handles preparing a bot for a call, as well as calling the move proc.
//Handles the bot's movement during a call.
	var/success = bot_move(ai_waypoint, 3)
	if(!success)
		if(calling_ai)
			to_chat(calling_ai, "[bicon(src)] [get_turf(src) == ai_waypoint ? "<span class='notice'>[src] successfully arrived to waypoint.</span>" : "<span class='danger'>[src] failed to reach waypoint.</span>"]")
			calling_ai = null
		bot_reset()


/mob/living/simple_animal/bot/proc/bot_reset()
	if(calling_ai) //Simple notification to the AI if it called a bot. It will not know the cause or identity of the bot.
		to_chat(calling_ai, "<span class='danger'>Call command to a bot has been reset.</span>")
		calling_ai = null
	if(reset_access_timer_id)
		deltimer(reset_access_timer_id)
		reset_access_timer_id = null
	set_path(null)
	summon_target = null
	pathset = FALSE
	access_card.access = prev_access
	tries = 0
	mode = BOT_IDLE
	ignore_list = list()
	diag_hud_set_botstat()
	diag_hud_set_botmode()


//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
//Patrol and summon code!
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

/mob/living/simple_animal/bot/proc/bot_patrol()
	patrol_step()
	addtimer(CALLBACK(src, PROC_REF(do_patrol)), 0.5 SECONDS)


/mob/living/simple_animal/bot/proc/do_patrol()
	if(mode == BOT_PATROL)
		patrol_step()


/mob/living/simple_animal/bot/proc/start_patrol()
	if(tries >= BOT_STEP_MAX_RETRIES) //Bot is trapped, so stop trying to patrol.
		auto_patrol = FALSE
		tries = 0
		speak("Unable to start patrol.")
		return

	if(!auto_patrol) //A bot not set to patrol should not be patrolling.
		mode = BOT_IDLE
		return

	if(patrol_target) // has patrol target
		INVOKE_ASYNC(src, PROC_REF(target_patrol))
	else // no patrol target, so need a new one
		speak("Engaging patrol mode.")
		find_patrol_target()
		tries++


/mob/living/simple_animal/bot/proc/target_patrol()
	calc_path() // Find a route to it
	if(!length(path))
		patrol_target = null
		return
	mode = BOT_PATROL


/**
 * Perform a single patrol step.
 */
/mob/living/simple_animal/bot/proc/patrol_step()

	if(client)	// In use by player, don't actually move.
		return

	if(loc == patrol_target) // reached target
		//Find the next beacon matching the target.
		if(!get_next_patrol_target())
			find_patrol_target() //If it fails, look for the nearest one instead.
		return

	else if(length(path) && patrol_target) // valid path
		if(path[1] == loc)
			increment_path()
			return

		var/moved = bot_move(patrol_target)	// attempt to move
		if(!moved) //Couldn't proceed the next step of the path BOT_STEP_MAX_RETRIES times
			addtimer(CALLBACK(src, PROC_REF(patrol_step_not_moved)), 0.2 SECONDS)

	else // no path, so calculate new one
		mode = BOT_START_PATROL


/mob/living/simple_animal/bot/proc/patrol_step_not_moved()
	calc_path()
	if(!length(path))
		find_patrol_target()
	tries = 0


/**
 * Finds the nearest beacon to self.
 */
/mob/living/simple_animal/bot/proc/find_patrol_target()
	send_status()
	nearest_beacon = null
	new_destination = null
	find_nearest_beacon()
	if(nearest_beacon)
		patrol_target = nearest_beacon_loc
		destination = next_destination
	else
		auto_patrol = FALSE
		mode = BOT_IDLE
		speak("Disengaging patrol mode.")
		send_status()


/mob/living/simple_animal/bot/proc/get_next_patrol_target()
	// search the beacon list for the next target in the list.
	for(var/obj/machinery/navbeacon/NB in GLOB.navbeacons["[z]"])
		if(NB.location == next_destination) //Does the Beacon location text match the destination?
			destination = new_destination //We now know the name of where we want to go.
			patrol_target = NB.loc //Get its location and set it as the target.
			next_destination = NB.codes["next_patrol"] //Also get the name of the next beacon in line.
			return TRUE


/mob/living/simple_animal/bot/proc/find_nearest_beacon()
	for(var/obj/machinery/navbeacon/NB in GLOB.navbeacons["[z]"])
		var/dist = get_dist(src, NB)
		if(nearest_beacon) //Loop though the beacon net to find the true closest beacon.
			//Ignore the beacon if were are located on it.
			if(dist>1 && dist<get_dist(src,nearest_beacon_loc))
				nearest_beacon = NB.location
				nearest_beacon_loc = NB.loc
				next_destination = NB.codes["next_patrol"]
			else
				continue
		else if(dist > 1) //Begin the search, save this one for comparison on the next loop.
			nearest_beacon = NB.location
			nearest_beacon_loc = NB.loc
	patrol_target = nearest_beacon_loc
	destination = nearest_beacon


/mob/living/simple_animal/bot/proc/bot_control_message(command, mob/user, user_turf)
	switch(command)
		if("stop")
			to_chat(src, span_warningbig("STOP PATROL"))
		if("go")
			to_chat(src, span_warningbig("START PATROL"))
		if("summon")
			var/area/our_area = get_area(user_turf)
			to_chat(src, span_warningbig(">PRIORITY ALERT: [user] in [our_area.name]!"))
		if("home")
			to_chat(src, span_warningbig("RETURN HOME!"))
		if("ejectpai")
			return // Do nothing for this
		else
			to_chat(src, span_warning("Unidentified control sequence received: [command]"))


/obj/machinery/bot_core/receive_signal(datum/signal/signal)
	owner.receive_signal(signal)


/mob/living/simple_animal/bot/proc/receive_signal(datum/signal/signal)
	. = TRUE

	if(!on)
		return // We aint even on, why bother

	var/r_command = signal.data["command"]
	var/user = signal.data["user"]

	// process all-bot input
	if(r_command == "bot_status" && (!signal.data["active"] || signal.data["active"] == src))
		send_status()
		return

	// check to see if we are the commanded bot
	if(signal.data["active"] != src)
		return

	if(emagged == 2 || remote_disabled || hijacked) //Emagged bots do not respect anyone's authority! Bots with their remote controls off cannot get commands. //Emagged bots do not respect anyone's authority! Bots with their remote controls off cannot get commands.
		return

	if(client)
		bot_control_message(r_command, user, signal.data["target"] ? signal.data["target"] : "Unknown")

	// process control input
	switch(r_command)
		if("stop")
			bot_reset() //HOLD IT!!
			auto_patrol = FALSE

		if("go")
			auto_patrol = TRUE

		if("summon")
			bot_reset()
			var/list/user_access = signal.data["useraccess"]
			summon_target = signal.data["target"]	//Location of the user

			if(length(user_access))
				access_card.access = user_access + prev_access //Adds the user's access, if any.

			mode = BOT_SUMMON
			calc_summon_path()
			speak("Responding.", radio_channel)

		else
			. = FALSE


/**
 * Send a radio signal with a single data key/value pair.
 */
/mob/living/simple_animal/bot/proc/post_signal(freq, key, value)
	post_signal_multiple(freq, list("[key]" = value) )


/**
 * Send a radio signal with multiple data key/values.
 */
/mob/living/simple_animal/bot/proc/post_signal_multiple(freq, list/keyval)
	if(!is_station_level(z)) //Bot control will only work on station.
		return

	var/datum/radio_frequency/frequency = SSradio.return_frequency(freq)
	if(!frequency)
		return

	var/datum/signal/signal = new()
	signal.source = bot_core
	signal.transmission_method = 1
	signal.data = keyval

	INVOKE_ASYNC(src, PROC_REF(async_post_signal), frequency, signal)


/mob/living/simple_animal/bot/proc/async_post_signal(datum/radio_frequency/freq, datum/signal/signal)
	if(signal.data["type"] == bot_type)
		freq.post_signal(bot_core, signal, filter = bot_filter)
	else
		freq.post_signal(bot_core, signal)


/**
 * Signals bot status etc. to controller.
 */
/mob/living/simple_animal/bot/proc/send_status()
	if(remote_disabled || emagged == 2)
		return

	var/list/key_values = list(
	"type" = bot_type,
	"name" = name,
	"loca" = get_area(src),	// area
	"mode" = mode
	)
	post_signal_multiple(control_freq, key_values)


/mob/living/simple_animal/bot/proc/bot_summon() // summoned to PDA
	summon_step()


/**
 * Calculates a path to the current destination, given an optional turf to avoid.
 */
/mob/living/simple_animal/bot/proc/calc_path(turf/avoid)
	check_bot_access()
	set_path(get_path_to(src, patrol_target, max_distance = 120, access = access_card.GetAccess(), exclude = avoid, diagonal_handling = DIAGONAL_REMOVE_ALL))


/mob/living/simple_animal/bot/proc/calc_summon_path(turf/avoid)
	check_bot_access()
	var/datum/callback/path_complete = CALLBACK(src, PROC_REF(on_summon_path_finish))
	SSpathfinder.pathfind(src, summon_target, max_distance = 150, access = access_card.GetAccess(), exclude = avoid, diagonal_handling = DIAGONAL_REMOVE_ALL, on_finish = list(path_complete))


/mob/living/simple_animal/bot/proc/on_summon_path_finish(list/path)
	set_path(path)
	if(!length(path)) //Cannot reach target. Give up and announce the issue.
		speak("Summon command failed, destination unreachable.", radio_channel)
		bot_reset()


/mob/living/simple_animal/bot/proc/summon_step()

	if(client)		// In use by player, don't actually move.
		return

	if(loc == summon_target)		// Arrived to summon location.
		bot_reset()
		return

	else if(length(path) && summon_target)		//Proper path acquired!
		if(path[1] == loc)
			increment_path()
			return

		var/moved = bot_move(summon_target, 3)	// Move attempt
		if(!moved)
			addtimer(CALLBACK(src, PROC_REF(try_calc_path)), 0.2 SECONDS)

	else	// no path, so calculate new one
		calc_summon_path()


/mob/living/simple_animal/bot/proc/try_calc_path()
	calc_summon_path()
	tries = 0


/mob/living/simple_animal/bot/proc/openedDoor(obj/machinery/door/D)
	frustration = 0


/mob/living/simple_animal/bot/proc/show_controls(mob/user)
	users |= user
	var/dat = {"<!DOCTYPE html><meta charset="UTF-8">"}
	dat += get_controls(user)
	var/datum/browser/popup = new(user, window_id, window_name, 350, 600, src)
	popup.set_content(dat)
	popup.open()
	return


/mob/living/simple_animal/bot/proc/update_controls()
	for(var/mob/user in users)
		show_controls(user)


/mob/living/simple_animal/bot/proc/get_controls(mob/user)
	return "PROTOBOT - NOT FOR USE"


/mob/living/simple_animal/bot/Topic(href, href_list)
	if(href_list["close"])// HUE HUE
		if(usr in users)
			users.Remove(usr)
		return TRUE

	if(topic_denied(usr))
		to_chat(usr, span_warning("[src]'s interface is not responding!"))
		return TRUE

	add_fingerprint(usr)

	if((href_list["power"]) && (bot_core.allowed(usr) || !locked || usr.can_admin_interact()))
		if(on)
			turn_off()
		else
			turn_on()

	switch(href_list["operation"])
		if("patrol")
			auto_patrol = !auto_patrol
			bot_reset()
		if("remote")
			remote_disabled = !remote_disabled
		if("hack")
			handle_hacking(usr)
		if("ejectpai")
			if(paicard && (!locked || issilicon(usr) || usr.can_admin_interact()))
				to_chat(usr, span_notice("You eject [paicard] from [bot_name]."))
				ejectpai(usr)

	update_controls()


/mob/living/simple_animal/bot/proc/canhack(mob/user)
	return ((issilicon(user) && (!emagged || hacked)) || user.can_admin_interact())


/mob/living/simple_animal/bot/proc/handle_hacking(mob/user) // refactored out of Topic/ to allow re-use by TGUIs
	if(!canhack(user))
		return

	if(emagged != 2)
		emagged = 2
		hacked = TRUE
		locked = TRUE
		to_chat(user, span_warning("[text_hack]"))
		show_laws()
		bot_reset()
		add_attack_logs(user, src, "Hacked")

	else if(!hacked)
		to_chat(user, span_userdanger("[text_dehack_fail]"))

	else
		emagged = 0
		hacked = FALSE
		to_chat(user, span_notice("[text_dehack]"))
		show_laws()
		bot_reset()
		add_attack_logs(user, src, "Dehacked")


/mob/living/simple_animal/bot/update_icon_state()
	icon_state = "[initial(icon_state)][on]"


/**
 * Machinery to simplify topic and access calls.
 */
/obj/machinery/bot_core
	use_power = NO_POWER_USE
	var/mob/living/simple_animal/bot/owner = null


/obj/machinery/bot_core/New(loc)
	..()
	owner = loc
	if(!istype(owner))
		qdel(src)


/**
 * Access check proc for bot topics! Remember to place in a bot's individual Topic if desired.
 */
/mob/living/simple_animal/bot/proc/topic_denied(mob/user)
	if(user.can_admin_interact())
		return FALSE
	if(user.incapacitated() || !(issilicon(user) || in_range(src, user)))
		return TRUE
	if(emagged == 2) //An emagged bot cannot be controlled by humans, silicons can if one hacked it.
		if(!hacked) //Manually emagged by a human - access denied to all.
			return TRUE
		else if(!(issilicon(user) || ispulsedemon(user))) //Bot is hacked, so only silicons are allowed access.
			return TRUE
	if(hijacked && !ispulsedemon(user))
		return FALSE
	if(locked && !(issilicon(user) || ispulsedemon(user)))
		return TRUE
	return FALSE


/mob/living/simple_animal/bot/proc/hack(mob/user)
	var/hack
	if(issilicon(user) || user.can_admin_interact()) //Allows silicons or admins to toggle the emag status of a bot.
		hack += "[emagged == 2 ? "Software compromised! Unit may exhibit dangerous or erratic behavior." : "Unit operating normally. Release safety lock?"]<BR>"
		hack += "Harm Prevention Safety System: <a href='byond://?src=[UID()];operation=hack'>[emagged ? "<span class='bad'>DANGER</span>" : "Engaged"]</A><BR>"
	else if(!locked) //Humans with access can use this option to hide a bot from the AI's remote control panel and PDA control.
		hack += "Remote network control radio: <a href='byond://?src=[UID()];operation=remote'>[remote_disabled ? "Disconnected" : "Connected"]</A><BR>"
	return hack


/mob/living/simple_animal/bot/proc/showpai(mob/user)
	var/eject = ""
	if(!locked || issilicon(usr) || user.can_admin_interact())
		if(paicard || allow_pai)
			eject += "Personality card status: "
			if(paicard)
				if(client)
					eject += "<a href='byond://?src=[UID()];operation=ejectpai'>Active</A>"
				else
					eject += "<a href='byond://?src=[UID()];operation=ejectpai'>Inactive</A>"
			else if(!allow_pai || key)
				eject += "Unavailable"
			else
				eject += "Not inserted"
			eject += "<BR>"
		eject += "<BR>"
	return eject


/mob/living/simple_animal/bot/proc/ejectpai(mob/user = null, announce = 1)
	if(paicard)
		if(mind && paicard.pai)
			mind.transfer_to(paicard.pai)
		else if(paicard.pai)
			paicard.pai.key = key
		else
			ghostize(0) // The pAI card that just got ejected was dead.
		key = null
		paicard.forceMove(loc)
		if(user)
			add_attack_logs(user, paicard.pai, "Ejected from [src.bot_name],")
		else
			add_attack_logs(src, paicard.pai, "Ejected")
		if(announce)
			to_chat(paicard.pai, span_notice("You feel your control fade as [paicard] ejects from [bot_name]."))
		paicard = null
		name = bot_name
		faction = initial(faction)
		tts_seed = initial(tts_seed)


/mob/living/simple_animal/bot/proc/ejectpairemote(mob/user)
	if(bot_core.allowed(user) && paicard)
		speak("Ejecting personality chip.", radio_channel)
		ejectpai(user)


/mob/living/simple_animal/bot/Login()
	. = ..()
	access_card.access += player_access

	var/datum/atom_hud/data_hud = GLOB.huds[data_hud_type]
	if(data_hud)
		data_hud.add_hud_to(src)

	diag_hud_set_botmode()
	show_laws()


/mob/living/simple_animal/bot/Logout()
	. = ..()
	bot_reset()


/mob/living/simple_animal/bot/revive(full_heal = 0, admin_revive = 0)
	if(..())
		update_icon()
		. = TRUE


/mob/living/simple_animal/bot/ghost()
	if(stat != DEAD) // Only ghost if we're doing this while alive, the pAI probably isn't dead yet.
		..()

	if(paicard && (!client || stat == DEAD))
		ejectpai()


/mob/living/simple_animal/bot/sentience_act()
	faction -= "silicon"


/mob/living/simple_animal/bot/verb/show_laws()
	set name = "Show Directives"
	set category = "IC"

	to_chat(src, "<b>Directives:</b>")
	if(paicard && paicard.pai && paicard.pai.master && paicard.pai.pai_law0)
		to_chat(src, "<span class='warning'>Your master, [paicard.pai.master], may overrule any and all laws.</span>")
		to_chat(src, "0. [paicard.pai.pai_law0]")
	if(emagged >= 2)
		to_chat(src, "<span class='danger'>1. #$!@#$32K#$</span>")
	else
		to_chat(src, "1. You are a machine built to serve the station's crew and AI(s).")
		to_chat(src, "2. Your function is to [bot_purpose].")
		to_chat(src, "3. You cannot serve your function if you are broken.")
		to_chat(src, "4. Serve your function to the best of your ability.")
	if(paicard && paicard.pai && paicard.pai.pai_laws)
		to_chat(src, "<b>Supplemental Directive(s):</b>")
		to_chat(src, "[paicard.pai.pai_laws]")


/mob/living/simple_animal/bot/get_access()
	if(hijacked)
		return get_all_accesses()

	. = ..()
	if(access_card)
		. |= access_card.GetAccess()


/mob/living/simple_animal/bot/proc/door_opened(obj/machinery/door/D)
	frustration = 0


/mob/living/simple_animal/bot/handle_message_mode(message_mode, message, verb, speaking, used_radios)
	switch(message_mode)
		if("intercom")
			for(var/obj/item/radio/intercom/I in view(1, src))
				I.talk_into(src, message, null, verb, speaking)
				used_radios += I
		if("headset")
			Radio.talk_into(src, message, null, verb, speaking)
			used_radios += Radio
		else
			if(message_mode)
				Radio.talk_into(src, message, message_mode, verb, speaking)
				used_radios += Radio


/mob/living/simple_animal/bot/is_mechanical()
	return TRUE


/mob/living/simple_animal/bot/proc/set_path(list/newpath)
	path = newpath ? newpath : list()
	if(!path_hud)
		return
	var/list/path_huds_watching_me = list(GLOB.huds[DATA_HUD_DIAGNOSTIC_ADVANCED])
	if(path_hud)
		path_huds_watching_me += path_hud
	for(var/V in path_huds_watching_me)
		var/datum/atom_hud/H = V
		H.remove_from_hud(src)

	var/list/path_images = hud_list[DIAG_PATH_HUD]
	QDEL_LIST(path_images)
	if(newpath)
		for(var/i in 1 to newpath.len)
			var/turf/T = newpath[i]
			var/direction = NORTH
			if(i > 1)
				var/turf/prevT = path[i - 1]
				var/image/prevI = path[prevT]
				direction = get_dir(prevT, T)
				if(i > 2)
					var/turf/prevprevT = path[i - 2]
					var/prevDir = get_dir(prevprevT, prevT)
					var/mixDir = direction|prevDir
					if(mixDir in GLOB.diagonals)
						prevI.dir = mixDir
						if(prevDir & (NORTH|SOUTH))
							var/matrix/ntransform = matrix()
							ntransform.Turn(90)
							if((mixDir == NORTHWEST) || (mixDir == SOUTHEAST))
								ntransform.Scale(-1, 1)
							else
								ntransform.Scale(1, -1)
							prevI.transform = ntransform
			var/mutable_appearance/MA = new /mutable_appearance()
			MA.icon = path_image_icon
			MA.icon_state = path_image_icon_state
			MA.layer = ABOVE_OPEN_TURF_LAYER
			MA.plane = 0
			MA.appearance_flags = RESET_COLOR|RESET_TRANSFORM
			MA.color = path_image_color
			MA.dir = direction
			var/image/I = image(loc = T)
			I.appearance = MA
			SET_PLANE(I, GAME_PLANE, T)
			path[T] = I
			path_images += I

	for(var/V in path_huds_watching_me)
		var/datum/atom_hud/H = V
		H.add_to_hud(src)


/mob/living/simple_animal/bot/proc/increment_path()
	if(!path || !length(path))
		return
	var/image/I = path[path[1]]
	if(I)
		I.icon = null
	path.Cut(1, 2)


/mob/living/simple_animal/bot/proc/drop_part(obj/item/drop_item, dropzone)
	new drop_item(dropzone)


/obj/effect/proc_holder/spell/bot_speed
	name = "Speed Charge"
	desc = "Speeds up the bot's internal systems for a while."
	action_icon_state = "adrenal-bot"
	base_cooldown = 300 SECONDS
	clothes_req = FALSE
	human_req = FALSE


/obj/effect/proc_holder/spell/bot_speed/create_new_targeting()
	return new /datum/spell_targeting/self


/obj/effect/proc_holder/spell/bot_speed/cast(list/targets, mob/user = usr)
	for(var/mob/living/simple_animal/bot/bot in targets)
		bot.set_varspeed(0.1)
		addtimer(CALLBACK(bot, TYPE_PROC_REF(/mob/living/simple_animal/bot, reset_speed)), 45 SECONDS)


/mob/living/simple_animal/bot/proc/reset_speed()
	if(QDELETED(src))
		return
	set_varspeed(initial(speed))
	to_chat(src, span_notice("Now you are moving at your normal speed."))

/obj/machinery/bot_core/syndicate
	req_access = list(ACCESS_SYNDICATE)

