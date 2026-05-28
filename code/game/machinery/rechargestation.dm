/obj/machinery/recharge_station
	name = "cyborg recharging station"
	icon = 'icons/obj/objects.dmi'
	icon_state = "borgcharger0"
	density = TRUE
	anchored = TRUE
	idle_power_usage = 5
	active_power_usage = 1000
	var/mob/occupant = null
	var/circuitboard = /obj/item/circuitboard/cyborgrecharger
	var/recharge_speed
	var/recharge_speed_nutrition
	var/repairs

/obj/machinery/recharge_station/Destroy()
	go_out()
	return ..()

/obj/machinery/recharge_station/Initialize(mapload)
	. = ..()
	component_parts = list()
	component_parts += new /obj/item/circuitboard/cyborgrecharger(null)
	component_parts += new /obj/item/stock_parts/capacitor(null)
	component_parts += new /obj/item/stock_parts/capacitor(null)
	component_parts += new /obj/item/stock_parts/manipulator(null)
	component_parts += new /obj/item/stock_parts/cell/high(null)
	RefreshParts()
	update_icon(UPDATE_ICON_STATE)

/obj/machinery/recharge_station/ert/Initialize(mapload)
	. = ..()
	component_parts = list()
	component_parts += new /obj/item/circuitboard/cyborgrecharger(null)
	component_parts += new /obj/item/stock_parts/capacitor(null)
	component_parts += new /obj/item/stock_parts/capacitor/adv(null)
	component_parts += new /obj/item/stock_parts/manipulator/femto(null)
	component_parts += new /obj/item/stock_parts/cell/super(null)
	RefreshParts()

/obj/machinery/recharge_station/upgraded/Initialize(mapload)
	. = ..()
	component_parts = list()
	component_parts += new /obj/item/circuitboard/cyborgrecharger(null)
	component_parts += new /obj/item/stock_parts/capacitor/super(null)
	component_parts += new /obj/item/stock_parts/capacitor/super(null)
	component_parts += new /obj/item/stock_parts/manipulator/pico(null)
	component_parts += new /obj/item/stock_parts/cell/hyper(null)
	RefreshParts()

/obj/machinery/recharge_station/RefreshParts()
	recharge_speed = 0
	recharge_speed_nutrition = 0
	repairs = 0
	for(var/obj/item/stock_parts/capacitor/C in component_parts)
		recharge_speed += C.rating * 100
		recharge_speed_nutrition += C.rating * 10
	for(var/obj/item/stock_parts/manipulator/M in component_parts)
		repairs += M.rating - 1
	for(var/obj/item/stock_parts/cell/C in component_parts)
		var/multiplier = C.maxcharge / 10000
		recharge_speed *= multiplier
		recharge_speed_nutrition *= multiplier

/obj/machinery/recharge_station/process()
	if(!is_operational())
		return

	if(!occupant)
		return

	process_occupant()

	for(var/mob/mob_inside in src)
		if(mob_inside == occupant || ispulsedemon(mob_inside))
			continue
		mob_inside.forceMove(loc)

/obj/machinery/recharge_station/ex_act(severity, target)
	if(occupant)
		occupant.ex_act(severity, target)
	return ..()

/obj/machinery/recharge_station/handle_atom_del(atom/A)
	. = ..()
	if(A == occupant)
		occupant = null
		updateUsrDialog()
		update_icon(UPDATE_ICON_STATE)

/obj/machinery/recharge_station/narsie_act()
	go_out()
	new /obj/effect/gibspawner/generic(get_turf(loc)) //I REPLACE YOUR TECHNOLOGY WITH FLESH!
	qdel(src)

/obj/machinery/recharge_station/ratvar_act()
	go_out()
	new /obj/effect/decal/cleanable/blood/gibs/clock(get_turf(loc))
	qdel(src)

/obj/machinery/recharge_station/Bumped(atom/movable/moving_atom)
	. = ..()
	if(!is_operational())
		return

	if(occupant)
		return

	if(ismob(moving_atom))
		move_inside(moving_atom)

/obj/machinery/recharge_station/AllowDrop()
	return FALSE

/obj/machinery/recharge_station/relaymove(mob/user as mob)
	if(ispulsedemon(user))
		return
	go_out()

/obj/machinery/recharge_station/emp_act(severity)
	if(occupant)
		occupant.emp_act(severity)
		go_out()

	return ..(severity)

/obj/machinery/recharge_station/update_icon_state()
	if(!occupant)
		icon_state = "borgcharger0"
		return

	if(stat & (NOPOWER|BROKEN))
		icon_state = "borgcharger2"
		return

	icon_state = "borgcharger1"

/obj/machinery/recharge_station/attackby(obj/item/I, mob/user, params)
	if(user.a_intent == INTENT_HARM)
		return ..()
	if(exchange_parts(user, I))
		return ATTACK_CHAIN_PROCEED_SUCCESS
	return ..()

/obj/machinery/recharge_station/crowbar_act(mob/user, obj/item/I)
	if(default_deconstruction_crowbar(user, I))
		return TRUE

/obj/machinery/recharge_station/screwdriver_act(mob/user, obj/item/I)
	if(occupant)
		to_chat(user, span_notice("The maintenance panel is locked."))
		return TRUE
	if(default_deconstruction_screwdriver(user, "borgdecon2", "borgcharger0", I))
		return TRUE

