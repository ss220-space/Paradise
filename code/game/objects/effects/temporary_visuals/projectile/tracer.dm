// These are the visual tracers, the beams you see with hitscan effects.

/**
 * Generates a tracer beam between two points
 * Do not pass z-crossing points as that will not be properly (and likely will never be properly until it's absolutely needed) supported!
 *
 * Arguments:
 * * starting_position - The starting position of the tracer
 * * ending_position - The ending position of the tracer
 * * beam_type - The type of tracer beam to create
 * * tracer_color - The color of the tracer beam
 * * deletion_delay - Time in ticks before the tracer is deleted
 * * lighting_range - The range of the lighting effect
 * * lighting_color_override - Override color for the lighting effect
 * * lighting_intensity - The intensity of the lighting effect
 * * lighting_instance_key - Unique key for the lighting instance
 */
/proc/generate_tracer_between_points(datum/position/starting_position, datum/position/ending_position, beam_type, tracer_color, deletion_delay = 5, lighting_range = 2, lighting_color_override, lighting_intensity = 1, lighting_instance_key)
	if(isnull(starting_position) || isnull(ending_position) || isnull(beam_type))
		return

	var/datum/position/midpoint_position = point_midpoint_points(starting_position, ending_position)
	var/tracer_count = 0
	for(var/obj/effect/projectile/tracer/existing_tracer in midpoint_position.return_turf())
		tracer_count++

	if(tracer_count >= 3)
		return // Damage still happens, this should stop engineers with looping emitters doing shenanigans that makes the server cry

	var/obj/effect/projectile/tracer/tracer_instance = new beam_type
	if(isnull(lighting_color_override))
		lighting_color_override = tracer_color

	tracer_instance.apply_vars(
		angle_override = angle_between_points(starting_position, ending_position),
		p_x = midpoint_position.return_px(),
		p_y = midpoint_position.return_py(),
		color_override = tracer_color,
		scaling = pixel_length_between_points(starting_position, ending_position) / ICON_SIZE_ALL,
		new_loc = midpoint_position.return_turf(),
		increment = 0
	)
	. = tracer_instance

	if(!(lighting_range > 0 && lighting_intensity > 0))
		if(deletion_delay)
			QDEL_IN(tracer_instance, deletion_delay)
		return

	var/list/turf/line_of_sight = get_line(starting_position.return_turf(), ending_position.return_turf())
	for(var/turf/current_turf as anything in line_of_sight)
		for(var/obj/effect/projectile_lighting/existing_lighting in current_turf)
			if(existing_lighting.owner == locateUID(lighting_instance_key))
				continue
		QDEL_IN(new /obj/effect/projectile_lighting(current_turf, lighting_color_override, lighting_range, lighting_intensity, lighting_instance_key), deletion_delay > 0 ? deletion_delay : 5)

	line_of_sight = null
	if(deletion_delay)
		QDEL_IN(tracer_instance, deletion_delay)

/obj/effect/projectile/tracer
	name = "beam"
	icon = 'icons/obj/weapons/guns/projectiles_tracer.dmi'

/obj/effect/projectile/tracer/laser
	name = "laser"
	icon_state = "beam"

/obj/effect/projectile/tracer/laser/blue
	icon_state = "beam_blue"

/obj/effect/projectile/tracer/disabler
	name = "disabler"
	icon_state = "beam_omni"

/obj/effect/projectile/tracer/xray
	name = "X-ray laser"
	icon_state = "xray"

/obj/effect/projectile/tracer/pulse
	name = "pulse laser"
	icon_state = "u_laser"

/obj/effect/projectile/tracer/plasma_cutter
	name = "plasma blast"
	icon_state = "plasmacutter"

/obj/effect/projectile/tracer/plasma_cutter/adv
	name = "plasma blast adv"
	icon_state = "plasmacutter_adv"

/obj/effect/projectile/tracer/plasma_cutter/mega
	name = "plasma blast mega"
	icon_state = "plasmacutter_mega"

/obj/effect/projectile/tracer/stun
	name = "stun beam"
	icon_state = "stun"

/obj/effect/projectile/tracer/heavy_laser
	name = "heavy laser"
	icon_state = "beam_heavy"

/obj/effect/projectile/tracer/solar
	name = "solar beam"
	icon_state = "solar"

/obj/effect/projectile/tracer/solar/thin
	icon_state = "solar_thin"

/obj/effect/projectile/tracer/solar/thinnest
	icon_state = "solar_thinnest"

/obj/effect/projectile/tracer/tracer/beam_rifle
	icon_state = "tracer_beam"

/obj/effect/projectile/tracer/tracer/aiming
	icon_state = "pixelbeam_greyscale"
	plane = ABOVE_LIGHTING_PLANE

/obj/effect/projectile/tracer/wormhole
	icon_state = "wormhole_g"

/obj/effect/projectile/tracer/laser/emitter
	name = "emitter beam"
	icon_state = "emitter"

/obj/effect/projectile/tracer/laser/emitter/bluelens
	name = "electrodisruptive emitter beam"
	icon_state = "u_laser"

/obj/effect/projectile/tracer/laser/emitter/redlens
	name = "hyperenergetic emitter beam"
	icon_state = "beam_heavy"

/obj/effect/projectile/tracer/laser/emitter/bioregen
	name = "bioregenerative emitter beam"
	icon_state = "solar"

/obj/effect/projectile/tracer/laser/emitter/psy
	name = "psychosiphoning emitter beam"
	icon_state = "tracer_greyscale"
	color = COLOR_PINK

/obj/effect/projectile/tracer/laser/emitter/magnetic
	name = "magnetogenerative emitter beam"
	icon_state = "tracer_greyscale"
	color = COLOR_SILVER

/obj/effect/projectile/tracer/laser/emitter/quake
	name = "seismodisintegrating emitter beam"
	icon_state = "tracer_greyscale"
	color = COLOR_BROWNER_BROWN

/obj/effect/projectile/tracer/laser/emitter/blast
	name = "hyperconcussive emitter beam"
	icon_state = "tracer_greyscale"
	color = COLOR_ORANGE

/obj/effect/projectile/tracer/sniper
	icon_state = "sniper"

/obj/effect/projectile/tracer/death
	icon_state = "hcult"
