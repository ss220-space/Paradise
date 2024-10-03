/proc/GetOppositeDir(var/dir)
	switch(dir)
		if(NORTH)     return SOUTH
		if(SOUTH)     return NORTH
		if(EAST)      return WEST
		if(WEST)      return EAST
		if(SOUTHWEST) return NORTHEAST
		if(NORTHWEST) return SOUTHEAST
		if(NORTHEAST) return SOUTHWEST
		if(SOUTHEAST) return NORTHWEST
	return 0

/proc/random_underwear(gender, species = SPECIES_HUMAN)
	var/list/pick_list = list()
	switch(gender)
		if(MALE)	pick_list = GLOB.underwear_m
		if(FEMALE)	pick_list = GLOB.underwear_f
		else		pick_list = GLOB.underwear_list
	return pick_species_allowed_underwear(pick_list, species)

/proc/random_undershirt(gender, species = SPECIES_HUMAN)
	var/list/pick_list = list()
	switch(gender)
		if(MALE)	pick_list = GLOB.undershirt_m
		if(FEMALE)	pick_list = GLOB.undershirt_f
		else		pick_list = GLOB.undershirt_list
	return pick_species_allowed_underwear(pick_list, species)

/proc/random_socks(gender, species = SPECIES_HUMAN)
	var/list/pick_list = list()
	switch(gender)
		if(MALE)	pick_list = GLOB.socks_m
		if(FEMALE)	pick_list = GLOB.socks_f
		else		pick_list = GLOB.socks_list
	return pick_species_allowed_underwear(pick_list, species)

/proc/pick_species_allowed_underwear(list/all_picks, species)
	var/list/valid_picks = list()
	for(var/test in all_picks)
		var/datum/sprite_accessory/S = all_picks[test]
		if(!(species in S.species_allowed))
			continue
		valid_picks += test

	if(!valid_picks.len) valid_picks += "Nude"

	return pick(valid_picks)

/proc/random_hair_style(gender, species = SPECIES_HUMAN, datum/robolimb/robohead, mob/living/carbon/human/H)
	var/h_style = "Bald"
	var/list/valid_hairstyles = list()

	if(species == SPECIES_WRYN) // wryns antennaes now bound to hivenode, no need to change them
		if(H)
			var/obj/item/organ/external/head/head_organ = H.get_organ(BODY_ZONE_HEAD)
			if(head_organ?.h_style)
				return head_organ.h_style
		else
			return "Antennae"

	for(var/hairstyle in GLOB.hair_styles_public_list)
		var/datum/sprite_accessory/S = GLOB.hair_styles_public_list[hairstyle]

		if(hairstyle == "Bald") //Just in case.
			valid_hairstyles += hairstyle
			continue
		if(gender == S.unsuitable_gender)
			continue
		if(species == SPECIES_MACNINEPERSON) //If the user is a species who can have a robotic head...
			if(!robohead)
				robohead = GLOB.all_robolimbs["Morpheus Cyberkinetics"]
			if((species in S.species_allowed) && robohead.is_monitor && ((S.models_allowed && (robohead.company in S.models_allowed)) || !S.models_allowed)) //If this is a hair style native to the user's species, check to see if they have a head with an ipc-style screen and that the head's company is in the screen style's allowed models list.
				valid_hairstyles += hairstyle //Give them their hairstyles if they do.
			else
				if(!robohead.is_monitor && (SPECIES_HUMAN in S.species_allowed)) /*If the hairstyle is not native to the user's species and they're using a head with an ipc-style screen, don't let them access it.
																			But if the user has a robotic humanoid head and the hairstyle can fit humans, let them use it as a wig. */
					valid_hairstyles += hairstyle
		else //If the user is not a species who can have robotic heads, use the default handling.
			if(species in S.species_allowed) //If the user's head is of a species the hairstyle allows, add it to the list.
				valid_hairstyles += hairstyle

	if(valid_hairstyles.len)
		h_style = pick(valid_hairstyles)

	return h_style

