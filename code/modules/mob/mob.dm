/mob/Destroy()//This makes sure that mobs with clients/keys are not just deleted from the game.
	GLOB.mob_list -= src
	GLOB.dead_mob_list -= src
	GLOB.alive_mob_list -= src
	focus = null
	QDEL_NULL(hud_used)
	if(mind && mind.current == src)
		spellremove(src)
	mobspellremove(src)
	QDEL_LIST(diseases)
	for(var/alert in alerts)
		clear_alert(alert)
	if(client)
		var/client/client_ = client
		client_.movingmob = null
	ghostize()
	QDEL_LIST_ASSOC_VAL(tkgrabbed_objects)
	if(buckled)
		buckled.unbuckle_mob(src, force = TRUE)
	if(viewing_alternate_appearances)
		for(var/datum/alternate_appearance/AA in viewing_alternate_appearances)
			AA.viewers -= src
		viewing_alternate_appearances = null
	LAssailant = null
	return ..()

/mob/Initialize(mapload)
	GLOB.mob_list += src
	if(stat == DEAD)
		GLOB.dead_mob_list += src
	else
		GLOB.alive_mob_list += src
	set_focus(src)
	prepare_huds()
	. = ..()
	update_config_movespeed()
	update_movespeed()
	initialize_actionspeed()
	if(can_strip())
		ADD_TRAIT(src, TRAIT_CAN_STRIP, GENERIC_TRAIT)

/mob/vv_edit_var(var_name, var_value)
	switch(var_name)
		if(NAMEOF(src, focus))
			set_focus(var_value)
			. = TRUE
		if(NAMEOF(src, machine))
			set_machine(var_value)
			. = TRUE
		if(NAMEOF(src, nutrition))
			set_nutrition(var_value)
			. = TRUE
		if(NAMEOF(src, stat))
			set_stat(var_value)
			. = TRUE

	if(!isnull(.))
		datum_flags |= DF_VAR_EDITED
		return .

	var/slowdown_edit = (var_name == NAMEOF(src, cached_multiplicative_slowdown))
	var/diff
	if(slowdown_edit && isnum(cached_multiplicative_slowdown) && isnum(var_value))
		remove_movespeed_modifier(/datum/movespeed_modifier/admin_varedit)
		diff = var_value - cached_multiplicative_slowdown

	. = ..()

	if(. && slowdown_edit && isnum(diff))
		add_or_update_variable_movespeed_modifier(/datum/movespeed_modifier/admin_varedit, multiplicative_slowdown = diff)


/atom/proc/prepare_huds()
	hud_list = list()
	for(var/hud in hud_possible)
		var/hint = hud_possible[hud]
		switch(hint)
			if(HUD_LIST_LIST)
				hud_list[hud] = list()
			else
				var/image/I = image('icons/mob/hud.dmi', src, "")
				I.appearance_flags = RESET_COLOR | RESET_TRANSFORM
				hud_list[hud] = I

/mob/proc/generate_name()
	return name

/mob/proc/GetAltName()
	return ""

/mob/proc/Cell()
	set category = "Admin"
	set hidden = 1

	if(!loc) return 0

	var/datum/gas_mixture/environment = loc.return_air()

	var/t = "<span class='notice'>Coordinates: [x],[y] \n</span>"
	t+= "<span class='warning'>Temperature: [environment.temperature] \n</span>"
	t+= "<span class='notice'>Nitrogen: [environment.nitrogen] \n</span>"
	t+= "<span class='notice'>Oxygen: [environment.oxygen] \n</span>"
	t+= "<span class='notice'>Plasma : [environment.toxins] \n</span>"
	t+= "<span class='notice'>Carbon Dioxide: [environment.carbon_dioxide] \n</span>"
	t+= "<span class='notice'>N2O: [environment.sleeping_agent] \n</span>"
	t+= "<span class='notice'>Agent B: [environment.agent_b] \n</span>"

	usr.show_message(t, 1)


/mob/proc/show_message(msg, type, alt, alt_type, chat_message_type)

	if(!client)
		return

	if(type)
		if((type & EMOTE_VISIBLE) && !has_vision(information_only = TRUE))	//Vision related
			if(!alt)
				return
			msg = alt
			type = alt_type

		if(type & EMOTE_AUDIBLE && !can_hear())	//Hearing related
			if(!alt)
				return
			msg = alt
			type = alt_type
			if((type & EMOTE_VISIBLE) && !has_vision(information_only = TRUE))
				return

	// Added voice muffling for Issue 41.
	if(stat == UNCONSCIOUS)
		to_chat(src, "<I>…Вам почти удаётся расслышать чьи-то слова…</I>", MESSAGE_TYPE_LOCALCHAT)
	else
		to_chat(src, msg, chat_message_type)


