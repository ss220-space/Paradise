// The knowledge and process of heretic sacrificing.

/// How long we put the target so sleep for(during sacrifice).
#define SACRIFICE_SLEEP_DURATION (12 SECONDS)
/// How long sacrifices must stay in the shadow realm to survive.
#define SACRIFICE_REALM_DURATION (2.5 MINUTES)

/**
 * Allows the heretic to sacrifice living heart targets.
 */
/datum/heretic_knowledge/hunt_and_sacrifice
	name = "Сердцебиение Мансуса"
	desc = "Позволяет приносить цели в жертву Мансусу, положив их в руну в критическом (или худшем) состоянии. \
			Если у вас нет целей, встаньте на руну трансмутации и проведите этот ритуал, чтобы получить их."
	required_atoms = list(/mob/living/carbon/human = 1)
	cost = 0
	priority = MAX_KNOWLEDGE_PRIORITY // Should be at the top
	is_starting_knowledge = TRUE
	research_tree_icon_path = 'icons/effects/eldritch.dmi'
	research_tree_icon_state = "eye_close"
	research_tree_icon_frame = 1
	/// How many targets do we generate?
	var/num_targets_to_generate = 5
	/// Whether we've generated a heretic sacrifice z-level yet, from any heretic.
	var/static/heretic_level_generated = FALSE
	/// A weakref to the mind of our heretic.
	var/datum/mind/heretic_mind
	/// Lazylist of minds that we won't pick as targets.
	var/list/datum/mind/target_blacklist
	/// An assoc list of [ref] to [timers] - a list of all the timers of people in the shadow realm currently
	var/list/return_timers
	/// Evil organs we can put in people
	var/static/list/grantable_organs = list(
		/obj/item/organ/internal/appendix/corrupt,
		/obj/item/organ/internal/eyes/corrupt,
		/obj/item/organ/internal/heart/corrupt,
		/obj/item/organ/internal/liver/corrupt,
		/obj/item/organ/internal/lungs/corrupt,
		///obj/item/organ/internal/stomach/corrupt,
		/obj/item/organ/internal/vocal_cords/corrupt,
	)


/datum/heretic_knowledge/hunt_and_sacrifice/Destroy(force)
	heretic_mind = null
	LAZYCLEARLIST(target_blacklist)
	return ..()


/datum/heretic_knowledge/hunt_and_sacrifice/on_research(mob/user, datum/antagonist/heretic/our_heretic)
	. = ..()
	obtain_targets(user, silent = TRUE, heretic_datum = our_heretic)
	heretic_mind = our_heretic.owner

//#ifndef UNIT_TESTS // This is a decently hefty thing to generate while unit testing, so we should skip it.
	//if(!heretic_level_generated)
		//heretic_level_generated = TRUE
		//log_game("Loading heretic lazytemplate for heretic sacrifices...")
		//`INVOKE_ASYNC(src, PROC_REF(generate_heretic_z_level))
//#endif
/*
/// Generate the sacrifice z-level.
/datum/heretic_knowledge/hunt_and_sacrifice/proc/generate_heretic_z_level()
	if(!SSmapping.lazy_load_template(LAZY_TEMPLATE_KEY_HERETIC_SACRIFICE))
		log_game("The heretic sacrifice template failed to load.")
		message_admins("The heretic sacrifice lazy template failed to load. Heretic sacrifices won't be teleported to the shadow realm. \
			If you want, you can spawn an /obj/effect/landmark/heretic somewhere to stop that from happening.")
		CRASH("Failed to lazy load heretic sacrifice template!")
*/

/datum/heretic_knowledge/hunt_and_sacrifice/recipe_snowflake_check(mob/living/user, list/atoms, list/selected_atoms, turf/loc)
	var/datum/antagonist/heretic/heretic_datum = user.mind.has_antag_datum(/datum/antagonist/heretic)
	// First we have to check if the heretic has a Living Heart.
	// You may wonder why we don't straight up prevent them from invoking the ritual if they don't have one -
	// Hunt and sacrifice should always be invokable for clarity's sake, even if it'll fail immediately.
	if(heretic_datum.has_living_heart() != HERETIC_HAS_LIVING_HEART)
		loc.balloon_alert(user, "нет живого сердца!")
		return FALSE

	// We've got no targets set, let's try to set some.
	// If we recently failed to acquire targets, we will be unable to acquire any.
	if(!LAZYLEN(heretic_datum.sac_targets))
		atoms += user
		return TRUE

	// If we have targets, we can check to see if we can do a sacrifice
	// Let's remove any humans in our atoms list that aren't a sac target
	for(var/mob/living/carbon/human/sacrifice in atoms)
		// If the mob's not in soft crit or worse, remove from list
		if(sacrifice.stat == CONSCIOUS)
			atoms -= sacrifice
			continue

		// Otherwise if it's neither a target nor a cultist, remove it
		if((sacrifice in heretic_datum.sac_targets) || iscultist(sacrifice))
			continue

		atoms -= sacrifice

	// Finally, return TRUE if we have a target in the list
	if(locate(/mob/living/carbon/human) in atoms)
		return TRUE

	// or FALSE if we don't
	loc.balloon_alert(user, "жертва не найдена!")
	return FALSE


