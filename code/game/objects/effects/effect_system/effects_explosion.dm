/obj/effect/particle_effect/expl_particles
	name = "fire"
	icon_state = "explosion_particle"
	opacity = TRUE
	anchored = TRUE


/obj/effect/particle_effect/expl_particles/Initialize(mapload)
	..()
	return INITIALIZE_HINT_LATELOAD



/obj/effect/particle_effect/expl_particles/LateInitialize()
	var/step_amt = pick(25;1,50;2,100;3,200;4)

	var/datum/move_loop/loop = SSmove_manager.move(src, pick(GLOB.alldirs), 1, timeout = step_amt, priority = MOVEMENT_ABOVE_SPACE_PRIORITY)
	RegisterSignal(loop, COMSIG_QDELETING, PROC_REF(end_particle))

/obj/effect/particle_effect/ex_act(severity)
	return

/obj/effect/particle_effect/expl_particles/proc/end_particle(datum/source)
	SIGNAL_HANDLER
	if(QDELETED(src))
		return
	qdel(src)


/datum/effect_system/expl_particles
	number = 10


/datum/effect_system/expl_particles/start()
	for(var/i in 1 to number)
		new /obj/effect/particle_effect/expl_particles(location)