/proc/random_facial_hair_style(gender, species = SPECIES_HUMAN, datum/robolimb/robohead)
	var/f_style = "Shaved"
	var/list/valid_facial_hairstyles = list()
	for(var/facialhairstyle in GLOB.facial_hair_styles_list)
		var/datum/sprite_accessory/S = GLOB.facial_hair_styles_list[facialhairstyle]

		if(facialhairstyle == "Shaved") //Just in case.
			valid_facial_hairstyles += facialhairstyle
			continue
		if(gender == S.unsuitable_gender)
			continue
		if(species == SPECIES_MACNINEPERSON) //If the user is a species who can have a robotic head...
			if(!robohead)
				robohead = GLOB.all_robolimbs["Morpheus Cyberkinetics"]
			if((species in S.species_allowed) && robohead.is_monitor && ((S.models_allowed && (robohead.company in S.models_allowed)) || !S.models_allowed)) //If this is a facial hair style native to the user's species, check to see if they have a head with an ipc-style screen and that the head's company is in the screen style's allowed models list.
				valid_facial_hairstyles += facialhairstyle //Give them their facial hairstyles if they do.
			else
				if(!robohead.is_monitor && (SPECIES_HUMAN in S.species_allowed)) /*If the facial hairstyle is not native to the user's species and they're using a head with an ipc-style screen, don't let them access it.
																			But if the user has a robotic humanoid head and the facial hairstyle can fit humans, let them use it as a wig. */
					valid_facial_hairstyles += facialhairstyle
		else //If the user is not a species who can have robotic heads, use the default handling.
			if(species in S.species_allowed) //If the user's head is of a species the facial hair style allows, add it to the list.
				valid_facial_hairstyles += facialhairstyle

	if(valid_facial_hairstyles.len)
		f_style = pick(valid_facial_hairstyles)

	return f_style

/proc/random_head_accessory(species = SPECIES_HUMAN)
	var/ha_style = "None"
	var/list/valid_head_accessories = list()
	for(var/head_accessory in GLOB.head_accessory_styles_list)
		var/datum/sprite_accessory/S = GLOB.head_accessory_styles_list[head_accessory]

		if(!(species in S.species_allowed))
			continue
		valid_head_accessories += head_accessory

	if(valid_head_accessories.len)
		ha_style = pick(valid_head_accessories)

	return ha_style

/proc/random_marking_style(location = "body", species = SPECIES_HUMAN, datum/robolimb/robohead, body_accessory, alt_head, gender = NEUTER)
	var/m_style = "None"
	var/list/valid_markings = list()
	for(var/marking in GLOB.marking_styles_list)
		var/datum/sprite_accessory/body_markings/S = GLOB.marking_styles_list[marking]
		if(S.name == "None")
			valid_markings += marking
			continue
		if(S.marking_location != location)	// If the marking isn't for the location we desire, skip.
			continue
		if(gender == S.unsuitable_gender)	// If the marking isn't allowed for the user's gender, skip.
			continue
		if(!(species in S.species_allowed))	// If the user's head is not of a species the marking style allows, skip it. Otherwise, add it to the list.
			continue
		if(location == "tail")
			if(!body_accessory)
				if(S.tails_allowed)
					continue
			else
				if(!S.tails_allowed || !(body_accessory in S.tails_allowed))
					continue
		if(location == "wing")
			if(!body_accessory)
				if(S.wings_allowed)
					continue
			else
				if(!S.wings_allowed || !(body_accessory in S.wings_allowed))
					continue
		if(location == "head")
			var/datum/sprite_accessory/body_markings/head/M = GLOB.marking_styles_list[S.name]
			if(species == SPECIES_MACNINEPERSON)//If the user is a species that can have a robotic head...
				if(!robohead)
					robohead = GLOB.all_robolimbs["Morpheus Cyberkinetics"]
				if(!(S.models_allowed && (robohead.company in S.models_allowed))) //Make sure they don't get markings incompatible with their head.
					continue
			else if(alt_head && alt_head != "None") //If the user's got an alt head, validate markings for that head.
				if(!("All" in M.heads_allowed) && !(alt_head in M.heads_allowed))
					continue
			else
				if(M.heads_allowed && !("All" in M.heads_allowed))
					continue
		valid_markings += marking

	if(valid_markings.len)
		m_style = pick(valid_markings)

	return m_style

/**
  * Returns a random body accessory for a given species name. Can be null based on is_optional argument.
  *
  * Arguments:
  * * species - The name of the species to filter valid body accessories.
  * * is_optional - Whether *no* body accessory (null) is an option.
 */
