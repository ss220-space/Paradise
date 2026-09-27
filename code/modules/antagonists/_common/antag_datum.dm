GLOBAL_LIST_EMPTY(antagonists)
GLOBAL_LIST_EMPTY(antagonists_datums)

/datum/antagonist
	/// The name of the antagonist.
	var/name = "Antagonist"
	/// Section of roundend report, datums with same category will be displayed together, also default header for the section.
	var/roundend_category = "Прочими антагонистами"
	/// Set to false to hide the antagonists from roundend report.
	var/show_in_roundend = TRUE
	var/roundend_blackbox_key
	var/roundend_death_is_failure = FALSE
	/// Mind that owns this datum.
	var/datum/mind/owner
	/// Silent will prevent the gain/lose texts to show.
	var/silent = FALSE
	/// List of other antag datum types that this type can't coexist with.
	var/list/antag_datum_blacklist
	/// If current antag datum should be deleted on mind deletion.
	var/delete_on_mind_deletion = TRUE
	var/obj/item/uplink/hidden/hidden_uplink = null
	/// Used to determine if the player jobbanned from this role. Things like `SPECIAL_ROLE_TRAITOR` should go here to determine the role.
	var/job_rank
	/// Should we replace the role-banned player with a ghost?
	var/replace_banned = TRUE
	/// List of objectives connected to this datum.
	var/list/objectives
	/// A list of strings which contain [targets][/datum/objective/var/target] of the antagonist's objectives. Used to prevent duplicate objectives.
	var/list/assigned_targets
	/// Current antagonist teams
	var/datum/team/team
	var/default_team_type
	/// Antagonist datum specific information that appears in the player's notes. Information stored here will be removed when the datum is removed from the player.
	var/antag_memory
	/// The special role that will be applied to the owner's `special_role` var. i.e. `SPECIAL_ROLE_TRAITOR`, `SPECIAL_ROLE_VAMPIRE`.
	var/special_role
	/// Should we automatically give this antagonist objectives upon them gaining the datum?
	var/give_objectives = TRUE
	/// Holds the type of antagonist hud this datum will get, i.e. `ANTAG_HUD_TRAITOR`, `ANTAG_HUD_VAMPIRE`, etc.
	var/antag_hud_type
	/// Holds the name of the hud's icon in the .dmi files, i.e "hudtraitor", "hudvampire", etc.
	var/antag_hud_name
	/// If the owner is a clown, this text will be displayed to them when they gain this datum.
	var/clown_gain_text = "You are no longer clumsy."
	/// If the owner is a clown, this text will be displayed to them when they lose this datum.
	var/clown_removal_text = "You are clumsy again."
	/// If antagonist has his own wiki page
	var/wiki_page_name
	/// Russian name of wiki page
	var/russian_wiki_name
	/// Show antag in ghost orbit
	var/show_in_orbit = TRUE
	/// Role name in antag menu
	var/antag_menu_name
	var/greet_box_class = "red_box center"
	var/stinger_sound
	/// A weakref to the alt-appearance hud shown to this antag's teammates, created by `add_team_hud`.
	var/datum/weakref/team_hud_ref

/datum/antagonist/New()
	GLOB.antagonists += src
	objectives = list()
	assigned_targets = list()

/datum/antagonist/Destroy(force)
	for(var/datum/objective/objective as anything in objectives)
		objectives -= objective
		objective.on_remove_objective(owner)

		if(!objective.team)
			qdel(objective)

	remove_owner_from_gamemode()
	GLOB.antagonists -= src

	if(hidden_uplink)
		var/obj/item/uplink_holder = hidden_uplink.loc
		if(!QDELETED(uplink_holder))
			uplink_holder.hidden_uplink = null

		QDEL_NULL(hidden_uplink)

	if(!silent)
		farewell()

	if(owner?.current)
		remove_innate_effects()

	antag_memory = null

	var/datum/team/team = get_team()
	team?.remove_member(owner)

	if(owner)
		LAZYREMOVE(owner.antag_datums, src)

		if(!LAZYLEN(owner.antag_datums)) // that one was the last antag datum.
			handle_last_instance_removal()

	restore_last_hud_and_role()
	owner = null

	return ..()

/**
 * Loops through the owner's `antag_datums` list and determines if this one is blacklisted by any others.
 *
 * If it's in one of their blacklists, return FALSE. It cannot coexist with the datum we're trying to add here.
 */
