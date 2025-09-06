/obj/item/mortar_shell
	name = "80mm mortar shell"
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
	var/sended = FALSE
	var/silent = FALSE
	var/locked = TRUE


/obj/item/mortar_shell/proc/detonate(turf/detonate_turf)
	var/old_loc = loc
	forceMove(detonate_turf)
	var/angle = get_angle(loc, old_loc)
	pixel_x = cos(angle) * ICON_SIZE_X * 6
	pixel_z = sin(angle) * ICON_SIZE_Y * 6
	var/rotation = delta_to_angle(pixel_x, pixel_z) //CUSTOM HOMEBREWED proc that is just arctan with extra steps
	transform = matrix().Turn(rotation + 180)
	layer = FLY_LAYER
	SET_PLANE_EXPLICIT(src, ABOVE_GAME_PLANE, src)
	animate(src, pixel_z = -1 * abs(sin(rotation)) * 4, pixel_x = SUPPLYPOD_X_OFFSET + (sin(rotation) * 20), time = falling_time, easing = LINEAR_EASING) //Make the pod fall! At an angle!
	sleep(falling_time)
	SEND_SIGNAL(src, COMSIG_MORTAR_DETONATE, src)

/proc/deploy_camera(turf/deploy_turf)
	var/obj/machinery/camera/mortar/old_cam = locate() in deploy_turf
	if(old_cam)
		qdel(old_cam)
	new /obj/machinery/camera/mortar(deploy_turf)

/obj/item/mortar_shell/blob_act(obj/structure/blob/B)
	if(sended)
		return
	handle_fire()
	return ..()

/obj/item/mortar_shell/fire_act(datum/gas_mixture/air, exposed_temperature, exposed_volume, global_overlay)
	if(sended)
		return
	handle_fire()
	return ..()

/obj/item/mortar_shell/flamer_fire_act(damage)
	if(sended)
		return
	handle_fire()
	return ..()


/obj/item/mortar_shell/he
	name = "80mm high explosive mortar shell"
	desc = "An 80mm mortar shell, loaded with a high explosive charge."
	icon_state = "mortar_ammo_he"
	item_state = "mortar_ammo_he"

/obj/item/mortar_shell/he/detonate(turf/detonate_turf)
	. = ..()
	explosion(detonate_turf, devastation_range = 0, heavy_impact_range = 4, light_impact_range = 7, flash_range = 7)

/obj/item/mortar_shell/frag
	name = "80mm fragmentation mortar shell"
	desc = "An 80mm mortar shell, loaded with a fragmentation charge."
	icon_state = "mortar_ammo_frag"
	item_state = "mortar_ammo_frag"

/obj/item/mortar_shell/frag/detonate(turf/detonate_turf)
	AddComponent(/datum/component/pellet_cloud, magnitude = 4)
	. = ..()
	sleep(2)
	explosion(detonate_turf, devastation_range = 0, heavy_impact_range = 0, light_impact_range = 5)

/obj/item/mortar_shell/incendiary
	name = "80mm incendiary mortar shell"
	desc = "An 80mm mortar shell, loaded with a Type B napalm charge. Perfect for long-range area denial."
	icon_state = "mortar_ammo_inc"
	item_state = "mortar_ammo_inc"
	var/radius = 5
	var/flame_level = BURN_TIME_TIER_5 + 5 //Type B standard, 50 base + 5 from chemfire code.
	var/burn_level = BURN_LEVEL_TIER_2
	var/flameshape = FLAMESHAPE_DEFAULT
	var/fire_type = FIRE_VARIANT_TYPE_B //Armor Shredding Greenfire

/obj/item/mortar_shell/incendiary/detonate(turf/detonate_turf)
	. = ..()
	flame_radius( radius, detonate_turf, flame_level, burn_level, flameshape, null, fire_type)
	playsound(detonate_turf, 'sound/weapons/gun_flamethrower2.ogg', 35, TRUE, 4)

/obj/item/mortar_shell/flare
	name = "80mm flare/camera mortar shell"
	desc = "An 80mm mortar shell, loaded with an illumination flare / camera combo, attached to a parachute."
	icon_state = "mortar_ammo_flr"
	item_state = "mortar_ammo_flr"
	silent = TRUE

/obj/item/mortar_shell/flare/detonate(turf/detonate_turf)
	. = ..()
	new /obj/item/flashlight/flare/on/illumination(detonate_turf)
	playsound(detonate_turf, 'sound/weapons/gun_flare.ogg', 50, TRUE, 4)
	deploy_camera(detonate_turf)

