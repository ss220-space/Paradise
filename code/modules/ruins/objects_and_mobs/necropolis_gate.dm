//The necropolis gate is used to call forth Legion from the Necropolis.
/obj/structure/necropolis_gate
	name = "necropolis gate"
	desc = "Огромные каменные врата, украшенные древними письменами."
	ru_names = list(
		NOMINATIVE = "врата Некрополя",
		GENITIVE = "врат Некрополя",
		DATIVE = "вратам Некрополя",
		ACCUSATIVE = "врата Некрополя",
		INSTRUMENTAL = "вратами Некрополя",
		PREPOSITIONAL = "вратах Некрополя"
	)
	icon = 'icons/effects/96x96.dmi'
	icon_state = "gate_full"
	flags = ON_BORDER
	appearance_flags = LONG_GLIDE
	layer = TABLE_LAYER
	anchored = TRUE
	density = TRUE
	pixel_x = -32
	pixel_y = -32
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | UNACIDABLE | ACID_PROOF
	light_range = 8
	light_color = LIGHT_COLOR_LAVA
	var/open = FALSE
	var/changing_openness = FALSE
	var/locked = FALSE
	var/static/mutable_appearance/top_overlay
	var/static/mutable_appearance/door_overlay
	var/static/mutable_appearance/dais_overlay
	var/obj/structure/opacity_blocker/sight_blocker
	var/sight_blocker_distance = 1


/obj/structure/necropolis_gate/Initialize(mapload)
	. = ..()
	setDir(SOUTH)
	var/turf/sight_blocker_turf = get_turf(src)
	if(sight_blocker_distance)
		for(var/i in 1 to sight_blocker_distance)
			if(!sight_blocker_turf)
				break
			sight_blocker_turf = get_step(sight_blocker_turf, NORTH)
	if(sight_blocker_turf)
		sight_blocker = new (sight_blocker_turf) //we need to block sight in a different spot than most things do
		sight_blocker.pixel_y = initial(sight_blocker.pixel_y) - (32 * sight_blocker_distance)
	icon_state = "gate_bottom"
	top_overlay = mutable_appearance('icons/effects/96x96.dmi', "gate_top")
	top_overlay.layer = EDGED_TURF_LAYER
	add_overlay(top_overlay)
	door_overlay = mutable_appearance('icons/effects/96x96.dmi', "door")
	door_overlay.layer = EDGED_TURF_LAYER
	add_overlay(door_overlay)
	dais_overlay = mutable_appearance('icons/effects/96x96.dmi', "gate_dais")
	dais_overlay.layer = CLOSED_TURF_LAYER
	add_overlay(dais_overlay)

	var/static/list/loc_connections = list(
		COMSIG_ATOM_EXIT = PROC_REF(on_exit),
	)
	AddElement(/datum/element/connect_loc, loc_connections)


/obj/structure/necropolis_gate/Destroy(force)
	if(force)
		qdel(sight_blocker, TRUE)
		. = ..()
	else
		return QDEL_HINT_LETMELIVE

/obj/structure/necropolis_gate/singularity_pull()
	return 0


/obj/structure/necropolis_gate/CanAllowThrough(atom/movable/mover, border_dir)
	. = ..()
	if(border_dir != dir)
		return TRUE


/obj/structure/necropolis_gate/proc/on_exit(datum/source, atom/movable/leaving, atom/newLoc)
	SIGNAL_HANDLER

	if(leaving.movement_type & PHASING)
		return

	if(leaving == src)
		return // Let's not block ourselves.

	if(pass_flags_self & leaving.pass_flags)
		return

	if(density && dir == get_dir(leaving, newLoc))
		leaving.Bump(src)
		return COMPONENT_ATOM_BLOCK_EXIT


/obj/structure/opacity_blocker
	icon = 'icons/effects/96x96.dmi'
	icon_state = "gate_blocker"
	layer = EDGED_TURF_LAYER
	pixel_x = -32
	pixel_y = -32
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	opacity = TRUE
	anchored = TRUE

/obj/structure/opacity_blocker/singularity_pull()
	return 0

/obj/structure/opacity_blocker/Destroy(force)
	if(force)
		. = ..()
	else
		return QDEL_HINT_LETMELIVE

//ATTACK HAND IGNORING PARENT RETURN VALUE
/obj/structure/necropolis_gate/attack_hand(mob/user)
	if(locked)
		to_chat(user, span_boldannounceic("Кажется, эта дверь [open ? "навеки открыта":"намертво запечатана"]."))
		return
	toggle_the_gate(user)
	return ..()

