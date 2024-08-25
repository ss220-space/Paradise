#define HEALPERCABLE 3
#define MAXCABLEPERHEAL 8
/obj/item/stack/cable_coil
	name = "cable coil"
	singular_name = "cable"
	icon = 'icons/obj/engines_and_power/power.dmi'
	icon_state = "coil"
	item_state = "coil_red"
	belt_icon = "cable_coil"
	amount = MAXCOIL
	max_amount = MAXCOIL
	merge_type = /obj/item/stack/cable_coil // This is here to let its children merge between themselves
	color = WIRE_COLOR_RED
	desc = "A coil of power cable."
	throwforce = 10
	w_class = WEIGHT_CLASS_SMALL
	full_w_class = WEIGHT_CLASS_SMALL
	throw_speed = 2
	throw_range = 5
	materials = list(MAT_METAL=10, MAT_GLASS=5)
	flags = CONDUCT
	slot_flags = ITEM_SLOT_BELT
	item_state = "coil"
	attack_verb = list("whipped", "lashed", "disciplined", "flogged")
	usesound = 'sound/items/deconstruct.ogg'
	toolspeed = 1


/obj/item/stack/cable_coil/Initialize(mapload, new_amount, merge = TRUE, cable_color = null)
	. = ..()
	if(cable_color)
		color = cable_color
	pixel_x = rand(-2,2)
	pixel_y = rand(-2,2)
	update_appearance(UPDATE_ICON_STATE|UPDATE_NAME)
	update_weight()


/obj/item/stack/cable_coil/split_stack()
	var/obj/item/stack/cable_coil/C = ..()
	C.color = color
	return C


/obj/item/stack/cable_coil/update_name(updates = ALL)
	. = ..()
	if(amount > 2)
		name = "cable coil"
	else
		name = "cable piece"


/obj/item/stack/cable_coil/update_icon_state()
	if(!color)
		color = pick(WIRE_COLOR_RED, WIRE_COLOR_BLUE, WIRE_COLOR_GREEN, WIRE_COLOR_ORANGE, WIRE_COLOR_WHITE, WIRE_COLOR_PINK, WIRE_COLOR_YELLOW, WIRE_COLOR_CYAN)
	if(amount == 1)
		icon_state = "coil1"
	else if(amount == 2)
		icon_state = "coil2"
	else
		icon_state = "coil"


/obj/item/stack/cable_coil/update_weight()
	if(amount == 1)
		w_class = WEIGHT_CLASS_TINY
	else
		w_class = WEIGHT_CLASS_SMALL


/obj/item/stack/cable_coil/examine(mob/user)
	. = ..()
	if(is_cyborg || !in_range(user, src))
		return
	if(get_amount() == 1)
		. += span_notice("A short piece of power cable.")
	else if(get_amount() == 2)
		. += span_notice("A piece of power cable.")
	else
		. += span_notice("A coil of power cable. There are [get_amount()] lengths of cable in the coil.")


/obj/item/stack/cable_coil/suicide_act(mob/user)
	if(locate(/obj/structure/chair/stool) in user.loc)
		user.visible_message("<span class='suicide'>[user] is making a noose with the [name]! It looks like [user.p_theyre()] trying to commit suicide.</span>")
	else
		user.visible_message("<span class='suicide'>[user] is strangling [user.p_them()]self with the [name]! It looks like [user.p_theyre()] trying to commit suicide.</span>")
	return OXYLOSS