/datum/antagonist/proc/can_be_owned(datum/mind/new_owner)
	var/datum/mind/tested = new_owner || owner
	if(tested?.has_antag_datum(type))
		return FALSE
	for(var/i in tested.antag_datums)
		var/datum/antagonist/A = i
		if(LAZYIN(A.antag_datum_blacklist, type))
			return FALSE
	return TRUE

/**
 * Checks if the person trying to receive this datum is role banned from it.
 */
/datum/antagonist/proc/is_banned(mob/user)
	if(!user)
		return FALSE

	return (jobban_isbanned(user, ROLE_SYNDICATE) || (job_rank && jobban_isbanned(user, job_rank)))

/**
 * When our datum was last and became removed.
 */
/datum/antagonist/proc/handle_last_instance_removal()
	return

/**
 * Attempts to replace the role banned antag with a ghost player.
 */
/datum/antagonist/proc/replace_banned_player()
	var/list/mob/dead/observer/candidates = SSghost_spawns.poll_candidates("Do you want to play as a [name]?", job_rank, TRUE, 10 SECONDS)
	if(!length(candidates))
		return FALSE

	if(QDELETED(owner.current))
		return

	var/mob/dead/observer/chosen = pick(candidates)
	to_chat(owner, "Your mob has been taken over by a ghost! Appeal your job ban if you want to avoid this in the future!")
	message_admins("[key_name_admin(chosen)] has taken control of ([key_name_admin(owner.current)]) to replace a jobbaned player.")
	owner.current.ghostize(FALSE)
	owner.current.possess_by_player(chosen.key)
	log_game("[owner.current.key] has taken control of ([owner.current]) to replace a jobbaned player.")
	return TRUE

/**
 * Proc called when the datum is given to a mind.
 */
/datum/antagonist/proc/on_gain()
	if(!owner?.current)
		return FALSE

	owner.special_role = special_role
	add_owner_to_gamemode()
	if(give_objectives)
		give_objectives()
	var/list/messages = list()
	if(!silent)
		messages.Add(greet())
		if(length(owner.get_all_objectives()))
			messages.Add(owner.prepare_announce_objectives())
		play_stinger()
	apply_innate_effects()
	messages.Add(finalize_antag())
	if(!silent && wiki_page_name)
		messages.Add(span_motd("С полной информацией вы можете ознакомиться на вики: <a href=\"[CONFIG_GET(string/wikiurl)]/index.php/[wiki_page_name]\">[russian_wiki_name]"))
	list_clear_nulls(messages)
	if(length(messages))
		to_chat(owner.current, custom_boxed_message(greet_box_class, messages.Join("<br>")))

	if(is_banned(owner.current) && replace_banned)
		INVOKE_ASYNC(src, PROC_REF(replace_banned_player))
	owner.current.create_log(MISC_LOG, "[owner.current] was made into \an [special_role]")
	return TRUE

/**
 * Adds the owner to their respective gamemode's list. For example `SSticker.mode.blobs[BLOB_GROUP_INFECTED] |= owner`.
 */
/datum/antagonist/proc/add_owner_to_gamemode()
	return

/**
 * Removes the owner from their respective gamemode's list. For example `SSticker.mode.blobs[BLOB_GROUP_INFECTED] -= owner`.
 */
/datum/antagonist/proc/remove_owner_from_gamemode()
	return

/**
 * Displays a message and their objectives to the antag mob after the datum is added to them, i.e. "Greetings you are a traitor! etc.
 *
 * Called in `on_gain()` if silent it set to FALSE.
 */
/datum/antagonist/proc/greet()
	var/list/messages = list()
	. = messages
	if(owner?.current && !silent)
		messages.Add(span_userdanger("You are a [special_role]!"))

/datum/antagonist/proc/play_stinger()
	if(!stinger_sound)
		return
	owner.current.playsound_local(null, stinger_sound, 100, FALSE, pressure_affected = FALSE, use_reverb = FALSE)

/**
 * Displays a message to the antag mob while the datum is being deleted, i.e. "Your powers are gone and you're no longer a vampire!"
 *
 * Called when datum is qdeled if silent is set to FALSE.
 */
/datum/antagonist/proc/farewell()
	if(owner?.current && !silent)
		to_chat(owner.current, span_userdanger("You are no longer a [special_role]!"))

