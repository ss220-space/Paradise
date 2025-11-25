/datum/component/spawner
	var/spawner_mode = SIMPLE_SPAWNER
	var/mob_types = list(/mob/living/simple_animal/hostile/carp)
	var/faction = list("hostile")
	var/spawn_text = "появляется из"
	var/max_mobs = 5

	var/spawn_time = 300

	var/wave_size = 3
	var/wave_spawn_time = 100
	var/wave_cooldown = 600
	var/activation_message = "начинает гудеть!"
	var/deactivation_message = "затихает."
	var/current_wave_count = 0

	var/burst_size = 5
	var/burst_cooldown = 1200

	var/active_icon_state = "fab_robot"
	var/inactive_icon_state = "fab_robot"
	var/activation_sound = 'sound/machines/synth_yes.ogg'
	var/deactivation_sound = 'sound/machines/synth_no.ogg'

	var/is_active = FALSE
	var/list/spawned_mobs = list() // Добавлен список заспавненных мобов

	COOLDOWN_DECLARE(spawn_cooldown)
	COOLDOWN_DECLARE(wave_cooldown_timer)

/datum/component/spawner/Initialize(
		_mob_types,
		_spawner_mode,
		_faction,
		_spawn_text,
		_max_mobs,
		_spawn_time,
		_wave_size,
		_wave_spawn_time,
		_wave_cooldown,
		_activation_message,
		_deactivation_message,
		_burst_size,
		_burst_cooldown,
		_active_icon_state,
		_inactive_icon_state,
		_activation_sound,
		_deactivation_sound
	)

	if(_mob_types)
		mob_types = _mob_types
	if(_spawner_mode)
		spawner_mode = _spawner_mode
	if(_faction)
		faction = _faction
	if(_spawn_text)
		spawn_text = _spawn_text
	if(_max_mobs)
		max_mobs = _max_mobs

	if(_spawn_time)
		spawn_time = _spawn_time
	if(_wave_size)
		wave_size = _wave_size
	if(_wave_spawn_time)
		wave_spawn_time = _wave_spawn_time
	if(_wave_cooldown)
		wave_cooldown = _wave_cooldown
	if(_activation_message)
		activation_message = _activation_message
	if(_deactivation_message)
		deactivation_message = _deactivation_message
	if(_burst_size)
		burst_size = _burst_size
	if(_burst_cooldown)
		burst_cooldown = _burst_cooldown

	if(_active_icon_state)
		active_icon_state = _active_icon_state
	if(_inactive_icon_state)
		inactive_icon_state = _inactive_icon_state
	if(_activation_sound)
		activation_sound = _activation_sound
	if(_deactivation_sound)
		deactivation_sound = _deactivation_sound

	RegisterSignal(parent, COMSIG_QDELETING, PROC_REF(stop_spawning))
	START_PROCESSING(SSprocessing, src)

	switch(spawner_mode)
		if(WAVE_SPAWNER)
			COOLDOWN_START(src, wave_cooldown_timer, wave_cooldown)
		if(BURST_SPAWNER)
			COOLDOWN_START(src, spawn_cooldown, burst_cooldown)

	update_icon()

/datum/component/spawner/Destroy()
	stop_spawning()
	return ..()

/datum/component/spawner/proc/stop_spawning()
	SIGNAL_HANDLER
	STOP_PROCESSING(SSprocessing, src)
	for(var/mob/living/simple_animal/L as anything in spawned_mobs)
		if(L.nest == src)
			L.nest = null
	spawned_mobs.Cut()

/datum/component/spawner/process()
	switch(spawner_mode)
		if(SIMPLE_SPAWNER)
			handle_simple_spawn()
		if(WAVE_SPAWNER)
			handle_wave_spawn()
		if(BURST_SPAWNER)
			handle_burst_spawn()

/datum/component/spawner/proc/handle_simple_spawn()
	if(!COOLDOWN_FINISHED(src, spawn_cooldown))
		return

	if(!can_spawn_more())
		return

	spawn_mob()
	COOLDOWN_START(src, spawn_cooldown, spawn_time)

/datum/component/spawner/proc/handle_wave_spawn()
	if(is_active)
		if(!COOLDOWN_FINISHED(src, spawn_cooldown))
			return

		if(!can_spawn_more())
			finish_wave()
			return

		spawn_mob()
		current_wave_count++

		if(current_wave_count >= wave_size)
			finish_wave()
		else
			COOLDOWN_START(src, spawn_cooldown, wave_spawn_time)
	else
		if(COOLDOWN_FINISHED(src, wave_cooldown_timer))
			if(can_spawn_more() || max_mobs <= 0)
				start_wave()
			else
				COOLDOWN_START(src, wave_cooldown_timer, 100)

/datum/component/spawner/proc/handle_burst_spawn()
	if(!COOLDOWN_FINISHED(src, spawn_cooldown))
		return

	if(!can_spawn_more())
		return

	start_burst()
	COOLDOWN_START(src, spawn_cooldown, burst_cooldown)

/datum/component/spawner/proc/start_wave()
	is_active = TRUE
	current_wave_count = 0
	update_icon()

	var/atom/parent_atom = parent
	if(activation_message)
		parent_atom.visible_message(span_warning("[parent_atom] [activation_message]"))
	if(activation_sound)
		playsound(parent_atom, activation_sound, 50)

	COOLDOWN_START(src, spawn_cooldown, wave_spawn_time)

/datum/component/spawner/proc/finish_wave()
	is_active = FALSE
	update_icon()

	var/atom/parent_atom = parent
	if(deactivation_message)
		parent_atom.visible_message(span_warning("[parent_atom] [deactivation_message]"))
	if(deactivation_sound)
		playsound(parent_atom, deactivation_sound, 50)

	COOLDOWN_START(src, wave_cooldown_timer, wave_cooldown)

/datum/component/spawner/proc/start_burst()
	var/spawned_count = 0
	for(var/i in 1 to burst_size)
		if(!can_spawn_more())
			break
		addtimer(CALLBACK(src, .proc/spawn_mob), i * 20)
		spawned_count++

	if(spawned_count == 0)
		COOLDOWN_START(src, spawn_cooldown, 100)

/datum/component/spawner/proc/spawn_mob()
	if(!can_spawn_more())
		return FALSE

	var/mob_type = pick(mob_types)
	var/atom/parent_atom = parent
	var/mob/living/simple_animal/new_mob = new mob_type(get_turf(parent_atom))

	new_mob.faction = faction
	if(parent_atom.flags & ADMIN_SPAWNED)
		new_mob.flags |= ADMIN_SPAWNED

	spawned_mobs += new_mob
	new_mob.nest = src

	if(spawn_text)
		parent_atom.visible_message(span_danger("[new_mob] [spawn_text] [parent_atom]."))

	return TRUE

/datum/component/spawner/proc/can_spawn_more()
	if(max_mobs <= 0)
		return TRUE

	spawned_mobs -= null
	for(var/mob/living/simple_animal/M as anything in spawned_mobs)
		if(QDELETED(M) || M.stat == DEAD)
			spawned_mobs -= M
			if(M.nest == src)
				M.nest = null

	return length(spawned_mobs) < max_mobs

/datum/component/spawner/proc/update_icon()
	var/atom/parent_atom = parent
	if(!parent_atom)
		return

	if(is_active && active_icon_state)
		parent_atom.icon_state = active_icon_state
	else if(inactive_icon_state)
		parent_atom.icon_state = inactive_icon_state
