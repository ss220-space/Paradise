/obj/machinery/sensor_array
	name = "overmap sensor array"
	desc = "Антенна сканера карты системы. Без консоли управления почти бесполезна."
	icon = 'icons/obj/machines/overmap.dmi'
	icon_state = "sensor_short"
	anchored = TRUE
	density = TRUE
	idle_power_usage = 250
	active_power_usage = 2000
	use_power = IDLE_POWER_USE
	var/obj/overmap/entity/vessel
	var/sensor_kind = OVERMAP_SENSOR_KIND_LONG
	var/on = TRUE

/obj/machinery/sensor_array/get_ru_names()
	return alist(
		NOMINATIVE = "массив сенсоров",
		GENITIVE = "массива сенсоров",
		DATIVE = "массиву сенсоров",
		ACCUSATIVE = "массив сенсоров",
		INSTRUMENTAL = "массивом сенсоров",
		PREPOSITIONAL = "массиве сенсоров",
	)

/obj/machinery/sensor_array/Initialize(mapload)
	. = ..()
	GLOB.sensor_arrays += src
	if(SSovermap?.initialized)
		link_vessel()

/obj/machinery/sensor_array/Destroy()
	GLOB.sensor_arrays -= src
	vessel?.unregister_sensor_array(src)
	vessel = null
	return ..()

/obj/machinery/sensor_array/proc/link_vessel()
	var/obj/overmap/entity/resolved = SSovermap?.resolve_vessel(src)
	if(!resolved)
		return
	if(vessel && vessel != resolved)
		vessel.unregister_sensor_array(src)
	resolved.register_sensor_array(src)

/obj/machinery/sensor_array/proc/is_ready()
	return on && !(stat & (NOPOWER|BROKEN))

/obj/machinery/sensor_array/proc/update_sensor_power()
	if(!vessel)
		use_power = IDLE_POWER_USE
		return
	if(sensor_kind == OVERMAP_SENSOR_KIND_LONG && vessel.long_sensors_on && is_ready())
		use_power = ACTIVE_POWER_USE
	else if(sensor_kind == OVERMAP_SENSOR_KIND_SHORT && vessel.short_sensors_on && is_ready())
		use_power = ACTIVE_POWER_USE
	else
		use_power = IDLE_POWER_USE

/obj/machinery/sensor_array/power_change(forced = FALSE)
	. = ..()
	vessel?.refresh_sensor_displays()
	update_sensor_power()

/obj/machinery/sensor_array/attack_hand(mob/user)
	if(..())
		return TRUE
	on = !on
	to_chat(user, span_notice("[src] [on ? "включён" : "выключен"]."))
	vessel?.refresh_sensor_displays()
	update_sensor_power()

/obj/machinery/sensor_array/long_range
	name = "long-range sensor array"
	desc = "Антенна дальнего действия. Позволяет видеть массивные объекты в большом радиусе. Не допускает точное сканирование. Может выдать позицию в секторе."
	sensor_kind = OVERMAP_SENSOR_KIND_LONG
	icon_state = "sensor_long"

/obj/machinery/sensor_array/short_range
	name = "short-range sensor array"
	desc = "Антенна короткого действия. Сканирует объекты на ближней дистанции. Не раскрывает судно и позволяет сканировать ближайшие объекты."
	sensor_kind = OVERMAP_SENSOR_KIND_SHORT
	icon_state = "sensor_short"
	idle_power_usage = 150
/obj/machinery/sensor_array/short_range/pod
	name = "pod short-range sensors"
	use_power = NO_POWER_USE
	idle_power_usage = 0
	active_power_usage = 0
	density = FALSE
	invisibility = INVISIBILITY_ABSTRACT
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | UNACIDABLE | ACID_PROOF

/obj/machinery/sensor_array/short_range/pod/Initialize(mapload)
	. = ..()
	stat &= ~NOPOWER

/obj/machinery/sensor_array/short_range/pod/powered(chan)
	return TRUE

/obj/machinery/sensor_array/short_range/pod/is_ready()
	return TRUE

/obj/machinery/sensor_array/short_range/pod/link_vessel()
	var/obj/spacepod/craft = loc
	if(!isspacepod(craft) || !craft.overmap_vessel)
		return
	if(vessel && vessel != craft.overmap_vessel)
		vessel.unregister_sensor_array(src)
	vessel = craft.overmap_vessel
	vessel.register_sensor_array(src)
