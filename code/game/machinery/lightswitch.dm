// the light switch
// can have multiple per area
// can also operate on non-loc area through "otherarea" var
/obj/machinery/light_switch
	name = "light switch"
	desc = "It turns lights on and off. What are you, simple?"
	icon = 'icons/obj/engines_and_power/power.dmi'
	icon_state = "light1"
	anchored = TRUE
	var/on = TRUE
	var/area/area = null
	var/otherarea = null
	//	luminosity = 1
	var/light_connect = TRUE							//Allows the switch to control lights in its associated areas. When set to 0, using the switch won't affect the lights.
	var/logic_id_tag = "default"					//Defines the ID tag to send logic signals to.
	var/logic_connect = 0							//Set this to allow the switch to send out logic signals.


/obj/machinery/light_switch/New(turf/loc, w_dir)
	..()
	switch(w_dir)
		if(NORTH)
			pixel_y = 25
		if(SOUTH)
			pixel_y = -25
		if(EAST)
			pixel_x = 25
		if(WEST)
			pixel_x = -25


/obj/machinery/light_switch/Initialize(mapload)
	. = ..()
	set_frequency(frequency)

	if(otherarea)
		area = locate(text2path("/area/[otherarea]"))
	else
		area = get_area(src)

	if(!name)
		name = "light switch([area.name])"

	on = area.lightswitch
	light_switch_light()
	update_icon()


/obj/machinery/light_switch/set_frequency(new_frequency)
	SSradio.remove_object(src, frequency)
	frequency = new_frequency
	radio_connection = SSradio.add_object(src, frequency, RADIO_LOGIC)


/obj/machinery/light_switch/Destroy()
	if(SSradio)
		SSradio.remove_object(src, frequency)
	radio_connection = null
	return ..()


/obj/machinery/light_switch/proc/light_switch_light()
	if(stat & (NOPOWER|BROKEN))
		set_light_on(FALSE)
		return
	set_light(1, LIGHTING_MINIMUM_POWER, on ? COLOR_APC_GREEN : COLOR_APC_RED)


/obj/machinery/light_switch/update_icon_state()
	if(stat & NOPOWER)
		icon_state = "light-p"
		return
	icon_state = "light[on]"


/obj/machinery/light_switch/update_overlays()
	. = ..()
	underlays.Cut()

	if(stat & NOPOWER)
		return
	underlays += emissive_appearance(icon, "light_lightmask")


/obj/machinery/light_switch/examine(mob/user)
	. = ..()
	. += span_notice("A light switch. It is [on? "on" : "off"].")


/obj/machinery/light_switch/attack_ghost(mob/user)
	if(user.can_advanced_admin_interact())
		return attack_hand(user)


/obj/machinery/light_switch/attack_hand(mob/user)
	playsound(src, 'sound/machines/lightswitch.ogg', 10, TRUE)
	add_fingerprint(user)
	on = !on
	light_switch_light()
	update_icon()


	if(light_connect && area)
		area.lightswitch = on
		area.update_icon(UPDATE_ICON_STATE)

	if(logic_connect && powered(LIGHT))		//Don't bother sending a signal if we aren't set to send them or we have no power to send with.
		handle_output()

	if(light_connect)
		for(var/obj/machinery/light_switch/light_switch in area.machinery_cache)
			light_switch.on = on
			light_switch.light_switch_light()
			light_switch.update_icon()
		area?.power_change()


/obj/machinery/light_switch/proc/handle_output()
	if(!radio_connection)		//can't output without this
		return

	if(logic_id_tag == null)	//Don't output to an undefined id_tag
		return

	var/datum/signal/signal = new
	signal.transmission_method = 1	//radio signal
	signal.source = src

	//Light switches are continuous signal sources, since they register as ON or OFF and stay that way until adjusted again
	if(on)
		signal.data = list(
				"tag" = logic_id_tag,
				"sigtype" = "logic",
				"state" = LOGIC_ON,
		)
	else
		signal.data = list(
				"tag" = logic_id_tag,
				"sigtype" = "logic",
				"state" = LOGIC_OFF,
		)

	radio_connection.post_signal(src, signal, filter = RADIO_LOGIC)
	if(on)
		use_power(5, LIGHT)			//Use a tiny bit of power every time we send an ON signal. Draws from the local APC's lighting circuit, since this is a LIGHT switch.


/obj/machinery/light_switch/power_change(forced = FALSE)
	if(!..() || !otherarea)
		return

	light_switch_light()
	update_icon()


/obj/machinery/light_switch/emp_act(severity)
	if(stat & (BROKEN|NOPOWER))
		..(severity)
		return
	power_change()
	..(severity)

/obj/machinery/light_switch/process()
	if(logic_connect && powered(LIGHT))		//We won't send signals while unpowered, but the last signal will remain valid for anything that received it before we went dark
		handle_output()

/obj/machinery/light_switch/attackby(obj/item/W, mob/user, params)
	if(istype(W, /obj/item/detective_scanner))
		return
	return ..()

/obj/machinery/light_switch/wrench_act(mob/user, obj/item/I)
	. = TRUE
	if(!I.tool_use_check(user, 0))
		return
	user.visible_message(span_notice("[user] starts unwrenching [src] from the wall..."), span_notice("You are unwrenching [src] from the wall..."), span_warning("You hear ratcheting."))
	if(!I.use_tool(src, user, 30, volume = I.tool_volume))
		return
	WRENCH_UNANCHOR_WALL_MESSAGE
	new/obj/item/mounted/frame/light_switch(get_turf(src))
	qdel(src)
