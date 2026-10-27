#define THRUSTER_OVERHANG 8

/obj/machinery/ship_engine
	name = "small advanced engine"
	desc = "Компактный двигатель. Даёт небольшую тягу, которой достаточно для комфортного передвижения на малых судах."
	icon = 'icons/turf/shuttle/misc.dmi'
	icon_state = "propulsion"
	anchored = TRUE
	appearance_flags = KEEP_TOGETHER
	density = TRUE
	opacity = TRUE
	idle_power_usage = 500
	active_power_usage = 2000
	resistance_flags = FIRE_PROOF
	max_integrity = 300
	use_power = NO_POWER_USE
	smoothing_groups = SMOOTH_GROUP_SHUTTLE_PARTS
	var/obj/overmap/entity/vessel
	var/on = TRUE
	var/thrust_limit = 1
	var/generated_thrust = OVERMAP_ENGINE_SMALL_THRUST
	var/requires_apc = FALSE
	var/side_thrust_fraction = 0.08
	var/wall_mounted = FALSE
	var/obj/machinery/power/apc/power_apc
	var/active_pushes = NONE
	var/engine_board

	var/omnidirectional = TRUE
	var/firing = FALSE
	var/engine_size = 1
	var/burn_icon = 'icons/obj/machines/ship_engine.dmi'
	var/burn_state = "nozzle_burn"
	var/burn_sound_type = /datum/looping_sound/ship_engine
	var/datum/looping_sound/burn_sound
	var/list/obj/structure/filler/fillers = list()

/obj/machinery/ship_engine/get_ru_names()
	return alist(
		NOMINATIVE = "[omnidirectional ? "продвинутый " : ""]двигатель корабля",
		GENITIVE = "[omnidirectional ? "продвинутого " : ""]двигателя корабля",
		DATIVE = "[omnidirectional ? "продвинутому " : ""]двигателю корабля",
		ACCUSATIVE = "[omnidirectional ? "продвинутый " : ""]двигатель корабля",
		INSTRUMENTAL = "[omnidirectional ? "продвинутым " : ""]двигателем корабля",
		PREPOSITIONAL = "[omnidirectional ? "продвинутом " : ""]двигателе корабля",
	)

/obj/machinery/ship_engine/Initialize(mapload)
	. = ..()
	GLOB.ship_engines += src
	create_engine_parts()
	if(engine_size == 2)
		spawn_engine_fillers(list(EAST, NORTH, NORTHEAST))
	else if(engine_size == 3)
		spawn_engine_fillers(list(EAST, WEST, NORTH, SOUTH, SOUTHEAST, SOUTHWEST, NORTHEAST, NORTHWEST))
	set_light_range_power_color(2)
	if(SSovermap?.initialized)
		link_vessel()

/obj/machinery/ship_engine/Destroy()
	QDEL_LIST(fillers)
	QDEL_NULL(burn_sound)
	GLOB.ship_engines -= src
	vessel?.unregister_engine(src)
	vessel = null
	return ..()

/obj/machinery/ship_engine/CanAtmosPass(direction)
	return !density

/obj/machinery/ship_engine/shuttleRotate(rotation, params)
	setDir(angle2dir(rotation + dir2angle(dir)))

/obj/machinery/ship_engine/proc/link_vessel()
	var/obj/overmap/entity/resolved = SSovermap?.resolve_vessel(src)
	if(!resolved)
		return
	resolved.register_engine(src)

/obj/machinery/ship_engine/proc/can_burn()
	if(!on || (stat & BROKEN) || (wall_mounted && !valid_wall_mount()))
		return FALSE
	if(requires_apc_power() && !get_power_apc()?.can_supply_equipment())
		return FALSE
	return fuel_available()

/obj/machinery/ship_engine/proc/get_thrust()
	if(!can_burn())
		return 0
	return generated_thrust * thrust_limit * 4 * resource_fraction(OVERMAP_FLIGHT_TICK)

/obj/machinery/ship_engine/proc/apply_thrust(elapsed = 1 SECONDS)
	if(!can_burn())
		return 0
	var/thrust = get_thrust()
	var/fraction = resource_fraction(elapsed)
	if(requires_apc_power() && !get_power_apc()?.cell?.use(active_power_usage * thrust_limit * elapsed / (1 SECONDS) * GLOB.CELLRATE * fraction))
		return 0
	if(!consume_fuel(elapsed * fraction))
		return 0
	return thrust

