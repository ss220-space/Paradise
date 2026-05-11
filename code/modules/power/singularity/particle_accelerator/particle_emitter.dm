#define PARTICLE_STRENGTH_WEAK 0
#define PARTICLE_STRENGTH_NORMAL 1
#define PARTICLE_STRENGTH_STRONG 2
#define PARTICLE_STRENGTH_POWERFUL 3

/obj/structure/particle_accelerator/particle_emitter
	name = "EM Containment Grid"
	desc_holder = "This part launches the Alpha particles. You might not want to stand near this end."
	/// Per-emitter cooldown gating consecutive particle emissions.
	COOLDOWN_DECLARE(emit_cooldown)

/obj/structure/particle_accelerator/particle_emitter/center
	icon_state = "emitter_center"
	reference = "emitter_center"

/obj/structure/particle_accelerator/particle_emitter/left
	icon_state = "emitter_left"
	reference = "emitter_left"

/obj/structure/particle_accelerator/particle_emitter/right
	icon_state = "emitter_right"
	reference = "emitter_right"

/obj/structure/particle_accelerator/particle_emitter/proc/emit_particle(strength = PARTICLE_STRENGTH_WEAK)
	if(!COOLDOWN_FINISHED(src, emit_cooldown))
		return FALSE
	var/particle_type
	switch(strength)
		if(PARTICLE_STRENGTH_WEAK)
			particle_type = /obj/effect/accelerated_particle/weak
		if(PARTICLE_STRENGTH_NORMAL)
			particle_type = /obj/effect/accelerated_particle
		if(PARTICLE_STRENGTH_STRONG)
			particle_type = /obj/effect/accelerated_particle/strong
		if(PARTICLE_STRENGTH_POWERFUL)
			particle_type = /obj/effect/accelerated_particle/powerful
		else
			return FALSE
	COOLDOWN_START(src, emit_cooldown, 5 SECONDS)
	var/obj/effect/accelerated_particle/particle = new particle_type(get_turf(src))
	particle.setDir(dir)
	return TRUE

#undef PARTICLE_STRENGTH_WEAK
#undef PARTICLE_STRENGTH_NORMAL
#undef PARTICLE_STRENGTH_STRONG
#undef PARTICLE_STRENGTH_POWERFUL
