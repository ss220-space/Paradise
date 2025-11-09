GLOBAL_VAR_INIT(total_curses, 3)
GLOBAL_DATUM(heart, /obj/structure/clockwork/functional/heart)

/obj/structure/clockwork/functional/heart
	name = "The Heart of Ratvar"
	desc = "Огромный механизм из латуни, напоминающий сердце. От его громкого тиканья у вас начинает болеть голова..."
	icon = 'icons/obj/clockheart.dmi'
	icon_state = "heart"
	pixel_x = -32
	pixel_y = -32
	layer = ABOVE_ALL_MOB_LAYER
	max_integrity = 3000
	var/list/obj/structure/fillers = list()
	var/pulse_range = 3
	mouse_drag_pointer = MOUSE_DROP_POINTER
	var/cur_enchant = null
	var/list/enchants
	var/list/blessings = list(/obj/item/gun/energy/clockwork, /obj/item/gun/energy/clockwork/sniper)
	var/list/enchanted_before = FALSE
	var/curse_dial = TRUE
	var/curse_upper = TRUE
	var/curse_lower = TRUE
	var/list/spawned_parts = list()
	var/summoning = FALSE
	var/summon_stage = 0
	var/obj/structure/clockwork/functional/celestial_gateway/gateway

/obj/structure/clockwork/functional/heart/examine(mob/user)
	. = ..()
	. += ""
	if(GLOB.total_curses > 0)
		var/list/cursed_text = get_cursed_text()
		var/list/adv_cursed_text = get_adv_cursed_text()
		if(isclocker(user) || isobserver(user) || iscultist(user))
			for(var/text in adv_cursed_text)
				. += span_cultitalic(text)
		else
			for(var/text in cursed_text)
				. += span_cultitalic(text)

	if(!summoning)
		return

	if(isclocker(user) || isobserver(user))
		switch(summon_stage)
			if(1)
				. += span_clockitalic("Сердце высвобождает энергию в блюспейс пространство.")
			if(2)
				. += span_clockitalic("Сердце открывает портал в тюрьму Ратвара.")
			if(3)
				. += span_clockitalic("Портал установлен, Ратвар вот-вот вернет себе сердце!")
	else
		switch(summon_stage)
			if(1)
				. += span_warning("От сердца исходит странная энергия.")
			if(2)
				. += span_warning("Вам кажется, что вы видите что-то в отражении на блестящем корпусе сердца.")
			if(3)
				. += span_boldwarning("Сердце вот-вот пройдет через блюспейс портал!")

/obj/structure/clockwork/functional/heart/proc/get_cursed_text()
	var/list/cursed_parts = list()
	if(curse_dial)
		cursed_parts += "Циферблат сердца покрыт странным барьером!"
	if(curse_upper)
		cursed_parts += "Верхняя часть сердца покрыта странным барьером!"
	if(curse_lower)
		cursed_parts += "Нижняя часть сердца покрыта странным барьером!"
	return cursed_parts

/obj/structure/clockwork/functional/heart/proc/get_adv_cursed_text()
	var/list/cursed_parts = list()
	if(curse_dial)
		cursed_parts += "Циферблат сердца покрыт печатью кровавого бога!"
	if(curse_upper)
		cursed_parts += "Верхняя часть сердца покрыта печатью кровавого бога!"
	if(curse_lower)
		cursed_parts += "Нижняя часть сердца покрыта печатью кровавого бога!"
	return cursed_parts

/obj/structure/clockwork/functional/heart/get_ru_names()
	return list(
		NOMINATIVE = "Сердце Ратвара",
		GENITIVE = "Сердца Ратвара",
		DATIVE = "Сердцу Ратвара",
		ACCUSATIVE = "Сердце Ратвара",
		INSTRUMENTAL = "Сердцем Ратвара",
		PREPOSITIONAL = "Сердце Ратвара",
	)

/obj/structure/clockwork/functional/heart/Initialize(mapload)
	if(GLOB.heart)
		qdel(src, TRUE)
		return
	GLOB.poi_list += src
	GLOB.heart = src
	enchants = GLOB.gun_and_heart_spells
	alpha = 0
	new /obj/effect/temp_visual/ratvar/reconstruct/heart(loc)
	update_icon(UPDATE_OVERLAYS)
	addtimer(CALLBACK(src, PROC_REF(throw_everything_back)), 1 SECONDS)
	addtimer(CALLBACK(src, PROC_REF(spawn_fillers)), 1 SECONDS)
	spawn_parts()
	SSticker.mode.clocker_objs.check_heart()
	. = ..()

