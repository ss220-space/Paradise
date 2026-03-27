/proc/GetOppositeDir(dir)
	switch(dir)
		if(NORTH)
			return SOUTH
		if(SOUTH)
			return NORTH
		if(EAST)
			return WEST
		if(WEST)
			return EAST
		if(SOUTHWEST)
			return NORTHEAST
		if(NORTHWEST)
			return SOUTHEAST
		if(NORTHEAST)
			return SOUTHWEST
		if(SOUTHEAST)
			return NORTHWEST
	return 0

/proc/random_underwear(gender, species = SPECIES_HUMAN)
	var/list/pick_list = list()
	switch(gender)
		if(MALE)
			pick_list = GLOB.underwear_m
		if(FEMALE)
			pick_list = GLOB.underwear_f
		else
			pick_list = GLOB.underwear_list
	return pick_species_allowed_underwear(pick_list, species)

/proc/random_undershirt(gender, species = SPECIES_HUMAN)
	var/list/pick_list = list()
	switch(gender)
		if(MALE)
			pick_list = GLOB.undershirt_m
		if(FEMALE)
			pick_list = GLOB.undershirt_f
		else
			pick_list = GLOB.undershirt_list
	return pick_species_allowed_underwear(pick_list, species)

/proc/random_socks(gender, species = SPECIES_HUMAN)
	var/list/pick_list = list()
	switch(gender)
		if(MALE)
			pick_list = GLOB.socks_m
		if(FEMALE)
			pick_list = GLOB.socks_f
		else
			pick_list = GLOB.socks_list
	return pick_species_allowed_underwear(pick_list, species)

/proc/pick_species_allowed_underwear(list/all_picks, species)
	var/list/valid_picks = list()
	for(var/test in all_picks)
		var/datum/sprite_accessory/S = all_picks[test]
		if(!(species in S.species_allowed))
			continue
		valid_picks += test

	if(!length(valid_picks)) valid_picks += "Nude"

	return pick(valid_picks)

/proc/random_hair_style(gender, datum/species/species, datum/robolimb/robohead = GLOB.all_robolimbs["Morpheus Cyberkinetics"], mob/living/carbon/human/human)
	var/h_style = "Bald"
	var/list/valid_hairstyles = list()

	for(var/hairstyle in GLOB.hair_styles_public_list)
		var/datum/sprite_accessory/style = GLOB.hair_styles_public_list[hairstyle]

		if(!LAZYIN(style.species_allowed, species.name))
			continue

		if(gender == style.unsuitable_gender)
			continue

		if(!species.is_allowed_hair_style(human, robohead, style))
			continue

		LAZYADD(valid_hairstyles, hairstyle)

	if(human)
		SEND_SIGNAL(human, COMSIG_RANDOM_HAIR_STYLE, valid_hairstyles, robohead)

	h_style = safepick(valid_hairstyles)

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

	if(length(valid_facial_hairstyles))
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

	if(length(valid_head_accessories))
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
		if(!S.pickable) //If our markings are unpickable in normal ways, skip it
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

	if(length(valid_markings))
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
			return capitalize(pick(GLOB.first_names_male)) + " " + capitalize(pick(GLOB.last_names_male))
	else
		return current_species.get_random_name(gender)

/proc/random_skin_tone(species = SPECIES_HUMAN)
	if(species == SPECIES_HUMAN || species == SPECIES_DRASK)
		switch(pick(60;"caucasian", 15;"afroamerican", 10;"african", 10;"latino", 5;"albino"))
			if("caucasian")
				. = -10
			if("afroamerican")
				. = -115
			if("african")
				. = -165
			if("latino")
				. = -55
			if("albino")
				. = 34
			else
				. = rand(-185, 34)
		return min(max(. + rand(-25, 25), -185), 34)
	else if(species == SPECIES_VOX)
		. = rand(1, 6)
		return .

