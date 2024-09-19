#define THEFT_FLAG_HIGHRISK 	1
#define THEFT_FLAG_UNIQUE 		2
#define THEFT_FLAG_HARD 		3
#define THEFT_FLAG_MEDIUM 		4
#define THEFT_FLAG_STRUCTURE	5
#define THEFT_FLAG_ANIMAL		6
#define THEFT_FLAG_COLLECT 		7


GLOBAL_LIST_EMPTY(all_objectives)

/// Stores objective [names][/datum/objective/var/name] as list keys, and their corresponding typepaths as list values.
GLOBAL_LIST_EMPTY(admin_objective_list)

/datum/objective
	/**
	 * Proper name of the objective. Not player facing, only shown to admins when adding objectives.
	 * Leave as null (or override to null) if you don't want admins to see that objective as a viable one to add (such as the mindslave objective).
	 */
	var/name
	/**
	 * Owner of the objective.
	 * Note that it's fine to set this directly, but when needing to check completion of the objective or otherwise check conditions on the owner of the objective,
	 * always use `get_owners()`, and check against ALL the owners. `get_owners()` accounts for objectives that may be team based and therefore have multiple owners.
	 */
	var/datum/mind/owner
	/// The target of the objective.
	var/datum/mind/target
	/// The team the objective belongs to, if any.
	var/datum/team/team
	/// What the owner is supposed to do to complete the objective.
	var/explanation_text = "Nothing"
	/// If the objective should have `find_target()` called for it.
	var/needs_target = TRUE
	/// If they are focused on a particular number. Steal objectives have their own counter.
	var/target_amount = 0
	/// If the objective has been completed.
	var/completed = FALSE
	/// If the objective is compatible with martyr objective, i.e. if you can still do it while dead.
	var/martyr_compatible = FALSE
	/// If the objective goes cryo, do we check for a new objective or ignore it
	var/check_cryo = TRUE


/datum/objective/New(text, datum/team/team_to_join)
	GLOB.all_objectives += src
	if(text)
		explanation_text = text
	if(team_to_join)
		team = team_to_join


/datum/objective/Destroy(force)
	for(var/datum/mind/user in get_owners())
		user.remove_objective(src)
	GLOB.all_objectives -= src
	owner = null
	target = null
	team = null
	return ..()


/datum/objective/proc/check_completion()
	return completed


/**
 * Get all owners of the objective, including ones from the objective's team, if it has one.
 *
 * Use this over directly referencing `owner` in most cases.
 */
/datum/objective/proc/get_owners()
	. = length(team?.members) ? team.members.Copy() : list()
	if(owner)
		. += owner


/**
 * Originally an Objective proc. Changed to a datum proc to allow for the proc to be run on minds, before the objective is created
 */
/datum/proc/is_invalid_target(datum/mind/possible_target)
	if(!ishuman(possible_target.current))
		return TARGET_INVALID_NOT_HUMAN

	if(possible_target.current.stat == DEAD)
		return TARGET_INVALID_DEAD

	if(!possible_target.key || !possible_target.current?.ckey)
		return TARGET_INVALID_NOCKEY

	if(possible_target.current)
		var/turf/current_location = get_turf(possible_target.current)
		if(current_location && !is_level_reachable(current_location.z))
			return TARGET_INVALID_UNREACHABLE

	if(isgolem(possible_target.current))
		return TARGET_INVALID_GOLEM

	if(possible_target.offstation_role)
		return TARGET_INVALID_EVENT


/datum/objective/is_invalid_target(datum/mind/possible_target)
	. = ..()
	if(.)
		return

	for(var/datum/mind/player in get_owners())
		if(possible_target == player)
			return TARGET_INVALID_IS_OWNER

		for(var/datum/objective/objective in player.get_all_objectives())
			if(objective.target == possible_target)
				return TARGET_INVALID_IS_TARGET

	if(SEND_SIGNAL(src, COMSIG_OBJECTIVE_CHECK_VALID_TARGET, possible_target) & OBJECTIVE_INVALID_TARGET)
		return TARGET_INVALID_BLACKLISTED


/datum/objective/proc/find_target(list/target_blacklist)
	if(!needs_target)
		return

	var/list/possible_targets = list()
	for(var/datum/mind/possible_target in SSticker.minds)
		if(is_invalid_target(possible_target) || (possible_target in target_blacklist))
			continue
		possible_targets |= possible_target

	if(length(possible_targets))
		target = pick(possible_targets)

	SEND_SIGNAL(src, COMSIG_OBJECTIVE_TARGET_FOUND, target)


/**
  * Called when the objective's target goes to cryo.
  */
/datum/objective/proc/on_target_cryo()
	if(!check_cryo)
		return

	alarm_changes()
	SSticker.mode.victims.Remove(target)
	target = null
	INVOKE_ASYNC(src, PROC_REF(post_target_cryo), get_owners())


/datum/objective/proc/alarm_changes()
	for(var/datum/mind/user in get_owners())
		to_chat(user.current, span_userdanger("<BR>You get the feeling your target is no longer within reach. Time for Plan [pick("A","B","C","D","X","Y","Z")]. Objectives updated!"))
		SEND_SOUND(user.current, 'sound/ambience/alarm4.ogg')


/**
  * Called a tick after when the objective's target goes to cryo.
  */
/datum/objective/proc/post_target_cryo(list/owners)

	find_target(existing_targets_blacklist())

	if(!target?.current)
		qdel(src)

	for(var/datum/mind/user in owners)
		var/list/messages = list()
		messages.Add(user.prepare_announce_objectives(FALSE))
		to_chat(user.current, chat_box_red(messages.Join("<br>")))



/**
 * Borgs, brains, AIs, etc count as dead for traitor objectives
 */
/datum/objective/proc/is_special_dead(mob/target_current, check_silicon = TRUE)
	if(check_silicon && issilicon(target_current))
		return TRUE
	return isbrain(target_current) || istype(target_current, /mob/living/simple_animal/spiderbot)


/**
 * Proc that forms a list of targets that are already exist for objective owners.
 */
/datum/objective/proc/existing_targets_blacklist()
	. = list()

	for(var/datum/mind/player in get_owners())
		if(QDELETED(player.current))
			continue

		if(istype(src, /datum/objective/steal))
			for(var/datum/objective/steal/steal_objective in player.get_all_objectives())
				if(!steal_objective.steal_target?.id)
					continue
				. |= steal_objective.steal_target.id
		else
			for(var/datum/objective/general_objective in player.get_all_objectives())
				if(istype(general_objective, /datum/objective/steal) || !general_objective.target)
					continue
				. |= general_objective.target


/datum/objective/assassinate
	name = "Assassinate"
	martyr_compatible = TRUE


/datum/objective/assassinate/find_target(list/target_blacklist)
	..()
	if(target?.current)
		explanation_text = "Assassinate [target.current.real_name], the [target.assigned_role]."
		if(!(target in SSticker.mode.victims))
			SSticker.mode.victims.Add(target)
	else
		explanation_text = "Free Objective"

	return target


/datum/objective/assassinate/check_completion()
	if(target && target.current)
		if(target.current.stat == DEAD)
			return TRUE

		if(is_special_dead(target.current)) //Borgs/brains/AIs count as dead for traitor objectives. --NeoFite
			return TRUE

		if(!target.current.ckey)
			return TRUE

		return FALSE

	return TRUE


