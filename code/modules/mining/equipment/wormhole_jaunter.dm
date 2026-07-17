/**********************Jaunter**********************/
/obj/item/wormhole_jaunter
	name = "wormhole jaunter"
	desc = "Одноразовое устройство, использующее устаревшую технологию червоточин. \"Нанотрейзен\" переключилась на блюспейс для более точной телепортации. Перемещение через создаваемые им червоточины, мягко говоря, некомфортно.\nБлагодаря модификациям Свободных Големов, этот генератор червоточин обеспечивает защиту от пропастей."
	icon_state = "Jaunter"
	item_state = "electronic"
	w_class = WEIGHT_CLASS_SMALL
	throw_speed = 3
	throw_range = 5
	origin_tech = "bluespace=2"
	slot_flags = ITEM_SLOT_BELT

/obj/item/wormhole_jaunter/get_ru_names()
	return alist(
		NOMINATIVE = "генератор червоточин",
		GENITIVE = "генератора червоточин",
		DATIVE = "генератору червоточин",
		ACCUSATIVE = "генератор червоточин",
		INSTRUMENTAL = "генератором червоточин",
		PREPOSITIONAL = "генераторе червоточин",
	)

/obj/item/wormhole_jaunter/attack_self(mob/user)
	user.visible_message(span_notice("[user.name] активиру[PLUR_ET_YUT(user)] [declent_ru(ACCUSATIVE)]!"))
	SSblackbox.record_feedback("tally", "jaunter", 1, "User") // user activated
	activate(user, TRUE)

/obj/item/wormhole_jaunter/proc/turf_check()
	var/turf/device_turf = get_turf(src)

	if(!device_turf || !is_teleport_allowed(device_turf.z))
		return "Ошибка! Телепортация невозможна."

	return TRUE

/obj/item/wormhole_jaunter/proc/get_destinations()
	. = list()
	for(var/obj/item/beacon/beacon as anything in GLOB.beacons)
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
			visible_message(span_notice("[DECLENT_RU_CAP(src, NOMINATIVE)] не нашёл маяков для создания якоря!"))
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
		var/turf/our_turf = get_turf(src)
		do_sparks(5, FALSE, our_turf)
		playsound(our_turf, SFX_SPARKS, 50, TRUE, SHORT_RANGE_SOUND_EXTRARANGE)

/obj/effect/portal/jaunt_tunnel
	name = "jaunt tunnel"
	icon = 'icons/effects/effects.dmi'
	icon_state = "bhole3"
	desc = "Стабильная дыра во вселенной, созданная генератором червоточин. Слово \"турбулентный\" не передаёт, насколько жёстким может быть прохождение через неё, но по крайней мере она всегда доставит вас куда-то рядом с маяком."
	failchance = 0
	light_on = FALSE

/obj/effect/portal/jaunt_tunnel/get_ru_names()
	return alist(
		NOMINATIVE = "стабильная червоточина",
		GENITIVE = "стабильной червоточины",
		DATIVE = "стабильной червоточине",
		ACCUSATIVE = "стабильную червоточину",
		INSTRUMENTAL = "стабильной червоточиной",
		PREPOSITIONAL = "стабильной червоточине",
	)

/obj/effect/portal/jaunt_tunnel/update_overlays()
	. = list()	// we need no mask here

/obj/effect/portal/jaunt_tunnel/can_teleport(atom/movable/movable, silent = FALSE)
	if(!emagged && ismegafauna(movable))
		return FALSE
	return ..()

/obj/effect/portal/jaunt_tunnel/teleport(atom/movable/movable)
	. = ..()
	if(!.)
		return .
	playsound(movable, 'sound/weapons/resonator_blast.ogg', 50, TRUE)

	if(!iscarbon(movable))
		return

	var/mob/living/carbon/living_target = movable
	if(ishuman(living_target)) //we need to check this first, because after weaken all held items will be dropped
		handle_clothing_destruction(living_target)
	living_target.Weaken(12 SECONDS)

	if(!ishuman(living_target))
		return

	shake_camera(living_target, 20, 1)
	addtimer(CALLBACK(living_target, TYPE_PROC_REF(/mob/living/carbon, vomit)), 2 SECONDS)

/obj/effect/portal/jaunt_tunnel/proc/handle_clothing_destruction(mob/living/carbon/human/our_human)
	if(!ishuman(our_human))
		return

	var/list/possible_clothings = list()
	var/obj/item/suit_item = our_human.s_store
	if(suit_item && !(suit_item.item_flags & ABSTRACT))
		possible_clothings += suit_item
	var/obj/item/backpack = our_human.back
	if(backpack && !(backpack.item_flags & ABSTRACT))
		possible_clothings += backpack
	var/obj/item/under = our_human.w_uniform
	if(under && !(under.item_flags & ABSTRACT))
		possible_clothings += under

	// The "we really need held_items() proc" code block
	var/obj/item/hand_item = our_human.l_hand
	if(hand_item && !(hand_item.item_flags & ABSTRACT))
		possible_clothings += hand_item
	var/obj/item/second_hand_item = our_human.r_hand
	if(second_hand_item && !(second_hand_item.item_flags & ABSTRACT))
		possible_clothings += second_hand_item

	if(!length(possible_clothings))
		return

	var/obj/item/picked_item = pick(possible_clothings)
	if(picked_item.resistance_flags & FIRE_PROOF || picked_item.resistance_flags & LAVA_PROOF)
		return
	our_human.temporarily_remove_item_from_inventory(picked_item)
	to_chat(our_human, span_warning("[DECLENT_RU_CAP(picked_item, NOMINATIVE)] не выдерживает температуры и разрушается!"))
	qdel(picked_item)

/obj/item/grenade/jaunter_grenade
	name = "chasm jaunter recovery grenade"
	desc = "Граната \"НТ-Пьяный набор\". Первоначально созданная \"Нанотрейзен\" для поиска всех маяков в области и создания червоточин к ним, теперь используется шахтёрами для спасения коллег из пропастей."
	icon_state = "mirage"
	/// Mob that threw the grenade.
	var/mob/living/thrower

/obj/item/grenade/jaunter_grenade/get_ru_names()
	return alist(
		NOMINATIVE = "граната спасения из пропасти",
		GENITIVE = "гранаты спасения из пропасти",
		DATIVE = "гранате спасения из пропасти",
		ACCUSATIVE = "гранату спасения из пропасти",
		INSTRUMENTAL = "гранатой спасения из пропасти",
		PREPOSITIONAL = "гранате спасения из пропасти",
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
	for(var/obj/item/beacon/beacon as anything in GLOB.beacons)
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
	for(var/turf/turf as anything in circle_view_turfs(our_turf, 3))
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