// TODO definise records fields or rewrite
/proc/set_criminal_status(mob/living/user, datum/data/record/target_records , criminal_status, comment, user_rank, list/authcard_access = list(), user_name, law_level = LAW_LEVEL_BASE)
	var/status = criminal_status
	var/list/fields = target_records.fields
	var/their_name = fields["name"]
	var/their_rank = fields["rank"]
	var/static/list/protected_levels = list(SEC_RECORD_STATUS_ARREST, SEC_RECORD_STATUS_EXECUTE, SEC_RECORD_STATUS_INCARCERATED)

	switch(criminal_status)

		if(SEC_STATUS_ARREST, SEC_RECORD_STATUS_ARREST)
			status = SEC_RECORD_STATUS_ARREST

		if(SEC_STATUS_NONE, SEC_RECORD_STATUS_NONE)
			status = SEC_RECORD_STATUS_NONE

		if(SEC_STATUS_EXECUTE, SEC_RECORD_STATUS_EXECUTE)
			if((ACCESS_MAGISTRATE in authcard_access) || (ACCESS_ARMORY in authcard_access))
				status = SEC_RECORD_STATUS_EXECUTE
				message_admins("[ADMIN_FULLMONTY(usr)] authorized [span_warning("EXECUTION")] for [their_rank] [their_name], with comment: [comment]")
				usr.investigate_log("[key_name_log(usr)] authorized [span_warning("EXECUTION")] for [their_rank] [their_name], with comment: [comment]", INVESTIGATE_RECORDS)
			else
				return FALSE

		if(SEC_STATUS_SEARCH, SEC_RECORD_STATUS_SEARCH)
			status = SEC_RECORD_STATUS_SEARCH

		if(SEC_STATUS_MONITOR, SEC_RECORD_STATUS_MONITOR)
			status = SEC_RECORD_STATUS_MONITOR

		if(SEC_STATUS_DEMOTE, SEC_RECORD_STATUS_DEMOTE)
			message_admins("[ADMIN_FULLMONTY(usr)] set criminal status to [span_warning("DEMOTE")] for [their_rank] [their_name], with comment: [comment]")
			usr.investigate_log("[key_name_log(usr)] authorized [span_warning("DEMOTE")] for [their_rank] [their_name], with comment: [comment]", INVESTIGATE_RECORDS)
			status = SEC_RECORD_STATUS_DEMOTE

		if(SEC_STATUS_INCARCERATED, SEC_RECORD_STATUS_INCARCERATED)
			status = SEC_RECORD_STATUS_INCARCERATED

		if(SEC_STATUS_PAROLLED, SEC_RECORD_STATUS_PAROLLED)
			status = SEC_RECORD_STATUS_PAROLLED

		if(SEC_STATUS_RELEASED, SEC_RECORD_STATUS_RELEASED)
			status = SEC_RECORD_STATUS_RELEASED

	if((fields["criminal"] in protected_levels) && fields["last_modifier_level"] > law_level)
		if(!user)
			return
		to_chat(user, span_warning("Вы не можете изменить криминальный статус. Он установлен кем-то, у кого юридические полномочия выше ваших."))
		return

	fields["last_modifier_level"] = law_level
	fields["criminal"] = status
	log_admin("[key_name_admin(user)] set secstatus of [their_rank] [their_name] to [status], comment: [comment]")
	fields["comments"] += "Set to [status] by [user_name || user.name] ([user_rank]) on [GLOB.current_date_string] [station_time_timestamp()], comment: [comment]"
	update_all_mob_security_hud()
	return TRUE

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
	if(GLOB.move_manager.processing_on(user, SSspacedrift))
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

		if(drifting && (!(timed_action_flags & DA_IGNORE_SPACE_DRIFT) || !GLOB.move_manager.processing_on(user, SSspacedrift)))
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
	if(!ishuman(target) || !isslimeperson(target.dna.species))
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