/obj/structure/necropolis_gate/proc/toggle_the_gate(mob/user, legion_damaged)
	if(changing_openness)
		return
	changing_openness = TRUE
	var/turf/T = get_turf(src)
	if(open)
		new /obj/effect/temp_visual/necropolis(T)
		visible_message(span_boldwarning("Врата с грохотом захлопываются!"))
		sleep(1)
		playsound(T, 'sound/effects/stonedoor_openclose.ogg', 300, TRUE, frequency = 80000)
		sleep(1)
		set_density(TRUE)
		sleep(1)
		var/turf/sight_blocker_turf = get_turf(src)
		if(sight_blocker_distance)
			for(var/i in 1 to sight_blocker_distance)
				if(!sight_blocker_turf)
					break
				sight_blocker_turf = get_step(sight_blocker_turf, NORTH)
		if(sight_blocker_turf)
			sight_blocker.pixel_y = initial(sight_blocker.pixel_y) - (32 * sight_blocker_distance)
			sight_blocker.forceMove(sight_blocker_turf)
		sleep(2.5)
		playsound(T, 'sound/magic/clockwork/invoke_general.ogg', 30, TRUE, frequency = 15000)
		add_overlay(door_overlay)
		open = FALSE
	else
		cut_overlay(door_overlay)
		new /obj/effect/temp_visual/necropolis/open(T)
		sleep(2)
		visible_message(span_warning("Врата со скрежетом начинают открываться..."))
		playsound(T, 'sound/effects/stonedoor_openclose.ogg', 300, TRUE, frequency = 20000)
		sleep(22)
		sight_blocker.forceMove(src)
		sleep(5)
		set_density(FALSE)
		sleep(5)
		open = TRUE
	changing_openness = FALSE
	return TRUE

/obj/structure/necropolis_gate/ashwalker
	desc = "Массивные каменные врата. Кажется, они намертво запечатаны."
	locked = TRUE

/obj/structure/necropolis_gate/ashwalker/attack_hand(mob/user)
	if(locked)
		if("ashwalker" in user.faction)
			locked = FALSE
	return ..()

/obj/structure/necropolis_gate/locked
	locked = TRUE

GLOBAL_DATUM(necropolis_gate, /obj/structure/necropolis_gate/legion_gate)
/obj/structure/necropolis_gate/legion_gate
	desc = "Массивные, внушительные врата, расположенные внутри высокой каменной башни."
	sight_blocker_distance = 2
	var/legion_triggered = FALSE

/obj/structure/necropolis_gate/legion_gate/Initialize(mapload)
	. = ..()
	GLOB.necropolis_gate = src

/obj/structure/necropolis_gate/legion_gate/Destroy(force)
	if(force)
		if(GLOB.necropolis_gate == src)
			GLOB.necropolis_gate = null
		. = ..()
	else
		return QDEL_HINT_LETMELIVE

//ATTACK HAND IGNORING PARENT RETURN VALUE
/obj/structure/necropolis_gate/legion_gate/attack_hand(mob/user)
	if(!open && !changing_openness)
		var/safety = tgui_alert(user, "Каждая клеточка тела кричит, что это плохая идея...", "Постучать?", list("Решиться", "Отступить"))
		if(!safety || safety == "Отступить" || !in_range(src, user) || !src || open || changing_openness || user.incapacitated())
			return
		user.visible_message(
			span_warning("[user] стуч[pluralize_ru(user.gender,"ит","ят")] по [declent_ru(DATIVE)]..."),
			span_boldannounceic("Вы осторожно стучите по [declent_ru(DATIVE)]...")
		)
		playsound(user.loc, 'sound/effects/shieldbash.ogg', 100, TRUE)
		sleep(50)
	return ..()