/**
 * Removes antagonist datum effects from the old body and applies it to the new one.
 *
 * Called in the`/datum/mind/proc/transfer_to()`.
 *
 * Arguments:
 * * new_body - the new body the antag mob is transferring into.
 * * old_body - the old body the antag mob is leaving.
 */
/datum/antagonist/proc/on_body_transfer(mob/living/old_body, mob/living/new_body)
	remove_innate_effects(old_body)
	apply_innate_effects(new_body)

/**
 * This handles the application of antag huds/special abilities.
 *
 * Gives the antag mob their assigned hud.
 * If they're a clown, removes their clumsy mutataion.
 *
 * Arguments:
 * * mob/living/mob_override - a mob to apply effects to. Can be null.
 */
/datum/antagonist/proc/apply_innate_effects(mob/living/mob_override)
	SHOULD_CALL_PARENT(TRUE)
	var/mob/living/user = mob_override || owner.current
	if(antag_hud_type && antag_hud_name)
		add_antag_hud(user)
	// If `mob_override` exists it means we're only transferring this datum, we don't need to show the clown any text.
	handle_clown_mutation(user, mob_override ? null : clown_gain_text, TRUE)
	return user

/**
 * This handles the removal of antag huds/special abilities.
 *
 * Removes the antag's assigned hud.
 * If they're a clown, gives them back their clumsy mutataion.
 *
 * Arguments:
 * * mob/living/mob_override - a mob to remove effects from. Can be null.
 */
/datum/antagonist/proc/remove_innate_effects(mob/living/mob_override)
	SHOULD_CALL_PARENT(TRUE)
	var/mob/living/user = mob_override || owner.current
	if(antag_hud_type && antag_hud_name)
		remove_antag_hud(user)
	// If `mob_override` exists it means we're only transferring this datum, we don't need to show the clown any text.
	handle_clown_mutation(user, mob_override ? null : clown_removal_text)
	return user

/**
 * Adds this datum's antag hud to `antag_mob`.
 *
 * Arguments:
 * * antag_mob - the mob to add the antag hud to.
 */
/datum/antagonist/proc/add_antag_hud(mob/living/antag_mob)
	var/datum/atom_hud/antag/hud = GLOB.huds[antag_hud_type]
	hud.join_hud(antag_mob)
	set_antag_hud(antag_mob, antag_hud_name)

/**
 * Removes this datum's antag hud from `antag_mob`.
 *
 * Arguments:
 * * antag_mob - the mob to remove the antag hud from.
 */
/datum/antagonist/proc/remove_antag_hud(mob/living/antag_mob)
	var/datum/atom_hud/antag/hud = GLOB.huds[antag_hud_type]
	hud.leave_hud(antag_mob)
	set_antag_hud(antag_mob, null)

/**
 * Adds an alternate-appearance hud image on `antag_mob`, visible only to mobs the hud type deems teammates (Arguments below).
 *
 * Arguments:
 * * antag_mob - the mob to draw the hud image on.
 * * team_hud_type - the `/datum/atom_hud/alternate_appearance` subtype deciding who sees the image.
 * * team_master - the mind identifying the team, passed through to the hud.
 */
/datum/antagonist/proc/add_team_hud(mob/living/antag_mob, team_hud_type, datum/mind/team_master)
	remove_team_hud()
	team_hud_ref = WEAKREF(antag_mob.add_alt_appearance(team_hud_type, "team_hud_[UID()]", hud_image_on(antag_mob), team_master))
	// Show us the huds of teammates that were created before we joined.
	for(var/datum/atom_hud/alternate_appearance/alt_hud as anything in GLOB.active_alternate_appearances)
		if(istype(alt_hud, team_hud_type))
			alt_hud.apply_to_new_mob(antag_mob)

/datum/antagonist/proc/remove_team_hud()
	var/datum/atom_hud/alternate_appearance/team_hud = team_hud_ref?.resolve()
	team_hud_ref = null
	if(team_hud)
		qdel(team_hud)

/datum/antagonist/proc/hud_image_on(mob/hud_loc)
	var/image/hud = image('icons/mob/hud.dmi', hud_loc, antag_hud_name)
	hud.appearance_flags = RESET_COLOR|PIXEL_SCALE|KEEP_APART
	return hud

/**
 * Re-sets the antag hud and `special_role` of the owner to that of the previous antag datum they had before this one was added.
 *
 * For example, if the owner has a traitor datum and a vampire datum, both at index 1 and 2 respectively,
 * After the vampire datum gets removed, it sets the owner's antag hud/role to whatever is set for traitor datum.
 */
