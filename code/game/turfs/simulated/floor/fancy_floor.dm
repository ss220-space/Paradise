/turf/simulated/floor/wood
	icon_state = "wood"
	floor_tile = /obj/item/stack/tile/wood
	prying_tool = TOOL_SCREWDRIVER
	footstep = FOOTSTEP_WOOD
	barefootstep = FOOTSTEP_WOOD_BAREFOOT
	clawfootstep = FOOTSTEP_WOOD_CLAW
	heavyfootstep = FOOTSTEP_GENERIC_HEAVY

/turf/simulated/floor/wood/broken_states()
	return list("wood-broken", "wood-broken2", "wood-broken3", "wood-broken4", "wood-broken5", "wood-broken6", "wood-broken7")

/turf/simulated/floor/wood/airless
	oxygen = 0
	nitrogen = 0
	temperature = TCMB

/turf/simulated/floor/wood/screwdriver_act(mob/user, obj/item/I)
	. = TRUE
	if(!I.use_tool(src, user, 0, volume = I.tool_volume))
		return
	remove_tile(user, FALSE, TRUE)

/turf/simulated/floor/wood/crowbar_act(mob/user, obj/item/I)
	. = TRUE
	if(!I.use_tool(src, user, 0, volume = I.tool_volume))
		return
	remove_tile(user, FALSE, FALSE)

/turf/simulated/floor/wood/remove_tile(mob/user, silent = FALSE, make_tile = TRUE)
	if(broken || burnt)
		broken = FALSE
		burnt = FALSE
		make_tile = FALSE
		if(user && !silent)
			to_chat(user, span_notice("You remove the broken planks."))
	else
		if(make_tile)
			if(user && !silent)
				to_chat(user, span_notice("You unscrew the planks."))
		else
			if(user && !silent)
				to_chat(user, span_warning("You forcefully pry off the planks, destroying them in the process."))
	return make_plating(make_tile, user)

/turf/simulated/floor/wood/cold
	oxygen = 22
	nitrogen = 82
	temperature = 180

/turf/simulated/floor/wood/oak
	icon_state = "wood-oak"
	floor_tile = /obj/item/stack/tile/wood/oak

/turf/simulated/floor/wood/oak/broken_states()
	return list("wood-oak-broken", "wood-oak-broken2", "wood-oak-broken3", "wood-oak-broken4", "wood-oak-broken5", "wood-oak-broken6", "wood-oak-broken7")

/turf/simulated/floor/wood/birch
	icon_state = "wood-birch"
	floor_tile = /obj/item/stack/tile/wood/birch

/turf/simulated/floor/wood/birch/broken_states()
	return list("wood-birch-broken", "wood-birch-broken2", "wood-birch-broken3", "wood-birch-broken4", "wood-birch-broken5", "wood-birch-broken6", "wood-birch-broken7")

/turf/simulated/floor/wood/cherry
	icon_state = "wood-cherry"
	floor_tile = /obj/item/stack/tile/wood/cherry

/turf/simulated/floor/wood/cherry/broken_states()
	return list("wood-cherry-broken", "wood-cherry-broken2", "wood-cherry-broken3", "wood-cherry-broken4", "wood-cherry-broken5", "wood-cherry-broken6", "wood-cherry-broken7")

/turf/simulated/floor/wood/fancy/oak
	icon_state = "fancy-wood-oak"
	floor_tile = /obj/item/stack/tile/wood/fancy/oak

/turf/simulated/floor/wood/fancy/oak/broken_states()
	return list("fancy-wood-oak-broken", "fancy-wood-oak-broken2", "fancy-wood-oak-broken3", "fancy-wood-oak-broken4", "fancy-wood-oak-broken5", "fancy-wood-oak-broken6", "fancy-wood-oak-broken7")

/turf/simulated/floor/wood/fancy/birch
	icon_state = "fancy-wood-birch"
	floor_tile = /obj/item/stack/tile/wood/fancy/birch

/turf/simulated/floor/wood/fancy/birch/broken_states()
	return list("fancy-wood-birch-broken", "fancy-wood-birch-broken2", "fancy-wood-birch-broken3", "fancy-wood-birch-broken4", "fancy-wood-birch-broken5", "fancy-wood-birch-broken6", "fancy-wood-birch-broken7")

/turf/simulated/floor/wood/fancy/cherry
	icon_state = "fancy-wood-cherry"
	floor_tile = /obj/item/stack/tile/wood/fancy/cherry

