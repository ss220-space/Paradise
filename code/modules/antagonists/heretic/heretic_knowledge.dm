
/**
 * # Heretic Knowledge
 *
 * The datums that allow heretics to progress and learn new spells and rituals.
 *
 * Heretic Knowledge datums are not singletons - they are instantiated as they
 * are given to heretics, and deleted if the heretic antagonist is removed.
 *
 */
/datum/heretic_knowledge
	/// Name of the knowledge, shown to the heretic.
	var/name = "Пишите баг репорт."
	/// Description of the knowledge, shown to the heretic. Describes what it unlocks / does.
	var/desc = "Если вы это увидели, что-то пошло не так."
	/// What's shown to the heretic when the knowledge is acquired
	var/gain_text
	/// The abstract parent type of the knowledge, used in determine mutual exclusivity in some cases
	var/datum/heretic_knowledge/abstract_parent_type = /datum/heretic_knowledge
	/// Assoc list of [typepaths we need] to [amount needed].
	/// If set, this knowledge allows the heretic to do a ritual on a transmutation rune with the components set.
	/// If one of the items in the list is a list, it's treated as 'any of these items will work'
	var/list/required_atoms
	/// Paired with above. If set, the resulting spawned atoms upon ritual completion.
	var/list/result_atoms = list()
	/// If set, required_atoms checks for these *exact* types and doesn't allow them to be ingredients.
	var/list/banned_atom_types = list()
	/// Cost of knowledge in knowledge points
	var/cost = 0
	/// The priority of the knowledge. Higher priority knowledge appear higher in the ritual list.
	/// Number itself is completely arbitrary. Does not need to be set for non-ritual knowledge.
	var/priority = 0
	///If this is considered starting knowledge, TRUE if yes
	var/is_starting_knowledge = FALSE
	/// In case we want to override the default UI icon getter and plug in our own icon instead.
	/// if research_tree_icon_path is not null, research_tree_icon_state must also be specified or things may break
	var/research_tree_icon_path
	var/research_tree_icon_state
	var/research_tree_icon_frame = 1
	var/research_tree_icon_dir = SOUTH

/** Called when the knowledge is first researched.
 * This is only ever called once per heretic.
 *
 * Arguments
 * * user - The heretic who researched something
 * * our_heretic - The antag datum of who researched us. This should never be null.
 */
/datum/heretic_knowledge/proc/on_research(mob/user, datum/antagonist/heretic/our_heretic)
	SHOULD_CALL_PARENT(TRUE)

	if(gain_text)
		to_chat(user, span_warning("[gain_text]"))

	on_gain(user, our_heretic)

/**
 * Called when the knowledge is applied to a mob.
 * This can be called multiple times per heretic,
 * in the case of bodyswap shenanigans.
 *
 * Arguments
 * * user - the heretic which we're applying things to
 * * our_heretic - The antag datum of who gained us. This should never be null.
 */
/datum/heretic_knowledge/proc/on_gain(mob/user, datum/antagonist/heretic/our_heretic, mind_transfer = FALSE)
	return

/**
 * Called when the knowledge is removed from a mob,
 * either due to a heretic being de-heretic'd or bodyswap memery.
 *
 * Arguments
 * * user - the heretic which we're removing things from
 * * our_heretic - The antag datum of who is losing us. This should never be null.
 */
/datum/heretic_knowledge/proc/on_lose(mob/user, datum/antagonist/heretic/our_heretic, mind_transfer = FALSE)
	return

/**
 * Determines if a heretic can actually attempt to invoke the knowledge as a ritual.
 * By default, we can only invoke knowledge with rituals associated.
 *
 * Return TRUE to have the ritual show up in the rituals list, FALSE otherwise.
 */
/datum/heretic_knowledge/proc/can_be_invoked(datum/antagonist/heretic/invoker)
	return !!LAZYLEN(required_atoms)