/obj/structure/clockwork/functional/heart/proc/spawn_fillers()
	var/list/occupied = list()
	for(var/direct in GLOB.alldirs)
		occupied += get_step(src, direct)

	for(var/filler_loc in occupied)
		var/obj/structure/heart_filler/F = new(filler_loc)
		F.update_parent(src)
		fillers += F

/obj/structure/clockwork/functional/heart/update_overlays()
	. = ..()

	if(curse_dial)
		. += "[icon_state]_dialcurse"
	if(curse_upper)
		. += "[icon_state]_curse_upper"
	if(curse_lower)
		. += "[icon_state]_curse_lower"
	if(cur_enchant)
		.+= "heart_overlay_[cur_enchant]"

/obj/structure/clockwork/functional/heart/update_icon_state()
	if(!summoning)
		return
	icon_state = "summoning_stage_[summon_stage]"

/obj/structure/clockwork/functional/heart/proc/select_pulse()
	switch(cur_enchant)
		if(EMP_G_SPELL)
			new /obj/effect/temp_visual/ratvar/reconstruct/heart_pulse/emp(loc, pulse_range)
		if(HEAL_G_SPELL)
			new /obj/effect/temp_visual/ratvar/reconstruct/heart_pulse/heal(loc, pulse_range)
		if(STUN_G_SPELL)
			new /obj/effect/temp_visual/ratvar/reconstruct/heart_pulse/stun(loc, pulse_range)
		else
			new /obj/effect/temp_visual/ratvar/reconstruct/heart_pulse(loc, pulse_range)
			enchanted_before = FALSE

/obj/structure/clockwork/functional/heart/proc/heart_pulse()
	if(!curse_dial)
		obj_integrity = max(obj_integrity + 300, max_integrity)
		enchanted_before = TRUE
		select_pulse()
		new /obj/effect/temp_visual/pulse(src.loc)
		new /obj/effect/warp_effect/heart(loc)
		cur_enchant = null
		pulse_range += 2
	update_icon(UPDATE_OVERLAYS)

/obj/structure/clockwork/functional/heart/Destroy(force)
	if(!force)
		for(var/turf/tile in orange(1, src))
			new /obj/effect/gibspawner/clock(tile)
		playsound(src, 'sound/effects/forge_destroy.ogg', 50, TRUE)
		GLOB.heart = null
	if(SSticker.mode.clocker_objs.clock_status != RATVAR_NEEDS_SUMMONING && SSticker.mode.clocker_objs.clock_status != RATVAR_HAS_RISEN)
		for(var/datum/mind/clock_mind in SSticker.mode.clockwork_cult)
			if(clock_mind?.current)
				to_chat(clock_mind.current, span_clocklarge("Сердце уничтожено!"))
				SSticker.mode.clocker_objs.need_heart()
	QDEL_LIST(fillers)
	for(var/part in spawned_parts)
		LAZYREMOVE(GLOB.poi_list, part)
		qdel(part)
	if(gateway)
		QDEL_NULL(gateway)
	spawned_parts = null
	GLOB.total_curses = 3
	. = ..()
/obj/structure/clockwork/functional/heart/MouseDrop_T(atom/movable/dropping, mob/user, params)
	if(!isclocker(user))
		return
	if(!istype(dropping, /obj/structure/part_dial))
		return
	if(!curse_dial)
		return
	if(!do_after(user, 5 SECONDS, src))
		return
	curse_dial = FALSE
	GLOB.total_curses--
	addtimer(CALLBACK(src, PROC_REF(heart_pulse)), 30 SECONDS, TIMER_LOOP | TIMER_DELETE_ME)
	addtimer(CALLBACK(GLOBAL_PROC, GLOBAL_PROC_REF(playsound), src, 'sound/magic/clockwork/heart_tick_tock.ogg', 100, FALSE, 0, SOUND_FALLOFF_EXPONENT, null, 0, TRUE, TRUE, SOUND_DEFAULT_FALLOFF_DISTANCE, TRUE), 4 SECONDS, TIMER_LOOP | TIMER_DELETE_ME)
	qdel(dropping)
	give_blessing(user)
	update_icon(UPDATE_OVERLAYS)

