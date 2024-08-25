/mob/living/proc/Life(seconds, times_fired)
	set waitfor = FALSE
	set invisibility = 0

	SEND_SIGNAL(src, COMSIG_LIVING_LIFE, seconds, times_fired)

	if(client || registered_z) // This is a temporary error tracker to make sure we've caught everything
		var/turf/T = get_turf(src)
		if(client && registered_z != T.z)
			message_admins("[src] [ADMIN_FLW(src, "FLW")] has somehow ended up in Z-level [T.z] despite being registered in Z-level [registered_z]. If you could ask them how that happened and notify the coders, it would be appreciated.")
			add_misc_logs(src, "Z-TRACKING: [src] has somehow ended up in Z-level [T.z] despite being registered in Z-level [registered_z].")
			update_z(T.z)
		else if (!client && registered_z)
			add_misc_logs(src, "Z-TRACKING: [src] of type [src.type] has a Z-registration despite not having a client.")
			update_z(null)

	if(HAS_TRAIT(src, TRAIT_NO_TRANSFORM))
		return FALSE

	if(!loc)
		return FALSE
	INVOKE_ASYNC(src, PROC_REF(burst_blob_in_mob))

	if(stat != DEAD)
		//Chemicals in the body
		if(reagents)
			handle_chemicals_in_body()

	if(QDELETED(src)) // some chems can gib mobs
		return

	if(stat != DEAD)
		//Mutations and radiation
		handle_mutations_and_radiation()

	if(stat != DEAD)
		//Breathing, if applicable
		handle_breathing(times_fired)

	if(stat != DEAD)
		//Random events (vomiting etc)
		handle_random_events()

	if(LAZYLEN(diseases))
		handle_diseases()

	if(QDELETED(src)) // diseases can qdel the mob via transformations
		return

	//Heart Attack, if applicable
	if(stat != DEAD)
		handle_heartattack()

	//Handle temperature/pressure differences between body and environment
	var/datum/gas_mixture/environment = loc.return_air()
	if(environment)
		handle_environment(environment)

	handle_fire()

	var/datum/antagonist/vampire/vamp = mind?.has_antag_datum(/datum/antagonist/vampire)
	if(vamp)
		vamp.handle_vampire()

	if(pulledby && pulledby.grab_state > GRAB_PASSIVE)
		pull_on_life()

	if(stat != DEAD)
		handle_critical_condition()

	if(stat != DEAD) // Status & health update, are we dead or alive etc.
		handle_disabilities() // eye, ear, brain damages

	if(stat != DEAD)
		handle_status_effects() //all special effects, stunned, weakened, jitteryness, hallucination, sleeping, etc

	if(stat != DEAD)
		if(forced_look && !isnum(forced_look))
			var/atom/A = locateUID(forced_look)
			if(istype(A))
				var/view = client ? client.maxview() : world.view
				if(get_dist(src, A) > view || !(src in viewers(view, A)))
					clear_forced_look(TRUE)
					to_chat(src, span_notice("Your direction target has left your view, you are no longer facing anything."))
			else
				clear_forced_look(TRUE)
				to_chat(src, span_notice("Your direction target has left your view, you are no longer facing anything."))
		// Make sure it didn't get cleared
		if(forced_look)
			setDir()

	if(machine)
		machine.check_eye(src)

	handle_gravity(seconds, times_fired)

	handle_SSD(seconds)

	if(stat != DEAD)
		return TRUE

/mob/living/proc/handle_breathing(times_fired)
	return

/mob/living/proc/handle_heartattack()
	return

/mob/living/proc/handle_mutations_and_radiation()
	radiation = 0 //so radiation don't accumulate in simple animals

/mob/living/proc/handle_chemicals_in_body()
	return

/mob/living/proc/handle_diseases()
	for(var/thing in diseases)
		var/datum/disease/D = thing
		D.stage_act()

/mob/living/proc/handle_random_events()
	return

/mob/living/proc/handle_environment(datum/gas_mixture/environment)
	return

//this updates all special effects: mainly stamina
/mob/living/proc/handle_status_effects() // We check for the status effect in this proc as opposed to the procs below to avoid excessive proc call overhead
	return

/mob/living/proc/update_damage_hud()
	return

/mob/living/proc/handle_disabilities()
	//Eyes
	if(HAS_TRAIT(src, TRAIT_BLIND) || stat)	//blindness from disability or unconsciousness doesn't get better on its own
		EyeBlind(2 SECONDS)

// Gives a mob the vision of being dead
/mob/living/proc/grant_death_vision()
	add_sight(SEE_TURFS|SEE_MOBS|SEE_OBJS)
	lighting_alpha = LIGHTING_PLANE_ALPHA_INVISIBLE
	set_invis_see(SEE_INVISIBLE_OBSERVER)
	sync_lighting_plane_alpha()

/mob/living/proc/handle_critical_condition()
	return

/mob/living/update_health_hud()
	if(!client)
		return
	if(healths)
		var/severity = 0
		var/healthpercent = (health / maxHealth) * 100
		switch(healthpercent)
			if(100 to INFINITY)
				healths.icon_state = "health0"
			if(80 to 100)
				healths.icon_state = "health1"
				severity = 1
			if(60 to 80)
				healths.icon_state = "health2"
				severity = 2
			if(40 to 60)
				healths.icon_state = "health3"
				severity = 3
			if(20 to 40)
				healths.icon_state = "health4"
				severity = 4
			if(1 to 20)
				healths.icon_state = "health5"
				severity = 5
			else
				healths.icon_state = "health7"
				severity = 6
		if(severity > 0)
			overlay_fullscreen("brute", /atom/movable/screen/fullscreen/brute, severity)
		else
			clear_fullscreen("brute")