/datum/objective/mutiny
	name = "Mutiny"
	martyr_compatible = TRUE


/datum/objective/mutiny/find_target(list/target_blacklist)
	..()
	if(target && target.current)
		explanation_text = "Exile or assassinate [target.current.real_name], the [target.assigned_role]."
	else
		explanation_text = "Free Objective"
	return target


/datum/objective/mutiny/check_completion()
	if(target && target.current)
		if(target.current.stat == DEAD || !ishuman(target.current) || !target.current.ckey || !target.current.client)
			return TRUE

		var/turf/T = get_turf(target.current)
		if(T && !is_station_level(T.z))			//If they leave the station they count as dead for this
			return TRUE

		return FALSE

	return TRUE


/datum/objective/mutiny/on_target_cryo()
	// We don't want revs to get objectives that aren't for heads of staff. Letting
	// them win or lose based on cryo is silly so we remove the objective.
	qdel(src)


/datum/objective/maroon
	name = "Maroon"
	martyr_compatible = TRUE


/datum/objective/maroon/find_target(list/target_blacklist)
	..()
	update_explanation()
	return target


/datum/objective/maroon/proc/update_explanation()
	if(target?.current)
		explanation_text = "Prevent from escaping alive or free [target.current.real_name], the [target.assigned_role]."
	else
		explanation_text = "Free Objective"


/datum/objective/maroon/check_completion()
	if(target && target.current)
		if(target.current.stat == DEAD)
			return TRUE

		if(!target.current.ckey)
			return TRUE

		if(is_special_dead(target.current))
			return TRUE

		if(isalien(target.current))
			return TRUE

		if(isslime(target.current))
			return TRUE

		var/mob/living/carbon/carbon_target = target.current
		if(istype(carbon_target) && carbon_target.handcuffed)
			return TRUE

		var/turf/T = get_turf(target.current)
		if(is_admin_level(T.z))
			return FALSE

		return TRUE

	return TRUE


/datum/objective/debrain //I want braaaainssss
	name = "Debrain"
	martyr_compatible = FALSE


/datum/objective/debrain/is_invalid_target(datum/mind/possible_target)
	. = ..()
	if(.)
		return
	// If the target is a changeling, then it's an invalid target. Since changelings can not be debrained.
	if(ischangeling(possible_target))
		return TARGET_INVALID_CHANGELING


/datum/objective/debrain/find_target(list/target_blacklist)
    ..()
    if(target?.current)
        var/obj/item/organ/internal/brains = target.current.get_organ_slot(INTERNAL_ORGAN_BRAIN)
        explanation_text = "Steal the [brains.name] of [target.current.real_name], the [target.assigned_role]."
        if(!(target in SSticker.mode.victims))
            SSticker.mode.victims.Add(target)
    else
        explanation_text = "Free Objective"
    return target


/datum/objective/debrain/check_completion()
	if(!target) // If it's a free objective.
		return TRUE

	if(!target.current || !isbrain(target.current))
		return FALSE

	if(isnymph(target.current))
		return FALSE

	for(var/datum/mind/player in get_owners())
		if(QDELETED(player.current))
			continue // Maybe someone who's alive has the brain.

		if(target.current in player.current.GetAllContents())
			return TRUE

	return FALSE


/datum/objective/pain_hunter
	name = "pain hunter"
	martyr_compatible = TRUE
	var/damage_need = 200
	var/damage_type = BRUTE
	var/damage_target = 0
	var/saved_target_name = "Безымянный"
	var/saved_target_role = "без роли"
	var/saved_own_text = "лично"
	/// Time when 10 minutes timet started. To moment of its end, target have to exist and live.
	var/start_of_completing = 0
	/// Loop timer for checking targer and objective completetion.
	var/checking_timer = null
	/// Color of numbers, red - fail, green - success, white - in process
	var/obj_process_color = ""

/datum/objective/pain_hunter/proc/take_damage(take_damage, take_damage_type)
	if(damage_type != take_damage_type)
		return
	if(target.current.stat == DEAD)
		return
	damage_target += take_damage
	update_explain_text()


/datum/objective/pain_hunter/New(text)
	. = ..()
	update_explain_text()
	checking_timer = addtimer(CALLBACK(src, PROC_REF(target_check)), 30 SECONDS, TIMER_UNIQUE | TIMER_LOOP | TIMER_STOPPABLE | TIMER_DELETE_ME)


/datum/objective/pain_hunter/find_target(list/target_blacklist)
	..()
	if(target && ishuman(target.current))
		update_find_objective()
	else
		explanation_text = "Free Objective"
		completed = TRUE
		deltimer(checking_timer)
		checking_timer = null
	return target


/datum/objective/pain_hunter/proc/update_find_objective()
	saved_target_name = target.current.real_name
	saved_target_role = target.assigned_role
	damage_target = 0
	random_type()
	update_explain_text()


/datum/objective/pain_hunter/proc/update_explain_text()
	explanation_text = "Преподать урок и [saved_own_text] нанести [saved_target_name], [saved_target_role], не менее [damage_need] единиц [damage_explain()]. Цель должна выжить. \nПрогресс: <span class = '[obj_process_color]'>[damage_target]/[damage_need]</span>"

/datum/objective/pain_hunter/on_target_cryo()
	if(completed)
		return
	if(start_of_completing && !isnull(checking_timer))
		completed = TRUE
		target = null
		deltimer(checking_timer)
		obj_process_color = "green"
		checking_timer = null
		update_explain_text()
		for(var/datum/mind/user in get_owners())
			var/list/messages = list()
			messages.Add(user.prepare_announce_objectives(FALSE))
			to_chat(user.current, chat_box_red(messages.Join("<br>")))
	else
		..()


/datum/objective/pain_hunter/proc/target_check()
	if(!start_of_completing)
		if(damage_target >= damage_need)
			start_of_completing = world.time
			return
		if(!ishuman(target.current))
			target = null
			find_target(existing_targets_blacklist())
			alarm_changes()
			for(var/datum/mind/user in get_owners())
				var/list/messages = list()
				messages.Add(user.prepare_announce_objectives(FALSE))
				to_chat(user.current, chat_box_red(messages.Join("<br>")))
	else
		if((world.time - start_of_completing) >= 10	MINUTES)
			if(target && ishuman(target.current) && target.current.stat != DEAD)
				completed = TRUE
				obj_process_color = "green"
			else
				obj_process_color = "red"
			update_explain_text()
			for(var/datum/mind/user in get_owners())
				var/list/messages = list()
				messages.Add(user.prepare_announce_objectives(FALSE))
				to_chat(user.current, chat_box_red(messages.Join("<br>")))
			deltimer(checking_timer)
			checking_timer = null


/datum/objective/pain_hunter/proc/random_type()
	damage_need = rand(1, 2) * 100
	if(prob(70))
		damage_type = BRUTE
	else
		damage_type = BURN
		if(prob(20) && !ismachineperson(target.current))
			saved_own_text = "любым источником"
			damage_type = TOX
			damage_need = rand(2, 4) * 50