/obj/structure/clockwork/functional/heart/attackby(obj/item/I, mob/user, params)
	if(istype(I, /obj/item/clockwork/clockslab) && isclocker(user))
		add_fingerprint(user)
		return ATTACK_CHAIN_BLOCKED_ALL
	if(istype(I, /obj/item/part_upper))
		adjust_part(I, user)
		return ATTACK_CHAIN_PROCEED
	if(istype(I, /obj/item/clockwork/shard) && !summoning)
		summon(user, I)
		return ATTACK_CHAIN_PROCEED
	. = ..()

/obj/structure/clockwork/functional/heart/proc/adjust_part(obj/item/part_upper/part, mob/user)
	if(curse_dial)
		balloon_alert(user, "циферблат сломан!")
		return
	if(!do_after(user, 5 SECONDS, src))
		return
	part.destroy_curse(user)
	balloon_alert(user, "деталь установлена")
	GLOB.total_curses --
	qdel(part)
	update_icon(UPDATE_OVERLAYS)
	give_blessing(user)
	SSticker.mode.clocker_objs.update_seals()

/obj/structure/clockwork/functional/heart/proc/summon(mob/user, obj/item/shard)
	var/datum/game_mode/gamemode = SSticker.mode
	if(GLOB.total_curses > 0)
		balloon_alert(user, "сначала снимите печати")
		return
	if(gamemode.clocker_objs.clock_status < RATVAR_NEEDS_SUMMONING)
		balloon_alert(user, "слишком рано...")
		return
	if(GLOB.clockwork_power < 250)
		balloon_alert(user, "не хватает энергии")
		return
	adjust_clockwork_power(-250)
	visible_message(span_danger("[capitalize(declent_ru(NOMINATIVE))] исчезает, и на его месте появляется Великий Ковчег!"))
	var/area/summon_zone = get_area(src)
	GLOB.major_announcement.announce("Была обнаружена аномально высокая концентрация энергии в [summon_zone.map_name]. Источник энергии указывает на попытку вызвать потустороннего бога по имени Ратвар. Сорвите ритуал любой ценой, пока станция не была уничтожена! Действие космического закона и стандартных рабочих процедур приостановлено. Весь экипаж должен уничтожать культистов на месте.",
		ANNOUNCE_CCPARANORMAL_RU,
		'sound/AI/commandreport.ogg'
	)
	gateway = new
	gateway.heart = src
	summoning = TRUE
	qdel(shard)

/obj/structure/clockwork/functional/heart/proc/throw_everything_back()
	var/throw_dist
	for(var/atom/movable/did_not_stand_back in range(1, loc))
		throw_dist = calculate_throw_dist(did_not_stand_back)
		if(throw_dist < 0)
			continue
		throw_out(did_not_stand_back, throw_dist)

/obj/structure/clockwork/functional/heart/proc/calculate_throw_dist(atom/movable/did_not_stand_back)
	var/base_x_throw_distance = 2
	var/base_y_throw_distance = 2
	var/throw_dist = 0
	var/dir_to_center = get_dir(loc, did_not_stand_back)
	var/x_component = abs(did_not_stand_back.x - loc.x)
	var/y_component = abs(did_not_stand_back.y - loc.y)
	if(istype(did_not_stand_back, /obj/structure/clockwork/functional/heart) || istype(did_not_stand_back, /obj/structure/heart_filler) || istype(did_not_stand_back, /obj/effect/temp_visual/ratvar/reconstruct/heart))
		return -1
	if(ISDIAGONALDIR(dir_to_center))
		throw_dist = ceil(sqrt(base_x_throw_distance ** 2 + base_y_throw_distance ** 2) - (sqrt(x_component ** 2 + y_component ** 2)))
		did_not_stand_back.forceMove(get_ranged_target_turf(loc, dir_to_center, throw_dist))
	else if(dir_to_center & (NORTH|SOUTH))
		throw_dist = base_y_throw_distance - y_component + 1
		did_not_stand_back.forceMove(get_ranged_target_turf(loc, dir_to_center, base_y_throw_distance))
	else if(dir_to_center & (EAST|WEST))
		throw_dist = base_x_throw_distance - x_component + 1
		did_not_stand_back.forceMove(get_ranged_target_turf(loc, dir_to_center, base_x_throw_distance))
	return throw_dist