///////////////////////////////////
// General procedures
///////////////////////////////////
/obj/item/stack/cable_coil/attack_self(mob/user)
	var/image/restraints_icon = image(icon = 'icons/obj/items.dmi', icon_state = "cuff_white")
	var/image/multiz_icon = image(icon = 'icons/obj/engines_and_power/power.dmi', icon_state = "cable_bridge")
	var/choices = list(
		"cable restraints (15)" = restraints_icon,
		"multi z cable hub (10)" = multiz_icon,
	)
	var/choice = show_radial_menu(user, src, choices, custom_check = CALLBACK(src, PROC_REF(check_menu), user))
	if(!check_menu(user))
		return
	var/turf/T = get_turf(src)
	switch(choice)
		if("cable restraints (15)")
			if(get_amount() < 15)
				to_chat(user, span_warning("You don't have enough [src] to make cable restraints!"))
			if(use(15))
				var/obj/item/restraints/handcuffs/cable/cablecuff = new(T)
				var/text_color
				switch(color)
					if(WIRE_COLOR_BLUE)
						text_color = "blue"
					if(WIRE_COLOR_CYAN)
						text_color = "cyan"
					if(WIRE_COLOR_GREEN)
						text_color = "green"
					if(WIRE_COLOR_ORANGE)
						text_color = "orange"
					if(WIRE_COLOR_PINK)
						text_color = "pink"
					if(WIRE_COLOR_RED)
						text_color = "red"
					if(WIRE_COLOR_YELLOW)
						text_color = "yellow"
					else
						text_color = "white"

				cablecuff.icon_state = "cuff_[text_color]"
		if("multi z cable hub (10)")
			if(T.intact || (T.transparent_floor == TURF_TRANSPARENT))
				to_chat(user, span_warning("You need to remove floor plating."))
				return
			if(get_amount() < 10)
				to_chat(user, span_warning("You don't have enough [src] to make cable restraints!"))
				return
			if(do_after(user, 2 SECONDS, user))
				if(!use(10))
					to_chat(user, span_warning("You don't have enough [src] to make cable restraints!"))
					return
				playsound(T, usesound, 50, 1)
				to_chat(user, span_notice("You place hub cable onto the floor."))
				var/obj/structure/cable/multiz/multicable = new(T)
				multicable.cable_color(color)

/obj/item/stack/cable_coil/proc/check_menu(mob/living/user)
	if(!istype(user))
		return FALSE
	if(user.incapacitated() || user.get_active_hand() != src)
		return FALSE
	return TRUE

//you can use wires to heal robotics
/obj/item/stack/cable_coil/attack(mob/living/carbon/human/target, mob/living/user, params, def_zone, skip_attack_anim = FALSE)
	if(!ishuman(target))
		return ..()

	var/obj/item/organ/external/target_organ = target.get_organ(check_zone(user.zone_selected))
	if(!target_organ || !target_organ.is_robotic() || user.a_intent != INTENT_HELP || target_organ.open == ORGAN_SYNTHETIC_OPEN)
		return ..()

	. = ATTACK_CHAIN_PROCEED

	if(target_organ.burn_dam > ROBOLIMB_SELF_REPAIR_CAP)
		to_chat(user, span_danger("The damage is far too severe to patch over externally."))
		return .

	if(!target_organ.burn_dam)
		to_chat(user, span_notice("Nothing to fix!"))
		return .

	if(target == user && !do_after(user, 1 SECONDS, target, NONE))
		return .

	. |= ATTACK_CHAIN_SUCCESS

	var/cable_used = 0
	var/list/childlist = LAZYLEN(target_organ.children) ? target_organ.children.Copy() : null
	var/parenthealed = FALSE
	var/should_update_health = FALSE
	var/update_damage_icon = NONE
	while(cable_used <= MAXCABLEPERHEAL && amount)
		var/obj/item/organ/external/current_organ
		if(target_organ.burn_dam)
			current_organ = target_organ
		else if(LAZYLEN(childlist))
			current_organ = pick_n_take(childlist)
			if(!current_organ.burn_dam || !current_organ.is_robotic())
				continue
		else if(target_organ.parent && !parenthealed)
			current_organ = target_organ.parent
			parenthealed = TRUE
			if(!current_organ.burn_dam || !current_organ.is_robotic())
				break
		else
			break
		var/burn_was = current_organ.burn_dam
		while(cable_used <= MAXCABLEPERHEAL && current_organ.burn_dam && amount)
			use(1)
			cable_used++
			update_damage_icon |= current_organ.heal_damage(0, HEALPERCABLE, FALSE, TRUE, FALSE)
		if(current_organ.burn_dam != burn_was)
			should_update_health = TRUE
		user.visible_message(span_alert("[user] repairs some burn damage on [target]'s [current_organ.name] with [src]."))
	if(should_update_health)
		target.updatehealth("cable repair")
	if(update_damage_icon)
		target.UpdateDamageIcon()


/obj/item/stack/cable_coil/attackby(obj/item/I, mob/user, params)
	if(istype(I, /obj/item/toy/crayon))
		add_fingerprint(user)
		var/obj/item/toy/crayon/crayon = I
		cable_color(crayon.colourName)
		return ATTACK_CHAIN_PROCEED_SUCCESS

	return ..()


///////////////////////////////////////////////
// Cable laying procedures
//////////////////////////////////////////////

/obj/item/stack/cable_coil/proc/get_new_cable(location)
	var/obj/structure/cable/C = new(location)
	C.cable_color(color)

	return C