/datum/objective/pain_hunter/proc/damage_explain()
	var/damage_explain = damage_type
	switch(damage_type)
		if(BRUTE)
			damage_explain = "ушибов"
		if(BURN)
			damage_explain = "ожогов"
		if(TOX)
			damage_explain = "токсинов"
	return damage_explain

/datum/objective/pain_hunter/check_completion()
	if(start_of_completing && target && ishuman(target.current) && target.current.stat != DEAD)
		return TRUE
	else
		return completed

/datum/objective/protect //The opposite of killing a dude.
	name = "Protect"
	martyr_compatible = TRUE


/datum/objective/protect/find_target(list/target_blacklist)
	..()
	if(target && target.current)
		explanation_text = "Protect [target.current.real_name], the [target.assigned_role]."
	else
		explanation_text = "Free Objective"
	return target


/datum/objective/protect/check_completion()
	if(!target) //If it's a free objective.
		return TRUE

	if(target.current)
		if(target.current.stat == DEAD)
			return FALSE
		if(isbrain(target.current))
			return FALSE
		if(!iscarbon(target.current))
			return FALSE
		return TRUE
	return FALSE


/datum/objective/protect/mindslave //subytpe for mindslave implants
	needs_target = FALSE // To be clear, this objective should have a target, but it will always be manually set to the mindslaver through the mindslave antag datum.


// This objective should only be given to a single owner. We can use `owner` and not `get_owners()`.
/datum/objective/protect/mindslave/on_target_cryo()
	if(owner?.current)
		SEND_SOUND(owner.current, sound('sound/ambience/alarm4.ogg'))
		owner.remove_antag_datum(/datum/antagonist/mindslave)
		to_chat(owner.current, "<BR><span class='userdanger'>You notice that your master has entered cryogenic storage, and revert to your normal self.</span>")
		log_admin("[key_name(owner.current)]'s mindslave master has cryo'd, and is no longer a mindslave.")
		message_admins("[key_name_admin(owner.current)]'s mindslave master has cryo'd, and is no longer a mindslave.") //Since they were on antag hud earlier, this feels important to log
		qdel(src)


/datum/objective/protect/contractor //subtype for support units

/datum/objective/hijack
	name = "Hijack"
	martyr_compatible = FALSE //Technically you won't get both anyway.
	explanation_text = "Hijack the shuttle by escaping on it with no loyalist Nanotrasen crew on board and free. \
	Syndicate agents, other enemies of Nanotrasen, cyborgs, pets, and cuffed/restrained hostages may be allowed on the shuttle alive."
	needs_target = FALSE


/datum/objective/hijack/check_completion()
	if(SSshuttle.emergency.mode < SHUTTLE_ENDGAME)
		return FALSE

	for(var/datum/mind/player in get_owners())
		if(QDELETED(player.current) || player.current.stat != CONSCIOUS || issilicon(player.current) || get_area(player.current) != SSshuttle.emergency.areaInstance)
			return FALSE

	return SSshuttle.emergency.is_hijacked()


/datum/objective/hijackclone
	name = "Hijack (with clones)"
	explanation_text = "Hijack the shuttle by ensuring only you (or your copies) escape."
	martyr_compatible = FALSE
	needs_target = FALSE


/**
 * This objective should only be given to a single owner, because the "copies" can only copy one person.
 * We're fine to use `owner` instead of `get_owners()`.
 */
/datum/objective/hijackclone/check_completion()
	if(SSshuttle.emergency.mode < SHUTTLE_ENDGAME || !owner.current)
		return FALSE

	var/area/shuttle_area = SSshuttle.emergency.areaInstance

	for(var/mob/living/player in GLOB.player_list) //Make sure nobody else is onboard
		if(player.mind && player.mind != owner)
			if(player.stat != DEAD)
				if(issilicon(player))
					continue
				if(get_area(player) == shuttle_area)
					if(player.real_name != owner.current.real_name && !istype(get_turf(player.mind.current), /turf/simulated/floor/shuttle/objective_check))
						return FALSE

	for(var/mob/living/player in GLOB.player_list) //Make sure at least one of you is onboard
		if(player.mind && player.mind != owner)
			if(player.stat != DEAD)
				if(issilicon(player))
					continue
				if(get_area(player) == shuttle_area)
					if(player.real_name == owner.current.real_name && !istype(get_turf(player.mind.current), /turf/simulated/floor/shuttle/objective_check))
						return TRUE

	return FALSE


/datum/objective/block
	name = "Silicon Supremacy"
	explanation_text = "Do not allow any lifeforms, be it organic or synthetic to escape on the shuttle alive. AIs, Cyborgs, Maintenance drones, and pAIs are not considered alive."
	martyr_compatible = TRUE
	needs_target = FALSE


/datum/objective/block/check_completion()
	for(var/datum/mind/player in get_owners())
		if(!player.current || !issilicon(player.current))
			return FALSE

	if(SSticker.mode.station_was_nuked)
		return TRUE

	if(SSshuttle.emergency.mode < SHUTTLE_ENDGAME)
		return FALSE

	var/area/shuttle_area = SSshuttle.emergency.areaInstance

	for(var/mob/living/player in GLOB.player_list)
		if(issilicon(player))
			continue // If they're silicon, they're not considered alive, skip them.

		if(player.mind && player.stat != DEAD)
			if(get_area(player) == shuttle_area)
				return FALSE // If there are any other organic mobs on the shuttle, you failed the objective.

	return TRUE


/datum/objective/escape
	name = "Escape"
	explanation_text = "Escape on the shuttle or an escape pod alive and free."
	needs_target = FALSE


/datum/objective/escape/check_completion()
	var/list/owners = get_owners()

	for(var/datum/mind/player in owners)
		// These are mandatory conditions, they should come before the freebie conditions below.
		if(QDELETED(player.current) || player.current.stat == DEAD || is_special_dead(player.current))
			return FALSE

	if(SSticker.force_ending) // This one isn't their fault, so lets just assume good faith.
		return TRUE

	if(SSticker.mode.station_was_nuked) // If they escaped the blast somehow, let them win.
		return TRUE

	if(SSshuttle.emergency.mode < SHUTTLE_ENDGAME)
		return FALSE

	for(var/datum/mind/player in owners)
		// Fails traitors if they are in the shuttle brig -- Polymorph
		var/turf/location = get_turf(player.current)
		if(istype(location, /turf/simulated/floor/shuttle/objective_check) || istype(location, /turf/simulated/floor/mineral/plastitanium/red/brig))
			return FALSE

		if(!location.onCentcom() && !location.onSyndieBase())
			return FALSE

	return TRUE


/datum/objective/escape/escape_with_identity
	name = "Escape With Identity"
	needs_target = TRUE
	/// Stored because the target's `[mob/var/real_name]` can change over the course of the round.
	var/target_real_name
	/// If the objective has an special objective tied to it.
	var/datum/objective/special_objective


/datum/objective/escape/escape_with_identity/New(text, datum/team/team_to_join, datum/objective/_special_objective)
	..()
	if(!_special_objective)
		return
	special_objective = _special_objective
	RegisterSignal(special_objective, COMSIG_OBJECTIVE_TARGET_FOUND, PROC_REF(special_objective_found_target))
	RegisterSignal(special_objective, COMSIG_OBJECTIVE_CHECK_VALID_TARGET, PROC_REF(special_objective_checking_target))