/proc/random_body_accessory(species = SPECIES_VULPKANIN, is_optional = FALSE)
	var/list/valid_body_accessories = list()
	if(is_optional)
		valid_body_accessories += null
	if(GLOB.body_accessory_by_species[species])
		for(var/name in GLOB.body_accessory_by_species[species])
			valid_body_accessories.Add(name)
	return length(valid_body_accessories) ? pick(valid_body_accessories) : null

/proc/random_name(gender, species = SPECIES_HUMAN)

	var/datum/species/current_species
	if(species)
		current_species = GLOB.all_species[species]

	if(!current_species || current_species.name == SPECIES_HUMAN)
		if(gender==FEMALE)
			return capitalize(pick(GLOB.first_names_female)) + " " + capitalize(pick(GLOB.last_names_female))
		else
			return capitalize(pick(GLOB.first_names_male)) + " " + capitalize(pick(GLOB.last_names))
	else
		return current_species.get_random_name(gender)

/proc/random_skin_tone(species = SPECIES_HUMAN)
	if(species == SPECIES_HUMAN || species == SPECIES_DRASK)
		switch(pick(60;"caucasian", 15;"afroamerican", 10;"african", 10;"latino", 5;"albino"))
			if("caucasian")		. = -10
			if("afroamerican")	. = -115
			if("african")		. = -165
			if("latino")		. = -55
			if("albino")		. = 34
			else				. = rand(-185, 34)
		return min(max(. + rand(-25, 25), -185), 34)
	else if(species == SPECIES_VOX)
		. = rand(1, 6)
		return .

/proc/skintone2racedescription(tone, species = SPECIES_HUMAN)
	if(species == SPECIES_HUMAN)
		switch(tone)
			if(30 to INFINITY)		return "albino"
			if(20 to 30)			return "pale"
			if(5 to 15)				return "light skinned"
			if(-10 to 5)			return "white"
			if(-25 to -10)			return "tan"
			if(-45 to -25)			return "darker skinned"
			if(-65 to -45)			return "brown"
			if(-INFINITY to -65)	return "black"
			else					return "unknown"
	else if(species == SPECIES_VOX)
		switch(tone)
			if(2)					return "dark green"
			if(3)					return "brown"
			if(4)					return "gray"
			if(5)					return "emerald"
			if(6)					return "azure"
			else					return "green"
	else
		return "unknown"

/proc/age2agedescription(age)
	switch(age)
		if(0 to 1)			return "infant"
		if(1 to 3)			return "toddler"
		if(3 to 13)			return "child"
		if(13 to 19)		return "teenager"
		if(19 to 30)		return "young adult"
		if(30 to 45)		return "adult"
		if(45 to 60)		return "middle-aged"
		if(60 to 70)		return "aging"
		if(70 to INFINITY)	return "elderly"
		else				return "unknown"

/proc/set_criminal_status(mob/living/user, datum/data/record/target_records , criminal_status, comment, user_rank, list/authcard_access = list(), user_name)
	var/status = criminal_status
	var/their_name = target_records.fields["name"]
	var/their_rank = target_records.fields["rank"]
	switch(criminal_status)
		if("arrest", SEC_RECORD_STATUS_ARREST)
			status = SEC_RECORD_STATUS_ARREST
		if("none", SEC_RECORD_STATUS_NONE)
			status = SEC_RECORD_STATUS_NONE
		if("execute", SEC_RECORD_STATUS_EXECUTE)
			if((ACCESS_MAGISTRATE in authcard_access) || (ACCESS_ARMORY in authcard_access))
				status = SEC_RECORD_STATUS_EXECUTE
				message_admins("[ADMIN_FULLMONTY(usr)] authorized <span class='warning'>EXECUTION</span> for [their_rank] [their_name], with comment: [comment]")
				usr.investigate_log("[key_name_log(usr)] authorized <span class='warning'>EXECUTION</span> for [their_rank] [their_name], with comment: [comment]", INVESTIGATE_RECORDS)
			else
				return 0
		if("search", SEC_RECORD_STATUS_SEARCH)
			status = SEC_RECORD_STATUS_SEARCH
		if("monitor", SEC_RECORD_STATUS_MONITOR)
			status = SEC_RECORD_STATUS_MONITOR
		if("demote", SEC_RECORD_STATUS_DEMOTE)
			message_admins("[ADMIN_FULLMONTY(usr)] set criminal status to <span class='warning'>DEMOTE</span> for [their_rank] [their_name], with comment: [comment]")
			usr.investigate_log("[key_name_log(usr)] authorized <span class='warning'>DEMOTE</span> for [their_rank] [their_name], with comment: [comment]", INVESTIGATE_RECORDS)
			status = SEC_RECORD_STATUS_DEMOTE
		if("incarcerated", SEC_RECORD_STATUS_INCARCERATED)
			status = SEC_RECORD_STATUS_INCARCERATED
		if("parolled", SEC_RECORD_STATUS_PAROLLED)
			status = SEC_RECORD_STATUS_PAROLLED
		if("released", SEC_RECORD_STATUS_RELEASED)
			status = SEC_RECORD_STATUS_RELEASED
	target_records.fields["criminal"] = status
	log_admin("[key_name_admin(user)] set secstatus of [their_rank] [their_name] to [status], comment: [comment]")
	target_records.fields["comments"] += "Set to [status] by [user_name || user.name] ([user_rank]) on [GLOB.current_date_string] [station_time_timestamp()], comment: [comment]"
	update_all_mob_security_hud()
	return 1


