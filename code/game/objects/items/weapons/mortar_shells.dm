/obj/item/mortar_shell
	name = "\improper 80mm mortar shell"
	desc = "An unlabeled 80mm mortar shell, probably a casing."
	icon = 'icons/obj/structures/mortar.dmi'
	icon_state = "mortar_ammo_cas"
	lefthand_file = 'icons/mob/inhands/ammo_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/ammo_righthand.dmi'
	w_class = WEIGHT_CLASS_HUGE
	flags = CONDUCT
	ground_offset_x = 7
	ground_offset_y = 6
	/// is it currently on fire and about to explode?
	var/burning = FALSE
	var/falling_time = 0.3 SECONDS


/obj/item/mortar_shell/proc/detonate(turf/T)
	var/old_loc = loc
	forceMove(T)
	var/angle = 90 - get_angle(loc, old_loc)
	pixel_x = cos(angle) * 32 * 6
	pixel_z = sin(angle) * 32 * 6
	var/rotation = get_pixel_angle(pixel_z, pixel_x) //CUSTOM HOMEBREWED proc that is just arctan with extra steps
	transform = matrix().Turn(rotation + 180)
	layer = FLY_LAYER
	SET_PLANE_EXPLICIT(src, ABOVE_GAME_PLANE, src)
	animate(src, pixel_z = -1 * abs(sin(rotation))*4, pixel_x = SUPPLYPOD_X_OFFSET + (sin(rotation) * 20), time = falling_time, easing = LINEAR_EASING) //Make the pod fall! At an angle!
	sleep(falling_time)
	SEND_SIGNAL(src, COMSIG_MORTAR_DETONATE, src)

/obj/item/mortar_shell/proc/deploy_camera(turf/T)
	var/obj/machinery/camera/mortar/old_cam = locate() in T
	if(old_cam)
		qdel(old_cam)
	new /obj/machinery/camera/mortar(T)

/obj/item/mortar_shell/he
	name = "\improper 80mm high explosive mortar shell"
	desc = "An 80mm mortar shell, loaded with a high explosive charge."
	icon_state = "mortar_ammo_he"
	item_state = "mortar_ammo_he"

/obj/item/mortar_shell/he/detonate(turf/T)
	. = ..()
	explosion(T, 0, 4, 7, 7)

/obj/item/mortar_shell/frag
	name = "\improper 80mm fragmentation mortar shell"
	desc = "An 80mm mortar shell, loaded with a fragmentation charge."
	icon_state = "mortar_ammo_frag"
	item_state = "mortar_ammo_frag"

/obj/item/mortar_shell/frag/detonate(turf/T)
	AddComponent(/datum/component/pellet_cloud, magnitude = 4)
	. = ..()
	sleep(2)
	explosion(T, 0, 0, 5)
/*
/obj/item/mortar_shell/incendiary
	name = "\improper 80mm incendiary mortar shell"
	desc = "An 80mm mortar shell, loaded with a Type B napalm charge. Perfect for long-range area denial."
	icon_state = "mortar_ammo_inc"
	item_state = "mortar_ammo_inc"
	var/radius = 5
	var/flame_level = BURN_TIME_TIER_5 + 5 //Type B standard, 50 base + 5 from chemfire code.
	var/burn_level = BURN_LEVEL_TIER_2
	var/flameshape = FLAMESHAPE_DEFAULT
	var/fire_type = FIRE_VARIANT_TYPE_B //Armor Shredding Greenfire

/obj/item/mortar_shell/incendiary/detonate(turf/T)
	flame_radius(cause_data, radius, T, flame_level, burn_level, flameshape, null, fire_type)
	playsound(T, 'sound/weapons/gun_flamethrower2.ogg', 35, 1, 4)
*/
/obj/item/mortar_shell/flare
	name = "\improper 80mm flare/camera mortar shell"
	desc = "An 80mm mortar shell, loaded with an illumination flare / camera combo, attached to a parachute."
	icon_state = "mortar_ammo_flr"
	item_state = "mortar_ammo_flr"

/obj/item/mortar_shell/flare/detonate(turf/T)
	. = ..()
	new /obj/item/flashlight/flare/on/illumination(T)
	playsound(T, 'sound/weapons/gun_flare.ogg', 50, 1, 4)
	deploy_camera(T)