/datum/objective/escape/escape_with_identity/Destroy(force)
	special_objective = null
	return ..()


/datum/objective/escape/escape_with_identity/is_invalid_target(datum/mind/possible_target)
	if(..() || !possible_target.current.client)
		return TRUE
	// If the target is geneless, then it's an invalid target.
	return HAS_TRAIT(possible_target.current, TRAIT_NO_DNA)


/datum/objective/escape/escape_with_identity/find_target(list/target_blacklist)
	if(special_objective?.target)
		target = special_objective.target
	else
		..()

	if(target && target.current)
		target_real_name = target.current.real_name
		explanation_text = "Escape on the shuttle or an escape pod with the identity of [target_real_name], the [target.assigned_role] while wearing [target.p_their()] identification card."
	else
		explanation_text = "Free Objective"


/datum/objective/escape/escape_with_identity/proc/special_objective_checking_target(datum/source, datum/mind/possible_target)
	SIGNAL_HANDLER
	if(!possible_target.current.client || HAS_TRAIT(possible_target.current, TRAIT_NO_DNA))
		// Stop our linked special objective from choosing a clientless/geneless target.
		return OBJECTIVE_INVALID_TARGET
	return OBJECTIVE_VALID_TARGET


/datum/objective/escape/escape_with_identity/proc/special_objective_found_target(datum/source, datum/mind/new_target)
	SIGNAL_HANDLER
	if(!new_target)
		// The special objective was unable to find a new target after the old one cryo'd as was qdel'd. We're on our own.
		special_objective = null
	find_target()


/datum/objective/escape/escape_with_identity/on_target_cryo()
	if(special_objective)
		return // Our special objective will handle this.
	..()


/datum/objective/escape/escape_with_identity/post_target_cryo(list/owners)
	if(special_objective)
		return // Our special objective will handle this.
	..()


/**
 * This objective should only be given to a single owner since only 1 person can have the ID card of the target.
 * We're fine to use `owner` instead of `get_owners()`.
 */
/datum/objective/escape/escape_with_identity/check_completion()
	if(!target_real_name)
		return TRUE

	if(!ishuman(owner.current))
		return FALSE

	var/mob/living/carbon/human/human_owner = owner.current
	if(..())
		if(human_owner.dna.real_name == target_real_name)
			if(human_owner.get_id_name() == target_real_name)
				return TRUE

	return FALSE


/datum/objective/die
	name = "Glorious Death"
	explanation_text = "Die a glorious death."
	needs_target = FALSE


/**
 * Glorious team death might be funny but we really have no need to use `get_owners()` here.
 */
/datum/objective/die/check_completion()
	if(!owner.current || owner.current.stat == DEAD || isbrain(owner.current))
		return TRUE

	if(issilicon(owner.current) && owner.original_mob_name && owner.current.name != owner.original_mob_name)
		return TRUE

	return FALSE


/datum/objective/survive
	name = "Survive"
	explanation_text = "Stay alive until the end."
	needs_target = FALSE


/datum/objective/survive/check_completion()
	for(var/datum/mind/player in get_owners())
		if(QDELETED(player.current) || player.current.stat == DEAD || is_special_dead(player.current, check_silicon = FALSE))
			return FALSE
		if(issilicon(player.current) && !player.is_original_mob(player.current))
			return FALSE
	return TRUE


/datum/objective/nuclear
	name = "Nuke station"
	explanation_text = "Destroy the station with a nuclear device."
	martyr_compatible = TRUE
	needs_target = FALSE


/datum/objective/steal
	name = "Steal Item"
	var/datum/theft_objective/steal_target
	martyr_compatible = FALSE
	var/type_theft_flag = THEFT_FLAG_HIGHRISK


/datum/objective/steal/proc/get_theft_list_objectives(type_theft_flag)
	switch(type_theft_flag)
		if(THEFT_FLAG_HIGHRISK)
			return GLOB.potential_theft_objectives
		if(THEFT_FLAG_HARD)
			return GLOB.potential_theft_objectives_hard
		if(THEFT_FLAG_MEDIUM)
			return GLOB.potential_theft_objectives_medium
		if(THEFT_FLAG_COLLECT)
			return GLOB.potential_theft_objectives_collect
		if(THEFT_FLAG_UNIQUE)
			return subtypesof(/datum/theft_objective/unique)
		if(THEFT_FLAG_STRUCTURE)
			return GLOB.potential_theft_objectives_structure
		if(THEFT_FLAG_ANIMAL)
			return GLOB.potential_theft_objectives_animal
		else
			return GLOB.potential_theft_objectives


/datum/objective/steal/find_target(list/target_blacklist)
	var/list/temp = get_theft_list_objectives(type_theft_flag)
	var/list/theft_types = temp.Copy()
	while(!steal_target && length(theft_types))
		var/thefttype = pick_n_take(theft_types)
		var/datum/theft_objective/new_theft_objective = new thefttype

		var/has_invalid_owner = FALSE
		for(var/datum/mind/player in get_owners())
			if((player.assigned_role in new_theft_objective.protected_jobs))
				has_invalid_owner = TRUE
				break

		if(has_invalid_owner)
			continue

		if(!new_theft_objective.check_objective_conditions())
			continue

		if(new_theft_objective.id in target_blacklist)
			continue

		steal_target = new_theft_objective
		steal_target.generate_explanation_text(src)

		if(steal_target.special_equipment)
			give_kit(steal_target.special_equipment)

		return TRUE

	explanation_text = "Free Objective."
	return FALSE


/datum/objective/steal/check_completion()
	if(!steal_target)
		return TRUE // Free Objective
	return steal_target.check_completion(get_owners())


/datum/objective/steal/proc/select_target()
	var/list/possible_items_all = get_theft_list_objectives(type_theft_flag)
	if(type_theft_flag == THEFT_FLAG_HIGHRISK)
		possible_items_all |= "custom"
	var/new_target = input("Select target:", "Objective target", null) as null|anything in possible_items_all
	if(!new_target)
		return FALSE
	if(new_target == "custom")
		var/datum/theft_objective/O=new
		O.typepath = input("Select type:","Type") as null|anything in typesof(/obj/item)
		if(!O.typepath)
			return FALSE
		var/tmp_obj = new O.typepath
		var/custom_name = tmp_obj:name
		qdel(tmp_obj)
		O.name = sanitize(copytext_char(input("Enter target name:", "Objective target", custom_name) as text|null,1,MAX_NAME_LEN))
		if(!O.name)
			return FALSE
		steal_target = O
		explanation_text = "Украсть [O.name]."
	else
		steal_target = new new_target
		steal_target.generate_explanation_text(src)
		if(steal_target.special_equipment)
			give_kit(steal_target.special_equipment)
	if(steal_target)
		return TRUE
	return FALSE


