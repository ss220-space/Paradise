GLOBAL_VAR_INIT(curse_dial, TRUE)
GLOBAL_VAR_INIT(curse_upper, TRUE)
GLOBAL_VAR_INIT(curse_lower, TRUE)
GLOBAL_DATUM(Heart, /obj/structure/clockwork/functional/heart)

/obj/structure/clockwork/functional/heart
	name = "The heart of Ratvar"
	ru_names = list(
		NOMINATIVE = "Сердце Ратвара",
		GENITIVE = "Сердца Ратвара",
		DATIVE = "Сердцу Ратвара",
		ACCUSATIVE = "Сердце Ратвара",
		INSTRUMENTAL = "Сердцем Ратвара",
		PREPOSITIONAL = "Сердце Ратвара",
	)
	desc = "Огромный механизм из латуни, напоминающий сердце. От его громкого тиканья у вас начинает болеть голова..."
	icon = 'icons/obj/clockheart.dmi'
	icon_state = "heart"
	pixel_x = -32
	pixel_y = -32
	layer = ABOVE_ALL_MOB_LAYER
	var/list/obj/structure/fillers = list()
	var/pulse_range = 3
	mouse_drag_pointer = MOUSE_DROP_POINTER
	var/cur_enchant = null
	var/list/enchants
	var/list/blessings = list(/obj/item/gun/energy/clockwork, /obj/item/gun/energy/clockwork/sniper)
	var/list/enchanted_before = FALSE

/obj/structure/clockwork/functional/heart/Initialize(mapload)
	if(!GLOB.Heart)
		GLOB.Heart = src
	enchants = GLOB.heart_pulses
	alpha = 0
	new /obj/effect/temp_visual/ratvar/reconstruct/heart(loc)
	update_icon(UPDATE_OVERLAYS)
	alpha = 255
	throw_everything_back()
	var/list/occupied = list()
	for(var/direct in list(NORTHWEST,NORTH,NORTHEAST,EAST,SOUTHEAST,SOUTH,SOUTHWEST,WEST))
		occupied += get_step(src,direct)

	for(var/T in occupied)
		var/obj/structure/heart_filler/F = new(T)
		F.parent = src
		fillers += F
	spawn_parts()
	. = ..()

/obj/structure/clockwork/functional/heart/update_overlays()
	.=..()
	if(GLOB.curse_dial)
		. += "[icon_state]_dialcurse"
	else
		. -= "[icon_state]_dialcurse"
	if(GLOB.curse_upper)
		. += "[icon_state]_curse_upper"
	else
		. -= "[icon_state]_curse_upper"

	if(GLOB.curse_lower)
		. += "[icon_state]_curse_lower"
	else
		. -= "[icon_state]_curse_lower"
	if(cur_enchant)
		.+= "heart_overlay_[cur_enchant]"
	else
		if("heart_overlay_[cur_enchant]" in overlays && !cur_enchant)
			remove_persistent_overlay("heart_overlay_[cur_enchant]")

/obj/structure/clockwork/functional/heart/proc/heart_pulse()
	if(!GLOB.curse_dial)
		enchanted_before = TRUE
		switch(cur_enchant)
			if(EMP_HEART_PULSE)
				new /obj/effect/temp_visual/ratvar/reconstruct/heart_pulse/emp(loc, pulse_range)
			if(HEAL_HEART_PULSE)
				new /obj/effect/temp_visual/ratvar/reconstruct/heart_pulse/heal(loc, pulse_range)
			if(STUN_HEART_PULSE)
				new /obj/effect/temp_visual/ratvar/reconstruct/heart_pulse/stun(loc, pulse_range)
			else
				new /obj/effect/temp_visual/ratvar/reconstruct/heart_pulse(loc, pulse_range)
				enchanted_before = FALSE
		new /obj/effect/temp_visual/pulse(src.loc)
		new /obj/effect/warp_effect/heart(loc)
		cur_enchant = null
		pulse_range += 2
	update_icon(UPDATE_OVERLAYS)
	return


/obj/structure/clockwork/functional/heart/Destroy(force)
	for(var/turf/tile in orange(1, src))
		new /obj/effect/gibspawner/clock(tile)
	playsound(src, 'sound/effects/forge_destroy.ogg', 50, TRUE)
	GLOB.Heart = null
	QDEL_LIST(fillers)
	. = ..()

