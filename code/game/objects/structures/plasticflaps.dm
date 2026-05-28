/obj/structure/plasticflaps
	name = "airtight plastic flaps"
	desc = "Прочные герметичные пластиковые занавески. Сквозь них точно не пройти. Ни за что."
	gender = PLURAL
	icon = 'icons/obj/stationobjs.dmi'
	icon_state = "plasticflaps"
	anchored = TRUE
	pass_flags_self = PASSFLAPS
	can_astar_pass = CANASTARPASS_ALWAYS_PROC
	integrity_failure = 225
	// This layer only matters for determining when you click it vs other objects
	layer = BELOW_OPEN_DOOR_LAYER
	armor = list(MELEE = 100, BULLET = 80, LASER = 80, ENERGY = 100, BOMB = 50, BIO = 100, FIRE = 50, ACID = 50)
	cares_about_temperature = TRUE
	/// If TRUE, we can't pass through unless the mob is resting (or fulfills more specific requirements)
	var/require_resting = TRUE
	/// Layer the flaps render on
	var/flaps_layer = ABOVE_MOB_LAYER
	/// Alpha of the flaps
	var/flaps_alpha = 255
	/// Limits how much damage from environmental fire we can take per second
	COOLDOWN_DECLARE(burn_damage_cd)
	/// Can it atmos pass?
	var/can_atmos_pass = FALSE

/obj/structure/plasticflaps/get_ru_names()
	return list(
		NOMINATIVE = "герметичные пластиковые занавески",
		GENITIVE = "герметичных пластиковых занавесок",
		DATIVE = "герметичным пластиковым занавескам",
		ACCUSATIVE = "герметичные пластиковые занавески",
		INSTRUMENTAL = "герметичными пластиковыми занавесками",
		PREPOSITIONAL = "герметичных пластиковых занавесках",
	)

/obj/structure/plasticflaps/opaque
	opacity = TRUE

/obj/structure/plasticflaps/kitchen
	name = "cold room plastic flaps"
	desc = "Лёгкие и герметичные пластиковые занавески, призванные удерживать холод в холодильной комнате, а тепло — в тёплой."
	armor = list(MELEE = 50, BULLET = 80, LASER = 80, ENERGY = 100, BOMB = 50, BIO = 100, FIRE = 20, ACID = 20)
	require_resting = FALSE
	flaps_alpha = 150

/obj/structure/plasticflaps/kitchen/get_ru_names()
	return list(
		NOMINATIVE = "пластиковые занавески холодильной комнаты",
		GENITIVE = "пластиковых занавесок холодильной комнаты",
		DATIVE = "пластиковым занавескам холодильной комнаты",
		ACCUSATIVE = "пластиковые занавески холодильной комнаты",
		INSTRUMENTAL = "пластиковыми занавесками холодильной комнаты",
		PREPOSITIONAL = "пластиковых занавесках холодильной комнаты",
	)

/obj/structure/plasticflaps/Initialize(mapload)
	. = ..()
	alpha = 0
	gen_overlay()
	update_atmos_behaviour()
	recalculate_atmos_connectivity()
	var/static/list/loc_connections = list(
		COMSIG_ATOM_EXITED = PROC_REF(play_plastic_sound),
	)
	AddElement(/datum/element/connect_loc, loc_connections)

/obj/structure/plasticflaps/Destroy(force)
	var/turf/old_turf = get_turf(src)
	. = ..()
	if(old_turf)
		old_turf.recalculate_atmos_connectivity()

/obj/structure/plasticflaps/proc/play_plastic_sound(obj/source, atom/movable/exiting)
	SIGNAL_HANDLER
	if(isitem(exiting))
		var/obj/item/item_exiter = exiting
		if(item_exiter.w_class <= WEIGHT_CLASS_NORMAL)
			return
		if(item_exiter.item_flags & ABSTRACT)
			return
	if(isliving(exiting))
		var/mob/living/living_exiter = exiting
		if(living_exiter.mob_size <= MOB_SIZE_TINY)
			return
		// you're crawling under them
		if(living_exiter.body_position == LYING_DOWN)
			return
		if(living_exiter.incorporeal_move)
			return
	if(locate(/obj/structure/plasticflaps) in exiting.loc)
		return
	playsound(src, 'sound/effects/plasticflaps.ogg', 50, TRUE, ignore_walls = FALSE, falloff_exponent = 8, extrarange = SHORT_RANGE_SOUND_EXTRARANGE)

/obj/structure/plasticflaps/temperature_expose(exposed_temperature, exposed_volume)
	..()
	if(exposed_temperature < FIRE_MINIMUM_TEMPERATURE_TO_EXIST * 1.5)
		return
	if(!COOLDOWN_FINISHED(src, burn_damage_cd))
		return
	COOLDOWN_START(src, burn_damage_cd, 1 SECONDS)
	var/percent_damage_taken = clamp(0.2 * (exposed_temperature / (FIRE_MINIMUM_TEMPERATURE_TO_EXIST * 2.5)), 0.05, 0.25)
	take_damage(max_integrity * percent_damage_taken, BURN, FIRE, sound_effect = FALSE)

/obj/structure/plasticflaps/obj_break(damage_flag)
	if(damage_flag == FIRE)
		visible_message(span_warning("[DECLENT_RU_CAP(src, NOMINATIVE)] начинают плавиться от жара!"))
	return ..()

/obj/structure/plasticflaps/obj_destruction(damage_flag)
	if(damage_flag == FIRE)
		visible_message(span_warning("[DECLENT_RU_CAP(src, NOMINATIVE)] оплавляются в пластиковую жижу!"))
	return ..()