/turf/simulated/floor/wood/fancy/cherry/broken_states()
	return list("fancy-wood-cherry-broken", "fancy-wood-cherry-broken2", "fancy-wood-cherry-broken3", "fancy-wood-cherry-broken4", "fancy-wood-cherry-broken5", "fancy-wood-cherry-broken6", "fancy-wood-cherry-broken7")

/turf/simulated/floor/wood/fancy/light
	icon_state = "light-fancy-wood"
	floor_tile = /obj/item/stack/tile/wood/fancy/light

/turf/simulated/floor/wood/fancy/light/broken_states()
	return list("light-fancy-wood-broken", "light-fancy-wood-broken2", "light-fancy-wood-broken3", "light-fancy-wood-broken4", "light-fancy-wood-broken5", "light-fancy-wood-broken6", "light-fancy-wood-broken7")

// GRASS
/turf/simulated/floor/grass
	name = "grass patch"
	icon_state = "grass1"
	floor_tile = /obj/item/stack/tile/grass
	footstep = FOOTSTEP_GRASS
	barefootstep = FOOTSTEP_GRASS
	clawfootstep = FOOTSTEP_GRASS
	heavyfootstep = FOOTSTEP_GENERIC_HEAVY

/turf/simulated/floor/grass/broken_states()
	return list("sand")

/turf/simulated/floor/grass/Initialize(mapload)
	. = ..()
	update_icon()

/turf/simulated/floor/grass/update_icon_state()
	icon_state = "grass[pick("1","2","3","4")]"


/turf/simulated/floor/grass/attackby(obj/item/I, mob/user, params)
	. = ..()

	if(ATTACK_CHAIN_CANCEL_CHECK(.))
		return .

	if(istype(I, /obj/item/shovel))
		add_fingerprint(user)
		if((locate(/obj/structure/pit) in src))
			to_chat(user, span_notice("Looks like someone dug here a pit!"))
			return .

		if(user.a_intent == INTENT_DISARM)
			I.play_tool_sound(src)
			to_chat(user, span_notice("You start digging..."))
			if(!do_after(user, 4 SECONDS * I.toolspeed, src, category = DA_CAT_TOOL))
				return .
			I.play_tool_sound(src)
			to_chat(user, span_notice("You have dug a pit."))
			new /obj/structure/pit(src)
			return .|ATTACK_CHAIN_SUCCESS

		I.play_tool_sound(src)
		to_chat(user, span_notice("You shovel the grass."))
		make_plating(FALSE)
		new /obj/item/stack/ore/glass(src, 2) //Make some sand if you shovel grass
		return .|ATTACK_CHAIN_BLOCKED_ALL


// CARPETS
/turf/simulated/floor/carpet
	name = "carpet"
	icon = 'icons/turf/floors/carpet.dmi'
	icon_state = "carpet-0"
	smooth = SMOOTH_BITMASK
	base_icon_state = "carpet"
	canSmoothWith = SMOOTH_GROUP_CARPET
	smoothing_groups = SMOOTH_GROUP_CARPET
	floor_tile = /obj/item/stack/tile/carpet
	footstep = FOOTSTEP_CARPET
	barefootstep = FOOTSTEP_CARPET_BAREFOOT
	clawfootstep = FOOTSTEP_CARPET_BAREFOOT
	heavyfootstep = FOOTSTEP_GENERIC_HEAVY

/turf/simulated/floor/carpet/airless
	oxygen = 0
	nitrogen = 0
	temperature = TCMB

/turf/simulated/floor/carpet/Initialize(mapload)
	. = ..()
	update_icon()


/turf/simulated/floor/carpet/broken_states()
	return list("damaged")


/turf/simulated/floor/carpet/update_icon_state()
	dir = NONE //Prevents wrong smoothing
	if(!broken && !burnt)
		if(smooth)
			queue_smooth(src)
	else
		make_plating(FALSE)
		if(smooth)
			queue_smooth_neighbors(src)

/turf/simulated/floor/carpet/break_tile()
	broken = TRUE
	update_icon()

/turf/simulated/floor/carpet/burn_tile()
	burnt = TRUE
	update_icon()

/turf/simulated/floor/carpet/get_smooth_underlay_icon(mutable_appearance/underlay_appearance, turf/asking_turf, adjacency_dir)
	return FALSE

/turf/simulated/floor/carpet/black
	icon = 'icons/turf/floors/carpet_black.dmi'
	floor_tile = /obj/item/stack/tile/carpet/black
	base_icon_state = "carpet_black"
	icon_state = "carpet_black-0"
	canSmoothWith = SMOOTH_GROUP_CARPET_BLACK
	smoothing_groups = SMOOTH_GROUP_CARPET_BLACK