/obj/structure/necropolis_gate/legion_gate/toggle_the_gate(mob/user, legion_damaged)
	if(open)
		return
	GLOB.necropolis_gate.legion_triggered = TRUE
	. = ..()
	if(.)
		locked = TRUE
		var/turf/T = get_turf(src)
		visible_message(span_userdanger("Что-то ужасное вырывается из Некрополя!"))
		if(legion_damaged)
			message_admins("Legion took damage while the necropolis gate was closed, and has released itself!")
			add_game_logs("Legion took damage while the necropolis gate was closed and released itself.")
		else
			message_admins("[user ? ADMIN_LOOKUPFLW(user):"Unknown"] has released Legion!")
			add_game_logs("[user ? key_name_log(user) : "Unknown"] released Legion.", user)

		var/sound/legion_sound = sound('sound/creatures/legion_spawn.ogg')
		for(var/mob/M in GLOB.player_list)
			if(M.z == z)
				to_chat(M, span_userdanger("Ваш разум наполняют диссонирующие шёпоты тысяч голосов. Каждый повторяет ваше имя снова и снова..."))
				to_chat(M, span_userdanger("Выпущено нечто ужасающее!"))
				M.playsound_local(T, null, 100, FALSE, 0, FALSE, pressure_affected = FALSE, sound = legion_sound)
				flash_color(M, flash_color = "#FF0000", flash_time = 50)
		var/mutable_appearance/release_overlay = mutable_appearance('icons/effects/effects.dmi', "legiondoor")
		notify_ghosts("Легион был выпущен в [get_area(src)]!", source = src, alert_overlay = release_overlay, action = NOTIFY_JUMP)

/obj/effect/temp_visual/necropolis
	icon = 'icons/effects/96x96.dmi'
	icon_state = "door_closing"
	appearance_flags = LONG_GLIDE
	duration = 6
	layer = EDGED_TURF_LAYER
	pixel_x = -32
	pixel_y = -32

/obj/effect/temp_visual/necropolis/open
	icon_state = "door_opening"
	duration = 38

/obj/structure/necropolis_arch
	name = "necropolis arch"
	desc = "Массивная арка над вратами Некрополя, вставленная в массивную каменную башню."
	ru_names = list(
		NOMINATIVE = "арка Некрополя",
		GENITIVE = "арки Некрополя",
		DATIVE = "арке Некрополя",
		ACCUSATIVE = "арку Некрополя",
		INSTRUMENTAL = "аркой Некрополя",
		PREPOSITIONAL = "арке Некрополя"
	)
	icon = 'icons/effects/160x160.dmi'
	icon_state = "arch_full"
	appearance_flags = LONG_GLIDE
	layer = TABLE_LAYER
	anchored = TRUE
	pixel_x = -64
	pixel_y = -40
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | UNACIDABLE | ACID_PROOF
	var/open = FALSE
	var/static/mutable_appearance/top_overlay

/obj/structure/necropolis_arch/Initialize(mapload)
	. = ..()
	icon_state = "arch_bottom"
	top_overlay = mutable_appearance('icons/effects/160x160.dmi', "arch_top")
	top_overlay.layer = EDGED_TURF_LAYER
	add_overlay(top_overlay)

/obj/structure/necropolis_arch/singularity_pull()
	return 0

/obj/structure/necropolis_arch/Destroy(force)
	if(force)
		. = ..()
	else
		return QDEL_HINT_LETMELIVE

#define STABLE 0 //The tile is stable and won't collapse/sink when crossed.
#define COLLAPSE_ON_CROSS 1 //The tile is unstable and will temporary become unusable when crossed.
#define DESTROY_ON_CROSS 2 //The tile is nearly broken and will permanently become unusable when crossed.
#define UNIQUE_EFFECT 3 //The tile has some sort of unique effect when crossed.
//stone tiles for boss arenas
/obj/structure/stone_tile
	name = "stone tile"
	ru_names = list(
		NOMINATIVE = "каменная плитка",
		GENITIVE = "каменной плитки",
		DATIVE = "каменной плитке",
		ACCUSATIVE = "каменную плитку",
		INSTRUMENTAL = "каменной плиткой",
		PREPOSITIONAL = "каменной плитке"
	)
	icon = 'icons/turf/floors/boss_floors.dmi'
	icon_state = "pristine_tile1"
	layer = ABOVE_OPEN_TURF_LAYER
	anchored = TRUE
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | UNACIDABLE | ACID_PROOF
	var/tile_key = "pristine_tile"
	var/tile_random_sprite_max = 24
	var/fall_on_cross = STABLE //If the tile has some sort of effect when crossed
	var/fallen = FALSE //If the tile is unusable
	var/falling = FALSE //If the tile is falling


/obj/structure/stone_tile/Initialize(mapload)
	. = ..()
	icon_state = "[tile_key][rand(1, tile_random_sprite_max)]"
	var/static/list/loc_connections = list(
		COMSIG_ATOM_ENTERED = PROC_REF(on_entered),
	)
	AddElement(/datum/element/connect_loc, loc_connections)
	toggle_fallen(FALSE, TRUE)