/datum/heretic_knowledge/hunt_and_sacrifice/on_finished_recipe(mob/living/user, list/selected_atoms, turf/loc)
	var/datum/antagonist/heretic/heretic_datum = user.mind.has_antag_datum(/datum/antagonist/heretic)
	// Force it to work if the sacrifice is a cultist, even if there's no targets.
	var/mob/living/carbon/human/sac = selected_atoms[1]
	if(!LAZYLEN(heretic_datum.sac_targets) && !iscultist(sac))
		if(obtain_targets(user, heretic_datum = heretic_datum))
			return TRUE

		loc.balloon_alert(user, "цели не найдены!")
		return FALSE

	sacrifice_process(user, selected_atoms, loc)
	return TRUE

/**
 * Obtain a list of targets for the user to hunt down and sacrifice.
 * Tries to get four targets (minds) with living human currents.
 *
 * Returns FALSE if no targets are found, TRUE if the targets list was populated.
 */
/datum/heretic_knowledge/hunt_and_sacrifice/proc/obtain_targets(mob/living/user, silent = FALSE, datum/antagonist/heretic/heretic_datum)

	// First construct a list of minds that are valid objective targets.
	var/list/datum/mind/valid_targets = list()
	for(var/datum/mind/possible_target as anything in SSticker.minds)
		if(possible_target == user.mind)
			continue

		if(possible_target in target_blacklist)
			continue

		if(!ishuman(possible_target.current))
			continue

		if(possible_target.current.stat == DEAD)
			continue

		if(!is_station_level(possible_target.current.z))
			continue

		valid_targets += possible_target

	if(!length(valid_targets))
		if(!silent)
			to_chat(user, span_hierophant_warning("Целей для жертвоприношения не обнаружено!"))

		return FALSE

	// Now, let's try to get four targets.
	// - One completely random
	// - One from your department
	// - One from security
	// - One from heads of staff ("high value")
	var/list/datum/mind/final_targets = list()

	// First target, any command.
	for(var/datum/mind/head_mind as anything in shuffle(valid_targets))
		if(!head_mind?.assigned_job?.is_command)
			continue

		final_targets += head_mind
		valid_targets -= head_mind
		break

	// Second target, any security
	for(var/datum/mind/sec_mind as anything in shuffle(valid_targets))
		if(!HASBIT(sec_mind?.assigned_job?.department_flag, JOBCAT_ENGSEC))
			continue

		final_targets += sec_mind
		valid_targets -= sec_mind
		break

	// Third target, someone in their department.
	for(var/datum/mind/department_mind as anything in shuffle(valid_targets))
		if(!HASBIT(department_mind?.assigned_job?.department_flag, user.mind.assigned_job?.department_flag))
			continue

		final_targets += department_mind
		valid_targets -= department_mind
		break

	// Now grab completely random targets until we'll full
	var/target_sanity = 0
	while(length(final_targets) < num_targets_to_generate && target_sanity < 25 && valid_targets.len)
		final_targets += pick_n_take(valid_targets)
		target_sanity++

	if(!silent)
		to_chat(user, span_danger("Ваши цели определены. Ваше Живое Сердце позволит вам отслеживать их местоположение. Идите и принесите их в жертву!"))

	for(var/datum/mind/chosen_mind as anything in final_targets)
		heretic_datum.add_sacrifice_target(chosen_mind.current)
		if(silent)
			continue

		to_chat(user, span_danger("[chosen_mind.current.real_name] - [chosen_mind.assigned_role]."))

	return TRUE

/**
 * Begin the process of sacrificing the target.
 *
 * Arguments
 * * user - the mob doing the sacrifice (a heretic)
 * * selected_atoms - a list of all atoms chosen. Should be (at least) one human.
 * * loc - the turf the sacrifice is occurring on
 */
/datum/heretic_knowledge/hunt_and_sacrifice/proc/sacrifice_process(mob/living/user, list/selected_atoms, turf/loc)

	var/datum/antagonist/heretic/heretic_datum = user.mind.has_antag_datum(/datum/antagonist/heretic)
	var/mob/living/carbon/human/sacrifice = locate() in selected_atoms
	if(!sacrifice)
		CRASH("[type] sacrifice_process didn't have a human in the atoms list. How'd it make it so far?")
	if(!(sacrifice in heretic_datum.sac_targets) && !iscultist(sacrifice))
		CRASH("[type] sacrifice_process managed to get a non-target, non-cult human. This is incorrect.")

	if(sacrifice.mind)
		LAZYADD(target_blacklist, sacrifice.mind)

	heretic_datum.remove_sacrifice_target(sacrifice)
	var/feedback = "Ваши покровители принимают вашу жертву"
	var/datum/job/sac_job = sacrifice.mind?.assigned_job
	// Heads give 3 points, cultists give 1 point (and a special reward), normal sacrifices give 2 points.
	heretic_datum.total_sacrifices++
	if(sac_job?.is_command)
		heretic_datum.knowledge_points += 3
		heretic_datum.high_value_sacrifices++
		feedback += "Ваши покровители <i>с радостью</i> принимают вашу жертву"

	if(!iscultist(sacrifice))
		heretic_datum.knowledge_points += 2
		to_chat(user, span_purple("[feedback]."))
		if(!begin_sacrifice(sacrifice))
			disembowel_target(sacrifice)
			return

		sacrifice.apply_status_effect(/datum/status_effect/heretic_curse, user)
		return

	heretic_datum.knowledge_points += 2
	grant_reward(user, sacrifice, loc)
	// easier to read
	var/rewards_given = heretic_datum.rewards_given
	// Chance for it to send a warning to cultists, higher with each reward. Stops after 5 because they probably got the hint by then.
	if(!prob(min(15 * rewards_given)) || (rewards_given > 5))
		return

	for(var/datum/mind/mind as anything in SSticker.mode.cult)
		if(!mind.current)
			continue

		SEND_SOUND(mind.current, 'sound/magic/clockwork/narsie_attack.ogg')
		var/message = span_narsie("Подлый еретик ") + \
		span_cultlarge(span_purple("принес в жертву")) + \
		span_narsie(" одного из наших. Уничтожьте и принеси в жертву неверных, прежде чем они принесут в жертву нас!")
		to_chat(mind.current, message)

	// he(retic) gets a warn too
	to_chat(user, span_narsiesmall("Да как ты СМЕЕШЬ!? Я тебя уничтожу!"))
	var/non_flavor_warning = span_cultbold("Вы чувствуете, что ваши действия привлекли ") + span_purple("внимание") + span_cultbold(".")
	to_chat(user, non_flavor_warning)


