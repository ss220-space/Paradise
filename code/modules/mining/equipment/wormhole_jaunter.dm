/**********************Jaunter**********************/
/obj/item/wormhole_jaunter
	name = "wormhole jaunter"
	desc = "Одноразовое устройство, использующее устаревшую технологию червоточин. НаноТрейзен переключилась на блюспейс для более точной телепортации. Перемещение через создаваемые им червоточины, мягко говоря, некомфортно.\nБлагодаря модификациям Свободных Големов, этот генератор червоточин обеспечивает защиту от пропастей."
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

/obj/item/wormhole_jaunter/get_ru_names()
	return list(
		NOMINATIVE = "генератор червоточин",
		GENITIVE = "генератора червоточин",
		DATIVE = "генератору червоточин",
		ACCUSATIVE = "генератор червоточин",
		INSTRUMENTAL = "генератором червоточин",
		PREPOSITIONAL = "генераторе червоточин"
	)

/obj/item/wormhole_jaunter/attack_self(mob/user)
	user.visible_message(span_notice("[user.name] активиру[pluralize_ru(user.gender,"ет","ют")] [declent_ru(ACCUSATIVE)]!"))
	SSblackbox.record_feedback("tally", "jaunter", 1, "User") // user activated
	activate(user, TRUE)


/obj/item/wormhole_jaunter/proc/turf_check()
	var/turf/device_turf = get_turf(src)

	if(!device_turf || !is_teleport_allowed(device_turf.z))
		return "Ошибка! Телепортация невозможна."

	if(!is_mining_level(device_turf.z) || istype(get_area(device_turf), /area/ruin/space/bubblegum_arena))
		return "Ошибка! Требуется натуральная гравитация для размещения якоря."

	return TRUE


/obj/item/wormhole_jaunter/proc/get_destinations()
	. = list()
	for(var/obj/item/radio/beacon/beacon in GLOB.global_radios)
		var/turf/beacon_turf = get_turf(beacon)
		if(is_station_level(beacon_turf.z))
			. += beacon


/obj/item/wormhole_jaunter/proc/activate(mob/user, adjacent, teleport)
	var/turf_check_result = turf_check()

	if(!istrue(turf_check_result))
		atom_say(turf_check_result)
		return FALSE

	var/list/destinations = get_destinations()
	if(!length(destinations))
		if(user)
			balloon_alert(user, "нет доступных маяков!")
		else
			visible_message(span_notice("[capitalize(declent_ru(NOMINATIVE))] не нашёл маяков для создания якоря!"))
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
		to_chat(user, span_notice("Ваш [declent_ru(NOMINATIVE)] активируется, спасая вас от пропасти!"))
		SSblackbox.record_feedback("tally", "jaunter", 1, "Chasm") // chasm automatic activation


/obj/item/wormhole_jaunter/emag_act(mob/user)
	if(!emagged)
		add_attack_logs(user, src, "emagged")
		emagged = TRUE
		if(user)
			balloon_alert(user, "протоколы защиты сняты!")
		var/turf/T = get_turf(src)
		do_sparks(5, FALSE, T)
		playsound(T, SFX_SPARKS, 50, TRUE, SHORT_RANGE_SOUND_EXTRARANGE)


/obj/effect/portal/jaunt_tunnel
	name = "jaunt tunnel"
	icon = 'icons/effects/effects.dmi'
	icon_state = "bhole3"
	desc = "Стабильная дыра во вселенной, созданная генератором червоточин. Слово \"турбулентный\" не передаёт, насколько жёстким может быть прохождение через неё, но по крайней мере она всегда доставит вас куда-то рядом с маяком."
	failchance = 0
	var/emagged = FALSE

/obj/effect/portal/jaunt_tunnel/get_ru_names()
	return list(
		NOMINATIVE = "стабильная червоточина",
		GENITIVE = "стабильной червоточины",
		DATIVE = "стабильной червоточине",
		ACCUSATIVE = "стабильную червоточину",
		INSTRUMENTAL = "стабильной червоточиной",
		PREPOSITIONAL = "стабильной червоточине"
	)

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
		playsound(M,'sound/weapons/resonator_blast.ogg', 50, TRUE)
		if(iscarbon(M))
			var/mob/living/carbon/L = M
			L.Weaken(12 SECONDS)
			if(ishuman(L))
				shake_camera(L, 20, 1)
				addtimer(CALLBACK(L, TYPE_PROC_REF(/mob/living/carbon, vomit)), 20)

/obj/item/grenade/jaunter_grenade
	name = "chasm jaunter recovery grenade"
	desc = "Граната \"НТ-Пьяный набор\". Первоначально созданная НаноТрейзен для поиска всех маяков в области и создания червоточин к ним, теперь используется шахтёрами для спасения коллег из пропастей."
	icon_state = "mirage"
	/// Mob that threw the grenade.
	var/mob/living/thrower

/obj/item/grenade/jaunter_grenade/get_ru_names()
	return list(
		NOMINATIVE = "граната спасения из пропасти",
		GENITIVE = "гранаты спасения из пропасти",
		DATIVE = "гранате спасения из пропасти",
		ACCUSATIVE = "гранату спасения из пропасти",
		INSTRUMENTAL = "гранатой спасения из пропасти",
		PREPOSITIONAL = "гранате спасения из пропасти"
	)

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