/obj/machinery/ship_engine/proc/toggle()
	on = !on
	update_icon(UPDATE_OVERLAYS)

/obj/machinery/ship_engine/proc/set_firing(new_firing, pushes = NONE)
	if(firing == new_firing && active_pushes == pushes)
		return
	firing = new_firing
	active_pushes = pushes
	update_icon(UPDATE_OVERLAYS)
	if(!firing)
		burn_sound?.stop()
		return
	if(!isturf(loc))
		return
	if(!burn_sound)
		burn_sound = new burn_sound_type(src)
	burn_sound.start()

/obj/machinery/ship_engine/proc/get_status()
	if(stat & BROKEN)
		return "Повреждён"
	if(!on)
		return "Выключен"
	if(wall_mounted && !valid_wall_mount())
		return "Нужна внешняя стена"
	if(requires_apc_power())
		var/obj/machinery/power/apc/apc = get_power_apc()
		if(!apc)
			return "Нет APC на шаттле"
		if(!apc.can_supply_equipment())
			return "APC отключён или разряжен"
	if(!fuel_available())
		return "Нет подачи плазмы"
	return "Готов"

/obj/machinery/ship_engine/update_overlays()
	. = ..()
	if(firing)
		for(var/push in GLOB.cardinal)
			if(!(active_pushes & push))
				continue
			. += exhaust_overlay(mutable_appearance(burn_icon, burn_state, appearance_flags = PIXEL_SCALE), REVERSE_DIR(push))
			. += exhaust_overlay(emissive_appearance(burn_icon, burn_state, src, appearance_flags = PIXEL_SCALE), REVERSE_DIR(push))
	if(icon != 'icons/obj/machines/ship_engine.dmi')
		return
	if(can_burn())
		. += mutable_appearance(icon, "nozzle_idle")

/obj/machinery/ship_engine/proc/exhaust_overlay(mutable_appearance/flame, exhaust_dir = dir)
	var/flame_scale = 1 + (engine_size - 1) / 2
	var/reach = (engine_size + flame_scale) * ICON_SIZE_X / 2
	flame.dir = exhaust_dir
	flame.pixel_w = (engine_size - 1) * ICON_SIZE_X / 2 + (!!(exhaust_dir & EAST) - !!(exhaust_dir & WEST)) * reach
	flame.pixel_z = (engine_size - 1) * ICON_SIZE_Y / 2 + (!!(exhaust_dir & NORTH) - !!(exhaust_dir & SOUTH)) * reach
	if(flame_scale != 1)
		flame.transform = matrix().Scale(flame_scale)
	return flame

/obj/machinery/ship_engine/proc/spawn_engine_fillers(list/dirs)
	for(var/direct in dirs)
		var/turf/spot = get_step(src, direct)
		if(!spot)
			continue
		var/obj/structure/filler/piece = new(spot)
		piece.parent = src
		fillers += piece

/obj/structure/filler/CanAtmosPass(direction)
	if(istype(parent, /obj/machinery/ship_engine))
		return FALSE
	return TRUE

/obj/machinery/ship_engine/small

/obj/machinery/ship_engine/large
	name = "large advanced engine"
	desc = "Тяжёлый двигатель. Даёт большое количество тяги для перелётов на самых больших судах."
	icon = 'icons/obj/2x2.dmi'
	icon_state = "large_engine"
	appearance_flags = LONG_GLIDE | KEEP_TOGETHER
	generated_thrust = OVERMAP_ENGINE_LARGE_THRUST
	idle_power_usage = 1500
	active_power_usage = 6000
	engine_size = 2
	side_thrust_fraction = 0

/obj/machinery/ship_engine/large/get_ru_names()
	return alist(
		NOMINATIVE = "большой продвинутый двигатель корабля",
		GENITIVE = "большого продвинутого двигателя корабля",
		DATIVE = "большому продвинутому двигателю корабля",
		ACCUSATIVE = "большой продвинутый двигатель корабля",
		INSTRUMENTAL = "большим продвинутым двигателем корабля",
		PREPOSITIONAL = "большом продвинутом двигателе корабля",
	)

