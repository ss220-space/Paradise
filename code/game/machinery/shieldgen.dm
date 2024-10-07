/obj/machinery/shield
	name = "Emergency energy shield"
	desc = "An energy shield used to contain hull breaches."
	icon = 'icons/effects/effects.dmi'
	icon_state = "shield-old"
	density = TRUE
	opacity = FALSE
	anchored = TRUE
	resistance_flags = LAVA_PROOF | FIRE_PROOF | UNACIDABLE | ACID_PROOF
	max_integrity = 200

/obj/machinery/shield/New()
	dir = pick(NORTH, SOUTH, EAST, WEST)
	..()

/obj/machinery/shield/Initialize()
	air_update_turf(1)
	..()

/obj/machinery/shield/Destroy()
	set_opacity(FALSE)
	set_density(FALSE)
	air_update_turf(1)
	return ..()

/obj/machinery/shield/has_prints()
	return FALSE

/obj/machinery/shield/Move(atom/newloc, direct = NONE, glide_size_override = 0, update_dir = TRUE)
	var/turf/T = loc
	. = ..()
	move_update_air(T)


/obj/machinery/shield/CanAtmosPass(turf/T, vertical)
	return !density

/obj/machinery/shield/ex_act(severity)
	switch(severity)
		if(1.0)
			if(prob(75))
				qdel(src)
		if(2.0)
			if(prob(50))
				qdel(src)
		if(3.0)
			if(prob(25))
				qdel(src)

/obj/machinery/shield/emp_act(severity)
	switch(severity)
		if(1)
			qdel(src)
		if(2)
			if(prob(50))
				qdel(src)

/obj/machinery/shield/blob_act()
	if(!QDELETED(src))
		qdel(src)

/obj/machinery/shield/cult
	name = "cult barrier"
	desc = "A shield summoned by cultists to keep heretics away."
	max_integrity = 100
	icon_state = "shield-cult"

/obj/machinery/shield/cult/emp_act(severity)
	return

/obj/machinery/shield/cult/narsie
	name = "sanguine barrier"
	desc = "A potent shield summoned by cultists to defend their rites."
	max_integrity = 60

/obj/machinery/shield/cult/weak
	name = "Invoker's Shield"
	desc = "A weak shield summoned by cultists to protect them while they carry out delicate rituals."
	max_integrity = 20
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	layer = ABOVE_MOB_LAYER

/obj/machinery/shield/cult/barrier
	density = FALSE
	/// The rune that created the shield itself. Used to delete the rune when the shield is destroyed.
	var/obj/effect/rune/parent_rune

/obj/machinery/shield/cult/barrier/Initialize()
	. = ..()
	invisibility = INVISIBILITY_ABSTRACT

/obj/machinery/shield/cult/barrier/Destroy()
	if(parent_rune && !QDELETED(parent_rune))
		QDEL_NULL(parent_rune)
	return ..()

/obj/machinery/shield/cult/barrier/attack_hand(mob/living/user)
	parent_rune.attack_hand(user)

/obj/machinery/shield/cult/barrier/attack_animal(mob/living/simple_animal/user)
	if(iscultist(user))
		parent_rune.attack_animal(user)
	else
		..()

/**
* Turns the shield on and off.
*
* The shield has 2 states: on and off. When on, it will block movement, projectiles, items, etc. and be clearly visible, and block atmospheric gases.
* When off, the rune no longer blocks anything and turns invisible.
* The barrier itself is not intended to interact with the conceal runes cult spell for balance purposes.
*/
/obj/machinery/shield/cult/barrier/proc/Toggle()
	var/visible
	if(!density) // Currently invisible
		set_density(TRUE) // Turn visible
		invisibility = initial(invisibility)
		visible = TRUE
	else // Currently visible
		set_density(FALSE) // Turn invisible
		invisibility = INVISIBILITY_ABSTRACT
		visible = FALSE

	air_update_turf(1)
	return visible

/obj/machinery/shieldgen
	name = "Emergency shield projector"
	desc = "Used to seal minor hull breaches."
	icon = 'icons/obj/objects.dmi'
	icon_state = "shieldoff"
	density = TRUE
	opacity = FALSE
	anchored = FALSE
	pressure_resistance = 2*ONE_ATMOSPHERE
	req_access = list(ACCESS_ENGINE)
	var/const/max_health = 100
	var/health = max_health
	var/active = 0
	var/malfunction = FALSE //Malfunction causes parts of the shield to slowly dissapate
	var/list/deployed_shields = list()
	var/is_open = FALSE //Whether or not the wires are exposed
	var/locked = FALSE