/obj/structure/clockwork/functional/heart/MouseDrop_T(atom/movable/dropping, mob/user, params)
	if(!isclocker(user))
		return
	if(istype(dropping, /obj/structure/part1))
		if(GLOB.curse_dial)
			if(do_after(user, 5 SECONDS, src))
				GLOB.curse_dial = FALSE
				addtimer(CALLBACK(src, PROC_REF(heart_pulse)), 30 SECONDS, TIMER_LOOP | TIMER_DELETE_ME)
				addtimer(CALLBACK(GLOBAL_PROC, GLOBAL_PROC_REF(playsound), src, 'sound/magic/clockwork/heart_tick_tock.ogg', 100, FALSE, 0, SOUND_FALLOFF_EXPONENT, null, 0, TRUE, TRUE, SOUND_DEFAULT_FALLOFF_DISTANCE, TRUE), 4 SECONDS, TIMER_LOOP | TIMER_DELETE_ME)
				qdel(dropping)
				give_blessing(user)
				update_icon(UPDATE_OVERLAYS)

/obj/structure/clockwork/functional/heart/attackby(obj/item/I, mob/user, params)
	if(istype(I, /obj/item/part2))
		if(GLOB.curse_upper)
			if(do_after(user, 5 SECONDS, src))
				GLOB.curse_upper = FALSE
				qdel(I)
				update_icon(UPDATE_OVERLAYS)
				give_blessing(user)
				return
	if(istype(I, /obj/item/part3))
		if(GLOB.curse_lower)
			if(do_after(user, 5 SECONDS, src))
				GLOB.curse_lower = FALSE
				qdel(I)
				update_icon(UPDATE_OVERLAYS)
				give_blessing(user)
				return
	if(istype(I, /obj/item/clockwork/shard))
		var/datum/game_mode/gamemode = SSticker.mode
		if(GLOB.curse_dial || GLOB.curse_lower || GLOB.curse_lower)
			to_chat(user, span_clocklarge("Сердце слишком слабо! Сначало снимите печати!"))
			return
		if(gamemode.clocker_objs.clock_status < RATVAR_NEEDS_SUMMONING)
			to_chat(user, span_clocklarge("Еще слишком рано, Сын мой..."))
			return
		if(GLOB.clockwork_power < 250)
			to_chat(user, span_clocklarge("Вам не хватает энергии!"))
			return
		adjust_clockwork_power(-250)
		visible_message(span_danger("[capitalize(src)] исчезает, и на его месте появляется Великий Ковчег!"))
		var/area/A = get_area(src)
		GLOB.major_announcement.announce("Была обнаружена аномально высокая концентрация энергии в [A.map_name]. Источник энергии указывает на попытку вызвать потустороннего бога по имени Ратвар. Сорвите ритуал любой ценой, пока станция не была уничтожена! Действие космического закона и стандартных рабочих процедур приостановлено. Весь экипаж должен уничтожать культистов на месте.",
										ANNOUNCE_CCPARANORMAL_RU,
										'sound/AI/commandreport.ogg')
		new /obj/structure/clockwork/functional/celestial_gateway(get_turf(src))
		qdel(src)
		return
	. = ..()

