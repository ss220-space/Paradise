// Singulo, tesla, and explosive delam

/// When we have too much gas.
/datum/sm_delam/singularity

/datum/sm_delam/singularity/can_select(obj/machinery/power/supermatter_crystal/sm)
	return (sm.absorbed_gasmix.total_moles() >= MOLE_PENALTY_THRESHOLD)

/datum/sm_delam/singularity/delam_progress(obj/machinery/power/supermatter_crystal/sm)
	if(!..())
		return FALSE
	radio_announce(
		"Warning: Critical coolant mass reached.",
		sm,
		sm.damage > sm.emergency_point ? sm.emergency_channel : sm.warning_channel,
		sm,
	)
	return TRUE

/datum/sm_delam/singularity/delaminate(obj/machinery/power/supermatter_crystal/sm)
	message_admins("Supermatter [sm] at [ADMIN_VERBOSEJMP(sm)] triggered a singularity delam.")
	sm.investigate_log("triggered a singularity delam.", INVESTIGATE_ENGINE)

	effect_irradiate(sm)
	effect_demoralize(sm)
	if(sm.is_main_engine)
		effect_anomaly(sm)
	if(!effect_singulo(sm))
		effect_explosion(sm)
	return ..()

/datum/sm_delam/singularity/on_select(obj/machinery/power/supermatter_crystal/sm)
	if(sm.warp)
		return

	sm.warp = new(src)
	sm.vis_contents += sm.warp

/datum/sm_delam/singularity/filters(obj/machinery/power/supermatter_crystal/sm)
	..()
	var/cached_damage = sm.damage

	sm.modify_filter(name = "ray", new_params = list(
		color = SUPERMATTER_SINGULARITY_RAYS_COLOUR,
		factor =  clamp(cached_damage / 300, 1, 30),
		density =  clamp(cached_damage / 5, 12, 300)
	))

	sm.add_filter(name = "outline", priority = 2, params = list(
			type = "outline",
			size = 1,
			color = SUPERMATTER_SINGULARITY_LIGHT_COLOUR
		))

	if(sm.pulse_stage == 4)
		animate(sm.warp, time = 6, transform = matrix().Scale(0.5, 0.5))
		animate(time = 14, transform = matrix())
		sm.pulse_stage = 0
	else
		sm.pulse_stage++

	if(sm.final_countdown)
		sm.add_filter(name = "icon", priority = 3, params = list(
			type = "layer",
			icon = new/icon('icons/effects/96x96.dmi', "singularity_s3", frame = rand(1,8)),
			flags = FILTER_OVERLAY
		))
	else
		sm.remove_filter("icon")

/datum/sm_delam/singularity/on_deselect(obj/machinery/power/supermatter_crystal/sm)
	. = ..()
	sm.remove_filter(list("outline", "icon"))
	sm.vis_contents -= sm.warp
	QDEL_NULL(sm.warp)
	for(var/obj/darkness_effect in sm.darkness_effects)
		qdel(darkness_effect)

/datum/sm_delam/singularity/overlays(obj/machinery/power/supermatter_crystal/sm)
	return list()

/datum/sm_delam/singularity/lights(obj/machinery/power/supermatter_crystal/sm)
	..()
	var/cached_damage = sm.damage
	if(sm.get_integrity_percent() > SUPERMATTER_DANGER_PERCENT)
		sm.set_light(
			l_range = 4 + clamp((450 - cached_damage) / 10, 1, 50),
			l_power = 3,
			l_color = SUPERMATTER_SINGULARITY_LIGHT_COLOUR,
		)
		for(var/obj/darkness_effect in sm.darkness_effects)
			qdel(darkness_effect)
		return

	var/darkness_strength = clamp((cached_damage - 450) / 75, 1, 8) / 2
	var/darkness_aoe = clamp((cached_damage - 450) / 25, 1, 25)
	sm.set_light(
		l_range = 4 + darkness_aoe,
		l_power = -1 - darkness_strength,
		l_color = COLOR_DARK_DELAM,
	)
	var/x = sm.x
	var/y = sm.y
	var/z = sm.z
	var/list/cached_darkness_effects = sm.darkness_effects
	if(!length(cached_darkness_effects) && !sm.moveable) //Don't do this on movable sms oh god. Ideally don't do this at all, but hey, that's lightning for you
		cached_darkness_effects += new /obj/effect/abstract(locate(x - 3, y + 3, z))
		cached_darkness_effects += new /obj/effect/abstract(locate(x + 3, y + 3, z))
		cached_darkness_effects += new /obj/effect/abstract(locate(x - 3, y - 3, z))
		cached_darkness_effects += new /obj/effect/abstract(locate(x + 3, y - 3, z))
	else
		for(var/obj/object as anything in cached_darkness_effects)
			object.set_light(
				l_range = 0 + darkness_aoe,
				l_power = -1 - darkness_strength / 1.25,
				l_color = COLOR_DARK_DELAM,
			)

