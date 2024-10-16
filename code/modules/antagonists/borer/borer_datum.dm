/datum/antagonist/borer
	name = "Cortical borer"
	show_in_roundend = FALSE
	job_rank = ROLE_BORER
	special_role = SPECIAL_ROLE_BORER
	var/mob/living/simple_animal/borer/user // our borer
	var/mob/living/carbon/human/host // our host
	var/mob/living/carbon/human/previous_host // previous host, used to del transferable effects from previous host.

	var/datum/borer_rank/borer_rank
	var/list/learned_focuses = list() // what focuses learned borer
	var/datum/borer_misc/change_host_and_scale/scaling = new // chemical scaling, gained when acquired unique host

	var/reproductions = 0 // used to upgrade rank
	var/evo_points = 0 // used for borer shopping, gained by reproductions

	var/tick_interval = 1 SECONDS

/datum/antagonist/borer/apply_innate_effects(mob/living/simple_animal/borer/borer)
	. = ..()

	sync()
	RegisterSignal(user, COMSIG_BORER_ENTERED_HOST, PROC_REF(entered_host))
	RegisterSignal(user, COMSIG_BORER_LEFT_HOST, PROC_REF(left_host))
	RegisterSignal(user, COMSIG_MOB_DEATH, PROC_REF(on_mob_death)) 
	RegisterSignal(user, COMSIG_LIVING_REVIVE, PROC_REF(on_mob_revive))

	if(tick_interval != -1)
		tick_interval = world.time + tick_interval

	if(!(tick_interval > world.time))
		return FALSE

	if(user.stat != DEAD)
		START_PROCESSING(SSprocessing, src)

	return TRUE

/datum/antagonist/borer/proc/sync()
	user = owner.current
	host = user.host
	previous_host = host
	parent_sync()
	return

/datum/antagonist/borer/proc/parent_sync()
	scaling?.parent = src
	borer_rank.parent = src

	if(!LAZYLEN(learned_focuses))
		return

	for(var/datum/borer_focus/focus as anything in learned_focuses)
		focus.parent = src

	return

/datum/antagonist/borer/greet()
	var/list/messages = list()
	messages.Add(span_notice("Вы - Мозговой Червь!"))
	messages.Add("Забирайтесь в голову своей жертвы, используйте скрытность, убеждение и свои способности к управлению разумом, чтобы сохранить себя, своё потомство и своего носителя в безопасности и тепле.")
	messages.Add("Сахар сводит на нет ваши способности, избегайте его любой ценой!")
	messages.Add("Вы можете разговаривать со своими коллегами-борерами, используя '[get_language_prefix(LANGUAGE_HIVE_BORER)]'.")
	messages.Add("Воспроизведение себе подобных увеличивает количество эволюционных очков и позволяет перейти на следующий ранг.")
	return messages

/datum/antagonist/borer/proc/post_reproduce()
	reproductions++
	evo_points++

	if(!borer_rank?.required_reproductions)
		return
		
	if(reproductions < borer_rank.required_reproductions)
		return

	reproductions -= borer_rank.required_reproductions
	update_rank()

	return

/datum/antagonist/borer/proc/process_focus_choice(datum/borer_focus/focus)
	if(!user || !host || user.stat || user.docile)
		return

	if(locate(focus) in learned_focuses)
		to_chat(user, span_notice("Вы не можете изучить уже изученный фокус."))
		return

	if(evo_points >= focus.cost)
		evo_points -= focus.cost
		learned_focuses += new focus(user)
		
		pre_grant_movable_effect()
		to_chat(user, span_notice("Вы успешно приобрели [focus.bodypartname]"))
		return

	to_chat(user, span_notice("Вам требуется еще [focus.cost - evo_points] очков эволюции для получения [focus.bodypartname]."))
	return 

/datum/antagonist/borer/proc/entered_host()
	SIGNAL_HANDLER

	host = user.host
	previous_host = user.host

	pre_grant_movable_effect()

/datum/antagonist/borer/proc/left_host()
	SIGNAL_HANDLER

	host = null

	pre_remove_movable_effect()
	previous_host = null

/datum/antagonist/borer/proc/pre_grant_movable_effect()
	if(QDELETED(user) || QDELETED(host))
		return
		
	for(var/datum/borer_focus/focus as anything in learned_focuses)
		if(focus.movable_granted)
			continue

		focus.movable_granted = TRUE
		if(!host.ckey)
			focus.is_catathonic = TRUE

		focus.grant_movable_effect()

	scaling?.grant_movable_effect()
	
	return

/datum/antagonist/borer/proc/pre_remove_movable_effect()
	if(QDELETED(user) || QDELETED(previous_host))
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
		COMSIG_BORER_LEFT_HOST,
		COMSIG_MOB_DEATH,
		COMSIG_LIVING_REVIVE
	))
	pre_remove_movable_effect()
	STOP_PROCESSING(SSprocessing, src)

	QDEL_NULL(borer_rank)
	QDEL_NULL(learned_focuses)
	QDEL_NULL(scaling)

	user = null
	host = null
	previous_host = null

	return ..()

/datum/antagonist/borer/proc/on_mob_death()
	SIGNAL_HANDLER
	
	STOP_PROCESSING(SSprocessing, src)

/datum/antagonist/borer/proc/on_mob_revive()
	SIGNAL_HANDLER

	if(tick_interval > world.time)
		START_PROCESSING(SSprocessing, src)

/datum/antagonist/borer/process(seconds_per_tick)
	if(QDELETED(user))
		qdel(src)
		return

	if(tick_interval != -1 && tick_interval <= world.time)
		var/tick_length = initial(tick_interval)

		for(var/datum/borer_focus/focus as anything in learned_focuses)
			focus.tick(tick_length / (1 SECONDS))

		borer_rank.tick(tick_length / (1 SECONDS))
		tick_interval = world.time + tick_length

		if(QDELING(src))
			return

/datum/antagonist/borer/proc/update_rank()
	switch(borer_rank.type)
		if(BORER_RANK_YOUNG)
			borer_rank = new BORER_RANK_MATURE(user)
		if(BORER_RANK_MATURE)
			borer_rank = new BORER_RANK_ADULT(user)
		if(BORER_RANK_ADULT)
			borer_rank = new BORER_RANK_ELDER(user)

	to_chat(user.controlling ? host : user, span_notice("Вы эволюционировали. Ваш текущий ранг - [borer_rank.rankname]."))
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
		return

	if(parent.host.ckey && !LAZYIN(parent.host.UID(), used_UIDs))
		parent.user.max_chems += SCALING_CHEM_GAIN
		used_UIDs += parent.host.UID()

	return TRUE

/datum/borer_misc/change_host_and_scale/Destroy(force)
	LAZYNULL(used_UIDs)
	return ..()