// Show a message to all mobs in sight of this one
// This would be for visible actions by the src mob
// message is the message output to anyone who can see e.g. "[src] does something!"
// self_message (optional) is what the src mob sees  e.g. "You do something!"
// blind_message (optional) is what blind people will hear e.g. "You hear something!"
/mob/visible_message(message, self_message, blind_message, list/ignored_mobs, chat_message_type)
	if(!isturf(loc)) // mobs inside objects (such as lockers) shouldn't have their actions visible to those outside the object
		for(var/mob/mob as anything in (get_mobs_in_view(3, src, include_radio = FALSE) - ignored_mobs))
			if(mob.see_invisible < invisibility)
				continue //can't view the invisible
			var/msg = message
			if(self_message && mob == src)
				msg = self_message
			if(mob.loc != loc)
				if(!blind_message) // for some reason VISIBLE action has blind_message param so if we are not in the same object but next to it, lets show it
					continue
				msg = blind_message
			mob.show_message(msg, EMOTE_VISIBLE, blind_message, EMOTE_AUDIBLE, chat_message_type)
		return

	for(var/mob/mob as anything in (get_mobs_in_view(7, src, include_radio = FALSE) - ignored_mobs))
		if(mob.see_invisible < invisibility)
			continue //can't view the invisible
		var/msg = message
		if(self_message && mob == src)
			msg = self_message
		mob.show_message(msg, EMOTE_VISIBLE, blind_message, EMOTE_AUDIBLE, chat_message_type)


// Show a message to all mobs in sight of this atom
// Use for objects performing visible actions
// message is output to anyone who can see, e.g. "The [src] does something!"
// blind_message (optional) is what blind people will hear e.g. "You hear something!"
/atom/proc/visible_message(message, self_message, blind_message, list/ignored_mobs)
	for(var/mob/mob as anything in (get_mobs_in_view(7, src, include_radio = FALSE) - ignored_mobs))
		mob.show_message(message, EMOTE_VISIBLE, blind_message, EMOTE_AUDIBLE)


// Show a message to all mobs in earshot of this one
// This would be for audible actions by the src mob
// message is the message output to anyone who can hear.
// self_message (optional) is what the src mob hears.
// deaf_message (optional) is what deaf people will see.
// hearing_distance (optional) is the range, how many tiles away the message can be heard.
/mob/audible_message(message, deaf_message, hearing_distance)
	var/range = 7
	if(hearing_distance)
		range = hearing_distance
	var/msg = message
	for(var/mob/M in get_mobs_in_view(range, src))
		M.show_message(msg, EMOTE_AUDIBLE, deaf_message, EMOTE_VISIBLE)

	// based on say code
	var/omsg = replacetext(message, "<B>[src]</B> ", "")
	var/list/listening_obj = new
	for(var/atom/movable/A in view(range, src))
		if(ismob(A))
			var/mob/M = A
			for(var/obj/O in M.contents)
				listening_obj |= O
		else if(isobj(A))
			var/obj/O = A
			listening_obj |= O
	for(var/obj/O in listening_obj)
		O.hear_message(src, omsg)


// Show a message to all mobs in earshot of this atom
// Use for objects performing audible actions
// message is the message output to anyone who can hear.
// deaf_message (optional) is what deaf people will see.
// hearing_distance (optional) is the range, how many tiles away the message can be heard.
/atom/proc/audible_message(message, deaf_message, hearing_distance)
	var/range = 7
	if(hearing_distance)
		range = hearing_distance
	for(var/mob/M in get_mobs_in_view(range, src))
		M.show_message(message, EMOTE_AUDIBLE, deaf_message, EMOTE_VISIBLE)


/mob/proc/findname(msg)
	for(var/mob/M in GLOB.mob_list)
		if(M.real_name == text("[]", msg))
			return M
	return 0


/mob/proc/get_visible_mobs()
	var/list/seen_mobs = list()
	var/list/actual_view = client ? view(client) : view(src)
	for(var/mob/M in actual_view)
		seen_mobs += M
	return seen_mobs

/**
  * Called by using Activate Held Object with an empty hand/limb
  *
  * Does nothing by default. The intended use is to allow limbs to call their
  * own attack_self procs. It is up to the individual mob to override this
  * parent and actually use it.
  */
/mob/proc/limb_attack_self()
	return

/**
 * Returns an assoc list which contains the mobs in range and their "visible" name.
 * Mobs out of view but in range will be listed as unknown. Else they will have their visible name
*/
/mob/proc/get_telepathic_targets()
	var/list/validtargets = new /list()
	var/turf/T = get_turf(src)
	var/list/mobs_in_view = get_visible_mobs()

	for(var/mob/living/M in range(14, T))
		if(M && M.mind)
			if(M == src)
				continue
			var/mob_name
			if(M in mobs_in_view)
				mob_name = M.name
			else
				mob_name = "Unknown entity"
			var/i = 0
			var/result_name
			do
				result_name = mob_name
				if(i++)
					result_name += " ([i])" // Avoid dupes
			while(validtargets[result_name])
			validtargets[result_name] = M
	return validtargets


/**
 * Reset the attached clients perspective (viewpoint)
 *
 * reset_perspective(null) set eye to common default : mob on turf, loc otherwise
 * reset_perspective(thing) set the eye to the thing (if it's equal to current default reset to mob perspective)
 */
/mob/proc/reset_perspective(atom/new_eye)
	SHOULD_CALL_PARENT(TRUE)
	if(!client)
		return

	if(new_eye)
		if(ismovable(new_eye))
			//Set the new eye unless it's us
			if(new_eye != src)
				client.perspective = EYE_PERSPECTIVE
				client.set_eye(new_eye)
			else
				client.set_eye(client.mob)
				client.perspective = MOB_PERSPECTIVE

		else if(isturf(new_eye))
			//Set to the turf unless it's our current turf
			if(new_eye != loc)
				client.perspective = EYE_PERSPECTIVE
				client.set_eye(new_eye)
			else
				client.set_eye(client.mob)
				client.perspective = MOB_PERSPECTIVE
		else
			return TRUE //no setting eye to stupid things like areas or whatever
	else
		//Reset to common defaults: mob if on turf, otherwise current loc
		if(isturf(loc))
			client.set_eye(client.mob)
			client.perspective = MOB_PERSPECTIVE
		else
			client.perspective = EYE_PERSPECTIVE
			client.set_eye(loc)

	return TRUE


