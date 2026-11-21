/turf/simulated/floor/light
	name = "light floor"
	light_range = 5
	icon_state = "light_on"
	floor_tile = /obj/item/stack/tile/light
	var/on = TRUE
	var/bulb_broken = FALSE
	var/state
	var/datum/lightfloor_mode/mode = /datum/lightfloor_mode/cyan
	var/can_modify_colour = TRUE
	var/static/list/choices

/turf/simulated/floor/light/Initialize(mapload)
	. = ..()
	if(!isnull(state))
		if(state == 0)
			bulb_broken = TRUE
		else
			for(var/mode_name in GLOB.lightfloor_modes)
				var/datum/lightfloor_mode/floor_mode = GLOB.lightfloor_modes[mode_name]
				if(floor_mode.legacy_state == state)
					mode = floor_mode
					break
	if(ispath(mode))
		mode = GLOB.lightfloor_modes[initial(mode.name)]
	if(!LAZYLEN(choices))
		choices = list()
		for(var/mode_name in GLOB.lightfloor_modes)
			var/datum/lightfloor_mode/floor_mode = GLOB.lightfloor_modes[mode_name]
			choices[mode_name] = image(icon = icon, icon_state = floor_mode.icon_state)
	update_icon()

/turf/simulated/floor/light/broken_states()
	return list("light_broken")

/turf/simulated/floor/light/update_icon_state()
	if(!on || bulb_broken || !mode)
		set_light_on(FALSE)
		icon_state = "light_off"
		return

	icon_state = mode.icon_state
	set_light(light_range, null, mode.light_color, l_on = TRUE)

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

	if(istype(I, /obj/item/light/bulb)) //only for light tiles
		if(!bulb_broken)
			to_chat(user, span_notice("Лампочка выглядит исправной, менять её не нужно."))
			return .
		if(!user.drop_transfer_item_to_loc(I, src))
			return .
		qdel(I)
		bulb_broken = FALSE
		var/datum/lightfloor_mode/default_mode = /datum/lightfloor_mode/cyan
		mode = GLOB.lightfloor_modes[initial(default_mode.name)]
		update_icon()
		to_chat(user, span_notice("Вы заменили лампочку."))
		return . | ATTACK_CHAIN_BLOCKED_ALL

/turf/simulated/floor/light/multitool_act(mob/user, obj/item/I)
	. = TRUE
	if(!can_modify_colour)
		return
	if(bulb_broken)
		to_chat(user, span_warning("Похоже, лампочка перегорела."))
		return

	var/choice = show_radial_menu(user, src, choices, radius = 48, require_near = TRUE, tooltips = TRUE)
	if(!choice || !can_modify_colour || bulb_broken)
		return

	var/datum/lightfloor_mode/new_mode = GLOB.lightfloor_modes[choice]
	if(!new_mode || new_mode == mode)
		return

	if(!I.use_tool(src, user, 0, volume = I.tool_volume))
		return

	mode = new_mode
	update_icon()

/turf/simulated/floor/light/proc/toggle_light(light)
	on = light
	update_icon()

/turf/simulated/floor/light/extinguish_light(force = FALSE)
	if(on)
		toggle_light(FALSE)
		visible_message(span_danger("[src] flickers and falls dark."))

//Cycles through all of the colours
/turf/simulated/floor/light/colour_cycle
	mode = /datum/lightfloor_mode/rainbow
	can_modify_colour = FALSE

//Two different "dancefloor" types so that you can have a checkered pattern
// (also has a longer delay than colour_cycle between cycling colours)
/turf/simulated/floor/light/colour_cycle/dancefloor_a
	name = "dancefloor"
	desc = "Funky floor."
	mode = /datum/lightfloor_mode/dancefloor_a

/turf/simulated/floor/light/colour_cycle/dancefloor_b
	name = "dancefloor"
	desc = "Funky floor."
	mode = /datum/lightfloor_mode/dancefloor_b

/turf/simulated/floor/light/lavaland_air
	atmos_mode = ATMOS_MODE_EXPOSED_TO_ENVIRONMENT
	atmos_environment = ENVIRONMENT_LAVALAND

/turf/simulated/floor/light/airless
	oxygen = 0
	nitrogen = 0
	temperature = TCMB