/datum/heretic_knowledge/hunt_and_sacrifice/proc/grant_reward(mob/living/user, mob/living/sacrifice, turf/loc)

	// Visible and audible encouragement!
	to_chat(user, span_big(span_purple("Слуга Сангвинического Отступника!")))
	to_chat(user, span_hierophant("Ваши покровители в восторге!"))
	playsound(sacrifice, 'sound/magic/disintegrate.ogg', 75, TRUE)

	// Drop all items and splatter them around messily.
	var/list/dustee_items = sacrifice.unequip_everything()
	for(var/obj/item/loot as anything in dustee_items)
		loot.throw_at(get_step_rand(sacrifice), 2, 4, user, TRUE)

	// The loser is DUSTED.
	sacrifice.dust(TRUE, TRUE)

	// Increase reward counter
	var/datum/antagonist/heretic/antag = user.mind.has_antag_datum(/datum/antagonist/heretic)
	antag.rewards_given++

	// Cool effect for the rune as well as the item
	var/obj/effect/decal/heretic_rune/rune = locate() in range(2, user)
	if(rune)
		rune.gender_reveal(
			outline_color = COLOR_CULT_RED,
			ray_color = null,
			do_float = FALSE,
			do_layer = FALSE,
		)

	addtimer(CALLBACK(src, PROC_REF(deposit_reward), user, loc, null, rune), 5 SECONDS)


/datum/heretic_knowledge/hunt_and_sacrifice/proc/deposit_reward(mob/user, turf/loc, loop = 0, obj/rune)
	if(loop > 5) // Max limit for retrying a reward
		return
	// Remove the outline, we don't need it anymore.
	rune?.remove_filter("reward_outline")
	playsound(loc, 'sound/magic/repulse.ogg', 75, TRUE)
	var/datum/antagonist/heretic/heretic_datum = user.mind.has_antag_datum(/datum/antagonist/heretic)
	ASSERT(heretic_datum)
	// This list will be almost identical to unlocked_heretic_items, with the same keys, the difference being the values will be 1 to 5.
	var/list/rewards = heretic_datum.unlocked_heretic_items.Copy()
	// We will make it increasingly less likely to get a reward if you've already got it
	for(var/possible_reward in heretic_datum.unlocked_heretic_items)
		var/amount_already_awarded = heretic_datum.unlocked_heretic_items[possible_reward]
		rewards[possible_reward] = min(5 - (amount_already_awarded * 2), 1)

	var/atom/reward = pick_weight_classic(rewards)
	reward = new reward(loc)

	if(isliving(reward))
		if(summon_ritual_mob(user, loc, reward) != FALSE)
			return

		qdel(reward)
		deposit_reward(user, loc, loop++, rune) // If no ghosts, try again until limit is hit
		return

	if(isitem(reward))
		var/obj/item/item_reward = reward
		item_reward.gender_reveal(outline_color = null, ray_color = COLOR_CULT_RED)

	ASSERT(reward)
	return reward

/**
 * This proc is called from [proc/sacrifice_process] after the heretic successfully sacrifices [sac_target].)
 *
 * Sets off a chain that sends the person sacrificed to the shadow realm to dodge hands to fight for survival.
 *
 * Arguments
 * * sac_target - the mob being sacrificed.
 */
