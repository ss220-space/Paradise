#define LIGHTFLOOR_BROKEN 0
#define LIGHTFLOOR_ON 1
#define LIGHTFLOOR_WHITE 2
#define LIGHTFLOOR_RED 3
#define LIGHTFLOOR_GREEN 4
#define LIGHTFLOOR_YELLOW 5
#define LIGHTFLOOR_BLUE 6
#define LIGHTFLOOR_PURPLE 7

#define LIGHTFLOOR_GENERICCYCLE 8
#define LIGHTFLOOR_CYCLEA 9
#define LIGHTFLOOR_CYCLEB 10

#define LIGHTFLOOR_NAME 1
#define LIGHTFLOOR_ICON_STATE 2
#define LIGHTFLOOR_LIGHT_COLOR 3

GLOBAL_ALIST_INIT(lightfloor_configs, alist(
	LIGHTFLOOR_ON = list("Cyan", "light_on", LIGHT_COLOR_BLUE),
	LIGHTFLOOR_WHITE = list("White", "light_on-w", COLOR_WHITE),
	LIGHTFLOOR_RED = list("Red", "light_on-r", COLOR_SOFT_RED),
	LIGHTFLOOR_GREEN = list("Green", "light_on-g", LIGHT_COLOR_ELECTRIC_GREEN),
	LIGHTFLOOR_YELLOW = list("Yellow", "light_on-y", LIGHT_COLOR_DIM_YELLOW),
	LIGHTFLOOR_BLUE = list("Blue", "light_on-b", LIGHT_COLOR_DARK_BLUE),
	LIGHTFLOOR_PURPLE = list("Purple", "light_on-p", LIGHT_COLOR_PURPLE),
	LIGHTFLOOR_GENERICCYCLE = list("Rainbow", "light_on-cycle_all", COLOR_WHITE),
	LIGHTFLOOR_CYCLEA = list("Dancefloor A", "light_on-dancefloor_A", COLOR_RED),
	LIGHTFLOOR_CYCLEB = list("Dancefloor B", "light_on-dancefloor_B", LIGHT_COLOR_DARK_BLUE),
))

/turf/simulated/floor/light
	name = "light floor"
	light_range = 5
	icon_state = "light_on"
	floor_tile = /obj/item/stack/tile/light
	var/on = TRUE
	var/state = LIGHTFLOOR_ON
	var/can_modify_colour = TRUE
	var/static/list/choices
	var/static/alist/name_to_state

/turf/simulated/floor/light/Initialize(mapload)
	. = ..()
	if(!LAZYLEN(choices))
		choices = list()
		name_to_state = alist()
		for(var/state_key in GLOB.lightfloor_configs)
			var/list/config = GLOB.lightfloor_configs[state_key]
			var/mode_name = config[LIGHTFLOOR_NAME]
			choices[mode_name] = image(icon = icon, icon_state = config[LIGHTFLOOR_ICON_STATE])
			name_to_state[mode_name] = state_key
	update_icon()

/turf/simulated/floor/light/broken_states()
	return list("light_broken")//

/turf/simulated/floor/light/update_icon_state()
	if(!on)
		set_light_on(FALSE)
		icon_state = "light_off"
		return

	var/list/config = GLOB.lightfloor_configs[state]
	if(config)
		icon_state = config[LIGHTFLOOR_ICON_STATE]
		set_light(light_range, null, config[LIGHTFLOOR_LIGHT_COLOR], l_on = TRUE)
	else
		icon_state = "light_off"
		set_light_on(FALSE)

/turf/simulated/floor/light/BeforeChange()
	set_light_on(FALSE)
	return ..()

/turf/simulated/floor/light/attack_hand(mob/user)
	if(!can_modify_colour)
		return
	toggle_light(!on)

/turf/simulated/floor/light/attackby(obj/item/I, mob/user, params)
	. = ..()

	if(ATTACK_CHAIN_CANCEL_CHECK(.))
		return .

	if(istype(I, /obj/item/light/bulb))
		if(state != LIGHTFLOOR_BROKEN)
			to_chat(user, span_notice("The light bulb seems fine, no need to replace it."))
			return .
		if(!user.drop_transfer_item_to_loc(I, src))
			return .
		qdel(I)
		state = LIGHTFLOOR_ON
		update_icon()
		to_chat(user, span_notice("You replace the light bulb."))
		return . | ATTACK_CHAIN_BLOCKED_ALL

/turf/simulated/floor/light/multitool_act(mob/user, obj/item/I)
	. = TRUE
	if(!can_modify_colour)
		return
	if(state == LIGHTFLOOR_BROKEN)
		to_chat(user, span_warning("[src]'s light bulb appears to have burned out."))
		return

	var/choice = show_radial_menu(user, src, choices, radius = 50, require_near = TRUE, tooltips = TRUE)
	if(!choice || !can_modify_colour || state == LIGHTFLOOR_BROKEN)
		return

	var/new_state = name_to_state[choice]
	if(!new_state || new_state == state)
		return

	if(!I.use_tool(src, user, 0, volume = I.tool_volume))
		return

	state = new_state
	to_chat(user, span_notice("You change [src]'s light bulb color to [lowertext(choice)]."))
	update_icon()

/turf/simulated/floor/light/proc/toggle_light(light)
	on = light
	update_icon()

/turf/simulated/floor/light/extinguish_light(force = FALSE)
	if(on)
		toggle_light(FALSE)
		visible_message(span_danger("[src] flickers and falls dark."))

/turf/simulated/floor/light/colour_cycle
	state = LIGHTFLOOR_GENERICCYCLE
	can_modify_colour = FALSE

/turf/simulated/floor/light/colour_cycle/dancefloor_a
	name = "dancefloor"
	desc = "Funky floor."
	state = LIGHTFLOOR_CYCLEA

/turf/simulated/floor/light/colour_cycle/dancefloor_b
	name = "dancefloor"
	desc = "Funky floor."
	state = LIGHTFLOOR_CYCLEB

/turf/simulated/floor/light/lavaland_air
	atmos_mode = ATMOS_MODE_EXPOSED_TO_ENVIRONMENT
	atmos_environment = ENVIRONMENT_LAVALAND

/turf/simulated/floor/light/airless
	oxygen = 0
	nitrogen = 0
	temperature = TCMB

#undef LIGHTFLOOR_BROKEN
#undef LIGHTFLOOR_ON
#undef LIGHTFLOOR_WHITE
#undef LIGHTFLOOR_RED
#undef LIGHTFLOOR_GREEN
#undef LIGHTFLOOR_YELLOW
#undef LIGHTFLOOR_BLUE
#undef LIGHTFLOOR_PURPLE

#undef LIGHTFLOOR_GENERICCYCLE
#undef LIGHTFLOOR_CYCLEA
#undef LIGHTFLOOR_CYCLEB

#undef LIGHTFLOOR_NAME
#undef LIGHTFLOOR_ICON_STATE
#undef LIGHTFLOOR_LIGHT_COLOR