/mob/living/update_stamina_hud(shown_stamina_loss)
	if(!client || !stamina_bar)
		return

	var/stam_crit_threshold = maxHealth - HEALTH_THRESHOLD_CRIT

	if(stat == DEAD)
		stamina_bar.icon_state = "stamina_dead"
		return

	if(shown_stamina_loss == null)
		shown_stamina_loss = getStaminaLoss()

	if(shown_stamina_loss >= stam_crit_threshold)
		stamina_bar.icon_state = "stamina_crit"
	else if(shown_stamina_loss > maxHealth * 0.8)
		stamina_bar.icon_state = "stamina_5"
	else if(shown_stamina_loss > maxHealth * 0.6)
		stamina_bar.icon_state = "stamina_4"
	else if(shown_stamina_loss > maxHealth * 0.4)
		stamina_bar.icon_state = "stamina_3"
	else if(shown_stamina_loss > maxHealth * 0.2)
		stamina_bar.icon_state = "stamina_2"
	else if(shown_stamina_loss > 0)
		stamina_bar.icon_state = "stamina_1"
	else
		stamina_bar.icon_state = "stamina_full"


/mob/living/simple_animal/update_health_hud()
	if(!client)
		return
	var/severity = 0
	var/healthpercent = (health/maxHealth) * 100
	if(healths)
		..()
	if(healthdoll)
		var/atom/movable/screen/healthdoll/living/livingdoll = healthdoll
		switch(healthpercent)
			if(100 to INFINITY)
				severity = 0
			if(80 to 100)
				severity = 1
			if(60 to 80)
				severity = 2
			if(40 to 60)
				severity = 3
			if(20 to 40)
				severity = 4
			if(1 to 20)
				severity = 5
			else
				severity = 6
		livingdoll.icon_state = "living[severity]"
		if(!livingdoll.filtered)
			livingdoll.filtered = TRUE
			var/icon/mob_mask = icon(icon, icon_state)
			if(mob_mask.Height() > world.icon_size || mob_mask.Width() > world.icon_size)
				var/health_doll_icon_state = health_doll_icon ? health_doll_icon : "megasprite"
				mob_mask = icon('icons/mob/screen_gen.dmi', health_doll_icon_state) //swap to something generic if they have no special doll
			livingdoll.add_filter("mob_shape_mask", 1, alpha_mask_filter(icon = mob_mask))
			livingdoll.add_filter("inset_drop_shadow", 2, drop_shadow_filter(size = -1))
	if(severity > 0)
		overlay_fullscreen("brute", /atom/movable/screen/fullscreen/brute, severity)
	else
		clear_fullscreen("brute")


/mob/living/proc/handle_gravity(seconds_per_tick, times_fired)
	if(gravity_state > STANDARD_GRAVITY)
		handle_high_gravity(gravity_state, seconds_per_tick, times_fired)


/mob/living/proc/gravity_animate()
	if(!get_filter("gravity"))
		add_filter("gravity",1,list("type"="motion_blur", "x"=0, "y"=0))
	animate(get_filter("gravity"), y = 1, time = 10, loop = -1)
	animate(y = 0, time = 10)


/mob/living/proc/handle_high_gravity(gravity, seconds_per_tick, times_fired)
	if(gravity < GRAVITY_DAMAGE_THRESHOLD) //Aka gravity values of 3 or more
		return

	var/grav_strength = gravity - GRAVITY_DAMAGE_THRESHOLD
	adjustBruteLoss(min(GRAVITY_DAMAGE_SCALING * grav_strength, GRAVITY_DAMAGE_MAXIMUM) * seconds_per_tick)


/// Updates grabbed victim status effects.
/mob/living/proc/pull_on_life()
	var/mob/grabber = pulledby
	if(HAS_TRAIT(grabber, TRAIT_PACIFISM) || GLOB.pacifism_after_gt)
		grabber.stop_pulling()
		return

	if(grabber.grab_state >= GRAB_AGGRESSIVE && grabber.zone_selected == BODY_ZONE_PRECISE_EYES && ishuman(src))
		AdjustEyeBlind(3 SECONDS, bound_upper = 6 SECONDS)

	var/breathing_tube = get_organ_slot(INTERNAL_ORGAN_BREATHING_TUBE)

	if(grabber.grab_state >= GRAB_NECK && !breathing_tube)
		adjustOxyLoss(1)

	if(grabber.grab_state >= GRAB_KILL)
		AdjustStuttering(5 SECONDS, bound_upper = 10 SECONDS)	//It will hamper your voice, being choked and all.
		if(!breathing_tube)
			AdjustLoseBreath(3 SECONDS, bound_upper = 6 SECONDS)


/// Handles mob SSD status.
/mob/living/proc/handle_SSD(seconds_per_tick)
	if(isnull(player_logged))
		return FALSE
	if(stat == DEAD)
		set_SSD(FALSE)
		return FALSE
	player_logged += seconds_per_tick SECONDS	// called every 2s. on life
	return TRUE

