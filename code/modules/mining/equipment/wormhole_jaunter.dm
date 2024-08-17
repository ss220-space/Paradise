/**********************Jaunter**********************/
/obj/item/wormhole_jaunter
	name = "wormhole jaunter"
	desc = "A single use device harnessing outdated wormhole technology, Nanotrasen has since turned its eyes to bluespace for more accurate teleportation. The wormholes it creates are unpleasant to travel through, to say the least.\nThanks to modifications provided by the Free Golems, this jaunter provides protection from chasms."
	icon = 'icons/obj/items.dmi'
	icon_state = "Jaunter"
	item_state = "electronic"
	throwforce = 0
	w_class = WEIGHT_CLASS_SMALL
	throw_speed = 3
	throw_range = 5
	origin_tech = "bluespace=2"
	slot_flags = ITEM_SLOT_BELT
	var/emagged = FALSE


/obj/item/wormhole_jaunter/attack_self(mob/user)
	user.visible_message(span_notice("[user.name] activates the [name]!"))
	SSblackbox.record_feedback("tally", "jaunter", 1, "User") // user activated
	activate(user, TRUE)


/obj/item/wormhole_jaunter/proc/turf_check(mob/user)
	var/turf/device_turf = get_turf(src)
	if(!device_turf || !is_teleport_allowed(device_turf.z))
		if(user)
			to_chat(user, span_notice("You're having difficulties getting [src] to work."))
		return FALSE
	return TRUE


/obj/item/wormhole_jaunter/proc/get_destinations()
	. = list()
	for(var/obj/item/radio/beacon/beacon in GLOB.global_radios)
		var/turf/beacon_turf = get_turf(beacon)
		if(is_station_level(beacon_turf.z))
			. += beacon


/obj/item/wormhole_jaunter/proc/activate(mob/user, adjacent, teleport)
	if(!turf_check(user))
		return FALSE

	var/list/destinations = get_destinations()
	if(!length(destinations))
		if(user)
			balloon_alert(user, "нет доступных маяков!")
		else
			visible_message(span_notice("\The [src] found no beacons in the world to anchor a wormhole to!"))
		return TRUE // used for chasm code

	var/chosen_beacon = pick(destinations)

	var/obj/effect/portal/jaunt_tunnel/tunnel = new(get_turf(src), get_turf(chosen_beacon), src, 100, user)
	tunnel.emagged = emagged
	if(teleport)
		tunnel.teleport(user)
	else if(adjacent)
		try_move_adjacent(tunnel)

	qdel(src)
	return FALSE // used for chasm code


/obj/item/wormhole_jaunter/proc/chasm_react(mob/user)
	. = activate(user, FALSE, TRUE)

	if(!.)
		to_chat(user, span_notice("Your [name] activates, saving you from the chasm!"))
		SSblackbox.record_feedback("tally", "jaunter", 1, "Chasm") // chasm automatic activation


/obj/item/wormhole_jaunter/emag_act(mob/user)
	if(!emagged)
		add_attack_logs(user, src, "emagged")
		emagged = TRUE
		if(user)
			balloon_alert(user, "протоколы защиты сняты!")
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


/obj/effect/portal/jaunt_tunnel/can_teleport(atom/movable/M, silent = FALSE)
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
	for(var/obj/item/radio/beacon/beacon in GLOB.global_radios)
		var/turf/beacon_turf = get_turf(beacon)
		if(is_station_level(beacon_turf.z))
			destinations += beacon_turf
	if(!length(destinations))
		return

	var/turf/our_turf = get_turf(src)
	if(!our_turf)
		return

	if(ischasm(our_turf))
		for(var/turf/simulated/floor/chasm/chasm in RANGE_TURFS(5, our_turf))
			var/obj/effect/abstract/chasm_storage/pool = locate() in chasm.contents
			if(!pool)
				continue
			var/found_mob = FALSE
			for(var/mob/fish in pool.contents)
				found_mob = TRUE
				pool.get_fish(fish)
				do_teleport(fish, pick(destinations))
			if(found_mob)
				new /obj/effect/temp_visual/thunderbolt(chasm) // visual feedback if it worked.
				playsound(src, 'sound/magic/lightningbolt.ogg', 100, TRUE)
		qdel(src)
		return

	var/list/portal_turfs = list()
	for(var/turf/turf as anything in circleviewturfs(our_turf, 3))
		if(!turf.density)
			portal_turfs += turf
	playsound(our_turf, 'sound/magic/lightningbolt.ogg', 100, TRUE)
	for(var/turf/drunk_dial as anything in shuffle(destinations))
		if(!length(portal_turfs))
			break
		var/drunken_opening = pick_n_take(portal_turfs)
		new /obj/effect/portal/jaunt_tunnel(drunken_opening, drunk_dial, src, 10 SECONDS, thrower)
		new /obj/effect/temp_visual/thunderbolt(drunken_opening)
	qdel(src)