/mob/living/reset_perspective(atom/new_eye)
	. = ..()
	if(.)
		// Above check means the mob has a client
		update_sight()
		update_fullscreen()
		update_pipe_vision()


/// Proc used to handle the fullscreen overlay updates, realistically meant for the reset_perspective() proc.
/mob/living/proc/update_fullscreen()
	if(client.eye && client.eye != src)
		var/atom/client_eye = client.eye
		client_eye.get_remote_view_fullscreens(src)
	else
		clear_fullscreen("remote_view", 0)


/mob/dead/reset_perspective(atom/A)
	. = ..()
	if(.)
		// Allows sharing HUDs with ghosts
		if(hud_used)
			client.screen = list()
			hud_used.show_hud(hud_used.hud_version)

//mob verbs are faster than object verbs. See http://www.byond.com/forum/?post=1326139&page=2#comment8198716 for why this isn't atom/verb/examine()
/mob/verb/examinate(atom/A as mob|obj|turf in view())
	set name = "Examine"
	set category = "IC"

	DEFAULT_QUEUE_OR_CALL_VERB(VERB_CALLBACK(src, PROC_REF(run_examinate), A))

/mob/proc/run_examinate(atom/A)
	var/list/result = A.examine(src)
	to_chat(src, chat_box_examine(result.Join("\n")), MESSAGE_TYPE_INFO, confidential = TRUE)


/mob/verb/mode()
	set name = "Activate Held Object"
	set src = usr

	if(ismecha(loc))
		var/obj/mecha/mecha = loc
		if(src == mecha.occupant)
			mecha.selected?.self_occupant_attack()
		return

	var/obj/item/I = get_active_hand()
	if(I)
		I.attack_self(src)
		update_inv_hands()
		return

	if(pulling && isliving(src))
		var/mob/living/grabber = src
		if(!isnull(grabber.pull_hand) && grabber.pull_hand != PULL_WITHOUT_HANDS)
			if(grabber.next_move <= world.time && grabber.hand == grabber.pull_hand)
				grabber.grab(pulling)
			return

	limb_attack_self()


/// Cleanup proc that's called when a mob loses a client, either through client destroy or logout
/// Logout happens post client del, so we can't just copypaste this there. This keeps things clean and consistent
/mob/proc/become_uncliented()
	if(!canon_client)
		return

	if(canon_client?.movingmob)
		LAZYREMOVE(canon_client.movingmob.client_mobs_in_contents, src)
		canon_client.movingmob = null

	canon_client = null

/mob/verb/memory()
	set name = "Notes"
	set category = "IC"
	if(mind)
		mind.show_memory(src)
	else
		to_chat(src, "The game appears to have misplaced your mind datum, so we can't show you your notes.")

/mob/verb/add_memory(msg as message)
	set name = "Add Note"
	set category = "IC"

	msg = copytext(msg, 1, MAX_MESSAGE_LEN)
	msg = sanitize_simple(html_encode(msg), list("\n" = "<BR>"))
	msg = sanitize_censored_patterns(msg)

	var/combined = length(memory + msg)
	if(mind && (combined < MAX_PAPER_MESSAGE_LEN))
		mind.store_memory(msg)
	else if(combined >= MAX_PAPER_MESSAGE_LEN)
		to_chat(src, "Your brain can't hold that much information!")
		return
	else
		to_chat(src, "The game appears to have misplaced your mind datum, so we can't show you your notes.")

/mob/proc/store_memory(msg as message, popup, sane = 1)
	msg = copytext(msg, 1, MAX_MESSAGE_LEN)

	if(sane)
		msg = sanitize(msg)

	if(length(memory) == 0)
		memory += msg
	else
		memory += "<BR>[msg]"

	if(popup)
		memory()

/mob/proc/update_flavor_text()
	set src in usr
	if(usr != src)
		to_chat(usr, "No.")
	var/msg = tgui_input_text(usr, "Set the flavor text in your 'examine' verb. The flavor text should be a physical descriptor of your character at a glance. SFW Drawn Art of your character is acceptable.", "Flavor Text", flavor_text, multiline = TRUE)
	if(isnull(msg))
		return
	if(stat)
		to_chat(usr, "<span class='notice'>You have to be conscious to change your flavor text</span>")
		return
	msg = copytext(msg, 1, MAX_MESSAGE_LEN)
	flavor_text = msg

/mob/proc/print_flavor_text(var/shrink = TRUE)
	if(flavor_text && flavor_text != "")
		var/msg = replacetext(flavor_text, "\n", " ")
		if(length(msg) <= 60 || !shrink)
			return "<span class='notice'>[msg]</span>" // There is already encoded by tgui_input
		else
			return "<span class='notice'>[copytext_preserve_html(msg, 1, 57)]... <a href='byond://?src=[UID()];flavor_more=1'>More...</a></span>"

/mob
	var/newPlayerType = /mob/new_player