/datum/heretic_knowledge/hunt_and_sacrifice/proc/begin_sacrifice(mob/living/carbon/human/sac_target)
	. = FALSE

	var/datum/antagonist/heretic/our_heretic = heretic_mind?.has_antag_datum(/datum/antagonist/heretic)
	if(!our_heretic)
		CRASH("[type] - begin_sacrifice was called, and no heretic [heretic_mind ? "antag datum":"mind"] could be found!")

	//if(!LAZYLEN(GLOB.heretic_sacrifice_landmarks))
		//CRASH("[type] - begin_sacrifice was called, but no heretic sacrifice landmarks were found!")

	var/obj/effect/landmark/heretic/destination_landmark = GLOB.heretic_sacrifice_landmarks[our_heretic.heretic_path] || GLOB.heretic_sacrifice_landmarks[PATH_START]
	//if(!destination_landmark)
	//	CRASH("[type] - begin_sacrifice could not find a destination landmark OR default landmark to send the sacrifice! (Heretic's path: [our_heretic.heretic_path])")

	var/turf/destination = get_turf(destination_landmark)

	sac_target.visible_message(span_danger("[sac_target.declent_ru(NOMINATIVE)] начинает яростно содрогаться, когда темные щупальца утаскивают [genderize_ru(sac_target.gender, "его", "её", "его", "их")] в пустоту!"))
	sac_target.set_handcuffed(new /obj/item/restraints/handcuffs/energy/cult(sac_target))

	if(sac_target.legcuffed)
		sac_target.legcuffed.forceMove(sac_target.drop_location())
		sac_target.legcuffed.dropped(sac_target)
		sac_target.legcuffed = null
		sac_target.update_legcuffed_status()
		//sac_target.update_worn_legcuffs()

	sac_target.adjustOrganLoss(INTERNAL_ORGAN_BRAIN, 85, 150)
	sac_target.do_jitter_animation()
	//log_combat(heretic_mind.current, sac_target, "sacrificed")

	addtimer(CALLBACK(sac_target, TYPE_PROC_REF(/mob/living/carbon, do_jitter_animation)), SACRIFICE_SLEEP_DURATION * (1/3))
	addtimer(CALLBACK(sac_target, TYPE_PROC_REF(/mob/living/carbon, do_jitter_animation)), SACRIFICE_SLEEP_DURATION * (2/3))

	// If our target is dead, try to revive them
	// and if we fail to revive them, don't proceede the chain
	sac_target.adjustOxyLoss(-100, FALSE)
	if(!sac_target.heal_and_revive(50, span_danger("Сердце [sac_target.declent_ru(GENITIVE)] начинает биться с нечестивой силой, когда [genderize_ru(sac_target.gender, "он", "она", "ого", "они")] возвраща[pluralize_ru(sac_target.gender, "е", "ю")]тся из объятий смерти!")))
		return

	if(sac_target.Sleeping(SACRIFICE_SLEEP_DURATION))
		to_chat(sac_target, span_purple("Ваш разум разрывается на части, когда вы погружаетесь в поверхностный сон..."))
	else
		to_chat(sac_target, span_purple("Ваш разум начинает разрываться на части, когда вы видите, как вас окутывают темные щупальца."))

	sac_target.AdjustParalysis(SACRIFICE_SLEEP_DURATION * 1.2)
	sac_target.AdjustImmobilized(SACRIFICE_SLEEP_DURATION * 1.2)

	addtimer(CALLBACK(src, PROC_REF(after_target_sleeps), sac_target, destination), SACRIFICE_SLEEP_DURATION * 0.5) // Teleport to the minigame
	return TRUE

/**
 * This proc is called from [proc/begin_sacrifice] after the [sac_target] falls asleep), shortly after the sacrifice occurs.
 *
 * Teleports the [sac_target] to the heretic room, asleep.
 * If it fails to teleport, they will be disemboweled and stop the chain.
 *
 * Arguments
 * * sac_target - the mob being sacrificed.
 * * destination - the spot they're being teleported to.
 */
/datum/heretic_knowledge/hunt_and_sacrifice/proc/after_target_sleeps(mob/living/carbon/human/sac_target, turf/destination)
	if(QDELETED(sac_target))
		return

	// The target disconnected or something, we shouldn't bother sending them along.
	sac_target.grab_ghost()
	if(!sac_target.client || !sac_target.mind)
		disembowel_target(sac_target)
		return

	curse_organs(sac_target)

	// Send 'em to the destination. If the teleport fails, just disembowel them and stop the chain
	if(!destination || !do_teleport(sac_target, destination, asoundin = 'sound/magic/repulse.ogg', asoundout = 'sound/magic/blind.ogg', bypass_area_flag = TRUE))
		disembowel_target(sac_target)
		return

	// If our target died during the (short) wait timer,
	// and we fail to revive them (using a lower number than before),
	// just disembowel them and stop the chain
	sac_target.adjustOxyLoss(-100, FALSE)
	if(!sac_target.heal_and_revive(60, span_danger("Сердце [sac_target.declent_ru(GENITIVE)] начинает биться с нечестивой силой, когда [genderize_ru(sac_target.gender, "он", "она", "ого", "они")] возвраща[pluralize_ru(sac_target.gender, "е", "ю")]тся из объятий смерти!")))
		disembowel_target(sac_target)
		return

	to_chat(sac_target, span_big(span_purple("Противоестественные силы из-за завесы начинают терзать ваши тело и душу!")))
	playsound(sac_target, 'sound/music/heretic/heretic_sacrifice.ogg', 50, FALSE) // play theme

	sac_target.apply_status_effect(/datum/status_effect/unholy_determination, SACRIFICE_REALM_DURATION)
	addtimer(CALLBACK(src, PROC_REF(after_target_wakes), sac_target), SACRIFICE_SLEEP_DURATION * 0.5) // Begin the minigame

	RegisterSignal(sac_target, COMSIG_MOVABLE_Z_CHANGED, PROC_REF(on_target_escape)) // Cheese condition
	RegisterSignal(sac_target, COMSIG_LIVING_DEATH, PROC_REF(on_target_death)) // Loss condition


/// Apply a sinister curse to some of the target's organs as an incentive to leave us alone
/datum/heretic_knowledge/hunt_and_sacrifice/proc/curse_organs(mob/living/carbon/human/sac_target)
	var/usable_organs = grantable_organs.Copy()
	if(isplasmaman(sac_target))
		usable_organs -= /obj/item/organ/internal/lungs/corrupt // Their lungs are already more cursed than anything I could give them

	var/total_implant = rand(2, 4)

	for(var/i in 1 to total_implant)
		if(!length(usable_organs))
			return

		var/organ_path = pick_n_take(usable_organs)
		var/obj/item/organ/to_give = new organ_path
		to_give.safe_replace(sac_target)

	new /obj/effect/gibspawner/human/bodypartless(get_turf(sac_target), sac_target.dna)
	sac_target.visible_message(span_boldwarning("Несколько органов вылетают из тела [sac_target.declent_ru(GENITIVE)] направляемые таинственной силой!"))