/datum/objective/steal/proc/give_kit(obj/item/item_path)
	var/item = new item_path
	var/list/slots = list(
		"backpack" = ITEM_SLOT_BACKPACK,
		"left pocket" = ITEM_SLOT_POCKET_LEFT,
		"right pocket" = ITEM_SLOT_POCKET_RIGHT,
		"left hand" = ITEM_SLOT_HAND_LEFT,
		"right hand" = ITEM_SLOT_HAND_RIGHT,
	)

	for(var/datum/mind/player in get_owners())
		var/mob/living/carbon/human/human_owner = player.current
		var/where = human_owner.equip_in_one_of_slots(item, slots)
		if(where)
			to_chat(human_owner, "<br><br><span class='info'>In your [where] is a box containing <b>items and instructions</b> to help you with your steal objective.</span><br>")
		else
			to_chat(human_owner, span_userdanger("Unfortunately, you weren't able to get a stealing kit. This is very bad and you should adminhelp immediately (press F1)."))
			message_admins("[ADMIN_LOOKUPFLW(human_owner)] Failed to spawn with their [item_path] theft kit.")
			qdel(item)


/datum/objective/steal/hard
	type_theft_flag = THEFT_FLAG_HARD


/datum/objective/steal/medium
	type_theft_flag = THEFT_FLAG_MEDIUM


/datum/objective/steal/structure
	type_theft_flag = THEFT_FLAG_STRUCTURE


/datum/objective/steal/animal
	type_theft_flag = THEFT_FLAG_ANIMAL


/datum/objective/steal/collect
	type_theft_flag = THEFT_FLAG_COLLECT


/datum/objective/steal/exchange
	martyr_compatible = FALSE
	needs_target = FALSE


/datum/objective/steal/exchange/proc/set_faction(var/faction,var/otheragent)
	target = otheragent
	var/datum/theft_objective/unique/targetinfo
	if(faction == "red")
		targetinfo = new /datum/theft_objective/unique/docs_blue
	else if(faction == "blue")
		targetinfo = new /datum/theft_objective/unique/docs_red
	explanation_text = "Acquire [targetinfo.name] held by [target.current.real_name], the [target.assigned_role] and syndicate agent"
	steal_target = targetinfo


/datum/objective/steal/exchange/backstab

/datum/objective/steal/exchange/backstab/set_faction(var/faction)
	var/datum/theft_objective/unique/targetinfo
	if(faction == "red")
		targetinfo = new /datum/theft_objective/unique/docs_red
	else if(faction == "blue")
		targetinfo = new /datum/theft_objective/unique/docs_blue
	explanation_text = "Do not give up or lose [targetinfo.name]."
	steal_target = targetinfo

/datum/objective/download
	needs_target = FALSE

/datum/objective/download/proc/gen_amount_goal()
	target_amount = rand(10,20)
	explanation_text = "Download [target_amount] research levels."
	return target_amount


/datum/objective/download/check_completion()
	return FALSE


/datum/objective/capture
	needs_target = FALSE

/datum/objective/capture/proc/gen_amount_goal()
	target_amount = rand(5,10)
	explanation_text = "Accumulate [target_amount] capture points."
	return target_amount


/datum/objective/capture/check_completion()//Basically runs through all the mobs in the area to determine how much they are worth.
	return FALSE


/datum/objective/absorb
	name = "Absorb DNA"
	needs_target = FALSE


/datum/objective/absorb/proc/gen_amount_goal(lowbound = 4, highbound = 6)
	target_amount = rand(lowbound, highbound)

	if(SSticker)
		var/n_p = 1 //autowin
		if(SSticker.current_state == GAME_STATE_SETTING_UP)
			for(var/mob/new_player/player in GLOB.player_list)
				if(player.client && player.ready && !(player.mind in get_owners()))
					if(player.client.prefs && (player.client.prefs.species == SPECIES_MACNINEPERSON)) // Special check for species that can't be absorbed. No better solution.
						continue
					n_p++

		else if(SSticker.current_state == GAME_STATE_PLAYING)
			for(var/mob/living/carbon/human/player in GLOB.player_list)
				if(HAS_TRAIT(player, TRAIT_NO_DNA))
					continue

				if(player.client && !(player.mind in SSticker.mode.changelings) && !(player.mind in get_owners()))
					n_p++

		target_amount = min(target_amount, n_p)

	explanation_text = "Acquire [target_amount] compatible genomes. The 'Extract DNA Sting' can be used to stealthily get genomes without killing somebody."
	return target_amount


/datum/objective/absorb/check_completion()
	for(var/datum/mind/user in get_owners())
		var/datum/antagonist/changeling/cling = user?.has_antag_datum(/datum/antagonist/changeling)
		if(cling?.absorbed_dna && (cling.absorbed_count >= target_amount))
			return TRUE
	return FALSE


/datum/objective/destroy
	name = "Destroy AI"
	martyr_compatible = TRUE
	var/target_real_name


/datum/objective/destroy/find_target(list/target_blacklist)
	var/list/possible_targets = active_ais()
	var/mob/living/silicon/ai/target_ai = safepick(possible_targets)
	target = target_ai?.mind
	if(target?.current)
		target_real_name = target.current.real_name
		explanation_text = "Destroy [target_real_name], the AI."
	else
		explanation_text = "Free Objective"
	return target


/datum/objective/destroy/check_completion()
	if(target && target.current)
		if(target.current.stat == DEAD || is_away_level(target.current.z) || !target.current.ckey)
			return TRUE
		return FALSE
	return TRUE


/datum/objective/steal_five_of_type
	name = "Steal Five Items"
	explanation_text = "Steal at least five items!"
	needs_target = FALSE
	var/list/wanted_items = list()


/datum/objective/steal_five_of_type/New()
	..()
	wanted_items = typecacheof(wanted_items)


/datum/objective/steal_five_of_type/check_completion()
	var/stolen_count = 0
	var/list/owners = get_owners()
	var/list/all_items = list()

	for(var/datum/mind/player in owners)
		if(!isliving(player.current))
			continue
		all_items += player.current.GetAllContents()	//this should get things in cheesewheels, books, etc.

	for(var/obj/item in all_items) //Check for wanted items
		if(is_type_in_typecache(item, wanted_items))
			stolen_count++

	return stolen_count >= 5


/datum/objective/steal_five_of_type/summon_guns
	explanation_text = "Steal at least five guns!"
	wanted_items = list(/obj/item/gun)


/datum/objective/steal_five_of_type/summon_magic
	explanation_text = "Steal at least five magical artefacts!"
	wanted_items = list()


/datum/objective/steal_five_of_type/summon_magic/New()
	wanted_items = GLOB.summoned_magic_objectives
	..()


/datum/objective/steal_five_of_type/summon_magic/check_completion()
	var/stolen_count = 0
	var/list/owners = get_owners()
	var/list/all_items = list()

	for(var/datum/mind/player in owners)
		if(!isliving(player.current))
			continue
		all_items += player.current.GetAllContents()	//this should get things in cheesewheels, books, etc.

	for(var/obj/item in all_items) //Check for wanted items
		if(istype(item, /obj/item/spellbook) && !istype(item, /obj/item/spellbook/oneuse))
			var/obj/item/spellbook/spellbook = item
			if(spellbook.uses) //if the book still has powers...
				stolen_count++ //it counts. nice.

		if(istype(item, /obj/item/spellbook/oneuse))
			var/obj/item/spellbook/oneuse/oneuse = item
			if(!oneuse.used)
				stolen_count++

		else if(is_type_in_typecache(item, wanted_items))
			stolen_count++

	return stolen_count >= 5