/obj/item/mortar_shell/custom
	name = "80mm custom mortar shell"
	desc = "An 80mm mortar shell."
	icon_state = "mortar_ammo_custom"
	item_state = "mortar_ammo_custom_locked"

	materials = list(METAL = 18750) //5 sheets
	var/obj/item/warhead/mortar/warhead
	var/obj/item/reagent_containers/glass/beaker/fuel
	var/fuel_requirement = 60
	var/fuel_type = "hydrogen"
	locked = FALSE

/obj/item/mortar_shell/custom/examine(mob/user)
	. = ..()
	if(fuel)
		. += span_notice("Contains fuel.")
	if(warhead)
		. += span_notice("Contains a warhead[warhead.has_camera ? " with integrated camera drone." : ""].")

/obj/item/mortar_shell/custom/detonate(turf/detonate_turf)
	if(fuel)
		var/fuel_amount = fuel.reagents.get_reagent_amount(fuel_type)
		if(fuel_amount >= fuel_requirement)
			. = ..()
			if(warhead?.has_camera)
				deploy_camera(detonate_turf)
	if(warhead && locked)
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

	update_icon(UPDATE_ICON_STATE)

/obj/item/mortar_shell/custom/update_icon_state()
	if(!warhead)
		icon_state = initial(icon_state)
		return

	if(!(fuel && fuel.reagents.get_reagent_amount(fuel_type) >= fuel_requirement))
		icon_state = initial(icon_state) + "_no_fuel"
		return

	if(!locked)
		icon_state = initial(icon_state) + "_unlocked"
		return

	icon_state = initial(icon_state) + "_locked"

/obj/item/mortar_shell/custom/screwdriver_act(mob/living/user, obj/item/I)
	if(!warhead)
		to_chat(user, span_notice("[name] must contain a warhead to do that!"))
		return

	if(!fuel)
		to_chat(user, span_notice("[name] must contain a fuel to do that!"))
		return

	if(locked)
		to_chat(user, span_notice("You unlock [name]."))
	else
		to_chat(user, span_notice("You lock [name]."))
	locked = !locked
	playsound(loc, 'sound/items/Screwdriver.ogg', 25, FALSE, 6)
	update_icon(UPDATE_ICON_STATE)
	. = ..()


/obj/item/mortar_shell/custom/attackby(obj/item/I, mob/user)
	if(istype(I, /obj/item/reagent_containers/glass) && !locked)
		if(!warhead)
			to_chat(user, span_notice("[name] must contain a warhead to do that!"))
			return ATTACK_CHAIN_PROCEED
		if(fuel)
			to_chat(user, span_danger("The [name] already has a fuel container!"))
			return ATTACK_CHAIN_PROCEED
		user.temporarily_remove_item_from_inventory(I)
		I.forceMove(src)
		fuel = I
		to_chat(user, span_danger("You add [I] to [name]."))
		update_icon(UPDATE_ICON_STATE)
		playsound(loc, 'sound/items/Screwdriver2.ogg', 25, FALSE, 6)
		return ATTACK_CHAIN_PROCEED_SUCCESS

	if(!(istype(I,/obj/item/warhead/mortar) && !locked))
		return ..()

	if(warhead)
		to_chat(user, span_danger("The [name] already has a warhead!"))
		return ATTACK_CHAIN_PROCEED

	var/obj/item/warhead/mortar/det = I
	if(!det.locked)
		to_chat(user, span_danger("The [I] is not secured!"))
		return ATTACK_CHAIN_PROCEED

	user.temporarily_remove_item_from_inventory(I)
	I.forceMove(src)
	warhead = I
	to_chat(user, span_danger("You add [I] to [name]."))
	update_icon(UPDATE_ICON_STATE)
	playsound(loc, 'sound/items/Screwdriver2.ogg', 25, FALSE, 6)
	return ATTACK_CHAIN_PROCEED_SUCCESS

/obj/item/mortar_shell/ex_act(severity, explosion_direction)
	if(!burning)
		return ..()

/obj/item/mortar_shell/attack_hand(mob/user)
	if(burning)
		to_chat(user, span_danger("[src] is on fire and might explode!"))
		return
	return ..()

/obj/item/mortar_shell/proc/can_explode()
	return TRUE

/obj/item/mortar_shell/custom/can_explode()
	return FALSE

/obj/item/mortar_shell/flare/can_explode()
	return FALSE