/**
 * This proc is called from [proc/after_target_sleeps] when the [sac_target] should be waking up.)
 *
 * Begins the survival minigame, featuring the sacrifice targets.
 * Gives them Helgrasp, throwing cursed hands towards them that they must dodge to survive.
 * Also gives them a status effect, Unholy Determination, to help them in this endeavor.
 *
 * Then applies some miscellaneous effects.
 */
/datum/heretic_knowledge/hunt_and_sacrifice/proc/after_target_wakes(mob/living/carbon/human/sac_target)
	if(QDELETED(sac_target))
		return

	// About how long should the helgrasp last? (1 metab a tick = helgrasp_time / 2 ticks (so, 1 minute = 60 seconds = 30 ticks))
	var/helgrasp_time = 1 MINUTES

	sac_target.reagents?.add_reagent(/datum/reagent/inverse/helgrasp/heretic, helgrasp_time / 20)
	sac_target.apply_necropolis_curse(CURSE_BLINDING | CURSE_GRASPING)

	sac_target.flash_eyes()
	sac_target.SetSleeping(0 SECONDS)
	sac_target.EyeBlurry(30 SECONDS)
	sac_target.Jitter(20 SECONDS)
	sac_target.Dizzy(20 SECONDS)
	sac_target.Hallucinate(24 SECONDS)
	sac_target.emote("scream")

	//to_chat(sac_target, span_reallybig(span_purple("Прикосновение Мансус открывается вам!")))
	to_chat(sac_target, span_purple("Вы чувствуете прилив сил! Боритесь чтобывыжить!"))
	// When it runs out, let them know they're almost home free
	addtimer(CALLBACK(src, PROC_REF(after_helgrasp_ends), sac_target), helgrasp_time)
	// Win condition
	var/win_timer = addtimer(CALLBACK(src, PROC_REF(return_target), sac_target), SACRIFICE_REALM_DURATION, TIMER_STOPPABLE)
	LAZYSET(return_timers, sac_target.UID(), win_timer)

/**
 * This proc is called from [proc/after_target_wakes] after the helgrasp runs out in the [sac_target].)
 *
 * It gives them a message letting them know it's getting easier and they're almost free.
 */
/datum/heretic_knowledge/hunt_and_sacrifice/proc/after_helgrasp_ends(mob/living/carbon/human/sac_target)
	if(QDELETED(sac_target) || sac_target.stat == DEAD)
		return

	// Давай! давай давай давай давай давай❤️ ты сможешь🤗верь в себя🙏зайка🥺верь💘давай давай!! поднажми)) ☝🏼еще чуть-чуть...прошу тебя😕не здавайся😘поднажми😉ты все сможешь!! 😭
	// Sorry
	to_chat(sac_target, span_purple("Худшее позади... Осталось совсем немного! Держитесь, иначе погибните!"))

/**
 * This proc is called from [proc/begin_sacrifice] if the target survived the shadow realm), or [COMSIG_LIVING_DEATH] if they don't.
 *
 * Teleports [sac_target] back to a random safe turf on the station (or observer spawn if it fails to find a safe turf).
 * Also clears their status effects, unregisters any signals associated with the shadow realm, and sends a message
 * to the heretic who did the sacrificed about whether they survived, and where they ended up.
 *
 * Arguments
 * * sac_target - the mob being sacrificed
 * * heretic - the heretic who originally did the sacrifice.
 */
/datum/heretic_knowledge/hunt_and_sacrifice/proc/return_target(mob/living/carbon/human/sac_target)
	if(QDELETED(sac_target))
		return

	var/current_timer = LAZYACCESS(return_timers, sac_target.UID())
	if(current_timer)
		deltimer(current_timer)

	LAZYREMOVE(return_timers, sac_target.UID())

	UnregisterSignal(sac_target, COMSIG_MOVABLE_Z_CHANGED)
	UnregisterSignal(sac_target, COMSIG_LIVING_DEATH)
	sac_target.remove_status_effect(/datum/status_effect/necropolis_curse)
	sac_target.remove_status_effect(/datum/status_effect/unholy_determination)
	sac_target.reagents?.del_reagent(/datum/reagent/inverse/helgrasp/heretic)
	sac_target.uncuff()
	//sac_target.clear_mood_event("shadow_realm")
	if(isheretic(sac_target))
		var/datum/antagonist/heretic/victim_heretic = sac_target.mind?.has_antag_datum(/datum/antagonist/heretic)
		victim_heretic.knowledge_points -= 3

	// Wherever we end up, we sure as hell won't be able to explain
	sac_target.apply_status_effect(/*/datum/status_effect/speech/slurring/heretic*/ STATUS_EFFECT_CLOCK_CULT_SLUR, 40 SECONDS)
	sac_target.Stuttering(40 SECONDS)

	// They're already back on the station for some reason, don't bother teleporting
	var/turf/below_target = get_turf(sac_target)
	// is_station_level runtimes when passed z = 0, so I'm being very explicit here about checking for nullspace until fixed
	// otherwise, we really don't want this to runtime error, as it'll get people stuck in hell forever - not ideal!
	if(below_target && below_target.z != 0 && is_station_level(below_target.z))
		return

	// Teleport them to a random safe coordinate on the station z level.
	var/turf/simulated/floor/safe_turf = get_safe_random_station_turf()
	var/obj/effect/landmark/observer_start/backup_loc = locate(/obj/effect/landmark/observer_start) in GLOB.landmarks_list
	if(!safe_turf)
		safe_turf = get_turf(backup_loc)
		stack_trace("[type] - return_target was unable to find a safe turf for [sac_target] to return to. Defaulting to observer start turf.")

	if(!do_teleport(sac_target, safe_turf, asoundout = 'sound/magic/blind.ogg'/*, forced = TRUE*/))
		safe_turf = get_turf(backup_loc)
		sac_target.forceMove(safe_turf)
		stack_trace("[type] - return_target was unable to teleport [sac_target] to the observer start turf. Forcemoving.")

	if(sac_target.stat == DEAD)
		after_return_dead_target(sac_target)
	else
		after_return_live_target(sac_target)

	if(!heretic_mind?.current)
		return

	var/composed_return_message = ""
	composed_return_message += span_notice("Ваша жертва, [sac_target.declent_ru(NOMINATIVE)], была возвращена на станцию - ")
	if(sac_target.stat == DEAD)
		composed_return_message += span_red("мёртвой. ")
	else
		composed_return_message += span_green("живой, но с разбитым разумом. ")

	composed_return_message += span_notice("Вы слышите шепот...")
	composed_return_message += span_purple(get_area_name(safe_turf, TRUE))
	to_chat(heretic_mind.current, composed_return_message)