/obj/structure/stone_tile/proc/toggle_fallen(new_fallen, init)
	if(new_fallen == fallen && !init)
		return
	. = new_fallen
	fallen = new_fallen
	var/static/list/give_turf_traits
	if(!give_turf_traits)
		give_turf_traits = string_list(list(TRAIT_LAVA_STOPPED, TRAIT_CHASM_STOPPED, TRAIT_TURF_IGNORE_SLOWDOWN))
	if(fallen)
		RemoveElement(/datum/element/give_turf_traits, give_turf_traits)
	else
		AddElement(/datum/element/give_turf_traits, give_turf_traits)


/obj/structure/stone_tile/Destroy(force)
	if(force || fallen)
		. = ..()
	else
		return QDEL_HINT_LETMELIVE

/obj/structure/stone_tile/singularity_pull()
	return


/obj/structure/stone_tile/proc/on_entered(datum/source, atom/movable/arrived, atom/old_loc, list/atom/old_locs)
	SIGNAL_HANDLER

	if(falling || fallen)
		return

	var/turf/our_turf = get_turf(src)
	if(!islava(our_turf) && !ischasm(our_turf)) //nothing to sink or fall into
		return

	var/obj/item/item
	var/mob/living/mob
	if(isitem(arrived))
		item = arrived
	else if(isliving(arrived))
		mob = arrived

	switch(fall_on_cross)
		if(COLLAPSE_ON_CROSS, DESTROY_ON_CROSS)
			if((item && item.w_class >= WEIGHT_CLASS_BULKY) || (mob && !(mob.movement_type & MOVETYPES_NOT_TOUCHING_GROUND) && mob.mob_size >= MOB_SIZE_HUMAN)) //too heavy! too big! aaah!
				INVOKE_ASYNC(src, PROC_REF(collapse))
		if(UNIQUE_EFFECT)
			INVOKE_ASYNC(src, PROC_REF(crossed_effect), arrived)


/obj/structure/stone_tile/proc/collapse()
	falling = TRUE
	var/break_that_sucker = fall_on_cross == DESTROY_ON_CROSS
	playsound(src, 'sound/effects/pressureplate.ogg', 50, TRUE)
	Shake(-1, -1, 25)
	sleep(5)
	if(break_that_sucker)
		playsound(src, 'sound/effects/break_stone.ogg', 50, TRUE)
	else
		playsound(src, 'sound/mecha/mechmove04.ogg', 50, TRUE)
	animate(src, alpha = 0, pixel_y = pixel_y - 3, time = 5)
	toggle_fallen(TRUE)
	if(break_that_sucker)
		QDEL_IN(src, 10)
	else
		addtimer(CALLBACK(src, PROC_REF(rebuild)), 55)

/obj/structure/stone_tile/proc/rebuild()
	pixel_x = initial(pixel_x)
	pixel_y = initial(pixel_y) - 5
	animate(src, alpha = initial(alpha), pixel_x = initial(pixel_x), pixel_y = initial(pixel_y), time = 30)
	sleep(30)
	falling = FALSE
	toggle_fallen(FALSE)

/obj/structure/stone_tile/proc/crossed_effect(atom/movable/AM, oldloc)
	return

/obj/structure/stone_tile/block
	name = "stone block"
	ru_names = list(
		NOMINATIVE = "каменный блок",
		GENITIVE = "каменного блока",
		DATIVE = "каменному блоку",
		ACCUSATIVE = "каменный блок",
		INSTRUMENTAL = "каменным блоком",
		PREPOSITIONAL = "каменном блоке"
	)
	icon_state = "pristine_block1"
	tile_key = "pristine_block"
	tile_random_sprite_max = 4

/obj/structure/stone_tile/slab
	name = "stone slab"
	ru_names = list(
		NOMINATIVE = "каменная плита",
		GENITIVE = "каменной плиты",
		DATIVE = "каменной плите",
		ACCUSATIVE = "каменную плиту",
		INSTRUMENTAL = "каменной плитой",
		PREPOSITIONAL = "каменной плите"
	)
	icon_state = "pristine_slab1"
	tile_key = "pristine_slab"
	tile_random_sprite_max = 4

/obj/structure/stone_tile/slab/bone
	name = "stone bone slab"
	ru_names = list(
		NOMINATIVE = "костяная каменная плита",
		GENITIVE = "костяной каменной плиты",
		DATIVE = "костяной каменной плите",
		ACCUSATIVE = "костяную каменную плиту",
		INSTRUMENTAL = "костяной каменной плитой",
		PREPOSITIONAL = "костяной каменной плите"
	)
	icon_state = "cracked_slab_bone1"
	tile_key = "cracked_slab_bone"
	tile_random_sprite_max = 1
	color = "#fffff0"

