/datum/ai_controller/dog
	blackboard = list(\
		BB_SIMPLE_CARRY_ITEM = null,\
		BB_FETCH_TARGET = null,\
		BB_FETCH_DELIVER_TO = null,\
		BB_DOG_FRIENDS = list(),\
		BB_FETCH_IGNORE_LIST = list(),\
		BB_DOG_ORDER_MODE = DOG_COMMAND_NONE,\
		BB_DOG_PLAYING_DEAD = FALSE,\
		BB_DOG_HARASS_TARGET = null)
	ai_movement = /datum/ai_movement/jps
	planning_subtrees = list(/datum/ai_planning_subtree/dog)
	COOLDOWN_DECLARE(heel_cooldown)
	COOLDOWN_DECLARE(command_cooldown)

/datum/ai_controller/dog/process(delta_time)
	if(ismob(pawn))
		var/mob/living/living_pawn = pawn
		movement_delay = living_pawn.cached_multiplicative_slowdown
	return ..()

/datum/ai_controller/dog/TryPossessPawn(atom/new_pawn)
	if(!isliving(new_pawn))
		return AI_CONTROLLER_INCOMPATIBLE

	RegisterSignal(new_pawn, COMSIG_ATOM_ATTACK_HAND, PROC_REF(on_attack_hand))
	RegisterSignal(new_pawn, COMSIG_PARENT_EXAMINE, PROC_REF(on_examined))
	RegisterSignal(new_pawn, COMSIG_CLICK_ALT, PROC_REF(check_altclicked))
	RegisterSignal(new_pawn, list(COMSIG_MOB_DEATH, COMSIG_QDELETING), PROC_REF(on_death))
	RegisterSignal(SSdcs, COMSIG_GLOB_CARBON_THROW_THING, PROC_REF(listened_throw))
	return ..() //Run parent at end

/datum/ai_controller/dog/UnpossessPawn(destroy)
	var/obj/item/carried_item = blackboard[BB_SIMPLE_CARRY_ITEM]
	if(carried_item)
		pawn.visible_message(span_warning("[pawn] выплевывает [carried_item]."))
		carried_item.forceMove(pawn.drop_location())
		blackboard[BB_SIMPLE_CARRY_ITEM] = null
	UnregisterSignal(pawn, list(COMSIG_ATOM_ATTACK_HAND, COMSIG_PARENT_EXAMINE, COMSIG_CLICK_ALT, COMSIG_MOB_DEATH, COMSIG_GLOB_CARBON_THROW_THING, COMSIG_QDELETING))
	return ..() //Run parent at end

/datum/ai_controller/dog/able_to_run()
	var/mob/living/living_pawn = pawn

	if(IS_DEAD_OR_INCAP(living_pawn))
		return FALSE
	return ..()

/datum/ai_controller/dog/get_access()
	var/mob/living/simple_animal/simple_pawn = pawn
	if(!istype(simple_pawn))
		return
	if(simple_pawn.pcollar)
		var/obj/item/clothing/accessory/petcollar/collar = simple_pawn.pcollar
		return collar.GetAccess()

/datum/ai_controller/dog/PerformIdleBehavior(delta_time)
	var/mob/living/living_pawn = pawn
	if(!isturf(living_pawn.loc) || living_pawn.pulledby)
		return

	// if we were just ordered to heel, chill out for a bit
	if(!COOLDOWN_FINISHED(src, heel_cooldown))
		return

	// if we're just ditzing around carrying something, occasionally print a message so people know we have something
	if(blackboard[BB_SIMPLE_CARRY_ITEM] && SPT_PROB(5, delta_time))
		var/obj/item/carry_item = blackboard[BB_SIMPLE_CARRY_ITEM]
		living_pawn.visible_message(span_notice("[living_pawn] мягко впивается зубами в [carry_item.declent_ru(ACCUSATIVE)]в [genderize_ru(living_pawn.gender, "его", "её", "его", "их")] пасти."))

		if(SPT_PROB(5, delta_time) && (living_pawn.mobility_flags & MOBILITY_MOVE))
			var/move_dir = pick(GLOB.alldirs)
			living_pawn.Move(get_step(living_pawn, move_dir), move_dir)
		else if(SPT_PROB(10, delta_time))
			living_pawn.manual_emote("[living_pawn] [pick("гоняется за своим хвостом!", "ходит кругами.")]")
			living_pawn.AddComponent(/datum/component/spinny)

