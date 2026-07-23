
/// How long we put the target so sleep for(during sacrifice).
#define SACRIFICE_SLEEP_DURATION (12 SECONDS)
/// How long sacrifices must stay in the shadow realm to survive.
#define SACRIFICE_REALM_DURATION (2.5 MINUTES)
#define SACRIFICE_BRAIN_DAMAGE 50
#define SACRIFICE_BRAIN_DAMAGE_MAX 90

/// Allows the heretic to sacrifice living heart targets.
/datum/heretic_knowledge/hunt_and_sacrifice
	name = "Сердцебиение Обители"
	desc = "Позволяет приносить цели в жертву Обители, положив их в руну в критическом (или худшем) состоянии."
	notice = "Если у вас нет целей, встаньте на руну трансмутации и проведите этот ритуал, чтобы получить их."
	required_atoms = list(/mob/living/carbon/human = 1)
	priority = MAX_KNOWLEDGE_PRIORITY // Should be at the top
	is_starting_knowledge = TRUE
	research_tree_icon_path = 'icons/effects/eldritch.dmi'
	research_tree_icon_state = "eye_close"
	/// How many targets do we generate?
	var/num_targets_to_generate = 5
	/// A weakref to the mind of our heretic.
	var/datum/mind/heretic_mind
	/// Lazylist of minds that we won't pick as targets.
	var/list/datum/mind/target_blacklist
	/// An assoc list of [ref] to [timers] - a list of all the timers of people in the shadow realm currently
	var/list/return_timers
	var/backdoor_sacrifice_attempts = 0
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

/datum/heretic_knowledge/hunt_and_sacrifice/recipe_snowflake_check(mob/living/user, list/atoms, list/selected_atoms, turf/loc)
	var/datum/antagonist/heretic/heretic_datum = GET_HERETIC(user)
	if(heretic_datum.has_living_heart() != HERETIC_HAS_LIVING_HEART)
		loc.balloon_alert(user, "нет живого сердца!")
		return FALSE

	if(!LAZYLEN(heretic_datum.sac_targets))
		atoms += user
		return TRUE

	if(istype(get_area(loc), /area/centcom/heretic_backdoor))
		loc.balloon_alert(user, "неподходящее место!")
		switch(backdoor_sacrifice_attempts)
			if(0)
				to_chat(user, span_mansus("Проводить жертвоприношение так близко к богам рискованно..."))
			if(1)
				to_chat(user, span_mansus("<i>Вы слышите стук[HAS_TRAIT(user, TRAIT_DEAF) ? ", несмотря на свою глухоту" : ""]...</i>"))
			if(2)
				to_chat(user, span_mansus("<i>Стук становится громче...</i>"))
				user.AdjustDeaf(10 SECONDS)
				user.Weaken(1 SECONDS)
				user.adjustBruteLoss(10)
			if(3)
				to_chat(user, span_mansus("<i>Стук становится оглушительным!</i>"))
				user.AdjustDeaf(20 SECONDS)
				user.Weaken(4 SECONDS)
				user.adjustBruteLoss(20)
			if(4)
				if(begin_sacrifice(user))
					to_chat(user, span_mansus("<b><i>Ваша дерзость наказана!</i></b>"))
				else
					to_chat(user, span_mansus("Стук прекращается — но вас не покидает чувство, что вы чудом избежали расправы."))
			if(5 to INFINITY)
				to_chat(user, span_mansus("Вы не думаете, что очередная попытка откроет вам что-то новое..."))

		backdoor_sacrifice_attempts++
		return FALSE

	for(var/mob/living/carbon/human/sacrifice in atoms)
		if(sacrifice.stat == CONSCIOUS)
			atoms -= sacrifice
			continue

		if((sacrifice in heretic_datum.sac_targets) || iscultist(sacrifice))
			continue

		atoms -= sacrifice

	if(locate(/mob/living/carbon/human) in atoms)
		return TRUE

	loc.balloon_alert(user, "жертва не найдена!")
	return FALSE


/datum/heretic_knowledge/hunt_and_sacrifice/on_finished_recipe(mob/living/user, list/selected_atoms, turf/loc)
	var/datum/antagonist/heretic/heretic_datum = GET_HERETIC(user)
	var/mob/living/carbon/human/sac = selected_atoms[1]
	if(!LAZYLEN(heretic_datum.sac_targets) && !iscultist(sac))
		if(obtain_targets(user, heretic_datum = heretic_datum))
			return TRUE

		loc.balloon_alert(user, "цели не найдены!")
		return FALSE

	sacrifice_process(user, selected_atoms, loc)
	return TRUE