/mob/verb/abandon_mob()
	set name = "Respawn"
	set category = "OOC"

	if(!GLOB.abandon_allowed)
		to_chat(usr, "<span class='warning'>Respawning is disabled.</span>")
		return

	if(stat != DEAD || !SSticker)
		to_chat(usr, "<span class='boldnotice'>You must be dead to use this!</span>")
		return

	if(!(usr in GLOB.respawnable_list))
		to_chat(usr, "You are not dead or you have given up your right to be respawned!")
		return

	var/deathtime = world.time - src.timeofdeath
	if(istype(src,/mob/dead/observer))
		var/mob/dead/observer/G = src
		if(cannotPossess(G))
			to_chat(usr, "<span class='warning'>Upon using the antagHUD you forfeited the ability to join the round.</span>")
			return

	var/deathtimeminutes = round(deathtime / 600)
	var/pluralcheck = "minute"
	if(deathtimeminutes == 0)
		pluralcheck = ""
	else if(deathtimeminutes == 1)
		pluralcheck = " [deathtimeminutes] minute and"
	else if(deathtimeminutes > 1)
		pluralcheck = " [deathtimeminutes] minutes and"
	var/deathtimeseconds = round((deathtime - deathtimeminutes * 600) / 10,1)

	if(deathtimeminutes < CONFIG_GET(number/respawn_delay))
		to_chat(usr, "You have been dead for[pluralcheck] [deathtimeseconds] seconds.")
		to_chat(usr, "<span class='warning'>You must wait [CONFIG_GET(number/respawn_delay)] minutes to respawn!</span>")
		return

	if(alert("Are you sure you want to respawn?", "Are you sure?", "Yes", "No") != "Yes")
		return

	add_game_logs("has respawned.", usr)

	to_chat(usr, "<span class='boldnotice'>Make sure to play a different character, and please roleplay correctly!</span>")

	if(!client)
		add_game_logs("respawn failed due to disconnect.", usr)
		return
	client.screen.Cut()
	client.screen += client.void

	if(!client)
		add_game_logs("respawn failed due to disconnect.", usr)
		return

	GLOB.respawnable_list -= usr
	var/mob/new_player/M = new /mob/new_player()
	if(!client)
		add_game_logs("respawn failed due to disconnect.", usr)
		qdel(M)
		return

	M.key = key
	GLOB.respawnable_list += usr
	return

/mob/proc/is_dead()
	return stat == DEAD

/mob/verb/cancel_camera()
	set name = "Cancel Camera View"
	set category = "OOC"
	reset_perspective(null)
	unset_machine()
	if(isliving(src))
		if(src:cameraFollow)
			src:cameraFollow = null

/mob/Topic(href, href_list)
	. = ..()
	if(href_list["mach_close"])
		var/t1 = text("window=[href_list["mach_close"]]")
		unset_machine()
		src << browse(null, t1)

	if(href_list["flavor_more"])
		usr << browse(text({"<HTML><meta charset="UTF-8"><HEAD><TITLE>[]</TITLE></HEAD><BODY><TT>[]</TT></BODY></HTML>"}, name, replacetext(flavor_text, "\n", "<BR>")), text("window=[];size=500x200", name))
		onclose(usr, "[name]")
	if(href_list["flavor_change"])
		update_flavor_text()

	if(href_list["scoreboard"])
		usr << browse(GLOB.scoreboard, "window=roundstats;size=700x900")


/mob/MouseDrop(mob/living/user, src_location, over_location, src_control, over_control, params)
	. = ..()
	if(!. || usr != user || usr == src || !HAS_TRAIT(user, TRAIT_CAN_STRIP))
		return FALSE
	if(isliving(user) && user.mob_size <= MOB_SIZE_SMALL)
		return FALSE // Stops pAI drones and small mobs (borers, parrots, crabs) from stripping people. --DZD
	if(IsFrozen(src) && !is_admin(user))
		to_chat(usr, span_boldnotice("Interacting with admin-frozen players is not permitted."))
		return FALSE
	if(isLivingSSD(src) && user.client?.send_ssd_warning(src))
		return FALSE
	SEND_SIGNAL(src, COMSIG_DO_MOB_STRIP, user, usr)

/mob/proc/is_mechanical()
	return mind && (mind.assigned_role == JOB_TITLE_CYBORG || mind.assigned_role == JOB_TITLE_AI)

/mob/proc/is_ready()
	return client && !!mind

/mob/proc/is_in_brig()
	if(!loc || !loc.loc)
		return 0

	// They should be in a cell or the Brig portion of the shuttle.
	var/area/A = loc.loc
	if(!istype(A, /area/security/prison))
		if(!istype(A, /area/shuttle/escape) || loc.name != "Brig floor")
			return 0

	// If they still have their ID they're not brigged.
	for(var/obj/item/card/id/card in src)
		return 0
	for(var/obj/item/pda/P in src)
		if(P.id)
			return 0

	return 1

/mob/proc/get_gender()
	return gender

/mob/proc/is_muzzled()
	return 0

/mob/proc/get_status_tab_items()
	SHOULD_CALL_PARENT(TRUE)
	var/list/status_tab_data = list()
	return status_tab_data

// facing verbs
/mob/proc/canface()
	if(stat == DEAD)
		return FALSE
	if(anchored)
		return FALSE
	if(HAS_TRAIT(src, TRAIT_NO_TRANSFORM))
		return FALSE
	if(HAS_TRAIT(src, TRAIT_RESTRAINED))
		return FALSE
	return TRUE