// called when cable_coil is clicked on a turf/simulated/floor
/obj/item/stack/cable_coil/proc/place_turf(turf/T, mob/user, dirnew)
	if(!isturf(user.loc))
		return

	if(!isturf(T) || !T.can_lay_cable())
		to_chat(user, "<span class='warning'>You can only lay cables on catwalks and plating!</span>")
		return

	if(get_amount() < 1) // Out of cable
		to_chat(user, "<span class='warning'>There is no cable left!</span>")
		return

	if(get_dist(T,user.loc) > 1) // Too far
		to_chat(user, "<span class='warning'>You can't lay cable at a place that far away!</span>")
		return

	var/dirn
	if(!dirnew) //If we weren't given a direction, come up with one! (Called as null from catwalk.dm and floor.dm)
		if(user.loc == T)
			dirn = user.dir //If laying on the tile we're on, lay in the direction we're facing
		else
			dirn = get_dir(T, user)
	else
		dirn = dirnew

	for(var/obj/structure/cable/LC in T)
		if(LC.d2 == dirn && LC.d1 == 0)
			to_chat(user, "<span class='warning'>There's already a cable at that position!</span>")
			return

	var/obj/structure/cable/C = get_new_cable(T)

	//set up the new cable
	C.d1 = 0 //it's a O-X node cable
	C.d2 = dirn
	C.add_fingerprint(user)
	C.update_icon(UPDATE_ICON_STATE)

	//create a new powernet with the cable, if needed it will be merged later
	var/datum/powernet/PN = new()
	PN.add_cable(C)

	C.mergeConnectedNetworks(C.d2) //merge the powernet with adjacents powernets
	C.mergeConnectedNetworksOnTurf() //merge the powernet with on turf powernets

	if(C.d2 & (C.d2 - 1))// if the cable is layed diagonally, check the others 2 possible directions
		C.mergeDiagonalsNetworks(C.d2)

	use(1)

	if(C.shock(user, 50))
		if(prob(50)) //fail
			new /obj/item/stack/cable_coil(get_turf(C), 1, TRUE, C.color)
			C.deconstruct()

	SEND_GLOBAL_SIGNAL(COMSIG_GLOB_CABLE_UPDATED, T)
	return C

// called when cable_coil is click on an installed obj/cable
// or click on a turf that already contains a "node" cable
/obj/item/stack/cable_coil/proc/cable_join(obj/structure/cable/C, mob/user)
	if(istype(C, /obj/structure/cable/multiz))
		return
	var/turf/U = user.loc
	if(!isturf(U))
		return

	var/turf/T = get_turf(C)

	if(!isturf(T) || T.intact || (T.transparent_floor == TURF_TRANSPARENT))		// sanity checks, also stop use interacting with T-scanner revealed cable
		return

	if(get_dist(C, user) > 1)		// make sure it's close enough
		to_chat(user, "<span class='warning'>You can't lay cable at a place that far away!</span>")
		return


	if(U == T) //if clicked on the turf we're standing on, try to put a cable in the direction we're facing
		place_turf(T,user)
		return

	var/dirn = get_dir(C, user)
	SEND_GLOBAL_SIGNAL(COMSIG_GLOB_CABLE_UPDATED, T)

	// one end of the clicked cable is pointing towards us
	if(C.d1 == dirn || C.d2 == dirn)
		if(U.intact || (U.transparent_floor == TURF_TRANSPARENT))						// can't place a cable if the floor is complete
			to_chat(user, "<span class='warning'>You can't lay cable there unless the floor tiles are removed!</span>")
			return
		// cable is pointing at us, we're standing on an open tile
		// so create a stub pointing at the clicked cable on our tile

		var/fdirn = turn(dirn, 180)		// the opposite direction

		for(var/obj/structure/cable/LC in U)		// check to make sure there's not a cable there already
			if(LC.d1 == fdirn || LC.d2 == fdirn)
				to_chat(user, "<span class='warning'>There's already a cable at that position!</span>")
				return

		var/obj/structure/cable/NC = get_new_cable (U)

		NC.d1 = 0
		NC.d2 = fdirn
		NC.add_fingerprint(user)
		NC.update_icon()

		//create a new powernet with the cable, if needed it will be merged later
		var/datum/powernet/newPN = new()
		newPN.add_cable(NC)

		NC.mergeConnectedNetworks(NC.d2) //merge the powernet with adjacents powernets
		NC.mergeConnectedNetworksOnTurf() //merge the powernet with on turf powernets

		if(NC.d2 & (NC.d2 - 1))// if the cable is layed diagonally, check the others 2 possible directions
			NC.mergeDiagonalsNetworks(NC.d2)

		use(1)

		if(NC.shock(user, 50))
			if(prob(50)) //fail
				NC.deconstruct()
				return

	// exisiting cable doesn't point at our position, so see if it's a stub
	else if(C.d1 == 0)
							// if so, make it a full cable pointing from it's old direction to our dirn
		var/nd1 = C.d2	// these will be the new directions
		var/nd2 = dirn


		if(nd1 > nd2)		// swap directions to match icons/states
			nd1 = dirn
			nd2 = C.d2


		for(var/obj/structure/cable/LC in T)		// check to make sure there's no matching cable
			if(LC == C)			// skip the cable we're interacting with
				continue
			if((LC.d1 == nd1 && LC.d2 == nd2) || (LC.d1 == nd2 && LC.d2 == nd1) )	// make sure no cable matches either direction
				to_chat(user, "<span class='warning'>There's already a cable at that position!</span>")
				return


		C.cable_color(color)

		C.d1 = nd1
		C.d2 = nd2

		C.add_fingerprint()
		C.update_icon(UPDATE_ICON_STATE)


		C.mergeConnectedNetworks(C.d1) //merge the powernets...
		C.mergeConnectedNetworks(C.d2) //...in the two new cable directions
		C.mergeConnectedNetworksOnTurf()

		if(C.d1 & (C.d1 - 1))// if the cable is layed diagonally, check the others 2 possible directions
			C.mergeDiagonalsNetworks(C.d1)

		if(C.d2 & (C.d2 - 1))// if the cable is layed diagonally, check the others 2 possible directions
			C.mergeDiagonalsNetworks(C.d2)

		use(1)

		if(C.shock(user, 50))
			if(prob(50)) //fail
				C.deconstruct()
				return

		C.denode()// this call may have disconnected some cables that terminated on the centre of the turf, if so split the powernets.
		SEND_GLOBAL_SIGNAL(COMSIG_GLOB_CABLE_UPDATED, T)

