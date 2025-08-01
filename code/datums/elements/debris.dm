/**
 * In this file you can find the particle element for bullet hits.
 * Originally from TGMC.
 */

/datum/element/debris
	element_flags = ELEMENT_BESPOKE
	id_arg_index = 2

	/// Icon state of debris when impacted by a projectile.
	var/debris = null
	/// Velocity of debris particles.
	var/debris_velocity = -40
	/// Amount of debris particles.
	var/debris_amount = 8
	/// Scale of particle debris.
	var/debris_scale = 1

/datum/element/debris/Attach(datum/target, _debris_icon_state, _debris_velocity = -40, _debris_amount = 8, _debris_scale = 1)
	. = ..()
	debris = _debris_icon_state
	debris_velocity = _debris_velocity
	debris_amount = _debris_amount
	debris_scale = _debris_scale
	RegisterSignal(target, COMSIG_ATOM_BULLET_ACT, PROC_REF(register_for_impact), override = TRUE) // Override because the element gets overriden.

/datum/element/debris/Detach(datum/source, force)
	. = ..()
	UnregisterSignal(source, COMSIG_ATOM_BULLET_ACT)

/datum/element/debris/proc/register_for_impact(datum/source, obj/projectile/proj)
	SIGNAL_HANDLER // COMSIG_ATOM_BULLET_ACT
	INVOKE_ASYNC(src, PROC_REF(on_impact), source, proj)

/datum/element/debris/proc/on_impact(datum/source, obj/projectile/proj)
	var/angle = !isnull(proj.Angle) ? proj.Angle : round(get_angle_tgmc(proj.starting, source), 1)
	var/x_component = sin(angle) * debris_velocity
	var/y_component = cos(angle) * debris_velocity
	var/x_component_smoke = sin(angle) * -37
	var/y_component_smoke = cos(angle) * -37

	var/obj/effect/abstract/particle_holder_tgmc/debris_visuals
	var/obj/effect/abstract/particle_holder_tgmc/smoke_visuals
	var/position_offset = rand(-6, 6)

	// Removing the effect of disabler or taser hits.
	if(proj.nodamage || proj.damage_type == STAMINA)
		return

	smoke_visuals = new(source, /particles/impact_smoke)
	smoke_visuals.particles.position = list(position_offset, position_offset)
	smoke_visuals.particles.velocity = list(x_component_smoke, y_component_smoke)

	if(debris && proj.damage_type == BRUTE)
		debris_visuals = new(source, /particles/debris)
		debris_visuals.particles.position = generator(GEN_CIRCLE, position_offset, position_offset)
		debris_visuals.particles.velocity = list(x_component, y_component)
		debris_visuals.layer = ABOVE_OBJ_LAYER + 0.02
		debris_visuals.particles.icon_state = debris
		debris_visuals.particles.count = debris_amount
		debris_visuals.particles.spawning = debris_amount
		debris_visuals.particles.scale = debris_scale
	smoke_visuals.layer = ABOVE_OBJ_LAYER + 0.01

	addtimer(CALLBACK(src, PROC_REF(remove_ping), src, smoke_visuals, debris_visuals), 0.5 SECONDS)

/datum/element/debris/proc/remove_ping(hit, obj/effect/abstract/particle_holder_tgmc/smoke_visuals, obj/effect/abstract/particle_holder_tgmc/debris_visuals)
	QDEL_NULL(smoke_visuals)
	if(debris_visuals)
		QDEL_NULL(debris_visuals)