/// Obtains a list of targets for the user to hunt down and sacrifice. Returns FALSE if no targets are found.
/datum/heretic_knowledge/hunt_and_sacrifice/proc/obtain_targets(mob/living/user, silent = FALSE, datum/antagonist/heretic/heretic_datum)
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
			to_chat(user, span_mansus("Целей для жертвоприношения не обнаружено!"))

		return FALSE

	var/list/datum/mind/final_targets = list()

	for(var/datum/mind/head_mind as anything in shuffle(valid_targets))
		if(!head_mind.assigned_job?.head_position)
			continue

		final_targets += head_mind
		valid_targets -= head_mind
		break

	for(var/datum/mind/sec_mind as anything in shuffle(valid_targets))
		if(!(sec_mind.assigned_job?.departments_bitflags & DEPARTMENT_BITFLAG_SECURITY))
			continue

		final_targets += sec_mind
		valid_targets -= sec_mind
		break

	var/heretic_departments = user.mind.assigned_job?.departments_bitflags
	for(var/datum/mind/department_mind as anything in shuffle(valid_targets))
		if(!(department_mind.assigned_job?.departments_bitflags & heretic_departments))
			continue

		final_targets += department_mind
		valid_targets -= department_mind
		break

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

/// Begins the process of sacrificing the target. selected_atoms should contain (at least) one human.
/datum/heretic_knowledge/hunt_and_sacrifice/proc/sacrifice_process(mob/living/user, list/selected_atoms, turf/loc)

	var/datum/antagonist/heretic/heretic_datum = GET_HERETIC(user)
	var/mob/living/carbon/human/sacrifice = locate() in selected_atoms
	if(!sacrifice)
		CRASH("[type] sacrifice_process didn't have a human in the atoms list. How'd it make it so far?")
	if(!(sacrifice in heretic_datum.sac_targets) && !iscultist(sacrifice))
		CRASH("[type] sacrifice_process managed to get a non-target, non-cult human. This is incorrect.")

	if(sacrifice.mind)
		LAZYADD(target_blacklist, sacrifice.mind)

	for(var/datum/antagonist/heretic/other_heretic in GLOB.antagonists)
		other_heretic.remove_sacrifice_target(sacrifice)

	var/feedback = "Ваши покровители принимают вашу жертву"
	var/datum/job/sac_job = sacrifice.mind?.assigned_job || sacrifice.last_mind?.assigned_job
	heretic_datum.total_sacrifices++
	if(sac_job?.head_position)
		heretic_datum.adjust_knowledge_points(3)
		heretic_datum.high_value_sacrifices++
		feedback = "Ваши покровители <i>с радостью</i> принимают вашу жертву"

	if(!iscultist(sacrifice))
		heretic_datum.adjust_knowledge_points(2)
		to_chat(user, span_purple("[feedback]."))
		if(!begin_sacrifice(sacrifice))
			disembowel_target(sacrifice)
			return

		sacrifice.apply_status_effect(/datum/status_effect/heretic_curse, user)
		return

	heretic_datum.adjust_knowledge_points(1)
	grant_reward(user, sacrifice, loc)
	var/rewards_given = heretic_datum.rewards_given
	if(!prob(min(15 * rewards_given)) || (rewards_given > 5))
		return

	for(var/datum/mind/mind as anything in SSticker.mode.cult)
		if(!mind.current)
			continue

		SEND_SOUND(mind.current, 'sound/magic/clockwork/narsie_attack.ogg')
		var/message = span_narsie("Подлый еретик ") + \
		span_cultlarge(span_purple("принёс в жертву")) + \
		span_narsie(" одного из наших. Уничтожьте и принесите в жертву неверных, прежде чем они принесут в жертву нас!")
		to_chat(mind.current, message)

	to_chat(user, span_narsiesmall("Да как ты СМЕЕШЬ!? Я тебя уничтожу!"))
	var/non_flavor_warning = span_cultbold("Вы чувствуете, что ваши действия привлекли ") + span_purple("внимание") + span_cultbold(".")
	to_chat(user, non_flavor_warning)