/**
 * Special check for rituals.
 * Called before any of the required atoms are checked.
 *
 * If you are adding a more complex summoning,
 * or something that requires a special check
 * that parses through all the atoms,
 * you should override this.
 *
 * Arguments
 * * user - the mob doing the ritual
 * * atoms - a list of all atoms being checked in the ritual.
 * * selected_atoms - an empty list(!) instance passed in by the ritual. You can add atoms to it in this proc.
 * * loc - the turf the ritual's occuring on
 *
 * Returns: TRUE, if the ritual will continue, or FALSE, if the ritual is skipped / cancelled
 */
/datum/heretic_knowledge/proc/recipe_snowflake_check(mob/living/user, list/atoms, list/selected_atoms, turf/loc)
	return TRUE

/**
 * Parses specific items into a more readble form.
 * Can be overriden by knoweldge subtypes.
 */
/datum/heretic_knowledge/proc/parse_required_item(atom/item_path, number_of_things)
	// If we need a human, there is a high likelihood we actually need a (dead) body
	if(ispath(item_path, /mob/living/carbon/human))
		return "bod[number_of_things > 1 ? "ies" : "y"]"

	if(ispath(item_path, /mob/living))
		return "carcass[number_of_things > 1 ? "es" : ""] of any kind"

	return "[initial(item_path.name)]\s"
/**
 * Called whenever the knowledge's associated ritual is completed successfully.
 *
 * Creates atoms from types in result_atoms.
 * Override this if you want something else to happen.
 * This CAN sleep, such as for summoning rituals which poll for ghosts.
 *
 * Arguments
 * * user - the mob who did the ritual
 * * selected_atoms - an list of atoms chosen as a part of this ritual.
 * * loc - the turf the ritual's occuring on
 *
 * Returns: TRUE, if the ritual should cleanup afterwards, or FALSE, to avoid calling cleanup after.
 */
/datum/heretic_knowledge/proc/on_finished_recipe(mob/living/user, list/selected_atoms, turf/loc)
	if(!length(result_atoms))
		return FALSE

	for(var/result in result_atoms)
		new result(loc)

	return TRUE

/**
 * Called after on_finished_recipe returns TRUE
 * and a ritual was successfully completed.
 *
 * Goes through and cleans up (deletes)
 * all atoms in the selected_atoms list.
 *
 * Remove atoms from the selected_atoms
 * (either in this proc or in on_finished_recipe)
 * to NOT have certain atoms deleted on cleanup.
 *
 * Arguments
 * * selected_atoms - a list of all atoms we intend on destroying.
 */
/datum/heretic_knowledge/proc/cleanup_atoms(list/selected_atoms)
	SHOULD_CALL_PARENT(TRUE)

	for(var/atom/sacrificed as anything in selected_atoms)
		if(isliving(sacrificed))
			continue

		if(!isstack(sacrificed))
			selected_atoms -= sacrificed
			qdel(sacrificed)
			continue

		var/obj/item/stack/sac_stack = sacrificed
		var/how_much_to_use = 0
		for(var/requirement in required_atoms)
			// If it's not requirement type and type is not a list, skip over this check
			if(!istype(sacrificed, requirement) && !islist(requirement))
				continue
			// If requirement *is* a list and the stack *is* in the list, skip over this check
			if(islist(requirement) && !is_type_in_list(sacrificed, requirement))
				continue
			how_much_to_use = min(required_atoms[requirement], sac_stack.amount)
			break

		sac_stack.use(how_much_to_use)
		continue

/**
 * A knowledge subtype that grants the heretic a certain spell.
 */
/datum/heretic_knowledge/spell
	abstract_parent_type = /datum/heretic_knowledge/spell
	/// Spell path we add to the heretic. Type-path.
	var/obj/effect/proc_holder/spell/spell_to_add


/datum/heretic_knowledge/spell/Destroy()
	spell_to_add = null
	return ..()