/obj/structure/clockwork/functional/heart/proc/throw_everything_back()
	//just like in survival_pod.dm
	var/width = 3
	var/height = 3
	var/base_x_throw_distance = ceil(width / 2)
	var/base_y_throw_distance = ceil(height / 2)
	for(var/mob/living/did_not_stand_back in range(loc, "[width]x[height]"))
		var/dir_to_center = get_dir(src.loc, did_not_stand_back) || pick(GLOB.alldirs)
		var/throw_dist = 0
		var/x_component = abs(did_not_stand_back.x - src.loc.x)
		var/y_component = abs(did_not_stand_back.y - src.loc.y)
		if(ISDIAGONALDIR(dir_to_center))
			throw_dist = ceil(sqrt(base_x_throw_distance ** 2 + base_y_throw_distance ** 2) - (sqrt(x_component ** 2 + y_component ** 2)))
			did_not_stand_back.forceMove(get_ranged_target_turf(src.loc, dir_to_center, throw_dist))
		else if(dir_to_center & (NORTH|SOUTH))
			throw_dist = base_y_throw_distance - y_component + 1
			did_not_stand_back.forceMove(get_ranged_target_turf(src.loc, dir_to_center, base_y_throw_distance))
		else if(dir_to_center & (EAST|WEST))
			throw_dist = base_x_throw_distance - x_component + 1
			did_not_stand_back.forceMove(get_ranged_target_turf(src.loc, dir_to_center, base_x_throw_distance))
		did_not_stand_back.Knockdown(6 SECONDS)
		did_not_stand_back.throw_at(
			target = get_edge_target_turf(did_not_stand_back, dir_to_center),
			range = throw_dist,
			speed = 3,
			force = MOVE_FORCE_VERY_STRONG,
		)
	for(var/obj/item/item_in_range in range(loc, "[width]x[height]"))
		var/dir_to_center = get_dir(src.loc, item_in_range) || pick(GLOB.alldirs)
		var/throw_dist = 0
		var/x_component = abs(item_in_range.x - src.loc.x)
		var/y_component = abs(item_in_range.y - src.loc.y)
		if(ISDIAGONALDIR(dir_to_center))
			throw_dist = ceil(sqrt(base_x_throw_distance ** 2 + base_y_throw_distance ** 2) - (sqrt(x_component ** 2 + y_component ** 2)))
			item_in_range.forceMove(get_ranged_target_turf(src.loc, dir_to_center, throw_dist))
		else if(dir_to_center & (NORTH|SOUTH))
			throw_dist = base_y_throw_distance - y_component + 1
			item_in_range.forceMove(get_ranged_target_turf(src.loc, dir_to_center, base_y_throw_distance))
		else if(dir_to_center & (EAST|WEST))
			throw_dist = base_x_throw_distance - x_component + 1
			item_in_range.forceMove(get_ranged_target_turf(src.loc, dir_to_center, base_x_throw_distance))
		item_in_range.throw_at(
			target = get_edge_target_turf(item_in_range, dir_to_center),
			range = throw_dist,
			speed = 3,
			force = MOVE_FORCE_VERY_STRONG,
		)

/obj/structure/clockwork/functional/heart/proc/give_blessing(mob/living/user)
	if(isnull(blessings))
		return
	var/chosen_blessing = pick(blessings)
	var/bless_to_give = new chosen_blessing(user.loc)
	user.put_in_hands(bless_to_give)
	LAZYREMOVE(blessings, chosen_blessing)
	chosen_blessing = null
	bless_to_give = null

/obj/structure/clockwork/functional/heart/proc/spawn_parts()
	var/first_part_loc = get_safe_random_station_turf()
	var/second_part_loc = get_safe_random_station_turf()
	var/third_part_loc = get_safe_random_station_turf()
	new /obj/structure/part1(first_part_loc)
	new /obj/item/part2(second_part_loc)
	new /obj/item/part3(third_part_loc)

/obj/structure/heart_filler
	name = "The heart of Ratvar"
	ru_names = list(
		NOMINATIVE = "Сердце Ратвара",
		GENITIVE = "Сердца Ратвара",
		DATIVE = "Сердцу Ратвара",
		ACCUSATIVE = "Сердце Ратвара",
		INSTRUMENTAL = "Сердцем Ратвара",
		PREPOSITIONAL = "Сердце Ратвара",
	)
	desc = "Огромный механизм из латуни, напоминающий сердце. От его громкого тиканья у вас начинает болеть голова..."
	density = TRUE
	anchored = TRUE
	smoothing_groups = SMOOTH_GROUP_FILLER
	var/obj/machinery/parent
	icon = 'icons/effects/blood.dmi'
	icon_state =  "thisisfuckingstupid"
	alpha = 1
	mouse_drag_pointer = MOUSE_DROP_POINTER
	plane = ABOVE_GAME_PLANE

/obj/structure/heart_filler/Destroy()
	parent = null
	return ..()

/obj/structure/heart_filler/ex_act()
	return