/datum/objective/blood
	name = "Spread blood"
	needs_target = FALSE


/datum/objective/blood/New()
	gen_amount_goal()
	. = ..()


/datum/objective/blood/proc/gen_amount_goal(low = 150, high = 400)
	target_amount = rand(low, high)
	target_amount = round(round(target_amount / 5) * 5)
	explanation_text = "Накопить не менее [target_amount] единиц крови."
	return target_amount


/datum/objective/blood/check_completion()
	for(var/datum/mind/player in get_owners())
		var/datum/antagonist/vampire/vampire = player.has_antag_datum(/datum/antagonist/vampire)
		if(vampire && (vampire.bloodtotal >= target_amount))
			return TRUE

		var/datum/antagonist/goon_vampire/g_vampire = player.has_antag_datum(/datum/antagonist/goon_vampire)
		if(g_vampire && (g_vampire.bloodtotal >= target_amount))
			return TRUE

		return FALSE


// /vg/; Vox Inviolate for humans :V
/datum/objective/minimize_casualties
	explanation_text = "Minimise casualties."
	needs_target = FALSE


/datum/objective/minimize_casualties/check_completion()
	return TRUE


//Vox heist objectives.

/datum/objective/heist
	needs_target = FALSE

/datum/objective/heist/proc/choose_target()
	return

/datum/objective/heist/kidnap


/datum/objective/heist/kidnap/choose_target()
	var/list/roles = list(JOB_TITLE_CHIEF, JOB_TITLE_RD, JOB_TITLE_CMO, JOB_TITLE_HOP, JOB_TITLE_HOS, JOB_TITLE_REPRESENTATIVE, JOB_TITLE_JUDGE, JOB_TITLE_ROBOTICIST, JOB_TITLE_CHEMIST)
	var/list/possible_targets = list()
	var/list/priority_targets = list()

	for(var/datum/mind/possible_target in SSticker.minds)
		if(possible_target != owner && ishuman(possible_target.current) && (possible_target.current.stat != DEAD) && (possible_target.assigned_role != possible_target.special_role) && !possible_target.offstation_role)
			possible_targets += possible_target
			for(var/role in roles)
				if(possible_target.assigned_role == role)
					priority_targets += possible_target
					continue

	if(priority_targets.len > 0)
		target = pick(priority_targets)
	else if(possible_targets.len > 0)
		target = pick(possible_targets)

	if(target && target.current)
		explanation_text = "The Shoal has a need for [target.current.real_name], the [target.assigned_role]. Take [target.current.p_them()] alive."
	else
		explanation_text = "Free Objective"
	return target

/datum/objective/heist/kidnap/check_completion()
	if(target && target.current)
		if(target.current.stat == DEAD)
			return FALSE

		var/area/shuttle/vox/A = locate() //stupid fucking hardcoding
		var/area/vox_station/B = locate() //but necessary

		for(var/mob/living/carbon/human/M in A)
			if(target.current == M)
				return TRUE
		for(var/mob/living/carbon/human/M in B)
			if(target.current == M)
				return TRUE
	else
		return FALSE

/datum/objective/heist/loot
	needs_target = FALSE

/datum/objective/heist/loot/choose_target()
	var/loot = "an object"
	switch(rand(1,8))
		if(1)
			target = /obj/structure/particle_accelerator
			target_amount = 6
			loot = "a complete particle accelerator"
		if(2)
			target = /obj/machinery/the_singularitygen
			target_amount = 1
			loot = "a gravitational singularity generator"
		if(3)
			target = /obj/machinery/power/emitter
			target_amount = 4
			loot = "four emitters"
		if(4)
			target = /obj/machinery/nuclearbomb
			target_amount = 1
			loot = "a nuclear bomb"
		if(5)
			target = /obj/item/gun
			target_amount = 6
			loot = "six guns. Tasers and other non-lethal guns are acceptable"
		if(6)
			target = /obj/item/gun/energy
			target_amount = 4
			loot = "four energy guns"
		if(7)
			target = /obj/item/gun/energy/laser
			target_amount = 2
			loot = "two laser guns"
		if(8)
			target = /obj/item/gun/energy/ionrifle
			target_amount = 1
			loot = "an ion gun"

	explanation_text = "We are lacking in hardware. Steal or trade [loot]."

/datum/objective/heist/loot/check_completion()
	var/total_amount = 0

	for(var/obj/O in locate(/area/shuttle/vox))
		if(istype(O, target))
			total_amount++
		for(var/obj/I in O.contents)
			if(istype(I, target))
				total_amount++
			if(total_amount >= target_amount)
				return TRUE

	for(var/obj/O in locate(/area/vox_station))
		if(istype(O, target))
			total_amount++
		for(var/obj/I in O.contents)
			if(istype(I, target))
				total_amount++
			if(total_amount >= target_amount)
				return TRUE

	var/datum/game_mode/heist/H = SSticker.mode
	for(var/datum/mind/raider in H.raiders)
		if(raider.current)
			for(var/obj/O in raider.current.get_contents())
				if(istype(O,target))
					total_amount++
				if(total_amount >= target_amount)
					return TRUE

	return FALSE

/datum/objective/heist/salvage
	needs_target = FALSE

/datum/objective/heist/salvage/choose_target()
	switch(rand(1,6))
		if(1)
			target = "plasteel"
			target_amount = 100
		if(2)
			target = "solid plasma"
			target_amount = 100
		if(3)
			target = "silver"
			target_amount = 50
		if(4)
			target = "gold"
			target_amount = 20
		if(5)
			target = "uranium"
			target_amount = 20
		if(6)
			target = "diamond"
			target_amount = 20

	explanation_text = "Ransack or trade with the station and escape with [target_amount] [target]."

/datum/objective/heist/salvage/check_completion()
	var/total_amount = 0

	for(var/obj/item/O in locate(/area/shuttle/vox))
		var/obj/item/stack/sheet/S
		if(istype(O,/obj/item/stack/sheet))
			if(O.name == target)
				S = O
				total_amount += S.get_amount()

		for(var/obj/I in O.contents)
			if(istype(I,/obj/item/stack/sheet))
				if(I.name == target)
					S = I
					total_amount += S.get_amount()

	for(var/obj/item/O in locate(/area/vox_station))
		var/obj/item/stack/sheet/S
		if(istype(O,/obj/item/stack/sheet))
			if(O.name == target)
				S = O
				total_amount += S.get_amount()

		for(var/obj/I in O.contents)
			if(istype(I,/obj/item/stack/sheet))
				if(I.name == target)
					S = I
					total_amount += S.get_amount()

	var/datum/game_mode/heist/H = SSticker.mode
	for(var/datum/mind/raider in H.raiders)
		if(raider.current)
			for(var/obj/item/O in raider.current.get_contents())
				if(istype(O,/obj/item/stack/sheet))
					if(O.name == target)
						var/obj/item/stack/sheet/S = O
						total_amount += S.get_amount()

	if(total_amount >= target_amount) return TRUE
	return FALSE


/datum/objective/heist/inviolate_crew
	explanation_text = "Do not leave any Vox behind, alive or dead."
	needs_target = FALSE

/datum/objective/heist/inviolate_crew/check_completion()
	var/datum/game_mode/heist/H = SSticker.mode
	if(H.is_raider_crew_safe())
		return TRUE
	return FALSE