/obj/structure/clockwork/functional/heart/proc/throw_out(atom/movable/did_not_stand_back, throw_dist)
	did_not_stand_back.throw_at(
		target = get_edge_target_turf(did_not_stand_back, get_dir(loc, did_not_stand_back) || pick(GLOB.alldirs)),
		range = throw_dist,
		speed = 3,
			force = MOVE_FORCE_VERY_STRONG,
	)
	if(!isliving(did_not_stand_back) || isclocker(did_not_stand_back))
		return
	var/mob/living/affected = did_not_stand_back
	to_chat(affected, span_userdanger("Неведомая сила отталкивает вас!"))
	affected.Knockdown(6 SECONDS)

/obj/structure/clockwork/functional/heart/proc/give_blessing(mob/living/user)
	var/bless_to_give
	var/chosen_blessing
	if(isnull(blessings))
		bless_to_give = new /obj/item/gun/energy/gun/minigun/clockwork
		user.put_in_hands(bless_to_give)
		return
	chosen_blessing = pick(blessings)
	bless_to_give = new chosen_blessing(user.loc)
	user.put_in_hands(bless_to_give)
	LAZYREMOVE(blessings, chosen_blessing)
	to_chat(user, span_clockitalic("Благодарю тебя, сын мой. Прими же этот дар!"))
	chosen_blessing = null
	bless_to_give = null

/obj/structure/clockwork/functional/heart/proc/spawn_parts()
	var/first_part_loc = get_safe_random_station_turf()
	var/second_part_loc = get_safe_random_station_turf()
	var/third_part_loc = get_safe_random_station_turf()
	spawned_parts += new /obj/structure/part_dial(first_part_loc)
	spawned_parts += new /obj/item/part_upper(second_part_loc)
	spawned_parts += new /obj/item/part_upper/lower(third_part_loc)

/obj/structure/heart_filler
	name = "The Heart of Ratvar"
	desc = "Огромный механизм из латуни, напоминающий сердце. От его громкого тиканья у вас начинает болеть голова..."
	density = TRUE
	anchored = TRUE
	smoothing_groups = SMOOTH_GROUP_FILLER
	var/obj/parent
	icon = 'icons/effects/blood.dmi'
	icon_state = "thisisfuckingstupid"
	alpha = 1
	mouse_drag_pointer = MOUSE_DROP_POINTER
	plane = ABOVE_GAME_PLANE

/obj/structure/heart_filler/examine(mob/user)
	return parent.examine(user)

/obj/structure/heart_filler/get_ru_names()
	return parent.get_ru_names()

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
	return ATTACK_CHAIN_PROCEED

/obj/structure/heart_filler/proc/update_parent(obj/new_parent)
	parent = new_parent
	name = parent.name
	desc = parent.desc
	update_appearance(UPDATE_NAME | UPDATE_DESC)

/obj/structure/part_dial
	name = "big brass dial"
	desc = "Большой циферблат из латуни."
	icon ='icons/obj/clockwork.dmi'
	icon_state = "ratvarpart1"
	density = TRUE
	resistance_flags = INDESTRUCTIBLE
	mouse_drag_pointer = MOUSE_DRAG_POINTER

/obj/structure/part_dial/get_ru_names()
	return list(
		NOMINATIVE = "большой латунный циферблат",
		GENITIVE = "большого латунного циферблата",
		DATIVE = "большому латунному циферблату",
		ACCUSATIVE = "большой латунный циферблат",
		INSTRUMENTAL = "большим латунным циферблатом",
		PREPOSITIONAL = "большом латунном циферблате",
	)

/obj/structure/part_dial/Bumped(atom/movable/moving_atom)
	if(!ismob(moving_atom))
		. = ..()
	var/mob/dragger = moving_atom
	if(isclocker(dragger))
		anchored = FALSE
		return ..()
	anchored = TRUE
	to_chat(dragger, span_clockitalic("Вы пытаетесь толкнуть [declent_ru(ACCUSATIVE)], но его что-то удерживает!"))