/mob/proc/facedir(ndir)
	if(!canface())
		return FALSE
	setDir(ndir)
	client.move_delay += cached_multiplicative_slowdown
	return TRUE


/mob/verb/eastface()
	set hidden = 1
	return facedir(EAST)


/mob/verb/westface()
	set hidden = 1
	return facedir(WEST)


/mob/verb/northface()
	set hidden = 1
	return facedir(NORTH)


/mob/verb/southface()
	set hidden = 1
	return facedir(SOUTH)


/mob/proc/IsAdvancedToolUser()//This might need a rename but it should replace the can this mob use things check
	return FALSE

/mob/proc/can_use_machinery(obj/machinery/mach)
	return IsAdvancedToolUser() 

/mob/proc/swap_hand()
	return

/mob/proc/activate_hand(selhand)
	return

/mob/dead/observer/verb/respawn()
	set name = "Respawn as NPC"
	set category = "Ghost"

	if(jobban_isbanned(usr, ROLE_SENTIENT))
		to_chat(usr, span_warning("You are banned from playing as sentient animals."))
		return

	if(!SSticker || SSticker.current_state < GAME_STATE_PLAYING)
		to_chat(src, span_warning("You can't respawn as an NPC before the game starts!"))
		return

	if(stat != DEAD && !isobserver(usr))
		to_chat(usr, span_warning("You are not dead or you have given up your right to be respawned!"))
		return

	var/list/allowed_creatures = list()
	for(var/mob/living/alive_mob as anything in GLOB.alive_mob_list)
		if(!alive_mob.key && alive_mob.stat != DEAD && safe_respawn(alive_mob, TRUE))
			allowed_creatures[++allowed_creatures.len] = "[alive_mob.name]" + " ([get_area_name(alive_mob, TRUE)])"
			allowed_creatures["[alive_mob.name]" + " ([get_area_name(alive_mob, TRUE)])"] = alive_mob

	allowed_creatures.Insert(1, "Mouse")

	var/mob/living/picked = tgui_input_list(usr, "Please select an NPC to respawn as", "Respawn as NPC", allowed_creatures)
	if(!picked)
		return
		
	if(picked == "Mouse")
		become_mouse()
		return

	var/mob/living/picked_mob = allowed_creatures[picked]
	var/message = picked_mob.get_npc_respawn_message()

	if(QDELETED(picked_mob) || picked_mob.key || picked_mob.stat == DEAD)
		to_chat(usr, span_warning("[capitalize(picked_mob)] is no longer available to respawn!"))
		return
	
	if(istype(picked_mob, /mob/living/simple_animal/borer))
		var/mob/living/simple_animal/borer/borer = picked_mob
		borer.transfer_personality(usr.client)
		return

	to_chat(usr, span_notify(message))
	GLOB.respawnable_list -= usr
	picked_mob.key = key
		

/mob/proc/become_mouse()
	var/timedifference = world.time - client.time_joined_as_mouse
	if(client.time_joined_as_mouse && timedifference <= GLOB.mouse_respawn_time * 600)
		var/timedifference_text = time2text(GLOB.mouse_respawn_time * 600 - timedifference,"mm:ss")
		to_chat(src, "<span class='warning'>You may only spawn again as a mouse more than [GLOB.mouse_respawn_time] minutes after last spawn. You have [timedifference_text] left.</span>")
		return

	//find a viable mouse candidate
	var/list/found_vents = get_valid_vent_spawns(min_network_size = 0)
	if(length(found_vents))
		GLOB.respawnable_list -= src
		client.time_joined_as_mouse = world.time
		var/obj/vent_found = pick(found_vents)
		var/choosen_type = prob(90) ? /mob/living/simple_animal/mouse : /mob/living/simple_animal/mouse/rat
		var/mob/living/simple_animal/mouse/host = new choosen_type(vent_found.loc)
		host.ckey = src.ckey
		to_chat(host, "<span class='info'>You are now a mouse. Try to avoid interaction with players, and do not give hints away that you are more than a simple rodent.</span>")
	else
		to_chat(src, "<span class='warning'>Unable to find any unwelded vents to spawn mice at.</span>")

/mob/proc/assess_threat() //For sec bot threat assessment
	return 5

/mob/proc/get_ghost(even_if_they_cant_reenter = 0)
	if(mind)
		return mind.get_ghost(even_if_they_cant_reenter)

/mob/proc/grab_ghost(force)
	if(mind)
		return mind.grab_ghost(force = force)

/mob/proc/notify_ghost_cloning(message = "Someone is trying to revive you. Re-enter your corpse if you want to be revived!", sound = 'sound/effects/genetics.ogg', atom/source = null, flashwindow = TRUE)
	var/mob/dead/observer/ghost = get_ghost()
	if(ghost)
		if(flashwindow)
			window_flash(ghost.client)
		ghost.notify_cloning(message, sound, source)
		return ghost

/mob/proc/fakevomit(green = 0, no_text = 0) //for aesthetic vomits that need to be instant and do not stun. -Fox
	if(stat==DEAD)
		return
	var/turf/location = loc
	if(issimulatedturf(location))
		if(green)
			if(!no_text)
				visible_message("<span class='warning'>[src.name] вырвало зелёной липкой массой!</span>","<span class='warning'>Вас вырвало зелёной липкой массой!</span>")
			location.add_vomit_floor(FALSE, TRUE)
		else
			if(!no_text)
				visible_message("<span class='warning'>[src.name] наблевал[genderize_ru(src.gender,"","а","о","и")] на себя!</span>","<span class='warning'>Вы наблевали на себя!</span>")
			location.add_vomit_floor(TRUE)