/obj/item/mortar_shell/proc/handle_fire()
	if(!can_explode())
		return
	visible_message(span_warning("[src] catches on fire and starts cooking off! It's gonna blow!"))
	anchored = TRUE // don't want other explosions launching it elsewhere
	var/datum/effect_system/spark_spread/sparks = new()
	sparks.set_up(number = 10, location = loc)
	sparks.start()
	new /obj/effect/warning/explosive(loc, 5 SECONDS)

	addtimer(CALLBACK(src, PROC_REF(explode)), 5 SECONDS)
	addtimer(CALLBACK(GLOBAL_PROC, GLOBAL_PROC_REF(qdel), (src)), 5.5 SECONDS)


/obj/item/mortar_shell/proc/explode()
	explosion(get_turf(src), devastation_range = 0, heavy_impact_range = 3, light_impact_range = 5)


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

/obj/structure/closet/crate/secure/mortar
	icon = 'icons/obj/structures/mortar.dmi'
	icon_state = "secure_locked_mortar"
	overlay_locked = null
	overlay_unlocked = null
	overlay_sparking = null

/obj/structure/closet/crate/secure/mortar/update_icon_state()
	var/state = (locked)? "locked" : ((opened)? "open" : "unlocked")
	icon_state = "secure_[state]_mortar"

/obj/structure/closet/crate/secure/mortar/togglelock(mob/living/user)
	if(!locked)
		return FALSE
	return ..()

/obj/structure/closet/crate/secure/mortar/mortar_kit
	name = "mortar kit crate"

/obj/structure/closet/crate/secure/mortar/populate_contents()
	new /obj/item/mortar_kit(src)
	new /obj/item/mortar_shell/he(src)
	new /obj/item/mortar_shell/he(src)
	new /obj/item/mortar_shell/flare(src)
	new /obj/item/mortar_shell/frag(src)
	new /obj/item/mortar_shell/frag(src)
	new /obj/item/mortar_shell/incendiary(src)
	new /obj/item/wrench(src)

/obj/structure/closet/crate/secure/mortar/mortar_shells
	name = "mortar kit crate"
	var/count = 5
	var/shell_type = /obj/item/mortar_shell

/obj/structure/closet/crate/secure/mortar/mortar_shells/populate_contents()
	for (var/i = 1; i <= count; i++)
		new shell_type(src)

/obj/structure/closet/crate/secure/mortar/mortar_shells/he
	name = "mortar shells HE crate"
	shell_type = /obj/item/mortar_shell/he

/obj/structure/closet/crate/secure/mortar/mortar_shells/frag
	name = "mortar shells frag crate"
	shell_type = /obj/item/mortar_shell/frag

/obj/structure/closet/crate/secure/mortar/mortar_shells/flare
	name = "mortar shells flare crate"
	count = 3
	shell_type = /obj/item/mortar_shell/flare

/obj/structure/closet/crate/secure/mortar/mortar_shells/incendiary
	name = "mortar shells incendiary crate"
	count = 5
	shell_type = /obj/item/mortar_shell/incendiary

/obj/structure/closet/crate/secure/mortar/custom_kit
	name = "mortar shells custom kit"

/obj/structure/closet/crate/secure/mortar/custom_kit/populate_contents()
	for (var/i = 1; i <= 6; i++)
		new /obj/item/mortar_shell/custom(src)
	for (var/i = 1; i <= 3; i++)
		new /obj/item/warhead/mortar(src)
	for (var/i = 1; i <= 3; i++)
		new/obj/item/warhead/mortar/camera(src)

	var/obj/item/paper/paper = new(src)
	paper.name = "Инструкция по сборке снаряда для мортиры"
	paper.info = "<b>Инструкция по сборке снаряда для мортиры</b></br>\
	1) Для начала соберите боевую часть. Для этого нужно вставить минимум один(максимум 2) бикер, с нужными вам реагентами.</br>\
	Помните: у снаряда есть ограничения по вместимости бикеров(50 с камерой и 100 без)</br>\
	2) После того, как вставите нужные бикеры, закрутите крышку отверткой.</br> \
	Внимание: Не рекомендуется пытаться раскрутить крышку после сборки. Это приведет к преждевременному смешению содержимого.</br> \
	3) Затем необходимо вставить собраную боевую часть в корпус снаряда.</br> \
	4) Затем вставьте в корпус бикер с топливом(минимум 60 юнитов). Наши снаряды используют водород в качестве оного</br> \
	5) После этого можно завершить сборку снаряда, закрутив крышку отверткой \
	"