/datum/heretic_knowledge/spell/on_gain(mob/user, datum/antagonist/heretic/our_heretic, mind_transfer = FALSE)
	// Added spells are tracked on the body, and not the mind,
	// because we handle heretic mind transfers
	// via the antag datum (on_gain and on_lose).
	if(!spell_to_add || mind_transfer)
		return

	user.mind.AddSpell(new spell_to_add())

/datum/heretic_knowledge/spell/on_lose(mob/user, datum/antagonist/heretic/our_heretic, mind_transfer = FALSE)
	if(mind_transfer)
		return

	user.mind?.RemoveSpell(spell_to_add)

/**
 * A knowledge subtype for knowledge that can only
 * have a limited amount of its resulting atoms
 * created at once.
 */
/datum/heretic_knowledge/limited_amount
	abstract_parent_type = /datum/heretic_knowledge/limited_amount
	/// The limit to how many items we can create at once.
	var/limit = 1
	/// A list of weakrefs to all items we've created.
	var/list/datum/weakref/created_items

/datum/heretic_knowledge/limited_amount/Destroy(force)
	LAZYCLEARLIST(created_items)
	return ..()

/datum/heretic_knowledge/limited_amount/recipe_snowflake_check(mob/living/user, list/atoms, list/selected_atoms, turf/loc)
	for(var/datum/weakref/ref as anything in created_items)
		var/atom/real_thing = ref.resolve()
		if(!QDELETED(real_thing))
			continue

		LAZYREMOVE(created_items, ref)

	if(LAZYLEN(created_items) >= limit)
		loc.balloon_alert(user, "лимит создания преавышен!")
		return FALSE

	return TRUE


/datum/heretic_knowledge/limited_amount/on_finished_recipe(mob/living/user, list/selected_atoms, turf/loc)
	for(var/result in result_atoms)
		var/atom/created_thing = new result(loc)
		LAZYADD(created_items, WEAKREF(created_thing))

	return TRUE

/**
 * A knowledge subtype for limited_amount knowledge
 * used for base knowledge (the ones that make blades)
 *
 * A heretic can only learn one /starting type knowledge,
 * and their ascension depends on whichever they chose.
 */
/datum/heretic_knowledge/limited_amount/starting
	abstract_parent_type = /datum/heretic_knowledge/limited_amount/starting
	limit = 2
	cost = 1
	priority = MAX_KNOWLEDGE_PRIORITY - 5

/datum/heretic_knowledge/limited_amount/starting/on_research(mob/user, datum/antagonist/heretic/our_heretic)
	. = ..()
	our_heretic.heretic_path = GLOB.heretic_research_tree[type][HKT_ROUTE]
	SSblackbox.record_feedback("tally", "heretic_path_taken", 1, our_heretic.heretic_path)

/**
 * A knowledge subtype for heretic knowledge
 * that applies a mark on use.
 *
 * A heretic can only learn one /mark type knowledge.
 */
/datum/heretic_knowledge/mark
	abstract_parent_type = /datum/heretic_knowledge/mark
	cost = 2
	/// The status effect typepath we apply on people on mansus grasp.
	var/datum/status_effect/eldritch/mark_type

/datum/heretic_knowledge/mark/on_gain(mob/user, datum/antagonist/heretic/our_heretic, mind_transfer = FALSE)
	RegisterSignal(user, list(COMSIG_HERETIC_MANSUS_GRASP_ATTACK, COMSIG_LIONHUNTER_ON_HIT), PROC_REF(on_mansus_grasp), override = TRUE)
	RegisterSignal(user, COMSIG_HERETIC_BLADE_ATTACK, PROC_REF(on_eldritch_blade))

/datum/heretic_knowledge/mark/on_lose(mob/user, datum/antagonist/heretic/our_heretic, mind_transfer = FALSE)
	UnregisterSignal(user, list(COMSIG_HERETIC_MANSUS_GRASP_ATTACK, COMSIG_HERETIC_BLADE_ATTACK))