/// Someone has thrown something, see if it's someone we care about and start listening to the thrown item so we can see if we want to fetch it when it lands
/datum/ai_controller/dog/proc/listened_throw(datum/source, mob/living/carbon/carbon_thrower)
	SIGNAL_HANDLER
	if(blackboard[BB_FETCH_TARGET] || blackboard[BB_FETCH_DELIVER_TO] || blackboard[BB_DOG_PLAYING_DEAD]) // we're already busy
		return
	if(!COOLDOWN_FINISHED(src, heel_cooldown))
		return
	if(!pawn.can_see(carbon_thrower, length = AI_DOG_VISION_RANGE))
		return
	var/obj/item/thrown_thing = carbon_thrower.get_active_hand()
	if(!isitem(thrown_thing))
		return
	if(blackboard[BB_FETCH_IGNORE_LIST][WEAKREF(thrown_thing)])
		return

	RegisterSignal(thrown_thing, COMSIG_MOVABLE_THROW_LANDED, PROC_REF(listen_throw_land))

/// A throw we were listening to has finished, see if it's in range for us to try grabbing it
/datum/ai_controller/dog/proc/listen_throw_land(obj/item/thrown_thing, datum/thrownthing/throwing_datum)
	SIGNAL_HANDLER

	UnregisterSignal(thrown_thing, list(COMSIG_QDELETING, COMSIG_MOVABLE_THROW_LANDED))
	if(!istype(thrown_thing) || !isturf(thrown_thing.loc) || !pawn.can_see(thrown_thing, length = AI_DOG_VISION_RANGE))
		return

	current_movement_target = thrown_thing
	blackboard[BB_FETCH_TARGET] = thrown_thing
	blackboard[BB_FETCH_DELIVER_TO] = throwing_datum.thrower
	queue_behavior(/datum/ai_behavior/fetch)

/// Someone's interacting with us by hand, see if they're being nice or mean
/datum/ai_controller/dog/proc/on_attack_hand(datum/source, mob/living/user)
	SIGNAL_HANDLER

	if(user.a_intent == INTENT_HARM)
		unfriend(user)
	else
		if(prob(AI_DOG_PET_FRIEND_PROB))
			befriend(user)
		// if the dog has something in their mouth that they're not bringing to someone for whatever reason, have them drop it when pet by a friend
		var/list/friends = blackboard[BB_DOG_FRIENDS]
		if(blackboard[BB_SIMPLE_CARRY_ITEM] && !current_movement_target && friends[WEAKREF(user)])
			var/obj/item/carried_item = blackboard[BB_SIMPLE_CARRY_ITEM]
			pawn.visible_message(span_warning("[pawn] бросает [carried_item] к ногам [user]!"))
			// maybe have a dedicated proc for dropping things
			carried_item.forceMove(get_turf(user))
			blackboard[BB_SIMPLE_CARRY_ITEM] = null

/// Someone is being nice to us, let's make them a friend!
/datum/ai_controller/dog/proc/befriend(mob/living/new_friend)
	var/list/friends = blackboard[BB_DOG_FRIENDS]
	var/datum/weakref/friend_ref = WEAKREF(new_friend)
	if(friends[friend_ref])
		return
	if(in_range(pawn, new_friend))
		new_friend.visible_message(
			span_notice("<b>[pawn]</b> дружелюбно облизывает [new_friend]!"),
			span_notice("[pawn] дружелюбно облизывает вас!"))
		friends[friend_ref] = TRUE
		RegisterSignal(new_friend, COMSIG_MOB_POINTED, PROC_REF(check_point))
		RegisterSignal(new_friend, COMSIG_MOB_TRY_SPEECH, PROC_REF(check_verbal_command))

/// Someone is being mean to us, take them off our friends (add actual enemies behavior later)
/datum/ai_controller/dog/proc/unfriend(mob/living/ex_friend)
	var/list/friends = blackboard[BB_DOG_FRIENDS]
	friends -= WEAKREF(ex_friend)
	UnregisterSignal(ex_friend, list(COMSIG_MOB_POINTED, COMSIG_MOB_TRY_SPEECH))