/**
 * If they die in the shadow realm, they lost. Send them back.
 */
/datum/heretic_knowledge/hunt_and_sacrifice/proc/on_target_death(mob/living/carbon/human/sac_target, gibbed)
	SIGNAL_HANDLER

	if(gibbed) // Nothing to return
		return

	return_target(sac_target)

/**
 * If they somehow cheese the shadow realm by teleporting out, they are disemboweled and killed.
 */
/datum/heretic_knowledge/hunt_and_sacrifice/proc/on_target_escape(mob/living/carbon/human/sac_target, old_z, new_z)
	SIGNAL_HANDLER

	to_chat(sac_target, span_boldwarning("Ваша попытка сбежать от Мансуса не будет встречена благосклонно!"))
	// Ends up calling return_target() via death signal to clean up.
	disembowel_target(sac_target)

/**
 * This proc is called from [proc/return_target] if the [sac_target] survives the shadow realm.)
 *
 * Gives the sacrifice target some after effects upon ariving back to reality.
 */
/datum/heretic_knowledge/hunt_and_sacrifice/proc/after_return_live_target(mob/living/carbon/human/sac_target)
	to_chat(sac_target, span_purple("Борьба окончена, но дорогой ценой. Вы вернулись на станцию целым и невредимым."))
	if(isheretic(sac_target))
		to_chat(sac_target, span_big(span_purple("Вы не помните ничего, что предшествовало этому опыту, \
											но чувствуете, что ваша связь с Мансусом ослабла — когда-то известные знания забыты...")))
	else
		to_chat(sac_target, span_big(span_purple("Вы не помните ничего из того, что предшествовало этому опыту. \
												Все, о чем вы можете думать, — это те ужасные руки...")))

	// Oh god where are we?
	sac_target.flash_eyes()
	sac_target.Confused(60 SECONDS)
	sac_target.Jitter(120 SECONDS)
	sac_target.EyeBlurry(100 SECONDS)
	sac_target.Dizzy(1 MINUTES)
	sac_target.AdjustKnockdown(80)
	sac_target.adjustStaminaLoss(120)

	// Could use a little pick-me-up...
	sac_target.reagents?.add_reagent(/datum/reagent/medicine/atropine, 8)
	sac_target.reagents?.add_reagent(/datum/reagent/medicine/epinephrine, 8)

/**
 * This proc is called from [proc/return_target] if the target dies in the shadow realm.)
 *
 * After teleporting the target back to the station (dead),
 * it spawns a special red broken illusion on their spot, for style.
 */
/datum/heretic_knowledge/hunt_and_sacrifice/proc/after_return_dead_target(mob/living/carbon/human/sac_target)
	to_chat(sac_target, span_purple("Вы не смогли противостоять ужасам Мансуса! Ваше изуродованное тело вернули на станцию."))
	to_chat(sac_target, span_big(span_purple("Этот опыт оставляет ваш разум повреждённым, а воспоминания — рваными. \
												Даже если вы вернётесь к жизни, вы не вспомните ничего, что предшествовало этому опыту.")))

	var/obj/effect/visible_heretic_influence/illusion = new(get_turf(sac_target))
	illusion.name = "слабый разлом реальности"
	illusion.desc = "Трещина в реальности, достаточно широкая, чтобы что-то... или кто-то... мог через нее пройти."
	illusion.color = COLOR_DARK_RED

/**
 * "Fuck you" proc that gets called if the chain is interrupted at some points.
 * Disembowels the [sac_target] and brutilizes their body. Throws some gibs around for good measure.
 */