/**
 * Signal proc for [COMSIG_HERETIC_MANSUS_GRASP_ATTACK].
 *
 * Whenever we cast mansus grasp on someone, apply our mark.
 */
/datum/heretic_knowledge/mark/proc/on_mansus_grasp(mob/living/source, mob/living/target)
	SIGNAL_HANDLER

	create_mark(source, target)

/**
 * Signal proc for [COMSIG_HERETIC_BLADE_ATTACK].
 *
 * Whenever we attack someone with our blade, attempt to trigger any marks on them.
 */
/datum/heretic_knowledge/mark/proc/on_eldritch_blade(mob/living/source, mob/living/target, obj/item/melee/sickly_blade/blade)
	SIGNAL_HANDLER

	if(!isliving(target))
		return
	trigger_mark(source, target)

/**
 * Creates the mark status effect on our target.
 * This proc handles the instatiate and the application of the station effect,
 * and returns the /datum/status_effect instance that was made.
 *
 * Can be overriden to set or pass in additional vars of the status effect.
 */
/datum/heretic_knowledge/mark/proc/create_mark(mob/living/source, mob/living/target)
	if(target.stat == DEAD)
		return
	return target.apply_status_effect(mark_type)

/**
 * Handles triggering the mark on the target.
 *
 * If there is no mark, returns FALSE. Returns TRUE if a mark was triggered.
 */
/datum/heretic_knowledge/mark/proc/trigger_mark(mob/living/source, mob/living/target)
	var/datum/status_effect/eldritch/mark = target.has_status_effect(/datum/status_effect/eldritch)
	if(!istype(mark))
		return FALSE

	mark.on_effect()
	return TRUE

/**
 * A knowledge subtype for heretic knowledge that
 * upgrades their sickly blade, either on melee or range.
 *
 * A heretic can only learn one /blade_upgrade type knowledge.
 */
/datum/heretic_knowledge/blade_upgrade
	abstract_parent_type = /datum/heretic_knowledge/blade_upgrade
	cost = 2

/datum/heretic_knowledge/blade_upgrade/on_gain(mob/user, datum/antagonist/heretic/our_heretic, mind_transfer = FALSE)
	RegisterSignal(user, COMSIG_HERETIC_BLADE_ATTACK, PROC_REF(on_eldritch_blade))
	RegisterSignal(user, COMSIG_HERETIC_RANGED_BLADE_ATTACK, PROC_REF(on_ranged_eldritch_blade))

/datum/heretic_knowledge/blade_upgrade/on_lose(mob/user, datum/antagonist/heretic/our_heretic, mind_transfer = FALSE)
	UnregisterSignal(user, list(COMSIG_HERETIC_BLADE_ATTACK, COMSIG_HERETIC_RANGED_BLADE_ATTACK))


/**
 * Signal proc for [COMSIG_HERETIC_BLADE_ATTACK].
 *
 * Apply any melee effects from hitting someone with our blade.
 */
/datum/heretic_knowledge/blade_upgrade/proc/on_eldritch_blade(mob/living/source, mob/living/target, obj/item/melee/sickly_blade/blade)
	SIGNAL_HANDLER

	do_melee_effects(source, target, blade)

/**
 * Signal proc for [COMSIG_HERETIC_RANGED_BLADE_ATTACK].
 *
 * Apply any ranged effects from hitting someone with our blade.
 */
/datum/heretic_knowledge/blade_upgrade/proc/on_ranged_eldritch_blade(mob/living/source, mob/living/target, obj/item/melee/sickly_blade/blade)
	SIGNAL_HANDLER

	do_ranged_effects(source, target, blade)

/**
 * Overridable proc that invokes special effects
 * whenever the heretic attacks someone in melee with their heretic blade.
 */
/datum/heretic_knowledge/blade_upgrade/proc/do_melee_effects(mob/living/source, mob/living/target, obj/item/melee/sickly_blade/blade)
	return

/**
 * Overridable proc that invokes special effects
 * whenever the heretic clicks on someone at range with their heretic blade.
 */