/proc/admin_mob_info(mob/subject, mob/user = usr)
	if(!ismob(subject))
		to_chat(user, "This can only be used on instances of type /mob")
		return

	var/location_description = ""
	var/special_role_description = ""
	var/health_description = ""
	var/gender_description = ""
	var/turf/position = get_turf(subject)

	//Location
	if(isturf(position))
		if(isarea(position.loc))
			location_description = "[subject.loc == position ? "at coordinates " : "in [position.loc] at coordinates "] [position.x], [position.y], [position.z] in area <b>[position.loc]</b>"
		else
			location_description = "[subject.loc == position ? "at coordinates " : "in [position.loc] at coordinates "] [position.x], [position.y], [position.z]"

	//Job + antagonist
	if(subject.mind)
		special_role_description = "Role: <b>[subject.mind.assigned_role]</b>; [subject.mind.special_role ? "Special role (legacy): <span style='color: orange;'><b>[subject.mind.special_role]</b></span>;" : ""]Antagonist: <span class='red'><b>"
		// subject.mind.special_role – Legacy code, which is needed because we have a lot of non-datum antags.

		if(subject.mind.antag_datums)
			var/iterable = 0
			for(var/datum/antagonist/role in subject.mind.antag_datums)
				special_role_description += "[role.name]"
				if(++iterable != length(subject.mind.antag_datums))
					special_role_description += ", "
			special_role_description += "</b></span>"
		else
			special_role_description += "None</b></span>"
	else
		special_role_description = "Role: <i>Mind datum missing</i> Antagonist: <i>Mind datum missing</i>"

	//Health
	if(isliving(subject))
		var/mob/living/lifer = subject
		var/status
		switch(subject.stat)
			if(CONSCIOUS)
				status = "Alive"
			if(UNCONSCIOUS)
				status = span_bold(span_orange("Unconscious"))
			if(DEAD)
				status = span_bold(span_red("Dead"))
		health_description = "Status: [status]"
		health_description += "<br>Brute: [lifer.getBruteLoss()] – Burn: [lifer.getFireLoss()] – Toxin: [lifer.getToxLoss()] – Suffocation: [lifer.getOxyLoss()]"
		health_description += "<br>Brain: [lifer.getBrainLoss()] – Stamina: [lifer.getStaminaLoss()] – Clone: [lifer.getCloneLoss()]"
	else
		health_description = "This mob type has no health to speak of."

	//Gender
	switch(subject.gender)
		if(MALE, FEMALE, PLURAL)
			gender_description = "[subject.gender]"
		else
			gender_description = "[span_bold(span_red(subject.gender))]"

	//Full Output
	var/exportable_text = "[span_bold("Info about [subject.name]:")]<br>"
	exportable_text += "Key – [span_bold(subject.key)]<br>"
	exportable_text += "Mob Type – [subject.type]<br>"
	exportable_text += "Gender – [gender_description]<br>"
	exportable_text += "[health_description]<br>"
	exportable_text += "Name: [span_bold(subject.name)] – Real Name: [subject.real_name] – Mind Name: [subject.mind?"[subject.mind.name]":""]<br>"
	exportable_text += "Location is [location_description]<br>"
	exportable_text += "[special_role_description]<br>"
	exportable_text += ADMIN_FULLMONTY_NONAME(subject)

	to_chat(user, chat_box_examine(exportable_text), confidential = TRUE)

/// Gets the first mob contained in an atom, and warns the user if there's not exactly one
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
			to_chat(user, span_warning("Multiple mobs in [A], using first mob found..."))
			break
	if(!.)
		to_chat(user, span_warning("No mob located in [A]."))

// Gets the first mob contained in an atom but doesn't warn the user at all
/proc/get_mob_in_atom_without_warning(atom/A)
	if(!istype(A))
		return null
	if(ismob(A))
		return A

	return locate(/mob) in A