/obj/machinery/shieldgen/Destroy()
	QDEL_LIST(deployed_shields)
	deployed_shields = null
	return ..()


/obj/machinery/shieldgen/proc/shields_up()
	if(active)
		return //If it's already turned on, how did this get called?

	active = 1
	set_anchored(TRUE)
	update_icon(UPDATE_ICON_STATE)

	for(var/turf/target_tile in range(2, src))
		if(isspaceturf(target_tile) && !(locate(/obj/machinery/shield) in target_tile))
			if(malfunction && prob(33) || !malfunction)
				deployed_shields += new /obj/machinery/shield(target_tile)

/obj/machinery/shieldgen/proc/shields_down()
	if(!active)
		return //If it's already off, how did this get called?

	active = 0
	update_icon(UPDATE_ICON_STATE)

	for(var/obj/machinery/shield/shield_tile in deployed_shields)
		qdel(shield_tile)

/obj/machinery/shieldgen/process()
	if(malfunction && active)
		if(deployed_shields.len && prob(5))
			qdel(pick(deployed_shields))

	return

/obj/machinery/shieldgen/proc/checkhp()
	if(health <= 30)
		malfunction = TRUE
	if(health <= 0)
		qdel(src)
	update_icon(UPDATE_ICON_STATE)
	return

/obj/machinery/shieldgen/ex_act(severity)
	switch(severity)
		if(1.0)
			health -= 75
			checkhp()
		if(2.0)
			health -= 30
			if(prob(15))
				malfunction = TRUE
			checkhp()
		if(3.0)
			health -= 10
			checkhp()
	return

/obj/machinery/shieldgen/emp_act(severity)
	switch(severity)
		if(1)
			health = health * 0.5 //cut health in half
			malfunction = TRUE
			locked = pick(TRUE, FALSE)
		if(2)
			if(prob(50))
				health *= 0.3 //chop off a third of the health
				malfunction = TRUE
	checkhp()

/obj/machinery/shieldgen/attack_hand(mob/user as mob)
	if(locked)
		to_chat(user, "The machine is locked, you are unable to use it.")
		return
	if(is_open)
		to_chat(user, "The panel must be closed before operating this machine.")
		return

	if(active)
		add_fingerprint(user)
		user.visible_message(span_notice("[bicon(src)] [user] deactivated the shield generator."), \
			span_notice("[bicon(src)] You deactivate the shield generator."), \
			"You hear heavy droning fade out.")
		shields_down()
	else
		if(anchored)
			add_fingerprint(user)
			user.visible_message(span_notice("[bicon(src)] [user] activated the shield generator."), \
				span_notice("[bicon(src)] You activate the shield generator."), \
				"You hear heavy droning.")
			shields_up()
		else
			to_chat(user, "The device must first be secured to the floor.")


/obj/machinery/shieldgen/attackby(obj/item/I, mob/user, params)
	if(istype(I, /obj/item/card/emag))
		add_fingerprint(user)
		malfunction = TRUE
		update_icon(UPDATE_ICON_STATE)
		return ATTACK_CHAIN_PROCEED_SUCCESS

	if(user.a_intent == INTENT_HARM)
		return ..()

	if(istype(I, /obj/item/stack/cable_coil))
		add_fingerprint(user)
		if(!malfunction)
			to_chat(user, span_warning("The [name] is not malfunctioning!"))
			return ATTACK_CHAIN_PROCEED
		if(!is_open)
			to_chat(user, span_warning("Open panel first!"))
			return ATTACK_CHAIN_PROCEED
		var/obj/item/stack/cable_coil/coil = I
		if(coil.get_amount() < 1)
			to_chat(user, span_warning("You need more cable for this!"))
			return ATTACK_CHAIN_PROCEED
		to_chat(user, span_notice("You begin to replace the wires..."))
		playsound(loc, coil.usesound, 50, TRUE)
		if(!do_after(user, 3 SECONDS * coil.toolspeed, src, category = DA_CAT_TOOL) || !malfunction || !is_open || QDELETED(coil) || !coil.use(1))
			return ATTACK_CHAIN_PROCEED
		health = max_health
		malfunction = FALSE
		to_chat(user, span_notice("You repair the [src]!"))
		update_icon(UPDATE_ICON_STATE)
		return ATTACK_CHAIN_PROCEED_SUCCESS

	if(I.GetID() || is_pda(I))
		add_fingerprint(user)
		if(!allowed(user))
			to_chat(user, span_warning("Access denied."))
			return ATTACK_CHAIN_PROCEED
		locked = !locked
		to_chat(user, "The controls are now [locked ? "locked." : "unlocked."]")
		return ATTACK_CHAIN_PROCEED_SUCCESS

	return ..()