/datum/heretic_knowledge/hunt_and_sacrifice/proc/grant_reward(mob/living/user, mob/living/sacrifice, turf/loc)
	to_chat(user, span_big(span_purple("Слуга Кровавого Отступника!")))
	to_chat(user, span_mansus("Ваши покровители в восторге!"))
	playsound(sacrifice, 'sound/magic/disintegrate.ogg', 75, TRUE)

	var/list/dustee_items = sacrifice.unequip_everything()
	for(var/obj/item/loot as anything in dustee_items)
		loot.throw_at(get_step_rand(sacrifice), 2, 4, user, TRUE)

	sacrifice.dust(TRUE, TRUE)

	var/datum/antagonist/heretic/antag = GET_HERETIC(user)
	antag.rewards_given++

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
	rune?.remove_filter("reward_outline")
	playsound(loc, 'sound/magic/repulse.ogg', 75, TRUE)
	var/datum/antagonist/heretic/heretic_datum = GET_HERETIC(user)
	ASSERT(heretic_datum)
	var/list/rewards = heretic_datum.unlocked_heretic_items.Copy()
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

/// Sets off a chain that sends the sacrificed [sac_target] to the shadow realm to dodge hands and fight for survival.
/datum/heretic_knowledge/hunt_and_sacrifice/proc/begin_sacrifice(mob/living/carbon/human/sac_target)
	. = FALSE

	var/datum/antagonist/heretic/our_heretic = heretic_mind?.has_antag_datum(/datum/antagonist/heretic)
	if(!our_heretic)
		CRASH("[type] - begin_sacrifice was called, and no heretic [heretic_mind ? "antag datum":"mind"] could be found!")


	var/obj/effect/landmark/heretic/destination_landmark = GLOB.heretic_sacrifice_landmarks[our_heretic.heretic_path?.route] || GLOB.heretic_sacrifice_landmarks[PATH_START]

	var/turf/destination = get_turf(destination_landmark)

	sac_target.visible_message(span_danger("[sac_target.declent_ru(NOMINATIVE)] начинает яростно содрогаться, когда темные щупальца утаскивают [GEND_HIS_HER(sac_target)] в пустоту!"))
	sac_target.grab_ghost()
	sac_target.revive()
	sac_target.visible_message(span_danger("Сердце [sac_target.declent_ru(GENITIVE)] начинает биться с нечестивой силой, когда [GEND_HE_SHE(sac_target)] возвраща[PLUR_ET_YUT(sac_target)]ся из объятий смерти!"))
	sac_target.set_handcuffed(new /obj/item/restraints/handcuffs/cable(sac_target))

	if(sac_target.legcuffed)
		sac_target.legcuffed.forceMove(sac_target.drop_location())
		sac_target.legcuffed.dropped(sac_target)
		sac_target.legcuffed = null
		sac_target.update_legcuffed_status()

	sac_target.adjustOrganLoss(INTERNAL_ORGAN_BRAIN, SACRIFICE_BRAIN_DAMAGE, SACRIFICE_BRAIN_DAMAGE_MAX)
	sac_target.do_jitter_animation()

	addtimer(CALLBACK(sac_target, TYPE_PROC_REF(/mob/living/carbon, do_jitter_animation)), SACRIFICE_SLEEP_DURATION * (1/3))
	addtimer(CALLBACK(sac_target, TYPE_PROC_REF(/mob/living/carbon, do_jitter_animation)), SACRIFICE_SLEEP_DURATION * (2/3))

	if(sac_target.Sleeping(SACRIFICE_SLEEP_DURATION))
		to_chat(sac_target, span_purple("Ваш разум разрывается на части, когда вы погружаетесь в поверхностный сон..."))
	else
		to_chat(sac_target, span_purple("Ваш разум начинает разрываться на части, когда вы видите, как вас окутывают тёмные щупальца."))

	sac_target.AdjustParalysis(SACRIFICE_SLEEP_DURATION * 1.2)
	sac_target.AdjustImmobilized(SACRIFICE_SLEEP_DURATION * 1.2)

	addtimer(CALLBACK(src, PROC_REF(after_target_sleeps), sac_target, destination), SACRIFICE_SLEEP_DURATION * 0.5) // Teleport to the minigame
	return TRUE