/datum/heretic_knowledge/blade_upgrade/proc/do_ranged_effects(mob/living/source, mob/living/target, obj/item/melee/sickly_blade/blade)
	return

/**
 * A knowledge subtype lets the heretic summon a monster with the ritual.
 */
/datum/heretic_knowledge/summon
	abstract_parent_type = /datum/heretic_knowledge/summon
	/// Typepath of a mob to summon when we finish the recipe.
	var/mob/living/mob_to_summon

/datum/heretic_knowledge/summon/on_finished_recipe(mob/living/user, list/selected_atoms, turf/loc)
	return summon_ritual_mob(user, loc, mob_to_summon)

/**
 * Creates the ritual mob and grabs a ghost for it
 *
 * * user - the mob doing the summoning
 * * loc - where the summon is happening
 * * mob_to_summon - either a mob instance or a mob typepath
 */
/datum/heretic_knowledge/proc/summon_ritual_mob(mob/living/user, turf/loc, mob/living/mob_to_summon)
	var/mob/living/summoned
	if(isliving(mob_to_summon))
		summoned = mob_to_summon
	else
		summoned = new mob_to_summon(loc)

	summoned.ai_controller?.set_ai_status(AI_STATUS_OFF)
	// Fade in the summon while the ghost poll is ongoing.
	// Also don't let them mess with the summon while waiting
	summoned.alpha = 0
	ADD_TRAIT(summoned, TRAIT_NO_TRANSFORM, UID())
	summoned.move_resist = MOVE_FORCE_OVERPOWERING
	animate(summoned, 10 SECONDS, alpha = 155)

	message_admins("[summoned.name] был[genderize_ru(summoned.gender, "", "а", "о", "и")] призван[genderize_ru(summoned.gender, "", "а", "о", "ы")] [ADMIN_LOOKUPFLW(user)] в [ADMIN_COORDJMP(summoned)].")
	var/list/candidates = SSghost_spawns.poll_candidates("Вы бы хотели сыграть за [summoned.declent_ru(ACCUSATIVE)] призванн[genderize_ru(summoned.gender, "ого", "ую", "ое", "ых")] еретиком?", \
								null, FALSE, 10 SECONDS, TRUE, source = summoned)
	if(!candidates.len)
		loc.balloon_alert(user, "нет готовых кандидатов!")
		animate(summoned, 0.5 SECONDS, alpha = 0)
		QDEL_IN(summoned, 0.6 SECONDS)
		return FALSE

	var/mob/chosen_one = pick(candidates)
	// Ok let's make them an interactable mob now, since we got a ghost
	summoned.alpha = 255
	REMOVE_TRAIT(summoned, TRAIT_NO_TRANSFORM, UID())
	summoned.move_resist = initial(summoned.move_resist)

	summoned.ghostize(FALSE)
	summoned.key = chosen_one.key

	log_game("[key_name_log(user)] created a [summoned.name], controlled by [key_name(chosen_one)].")
	message_admins("[ADMIN_LOOKUPFLW(user)] created a [summoned.name], [ADMIN_LOOKUPFLW(summoned)].")

	var/datum/antagonist/heretic_monster/heretic_monster = summoned.mind.add_antag_datum(/datum/antagonist/heretic_monster)
	heretic_monster.set_owner(user.mind)
	ADD_TRAIT(heretic_monster, TRAIT_HERETIC_SUMMON, INNATE_TRAIT)

	var/datum/objective/heretic_summon/summon_objective = locate() in user.mind.get_all_objectives()
	summon_objective?.num_summoned++

	return TRUE

/// The amount of knowledge points the knowledge ritual gives on success.
#define KNOWLEDGE_RITUAL_POINTS 4

/**
 * A subtype of knowledge that generates random ritual components.
 */