/obj/machinery/recharge_station/proc/process_occupant()
	SEND_SIGNAL(occupant, COMSIG_PROCESS_BORGCHARGER_OCCUPANT, recharge_speed, repairs)
	if(isrobot(occupant))
		var/mob/living/silicon/robot/our_occupant = occupant
		restock_modules()
		if(repairs)
			our_occupant.heal_overall_damage(repairs, repairs)
		if(our_occupant.cell)
			our_occupant.cell.charge = min(our_occupant.cell.charge + recharge_speed, our_occupant.cell.maxcharge)
		return

	if(ishuman(occupant))
		var/mob/living/carbon/human/our_human = occupant
		if(!our_human.get_int_organ(/obj/item/organ/internal/cell))
			return

		if(our_human.nutrition < NUTRITION_LEVEL_FULL - 1)
			our_human.set_nutrition(min(our_human.nutrition + recharge_speed_nutrition, NUTRITION_LEVEL_FULL - 1))
		if(repairs)
			our_human.heal_overall_damage(repairs, repairs, TRUE, 0, 1)

/obj/machinery/recharge_station/proc/go_out(mob/user = usr)
	if(!occupant)
		return

	occupant.forceMove(loc)
	occupant = null
	update_icon(UPDATE_ICON_STATE)
	use_power = IDLE_POWER_USE

/obj/machinery/recharge_station/proc/restock_modules()
	if(!isrobot(occupant))
		return

	var/mob/living/silicon/robot/robot = occupant
	if(!robot.module)
		return

	var/list/modules = robot.module.modules
	if(!length(modules))
		return

	var/coeff = recharge_speed / 200
	for(var/obj/item/module as anything in modules)
		// Security
		if(istype(module, /obj/item/flash))
			var/obj/item/flash/flash = module
			if(flash.broken)
				flash.broken = FALSE
				flash.times_used = 0
				flash.update_icon(UPDATE_ICON_STATE)
			continue

		if(isenergygun(module))
			var/obj/item/gun/energy/egun = module
			var/obj/item/stock_parts/cell/gun_cell = egun.get_cell()
			if(gun_cell.charge < gun_cell.maxcharge)
				var/obj/item/ammo_casing/energy/E = egun.ammo_type[egun.select]
				gun_cell.give(E.e_cost)
				egun.on_recharge()
				egun.update_appearance(UPDATE_ICON)
			else
				egun.charge_tick = 0
			continue

		//Service
		if(istype(module, /obj/item/reagent_containers/food/condiment/enzyme))
			if(module.reagents.get_reagent_amount("enzyme") < 50)
				module.reagents.add_reagent("enzyme", 2 * coeff)
			continue

		//Janitor
		if(istype(module, /obj/item/lightreplacer))
			var/obj/item/lightreplacer/light_replacer = module
			for(var/i in 1 to coeff)
				light_replacer.Charge(occupant)
			continue

		//Fire extinguisher
		if(istype(module, /obj/item/extinguisher))
			var/obj/item/extinguisher/ext = module
			ext.reagents.check_and_add("water", ext.max_water, 5 * coeff)
			continue

		//Welding tools
		if(iswelder(module))
			var/obj/item/weldingtool/weld = module
			weld.reagents.check_and_add("fuel", weld.maximum_fuel, 2 * coeff)
			continue

	robot.module.respawn_consumable(robot)

	//Emagged items for janitor and medical borg
	if(!robot.module.emag)
		return

	if(istype(robot.module.emag, /obj/item/reagent_containers/spray))
		var/obj/item/reagent_containers/spray/spray = robot.module.emag
		if(spray.name == "polyacid spray")
			spray.reagents.add_reagent("facid", 2 * coeff)
			return

		if(spray.name == "lube spray")
			spray.reagents.add_reagent("lube", 2 * coeff)
			return

		if(spray.name == "acid synthesizer")
			spray.reagents.add_reagent("facid", 2 * coeff)
			spray.reagents.add_reagent("sacid", 2 * coeff)
			return

/obj/machinery/recharge_station/verb/move_eject()
	set category = VERB_CATEGORY_OBJECT
	set src in oview(1)
	go_out(usr)

/obj/machinery/recharge_station/verb/move_inside_verb()
	set category = VERB_CATEGORY_OBJECT
	set src in oview(1)
	move_inside(usr)

/obj/machinery/recharge_station/proc/move_inside(mob/user)
	if(!user || !istype(user))
		return

	if(!is_operational())
		return

	if(user.stat != CONSCIOUS)
		return

	if(get_dist(src, user) > 2)
		to_chat(user, "They are too far away to put inside")
		return

	if(occupant)
		to_chat(user, span_warning("The cell is already occupied!"))
		return

	var/can_accept_user
	if(isrobot(user))
		var/mob/living/silicon/robot/robot = user

		if(!robot.cell)
			to_chat(robot, span_warning("Without a power cell, you can't be recharged."))
			//Make sure they actually HAVE a cell, now that they can get in while powerless. --NEO
			return
		can_accept_user = TRUE

	if(ishuman(user))
		var/mob/living/carbon/human/H = user

		if(!H.get_int_organ(/obj/item/organ/internal/cell) && !H.get_int_organ(/obj/item/organ/internal/cyberimp/brain/bci) && !(ismodcontrol(H.back)))
			return

		can_accept_user = TRUE

	if(is_circuit_drone(user))
		can_accept_user = TRUE

	if(!can_accept_user)
		to_chat(user, span_notice("Only non-organics may enter the recharger!"))
		return

	user.forceMove(src)
	occupant = user

	add_fingerprint(user)
	update_icon(UPDATE_ICON_STATE)
	update_use_power(1)

/obj/machinery/recharge_station/Exited(atom/movable/gone, direction)
	. = ..()
	if(occupant && occupant == gone)
		occupant = null
		update_icon(UPDATE_ICON_STATE)
		use_power = IDLE_POWER_USE
