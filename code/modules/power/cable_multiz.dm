
///multilayer cable to connect different layers
/obj/structure/cable/multilayer
	name = "multilayer cable hub"
	desc = "A flexible, superconducting insulated multilayer hub for heavy-duty multilayer power transfer."
	icon = 'icons/obj/engines_and_power/power.dmi'
	icon_state = "cable_bridge"
	cable_layer = CABLE_LAYER_2
	layer = WIRE_LAYER - 0.02 //Below all cables Disabled layers can lay over hub
	color = CABLE_HEX_COLOR_WHITE


/obj/structure/cable/multilayer/cable_color(colorC)
	color = CABLE_HEX_COLOR_WHITE
	return

/obj/structure/cable/multilayer/update_icon_state()
	SHOULD_CALL_PARENT(FALSE)
	return

/obj/structure/cable/multilayer/update_icon()
	. = ..()
	underlays.Cut()
	var/mutable_appearance/cable_node_3 = mutable_appearance('icons/obj/engines_and_power/power_cond/power_cond_white.dmi', "node_all3")
	cable_node_3.color = CABLE_COLOR_BLUE
	cable_node_3?.alpha = cable_layer & CABLE_LAYER_3 ? 255 : 0
	underlays += cable_node_3
	var/mutable_appearance/cable_node_2 = mutable_appearance('icons/obj/engines_and_power/power_cond/power_cond_white.dmi', "node_all1")
	cable_node_2.color = CABLE_COLOR_YELLOW
	cable_node_2?.alpha = cable_layer & CABLE_LAYER_2 ? 255 : 0
	underlays += cable_node_2
	var/mutable_appearance/cable_node_1 = mutable_appearance('icons/obj/engines_and_power/power_cond/power_cond_white.dmi', "node_all")
	cable_node_1.color = CABLE_COLOR_RED
	cable_node_1?.alpha = cable_layer & CABLE_LAYER_1 ? 255 : 0
	underlays += cable_node_1
	var/mutable_appearance/machinery_node = mutable_appearance('icons/obj/engines_and_power/power_cond/power_cond_white.dmi', "connect_node")
	machinery_node.color = "black"
	underlays += machinery_node

/obj/structure/cable/multilayer/Initialize(mapload)
	. = ..()
	var/turf/T = get_turf(src)
	for(var/obj/structure/cable/C in T.contents - src)
		if(C.cable_layer & cable_layer)
			C.deconstruct() // remove adversary cable
	if(!mapload)
		auto_propagate_cut_cable(src)

	update_appearance()

/obj/structure/cable/multilayer/examine(mob/user)
	. += ..()
	. += span_notice("L1:[cable_layer & CABLE_LAYER_1 ? "Connect" : "Disconnect"].")
	. += span_notice("L2:[cable_layer & CABLE_LAYER_2 ? "Connect" : "Disconnect"].")
	. += span_notice("L3:[cable_layer & CABLE_LAYER_3 ? "Connect" : "Disconnect"].")

GLOBAL_LIST(hub_radial_layer_list)

/obj/structure/cable/multilayer/attack_robot(mob/user)
	attack_hand(user)

/obj/structure/cable/multilayer/attack_hand(mob/living/user, list/modifiers)
	if(!user)
		return
	if(!GLOB.hub_radial_layer_list)
		GLOB.hub_radial_layer_list = list(
			"Layer 1" = image(icon = 'icons/hud/radial.dmi', icon_state = "coil-red"),
			"Layer 2" = image(icon = 'icons/hud/radial.dmi', icon_state = "coil-yellow"),
			"Layer 3" = image(icon = 'icons/hud/radial.dmi', icon_state = "coil-blue")
			)

	var/layer_result = show_radial_menu(user, src, GLOB.hub_radial_layer_list, custom_check = CALLBACK(src, PROC_REF(check_menu), user), require_near = TRUE, tooltips = TRUE)
	if(!check_menu(user))
		return
	var/CL
	switch(layer_result)
		if("Layer 1")
			CL = CABLE_LAYER_1
			to_chat(user, span_warning("You toggle L1 connection."))
		if("Layer 2")
			CL = CABLE_LAYER_2
			to_chat(user, span_warning("You toggle L2 connection."))
		if("Layer 3")
			CL = CABLE_LAYER_3
			to_chat(user, span_warning("You toggle L3 connection."))

	cut_cable_from_powernet(FALSE)

	disconnect_cable()

	cable_layer ^= CL

	connect_cable(TRUE)

	Reload()

/obj/structure/cable/multilayer/proc/check_menu(mob/living/user)
	if(!istype(user))
		return FALSE
	if(!user.IsAdvancedToolUser())
		to_chat(user, span_warning("You don't have the dexterity to do this!"))
		return FALSE
	if(user.incapacitated() || !user.Adjacent(src))
		return FALSE
	return TRUE

///Reset powernet in this hub.
/obj/structure/cable/multilayer/proc/Reload()
	var/turf/T = get_turf(src)
	for(var/obj/structure/cable/C in T.contents - src)
		if(C.cable_layer & cable_layer)
			C.deconstruct() // remove adversary cable
	auto_propagate_cut_cable(src) // update the powernets

/obj/structure/cable/multilayer/CtrlClick(mob/user)
	to_chat(user, span_warning("You push the reset button."))
	addtimer(CALLBACK(src, PROC_REF(Reload)), 10, TIMER_UNIQUE) //spam protect
	return CLICK_ACTION_SUCCESS

// This is a mapping aid. In order for this to be placed on a map and function, all three layers need to have their nodes active
/obj/structure/cable/multilayer/connected
		cable_layer = CABLE_LAYER_1 | CABLE_LAYER_2 | CABLE_LAYER_3

/obj/structure/cable/multilayer/layer1
		cable_layer = CABLE_LAYER_1

/obj/structure/cable/multilayer/layer3
		cable_layer =  CABLE_LAYER_3

/obj/structure/cable/multilayer/multiz //This bridges powernets betwen Z levels
	name = "multi z layer cable hub"
	desc = "A flexible, superconducting insulated multi Z layer hub for heavy-duty multi Z power transfer."
	icon = 'icons/obj/engines_and_power/power.dmi'
	icon_state = "cable_bridge"
	color = CABLE_HEX_COLOR_ORANGE
	cable_layer = CABLE_LAYER_1|CABLE_LAYER_2|CABLE_LAYER_3

/obj/structure/cable/multilayer/multiz/get_cable_connections(powernetless_only)
	. = ..()
	var/turf/T = get_turf(src)
	. += locate(/obj/structure/cable/multilayer/multiz) in (GET_TURF_BELOW(T))
	. += locate(/obj/structure/cable/multilayer/multiz) in (GET_TURF_ABOVE(T))

/obj/structure/cable/multilayer/multiz/examine(mob/user)
	. = ..()
	var/turf/T = get_turf(src)
	. += span_notice("[locate(/obj/structure/cable/multilayer/multiz) in (GET_TURF_BELOW(T)) ? "Detected" : "Undetected"] hub UP.")
	. += span_notice("[locate(/obj/structure/cable/multilayer/multiz) in (GET_TURF_ABOVE(T)) ? "Detected" : "Undetected"] hub DOWN.")
