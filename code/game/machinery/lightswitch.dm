/// The light switch. Can have multiple per area.
/obj/machinery/light_switch
	name = "light switch"
	desc = "Выключатель для управления светом во всей комнате."
	icon = 'icons/obj/engines_and_power/power.dmi'
	icon_state = "light1"
	anchored = TRUE
	/// Set this to a string, path, or area instance to control that area instead of the switch's location.
	var/area/area = null
	/// Should this lightswitch automatically rename itself to match the area it's in?
	var/autoname = TRUE

/obj/machinery/light_switch/get_ru_names()
	return list(
		NOMINATIVE = "выключатель света",
		GENITIVE = "выключателя света",
		DATIVE = "выключателю света",
		ACCUSATIVE = "выключатель света",
		INSTRUMENTAL = "выключателем света",
		PREPOSITIONAL = "выключателе света"
	)

MAPPING_DIRECTIONAL_HELPERS(/obj/machinery/light_switch, 26)

/obj/machinery/light_switch/Initialize(mapload, direction)
	. = ..()
	if(direction)
		setDir(direction)
		set_pixel_offsets_from_dir(26, -26, 26, -26)

	if(istext(area))
		area = text2path(area)

	if(ispath(area))
		area = GLOB.areas_by_type[area]

	if(!area)
		area = get_area(src)

	if(autoname)
		name = "[declent_ru(NOMINATIVE)] ([area.name])"

	AddComponent(/datum/component/usb_port, list(
		/obj/item/circuit_component/light_switch,
	))

	update_icon()

/obj/machinery/light_switch/update_icon_state()
	if(stat & NOPOWER)
		icon_state = "light-p"
		return

	icon_state = "light[area.lightswitch]"

/obj/machinery/light_switch/update_overlays()
	. = ..()
	underlays.Cut()

	if(stat & NOPOWER)
		return

	underlays += emissive_appearance(icon, "light_lightmask", src)

/obj/machinery/light_switch/examine(mob/user)
	. = ..()
	. += span_boldnotice("[area.lightswitch ? "Включено" : "Выключено"].")

/obj/machinery/light_switch/attack_ghost(mob/user)
	if(user.can_advanced_admin_interact())
		return attack_hand(user)

/obj/machinery/light_switch/attack_hand(mob/user)
	add_fingerprint(user)
	set_lights(!area.lightswitch)

/obj/machinery/light_switch/proc/set_lights(status)
	if(area.lightswitch == status)
		return

	area.lightswitch = status
	update_icon()
	playsound(src, 'sound/machines/lightswitch.ogg', 10, TRUE)

	area.update_icon(UPDATE_ICON_STATE)

	for(var/obj/machinery/light_switch/light_switch in (area.machinery_cache - src))
		light_switch.update_icon()
		SEND_SIGNAL(light_switch, COMSIG_LIGHT_SWITCH_SET, status)

	area?.power_change()

/obj/machinery/light_switch/power_change(forced = FALSE)
	if(!..())
		return

	update_icon()

/obj/machinery/light_switch/emp_act(severity)
	if(stat & (BROKEN|NOPOWER))
		..(severity)
		return

	power_change()
	..(severity)

/obj/machinery/light_switch/attackby(obj/item/tool, mob/user, params)
	if(!istype(tool, /obj/item/detective_scanner))
		return ..()

	return ATTACK_CHAIN_PROCEED

/obj/machinery/light_switch/wrench_act(mob/user, obj/item/tool)
	. = TRUE
	if(!tool.tool_use_check(user, 0))
		return
	user.visible_message(
		span_notice("[user] starts unwrenching [src] from the wall..."),
		span_notice("You are unwrenching [src] from the wall..."),
		span_warning("You hear ratcheting.")
	)
	if(!tool.use_tool(src, user, 30, volume = tool.tool_volume))
		return
	WRENCH_UNANCHOR_WALL_MESSAGE
	new/obj/item/mounted/frame/light_switch(get_turf(src))
	qdel(src)


/obj/item/circuit_component/light_switch
	display_name = "выключатель света"
	desc = "Позволяет управлять освещением."
	circuit_flags = CIRCUIT_FLAG_INPUT_SIGNAL

	///If the lights should be turned on or off when the trigger is triggered.
	var/datum/port/input/on_setting
	///Whether the lights are turned on
	var/datum/port/output/is_on

	var/obj/machinery/light_switch/attached_switch

/obj/item/circuit_component/light_switch/populate_ports()
	on_setting = add_input_port("Вкл", PORT_TYPE_NUMBER)
	is_on = add_output_port("Включено", PORT_TYPE_NUMBER)

/obj/item/circuit_component/light_switch/register_usb_parent(atom/movable/parent)
	. = ..()
	if(!istype(parent, /obj/machinery/light_switch))
		return

	attached_switch = parent
	RegisterSignal(parent, COMSIG_LIGHT_SWITCH_SET, PROC_REF(on_light_switch_set))

/obj/item/circuit_component/light_switch/unregister_usb_parent(atom/movable/parent)
	attached_switch = null
	UnregisterSignal(parent, COMSIG_LIGHT_SWITCH_SET)
	return ..()

/obj/item/circuit_component/light_switch/proc/on_light_switch_set(datum/source, status)
	SIGNAL_HANDLER
	is_on.set_output(status)

/obj/item/circuit_component/light_switch/input_received(datum/port/input/port)
	attached_switch?.set_lights(on_setting.value ? TRUE : FALSE)