/obj/structure/stone_tile/center
	name = "stone center tile"
	ru_names = list(
		NOMINATIVE = "центральная каменная плитка",
		GENITIVE = "центральной каменной плитки",
		DATIVE = "центральной каменной плитке",
		ACCUSATIVE = "центральную каменную плитку",
		INSTRUMENTAL = "центральной каменной плиткой",
		PREPOSITIONAL = "центральной каменной плитке"
	)
	icon_state = "pristine_center1"
	tile_key = "pristine_center"
	tile_random_sprite_max = 4

/obj/structure/stone_tile/surrounding
	name = "stone surrounding slab"
	ru_names = list(
		NOMINATIVE = "окаймляющая каменная плита",
		GENITIVE = "окаймляющей каменной плиты",
		DATIVE = "окаймляющей каменной плите",
		ACCUSATIVE = "окаймляющую каменную плиту",
		INSTRUMENTAL = "окаймляющей каменной плитой",
		PREPOSITIONAL = "окаймляющей каменной плите"
	)
	icon_state = "pristine_surrounding1"
	tile_key = "pristine_surrounding"
	tile_random_sprite_max = 2

/obj/structure/stone_tile/surrounding_tile
	name = "stone surrounding tile"
	ru_names = list(
		NOMINATIVE = "окаймляющая каменная плитка",
		GENITIVE = "окаймляющей каменной плитки",
		DATIVE = "окаймляющей каменной плитке",
		ACCUSATIVE = "окаймляющую каменную плитку",
		INSTRUMENTAL = "окаймляющей каменной плиткой",
		PREPOSITIONAL = "окаймляющей каменной плитке"
	)
	icon_state = "pristine_surrounding_tile1"
	tile_key = "pristine_surrounding_tile"
	tile_random_sprite_max = 2

//cracked stone tiles
/obj/structure/stone_tile/cracked
	name = "cracked stone tile"
	ru_names = list(
		NOMINATIVE = "треснувшая каменная плитка",
		GENITIVE = "треснувшей каменной плитки",
		DATIVE = "треснувшей каменной плитке",
		ACCUSATIVE = "треснувшую каменную плитку",
		INSTRUMENTAL = "треснувшей каменной плиткой",
		PREPOSITIONAL = "треснувшей каменной плитке"
	)
	icon_state = "cracked_tile1"
	tile_key = "cracked_tile"

/obj/structure/stone_tile/block/cracked
	name = "cracked stone block"
	ru_names = list(
		NOMINATIVE = "треснувший каменный блок",
		GENITIVE = "треснувшего каменного блока",
		DATIVE = "треснувшему каменному блоку",
		ACCUSATIVE = "треснувший каменный блок",
		INSTRUMENTAL = "треснувшим каменным блоком",
		PREPOSITIONAL = "треснувшем каменном блоке"
	)
	icon_state = "cracked_block1"
	tile_key = "cracked_block"

/obj/structure/stone_tile/slab/cracked
	name = "cracked stone slab"
	ru_names = list(
		NOMINATIVE = "треснувшая каменная плита",
		GENITIVE = "треснувшей каменной плиты",
		DATIVE = "треснувшей каменной плите",
		ACCUSATIVE = "треснувшую каменную плиту",
		INSTRUMENTAL = "треснувшей каменной плитой",
		PREPOSITIONAL = "треснувшей каменной плите"
	)
	icon_state = "cracked_slab1"
	tile_key = "cracked_slab"
	tile_random_sprite_max = 1

/obj/structure/stone_tile/center/cracked
	name = "cracked stone center tile"
	ru_names = list(
		NOMINATIVE = "треснувшая центральная плитка",
		GENITIVE = "треснувшей центральной плитки",
		DATIVE = "треснувшей центральной плитке",
		ACCUSATIVE = "треснувшую центральную плитку",
		INSTRUMENTAL = "треснувшей центральной плиткой",
		PREPOSITIONAL = "треснувшей центральной плитке"
	)
	icon_state = "cracked_center1"
	tile_key = "cracked_center"

/obj/structure/stone_tile/surrounding/cracked
	name = "cracked stone surrounding slab"
	ru_names = list(
		NOMINATIVE = "треснувшая окаймляющая плита",
		GENITIVE = "треснувшей окаймляющей плиты",
		DATIVE = "треснувшей окаймляющей плите",
		ACCUSATIVE = "треснувшую окаймляющую плиту",
		INSTRUMENTAL = "треснувшей окаймляющей плитой",
		PREPOSITIONAL = "треснувшей окаймляющей плите"
	)
	icon_state = "cracked_surrounding1"
	tile_key = "cracked_surrounding"
	tile_random_sprite_max = 1