/**
 * Timed action involving one mob user. Target is optional.
 * Checks that `user` does not move, change hands, get stunned, etc. for the given `delay`.
 *
 * Arguments:
 * * user - The mob performing the action.
 * * delay - The time in deciseconds. Use the SECONDS define for readability. `1 SECONDS` is 10 deciseconds.
 * * target - The target of the action. This is where the progressbar will display.
 * * timed_action_flags - Flags to control the behavior of the timed action.
 * * progress - Whether to display a progress bar `TRUE` or `FALSE`.
 * * extra_checks - Additional checks to perform before the action is executed.
 * * interaction_key - The assoc key under which the do_after is capped, with max_interact_count being the cap. Interaction key will default to target if not set.
 * * max_interact_count - The maximum amount of interactions allowed.
 * * cancel_on_max - If `TRUE` this proc will fail after reaching max_interact_count.
 * * cancel_message - Message shown to the user if cancel_on_max is set to `TRUE` and they exceeds max interaction count. Use empty string ("") to skip default cancel message.
 * * category - Used to apply proper action speed modifier to passed delay.
 *
 * Returns `TRUE` on success, `FALSE` on failure.
 */
/proc/do_after(
	mob/user,
	delay,
	atom/target,
	timed_action_flags = DEFAULT_DOAFTER_IGNORE,
	progress = TRUE,
	datum/callback/extra_checks,
	interaction_key,
	max_interact_count = INFINITY,
	cancel_on_max = FALSE,
	cancel_message = span_warning("Attempt cancelled."),
	category = DA_CAT_ALL,
)
	if(!user)
		return FALSE

	if(!isnum(delay))
		CRASH("do_after was passed a non-number delay: [delay || "null"].")

	if(!interaction_key && target)
		interaction_key = target //Use the direct ref to the target
	if(interaction_key) //Do we have a interaction_key now?
		var/current_interaction_count = LAZYACCESS(user.do_afters, interaction_key) || 0
		if(current_interaction_count >= max_interact_count) //We are at our peak
			if(cancel_on_max)	// we are adding extra one, to catch this on while loop
				LAZYSET(user.do_afters, interaction_key, current_interaction_count + 1)
			return FALSE
		LAZYSET(user.do_afters, interaction_key, current_interaction_count + 1)

	var/atom/user_loc = user.loc
	var/atom/target_loc = target?.loc

	var/drifting = FALSE
	if(SSmove_manager.processing_on(user, SSspacedrift))
		drifting = TRUE

	var/holding = user.get_active_hand()
	var/obj/item/gripper/gripper = holding
	var/gripper_check = FALSE
	if(!(timed_action_flags & DA_IGNORE_EMPTY_GRIPPER) && istype(gripper) && !gripper.isEmpty())
		gripper_check = TRUE

	if(!(timed_action_flags & DA_IGNORE_SLOWDOWNS))
		delay *= user.get_actionspeed_by_category(category)

	var/datum/progressbar/progbar
	var/endtime = world.time + delay
	var/starttime = world.time

	// progress bar will not show up if there is no delay at all
	if(progress && user.client && starttime < endtime)
		progbar = new(user, delay, target || user)

	SEND_SIGNAL(user, COMSIG_DO_AFTER_BEGAN)

	. = TRUE

	while(world.time < endtime)
		stoplag(1)

		if(!QDELETED(progbar))
			progbar.update(world.time - starttime)

		if(QDELETED(user))
			. = FALSE
			break

		if(cancel_on_max && interaction_key)
			var/current_interaction_count = LAZYACCESS(user.do_afters, interaction_key) || 0
			if(current_interaction_count > max_interact_count)
				// we need to reduce count by one, since its just a marker
				LAZYSET(user.do_afters, interaction_key, current_interaction_count - 1)
				if(cancel_message)
					to_chat(user, "[cancel_message]")
				. = FALSE
				break

		if(drifting && (!(timed_action_flags & DA_IGNORE_SPACE_DRIFT) || !SSmove_manager.processing_on(user, SSspacedrift)))
			drifting = FALSE
			user_loc = user.loc

		if((!(timed_action_flags & DA_IGNORE_USER_LOC_CHANGE) && !drifting && user.loc != user_loc) \
			|| (!(timed_action_flags & DA_IGNORE_HELD_ITEM) && user.get_active_hand() != holding) \
			|| (!(timed_action_flags & DA_IGNORE_CONSCIOUSNESS) && user.stat) \
			|| (!(timed_action_flags & DA_IGNORE_LYING) && user.IsLying()) \
			|| (!(timed_action_flags & DA_IGNORE_INCAPACITATED) && HAS_TRAIT_NOT_FROM(user, TRAIT_INCAPACITATED, STAT_TRAIT)) \
			|| (!(timed_action_flags & DA_IGNORE_RESTRAINED) && HAS_TRAIT(user, TRAIT_RESTRAINED)) \
			|| (gripper_check && gripper?.isEmpty()) \
			|| (extra_checks && !extra_checks.Invoke()))
			. = FALSE
			break

		if(target && (user != target) && \
			(QDELETED(target) || (!(timed_action_flags & DA_IGNORE_TARGET_LOC_CHANGE) && target.loc != target_loc)))
			. = FALSE
			break

	if(!QDELETED(progbar))
		progbar.end_progress()

	if(interaction_key)
		var/reduced_interaction_count = (LAZYACCESS(user.do_afters, interaction_key) || 0) - 1
		if(reduced_interaction_count > 0) // Not done yet!
			LAZYSET(user.do_afters, interaction_key, reduced_interaction_count)
			return .
		// all out, let's clear er out fully
		LAZYREMOVE(user.do_afters, interaction_key)

	SEND_SIGNAL(user, COMSIG_DO_AFTER_ENDED)