/obj/machinery/shieldgen/screwdriver_act(mob/user, obj/item/I)
	. = TRUE
	if(!I.use_tool(src, user, 0, volume = I.tool_volume))
		return
	is_open = !is_open
	if(is_open)
		SCREWDRIVER_OPEN_PANEL_MESSAGE
	else
		SCREWDRIVER_CLOSE_PANEL_MESSAGE

/obj/machinery/shieldgen/wrench_act(mob/user, obj/item/I)
	. = TRUE
	if(locked)
		to_chat(user, "The bolts are covered, unlocking this would retract the covers.")
		return
	if(!I.use_tool(src, user, 0, volume = I.tool_volume))
		return
	if(anchored)
		WRENCH_UNANCHOR_MESSAGE
		if(active)
			visible_message(span_warning("[src] shuts off!"))
			shields_down()
		set_anchored(FALSE)
	else
		if(istype(get_turf(src), /turf/space))
			return //No wrenching these in space!
		WRENCH_ANCHOR_MESSAGE
		set_anchored(TRUE)


/obj/machinery/shieldgen/update_icon_state()
	icon_state = "shield[active ? "on" : "off"][malfunction ? "br" : ""]"


////FIELD GEN START //shameless copypasta from fieldgen, powersink, and grille
#define maxstoredpower 500
/obj/machinery/shieldwallgen
	name = "Shield Generator"
	desc = "A shield generator."
	icon = 'icons/obj/stationobjs.dmi'
	icon_state = "shieldgen"
	anchored = FALSE
	density = TRUE
	req_access = list(ACCESS_TELEPORTER)
	var/active = 0
	var/power = 0
	var/steps = 0
	var/last_check = 0
	var/check_delay = 10
	var/recalc = 0
	var/locked = TRUE
	var/destroyed = 0
	var/directwired = 1
	var/obj/structure/cable/attached		// the attached cable
	var/storedpower = 0
	flags = CONDUCT
	use_power = NO_POWER_USE


/obj/machinery/shieldwallgen/update_icon_state()
	icon_state = "shieldgen[active ? "_on" : ""]"


/obj/machinery/shieldwallgen/proc/power()
	if(!anchored)
		power = 0
		return 0
	var/turf/T = loc

	var/obj/structure/cable/C = T.get_cable_node()
	var/datum/powernet/PN
	if(C)
		PN = C.powernet		// find the powernet of the connected cable

	if(!PN)
		power = 0
		return 0

	var/surplus = max(PN.avail-PN.load, 0)
	var/shieldload = min(rand(50,200), surplus)
	if(shieldload==0 && !storedpower)		// no cable or no power, and no power stored
		power = 0
		return 0
	else
		power = 1	// IVE GOT THE POWER!
		if(PN) //runtime errors fixer. They were caused by PN.load trying to access missing network in case of working on stored power.
			storedpower += shieldload
			PN.load += shieldload //uses powernet power.
//		message_admins("[PN.load]", 1)
//		use_power(250) //uses APC power

/obj/machinery/shieldwallgen/attack_hand(mob/user)
	if(!anchored)
		to_chat(user, span_warning("The shield generator needs to be firmly secured to the floor first."))
		return 1
	if(locked && !issilicon(user))
		to_chat(user, span_warning("The controls are locked!"))
		return 1
	if(power != 1)
		to_chat(user, span_warning("The shield generator needs to be powered by wire underneath."))
		return 1

	if(active >= 1)
		active = 0
		update_icon(UPDATE_ICON_STATE)

		user.visible_message("[user] turned the shield generator off.", \
			"You turn off the shield generator.", \
			"You hear heavy droning fade out.")
		for(var/dir in list(NORTH, SOUTH, EAST, WEST))
			cleanup(dir)
	else
		active = 1
		update_icon(UPDATE_ICON_STATE)
		user.visible_message("[user] turned the shield generator on.", \
			"You turn on the shield generator.", \
			"You hear heavy droning.")
	add_fingerprint(user)

