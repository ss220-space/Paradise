/proc/fire_projectile_burst(datum/callback/shot, count, delay)
	if(shot.object != GLOBAL_PROC && QDELETED(shot.object))
		return FALSE
	if(count < 1 || !shot.Invoke())
		return FALSE
	if(count > 1)
		addtimer(CALLBACK(GLOBAL_PROC, GLOBAL_PROC_REF(fire_projectile_burst), shot, count - 1, delay), max(delay, world.tick_lag))
	return TRUE

/proc/pod_emp(turf/spot)
	playsound(spot, 'sound/effects/empulse.ogg', 60, TRUE)
	new /obj/effect/temp_visual/emp/pulse(spot)
	for(var/atom/target in range(1, spot))
		target.emp_act(EMP_HEAVY)
	add_game_logs("Pod ion impact at [COORD(spot)]")

/proc/overmap_explosion_severity(dx, dy, devastation_range, heavy_impact_range, light_impact_range, protect_epicenter, direction, arc)
	var/distance = sqrt(dx ** 2 + dy ** 2)
	if(protect_epicenter && distance < 0.5)
		return 0
	if(distance >= 0.5 && arc < 360 && abs(closer_angle_difference(direction, delta_to_angle(dx, dy))) > arc / 2)
		return 0
	return EXPLOSION_SEVERITY(distance, devastation_range, heavy_impact_range, light_impact_range)

/proc/overmap_explosion_damage(severity)
	switch(severity)
		if(EXPLODE_DEVASTATE)
			return 250
		if(EXPLODE_HEAVY)
			return 150
		if(EXPLODE_LIGHT)
			return 60
	return 0