/proc/is_species(A, species_datum)
	. = FALSE
	if(ishuman(A))
		var/mob/living/carbon/human/H = A
		if(H.dna && istype(H.dna.species, species_datum))
			. = TRUE


/proc/is_monkeybasic(mob/living/carbon/human/target)
	return ishuman(target) && target.dna.species.is_monkeybasic	// we deserve a runtime if a human has no DNA


/proc/is_evolvedslime(mob/living/carbon/human/target)
	if(!ishuman(target) || !istype(target.dna.species, /datum/species/slime))
		return FALSE
	var/datum/species/slime/species = target.dna.species
	return species.evolved_slime


/proc/spawn_atom_to_turf(spawn_type, target, amount, admin_spawn=FALSE, list/extra_args)
	var/turf/T = get_turf(target)
	if(!T)
		CRASH("attempt to spawn atom type: [spawn_type] in nullspace")

	var/list/new_args = list(T)
	if(extra_args)
		new_args += extra_args

	for(var/j in 1 to amount)
		var/atom/X = new spawn_type(arglist(new_args))
		if(admin_spawn)
			X.flags |= ADMIN_SPAWNED

/proc/admin_mob_info(mob/M, mob/user = usr)
	if(!ismob(M))
		to_chat(user, "This can only be used on instances of type /mob")
		return

	var/location_description = ""
	var/special_role_description = ""
	var/health_description = ""
	var/gender_description = ""
	var/turf/T = get_turf(M)

	//Location
	if(isturf(T))
		if(isarea(T.loc))
			location_description = "([M.loc == T ? "at coordinates " : "in [M.loc] at coordinates "] [T.x], [T.y], [T.z] in area <b>[T.loc]</b>)"
		else
			location_description = "([M.loc == T ? "at coordinates " : "in [M.loc] at coordinates "] [T.x], [T.y], [T.z])"

	//Job + antagonist
	if(M.mind)
		special_role_description = "Role: <b>[M.mind.assigned_role]</b>; Antagonist: <font color='red'><b>[M.mind.special_role]</b></font>; Has been rev: [(M.mind.has_been_rev)?"Yes":"No"]"
	else
		special_role_description = "Role: <i>Mind datum missing</i> Antagonist: <i>Mind datum missing</i>; Has been rev: <i>Mind datum missing</i>;"

	//Health
	if(isliving(M))
		var/mob/living/L = M
		var/status
		switch(M.stat)
			if(CONSCIOUS)
				status = "Alive"
			if(UNCONSCIOUS)
				status = "<font color='orange'><b>Unconscious</b></font>"
			if(DEAD)
				status = "<font color='red'><b>Dead</b></font>"
		health_description = "Status = [status]"
		health_description += "<BR>Oxy: [L.getOxyLoss()] - Tox: [L.getToxLoss()] - Fire: [L.getFireLoss()] - Brute: [L.getBruteLoss()] - Clone: [L.getCloneLoss()] - Brain: [L.getBrainLoss()]"
	else
		health_description = "This mob type has no health to speak of."

	//Gender
	switch(M.gender)
		if(MALE, FEMALE)
			gender_description = "[M.gender]"
		else
			gender_description = "<font color='red'><b>[M.gender]</b></font>"

	to_chat(user, "<b>Info about [M.name]:</b> ")
	to_chat(user, "Mob type = [M.type]; Gender = [gender_description] Damage = [health_description]")
	to_chat(user, "Name = <b>[M.name]</b>; Real_name = [M.real_name]; Mind_name = [M.mind?"[M.mind.name]":""]; Key = <b>[M.key]</b>;")
	to_chat(user, "Location = [location_description];")
	to_chat(user, "[special_role_description]")
	to_chat(user, "(<a href='byond://?src=[usr.UID()];priv_msg=[M.client?.ckey]'>PM</a>) ([ADMIN_PP(M,"PP")]) ([ADMIN_VV(M,"VV")]) ([ADMIN_TP(M,"TP")]) ([ADMIN_SM(M,"SM")]) ([ADMIN_FLW(M,"FLW")])")