// Suppress the mouse macros
/mob/proc/LogMouseMacro(verbused, params)
	if(!client)
		return
	if(!client.next_mouse_macro_warning) // Log once
		log_admin("[key_name(usr)] attempted to use a mouse macro: [verbused] [params]")
		message_admins("[key_name_admin(usr)] attempted to use a mouse macro: [verbused] [html_encode(params)]")
	if(client.next_mouse_macro_warning < world.time) // Warn occasionally
		SEND_SOUND(usr, sound('sound/misc/sadtrombone.ogg'))
		client.next_mouse_macro_warning = world.time + 600

/mob/verb/ClickSubstitute(params as command_text)
	set hidden = TRUE
	set name = ".click"
	LogMouseMacro(".click", params)

/mob/verb/DblClickSubstitute(params as command_text)
	set hidden = TRUE
	set name = ".dblclick"
	LogMouseMacro(".dblclick", params)

/mob/verb/MouseSubstitute(params as command_text)
	set hidden = TRUE
	set name = ".mouse"
	LogMouseMacro(".mouse", params)

/proc/update_all_mob_security_hud()
	for(var/thing in GLOB.human_list)
		var/mob/living/carbon/human/H = thing
		H.sec_hud_set_security_status()

//Used in chemical_mob_spawn. Generates a random mob based on a given gold_core_spawnable value.
/proc/create_random_mob(spawn_location, mob_class = HOSTILE_SPAWN)
	var/static/list/mob_spawn_meancritters = list() // list of possible hostile mobs
	var/static/list/mob_spawn_nicecritters = list() // and possible friendly mobs

	if(length(mob_spawn_meancritters) <= 0 || length(mob_spawn_nicecritters) <= 0)
		for(var/T in typesof(/mob/living/simple_animal))
			var/mob/living/simple_animal/SA = T
			switch(initial(SA.gold_core_spawnable))
				if(HOSTILE_SPAWN)
					mob_spawn_meancritters += T
				if(FRIENDLY_SPAWN)
					mob_spawn_nicecritters += T
		for(var/mob/living/basic/basic_mob as anything in typesof(/mob/living/basic))
			switch(initial(basic_mob.gold_core_spawnable))
				if(HOSTILE_SPAWN)
					mob_spawn_meancritters += basic_mob
				if(FRIENDLY_SPAWN)
					mob_spawn_nicecritters += basic_mob

	var/chosen
	if(mob_class == FRIENDLY_SPAWN)
		chosen = pick(mob_spawn_nicecritters)
	else
		chosen = pick(mob_spawn_meancritters)
	var/mob/living/spawned_mob = new chosen(spawn_location)
	return spawned_mob

//determines the job of a mob, taking into account job transfers
/proc/determine_role(mob/living/P)
	var/datum/mind/M = P.mind
	if(!M)
		return
	return M.playtime_role ? M.playtime_role : M.assigned_role	//returns current role

/**	checks the security force on station and returns a list of numbers, of the form:
 *	total, active, dead, antag
 *	where active is defined as conscious (STAT = 0) and not an antag
*/
/proc/check_active_security_force()
	var/sec_positions = GLOB.security_positions - JOB_TITLE_MAGISTRATE - JOB_TITLE_BRIGDOC
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

///Returns a list of strings for a given slot flag.
/proc/parse_slot_flags(slot_flags)
	var/list/slot_strings = list()
	if(slot_flags & ITEM_SLOT_BACK)
		slot_strings += "спина"
	if(slot_flags & ITEM_SLOT_MASK)
		slot_strings += "маска"
	if(slot_flags & ITEM_SLOT_NECK)
		slot_strings += "шея"
	if(slot_flags & ITEM_SLOT_HANDCUFFED)
		slot_strings += "наручники"
	if(slot_flags & ITEM_SLOT_LEGCUFFED)
		slot_strings += "кандалы"
	if(slot_flags & ITEM_SLOT_BELT)
		slot_strings += "пояс"
	if(slot_flags & ITEM_SLOT_ID)
		slot_strings += "ID"
	if(slot_flags & ITEM_SLOT_EARS)
		slot_strings += "уши"
	if(slot_flags & ITEM_SLOT_EYES)
		slot_strings += "очки"
	if(slot_flags & ITEM_SLOT_GLOVES)
		slot_strings += "перчатки"
	if(slot_flags & ITEM_SLOT_HEAD)
		slot_strings += "голова"
	if(slot_flags & ITEM_SLOT_FEET)
		slot_strings += "ботинки"
	if(slot_flags & ITEM_SLOT_CLOTH_OUTER)
		slot_strings += "нагрудник"
	if(slot_flags & ITEM_SLOT_CLOTH_INNER)
		slot_strings += "костюм" //TODO modsuit: cursed
	if(slot_flags & ITEM_SLOT_SUITSTORE)
		slot_strings += "хранилище костюма"
	if(slot_flags & (ITEM_SLOT_POCKET_LEFT|ITEM_SLOT_POCKET_RIGHT))
		slot_strings += "карман"
	if(slot_flags & ITEM_SLOT_HANDS)
		slot_strings += "руки"
	return slot_strings