/// Teleports the sleeping [sac_target] to [destination]. If the teleport fails, they're disemboweled instead.
/datum/heretic_knowledge/hunt_and_sacrifice/proc/after_target_sleeps(mob/living/carbon/human/sac_target, turf/destination)
	if(QDELETED(sac_target))
		return

	sac_target.grab_ghost()
	if(!sac_target.client || !sac_target.mind)
		disembowel_target(sac_target)
		return

	curse_organs(sac_target)

	if(!destination || !do_teleport(sac_target, destination, asoundin = 'sound/magic/repulse.ogg', asoundout = 'sound/magic/blind.ogg', bypass_area_flag = TRUE, ignore_bluespace_interference = TRUE, no_effects = TRUE, ignore_blocking_traits = TRUE))
		disembowel_target(sac_target)
		return

	sac_target.adjustOxyLoss(-100, FALSE)
	if(!sac_target.heal_and_revive(60, span_danger("Сердце [sac_target.declent_ru(GENITIVE)] начинает биться с нечестивой силой, когда [GEND_HE_SHE(sac_target)] возвраща[PLUR_ET_YUT(sac_target)]ся из объятий смерти!")))
		disembowel_target(sac_target)
		return

	to_chat(sac_target, span_big(span_purple("Противоестественные силы из-за завесы начинают терзать ваши тело и душу!")))
	playsound(sac_target, 'sound/music/heretic/heretic_sacrifice.ogg', 50, FALSE) // play theme

	sac_target.apply_status_effect(/datum/status_effect/unholy_determination, SACRIFICE_REALM_DURATION)
	addtimer(CALLBACK(src, PROC_REF(after_target_wakes), sac_target), SACRIFICE_SLEEP_DURATION * 0.5)

	RegisterSignal(sac_target, COMSIG_MOVABLE_Z_CHANGED, PROC_REF(on_target_escape)) // Cheese condition
	RegisterSignal(sac_target, COMSIG_LIVING_DEATH, PROC_REF(on_target_death)) // Loss condition


/// Apply a sinister curse to some of the target's organs as an incentive to leave us alone
/datum/heretic_knowledge/hunt_and_sacrifice/proc/curse_organs(mob/living/carbon/human/sac_target)
	var/usable_organs = grantable_organs.Copy()
	if(isplasmaman(sac_target))
		usable_organs -= /obj/item/organ/internal/lungs/corrupt // Their lungs are already more cursed than anything I could give them

	var/total_implant = rand(2, 4)
	var/turf/drop_turf = get_turf(sac_target)

	for(var/i in 1 to total_implant)
		if(!length(usable_organs))
			break

		var/organ_path = pick_n_take(usable_organs)
		var/obj/item/organ/internal/to_give = new organ_path
		var/obj/item/organ/internal/displaced = sac_target.get_organ_slot(to_give.slot)
		to_give.safe_replace(sac_target)
		if(displaced && isnull(displaced.loc))
			displaced.forceMove(drop_turf)
			displaced.throw_at(get_edge_target_turf(sac_target, pick(GLOB.alldirs)), rand(1, 3), 5)

	new /obj/effect/gibspawner/human/bodypartless(drop_turf, sac_target.dna)
	sac_target.visible_message(span_boldwarning("Несколько органов вылетают из тела [sac_target.declent_ru(GENITIVE)] направляемые таинственной силой!"))

/// Begins the survival minigame: throws cursed Helgrasp hands at [sac_target] to dodge, backed by Unholy Determination.
/datum/heretic_knowledge/hunt_and_sacrifice/proc/after_target_wakes(mob/living/carbon/human/sac_target)
	if(QDELETED(sac_target))
		return

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

	to_chat(sac_target, span_purple("Вы чувствуете прилив сил! Боритесь, чтобы выжить!"))
	addtimer(CALLBACK(src, PROC_REF(after_helgrasp_ends), sac_target), helgrasp_time)
	var/win_timer = addtimer(CALLBACK(src, PROC_REF(return_target), sac_target), SACRIFICE_REALM_DURATION, TIMER_STOPPABLE)
	LAZYSET(return_timers, sac_target.UID(), win_timer)

/// Lets [sac_target] know it's getting easier and they're almost free, once the helgrasp runs out.
/datum/heretic_knowledge/hunt_and_sacrifice/proc/after_helgrasp_ends(mob/living/carbon/human/sac_target)
	if(QDELETED(sac_target) || sac_target.stat == DEAD)
		return

	to_chat(sac_target, span_purple("Худшее позади... Осталось совсем немного! Держитесь, иначе погибните!"))