/obj/structure/heart_filler/attack_hand(mob/living/user)
	parent.attack_hand(user)

/obj/structure/heart_filler/take_damage(damage_amount, damage_type, damage_flag, sound_effect, attack_dir, armour_penetration)
	parent.take_damage(damage_amount, damage_type, damage_flag, sound_effect, attack_dir, armour_penetration)

/obj/structure/heart_filler/MouseDrop_T(atom/movable/dropping, mob/user, params)
	parent.MouseDrop_T(dropping, user, params)

/obj/structure/heart_filler/attackby(obj/item/I, mob/user, params)
	parent.attackby(I, user, params)

/obj/structure/part1
	name = "big brass dial"
	ru_names = list(
		NOMINATIVE = "большой латунный циферблат",
		GENITIVE = "большого латунного циферблата",
		DATIVE = "большому латунному циферблату",
		ACCUSATIVE = "большой латунный циферблат",
		INSTRUMENTAL = "большим латунным циферблатом",
		PREPOSITIONAL = "большом латунном циферблате",
	)
	desc = "Большой циферблат из латуни."
	icon ='icons/obj/clockwork.dmi'
	icon_state = "ratvarpart1"
	density = TRUE
	resistance_flags = INDESTRUCTIBLE
	mouse_drag_pointer = MOUSE_DRAG_POINTER

/obj/structure/part1/Bumped(atom/movable/moving_atom)
	if(!ismob(moving_atom))
		. = ..()
	var/mob/dragger = moving_atom
	if(isclocker(dragger))
		anchored = FALSE
		. = ..()
		return
	anchored = TRUE
	to_chat(dragger, span_clockitalic("Вы пытаетесь толкнуть циферблат, но его что-то удерживает!"))
	return

/obj/structure/part1/CtrlClick(mob/user)
	if(isclocker(user))
		anchored = FALSE
		. = ..()
		return
	if(user in orange(1, src))
		if(ishuman(user))
			to_chat(user, span_userdanger("Вы попытались потянуть циферблат, но ваша рука обратилась в пепел!"))
			var/obj/item/organ/external/limb_to_burn = user.get_organ((user.hand == ACTIVE_HAND_LEFT) ? BODY_ZONE_PRECISE_L_HAND : BODY_ZONE_PRECISE_R_HAND)
			limb_to_burn.droplimb(TRUE, DROPLIMB_BURN)
			new /obj/effect/decal/cleanable/ash(user.loc)
		else
			to_chat(user, span_clockitalic("Вы пытаетесь схватить циферблат, но он слишком тяжелый!"))
	return

/obj/structure/part1/New()
	addtimer(CALLBACK(src, PROC_REF(pulse)), 10 SECONDS, TIMER_LOOP | TIMER_DELETE_ME)
	. = ..()

/obj/structure/part1/proc/pulse()
	new /obj/effect/temp_visual/ratvar/reconstruct/part(src.loc)

/obj/item/part2
	name = "brass component"
	ru_names = list(
		NOMINATIVE = "латунная деталь",
		GENITIVE = "латунной детали",
		DATIVE = "латунной детали",
		ACCUSATIVE = "латунную деталь",
		INSTRUMENTAL = "латунной деталью",
		PREPOSITIONAL = "латунной детали",
	)
	desc = "Странная деталь из латуни."
	icon ='icons/obj/clockwork.dmi'
	icon_state = "ratvarpart2"
	item_state = "ratvarpart2"
	resistance_flags = INDESTRUCTIBLE
	mouse_drag_pointer = MOUSE_DRAG_POINTER
	w_class = WEIGHT_CLASS_BULKY
	lefthand_file = 'icons/mob/inhands/items_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/items_righthand.dmi'

/obj/item/part2/CtrlClick(mob/user)
	if(isclocker(user))
		. = ..()
		return
	if(user in orange(1, src))
		if(ishuman(user))
			to_chat(user, span_userdanger("Вы попытались потянуть деталь, но ваша рука обратилась в пепел!"))
			var/obj/item/organ/external/limb_to_burn = user.get_organ((user.hand == ACTIVE_HAND_LEFT) ? BODY_ZONE_PRECISE_L_HAND : BODY_ZONE_PRECISE_R_HAND)
			limb_to_burn.droplimb(TRUE, DROPLIMB_BURN)
			new /obj/effect/decal/cleanable/ash(user.loc)
		else
			to_chat(user, span_clockitalic("Вы пытаетесь схватить деталь, но она слишком тяжелая!"))
	return