/*
/obj/item/mortar_shell/custom
	name = "\improper 80mm custom mortar shell"
	desc = "An 80mm mortar shell."
	icon_state = "mortar_ammo_custom"
	item_state = "mortar_ammo_custom_locked"
	
	materials = list(METAL = 18750) //5 sheets
	var/obj/item/reagent_containers/glass/beaker/warhead
	var/obj/item/reagent_containers/glass/beaker/fuel
	var/fuel_requirement = 60
	var/fuel_type = "hydrogen"
	var/locked = FALSE
	var/has_camera = FALSE

/obj/item/mortar_shell/custom/examine(mob/user)
	. = ..()
	if(fuel)
		. += span_notice("Contains fuel.")
	if(warhead)
		. += span_notice("Contains a warhead[warhead.has_camera ? " with integrated camera drone." : ""].")

/obj/item/mortar_shell/custom/detonate(turf/T)
	if(fuel)
		var/fuel_amount = fuel.reagents.get_reagent_amount(fuel_type)
		if(fuel_amount >= fuel_requirement)
			forceMove(T)
			if(has_camera)
				deploy_camera(T)
	if(warhead && locked && warhead.detonator)
		warhead.cause_data = cause_data
		warhead.prime()

/obj/item/mortar_shell/custom/attack_self(mob/user)
	..()

	if(locked)
		return

	if(warhead)
		user.put_in_hands(warhead)
		warhead = null
	else if(fuel)
		user.put_in_hands(fuel)
		fuel = null
	icon_state = initial(icon_state)

/obj/item/mortar_shell/custom/attackby(obj/item/W as obj, mob/user)
	if(W.tool_behaviour == TOOL_SCREWDRIVER)
		if(!warhead)
			to_chat(user, span_notice("[name] must contain a warhead to do that!"))
			return
		if(locked)
			to_chat(user, span_notice("You unlock [name]."))
			icon_state = initial(icon_state) +"_unlocked"
		else
			to_chat(user, span_notice("You lock [name]."))
			if(fuel && fuel.reagents.get_reagent_amount(fuel_type) >= fuel_requirement)
				icon_state = initial(icon_state) +"_locked"
			else
				icon_state = initial(icon_state) +"_no_fuel"
		locked = !locked
		playsound(loc, 'sound/items/Screwdriver.ogg', 25, 0, 6)
		return
	else if(istype(W,/obj/item/reagent_container/glass) && !locked)
		if(fuel)
			to_chat(user, span_danger("The [name] already has a fuel container!"))
			return
		else
			user.temp_drop_inv_item(W)
			W.forceMove(src)
			fuel = W
			to_chat(user, span_danger("You add [W] to [name]."))
			playsound(loc, 'sound/items/Screwdriver2.ogg', 25, 0, 6)
	else if(istype(W,/obj/item/explosive/warhead/mortar) && !locked)
		if(warhead)
			to_chat(user, span_danger("The [name] already has a warhead!"))
			return
		var/obj/item/explosive/warhead/mortar/det = W
		if(det.assembly_stage < ASSEMBLY_LOCKED)
			to_chat(user, span_danger("The [W] is not secured!"))
			return
		user.temp_drop_inv_item(W)
		W.forceMove(src)
		warhead = W
		to_chat(user, span_danger("You add [W] to [name]."))
		icon_state = initial(icon_state) +"_unlocked"
		playsound(loc, 'sound/items/Screwdriver2.ogg', 25, 0, 6)
*/
/obj/item/mortar_shell/ex_act(severity, explosion_direction)
	if(!burning)
		return ..()

/obj/item/mortar_shell/attack_hand(mob/user)
	if(burning)
		to_chat(user, span_danger("[src] is on fire and might explode!"))
		return
	return ..()
/*
/obj/item/mortar_shell/flamer_fire_act(dam, datum/cause_data/flame_cause_data)
	addtimer(VARSET_CALLBACK(src, burning, FALSE), 5 SECONDS, TIMER_UNIQUE|TIMER_OVERRIDE|TIMER_DELETE_ME)

	if(burning)
		return
	burning = TRUE
	cause_data = create_cause_data("Burning Mortar Shell", flame_cause_data.resolve_mob(), src)
	handle_fire(cause_data)*/

/obj/item/mortar_shell/proc/can_explode()
	return TRUE
/*
/obj/item/mortar_shell/custom/can_explode()
	return FALSE */

/obj/item/mortar_shell/flare/can_explode()
	return FALSE

/obj/item/mortar_shell/proc/handle_fire(cause_data)
	if(can_explode())
		visible_message(span_warning("[src] catches on fire and starts cooking off! It's gonna blow!"))
		anchored = TRUE // don't want other explosions launching it elsewhere
		var/datum/effect_system/spark_spread/sparks = new()
		sparks.set_up(number = 10, location = loc)
		sparks.start()
		new /obj/effect/warning/explosive(loc, 5 SECONDS)

		addtimer(CALLBACK(src, PROC_REF(explode), cause_data), 5 SECONDS)
		addtimer(CALLBACK(GLOBAL_PROC, GLOBAL_PROC_REF(qdel), (src)), 5.5 SECONDS)


/obj/item/mortar_shell/proc/explode(flame_cause_data)
	explosion(get_turf(src), 0, 3, 5)


/obj/effect/warning
	name = "warning"
	icon = 'icons/effects/alert.dmi'
	icon_state = "alert_greyscale"
	anchored = TRUE

	mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	layer = ABOVE_OBJ_LAYER

/obj/effect/warning/Initialize(mapload, time)
	. = ..()
	addtimer(CALLBACK(GLOBAL_PROC, GLOBAL_PROC_REF(qdel), src), time)

/obj/effect/warning/explosive
	name = "explosive warning"
	color = "#ff0000"


/obj/structure/closet/crate/secure/weapon/mortar
	name = "mortar kit crate"

/obj/structure/closet/crate/secure/weapon/mortar/populate_contents()
	new /obj/item/mortar_kit(src)
	new /obj/item/mortar_shell/he(src)
	new /obj/item/mortar_shell/he(src)
	new /obj/item/mortar_shell/flare(src)
	new /obj/item/mortar_shell/frag(src)
	new /obj/item/mortar_shell/frag(src)

/obj/structure/closet/crate/secure/weapon/mortar_shells
	name = "mortar kit crate"
	var/count = 5
	var/shell_type = /obj/item/mortar_shell

/obj/structure/closet/crate/secure/weapon/mortar_shells/populate_contents()
	for (var/i = 1; i <= count; i++)
		new shell_type(src)

/obj/structure/closet/crate/secure/weapon/mortar_shells/he
	name = "mortar shells HE crate"
	shell_type = /obj/item/mortar_shell/he

/obj/structure/closet/crate/secure/weapon/mortar_shells/frag
	name = "mortar shells frag crate"
	shell_type = /obj/item/mortar_shell/frag

/obj/structure/closet/crate/secure/weapon/mortar_shells/flare
	name = "mortar shells flare crate"
	count = 3
	shell_type = /obj/item/mortar_shell/flare