/mob/proc/AddSpell(obj/effect/proc_holder/spell/spell)
	if(!istype(spell))
		return
	LAZYADD(mob_spell_list, spell)
	spell.action.Grant(src)
	spell.on_spell_gain(src)

/mob/proc/RemoveSpell(obj/effect/proc_holder/spell/instance_or_path)
	if(!ispath(instance_or_path))
		instance_or_path = instance_or_path.type
	for(var/obj/effect/proc_holder/spell/spell as anything in mob_spell_list)
		if(spell.type == instance_or_path)
			LAZYREMOVE(mob_spell_list, spell)
			qdel(spell)


//override to avoid rotating pixel_xy on mobs
/mob/shuttleRotate(rotation)
	dir = angle2dir(rotation+dir2angle(dir))


/**
  * Buckle to another mob
  *
  * You can buckle on mobs if you're next to them since most are dense
  *
  * Turns you to face the other mob too
  */
/mob/is_buckle_possible(mob/living/target, force = FALSE, check_loc = TRUE)
	if(target.buckled)
		return FALSE
	return ..()


/**
 * Buckle a living mob to this mob. Also turns you to face the other mob
 *
 * You can buckle on mobs if you're next to them since most are dense
 */
/mob/buckle_mob(mob/living/target, force = FALSE, check_loc = TRUE)
	if(target.buckled)
		return FALSE
	return ..()


///Call back post buckle to a mob to offset your visual height
/mob/post_buckle_mob(mob/living/target)
	target.pixel_y += target.get_mob_buckling_height(src)
	if(target.layer < layer)
		target.layer = layer + 0.01


///Call back post unbuckle from a mob, (reset your visual height here)
/mob/post_unbuckle_mob(mob/living/target)
	target.pixel_y -= target.get_mob_buckling_height(src)
	target.layer = initial(target.layer)


///returns the height in pixel the mob should have when buckled to another mob.
/mob/proc/get_mob_buckling_height(mob/seat)
	if(isliving(seat))
		var/mob/living/L = seat
		if(L.mob_size <= MOB_SIZE_SMALL) //being on top of a small mob doesn't put you very high.
			return 0
	return 9


//Can the mob see reagents inside of containers?
/mob/proc/can_see_reagents()
	return 0

/mob/proc/can_see_food()
	return FALSE

//Can this mob leave its location without breaking things terrifically?
/mob/proc/can_safely_leave_loc()
	return 1 // Yes, you can

/mob/proc/IsVocal()
	return 1

/mob/proc/get_access_locations()
	return list()

//Must return list or IGNORE_ACCESS
/mob/proc/get_access()
	. = list()
	for(var/obj/item/access_location in get_access_locations())
		. |= access_location.GetAccess()

/mob/update_tts_seed(new_tts_seed)
	. = ..()
	if(. && dna)
		dna.tts_seed_dna = new_tts_seed

/*
 * * Creates Log Record for Log Viewer
 * log_type - look __DEFINES/logs.dm (example: ATTACK_LOG, SAY_LOG, MISC_LOGS)
 * what - happened that got logged a mob. Someone screamed or planted an explosion
 * target - who targeted
 * where(optional) - at what placed
 */
/mob/proc/create_log(log_type, what, target = null, turf/where = get_turf(src))
	if(!ckey)
		return
	var/real_ckey = ckey
	if(ckey[1] == "@") // Admin aghosting will do this
		real_ckey = copytext(ckey, 2)
	var/datum/log_record/record = new(log_type, src, what, target, where, world.time)
	GLOB.logging.add_log(real_ckey, record)


/mob/proc/create_attack_log(text, collapse = TRUE)
	LAZYINITLIST(attack_log_old)
	create_log_in_list(attack_log_old, text, collapse, last_log)
	last_log = world.timeofday


/mob/proc/create_debug_log(text, collapse = TRUE)
	LAZYINITLIST(debug_log)
	create_log_in_list(debug_log, text, collapse, world.timeofday)


/proc/create_log_in_list(list/target, text, collapse = TRUE, last_log)//forgive me code gods for this shitcode proc
	//this proc enables lovely stuff like an attack log that looks like this: "[18:20:29-18:20:45]21x John Smith attacked Andrew Jackson with a crowbar."
	//That makes the logs easier to read, but because all of this is stored in strings, weird things have to be used to get it all out.
	var/new_log = "\[[time_stamp()]] [text]"

	if(target.len)//if there are other logs already present
		var/previous_log = target[target.len]//get the latest log
		var/last_log_is_range = (copytext(previous_log, 10, 11) == "-") //whether the last log is a time range or not. The "-" will be an indicator that it is.
		var/x_sign_position = findtext(previous_log, "x")

		if(world.timeofday - last_log > 100)//if more than 10 seconds from last log
			collapse = 0//don't collapse anyway

		//the following checks if the last log has the same contents as the new one
		if(last_log_is_range)
			if(!(copytext(previous_log, x_sign_position + 13) == text))//the 13 is there because of span classes; you won't see those normally in-game
				collapse = 0
		else
			if(!(copytext(previous_log, 12) == text))
				collapse = 0


		if(collapse == 1)
			var/rep = 0
			var/old_timestamp = copytext(previous_log, 2, 10)//copy the first time value. This one doesn't move when it's a timespan, so no biggie
			//An attack log entry can either be a time range with multiple occurences of an action or a single one, with just one time stamp
			if(last_log_is_range)

				rep = text2num(copytext(previous_log, 44, x_sign_position))//get whatever number is right before the 'x'

			new_log = "\[[old_timestamp]-[time_stamp()]]<font color='purple'><b>[rep?rep+1:2]x</b></font> [text]"
			target -= target[target.len]//remove the last log

	target += new_log


