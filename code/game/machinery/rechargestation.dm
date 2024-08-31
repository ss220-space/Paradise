/obj/machinery/recharge_station
	name = "cyborg recharging station"
	icon = 'icons/obj/objects.dmi'
	icon_state = "borgcharger0"
	density = TRUE
	anchored = TRUE
	use_power = IDLE_POWER_USE
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

/obj/machinery/recharge_station/New()
	..()
	component_parts = list()
	component_parts += new /obj/item/circuitboard/cyborgrecharger(null)
	component_parts += new /obj/item/stock_parts/capacitor(null)
	component_parts += new /obj/item/stock_parts/capacitor(null)
	component_parts += new /obj/item/stock_parts/manipulator(null)
	component_parts += new /obj/item/stock_parts/cell/high(null)
	RefreshParts()
	update_icon(UPDATE_ICON_STATE)

/obj/machinery/recharge_station/ert/New()
	..()
	component_parts = list()
	component_parts += new /obj/item/circuitboard/cyborgrecharger(null)
	component_parts += new /obj/item/stock_parts/capacitor(null)
	component_parts += new /obj/item/stock_parts/capacitor/adv(null)
	component_parts += new /obj/item/stock_parts/manipulator/femto(null)
	component_parts += new /obj/item/stock_parts/cell/super(null)
	RefreshParts()

/obj/machinery/recharge_station/upgraded/New()
	..()
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
	if(!(NOPOWER|BROKEN))
		return

	if(src.occupant)
		process_occupant()

	for(var/mob/M as mob in src) // makes sure that simple mobs don't get stuck inside a sleeper when they resist out of occupant's grasp
		if(M == occupant)
			continue
		else if(!ispulsedemon(M))
			M.forceMove(src.loc)
	return 1

/obj/machinery/recharge_station/ex_act(severity)
	if(occupant)
		occupant.ex_act(severity)
	..()

/obj/machinery/recharge_station/handle_atom_del(atom/A)
	..()
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
	if(ismob(moving_atom))
		move_inside(moving_atom)

/obj/machinery/recharge_station/AllowDrop()
	return FALSE

/obj/machinery/recharge_station/relaymove(mob/user as mob)
	if(ispulsedemon(user))
		return
	if(user.stat)
		return
	src.go_out()
	return

/obj/machinery/recharge_station/emp_act(severity)
	if(stat & (BROKEN|NOPOWER))
		..(severity)
		return
	if(occupant)
		occupant.emp_act(severity)
		go_out()
	..(severity)


/obj/machinery/recharge_station/update_icon_state()
	if(occupant)
		if(stat & (NOPOWER|BROKEN))
			icon_state = "borgcharger2"
		else
			icon_state = "borgcharger1"
	else
		icon_state = "borgcharger0"


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
	if(src.occupant)
		if(istype(occupant, /mob/living/silicon/robot))
			var/mob/living/silicon/robot/R = occupant
			restock_modules()
			if(repairs)
				R.heal_overall_damage(repairs, repairs)
			if(R.cell)
				R.cell.charge = min(R.cell.charge + recharge_speed, R.cell.maxcharge)
		else if(ishuman(occupant))
			var/mob/living/carbon/human/H = occupant
			if(H.get_int_organ(/obj/item/organ/internal/cell) && H.nutrition < 450)
				H.set_nutrition(min(H.nutrition + recharge_speed_nutrition, 450))
			if(repairs)
				H.heal_overall_damage(repairs, repairs, affect_robotic = TRUE)

/obj/machinery/recharge_station/proc/go_out(mob/user = usr)
	if(!occupant)
		return
	if(user && (user.incapacitated() || HAS_TRAIT(user, TRAIT_HANDS_BLOCKED)))
		return
	occupant.forceMove(loc)
	occupant = null
	update_icon(UPDATE_ICON_STATE)
	use_power = IDLE_POWER_USE