/datum/heretic_knowledge/knowledge_ritual
	name = "Ритуал Знания"
	desc = "Случайный ритуал трансмутации, который дарует знания и может быть выполнен только один раз."
	gain_text = "Все может быть ключом к разгадке секретов за Вратами. Я должен быть осторожным и мудрым."
	abstract_parent_type = /datum/heretic_knowledge/knowledge_ritual
	cost = 1
	priority = MAX_KNOWLEDGE_PRIORITY - 10 // A pretty important midgame ritual.
	research_tree_icon_path = 'icons/obj/eldritch.dmi'
	research_tree_icon_state = "book_open"
	/// Whether we've done the ritual. Only doable once.
	var/was_completed = FALSE

/datum/heretic_knowledge/knowledge_ritual/New()
	. = ..()
	var/static/list/potential_organs = list(
		/obj/item/organ/internal/appendix,
		/obj/item/organ/external/tail,
		/obj/item/organ/internal/eyes,
		///obj/item/organ/internal/vocal_cords,
		/obj/item/organ/internal/ears,
		/obj/item/organ/internal/heart,
		/obj/item/organ/internal/liver,
		///obj/item/organ/internal/stomach,
		/obj/item/organ/internal/lungs,
	)

	var/static/list/potential_easy_items = list(
		/obj/item/shard,
		/obj/item/candle,
		/obj/item/book,
		/obj/item/pen,
		/obj/item/paper,
		/obj/item/toy/crayon,
		/obj/item/flashlight,
		/obj/item/clipboard,
	)

	var/static/list/potential_uncommoner_items = list(
		/obj/item/restraints/legcuffs/beartrap,
		/obj/item/restraints/handcuffs/cable/zipties,
		/obj/item/circular_saw,
		/obj/item/scalpel,
		/obj/item/clothing/gloves/color/yellow,
		/obj/item/melee/baton/security,
		/obj/item/clothing/glasses/sunglasses,
	)

	required_atoms = list()
	// 2 organs. Can be the same.
	required_atoms[pick(potential_organs)] += 1
	required_atoms[pick(potential_organs)] += 1
	// 2-3 random easy items.
	required_atoms[pick(potential_easy_items)] += rand(2, 3)
	// 1 uncommon item.
	required_atoms[pick(potential_uncommoner_items)] += 1


/datum/heretic_knowledge/knowledge_ritual/on_research(mob/user, datum/antagonist/heretic/our_heretic)
	. = ..()

	var/list/requirements_string = list()

	to_chat(user, span_hierophant("[name] требует следующих подношений:"))
	for(var/obj/item/path as anything in required_atoms)
		var/amount_needed = required_atoms[path]
		to_chat(user, span_purple("[amount_needed] [initial(path.name)]\s..."))
		requirements_string += "[amount_needed == 1 ? "":"[amount_needed] "][initial(path.name)]\s"

	to_chat(user, span_hierophant("Завершив этот ритуал вы получите в награду [KNOWLEDGE_RITUAL_POINTS] очков знаний. Вы можете проверить свои знания в разделе «Изученные знания»."))
	desc = "Позволяет трансмутировать [english_list(requirements_string)] в [KNOWLEDGE_RITUAL_POINTS] дополнительных очков знаний. Этот ритуал может быть проведен только один раз."


/datum/heretic_knowledge/knowledge_ritual/can_be_invoked(datum/antagonist/heretic/invoker)
	return !was_completed


/datum/heretic_knowledge/knowledge_ritual/recipe_snowflake_check(mob/living/user, list/atoms, list/selected_atoms, turf/loc)
	return !was_completed


/datum/heretic_knowledge/knowledge_ritual/on_finished_recipe(mob/living/user, list/selected_atoms, turf/loc)
	var/datum/antagonist/heretic/our_heretic = user.mind.has_antag_datum(/datum/antagonist/heretic)
	our_heretic.knowledge_points += KNOWLEDGE_RITUAL_POINTS
	was_completed = TRUE

	to_chat(user, span_boldnotice("[name] завершен!"))
	to_chat(user, span_purple(span_big("[pick_list(HERETIC_INFLUENCE_FILE, "drain_message")]")))
	desc += " (Завершен!)"
	user.store_memory("Проведен Ритуал Знания.")
	return TRUE