/turf/simulated/floor/carpet/blue
	icon = 'icons/turf/floors/carpet_blue.dmi'
	floor_tile = /obj/item/stack/tile/carpet/blue
	base_icon_state = "carpet_blue"
	icon_state = "carpet_blue-0"
	canSmoothWith = SMOOTH_GROUP_CARPET_BLUE
	smoothing_groups = SMOOTH_GROUP_CARPET_BLUE

/turf/simulated/floor/carpet/cyan
	icon = 'icons/turf/floors/carpet_cyan.dmi'
	floor_tile = /obj/item/stack/tile/carpet/cyan
	base_icon_state = "carpet_cyan"
	icon_state = "carpet_cyan-0"
	canSmoothWith = SMOOTH_GROUP_CARPET_CYAN
	smoothing_groups = SMOOTH_GROUP_CARPET_CYAN

/turf/simulated/floor/carpet/green
	icon = 'icons/turf/floors/carpet_green.dmi'
	floor_tile = /obj/item/stack/tile/carpet/green
	base_icon_state = "carpet_green"
	icon_state = "carpet_green-0"
	canSmoothWith = SMOOTH_GROUP_CARPET_GREEN
	smoothing_groups = SMOOTH_GROUP_CARPET_GREEN

/turf/simulated/floor/carpet/orange
	icon = 'icons/turf/floors/carpet_orange.dmi'
	floor_tile = /obj/item/stack/tile/carpet/orange
	base_icon_state = "carpet_orange"
	icon_state = "carpet_orange-0"
	canSmoothWith = SMOOTH_GROUP_CARPET_ORANGE
	smoothing_groups = SMOOTH_GROUP_CARPET_ORANGE

/turf/simulated/floor/carpet/purple
	icon = 'icons/turf/floors/carpet_purple.dmi'
	floor_tile = /obj/item/stack/tile/carpet/purple
	base_icon_state = "carpet_purple"
	icon_state = "carpet_purple-0"
	canSmoothWith = SMOOTH_GROUP_CARPET_PURPLE
	smoothing_groups = SMOOTH_GROUP_CARPET_PURPLE

/turf/simulated/floor/carpet/red
	icon = 'icons/turf/floors/carpet_red.dmi'
	floor_tile = /obj/item/stack/tile/carpet/red
	base_icon_state = "carpet_red"
	icon_state = "carpet_red-0"
	canSmoothWith = SMOOTH_GROUP_CARPET_RED
	smoothing_groups = SMOOTH_GROUP_CARPET_RED

/turf/simulated/floor/carpet/royalblack
	icon = 'icons/turf/floors/carpet_royalblack.dmi'
	floor_tile = /obj/item/stack/tile/carpet/royalblack
	base_icon_state = "carpet_royalblack"
	icon_state = "carpet_royalblack-0"
	canSmoothWith = SMOOTH_GROUP_CARPET_ROYAL_BLACK
	smoothing_groups = SMOOTH_GROUP_CARPET_ROYAL_BLACK

/turf/simulated/floor/carpet/royalblue
	icon = 'icons/turf/floors/carpet_royalblue.dmi'
	floor_tile = /obj/item/stack/tile/carpet/royalblue
	base_icon_state = "carpet_royalblue"
	icon_state = "carpet_royalblue-0"
	canSmoothWith = SMOOTH_GROUP_CARPET_ROYAL_BLUE
	smoothing_groups = SMOOTH_GROUP_CARPET_ROYAL_BLUE

// FAKESPACE
/turf/simulated/floor/fakespace
	icon = 'icons/turf/space.dmi'
	icon_state = "0"
	floor_tile = /obj/item/stack/tile/fakespace
	plane = PLANE_SPACE

/turf/simulated/floor/fakespace/Initialize(mapload)
	. = ..()
	icon_state = SPACE_ICON_STATE

/turf/simulated/floor/fakespace/broken_states()
	return list("damaged")

/turf/simulated/floor/fakespace/get_smooth_underlay_icon(mutable_appearance/underlay_appearance, turf/asking_turf, adjacency_dir)
	underlay_appearance.icon = 'icons/turf/space.dmi'
	underlay_appearance.icon_state = SPACE_ICON_STATE
	SET_PLANE(underlay_appearance, PLANE_SPACE, src)
	return TRUE

/turf/simulated/floor/carpet/arcade
	icon = 'icons/goonstation/turf/floor.dmi'
	icon_state = "arcade"
	floor_tile = /obj/item/stack/tile/arcade_carpet
	smooth = NONE