/obj/item/part2/attack_hand(mob/user, pickupfireoverride)
	if(isclocker(user))
		. = ..()
		return
	if(user in orange(1, src))
		if(ishuman(user))
			to_chat(user, span_userdanger("Вы попытались поднять деталь, но ваша рука обратилась в пепел!"))
			var/obj/item/organ/external/limb_to_burn = user.get_organ((user.hand == ACTIVE_HAND_LEFT) ? BODY_ZONE_PRECISE_L_HAND : BODY_ZONE_PRECISE_R_HAND)
			limb_to_burn.droplimb(TRUE, DROPLIMB_BURN)
			new /obj/effect/decal/cleanable/ash(user.loc)
	return

/obj/item/part2/New()
	addtimer(CALLBACK(src, PROC_REF(pulse)), 10 SECONDS, TIMER_LOOP | TIMER_DELETE_ME)
	. = ..()


/obj/item/part2/proc/pulse()
	new /obj/effect/temp_visual/ratvar/reconstruct/part(src.loc)

/obj/item/part3
	name = "brass component"
	ru_names = list(
		NOMINATIVE = "латунная деталь",
		GENITIVE = "латунной детали",
		DATIVE = "латунной детали",
		ACCUSATIVE = "латунную деталь",
		INSTRUMENTAL = "латунной деталью",
		PREPOSITIONAL = "латунной детали",
	)
	desc = "Странная деталь из латуни."
	icon ='icons/obj/clockwork.dmi'
	icon_state = "ratvarpart3"
	item_state = "ratvarpart3"
	resistance_flags = INDESTRUCTIBLE
	mouse_drag_pointer = MOUSE_DRAG_POINTER
	w_class = WEIGHT_CLASS_BULKY
	lefthand_file = 'icons/mob/inhands/items_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/items_righthand.dmi'

/obj/item/part3/CtrlClick(mob/user)
	if(isclocker(user))
		. = ..()
		return
	if(user in orange(1, src))
		if(ishuman(user))
			to_chat(user, span_userdanger("Вы попытались потянуть деталь, но ваша рука обратилась в пепел!"))
			var/obj/item/organ/external/limb_to_burn = user.get_organ((user.hand == ACTIVE_HAND_LEFT) ? BODY_ZONE_PRECISE_L_HAND : BODY_ZONE_PRECISE_R_HAND)
			limb_to_burn.droplimb(TRUE, DROPLIMB_BURN)
			new /obj/effect/decal/cleanable/ash(user.loc)
		else
			to_chat(user, span_clockitalic("Вы пытаетесь схватить деталь, но она слишком тяжелая!"))
	return

/obj/item/part3/attack_hand(mob/user, pickupfireoverride)
	if(isclocker(user))
		. = ..()
		return
	if(user in orange(1, src))
		if(ishuman(user))
			to_chat(user, span_userdanger("Вы попытались поднять деталь, но ваша рука обратилась в пепел!"))
			var/obj/item/organ/external/limb_to_burn = user.get_organ((user.hand == ACTIVE_HAND_LEFT) ? BODY_ZONE_PRECISE_L_HAND : BODY_ZONE_PRECISE_R_HAND)
			limb_to_burn.droplimb(TRUE, DROPLIMB_BURN)
			new /obj/effect/decal/cleanable/ash(user.loc)
	return

/obj/item/part3/New()
	addtimer(CALLBACK(src, PROC_REF(pulse)), 10 SECONDS, TIMER_LOOP | TIMER_DELETE_ME)
	. = ..()

/obj/item/part3/proc/pulse()
	new /obj/effect/temp_visual/ratvar/reconstruct/part(src.loc)

/obj/effect/temp_visual/pulse
	icon = 'icons/obj/clockheart.dmi'
	icon_state = "pulse"
	pixel_x = -32
	pixel_y = -32
	layer = SPACEVINE_LAYER
	duration = 4