/obj/machinery/recharge_station/proc/restock_modules()
	if(isrobot(occupant))
		var/mob/living/silicon/robot/R = occupant
		var/coeff = recharge_speed / 200
		if(R.module && R.module.modules)
			var/list/um = R.contents|R.module.modules
			// ^ makes sinle list of active (R.contents) and inactive modules (R.module.modules)
			for(var/obj/O in um)
				// Security
				if(istype(O,/obj/item/flash))
					var/obj/item/flash/F = O
					if(F.broken)
						F.broken = FALSE
						F.times_used = 0
						F.update_icon(UPDATE_ICON_STATE)
				else if(istype(O,/obj/item/gun/energy))
					var/obj/item/gun/energy/D = O
					if(D.cell.charge < D.cell.maxcharge)
						var/obj/item/ammo_casing/energy/E = D.ammo_type[D.select]
						D.cell.give(E.e_cost)
						D.on_recharge()
						D.update_icon()
					else
						D.charge_tick = 0
				//Service
				else if(istype(O,/obj/item/reagent_containers/food/condiment/enzyme))
					if(O.reagents.get_reagent_amount("enzyme") < 50)
						O.reagents.add_reagent("enzyme", 2 * coeff)
				//Janitor
				else if(istype(O, /obj/item/lightreplacer))
					var/obj/item/lightreplacer/LR = O
					var/i = 1
					for(1, i <= coeff, i++)
						LR.Charge(occupant)
				//Fire extinguisher
				else if(istype(O, /obj/item/extinguisher))
					var/obj/item/extinguisher/ext = O
					ext.reagents.check_and_add("water", ext.max_water, 5 * coeff)
				//Welding tools
				else if(istype(O, /obj/item/weldingtool))
					var/obj/item/weldingtool/weld = O
					weld.reagents.check_and_add("fuel", weld.maximum_fuel, 2 * coeff)

			R.module.respawn_consumable(R)

			//Emagged items for janitor and medical borg
			if(R.module.emag)
				if(istype(R.module.emag, /obj/item/reagent_containers/spray))
					var/obj/item/reagent_containers/spray/S = R.module.emag
					if(S.name == "polyacid spray")
						S.reagents.add_reagent("facid", 2 * coeff)
					if(S.name == "lube spray")
						S.reagents.add_reagent("lube", 2 * coeff)
					else if(S.name == "acid synthesizer")
						S.reagents.add_reagent("facid", 2 * coeff)
						S.reagents.add_reagent("sacid", 2 * coeff)


/obj/machinery/recharge_station/verb/move_eject()
	set category = "Object"
	set src in oview(1)
	go_out(usr)


/obj/machinery/recharge_station/verb/move_inside_verb()
	set category = "Object"
	set src in oview(1)
	move_inside(usr)


/obj/machinery/recharge_station/proc/move_inside(mob/user = usr)
	set category = "Object"
	set src in oview(1)
	if(!user || !usr)
		return

	if(usr.stat != CONSCIOUS)
		return

	if(get_dist(src, user) > 2 || get_dist(usr, user) > 1)
		to_chat(usr, "They are too far away to put inside")
		return

	if(panel_open)
		to_chat(usr, span_warning("Close the maintenance panel first."))
		return

	var/can_accept_user
	if(isrobot(user))
		var/mob/living/silicon/robot/R = user

		if(R.stat == DEAD)
			//Whoever had it so that a borg with a dead cell can't enter this thing should be shot. --NEO
			return
		if(occupant)
			to_chat(R, span_warning("The cell is already occupied!"))
			return
		if(!R.cell)
			to_chat(R, span_warning("Without a power cell, you can't be recharged."))
			//Make sure they actually HAVE a cell, now that they can get in while powerless. --NEO
			return
		can_accept_user = 1

	else if(ishuman(user))
		var/mob/living/carbon/human/H = user

		if(H.stat == DEAD)
			return
		if(occupant)
			to_chat(H, span_warning("The cell is already occupied!"))
			return
		if(!H.get_int_organ(/obj/item/organ/internal/cell))
			return
		can_accept_user = 1

	if(!can_accept_user)
		to_chat(user, span_notice("Only non-organics may enter the recharger!"))
		return

	user.forceMove(src)
	occupant = user

	add_fingerprint(user)
	update_icon(UPDATE_ICON_STATE)
	update_use_power(1)

