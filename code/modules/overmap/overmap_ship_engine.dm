/obj/machinery/ship_engine
	name = "overmap engine"
	desc = "Двигатель, дающий тягу кораблю на карте системы."
	icon = 'icons/obj/machines/ship_engine.dmi'
	icon_state = "nozzle"
	anchored = TRUE
	density = TRUE
	idle_power_usage = 500
	active_power_usage = 2000
	use_power = IDLE_POWER_USE
	var/obj/overmap/entity/vessel
	var/on = TRUE
	var/thrust_limit = 1
	var/generated_thrust = 25

/obj/machinery/ship_engine/get_ru_names()
	return alist(
		NOMINATIVE = "двигатель корабля",
		GENITIVE = "двигателя корабля",
		DATIVE = "двигателю корабля",
		ACCUSATIVE = "двигатель корабля",
		INSTRUMENTAL = "двигателем корабля",
		PREPOSITIONAL = "двигателе корабля",
	)

/obj/machinery/ship_engine/Initialize(mapload)
	. = ..()
	GLOB.ship_engines += src
	if(SSovermap?.initialized)
		link_vessel()

/obj/machinery/ship_engine/Destroy()
	GLOB.ship_engines -= src
	vessel?.unregister_engine(src)
	vessel = null
	return ..()

/obj/machinery/ship_engine/proc/link_vessel()
	var/obj/overmap/entity/resolved = SSovermap?.resolve_vessel(src)
	if(!resolved)
		return
	resolved.register_engine(src)

/obj/machinery/ship_engine/proc/can_burn()
	if(!on || (stat & (BROKEN|NOPOWER)))
		return FALSE
	return TRUE

/obj/machinery/ship_engine/proc/get_thrust()
	if(!can_burn())
		return 0
	return generated_thrust * thrust_limit

/obj/machinery/ship_engine/proc/apply_thrust()
	if(!can_burn())
		return 0
	if(use_power != NO_POWER_USE)
		use_power(active_power_usage)
	return get_thrust()

/obj/machinery/ship_engine/proc/toggle()
	on = !on
	update_icon(UPDATE_OVERLAYS)

/obj/machinery/ship_engine/proc/get_status()
	if(stat & BROKEN)
		return "Повреждён"
	if(stat & NOPOWER)
		return "Нет питания"
	if(!on)
		return "Выключен"
	return "Готов"

/obj/machinery/ship_engine/update_overlays()
	. = ..()
	if(on && !(stat & (BROKEN|NOPOWER)))
		. += mutable_appearance(icon, "nozzle_idle")

/obj/machinery/ship_engine/infinite
	name = "test infinite engine"
	desc = "Тестовый двигатель без расхода топлива и энергии. Всегда даёт тягу, пока включён."
	use_power = NO_POWER_USE
	idle_power_usage = 0
	active_power_usage = 0
	generated_thrust = 80

/obj/machinery/ship_engine/infinite/can_burn()
	return on && !(stat & BROKEN)

/obj/machinery/ship_engine/virtual
	name = "virtual overmap drive"
	desc = "Служебный двигатель автопилота."
	generated_thrust = 40
	use_power = NO_POWER_USE
	idle_power_usage = 0
	active_power_usage = 0
	density = FALSE
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

/obj/effect/spawner/overmap_test_kit
	name = "overmap test kit"
	icon = OVERMAP_ICON_FILE
	icon_state = "ship"

/obj/effect/spawner/overmap_test_kit/Initialize(mapload)
	. = ..()
	var/turf/here = get_turf(src)
	if(here)
		new /obj/machinery/computer/helm(here)
		new /obj/machinery/computer/engines(get_step(here, EAST) || here)
		new /obj/machinery/ship_engine/infinite(get_step(here, WEST) || here)
		new /obj/machinery/transponder(get_step(here, SOUTH) || here)
		new /obj/machinery/computer/sensors(get_step(here, NORTH) || here)
		new /obj/machinery/sensor_array/long_range(get_step(here, NORTHEAST) || here)
		new /obj/machinery/sensor_array/short_range(get_step(here, NORTHWEST) || here)
	return INITIALIZE_HINT_QDEL