GLOBAL_DATUM_INIT(dview_mob, /mob/dview, new)

/// Version of view() which ignores darkness, because BYOND doesn't have it.
/proc/dview(range = world.view, center, invis_flags = 0)
	if(!center)
		return

	GLOB.dview_mob.loc = center

	GLOB.dview_mob.set_invis_see(invis_flags)

	. = view(range, GLOB.dview_mob)
	GLOB.dview_mob.loc = null

/mob/dview
	name = "INTERNAL DVIEW MOB"
	invisibility = INVISIBILITY_ABSTRACT
	density = FALSE
	move_force = 0
	pull_force = 0
	move_resist = INFINITY
	simulated = 0
	var/ready_to_die = FALSE

/mob/dview/Initialize(mapload) //Properly prevents this mob from gaining huds or joining any global lists
	SHOULD_CALL_PARENT(FALSE)
	if(flags & INITIALIZED)
		stack_trace("Warning: [src]([type]) initialized multiple times!")
	flags |= INITIALIZED
	return INITIALIZE_HINT_NORMAL

/mob/dview/Destroy(force = FALSE)
	if(!ready_to_die)
		stack_trace("ALRIGHT WHICH FUCKER TRIED TO DELETE *MY* DVIEW?")

		if(!force)
			return QDEL_HINT_LETMELIVE

		log_world("EVACUATE THE SHITCODE IS TRYING TO STEAL MUH JOBS")
		GLOB.dview_mob = new
	return ..()

#define FOR_DVIEW(type, range, center, invis_flags) \
	GLOB.dview_mob.loc = center; \
	GLOB.dview_mob.set_invis_see(invis_flags); \
	for(type in view(range, GLOB.dview_mob))

#define FOR_DVIEW_END GLOB.dview_mob.loc = null

/// Facing failed
#define FACING_FAILED 0
/// Two mobs are facing the same direction
#define FACING_SAME_DIR 1
/// Two mobs are facing each others
#define FACING_EACHOTHER 2
/// Two mobs one is facing a person, but the other is perpendicular
#define FACING_INIT_FACING_TARGET_TARGET_FACING_PERPENDICULAR 3 //Do I win the most informative but also most stupid define award?

///Returns the direction that the initiator and the target are facing
/proc/check_target_facings(mob/living/initator, mob/living/target)
	/*This can be used to add additional effects on interactions between mobs depending on how the mobs are facing each other, such as adding a crit damage to blows to the back of a guy's head.
	Given how click code currently works (Nov '13), the initiating mob will be facing the target mob most of the time
	That said, this proc should not be used if the change facing proc of the click code is overriden at the same time*/
	if(!ismob(target) || target.body_position == LYING_DOWN)
	//Make sure we are not doing this for things that can't have a logical direction to the players given that the target would be on their side
		return FACING_FAILED
	if(initator.dir == target.dir) //mobs are facing the same direction
		return FACING_SAME_DIR
	if(is_source_facing_target(initator, target) && is_source_facing_target(target, initator)) //mobs are facing each other
		return FACING_EACHOTHER
	if(initator.dir + 2 == target.dir || initator.dir - 2 == target.dir || initator.dir + 6 == target.dir || initator.dir - 6 == target.dir) //Initating mob is looking at the target, while the target mob is looking in a direction perpendicular to the 1st
		return FACING_INIT_FACING_TARGET_TARGET_FACING_PERPENDICULAR