#undef KNOWLEDGE_RITUAL_POINTS

/**
 * The special final tier of knowledges that unlocks ASCENSION.
 */
/datum/heretic_knowledge/ultimate
	abstract_parent_type = /datum/heretic_knowledge/ultimate
	cost = 2
	priority = MAX_KNOWLEDGE_PRIORITY + 1 // Yes, the final ritual should be ABOVE the max priority.
	required_atoms = list(/mob/living/carbon/human = 3)
	/// The typepath of the achievement to grant upon successful ascension.
	//var/datum/award/achievement/misc/ascension_achievement
	/// The text of the ascension announcement.
	/// %NAME% is replaced with the heretic's real name,
	/// and %SPOOKY% is replaced with output from [generate_heretic_text]
	var/announcement_text
	/// The sound that's played for the ascension announcement.
	var/announcement_sound


/datum/heretic_knowledge/ultimate/can_be_invoked(datum/antagonist/heretic/invoker, say_result = FALSE)
	if(invoker.ascended)
		return FALSE

	if(!invoker.can_ascend(say_result))
		return FALSE

	return TRUE


/datum/heretic_knowledge/ultimate/recipe_snowflake_check(mob/living/user, list/atoms, list/selected_atoms, turf/loc, say_result = FALSE)
	var/datum/antagonist/heretic/heretic_datum = user.mind.has_antag_datum(/datum/antagonist/heretic)
	if(!can_be_invoked(heretic_datum, TRUE))
		return FALSE

	// Remove all non-dead humans from the atoms list.
	// (We only want to sacrifice dead folk.)
	for(var/mob/living/carbon/human/sacrifice in atoms)
		if(is_valid_sacrifice(sacrifice))
			continue

		atoms -= sacrifice

	// All the non-dead humans are removed in this proc.
	// We handle checking if we have enough humans in the ritual itself.
	return TRUE


/**
 * Checks if the passed human is a valid sacrifice for our ritual.
 */
/datum/heretic_knowledge/ultimate/proc/is_valid_sacrifice(mob/living/carbon/human/sacrifice)
	return (sacrifice.stat == DEAD) && !ismonkey(sacrifice)


/datum/heretic_knowledge/ultimate/on_finished_recipe(mob/living/user, list/selected_atoms, turf/loc)
	var/datum/antagonist/heretic/heretic_datum = user.mind.has_antag_datum(/datum/antagonist/heretic)
	heretic_datum.ascended = TRUE

	// Show the cool red gradiant in our UI
	heretic_datum.update_static_data(user)

	if(ishuman(user))
		var/mob/living/carbon/human/human_user = user
		human_user.physiology.brute_mod *= 0.5
		human_user.physiology.burn_mod *= 0.5

	SSblackbox.record_feedback("tally", "heretic_ascended", 1, GLOB.heretic_research_tree[type][HKT_ROUTE])
	notify_ghosts(
		"[user.real_name] завершил[genderize_ru(user.gender, "", "а", "о", "и")] ритуал вознесения!",
		source = user,
		title = "Еретик Вознесся!",
	)
	GLOB.major_announcement.announce(
		message = replacetext(replacetext(announcement_text, "%NAME%", user.real_name), "%SPOOKY%", GLOBAL_PROC_REF(generate_heretic_text)),
		new_title = generate_heretic_text(),
		new_sound = announcement_sound
	)

	heretic_datum.increase_rust_strength()
	SSshuttle.emergency.request(coefficient = 0.5)
	return TRUE


/datum/heretic_knowledge/ultimate/cleanup_atoms(list/selected_atoms)
	for(var/mob/living/carbon/human/sacrifice in selected_atoms)
		selected_atoms -= sacrifice
		sacrifice.gib()

	return ..()