/obj/machinery/ship_engine/huge
	name = "huge advanced engine"
	desc = "Гигантский блюспейс-двигатель. Сконструирован для передвижения самых огромных космических объектов."
	icon = 'icons/obj/3x3.dmi'
	icon_state = "huge_engine"
	pixel_x = -32
	pixel_y = -32
	appearance_flags = LONG_GLIDE | KEEP_TOGETHER
	generated_thrust = OVERMAP_ENGINE_LARGE_THRUST
	idle_power_usage = 1500
	active_power_usage = 6000
	engine_size = 3
	side_thrust_fraction = 0

/obj/machinery/ship_engine/huge/get_ru_names()
	return alist(
		NOMINATIVE = "огромный продвинутый двигатель корабля",
		GENITIVE = "огромного продвинутого двигателя корабля",
		DATIVE = "огромному продвинутому двигателю корабля",
		ACCUSATIVE = "огромный продвинутый двигатель корабля",
		INSTRUMENTAL = "огромным продвинутым двигателем корабля",
		PREPOSITIONAL = "огромном продвинутом двигателе корабля",
	)

/obj/machinery/ship_engine/virtual
	name = "virtual overmap drive"
	desc = "Служебный двигатель автопилота."
	generated_thrust = 40
	idle_power_usage = 0
	active_power_usage = 0
	density = FALSE
	opacity = FALSE
	invisibility = INVISIBILITY_ABSTRACT
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | UNACIDABLE | ACID_PROOF

/obj/machinery/ship_engine/virtual/Initialize(mapload)
	. = ..()
	stat &= ~NOPOWER

/obj/machinery/ship_engine/virtual/powered(chan)
	return TRUE

/obj/machinery/ship_engine/virtual/link_vessel()
	return

/obj/machinery/ship_engine/virtual/can_burn()
	return on && !(stat & BROKEN)

/obj/machinery/ship_engine/thruster
	omnidirectional = FALSE
	requires_apc = TRUE
	wall_mounted = TRUE
	side_thrust_fraction = 0
	obj_flags = NODECONSTRUCT
	name = "maneuvering thruster"
	desc = "Маленькое сопло на внешней обшивке. Слабо толкает корабль в свою сторону и помогает ему поворачивать."
	icon = 'icons/obj/machines/ship_thruster.dmi'
	icon_state = "thruster"
	layer = ABOVE_WINDOW_LAYER
	density = FALSE
	opacity = FALSE
	smoothing_groups = null
	idle_power_usage = 50
	active_power_usage = 400
	generated_thrust = OVERMAP_ENGINE_THRUSTER_THRUST
	burn_icon = 'icons/obj/machines/ship_thruster.dmi'
	burn_state = "thruster_burn"
	burn_sound_type = /datum/looping_sound/ship_engine/thruster

/obj/machinery/ship_engine/thruster/get_ru_names()
	return alist(
		NOMINATIVE = "маневровый двигатель",
		GENITIVE = "маневрового двигателя",
		DATIVE = "маневровому двигателю",
		ACCUSATIVE = "маневровый двигатель",
		INSTRUMENTAL = "маневровым двигателем",
		PREPOSITIONAL = "маневровом двигателе",
	)

/obj/machinery/ship_engine/thruster/Initialize(mapload)
	. = ..()
	stick_out()

/obj/machinery/ship_engine/thruster/setDir(newdir)
	. = ..()
	stick_out()

/obj/machinery/ship_engine/thruster/proc/stick_out()
	pixel_x = (!!(dir & EAST) - !!(dir & WEST)) * THRUSTER_OVERHANG
	pixel_y = (!!(dir & NORTH) - !!(dir & SOUTH)) * THRUSTER_OVERHANG

/datum/looping_sound/ship_engine
	start_sound = 'sound/machines/engine/engine_start.ogg'
	start_length = 0.3 SECONDS
	mid_sounds = list('sound/machines/engine/engine_mid1.ogg' = 1)
	mid_length = 0.3 SECONDS
	end_sound = 'sound/machines/engine/engine_end.ogg'
	volume = 25
	extra_range = 6
	pressure_affected = FALSE
	use_sound_tokens = TRUE

/datum/looping_sound/ship_engine/thruster
	volume = 12
	extra_range = 2

#undef THRUSTER_OVERHANG
