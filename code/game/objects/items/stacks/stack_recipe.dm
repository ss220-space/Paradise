
/*
 * Recipe datum
 */
/datum/stack_recipe
	var/title = "ERROR"
	var/result_type
	var/req_amount = 1
	var/res_amount = 1
	var/max_res_amount = 1
	var/time = 0
	var/one_per_turf = 0
	var/on_floor = 0    //must have floor under it?
	var/on_lattice = 0  //ONLY if has on_floor = 1 checks could be built in space on lattice. Otherwise won't work.
	/// If the atom is fulltile, as in a fulltile window. This is used for the direction check to prevent fulltile windows from being able to be built over directional stuff.
	/// Setting this to true will effectively set check_direction to true.
	var/is_fulltile = FALSE
	/// If this atom should run the direction check, for use when building things like directional windows where you can have more than one per turf
	var/check_direction = FALSE
	var/cult_structure = FALSE

/datum/stack_recipe/New(title, result_type, req_amount = 1, res_amount = 1, max_res_amount = 1, time = 0, one_per_turf = 0, on_floor = 0, is_fulltile = FALSE, check_direction = FALSE, cult_structure = FALSE, on_lattice = FALSE)
	src.title = title
	src.result_type = result_type
	src.req_amount = req_amount
	src.res_amount = res_amount
	src.max_res_amount = max_res_amount
	src.time = time
	src.one_per_turf = one_per_turf
	src.on_floor = on_floor
	src.is_fulltile = is_fulltile
	src.check_direction = check_direction || is_fulltile
	src.cult_structure = cult_structure
	src.on_lattice = on_lattice

/datum/stack_recipe/proc/post_build(obj/item/stack/S, obj/result)
	return

/* Special Recipes */

/datum/stack_recipe/cable_restraints
/datum/stack_recipe/cable_restraints/post_build(obj/item/stack/S, obj/result)
	var/obj/item/restraints/handcuffs/cable/cable_restraints = result
	if(istype(cable_restraints))
		cable_restraints.cable_color(S.color)
	..()


/datum/stack_recipe/dangerous
/datum/stack_recipe/dangerous/post_build(obj/item/stack/S, obj/result)
	var/turf/targ = get_turf(usr)
	message_admins("[title] made by [key_name_admin(usr)] in [ADMIN_VERBOSEJMP(usr)]!",0,1)
	add_game_logs("made [title] at [AREACOORD(targ)].", usr)
	..()

/datum/stack_recipe/rods
/datum/stack_recipe/rods/post_build(obj/item/stack/S, obj/result)
	if(istype(result, /obj/item/stack/rods))
		var/obj/item/stack/rods/R = result
		R.update_icon()
	..()

/datum/stack_recipe/window
/datum/stack_recipe/window/post_build(obj/item/stack/S, obj/result)
	if(istype(result, /obj/structure/windoor_assembly))
		var/obj/structure/windoor_assembly/W = result
		W.ini_dir = W.dir
	else if(istype(result, /obj/structure/window))
		var/obj/structure/window/W = result
		W.ini_dir = W.dir
		W.anchored = FALSE
		W.state = WINDOW_OUT_OF_FRAME

/*
 * Recipe list datum
 */
/datum/stack_recipe_list
	var/title = "ERROR"
	var/list/recipes = null

/datum/stack_recipe_list/New(title, recipes)
	src.title = title
	src.recipes = recipes