/datum/antagonist/proc/restore_last_hud_and_role()
	if(!LAZYLEN(owner.antag_datums))
		// If they only had 1 antag datum, no need to restore anything. `remove_innate_effects()` will handle the removal of their hud.
		owner.special_role = null
		return FALSE
	var/datum/antagonist/antag = owner.antag_datums[LAZYLEN(owner.antag_datums)]
	ASSERT(antag)
	antag.add_antag_hud(owner.current) // Restore the hud of the previous antagonist datum.
	owner.special_role = antag.special_role

/**
 * Handles adding and removing the clumsy mutation from clown antags.
 *
 * Arguments:
 * * clown - the mob in which to add or remove clumsy from.
 * * message - the chat message to display to them the clown mob
 * * granting_datum - TRUE if the datum is being applied to the clown mob.
 */
/datum/antagonist/proc/handle_clown_mutation(mob/living/carbon/human/clown, message, granting_datum = FALSE)
	if(!istype(clown) || owner.assigned_role != JOB_TITLE_CLOWN)
		return FALSE

	// Remove clumsy and give them an action to toggle it on and off.
	if(granting_datum)
		clown.force_gene_block(GLOB.clumsyblock, FALSE)
		// Don't give them another action if they already have one.
		if(!(locate(/datum/action/innate/toggle_clumsy) in clown.actions))
			var/datum/action/innate/toggle_clumsy/A = new
			A.Grant(clown)
	// Give them back the clumsy gene and remove their toggle action, but ONLY if they don't have any other antag datums.
	else if(LAZYLEN(owner.antag_datums) <= 1)
		clown.force_gene_block(GLOB.clumsyblock, TRUE)
		if(locate(/datum/action/innate/toggle_clumsy) in clown.actions)
			var/datum/action/innate/toggle_clumsy/A = locate() in clown.actions
			A.Remove(clown)
	else
		return FALSE

	if(!silent && message)
		to_chat(clown, span_boldnotice(message))
	return TRUE

/**
 * Give the antagonist their objectives. Base proc, override as needed.
 */
/datum/antagonist/proc/give_objectives()
	return

/**
 * Announces all objectives of this datum, and only this datum.
 */
/datum/antagonist/proc/announce_objectives()
	if(!length(objectives))
		return FALSE

	to_chat(owner.current, span_notice("Your current objectives:"))
	var/objective_num = 1
	for(var/datum/objective/objective in objectives)
		to_chat(owner.current, span_notice("<b>Objective #[objective_num++]</b>: [objective.explanation_text]<br>"))
	return TRUE

/**
 * Create and add an objective of the given type.
 *
 * If the given objective type needs a target, it will try to find a target which isn't already the target of different objective for this antag.
 * If one cannot be found, it tries one more time. If one still cannot be found, it will be added as a "Free Objective" without a target.
 *
 * Arguments:
 * * objective_type - A type path of an objective, for example: /datum/objective/steal
 * * explanation_text - the explanation text that will be passed into the objective's `New()` proc
 * * mob/target_override - a target for the objective
 */
/datum/antagonist/proc/add_objective(objective_type, explanation_text = "", datum/mind/target_override = null)
	var/datum/objective/new_objective = objective_type
	if(ispath(objective_type))
		new_objective = new objective_type(explanation_text)
	new_objective.owner = owner

	if(!new_objective.needs_target)
		objectives += new_objective
		new_objective.on_add_objective(owner)
		return new_objective

	var/found_valid_target = FALSE

	if(target_override)
		new_objective.target = target_override
		found_valid_target = TRUE

	else
		if(istype(new_objective, /datum/objective/steal))
			var/datum/objective/steal/our_objective = new_objective
			var/list/steal_target_ids = list()
			for(var/datum/objective/steal/steal_objective in owner.get_all_objectives())
				if(!steal_objective.steal_target?.id)
					continue
				steal_target_ids |= steal_objective.steal_target.id

			if(our_objective.find_target(target_blacklist = steal_target_ids))
				found_valid_target = TRUE

		else
			var/list/general_targets = list()
			for(var/datum/objective/general_objective in owner.get_all_objectives())
				if(istype(general_objective, /datum/objective/steal) || !general_objective.target)
					continue
				general_targets |= general_objective.target

			new_objective.find_target(target_blacklist = general_targets)
			if(new_objective.target)
				found_valid_target = TRUE

	if(!found_valid_target)
		new_objective.explanation_text = "Ага. Делай, что душе угодно."
		new_objective.antag_menu_name = "Свободная цель"
		new_objective.target = null

	new_objective.on_add_objective(owner)
	objectives += new_objective
	return new_objective