/datum/heretic_knowledge/hunt_and_sacrifice/proc/disembowel_target(mob/living/carbon/human/sac_target)
	//if(heretic_mind)
	//	log_combat(heretic_mind.current, sac_target, "disemboweled via sacrifice")

	sac_target.spill_organs()
	sac_target.apply_damage(250, BRUTE)
	if(sac_target.stat != DEAD)
		sac_target.investigate_log("has been killed by heretic sacrifice.", INVESTIGATE_DEATHS)
		sac_target.death()

	sac_target.visible_message(
		span_danger("Органы [sac_target.declent_ru(GENITIVE)] были вытащены из тела теневыми руками!"),
		span_userdanger("Вашей органы насильно вырваны из тела теневыми руками!")
	)

	new /obj/effect/gibspawner/human/bodypartless(get_turf(sac_target), sac_target.dna)

#undef SACRIFICE_SLEEP_DURATION
#undef SACRIFICE_REALM_DURATION

/**
 * Drops a mob's organs on the floor
 *
 * drop_bitflags: (see code/__DEFINES/blood.dm)
 * * DROP_BRAIN - Mob will drop a brain
 * * DROP_ORGANS - Mob will drop organs
 * * DROP_BODYPARTS - Mob will drop bodyparts (arms, legs, etc.)
 * * DROP_ALL_REMAINS - Mob will drop everything
**/
/mob/living/proc/spill_organs()
	return


/mob/living/carbon/spill_organs()
	var/atom/Tsec = drop_location()

	for(var/obj/item/organ/organ as anything in internal_organs)
		organ.remove(src)
		organ.forceMove(Tsec)
		organ.throw_at(get_edge_target_turf(src, pick(GLOB.alldirs)), rand(1,3), 5)


/// Applies a curse with various possible effects
/mob/living/proc/apply_necropolis_curse(set_curse)
	var/datum/status_effect/necropolis_curse/curse = has_status_effect(/datum/status_effect/necropolis_curse)
	if(!set_curse)
		set_curse = pick(CURSE_BLINDING, CURSE_WASTING, CURSE_GRASPING)

	if(QDELETED(curse))
		apply_status_effect(/datum/status_effect/necropolis_curse, set_curse)
		return curse

	curse.apply_curse(set_curse)
	curse.duration += 5 MINUTES //time added by additional curses
	return curse


/// A curse that does up to three nasty things to you
/datum/status_effect/necropolis_curse
	id = "necrocurse"
	duration = 10 MINUTES //you're cursed for 10 minutes have fun
	tick_interval = 5 SECONDS
	alert_type = null
	/// Which nasty things are we doing? [CURSE_BLINDING / CURSE_WASTING / CURSE_GRASPING]]
	var/curse_flags = NONE
	/// When should we next throw hands?
	var/effect_next_activation = 0
	/// How long between throwing hands?
	var/effect_cooldown = 10 SECONDS
	/// Visuals for the wasting effect
	var/obj/effect/temp_visual/curse/wasting_effect


/datum/status_effect/necropolis_curse/on_creation(mob/living/new_owner, set_curse)
	. = ..()
	if(!.)
		return

	apply_curse(set_curse)


/datum/status_effect/necropolis_curse/Destroy()
	if(QDELETED(wasting_effect))
		return ..()

	qdel(wasting_effect)
	wasting_effect = null
	return ..()


/datum/status_effect/necropolis_curse/on_remove()
	remove_curse(curse_flags)


/datum/status_effect/necropolis_curse/proc/apply_curse(set_curse)
	curse_flags |= set_curse
	if(curse_flags & CURSE_BLINDING)
		owner.overlay_fullscreen("curse", /atom/movable/screen/fullscreen/curse, 1)

	if(curse_flags & CURSE_WASTING && !wasting_effect)
		wasting_effect = new


/datum/status_effect/necropolis_curse/proc/remove_curse(remove_curse)
	if(remove_curse & CURSE_BLINDING)
		owner.clear_fullscreen("curse", 50)

	curse_flags &= ~remove_curse


/datum/status_effect/necropolis_curse/tick(seconds_between_ticks)
	if(owner.stat == DEAD)
		return

	if(curse_flags & CURSE_WASTING)
		wasting_effect.forceMove(owner.loc)
		wasting_effect.setDir(owner.dir)
		wasting_effect.transform = owner.transform //if the owner has been stunned the overlay should inherit that position
		wasting_effect.alpha = 255
		animate(wasting_effect, alpha = 0, time = 32)
		playsound(owner, 'sound/effects/curse/curse5.ogg', 20, TRUE, -1)
		owner.adjustFireLoss(0.75)

	if(!HASBIT(curse_flags, CURSE_GRASPING))
		return

	if(effect_next_activation > world.time)
		return

	effect_next_activation = world.time + effect_cooldown
	fire_curse_hand(owner, range = 5, projectile_type = /obj/projectile/curse_hand) // This one stuns people


/obj/effect/temp_visual/curse
	icon_state = "curse"

/obj/effect/temp_visual/curse/Initialize(mapload)
	. = ..()
	deltimer(timerid)


/obj/effect/ebeam/curse_arm
	name = "проклятая рука"


/obj/projectile/curse_hand
	name = "проклятая рука"
	gender = FEMALE
	icon_state = "cursehand0"
	base_icon_state = "cursehand"
	hitsound = 'sound/effects/curse/curse4.ogg'
	layer = LARGE_MOB_LAYER
	damage_type = BURN
	damage = 10
	paralyze = 20
	speed = 0.5
	range = 16
	hit_crawling_mobs_chance = 100
	pass_flags = PASSTABLE | PASSGLASS | PASSGRILLE
	var/datum/beam/arm
	var/handedness = 0