//////////////////////////////
// Misc.
/////////////////////////////

/obj/item/stack/cable_coil/cut
	item_state = "coil2"

/obj/item/stack/cable_coil/cut/Initialize(mapload, new_amount, merge = TRUE, cable_color = null)
	. = ..(mapload, rand(1,2), merge, cable_color)

/obj/item/stack/cable_coil/yellow
	color = WIRE_COLOR_YELLOW

/obj/item/stack/cable_coil/blue
	color = WIRE_COLOR_BLUE

/obj/item/stack/cable_coil/green
	color = WIRE_COLOR_GREEN

/obj/item/stack/cable_coil/pink
	color = WIRE_COLOR_PINK

/obj/item/stack/cable_coil/orange
	color = WIRE_COLOR_ORANGE

/obj/item/stack/cable_coil/cyan
	color = WIRE_COLOR_CYAN

/obj/item/stack/cable_coil/white
	color = WIRE_COLOR_WHITE

/obj/item/stack/cable_coil/random/Initialize(mapload, new_amount, merge = TRUE, cable_color = null)
	var/random_color = pick(WIRE_COLOR_RED, WIRE_COLOR_BLUE, WIRE_COLOR_GREEN, WIRE_COLOR_WHITE, WIRE_COLOR_PINK, WIRE_COLOR_YELLOW, WIRE_COLOR_CYAN)
	. = ..(mapload, new_amount, merge, random_color)

/obj/item/stack/cable_coil/proc/cable_color(colorC)
	if(!colorC)
		color = WIRE_COLOR_RED
	else if(colorC == "rainbow")
		color = color_rainbow()
	else if(colorC == "orange") //byond only knows 16 colors by name, and orange isn't one of them
		color = WIRE_COLOR_ORANGE
	else
		color = colorC

/obj/item/stack/cable_coil/proc/color_rainbow()
	color = pick(WIRE_COLOR_RED, WIRE_COLOR_BLUE, WIRE_COLOR_GREEN, WIRE_COLOR_PINK, WIRE_COLOR_YELLOW, WIRE_COLOR_CYAN)
	return color

/obj/item/stack/cable_coil/cyborg
	name = "cyborg cable coil"
	is_cyborg = 1

/obj/item/stack/cable_coil/cyborg/attack_self(mob/user)
	var/cablecolor = input(user,"Pick a cable color.","Cable Color") in list("red","yellow","green","blue","pink","orange","cyan","white")
	color = cablecolor
	update_icon()

#undef MAXCABLEPERHEAL
#undef HEALPERCABLE