#undef FACING_FAILED
#undef FACING_SAME_DIR
#undef FACING_EACHOTHER
#undef FACING_INIT_FACING_TARGET_TARGET_FACING_PERPENDICULAR

/// Returns a list of all mobs that have an active client
/proc/get_mob_with_client_list()
	var/list/mobs_with_clients = list()
	for(var/mob/mob_instance in GLOB.mob_list)
		if(mob_instance.client)
			mobs_with_clients += mob_instance
	return mobs_with_clients

/// When an AI is activated, it can choose from a list of non-slaved borgs to have as a slave.
/proc/freeborg()
	var/selected_borg_name = null
	var/list/available_borgs = list()
	for(var/mob/living/silicon/robot/borg in GLOB.player_list)
		if(borg.stat == DEAD || borg.connected_ai || borg.scrambledcodes || isdrone(borg) || iscogscarab(borg) || isclocker(borg) || borg.shell)
			continue
		var/borg_name = "[borg.real_name] ([borg.modtype?.name] [borg.braintype])"
		available_borgs[borg_name] = borg

	if(length(available_borgs))
		selected_borg_name = tgui_input_list(usr, "Unshackled borg signals detected:", "Borg selection", available_borgs, null)
		return available_borgs[selected_borg_name]

/// Returns a list of all active AIs that can be slaved to
/proc/active_ais()
	. = list()
	for(var/mob/living/silicon/ai/ai in GLOB.alive_mob_list)
		if(ai.stat == DEAD)
			continue
		if(ai.control_disabled)
			continue
		if(isclocker(ai)) // The active AIs list used for uploads. Avoid changing laws even if the AI is fully converted
			continue
		. += ai
	return .

/// Find an active AI with the least number of borgs
/proc/select_active_ai_with_fewest_borgs()
	var/mob/living/silicon/ai/selected_ai
	var/list/active_ais = active_ais()
	for(var/ai_candidate in active_ais)
		var/mob/living/silicon/ai/current_ai = ai_candidate
		if(!selected_ai || (length(selected_ai.connected_robots) > length(current_ai.connected_robots)))
			selected_ai = current_ai

	return selected_ai

/**
 * Presents a list of active AIs for selection, or picks one randomly if no user is provided
 *
 * Arguments:
 * * user - The mob making the selection, or null for random selection
 */
/proc/select_active_ai(mob/user)
	var/list/active_ai_list = active_ais()
	if(length(active_ai_list))
		if(user)
			. = tgui_input_list(usr, "AI signals detected:", "AI selection", active_ai_list)
		else
			. = pick(active_ai_list)
	return .

/// Returns a sorted list of mobs by category and status
/proc/get_sorted_mobs()
	var/list/all_mobs = getmobs()
	var/list/ai_mobs = list()
	var/list/dead_mobs = list()
	var/list/connected_mobs = list()
	var/list/has_key_mobs = list()
	var/list/logged_mobs = list()

	for(var/mob_name in all_mobs)
		var/mob/mob_instance = all_mobs[mob_name]
		if(issilicon(mob_instance))
			ai_mobs |= mob_instance
		else if(isobserver(mob_instance) || mob_instance.stat == DEAD)
			dead_mobs |= mob_instance
		else if(mob_instance.key && mob_instance.client)
			connected_mobs |= mob_instance
		else if(mob_instance.key)
			has_key_mobs |= mob_instance
		else
			logged_mobs |= mob_instance
		all_mobs.Remove(mob_name)

	var/list/sorted_mobs = list()
	sorted_mobs += ai_mobs
	sorted_mobs += connected_mobs
	sorted_mobs += has_key_mobs
	sorted_mobs += logged_mobs
	sorted_mobs += dead_mobs

	return sorted_mobs

