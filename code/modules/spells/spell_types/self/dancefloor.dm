/datum/action/cooldown/spell/summon_dancefloor
	name = "Призвать танцпол"
	desc = "Когда Дьяволу действительно нужно зажечь."
	spell_requirements = SPELL_REQUIRES_NO_ANTIMAGIC
	school = SCHOOL_CONJURATION
	cooldown_time = 1 SECONDS
	button_icon_state = "funk"
	background_icon_state = "bg_demon"
	invocation = "Saltare, peccatores, saltare!"
	invocation_type = INVOCATION_SHOUT

	var/list/dancefloor_turfs
	var/list/dancefloor_turfs_types
	var/dancefloor_exists = FALSE

/datum/action/cooldown/spell/summon_dancefloor/cast(atom/cast_on)
	. = ..()
	LAZYINITLIST(dancefloor_turfs)
	LAZYINITLIST(dancefloor_turfs_types)

	if(dancefloor_exists)
		dancefloor_exists = FALSE
		for(var/i in 1 to length(dancefloor_turfs))
			var/turf/T = dancefloor_turfs[i]
			T.ChangeTurf(dancefloor_turfs_types[i])
	else
		var/list/funky_turfs = RANGE_TURFS(1, owner)
		for(var/turf/T in funky_turfs)
			if(T.density)
				to_chat(owner, span_warning("Вы находитесь слишком близко к стене."))
				return

		dancefloor_exists = TRUE
		var/i = 1

		dancefloor_turfs.len = funky_turfs.len
		dancefloor_turfs_types.len = funky_turfs.len

		for(var/t in funky_turfs)
			var/turf/T = t
			dancefloor_turfs[i] = T
			dancefloor_turfs_types[i] = T.type
			T.ChangeTurf((i % 2 == 0) ? /turf/simulated/floor/light/colour_cycle/dancefloor_a : /turf/simulated/floor/light/colour_cycle/dancefloor_b)
			i++