/obj/machinery/shieldwallgen/process()
	spawn(100)
		power()
		if(power)
			storedpower -= 50 //this way it can survive longer and survive at all
	if(storedpower >= maxstoredpower)
		storedpower = maxstoredpower
	if(storedpower <= 0)
		storedpower = 0

	if(active == 1)
		if(!anchored)
			active = 0
			return
		spawn(1)
			setup_field(1)
		spawn(2)
			setup_field(2)
		spawn(3)
			setup_field(4)
		spawn(4)
			setup_field(8)
		active = 2
	if(active >= 1)
		if(power == 0)
			visible_message(span_warning("The [name] shuts down due to lack of power!"), \
				"You hear heavy droning fade out")
			active = 0
			update_icon(UPDATE_ICON_STATE)
			for(var/dir in list(NORTH, SOUTH, EAST, WEST))
				cleanup(dir)

/obj/machinery/shieldwallgen/proc/setup_field(NSEW = 0)
	var/turf/T = loc
	var/turf/T2 = loc
	var/obj/machinery/shieldwallgen/G
	var/steps = 0
	var/oNSEW = 0

	if(!NSEW)//Make sure its ran right
		return

	if(NSEW == 1)
		oNSEW = 2
	else if(NSEW == 2)
		oNSEW = 1
	else if(NSEW == 4)
		oNSEW = 8
	else if(NSEW == 8)
		oNSEW = 4

	for(var/dist = 0, dist <= 9, dist += 1) // checks out to 8 tiles away for another generator
		T = get_step(T2, NSEW)
		T2 = T
		steps += 1
		if(locate(/obj/machinery/shieldwallgen) in T)
			G = (locate(/obj/machinery/shieldwallgen) in T)
			steps -= 1
			if(!G.active)
				return
			G.cleanup(oNSEW)
			break

	if(isnull(G))
		return

	T2 = loc

	for(var/dist = 0, dist < steps, dist += 1) // creates each field tile
		var/field_dir = get_dir(T2,get_step(T2, NSEW))
		T = get_step(T2, NSEW)
		T2 = T
		var/obj/machinery/shieldwall/CF = new/obj/machinery/shieldwall/(src, G) //(ref to this gen, ref to connected gen)
		CF.loc = T
		CF.dir = field_dir


/obj/machinery/shieldwallgen/wrench_act(mob/living/user, obj/item/I)
	. = TRUE
	if(active)
		to_chat(user, span_warning("Turn off the field generator first."))
		return .
	if(!I.use_tool(src, user, volume = I.tool_volume))
		return .
	set_anchored(!anchored)
	to_chat(user, "You [anchored ? "secure" : "loosen"] the external reinforcing bolts [anchored ? "to" : "from"] the floor.")


/obj/machinery/shieldwallgen/attackby(obj/item/I, mob/user, params)
	if(user.a_intent == INTENT_HARM)
		return ..()

	if(I.GetID() || is_pda(I))
		add_fingerprint(user)
		if(!allowed(user))
			to_chat(user, span_warning("Access denied."))
			return ATTACK_CHAIN_PROCEED
		locked = !locked
		to_chat(user, span_notice("Controls are now [locked ? "locked." : "unlocked."]"))
		return ATTACK_CHAIN_PROCEED_SUCCESS

	return ..()


/obj/machinery/shieldwallgen/proc/cleanup(NSEW)
	var/obj/machinery/shieldwall/F
	var/obj/machinery/shieldwallgen/G
	var/turf/T = loc
	var/turf/T2 = loc

	for(var/dist = 0, dist <= 9, dist += 1) // checks out to 8 tiles away for fields
		T = get_step(T2, NSEW)
		T2 = T
		if(locate(/obj/machinery/shieldwall) in T)
			F = (locate(/obj/machinery/shieldwall) in T)
			if(F.gen_primary == src || F.gen_secondary == src)
				qdel(F)

		if(locate(/obj/machinery/shieldwallgen) in T)
			G = (locate(/obj/machinery/shieldwallgen) in T)
			if(!G.active)
				break

/obj/machinery/shieldwallgen/Destroy()
	cleanup(1)
	cleanup(2)
	cleanup(4)
	cleanup(8)
	return ..()

/obj/machinery/shieldwallgen/bullet_act(obj/item/projectile/Proj)
	storedpower -= Proj.damage
	..()
	return