// Gets the first mob contained in an atom, and warns the user if there's not exactly one
/proc/get_mob_in_atom_with_warning(atom/A, mob/user = usr)
	if(!istype(A))
		return null
	if(ismob(A))
		return A

	. = null
	for(var/mob/M in A)
		if(!.)
			. = M
		else
			to_chat(user, "<span class='warning'>Multiple mobs in [A], using first mob found...</span>")
			break
	if(!.)
		to_chat(user, "<span class='warning'>No mob located in [A].</span>")

// Gets the first mob contained in an atom but doesn't warn the user at all
/proc/get_mob_in_atom_without_warning(atom/A)
	if(!istype(A))
		return null
	if(ismob(A))
		return A

	return locate(/mob) in A

/mob/proc/LogMouseMacro(verbused, params)
	if(!client)
		return
	if(!client.next_mouse_macro_warning) // Log once
		log_and_message_admins("attempted to use a mouse macro: [verbused] [html_encode(params)]")
	if(client.next_mouse_macro_warning < world.time) // Warn occasionally
		usr << 'sound/misc/sadtrombone.ogg'
		client.next_mouse_macro_warning = world.time + 600
/mob/verb/ClickSubstitute(params as command_text)
	set hidden = 1
	set name = ".click"
	LogMouseMacro(".click", params)
/mob/verb/DblClickSubstitute(params as command_text)
	set hidden = 1
	set name = ".dblclick"
	LogMouseMacro(".dblclick", params)
/mob/verb/MouseSubstitute(params as command_text)
	set hidden = 1
	set name = ".mouse"
	LogMouseMacro(".mouse", params)