/obj/structure/plasticflaps/on_changed_z_level(turf/old_turf, turf/new_turf, same_z_layer, notify_contents)
	if(!same_z_layer)
		SSvis_overlays.remove_vis_overlay(src, managed_vis_overlays)
		gen_overlay()
	return ..()

/obj/structure/plasticflaps/setDir(newdir)
	. = ..()
	SSvis_overlays.remove_vis_overlay(src, managed_vis_overlays)
	gen_overlay()

/obj/structure/plasticflaps/proc/gen_overlay()
	var/turf/our_turf = get_turf(src)
	if(!our_turf)
		return
	//you see mobs under it, but you hit them like they are above it
	SSvis_overlays.add_vis_overlay(src, icon, icon_state,
		layer = flaps_layer,
		plane = MUTATE_PLANE(GAME_PLANE, our_turf),
		dir = dir,
		alpha = flaps_alpha,
		add_appearance_flags = RESET_ALPHA,
	)

/obj/structure/plasticflaps/vv_edit_var(var_name, var_val)
	. = ..()
	var/list/relevant_vars = list(
		NAMEOF(src, flaps_layer),
		NAMEOF(src, flaps_alpha),
		NAMEOF(src, dir),
		NAMEOF(src, icon),
		NAMEOF(src, icon_state),
	)
	if(var_name in relevant_vars)
		SSvis_overlays.remove_vis_overlay(src, managed_vis_overlays)
		gen_overlay()

/obj/structure/plasticflaps/examine(mob/user)
	. = ..()
	if(anchored)
		. += span_notice("[DECLENT_RU_CAP(src, NOMINATIVE)] [span_bold("прикручены")] к полу.")
	else
		. += span_notice("[DECLENT_RU_CAP(src, NOMINATIVE)] больше не [span_italics("прикручены")] к полу, и их можно [span_bold("разрезать")].")

/obj/structure/plasticflaps/screwdriver_act(mob/living/user, obj/item/item)
	if(..())
		return TRUE
	add_fingerprint(user)
	if(anchored)
		SCREWDRIVER_ATTEMPT_UNSCREW_MESSAGE
	else
		SCREWDRIVER_ATTEMPT_SCREW_MESSAGE
	if(!item.use_tool(src, user, 10 SECONDS, volume = item.tool_volume, extra_checks = CALLBACK(src, PROC_REF(check_anchored_state), anchored)))
		return TRUE
	if(anchored)
		SCREWDRIVER_UNSCREW_MESSAGE
	else
		SCREWDRIVER_SCREW_MESSAGE
	set_anchored(!anchored)
	update_atmos_behaviour()
	recalculate_atmos_connectivity()
	return TRUE

/// Update the flaps behaviour to gases, if not anchored will let air pass through
/obj/structure/plasticflaps/proc/update_atmos_behaviour()
	can_atmos_pass = !anchored

/obj/structure/plasticflaps/get_superconductivity(direction)
	return can_atmos_pass ? ..() : ZERO_HEAT_TRANSFER_COEFFICIENT

/obj/structure/plasticflaps/welder_act(mob/user, obj/item/item)
	if(anchored)
		return ..()
	. = TRUE
	if(!item.tool_use_check(user, 0))
		return
	WELDER_ATTEMPT_SLICING_MESSAGE
	if(!item.use_tool(src, user, 5 SECONDS, volume = item.tool_volume))
		return
	if(anchored)
		return
	WELDER_SLICING_SUCCESS_MESSAGE
	var/obj/item/stack/sheet/plastic/five/plastic = new(drop_location())
	plastic.add_fingerprint(user)
	qdel(src)

/obj/structure/plasticflaps/proc/check_anchored_state(check_anchored)
	return anchored == check_anchored

/obj/structure/plasticflaps/CanAllowThrough(atom/movable/mover, border_dir)
	. = ..()

	if(checkpass(mover, PASSFLAPS)) // For anything specifically engineered to cross plastic flaps.
		return TRUE

	if(checkpass(mover, PASSGLASS) && prob(60))
		return TRUE

	if(!require_resting)
		return TRUE

	if(istype(mover, /obj/structure/bed))
		var/obj/structure/bed/bed_mover = mover
		if(bed_mover.density || bed_mover.has_buckled_mobs()) // if it's a bed/chair and is dense or someone is buckled, it will not pass
			return FALSE

	else if(ismecha(mover))
		return FALSE

	else if(isliving(mover)) // You Shall Not Pass!
		var/mob/living/living_mover = mover
		if(istype(living_mover.buckled, /mob/living/simple_animal/bot/mulebot)) // mulebot passenger gets a free pass.
			return TRUE

		if(living_mover.body_position != LYING_DOWN && living_mover.mob_size != MOB_SIZE_TINY && !is_ventcrawler(living_mover))	//If your not laying down, or a ventcrawler or a small creature, no pass.
			return FALSE

	return .

/obj/structure/plasticflaps/CanAStarPass(to_dir, datum/can_pass_info/pass_info)
	if(!require_resting)
		return TRUE
	if(pass_info.is_living)
		if(pass_info.is_bot)
			return TRUE
		if(!pass_info.can_ventcrawl && pass_info.mob_size != MOB_SIZE_TINY)
			return FALSE
	if(pass_info.pass_flags & PASSFLAPS)
		return TRUE
	if(pass_info.pulling_info)
		return CanAStarPass(to_dir, pass_info.pulling_info)
	return TRUE //diseases, stings, etc can pass

/obj/structure/plasticflaps/deconstruct(disassembled = TRUE)
	if(!(obj_flags & NODECONSTRUCT))
		new /obj/item/stack/sheet/plastic/five(drop_location())
	qdel(src)

/obj/structure/plasticflaps/CanAtmosPass(direction)
	return can_atmos_pass