////////////// Containment Field START
/obj/machinery/shieldwall
	name = "Shield"
	desc = "An energy shield."
	icon = 'icons/effects/effects.dmi'
	icon_state = "shieldwall"
	anchored = TRUE
	density = TRUE
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | UNACIDABLE | ACID_PROOF
	light_range = 3
	var/needs_power = 0
	var/active = 1
	var/delay = 5
	var/last_active
	var/mob/U
	var/obj/machinery/shieldwallgen/gen_primary
	var/obj/machinery/shieldwallgen/gen_secondary

/obj/machinery/shieldwall/New(obj/machinery/shieldwallgen/A, obj/machinery/shieldwallgen/B)
	..()
	gen_primary = A
	gen_secondary = B
	if(A && B)
		needs_power = 1

/obj/machinery/shieldwall/attack_hand(mob/user)
	return

/obj/machinery/shieldwall/rpd_blocksusage()
	return TRUE

/obj/machinery/shieldwall/process()
	if(needs_power)
		if(isnull(gen_primary)||isnull(gen_secondary))
			qdel(src)
			return

		if(!(gen_primary.active)||!(gen_secondary.active))
			qdel(src)
			return

		if(prob(50))
			gen_primary.storedpower -= 10
		else
			gen_secondary.storedpower -=10


/obj/machinery/shieldwall/bullet_act(obj/item/projectile/Proj)
	if(needs_power)
		var/obj/machinery/shieldwallgen/G
		if(prob(50))
			G = gen_primary
		else
			G = gen_secondary
		G.storedpower -= Proj.damage
	..()
	return


/obj/machinery/shieldwall/ex_act(severity)
	if(needs_power)
		var/obj/machinery/shieldwallgen/G
		switch(severity)
			if(1.0) //big boom
				if(prob(50))
					G = gen_primary
				else
					G = gen_secondary
				G.storedpower -= 200

			if(2.0) //medium boom
				if(prob(50))
					G = gen_primary
				else
					G = gen_secondary
				G.storedpower -= 50

			if(3.0) //lil boom
				if(prob(50))
					G = gen_primary
				else
					G = gen_secondary
				G.storedpower -= 20
	return


/obj/machinery/shieldwall/CanAllowThrough(atom/movable/mover, border_dir)
	. = ..()
	if(checkpass(mover))
		return TRUE
	if(checkpass(mover, PASSGLASS))
		return prob(20)
	if(isprojectile(mover))
		return prob(10)


/obj/machinery/shieldwall/syndicate
	name = "energy shield"
	desc = "A strange energy shield."
	icon_state = "shield-red"


/obj/machinery/shieldwall/syndicate/CanAllowThrough(atom/movable/mover, border_dir)
	. = ..()
	if(checkpass(mover))
		return TRUE
	if(isliving(mover))
		var/mob/living/living_mover = mover
		if("syndicate" in living_mover.faction)
			return TRUE
	else if(isprojectile(mover))
		return FALSE


/obj/machinery/shieldwall/syndicate/CanAStarPass(to_dir, datum/can_pass_info/pass_info)
	if(pass_info.faction && ("syndicate" in pass_info.faction))
		return TRUE
	return ..()


/obj/machinery/shieldwall/syndicate/proc/phaseout()
	// If you're bumping into an invisible shield, make it fully visible, then fade out over a couple of seconds.
	if(alpha == 0)
		alpha = 255
		animate(src, alpha = 10, time = 20, easing = EASE_OUT)
		spawn(20)
			alpha = 0

/obj/machinery/shieldwall/syndicate/Bumped(atom/movable/moving_atom)
	phaseout()
	return ..()


/obj/machinery/shieldwall/syndicate/attackby(obj/item/I, mob/user, params)
	. = ..()
	if(!ATTACK_CHAIN_CANCEL_CHECK(.))
		phaseout()


/obj/machinery/shieldwall/syndicate/bullet_act(obj/item/projectile/Proj)
	phaseout()
	return ..()

/obj/machinery/shieldwall/syndicate/ex_act(severity)
	phaseout()
	return ..()

/obj/machinery/shieldwall/syndicate/emp_act(severity)
	phaseout()
	return ..()

/obj/machinery/shieldwall/syndicate/attack_hand(mob/user)
	phaseout()
	return ..()

/obj/machinery/shieldwall/syndicate/hitby(atom/movable/AM, skipcatch, hitpush, blocked, datum/thrownthing/throwingdatum)
	phaseout()
	return ..()
