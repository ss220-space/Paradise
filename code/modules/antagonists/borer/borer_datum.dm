/datum/antagonist/borer
	name = "Cortical borer"
	show_in_roundend = FALSE
	job_rank = ROLE_BORER
	special_role = SPECIAL_ROLE_BORER
	antag_menu_name = "Борер"
	var/mob/living/simple_animal/borer/user
	/// Rank of our borer
	var/datum/borer_rank/borer_rank
	/// Which focuses we have
	var/list/learned_focuses = list()
	/// chemical scaling, gained when acquired unique host
	var/datum/borer_misc/change_host_and_scale/scaling = new
	/// used to upgrade rank
	var/reproductions = 0
	/// used for borer shopping, gained by reproductions
	var/evo_points = 0

/datum/antagonist/borer/apply_innate_effects(mob/living/simple_animal/borer/borer)
	. = ..()

	user = owner.current
	scaling.parent = src

	RegisterSignal(user, COMSIG_BORER_ENTERED_HOST, PROC_REF(entered_host))
	RegisterSignal(user, COMSIG_BORER_EARLY_LEFT_HOST, PROC_REF(left_host))
	RegisterSignal(user, COMSIG_LIVING_LIFE, PROC_REF(process_life))
	RegisterSignal(user, COMSIG_BORER_REPRODUCE, PROC_REF(post_reproduce))

	return TRUE

/datum/antagonist/borer/greet()
	var/list/messages = list()
	messages.Add(span_notice("Вы - Мозговой Червь!"))
	messages.Add("Забирайтесь в голову своей жертвы, используйте скрытность, убеждение и свои способности к управлению разумом, чтобы сохранить себя, своё потомство и своего носителя в безопасности и тепле.")
	messages.Add("Сахар сводит на нет ваши способности, избегайте его любой ценой!")
	messages.Add("Вы можете разговаривать со своими коллегами-борерами, используя '[get_language_prefix(LANGUAGE_HIVE_BORER)]'.")
	messages.Add("Воспроизведение себе подобных увеличивает количество эволюционных очков и позволяет перейти на следующий ранг.")
	return messages

/datum/antagonist/borer/proc/post_reproduce(mob/source, turf/turf)
	SIGNAL_HANDLER

	reproductions++
	evo_points++

	update_rank()

	return

/datum/antagonist/borer/proc/process_focus_choice(datum/borer_focus/focus)
	if(!user || !user.host || user.stat || user.docile)
		return

	if(locate(focus) in learned_focuses)
		to_chat(user, span_notice("Вы не можете изучить уже изученный фокус."))
		return

	if(evo_points >= focus.cost)
		evo_points -= focus.cost
		learned_focuses += new focus(user)

		pre_grant_movable_effect()
		to_chat(user, span_notice("Вы успешно приобрели [focus.name]"))
		return

	var/need_points = focus.cost - evo_points
	to_chat(user, span_notice("Вам требуется ещё [need_points] очк[declension_ru(need_points, "о", "а", "ов")] эволюции для получения [focus.name]."))
	return

/datum/antagonist/borer/proc/entered_host(mob/source)
	SIGNAL_HANDLER

	pre_grant_movable_effect()

/datum/antagonist/borer/proc/left_host(mob/source)
	SIGNAL_HANDLER

	pre_remove_movable_effect()

/datum/antagonist/borer/proc/pre_grant_movable_effect()
	if(QDELETED(user) || QDELETED(user.host))
		return

	for(var/datum/borer_focus/focus as anything in learned_focuses)
		if(focus.movable_granted)
			continue

		focus.movable_granted = TRUE
		if(!user.host.ckey)
			focus.is_catathonic = TRUE

		focus.grant_movable_effect()

	scaling?.grant_movable_effect()

	return

/datum/antagonist/borer/proc/pre_remove_movable_effect()
	if(QDELETED(user))
		return

	for(var/datum/borer_focus/focus as anything in learned_focuses)
		if(!focus.movable_granted)
			continue

		focus.movable_granted = FALSE
		focus.remove_movable_effect()
		focus.is_catathonic = FALSE // now we can set it manually without checks.

	return

/datum/antagonist/borer/Destroy(force)
	UnregisterSignal(user, list(
		COMSIG_BORER_ENTERED_HOST,
		COMSIG_BORER_EARLY_LEFT_HOST,
		COMSIG_LIVING_LIFE,
		COMSIG_BORER_REPRODUCE,
	))

	pre_remove_movable_effect()

	QDEL_NULL(borer_rank)
	QDEL_NULL(learned_focuses)
	QDEL_NULL(scaling)

	user = null

	return ..()

/datum/antagonist/borer/proc/process_life(mob/source, deltatime, times_fired)
	SIGNAL_HANDLER
	
	for(var/datum/borer_focus/focus as anything in learned_focuses)
		focus.tick()

	borer_rank.tick()

/datum/antagonist/borer/proc/update_rank()
	if(!borer_rank?.required_reproductions || !borer_rank.next_rank_type)
		return FALSE

	if(reproductions < borer_rank.required_reproductions)
		return FALSE

	reproductions -= borer_rank.required_reproductions
	borer_rank = new borer_rank.next_rank_type(user)
	to_chat(user.controlling ? user.host : user, span_notice("Вы эволюционировали. Ваш текущий ранг - [borer_rank.rankname]."))

	return TRUE

/datum/borer_misc // category for small datums.
	var/datum/antagonist/borer/parent
	var/movable_granted = FALSE

/datum/borer_misc/Destroy(force)
	parent = null
	return ..()

/datum/borer_misc/proc/grant_movable_effect()
	return

/datum/borer_misc/change_host_and_scale
	var/list/used_UIDs = list()

/datum/borer_misc/change_host_and_scale/grant_movable_effect()
	if(parent.user.max_chems >= SCALING_MAX_CHEM)
		qdel(src)
		return FALSE

	if(!parent.user.host.ckey || LAZYIN(parent.user.host.UID(), used_UIDs))
		return FALSE
		
	parent.user.max_chems += SCALING_CHEM_GAIN
	used_UIDs += parent.user.host.UID()

	return TRUE

/datum/borer_misc/change_host_and_scale/Destroy(force)
	LAZYNULL(used_UIDs)
	return ..()