/datum/objective/heist/inviolate_death
	explanation_text = "Follow the Inviolate. Minimise death and loss of resources."
	needs_target = FALSE

/datum/objective/heist/inviolate_death/check_completion()
	return TRUE

// Traders
// These objectives have no check_completion, they exist only to tell Sol Traders what to aim for.
/datum/objective/trade
	needs_target = FALSE


/datum/objective/trade/proc/choose_target()
	return


/datum/objective/trade/plasma/choose_target()
	explanation_text = "Acquire at least 15 sheets of plasma through trade."


/datum/objective/trade/credits/choose_target()
	explanation_text = "Acquire at least 10,000 credits through trade."


//wizard

/datum/objective/wizchaos
	explanation_text = "Wreak havoc upon the station as much you can. Send those wandless Nanotrasen scum a message!"
	needs_target = FALSE
	completed = TRUE


//Space Ninja

/datum/objective/cyborg_hijack
	name = "Cyborg Hijack"
	explanation_text = "Используя свои перчатки обратите на свою сторону хотя бы одного киборга, чтобы он помог вам в саботаже станции!"
	needs_target = FALSE


/datum/objective/plant_explosive
	name = "Plant Explosive"
	///Where we should KABOOM
	var/area/detonation_location
	var/list/area_blacklist = list(
		/area/engine/engineering, /area/engine/supermatter,
		/area/toxins/test_area, /area/turret_protected/ai)
	needs_target = FALSE


/datum/objective/plant_explosive/New(text, datum/team/team_to_join)
	if(!choose_target_area())
		explanation_text = "Free Objective"
	..()


/datum/objective/plant_explosive/Destroy()
	. = ..()
	detonation_location = null


/datum/objective/plant_explosive/proc/choose_target_area()
	for(var/sanity in 1 to 100) // 100 checks at most.
		var/area/selected_area = pick(return_sorted_areas())
		if(selected_area && is_station_level(selected_area.z) && selected_area.valid_territory) //Целью должна быть зона на станции!
			if(selected_area in area_blacklist)
				continue
			detonation_location = selected_area
			break
	. = detonation_location
	if(.)
		explanation_text = "Взорвите выданную вам бомбу в [detonation_location]. Учтите, что бомбу нельзя активировать на не предназначенной для подрыва территории!"


/datum/objective/plant_explosive/proc/give_bomb(delayed = null)
	if(isnull(delayed))
		actual_give_bomb()
	else if(isnum(delayed))
		addtimer(CALLBACK(src, PROC_REF(actual_give_bomb)), delayed)


/datum/objective/plant_explosive/proc/actual_give_bomb()
	if(!owner || !owner.current || !detonation_location || completed)
		return
	var/mob/ninja = owner.current
	var/obj/item/grenade/plastic/c4/ninja/bomb_item = new(ninja)
	bomb_item.detonation_objective = src
	ninja.equip_or_collect(bomb_item, ITEM_SLOT_POCKET_LEFT)


/datum/objective/get_money
	name = "Steal Money"
	needs_target = FALSE
	target_amount = 75000


/datum/objective/get_money/New(text, datum/team/team_to_join)
	new_cash()
	..()


/datum/objective/get_money/proc/new_cash(input_sum, accounts_procent = 60)
	var/temp_cash_summ = 0
	var/remainder = 0

	if(input_sum)
		temp_cash_summ = input_sum
	else
		for(var/datum/money_account/account in GLOB.all_money_accounts)
			temp_cash_summ += account.money
		temp_cash_summ = (temp_cash_summ / 100) * accounts_procent //procents from all accounts
		remainder = temp_cash_summ % 1000	//для красивого 1000-го числа

	target_amount = temp_cash_summ - remainder
	explanation_text = "Добудьте [target_amount] кредитов со станции, наличкой."


/datum/objective/get_money/check_completion()
	var/cash_sum = 0
	for(var/datum/mind/player in get_owners())
		if(!player.current || player.current.stat == DEAD)
			continue

		for(var/obj/item/check in player.current.get_contents()) //Check for items
			if(istype(check, /obj/item/stack/spacecash))
				var/obj/item/stack/spacecash/current_cash = check
				cash_sum += current_cash.amount

	return cash_sum >= target_amount


/datum/objective/protect/ninja
	name = "Ninja's Protect"
	var/list/killers_objectives = list()
	var/list/killers = list()


/datum/objective/protect/ninja/Destroy()
	if(killers_objectives)
		for(var/datum/objective/killer_objective in killers_objectives)
			qdel(killer_objective)
	return ..()


/datum/objective/protect/ninja/find_target(list/target_blacklist)
	if(!needs_target)
		return

	var/list/possible_targets = list()
	for(var/datum/mind/possible_target in SSticker.minds)
		if(is_invalid_target(possible_target) || (possible_target in killers) || (possible_target in target_blacklist) || target == possible_target)
			continue
		possible_targets |= possible_target

		if(length(killers_objectives))
			for(var/datum/objective/killer_objective in killers_objectives)
				possible_targets -= killer_objective.owner

	target = safepick(possible_targets)

	if(target?.current)
		explanation_text = "На [target.current.real_name], [target.assigned_role] ведут охоту. [target.current.real_name] должен любой ценой \
							дожить до конца смены и ваша работа как можно незаметнее позаботится о том, чтобы он остался жив."
	else
		explanation_text = "Free Objective"

	return target


/datum/objective/protect/ninja/post_target_cryo(list/owners)
	find_target(existing_targets_blacklist())
	if(!target?.current)
		qdel(src)
	else
		update_killers()

	for(var/datum/mind/user in owners)
		var/list/messages = user.prepare_announce_objectives()
		to_chat(user.current, chat_box_red(messages.Join("<br>")))


/datum/objective/protect/ninja/proc/update_killers()
	if(!length(killers_objectives))
		return

	for(var/datum/objective/killer_objective in killers_objectives)
		killer_objective.target = target
		if(istype(killer_objective, /datum/objective/assassinate))
			killer_objective.explanation_text = "Assassinate [killer_objective.target.current.real_name], the [killer_objective.target.assigned_role]."
		else if(istype(killer_objective, /datum/objective/maroon))
			killer_objective.explanation_text = "Prevent from escaping alive or free [killer_objective.target.current.real_name], the [killer_objective.target.assigned_role]."

		for(var/datum/mind/killer in killer_objective.get_owners())
			killer.prepare_announce_objectives()


/**
 * Set up a victim so that they are arrested.
 */
/datum/objective/set_up
	name = "Set Up"
	martyr_compatible = TRUE


/datum/objective/set_up/is_invalid_target(datum/mind/possible_target)
	. = ..()
	if(.)
		return
	if(ismindshielded(possible_target.current))
		return TARGET_INVALID_BLACKLISTED


/datum/objective/set_up/find_target(list/target_blacklist)
	..()
	if(target?.current)
		explanation_text = "Любым способом подставьте [target.current.real_name], [target.assigned_role], чтобы его лишили свободы. Но не убили!"
	else
		explanation_text = "Free Objective"
	return target