/mob/vv_get_dropdown()
	. = ..()
	.["Show player panel"] = "?_src_=vars;mob_player_panel=[UID()]"

	.["Give Spell"] = "?_src_=vars;give_spell=[UID()]"
	.["Give Martial Art"] = "?_src_=vars;givemartialart=[UID()]"
	.["Give Disease"] = "?_src_=vars;give_disease=[UID()]"
	.["Give Taipan Hud"] = "?_src_=vars;give_taipan_hud=[UID()]"
	.["Toggle Godmode"] = "?_src_=vars;godmode=[UID()]"
	.["Toggle Build Mode"] = "?_src_=vars;build_mode=[UID()]"

	.["Make 2spooky"] = "?_src_=vars;make_skeleton=[UID()]"

	.["Assume Direct Control"] = "?_src_=vars;direct_control=[UID()]"
	.["Offer Control to Ghosts"] = "?_src_=vars;offer_control=[UID()]"
	.["Drop Everything"] = "?_src_=vars;drop_everything=[UID()]"

	.["Regenerate Icons"] = "?_src_=vars;regenerateicons=[UID()]"
	.["Add Language"] = "?_src_=vars;addlanguage=[UID()]"
	.["Remove Language"] = "?_src_=vars;remlanguage=[UID()]"
	.["Grant All Language"] = "?_src_=vars;grantalllanguage=[UID()]"
	.["Change Voice"] = "?_src_=vars;changevoice=[UID()]"
	.["Add Organ"] = "?_src_=vars;addorgan=[UID()]"
	.["Remove Organ"] = "?_src_=vars;remorgan=[UID()]"

	.["Add Verb"] = "?_src_=vars;addverb=[UID()]"
	.["Remove Verb"] = "?_src_=vars;remverb=[UID()]"

	.["Gib"] = "?_src_=vars;gib=[UID()]"

///Can this mob resist (default FALSE)
/mob/proc/can_resist()
	return FALSE		//overridden in living.dm

///Can this mob use strip menu (defaut TRUE)
/mob/proc/can_strip()
	return TRUE

///Spin this mob around it's central axis
/mob/proc/spin(spintime, speed)
	set waitfor = FALSE
	var/our_dir = dir
	if((spintime < 1) || (speed < 1) || !spintime || !speed)
		return

	while(spintime >= speed)
		sleep(speed)
		switch(our_dir)
			if(NORTH)
				our_dir = EAST
			if(SOUTH)
				our_dir = WEST
			if(EAST)
				our_dir = SOUTH
			if(WEST)
				our_dir = NORTH
		setDir(our_dir)
		spintime -= speed

/mob/proc/is_literate()
	return universal_speak

/mob/proc/faction_check_mob(mob/target, exact_match)
	if(exact_match) //if we need an exact match, we need to do some bullfuckery.
		var/list/faction_src = faction.Copy()
		var/list/faction_target = target.faction.Copy()
		if(!("\ref[src]" in faction_target)) //if they don't have our ref faction, remove it from our factions list.
			faction_src -= "\ref[src]" //if we don't do this, we'll never have an exact match.
		if(!("\ref[target]" in faction_src))
			faction_target -= "\ref[target]" //same thing here.
		return faction_check(faction_src, faction_target, TRUE)
	return faction_check(faction, target.faction, FALSE)

/proc/faction_check(list/faction_A, list/faction_B, exact_match)
	var/list/match_list
	if(exact_match)
		match_list = faction_A & faction_B //only items in both lists
		var/length = LAZYLEN(match_list)
		if(length)
			return (length == LAZYLEN(faction_A)) //if they're not the same len(gth) or we don't have a len, then this isn't an exact match.
	else
		match_list = faction_A & faction_B
		return LAZYLEN(match_list)
	return FALSE

/mob/proc/update_sight()
	SEND_SIGNAL(src, COMSIG_MOB_UPDATE_SIGHT)
	sync_lighting_plane_alpha()

/mob/proc/set_vision_override(datum/vision_override/O)
	QDEL_NULL(vision_type)
	if(O) //in case of null
		vision_type = new O
	update_sight()

/mob/proc/sync_lighting_plane_alpha()
	if(!hud_used)
		return
	for(var/atom/movable/screen/plane_master/rendering_plate/lighting/light_plane in hud_used.get_true_plane_masters(RENDER_PLANE_LIGHTING))
		light_plane.set_alpha(lighting_alpha)

	sync_nightvision_screen() //Sync up the overlay used for nightvision to the amount of see_in_dark a mob has. This needs to be called everywhere sync_lighting_plane_alpha() is.

