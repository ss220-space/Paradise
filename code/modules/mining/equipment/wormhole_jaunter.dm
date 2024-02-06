/**********************Jaunter**********************/
/obj/item/wormhole_jaunter
	name = "wormhole jaunter"
	desc = "A single use device harnessing outdated wormhole technology, Nanotrasen has since turned its eyes to bluespace for more accurate teleportation. The wormholes it creates are unpleasant to travel through, to say the least.\nThanks to modifications provided by the Free Golems, this jaunter can be worn on the belt to provide protection from chasms."
	icon = 'icons/obj/items.dmi'
	icon_state = "Jaunter"
	item_state = "electronic"
	throwforce = 0
	w_class = WEIGHT_CLASS_SMALL
	throw_speed = 3
	throw_range = 5
	origin_tech = "bluespace=2"
	slot_flags = SLOT_BELT
	var/emagged = FALSE

/obj/item/wormhole_jaunter/attack_self(mob/user)
	user.visible_message("<span class='notice'>[user.name] activates the [name]!</span>")
	activate(user, TRUE)

/obj/item/wormhole_jaunter/proc/turf_check(mob/user)
	var/turf/device_turf = get_turf(user)
	if(!device_turf || !is_teleport_allowed(device_turf.z))
		to_chat(user, "<span class='notice'>You're having difficulties getting the [name] to work.</span>")
		return FALSE
	return TRUE

/obj/item/wormhole_jaunter/proc/get_destinations(mob/user)
	var/list/destinations = list()

	for(var/obj/item/radio/beacon/B in GLOB.global_radios)
		var/turf/T = get_turf(B)
		if(is_station_level(T.z))
			destinations += B

	return destinations

/obj/item/wormhole_jaunter/proc/activate(mob/user, adjacent)
	if(!turf_check(user))
		return

	var/list/L = get_destinations(user)
	if(!L.len)
		to_chat(user, "<span class='notice'>The [name] found no beacons in the world to anchor a wormhole to.</span>")
		return
	var/chosen_beacon = pick(L)
	var/obj/effect/portal/jaunt_tunnel/J = new(get_turf(src), get_turf(chosen_beacon), src, 100, user)
	J.emagged = emagged
	if(adjacent)
		try_move_adjacent(J)
	else
		J.teleport(user)
	playsound(src,'sound/effects/sparks4.ogg',50,1)
	qdel(src)

/obj/item/wormhole_jaunter/proc/chasm_react(mob/user)
	if(user.get_item_by_slot(slot_belt) == src)
		to_chat(user, "Your [name] activates, saving you from the chasm!</span>")
		activate(user, FALSE)
	else
		to_chat(user, "[src] is not attached to your belt, preventing it from saving you from the chasm. RIP.</span>")

/obj/item/wormhole_jaunter/emag_act(mob/user)
	if(!emagged)
		add_attack_logs(user, src, "emagged")
		emagged = TRUE
		if(user)
			to_chat(user, "<span class='notice'>You emag [src].</span>")
		var/turf/T = get_turf(src)
		do_sparks(5, 0, T)
		playsound(T, "sparks", 50, TRUE, SHORT_RANGE_SOUND_EXTRARANGE)

/obj/effect/portal/jaunt_tunnel
	name = "jaunt tunnel"
	icon = 'icons/effects/effects.dmi'
	icon_state = "bhole3"
	desc = "A stable hole in the universe made by a wormhole jaunter. Turbulent doesn't even begin to describe how rough passage through one of these is, but at least it will always get you somewhere near a beacon."
	failchance = 0
	var/emagged = FALSE


/obj/effect/portal/jaunt_tunnel/update_overlays()
	. = list()	// we need no mask here


/obj/effect/portal/jaunt_tunnel/can_teleport(atom/movable/M)
	if(!emagged && ismegafauna(M))
		return FALSE
	return ..()

/obj/effect/portal/jaunt_tunnel/teleport(atom/movable/M)
	. = ..()
	if(.)
		// KERPLUNK
		playsound(M,'sound/weapons/resonator_blast.ogg', 50, 1)
		if(iscarbon(M))
			var/mob/living/carbon/L = M
			L.Weaken(12 SECONDS)
			if(ishuman(L))
				shake_camera(L, 20, 1)
				addtimer(CALLBACK(L, TYPE_PROC_REF(/mob/living/carbon, vomit)), 20)

/obj/item/grenade/jaunter_grenade
	name = "chasm jaunter recovery grenade"
	desc = "NT-Drunk Dialer Grenade. Originally built by NT for locating all beacons in an area and creating wormholes to them, it now finds use to miners for recovering allies from chasms."
	icon_state = "mirage"
	/// Mob that threw the grenade.
	var/mob/living/thrower

/obj/item/grenade/jaunter_grenade/Destroy()
	thrower = null
	return ..()

/obj/item/grenade/jaunter_grenade/attack_self(mob/user)
	. = ..()
	thrower = user

/obj/item/grenade/jaunter_grenade/prime()
	update_mob()
	var/list/destinations = list()
	for(var/obj/item/radio/beacon/B in GLOB.global_radios)
		var/turf/BT = get_turf(B)
		if(is_station_level(BT.z))
			destinations += BT
	var/turf/T = get_turf(src)
	if(istype(T, /turf/simulated/floor/chasm/straight_down/lava_land_surface))
		for(var/obj/effect/abstract/chasm_storage/C in T)
			var/found_mob = FALSE
			for(var/mob/M in C)
				found_mob = TRUE
				do_teleport(M, pick(destinations))
			if(found_mob)
				new /obj/effect/temp_visual/thunderbolt(T) //Visual feedback it worked.
				playsound(src, 'sound/magic/lightningbolt.ogg', 100, TRUE)
		qdel(src)
	else
		var/list/portal_turfs = list()
		for(var/turf/PT in circleviewturfs(T, 3))
			if(!PT.density)
				portal_turfs += PT
		playsound(src, 'sound/magic/lightningbolt.ogg', 100, TRUE)
		for(var/turf/drunk_dial in shuffle(destinations))
			var/drunken_opening = pick_n_take(portal_turfs)
			new /obj/effect/portal/jaunt_tunnel(drunken_opening, drunk_dial, src, 100, thrower)
			new /obj/effect/temp_visual/thunderbolt(drunken_opening)
		qdel(src)