/**
 * Creates a new antagonist team.
 */
/datum/antagonist/proc/create_team(datum/team/team)
	src.team = create_antag_team(team)
	return

/proc/create_antag_team(datum/team/team)
	if(!ispath(team))
		team = team.type
	if(!GLOB.antagonist_teams[team])
		new team
	return GLOB.antagonist_teams[team]

/**
 * Returns the team the antagonist belongs to, if any.
 */
/datum/antagonist/proc/get_team()
	return team

/**
 * Give the antag any final information or items.
 */
/datum/antagonist/proc/finalize_antag()
	return

/**
 * Return name for antag menu
 */
/datum/antagonist/proc/get_antag_menu_name()
	return antag_menu_name

/**
 * Return if antag shows in antag menu
 */
/datum/antagonist/proc/check_anatag_menu_ability()
	return TRUE

/**
 * Individual roundend report.
 */
/datum/antagonist/proc/roundend_report()
	if(!owner)
		stack_trace("[name] datum has no owner")
		return

	var/list/report = list("[owner.get_mind_key()] был [owner.name] ([get_roundend_status()])")
	report += roundend_report_details()

	var/succeeded = !roundend_death_is_failure || (owner.current && owner.current.stat != DEAD)
	var/count = 1
	for(var/datum/objective/objective as anything in owner.get_all_objectives())
		if(objective.check_completion())
			report += "<b>Цель #[count]</b>: [objective.explanation_text] <font color='green'><b>Успех!</b></font>"
			record_objective_feedback(objective, "SUCCESS")
		else
			report += "<b>Цель #[count]</b>: [objective.explanation_text] <font color='red'>Провал.</font>"
			record_objective_feedback(objective, "FAIL")
			succeeded = FALSE
		count++

	if(succeeded)
		report += "<font color='green'><b>[antag_menu_name || name] — успех!</b></font>"
	else
		report += "<font color='red'><b>[antag_menu_name || name] — провал.</b></font>"

	if(roundend_blackbox_key)
		SSblackbox.record_feedback("tally", "[roundend_blackbox_key]_success", 1, succeeded ? "SUCCESS" : "FAIL")

	return report.Join("<br>")

/datum/antagonist/proc/get_roundend_status()
	if(!owner.current)
		return "тело уничтожено"
	var/status = owner.current.stat == DEAD ? "погиб" : "выжил"
	if(owner.current.real_name != owner.name)
		status += " как [owner.current.real_name]"
	return status

/datum/antagonist/proc/roundend_report_details()
	return list()

/datum/antagonist/proc/record_objective_feedback(datum/objective/objective, result)
	if(!roundend_blackbox_key)
		return
	if(istype(objective, /datum/objective/steal))
		var/datum/objective/steal/steal_objective = objective
		SSblackbox.record_feedback("nested tally", "[roundend_blackbox_key]_steal_objective", 1, list("Steal [steal_objective.steal_target]", result))
		return
	SSblackbox.record_feedback("nested tally", "[roundend_blackbox_key]_objective", 1, list("[objective.type]", result))

/**
 * Displayed at the start of roundend_category section, default to roundend_category header.
 */
/datum/antagonist/proc/roundend_report_header()
	return span_fontsize2("<b>[roundend_category] были:</b>")

/**
 * Displayed at the end of roundend_category section.
 */
/datum/antagonist/proc/roundend_report_footer()
	return

/**
 * Create and assign a single randomized objective.
 */
/datum/antagonist/proc/forge_single_objective()
	if(prob(50))
		if(length(active_ais()) && prob(100 / length(GLOB.player_list)))
			add_objective(/datum/objective/destroy)

		else if(prob(5))
			add_objective(/datum/objective/debrain)

		else if(prob(20))
			add_objective(/datum/objective/protect)

		else
			add_objective(/datum/objective/maroon)

	else
		add_objective(get_steal_objective_type())

/datum/antagonist/proc/get_steal_objective_type()
	return /datum/objective/steal