/// Teleports [sac_target] back to a random safe station turf (or observer spawn as fallback), clears their
/// shadow-realm status effects/signals, and tells the heretic whether they survived and where they ended up.
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
	if(IS_HERETIC(sac_target))
		var/datum/antagonist/heretic/victim_heretic = GET_HERETIC(sac_target)
		victim_heretic.adjust_knowledge_points(-3)

	sac_target.apply_status_effect(/*/datum/status_effect/speech/slurring/heretic*/ STATUS_EFFECT_CLOCK_CULT_SLUR, 40 SECONDS)
	sac_target.Stuttering(40 SECONDS)

	var/turf/below_target = get_turf(sac_target)
	if(below_target && below_target.z != 0 && is_station_level(below_target.z))
		return

	var/turf/simulated/floor/safe_turf = get_safe_random_station_turf()
	var/obj/effect/landmark/observer_start/backup_loc = locate(/obj/effect/landmark/observer_start) in GLOB.landmarks_list
	if(!safe_turf)
		safe_turf = get_turf(backup_loc)
		stack_trace("[type] - return_target was unable to find a safe turf for [sac_target] to return to. Defaulting to observer start turf.")

	if(!do_teleport(sac_target, safe_turf, asoundout = 'sound/magic/blind.ogg', ignore_bluespace_interference = TRUE, no_effects = TRUE, ignore_blocking_traits = TRUE))
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

	composed_return_message += span_notice("Вы слышите шёпот...")
	composed_return_message += span_purple(get_area_name(safe_turf, TRUE))
	to_chat(heretic_mind.current, composed_return_message)

/// If they die in the shadow realm, they lost. Send them back.
/datum/heretic_knowledge/hunt_and_sacrifice/proc/on_target_death(mob/living/carbon/human/sac_target, gibbed)
	SIGNAL_HANDLER

	if(gibbed) // Nothing to return
		return

	return_target(sac_target)

/// If they somehow cheese the shadow realm by teleporting out, they are disemboweled and killed.
/datum/heretic_knowledge/hunt_and_sacrifice/proc/on_target_escape(mob/living/carbon/human/sac_target, old_z, new_z)
	SIGNAL_HANDLER

	to_chat(sac_target, span_boldwarning("Ваша попытка сбежать от Обители не будет встречена благосклонно!"))
	disembowel_target(sac_target)

/// Gives [sac_target] some after-effects upon arriving back to reality.
/datum/heretic_knowledge/hunt_and_sacrifice/proc/after_return_live_target(mob/living/carbon/human/sac_target)
	to_chat(sac_target, span_purple("Борьба окончена, но дорогой ценой. Вы вернулись на станцию целым и невредимым."))
	if(IS_HERETIC(sac_target))
		to_chat(sac_target, span_big(span_purple("Вы не помните ничего, что предшествовало этому опыту, \
											но чувствуете, что ваша связь с Обителью ослабла — когда-то известные знания забыты...")))
	else
		to_chat(sac_target, span_big(span_purple("Вы не помните ничего из того, что предшествовало этому опыту. \
												Все, о чем вы можете думать, - это те ужасные руки...")))

	sac_target.flash_eyes()
	sac_target.Confused(60 SECONDS)
	sac_target.Jitter(120 SECONDS)
	sac_target.EyeBlurry(100 SECONDS)
	sac_target.Dizzy(1 MINUTES)
	sac_target.AdjustKnockdown(80)
	sac_target.adjustStaminaLoss(120)

	sac_target.reagents?.add_reagent(/datum/reagent/medicine/atropine, 8)
	sac_target.reagents?.add_reagent(/datum/reagent/medicine/epinephrine, 8)

/// After teleporting the dead target back to the station, spawns a red broken illusion on their spot for style.
/datum/heretic_knowledge/hunt_and_sacrifice/proc/after_return_dead_target(mob/living/carbon/human/sac_target)
	to_chat(sac_target, span_purple("Вы не смогли противостоять ужасам Обители! Ваше изуродованное тело вернули на станцию."))
	to_chat(sac_target, span_big(span_purple("Этот опыт оставляет ваш разум повреждённым, а воспоминания — рваными. \
												Даже если вы вернётесь к жизни, вы не вспомните ничего, что предшествовало этому опыту.")))

	var/obj/effect/visible_heretic_influence/illusion = new(get_turf(sac_target))
	illusion.name = "слабый разлом реальности"
	illusion.desc = "Трещина в реальности, достаточно широкая, чтобы что-то... или кто-то... мог через нее пройти."
	illusion.color = COLOR_DARK_RED