/mob/proc/sync_nightvision_screen()
	var/atom/movable/screen/fullscreen/see_through_darkness/S = screens["see_through_darkness"]
	if(S)
		var/suffix = ""
		var/nighvision_coeff = nightvision
		switch(nighvision_coeff)
			if(3 to 8)
				suffix = "_[nighvision_coeff]"
			if(8 to INFINITY)
				suffix = "_8"

		S.icon_state = "[initial(S.icon_state)][suffix]"

///Adjust the nutrition of a mob
/mob/proc/adjust_nutrition(change, forced)
	nutrition = max(0, nutrition + change)

///Force set the mob nutrition
/mob/proc/set_nutrition(change, forced)
	nutrition = max(0, change)

/mob/clean_blood(clean_hands = TRUE, clean_mask = TRUE, clean_feet = TRUE)
	. = ..()
	if(bloody_hands && clean_hands)
		bloody_hands = 0
		update_inv_gloves()
	if(l_hand)
		if(l_hand.clean_blood())
			update_inv_l_hand()
	if(r_hand)
		if(r_hand.clean_blood())
			update_inv_r_hand()
	if(back)
		if(back.clean_blood())
			update_inv_back()
	if(wear_mask && clean_mask)
		if(wear_mask.clean_blood())
			update_inv_wear_mask()
	if(clean_feet)
		feet_blood_color = null
		qdel(feet_blood_DNA)
		bloody_feet = list(BLOOD_STATE_HUMAN = 0, BLOOD_STATE_XENO = 0,  BLOOD_STATE_NOT_BLOODY = 0)
		blood_state = BLOOD_STATE_NOT_BLOODY
		update_inv_shoes()
	update_icons()	//apply the now updated overlays to the mob

///Makes a call in the context of a different usr. Use sparingly
/world/proc/invoke_callback_with_usr(mob/user_mob, datum/callback/invoked_callback, ...)
	var/temp = usr
	usr = user_mob
	if (length(args) > 2)
		. = invoked_callback.Invoke(arglist(args.Copy(3)))
	else
		. = invoked_callback.Invoke()
	usr = temp


GLOBAL_LIST_INIT(holy_areas, typecacheof(list(
	/area/chapel,
	/area/maintenance/chapel
)))


/mob/proc/holy_check()
	if(!is_type_in_typecache(get_area(src), GLOB.holy_areas))
		return FALSE

	if(!mind)
		return FALSE

	//Allows cult to bypass holy areas once they summon
	var/datum/game_mode/gamemode = SSticker.mode
	if(iscultist(src) && gamemode.cult_objs.cult_status == NARSIE_HAS_RISEN)
		return FALSE

	//Execption for Holy Constructs
	if(isconstruct(src) && !iscultist(src))
		return FALSE

	to_chat(src, span_warning("Your powers are useless on this holy ground."))
	return TRUE


/mob/proc/reset_visibility()
	invisibility = initial(invisibility)
	alpha = initial(alpha)
	add_to_all_human_data_huds()


/mob/proc/make_invisible()
	invisibility = INVISIBILITY_LEVEL_TWO
	alpha = 128
	remove_from_all_data_huds()


/mob/proc/set_stat(new_stat)
	if(new_stat == stat)
		return
	. = stat
	stat = new_stat
	SEND_SIGNAL(src, COMSIG_MOB_STATCHANGE, new_stat, .)
	if(.)
		set_typing_indicator(FALSE)

/**
 * Called when this mob slips over, override as needed
 *
 * weaken_amount - time (in deciseconds) the slip leaves them on the ground
 * slipped_on - optional, what'd we slip on? if not set, we assume they just fell over
 * lube - bitflag of "lube flags", see [mobs.dm] for more information
 * tilesSlipped - how many tiles will we slip through.
 */
/mob/proc/slip(weaken_amount, obj/slipped_on, lube_flags, tilesSlipped)
	SHOULD_CALL_PARENT(TRUE)
	SEND_SIGNAL(src, COMSIG_MOB_SLIPPED, weaken_amount, slipped_on, lube_flags, tilesSlipped)


/mob/proc/IsLying()
	return FALSE


///Ignores specific action slowdowns. Accepts a list of slowdowns.
/mob/proc/add_actionspeed_mod_immunities(source, slowdown_type, update = TRUE)
	if(islist(slowdown_type))
		for(var/listed_type in slowdown_type)
			if(ispath(listed_type))
				listed_type = "[listed_type]" //Path2String
			LAZYADDASSOCLIST(actionspeed_mod_immunities, listed_type, source)
	else
		if(ispath(slowdown_type))
			slowdown_type = "[slowdown_type]" //Path2String
		LAZYADDASSOCLIST(actionspeed_mod_immunities, slowdown_type, source)
	if(update)
		update_actionspeed()


///Unignores specific action slowdowns. Accepts a list of slowdowns.
/mob/proc/remove_actionspeed_mod_immunities(source, slowdown_type, update = TRUE)
	if(islist(slowdown_type))
		for(var/listed_type in slowdown_type)
			if(ispath(listed_type))
				listed_type = "[listed_type]" //Path2String
			LAZYREMOVEASSOC(actionspeed_mod_immunities, listed_type, source)
	else
		if(ispath(slowdown_type))
			slowdown_type = "[slowdown_type]" //Path2String
		LAZYREMOVEASSOC(actionspeed_mod_immunities, slowdown_type, source)
	if(update)
		update_actionspeed()