/// Someone is looking at us, if we're currently carrying something then show what it is, and include a message if they're our friend
/datum/ai_controller/dog/proc/on_examined(datum/source, mob/user, list/examine_text)
	SIGNAL_HANDLER

	var/obj/item/carried_item = blackboard[BB_SIMPLE_CARRY_ITEM]
	if(carried_item)
		examine_text += span_notice("В [genderize_ru(pawn.gender, "его", "её", "его", "их")] пасти находится [carried_item].")
	if(blackboard[BB_DOG_FRIENDS][WEAKREF(user)])
		var/mob/living/living_pawn = pawn
		if(!IS_DEAD_OR_INCAP(living_pawn))
			examine_text += span_notice("Кажется, [genderize_ru(living_pawn.gender, "он", "она", "оно", "они")] рад[genderize_ru(living_pawn.gender, "", "а", "о", "ы")] вас видеть!")

/// If we died, drop anything we were carrying
/datum/ai_controller/dog/proc/on_death(mob/living/ol_yeller)
	SIGNAL_HANDLER

	var/obj/item/carried_item = blackboard[BB_SIMPLE_CARRY_ITEM]
	if(!carried_item)
		return

	ol_yeller.visible_message(span_warning("[ol_yeller] отпускает  [carried_item] из своей пасти..."))
	carried_item.forceMove(ol_yeller.drop_location())
	blackboard[BB_SIMPLE_CARRY_ITEM] = null

// next section is regarding commands

/// Someone alt clicked us, see if they're someone we should show the radial command menu to
/datum/ai_controller/dog/proc/check_altclicked(datum/source, mob/living/clicker)
	SIGNAL_HANDLER

	if(!COOLDOWN_FINISHED(src, command_cooldown))
		return
	if(!istype(clicker) || !blackboard[BB_DOG_FRIENDS][WEAKREF(clicker)])
		return
	INVOKE_ASYNC(src, PROC_REF(command_radial), clicker)

/// Show the command radial menu
/datum/ai_controller/dog/proc/command_radial(mob/living/clicker)
	var/list/commands = list(
		COMMAND_HEEL = image(icon = 'icons/testing/turf_analysis.dmi', icon_state = "red_arrow"),
		COMMAND_FETCH = image(icon = 'icons/mob/actions/actions.dmi', icon_state = "summons_old"),
		COMMAND_ATTACK = image(icon = 'icons/effects/effects.dmi', icon_state = "bite"),
		COMMAND_DIE = image(icon = 'icons/mob/pets.dmi', icon_state = "puppy_dead")
		)

	var/choice = show_radial_menu(clicker, pawn, commands, custom_check = CALLBACK(src, PROC_REF(check_menu), clicker))
	if(!choice || !check_menu(clicker))
		return
	set_command_mode(clicker, choice)

/datum/ai_controller/dog/proc/check_menu(mob/user)
	if(!istype(user))
		CRASH("A non-mob is trying to issue an order to [pawn].")
	if(user.incapacitated() || !user.can_see(pawn, length = AI_DOG_VISION_RANGE))
		return FALSE
	return TRUE

/// One of our friends said something, see if it's a valid command, and if so, take action
/datum/ai_controller/dog/proc/check_verbal_command(mob/speaker, message)
	SIGNAL_HANDLER

	if(!blackboard[BB_DOG_FRIENDS][WEAKREF(speaker)])
		return

	if(!COOLDOWN_FINISHED(src, command_cooldown))
		return

	var/mob/living/living_pawn = pawn
	if(IS_DEAD_OR_INCAP(living_pawn))
		return

	var/spoken_text = message // probably should check for full words
	var/command
	if(findtext(spoken_text, "сид") || findtext(spoken_text, "стоп"))
		command = COMMAND_HEEL
	else if(findtext(spoken_text, "принес") || findtext(spoken_text, "апорт"))
		command = COMMAND_FETCH
	else if(findtext(spoken_text, "атак") || findtext(spoken_text, "бой") || findtext(spoken_text, "фас"))
		command = COMMAND_ATTACK
	else if(findtext(spoken_text, "мертв") || findtext(spoken_text, "умр") || findtext(spoken_text, "умир"))
		command = COMMAND_DIE
	else
		return

	if(!pawn.can_see(speaker, length = AI_DOG_VISION_RANGE))
		return
	set_command_mode(speaker, command)