/// Called if the chain is interrupted: disembowels the [sac_target] and brutalizes their body.
/datum/heretic_knowledge/hunt_and_sacrifice/proc/disembowel_target(mob/living/carbon/human/sac_target)

	sac_target.spill_organs()
	sac_target.apply_damage(250, BRUTE)
	if(sac_target.stat != DEAD)
		sac_target.investigate_log("has been killed by heretic sacrifice.", INVESTIGATE_DEATHS)
		sac_target.death()

	sac_target.visible_message(
		span_danger("Органы [sac_target.declent_ru(GENITIVE)] были вытащены из тела теневыми руками!"),
		span_userdanger("Ваши органы насильно вырваны из тела теневыми руками!")
	)

	new /obj/effect/gibspawner/human/bodypartless(get_turf(sac_target), sac_target.dna)

#undef SACRIFICE_SLEEP_DURATION
#undef SACRIFICE_REALM_DURATION
#undef SACRIFICE_BRAIN_DAMAGE
#undef SACRIFICE_BRAIN_DAMAGE_MAX

/// Drops a mob's organs on the floor.
/mob/living/proc/spill_organs()
	return


/mob/living/carbon/spill_organs()
	var/atom/Tsec = drop_location()

	for(var/obj/item/organ/organ as anything in internal_organs)
		organ.remove(src)
		organ.forceMove(Tsec)
		organ.throw_at(get_edge_target_turf(src, pick(GLOB.alldirs)), rand(1,3), 5)


/obj/effect/ebeam/curse_arm
	name = "проклятая рука"


/obj/projectile/curse_hand
	name = "curse hand"
	gender = FEMALE
	icon_state = "cursehand0"
	base_icon_state = "cursehand"
	hitsound = 'sound/effects/curse/curse4.ogg'
	layer = LARGE_MOB_LAYER
	damage_type = BURN
	paralyze = 20
	speed = 3
	range = 16
	hit_crawling_mobs_chance = 100
	pass_flags = PASSTABLE | PASSGLASS | PASSGRILLE
	ricochets_max = 0
	var/datum/beam/arm
	var/handedness = 0


/obj/projectile/curse_hand/get_ru_names()
	return alist(
		NOMINATIVE = "проклятая рука",
		GENITIVE = "проклятой руки",
		DATIVE = "проклятой руке",
		ACCUSATIVE = "проклятую руку",
		INSTRUMENTAL = "проклятой рукой",
		PREPOSITIONAL = "проклятой руке",
	)


/obj/projectile/curse_hand/Initialize(mapload)
	. = ..()
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

	if(HASBIT(movement_type, PHASING))
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
	finale()


/obj/projectile/curse_hand/hel //Used in helbital's impure reagent
	paralyze = 0 //Lets not stun people!
	speed = 1.875
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
	fades = FALSE


/obj/effect/temp_visual/dir_setting/curse/grasp_portal/fading
	fades = TRUE


/obj/effect/temp_visual/dir_setting/curse/hand
	icon_state = "cursehand1"


/// Heals the mob up to [heal_to] of each main damage type, reviving them if dead. Returns TRUE if alive afterwards.
/mob/living/proc/heal_and_revive(heal_to = 50, revive_message)

	var/brute_to_heal = heal_to - getBruteLoss()
	var/burn_to_heal = heal_to - getFireLoss()
	var/oxy_to_heal = heal_to - getOxyLoss()
	var/tox_to_heal = heal_to - getToxLoss()
	var/clone_to_heal = heal_to - getCloneLoss()
	if(brute_to_heal < 0)
		adjustBruteLoss(brute_to_heal, updating_health = FALSE)

	if(burn_to_heal < 0)
		adjustFireLoss(burn_to_heal, updating_health = FALSE)

	if(oxy_to_heal < 0)
		adjustOxyLoss(oxy_to_heal, updating_health = FALSE)

	if(tox_to_heal < 0)
		adjustToxLoss(tox_to_heal, updating_health = FALSE, forced = TRUE)

	if(clone_to_heal < 0)
		adjustCloneLoss(clone_to_heal, updating_health = FALSE)

	updatehealth()

	if(stat == DEAD && can_be_revived())
		grab_ghost()
		adjustOxyLoss(-10, updating_health = FALSE)
		adjustToxLoss(-10, updating_health = FALSE, forced = TRUE)
		updatehealth()
		if(update_revive() && revive_message)
			INVOKE_ASYNC(src, PROC_REF(emote), "gasp")
			visible_message(revive_message)

	updatehealth()

	return stat != DEAD


/mob/living/carbon/human/heal_and_revive(heal_to = 50, revive_message)
	if(dna.species.has_organ[INTERNAL_ORGAN_HEART] && !get_organ_slot(INTERNAL_ORGAN_HEART))
		return FALSE

	. = ..()
	if(.)
		set_heartattack(FALSE)