/datum/objective/set_up/on_target_cryo()
	if(check_completion())
		completed = TRUE
		return

	var/list/owners = get_owners()
	for(var/datum/mind/user in owners)
		to_chat(owner.current, "<BR><span class='userdanger'>You get the feeling your target is no longer within reach. Time for Plan [pick("A","B","C","D","X","Y","Z")]. Objectives updated!</span>")
		SEND_SOUND(owner.current, 'sound/ambience/alarm4.ogg')

	if(!completed)
		target = null
		INVOKE_ASYNC(src, PROC_REF(post_target_cryo), owners)


/datum/objective/set_up/check_completion()
	if(issilicon(target.current))
		return FALSE
	if(isbrain(target.current))
		return FALSE
	if(!target.current || target.current.stat == DEAD)
		return FALSE

	var/datum/data/record/target_record = find_security_record("name", target.name)
	if(target_record)
		if(target_record.fields["criminal"] == SEC_RECORD_STATUS_INCARCERATED || target_record.fields["criminal"] == SEC_RECORD_STATUS_EXECUTE || target_record.fields["criminal"] == SEC_RECORD_STATUS_PAROLLED || target_record.fields["criminal"] == SEC_RECORD_STATUS_RELEASED)
			return TRUE

	if(istype(target.current.lastarea, /area/security/prison/cell_block) || istype(target.current.lastarea, /area/security/permabrig) || istype(target.current.lastarea, /area/security/processing))
		return TRUE

	var/turf/location = get_turf(target.current)
	if(!location)
		return FALSE
	if(istype(location, /turf/simulated/floor/shuttle/objective_check) || istype(location, /turf/simulated/floor/mineral/plastitanium/red/brig))
		return TRUE

	return FALSE


/**
 * The goal is to find a person with information. All a ninja knows is person's profession.
 * To achieve this goal, the ninja must kidnap people of a certain profession until he finds THAT SAME asshole with the information.
 * Or until enough people are kidnapped (from 3 to 6 (per 100 players))
 */
/datum/objective/find_and_scan
	martyr_compatible = TRUE
	var/list/possible_roles = list()
	/// Variables below updated by ninja's scan machine.
	var/list/scanned_occupants = list()
	var/scans_to_win = 3
	var/list/available_roles = list(
		JOB_TITLE_CLOWN, JOB_TITLE_MIME, JOB_TITLE_CARGOTECH,
		JOB_TITLE_MINER, JOB_TITLE_SCIENTIST, JOB_TITLE_ROBOTICIST,
		JOB_TITLE_DOCTOR, JOB_TITLE_GENETICIST, JOB_TITLE_OFFICER,
		JOB_TITLE_CHEMIST, JOB_TITLE_ENGINEER, JOB_TITLE_CIVILIAN,
		JOB_TITLE_BOTANIST, JOB_TITLE_VIROLOGIST, JOB_TITLE_ATMOSTECH
	)


/datum/objective/find_and_scan/on_target_cryo()
	return	// objective is structured in such a way that even without a target it is still doable


/datum/objective/find_and_scan/find_target(list/target_blacklist)
	if(!needs_target)
		return

	if(!length(possible_roles))
		for(var/i in 1 to 3)
			var/role = pick_n_take(available_roles)
			possible_roles |= role

	var/list/possible_targets = list()
	var/list/priority_targets = list()
	for(var/datum/mind/possible_target in SSticker.minds)
		if(is_invalid_target(possible_target) || (possible_target in target_blacklist))
			continue
		possible_targets |= possible_target
		for(var/role in possible_roles)
			if(role == possible_target.assigned_role)
				priority_targets |= possible_target
				continue

	if(length(priority_targets))
		target = pick(priority_targets)
	else if(length(possible_targets))
		target = pick(possible_targets)

	if(target)
		if(!(target.assigned_role in possible_roles))
			possible_roles[pick(1,2,3)] = target.assigned_role
	scans_to_win = clamp(round(length(possible_targets) / 10), initial(scans_to_win), 6)

	explanation_text = "Найдите обладающего важной информацией человека среди следующих профессий: [possible_roles[1]], [possible_roles[2]], [possible_roles[3]]. \
		Для проверки и анализа памяти человека, вам придётся похитить его и просканировать в специальном устройстве на вашей базе."

	return target


/datum/objective/vermit_hunt
	needs_target = FALSE
	martyr_compatible = TRUE
	target_amount = 3


/datum/objective/vermit_hunt/New(text, datum/team/team_to_join)
	explanation_text = "На объекте вашей миссии действуют паразиты так же известные как \"Генокрады\" истребите хотя бы [target_amount] из них."
	..()


/datum/objective/vermit_hunt/proc/update_objective(amount)
	target_amount = max(1, round((amount || length(SSticker.mode.changelings)) / 2))
	explanation_text = "На объекте вашей миссии действуют паразиты так же известные как \"Генокрады\" истребите хотя бы [target_amount] из них."


/datum/objective/vermit_hunt/check_completion()
	var/killed_vermits = 0
	for(var/datum/mind/player in SSticker.mode.changelings)
		if(!player || !player.current || !player.current.ckey || player.current.stat == DEAD || is_special_dead(player.current, check_silicon = TRUE))
			killed_vermits++

	return killed_vermits >= target_amount


/**
 * Completed via [ninja_bloodscan_machine.dm]
 */
/datum/objective/collect_blood
	needs_target = FALSE
	martyr_compatible = TRUE
	explanation_text = "На объекте вашей миссии действуют вампиры. \
	Ваша задача отыскать их, взять с них образцы крови и просканировать оные в устройстве на вашей базе. \
	Вам нужно 3 уникальных образца чтобы начать сканирование.\
	Успешное сканирование поможет клану лучше противодействовать им."
	var/samples_to_win = 3


/datum/objective/research_corrupt
	needs_target = FALSE
	explanation_text = "Используя свои перчатки, загрузите мощный вирус на любой научный сервер станции, тем самым саботировав все их исследования! \
	Учтите, что установка займёт время и ИИ скорее всего будет уведомлён о вашей попытке взлома!"


/datum/objective/ai_corrupt
	needs_target = FALSE
	explanation_text = "Используя свои перчатки, загрузите в ИИ станции специальный вирус через консоль для смены законов которая стоит в загрузочной. \
	Подойдёт только консоль в этой зоне из-за уязвимости оставленной заранее для вируса. \
	Учтите, что установка займёт время и ИИ скорее всего будет уведомлён о вашей попытке взлома!"


/datum/objective/blob_critical_mass
	needs_target = FALSE
	//Total blob tiles count
	var/critical_mass = -2
	//Needed blob tiles count
	var/needed_critical_mass = -1


/datum/objective/blob_critical_mass/check_completion()
	if(!completed)
		completed = needed_critical_mass <= critical_mass && GLOB.security_level < SEC_LEVEL_DELTA
	return ..()


/datum/objective/blob_critical_mass/proc/set_target()
	explanation_text = "Наберите критическую массу, распостраняясь по станции. Текущаяя масса [critical_mass]. Необходимо набрать [needed_critical_mass]. Масса может изменяться в зависимости от количества блобов."

/datum/objective/blob_find_place_to_burst
	needs_target = FALSE
	explanation_text = "Найдите укромное место на станции, в котором вас не смогут найти после вылупления до тех пор, пока вы не наберетесь сил."