/// Whether we got here via radial menu or a verbal command, this is where we actually process what our new command will be
/datum/ai_controller/dog/proc/set_command_mode(mob/commander, command)
	COOLDOWN_START(src, command_cooldown, AI_DOG_COMMAND_COOLDOWN)

	switch(command)
		// heel: stop what you're doing, relax and try not to do anything for a little bit
		if(COMMAND_HEEL)
			pawn.visible_message(span_notice("[pawn] садится на задние лапы, ожидая новой команды от [commander]."))
			blackboard[BB_DOG_ORDER_MODE] = DOG_COMMAND_NONE
			COOLDOWN_START(src, heel_cooldown, AI_DOG_HEEL_DURATION)
			CancelActions()
		// fetch: whatever the commander points to, try and bring it back
		if(COMMAND_FETCH)
			pawn.visible_message(span_notice("[pawn] в предвкушении готовится дернуться с места!"))
			blackboard[BB_DOG_ORDER_MODE] = DOG_COMMAND_FETCH
		// attack: harass whoever the commander points to
		if(COMMAND_ATTACK)
			pawn.visible_message(span_warning("[pawn] настораживается и начинает агрессивно рычать.")) // imagine getting intimidated by a corgi
			blackboard[BB_DOG_ORDER_MODE] = DOG_COMMAND_ATTACK
		if(COMMAND_DIE)
			blackboard[BB_DOG_ORDER_MODE] = DOG_COMMAND_NONE
			CancelActions()
			queue_behavior(/datum/ai_behavior/play_dead)

/// Someone we like is pointing at something, see if it's something we might want to interact with (like if they might want us to fetch something for them)
/datum/ai_controller/dog/proc/check_point(mob/pointing_friend, atom/movable/pointed_movable)
	SIGNAL_HANDLER

	var/mob/living/living_pawn = pawn
	if(IS_DEAD_OR_INCAP(living_pawn))
		return

	if(!COOLDOWN_FINISHED(src, command_cooldown))
		return
	if(pointed_movable == pawn || blackboard[BB_FETCH_TARGET] || !istype(pointed_movable) || blackboard[BB_DOG_ORDER_MODE] == DOG_COMMAND_NONE) // busy or no command
		return
	if(!pawn.can_see(pointing_friend, length = AI_DOG_VISION_RANGE) || !pawn.can_see(pointed_movable, length = AI_DOG_VISION_RANGE))
		return

	COOLDOWN_START(src, command_cooldown, AI_DOG_COMMAND_COOLDOWN)

	switch(blackboard[BB_DOG_ORDER_MODE])
		if(DOG_COMMAND_FETCH)
			if(!isitem(pointed_movable) || pointed_movable.anchored)
				return
			var/obj/item/pointed_item = pointed_movable
			if(pointed_item.obj_flags & ABSTRACT)
				return
			pawn.visible_message(span_notice("[pawn] следует за указаниями [pointing_friend] и радостно гафкает!"))
			current_movement_target = pointed_movable
			blackboard[BB_FETCH_TARGET] = pointed_movable
			blackboard[BB_FETCH_DELIVER_TO] = pointing_friend
			if(living_pawn.buckled)
				queue_behavior(/datum/ai_behavior/resist)//in case they are in bed or something
			queue_behavior(/datum/ai_behavior/fetch)
		if(DOG_COMMAND_ATTACK)
			pawn.visible_message(span_notice("[pawn] следует за указаниями [pointing_friend] и агрессивно рычит!"))
			current_movement_target = pointed_movable
			blackboard[BB_DOG_HARASS_TARGET] = WEAKREF(pointed_movable)
			if(living_pawn.buckled)
				queue_behavior(/datum/ai_behavior/resist)//in case they are in bed or something
			queue_behavior(/datum/ai_behavior/harass)