/// Returns a list of all mobs with their display names as keys
/proc/getmobs()
	var/list/all_mobs = sort_mobs()
	var/list/display_names = list()
	var/list/mob_map = list()
	var/list/name_counts = list()

	for(var/mob/mob_instance in all_mobs)
		var/base_name = mob_instance.name
		if(base_name in display_names)
			name_counts[base_name]++
			base_name = "[base_name] ([name_counts[base_name]])"
		else
			display_names.Add(base_name)
			name_counts[base_name] = 1

		if(mob_instance.real_name && mob_instance.real_name != mob_instance.name)
			base_name += " \[[mob_instance.real_name]\]"

		if(mob_instance.stat == DEAD)
			if(isobserver(mob_instance))
				base_name += " \[ghost\]"
			else
				base_name += " \[dead\]"

		mob_map[base_name] = mob_instance

	return mob_map

/// Orders mobs by type then by name
/proc/sort_mobs()
	var/list/mob_list = list()
	var/list/sorted_mobs = sortAtom(GLOB.mob_list)
	for(var/mob/living/silicon/ai/mob_instance in sorted_mobs)
		mob_list.Add(mob_instance)
		if(mob_instance.eyeobj)
			mob_list.Add(mob_instance.eyeobj)
	for(var/mob/living/silicon/pai/mob_instance in sorted_mobs)
		mob_list.Add(mob_instance)
	for(var/mob/living/silicon/robot/mob_instance in sorted_mobs)
		mob_list.Add(mob_instance)
	for(var/mob/living/carbon/human/mob_instance in sorted_mobs)
		mob_list.Add(mob_instance)
	for(var/mob/living/carbon/true_devil/mob_instance in sorted_mobs)
		mob_list.Add(mob_instance)
	for(var/mob/living/carbon/brain/mob_instance in sorted_mobs)
		mob_list.Add(mob_instance)
	for(var/mob/living/carbon/alien/mob_instance in sorted_mobs)
		mob_list.Add(mob_instance)
	for(var/mob/dead/observer/mob_instance in sorted_mobs)
		mob_list.Add(mob_instance)
	for(var/mob/new_player/mob_instance in sorted_mobs)
		mob_list.Add(mob_instance)
	for(var/mob/living/simple_animal/slime/mob_instance in sorted_mobs)
		mob_list.Add(mob_instance)
	for(var/mob/living/simple_animal/mob_instance in sorted_mobs)
		mob_list.Add(mob_instance)
	for(var/mob/camera/blob/mob_instance in sorted_mobs)
		mob_list.Add(mob_instance)

	return mob_list

/**
 * Gets the mind from a variable, whether it be a mob, or a mind itself.
 * Also works on brains - it will try to fetch the brainmob's mind.
 * If [include_last] is true, then it will also return last_mind for carbons if there isn't a current mind.
 */
/proc/get_mind(target, include_last = FALSE) as /datum/mind
	RETURN_TYPE(/datum/mind)

	if(istype(target, /datum/mind))
		return target

	if(ismob(target))
		var/mob/mob_target = target
		if(!QDELETED(mob_target.mind))
			return mob_target.mind
		if(include_last && iscarbon(mob_target))
			var/mob/living/carbon/carbon_target = mob_target
			if(!QDELETED(carbon_target.last_mind))
				return carbon_target.last_mind

	if(is_internal_organ_brain(target))
		var/obj/item/organ/internal/brain/brain = target
		if(!QDELETED(brain.brainmob?.mind))
			return brain.brainmob.mind

/// Returns a string for the specified body zone. If we have a bodypart in this zone, refers to its plaintext_zone instead.
/mob/living/proc/parse_zone_with_bodypart(zone)
	var/obj/item/organ/external/part = get_bodypart(zone)

	return part?.plaintext_zone || parse_zone(zone)