/// When we have too much power.
/datum/sm_delam/tesla

/datum/sm_delam/tesla/can_select(obj/machinery/power/supermatter_crystal/sm)
	return (sm.internal_energy > POWER_PENALTY_THRESHOLD)

/datum/sm_delam/tesla/delam_progress(obj/machinery/power/supermatter_crystal/sm)
	if(!..())
		return FALSE
	radio_announce(
		"DANGER: CHARGE INERTIA CHAIN REACTION IN PROGRESS.",
		sm,
		sm.damage > sm.emergency_point ? sm.emergency_channel : sm.warning_channel,
		sm,
	)
	return TRUE

/datum/sm_delam/tesla/delaminate(obj/machinery/power/supermatter_crystal/sm)
	message_admins("Supermatter [sm] at [ADMIN_VERBOSEJMP(sm)] triggered a tesla delam.")
	sm.investigate_log("triggered a tesla delam.", INVESTIGATE_ENGINE)

	effect_irradiate(sm)
	effect_demoralize(sm)
	if(sm.is_main_engine)
		effect_anomaly(sm)
	effect_tesla(sm)
	effect_explosion(sm)
	return ..()

/datum/sm_delam/tesla/filters(obj/machinery/power/supermatter_crystal/sm)
	..()
	var/cached_internal_energy = sm.internal_energy
	var/cached_damage = sm.damage
	sm.modify_filter(name = "ray", new_params = list(
		size = cached_internal_energy ? clamp((cached_damage / 100) * cached_internal_energy, 50, 175) : 1,
		color = SUPERMATTER_TESLA_COLOUR,
		factor = clamp(cached_damage / 300, 1, 20),
		density = clamp(cached_damage / 5, 12, 200)
	))
	if(prob(25))
		new /obj/effect/warp_effect/bsg(get_turf(sm)) //Some extra visual effect to the shocking sm which is a bit less interesting.
	sm.add_filter(name = "icon", priority = 2, params = list(
		type = "layer",
		icon = new/icon('icons/obj/engines_and_power/tesla/energy_ball.dmi', "energy_ball"),
		flags = FILTER_UNDERLAY
	))

/datum/sm_delam/tesla/on_deselect(obj/machinery/power/supermatter_crystal/sm)
	. = ..()
	sm.remove_filter(list("icon"))

/datum/sm_delam/tesla/lights(obj/machinery/power/supermatter_crystal/sm)
	..()
	sm.set_light(
		l_range = 4 + clamp(sm.damage * sm.internal_energy, 50, 500),
		l_power = 3,
		l_color = SUPERMATTER_TESLA_COLOUR,
	)

/// Default delam.
/datum/sm_delam/explosive

/datum/sm_delam/explosive/can_select(obj/machinery/power/supermatter_crystal/sm)
	return TRUE

/datum/sm_delam/explosive/delaminate(obj/machinery/power/supermatter_crystal/sm)
	message_admins("Supermatter [sm] at [ADMIN_VERBOSEJMP(sm)] triggered a normal delam.")
	sm.investigate_log("triggered a normal delam.", INVESTIGATE_ENGINE)

	effect_irradiate(sm)
	effect_demoralize(sm)
	if(sm.is_main_engine)
		effect_anomaly(sm)
	effect_explosion(sm)
	return ..()