/obj/projectile/curse_hand/get_ru_names()
	return list(
		NOMINATIVE = "проклятая рука",
		GENITIVE = "проклятой руки",
		DATIVE = "проклятой руке",
		ACCUSATIVE = "проклятую руку",
		INSTRUMENTAL = "проклятой рукой",
		PREPOSITIONAL = "проклятой руке",
	)


/obj/projectile/curse_hand/Initialize(mapload)
	. = ..()
	//ADD_TRAIT(src, TRAIT_FREE_HYPERSPACE_MOVEMENT, INNATE_TRAIT)
	handedness = prob(50)
	icon_state = "[base_icon_state][handedness]"


/obj/projectile/curse_hand/Destroy()
	QDEL_NULL(arm)
	return ..()


/obj/projectile/curse_hand/update_icon_state()
	icon_state = "[base_icon_state]0[handedness]"
	return ..()


/obj/projectile/curse_hand/fire(setAngle)
	if(QDELETED(src)) //I'm going to try returning nothing because if it's being deleted, surely we don't want anything to happen?
		return

	if(!starting)
		..()
		return

	arm = starting.Beam(src, icon_state = "curse[handedness]", beam_type=/obj/effect/ebeam/curse_arm)
	..()

/*
/obj/projectile/curse_hand/prehit_pierce(atom/target)
	return (target == original)? PROJECTILE_PIERCE_NONE : PROJECTILE_PIERCE_PHASE
*/

/// The visual effect for the hand disappearing
/obj/projectile/curse_hand/proc/finale()
	if(arm)
		QDEL_NULL(arm)

	if((movement_type & PHASING))
		playsound(src, 'sound/effects/curse/curse3.ogg', 25, TRUE, -1)

	var/turf/T = get_step(src, dir)
	var/obj/effect/temp_visual/dir_setting/curse/hand/leftover = new(T, dir)
	leftover.icon_state = icon_state
	for(var/obj/effect/temp_visual/dir_setting/curse/grasp_portal/G in starting)
		qdel(G)

	if(!T) //T can be in nullspace when src is set to QDEL
		return

	new /obj/effect/temp_visual/dir_setting/curse/grasp_portal/fading(starting, dir)
	var/datum/beam/D = starting.Beam(T, icon_state = "curse[handedness]", time = 32, beam_type=/obj/effect/ebeam/curse_arm)
	animate(D.visuals, alpha = 0, time = 32)


/obj/projectile/curse_hand/on_range()
	finale()
	return ..()


/obj/projectile/curse_hand/on_hit(atom/target, blocked, pierce_hit)
	. = ..()
	//if(. == BULLET_ACT_HIT)
	finale()


/obj/projectile/curse_hand/hel //Used in helbital's impure reagent
	damage = 10
	paralyze = 0 //Lets not stun people!
	speed = 1
	range = 20
	color = "#ff7e7e"//Tint it slightly


/obj/effect/temp_visual/dir_setting/curse
	icon_state = "curse"
	duration = 32
	var/fades = TRUE


/obj/effect/temp_visual/dir_setting/curse/Initialize(mapload, set_dir)
	. = ..()
	if(!fades)
		return

	animate(src, alpha = 0, time = 32)


/obj/effect/temp_visual/dir_setting/curse/grasp_portal
	icon = 'icons/effects/64x64.dmi'
	layer = ABOVE_ALL_MOB_LAYER
	plane = ABOVE_GAME_PLANE
	pixel_y = -16
	pixel_x = -16
	duration = 32
	fades = FALSE


/obj/effect/temp_visual/dir_setting/curse/grasp_portal/fading
	duration = 32
	fades = TRUE


/obj/effect/temp_visual/dir_setting/curse/hand
	icon_state = "cursehand1"


/**
 * Heals up the mob up to [heal_to] of the main damage types.
 * EX: If heal_to is 50, and they have 150 brute damage, they will heal 100 brute (up to 50 brute damage)
 *
 * If the target is dead, also revives them and heals their organs / restores blood.
 * If we have a [revive_message], play a visible message if the revive was successful.
 *
 * Arguments
 * * heal_to - the health threshold to heal the mob up to for each of the main damage types.
 * * revive_message - if provided, a visible message to show on a successful revive.
 *
 * Returns TRUE if the mob is alive afterwards, or FALSE if they're still dead (revive failed).
 */
/mob/living/proc/heal_and_revive(heal_to = 50, revive_message)

	// Heal their brute and burn up to the threshold we're looking for
	var/brute_to_heal = heal_to - getBruteLoss()
	var/burn_to_heal = heal_to - getFireLoss()
	var/oxy_to_heal = heal_to - getOxyLoss()
	var/tox_to_heal = heal_to - getToxLoss()
	if(brute_to_heal < 0)
		adjustBruteLoss(brute_to_heal, updating_health = FALSE)

	if(burn_to_heal < 0)
		adjustFireLoss(burn_to_heal, updating_health = FALSE)

	if(oxy_to_heal < 0)
		adjustOxyLoss(oxy_to_heal, updating_health = FALSE)

	if(tox_to_heal < 0)
		adjustToxLoss(tox_to_heal, updating_health = FALSE, forced = TRUE)

	// Run updatehealth once to set health for the revival check
	updatehealth()

	// We've given them a decent heal.
	// If they happen to be dead too, try to revive them - if possible.
	if(stat == DEAD && can_be_revived())
		// If the revive is successful, show our revival message (if present).
		if(rejuvenate() && revive_message)
			visible_message(revive_message)

	// Finally update health again after we're all done
	updatehealth()

	return stat != DEAD