/proc/update_all_mob_security_hud()
	for(var/thing in GLOB.human_list)
		var/mob/living/carbon/human/H = thing
		H.sec_hud_set_security_status()


/proc/getviewsize(view)
	if(!view) // Just to avoid any runtimes that could otherwise cause constant disconnect loops.
		stack_trace("Missing value for 'view' in getviewsize(), defaulting to world.view!")
		view = world.view

	if(isnum(view))
		var/totalviewrange = (view < 0 ? -1 : 1) + 2 * view
		return list(totalviewrange, totalviewrange)
	else
		var/list/viewrangelist = splittext(view, "x")
		return list(text2num(viewrangelist[1]), text2num(viewrangelist[2]))


/proc/in_view_range(mob/user, atom/A)
	var/list/view_range = getviewsize(user.client.view)
	var/turf/source = get_turf(user)
	var/turf/target = get_turf(A)
	return ISINRANGE(target.x, source.x - view_range[1], source.x + view_range[1]) && ISINRANGE(target.y, source.y - view_range[1], source.y + view_range[1])


//Used in chemical_mob_spawn. Generates a random mob based on a given gold_core_spawnable value.
/proc/create_random_mob(spawn_location, mob_class = HOSTILE_SPAWN)
	var/static/list/mob_spawn_meancritters = list() // list of possible hostile mobs
	var/static/list/mob_spawn_nicecritters = list() // and possible friendly mobs

	if(mob_spawn_meancritters.len <= 0 || mob_spawn_nicecritters.len <= 0)
		for(var/T in typesof(/mob/living/simple_animal))
			var/mob/living/simple_animal/SA = T
			switch(initial(SA.gold_core_spawnable))
				if(HOSTILE_SPAWN)
					mob_spawn_meancritters += T
				if(FRIENDLY_SPAWN)
					mob_spawn_nicecritters += T

	var/chosen
	if(mob_class == FRIENDLY_SPAWN)
		chosen = pick(mob_spawn_nicecritters)
	else
		chosen = pick(mob_spawn_meancritters)
	var/mob/living/simple_animal/C = new chosen(spawn_location)
	return C

//determines the job of a mob, taking into account job transfers
/proc/determine_role(mob/living/P)
	var/datum/mind/M = P.mind
	if(!M)
		return
	return M.playtime_role ? M.playtime_role : M.assigned_role	//returns current role

/**	checks the security force on station and returns a list of numbers, of the form:
 * 	total, active, dead, antag
 * 	where active is defined as conscious (STAT = 0) and not an antag
*/
/proc/check_active_security_force()
	var/sec_positions = GLOB.security_positions - JOB_TITLE_JUDGE - JOB_TITLE_BRIGDOC
	var/total = 0
	var/active = 0
	var/dead = 0
	var/antag = 0
	for(var/p in GLOB.human_list)	//contains only human mobs, so no type check needed
		var/mob/living/carbon/human/player = p	//need to tell it what type it is or we can't access stat without the dreaded :
		if(determine_role(player) in sec_positions)
			total++
			if(player.stat == DEAD)
				dead++
				continue
			if(isAntag(player))
				antag++
				continue
			if(player.stat == CONSCIOUS)
				active++
	return list(total, active, dead, antag)


/**
  * Safe ckey getter
  *
  * Should be used whenever broadcasting public information about a mob,
  * as this proc will make a best effort to hide the users ckey if they request it.
  * It will first check the mob for a client, then use the mobs last ckey as a directory lookup.
  * If a client cant be found to check preferences on, it will just show as DC'd.
  * This proc should only be used for public facing stuff, not administration related things.
  *
  * Arguments:
  * * M - Mob to get a safe ckey of
  */
/proc/safe_get_ckey(mob/M)
	var/client/C = null
	if(M.client)
		C = M.client
	else if(M.last_known_ckey in GLOB.directory)
		C = GLOB.directory[M.last_known_ckey]

	// Now we see if we need to respect their privacy
	var/out_ckey
	if(C)
		if(C.prefs.toggles2 & PREFTOGGLE_2_ANON)
			out_ckey = "(Anon)"
		else
			out_ckey = C.ckey
	else
		// No client. Just mark as DC'd.
		out_ckey = "(Disconnected)"

	return out_ckey