/obj/structure/part_dial/CtrlClick(mob/user)
	if(isclocker(user))
		anchored = FALSE
		return ..()
	if(get_dist(user.loc, loc) > 1)
		return
	if(!ishuman(user))
		balloon_alert(user, "слишком тяжело!")
		return
	to_chat(user, span_userdanger("Вы попытались потянуть [declent_ru(ACCUSATIVE)], но ваша рука обратилась в пепел!"))
	var/obj/item/organ/external/limb_to_burn = user.get_organ((user.hand == ACTIVE_HAND_LEFT) ? BODY_ZONE_PRECISE_L_HAND : BODY_ZONE_PRECISE_R_HAND)
	limb_to_burn.droplimb(TRUE, DROPLIMB_BURN)
	new /obj/effect/decal/cleanable/ash(user.loc)

/obj/structure/part_dial/Initialize(mapload)
	addtimer(CALLBACK(src, PROC_REF(pulse)), 10 SECONDS, TIMER_LOOP | TIMER_DELETE_ME)
	GLOB.poi_list += src
	. = ..()

/obj/structure/part_dial/proc/pulse()
	new /obj/effect/temp_visual/ratvar/reconstruct/part(src.loc)

/obj/item/part_upper
	name = "brass component"

	desc = "Странная деталь из латуни."
	icon ='icons/obj/clockwork.dmi'
	icon_state = "ratvarpart3"
	item_state = "ratvarpart3"
	resistance_flags = INDESTRUCTIBLE
	mouse_drag_pointer = MOUSE_DRAG_POINTER
	w_class = WEIGHT_CLASS_BULKY

/obj/item/part_upper/get_ru_names()
	return list(
		NOMINATIVE = "латунная деталь",
		GENITIVE = "латунной детали",
		DATIVE = "латунной детали",
		ACCUSATIVE = "латунную деталь",
		INSTRUMENTAL = "латунной деталью",
		PREPOSITIONAL = "латунной детали",
	)

/obj/item/part_upper/CtrlClick(mob/user)
	if(!check_action(user, TRUE))
		return
	. = ..()

/obj/item/part_upper/attack_hand(mob/user, pickupfireoverride)
	if(!check_action(user, FALSE))
		return
	. = ..()

/obj/item/part_upper/proc/check_action(mob/living/user, is_pull_action = FALSE)
	if(isclocker(user))
		return TRUE
	if(get_dist(user.loc, src) > 1)
		return FALSE
	if(!ishuman(user))
		return FALSE
	to_chat(user, span_userdanger("Вы попытались [is_pull_action ? "потянуть" : "схватить"] [declent_ru(ACCUSATIVE)], но ваша рука обратилась в пепел!"))
	var/obj/item/organ/external/limb_to_burn = user.get_organ((user.hand == ACTIVE_HAND_LEFT) ? BODY_ZONE_PRECISE_L_HAND : BODY_ZONE_PRECISE_R_HAND)
	limb_to_burn.droplimb(TRUE, DROPLIMB_BURN)
	new /obj/effect/decal/cleanable/ash(user.loc)
	return FALSE

/obj/item/part_upper/Initialize(mapload)
	. = ..()
	GLOB.poi_list += src
	addtimer(CALLBACK(src, PROC_REF(pulse)), 10 SECONDS, TIMER_LOOP | TIMER_DELETE_ME)

/obj/item/part_upper/proc/destroy_curse(mob/living/user)
	if(!GLOB.heart?.curse_upper)
		return
	GLOB.heart?.curse_upper = FALSE

/obj/item/part_upper/proc/pulse()
	new /obj/effect/temp_visual/ratvar/reconstruct/part(src.loc)

/obj/item/part_upper/lower
	icon_state = "ratvarpart2"
	item_state = "ratvarpart2"

/obj/item/part_upper/lower/destroy_curse(mob/living/user)
	if(!GLOB.heart?.curse_lower)
		return
	GLOB.heart?.curse_lower = FALSE

/obj/effect/temp_visual/pulse
	icon = 'icons/obj/clockheart.dmi'
	icon_state = "pulse"
	pixel_x = -32
	pixel_y = -32
	layer = SPACEVINE_LAYER
	duration = 3