/obj/structure/stone_tile/surrounding_tile/cracked
	name = "cracked stone surrounding tile"
	ru_names = list(
		NOMINATIVE = "треснувшая окаймляющая плитка",
		GENITIVE = "треснувшей окаймляющей плитки",
		DATIVE = "треснувшей окаймляющей плитке",
		ACCUSATIVE = "треснувшую окаймляющую плитку",
		INSTRUMENTAL = "треснувшей окаймляющей плиткой",
		PREPOSITIONAL = "треснувшей окаймляющей плитке"
	)
	icon_state = "cracked_surrounding_tile1"
	tile_key = "cracked_surrounding_tile"

//burnt stone tiles
/obj/structure/stone_tile/burnt
	name = "burnt stone tile"
	ru_names = list(
		NOMINATIVE = "обугленная каменная плитка",
		GENITIVE = "обугленной каменной плитки",
		DATIVE = "обугленной каменной плитке",
		ACCUSATIVE = "обугленную каменную плитку",
		INSTRUMENTAL = "обугленной каменной плиткой",
		PREPOSITIONAL = "обугленной каменной плитке"
	)
	icon_state = "burnt_tile1"
	tile_key = "burnt_tile"

/obj/structure/stone_tile/block/burnt
	name = "burnt stone block"
	ru_names = list(
		NOMINATIVE = "обугленный каменный блок",
		GENITIVE = "обугленного каменного блока",
		DATIVE = "обугленному каменному блоку",
		ACCUSATIVE = "обугленный каменный блок",
		INSTRUMENTAL = "обугленным каменным блоком",
		PREPOSITIONAL = "обугленном каменном блоке"
	)
	icon_state = "burnt_block1"
	tile_key = "burnt_block"

/obj/structure/stone_tile/slab/burnt
	name = "burnt stone slab"
	ru_names = list(
		NOMINATIVE = "обугленная каменная плита",
		GENITIVE = "обугленной каменной плиты",
		DATIVE = "обугленной каменной плите",
		ACCUSATIVE = "обугленную каменную плиту",
		INSTRUMENTAL = "обугленной каменной плитой",
		PREPOSITIONAL = "обугленной каменной плите"
	)
	icon_state = "burnt_slab1"
	tile_key = "burnt_slab"

/obj/structure/stone_tile/center/burnt
	name = "burnt stone center tile"
	ru_names = list(
		NOMINATIVE = "обугленная центральная плитка",
		GENITIVE = "обугленной центральной плитки",
		DATIVE = "обугленной центральной плитке",
		ACCUSATIVE = "обугленную центральную плитку",
		INSTRUMENTAL = "обугленной центральной плиткой",
		PREPOSITIONAL = "обугленной центральной плитке"
	)
	icon_state = "burnt_center1"
	tile_key = "burnt_center"

/obj/structure/stone_tile/surrounding/burnt
	name = "burnt stone surrounding slab"
	ru_names = list(
		NOMINATIVE = "обугленная окаймляющая плита",
		GENITIVE = "обугленной окаймляющей плиты",
		DATIVE = "обугленной окаймляющей плите",
		ACCUSATIVE = "обугленную окаймляющую плиту",
		INSTRUMENTAL = "обугленной окаймляющей плитой",
		PREPOSITIONAL = "обугленной окаймляющей плите"
	)
	icon_state = "burnt_surrounding1"
	tile_key = "burnt_surrounding"

/obj/structure/stone_tile/surrounding_tile/burnt
	name = "burnt stone surrounding tile"
	ru_names = list(
		NOMINATIVE = "обугленная окаймляющая плитка",
		GENITIVE = "обугленной окаймляющей плитки",
		DATIVE = "обугленной окаймляющей плитке",
		ACCUSATIVE = "обугленную окаймляющую плитку",
		INSTRUMENTAL = "обугленной окаймляющей плиткой",
		PREPOSITIONAL = "обугленной окаймляющей плитке"
	)
	icon_state = "burnt_surrounding_tile1"
	tile_key = "burnt_surrounding_tile"

/obj/structure/stone_tile/bone

#undef STABLE
#undef COLLAPSE_ON_CROSS
#undef DESTROY_ON_CROSS
#undef UNIQUE_EFFECT
