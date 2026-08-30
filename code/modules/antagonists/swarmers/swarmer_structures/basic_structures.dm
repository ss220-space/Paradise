// Anything that has very simple mechanics can be put here

/**
 * Swarmer trap
 *
 * Electrocutes and weakens a mob on enter.
 */
/obj/structure/swarmer/trap
	name = "swarmer trap"
	desc = "Ловушка быстрой сборки, которая бьёт током живых существ и глушит сенсоры машин. Довольно хрупкая."
	icon_state = "trap"
	max_integrity = 10
	alpha = 125
	density = FALSE
	swarmers_pass = TRUE

/obj/structure/swarmer/trap/Initialize(mapload)
	. = ..()
	var/static/list/loc_connections = list(
		COMSIG_ATOM_ENTERED = PROC_REF(on_entered),
	)
	AddElement(/datum/element/connect_loc, loc_connections)

/obj/structure/swarmer/trap/proc/on_entered(datum/source, mob/living/arrived, atom/old_loc, list/atom/old_locs)
	SIGNAL_HANDLER

	if(!isliving(arrived) || isswarmer(arrived))
		return

	playsound(loc, 'sound/effects/snap.ogg', 50, TRUE)
	arrived.apply_effects(weaken = SWARMER_TRAP_WEAKEN, knockdown = SWARMER_TRAP_KNOCKDOWN, stamina = SWARMER_TRAP_DAMAGE, jitter = 10 SECONDS)
	qdel(src)

/obj/structure/swarmer/trap/get_ru_names()
	return alist(
		NOMINATIVE = "ловушка \"Свармеров\"",
		GENITIVE = "ловушки \"Свармеров\"",
		DATIVE = "ловушке \"Свармеров\"",
		ACCUSATIVE = "ловушку \"Свармеров\"",
		INSTRUMENTAL = "ловушкой \"Свармеров\"",
		PREPOSITIONAL = "ловушке \"Свармеров\""
	)

/**
 * Swarmer barricade
 *
 * Blocks projectiles, allows for swarmer projectiles to pass.
 */
/obj/structure/swarmer/blockade
	name = "swarmer blockade"
	desc = "Баррикада быстрой сборки."
	swarmer_examine = "Свободно пропускает свармеров и их выстрелы."
	icon_state = "barricade"
	light_range = MINIMUM_USEFUL_LIGHT_RANGE
	max_integrity = 60
	swarmers_pass = TRUE

/obj/structure/swarmer/blockade/get_ru_names()
	return alist(
		NOMINATIVE = "баррикада \"Свармеров\"",
		GENITIVE = "баррикады \"Свармеров\"",
		DATIVE = "баррикаде \"Свармеров\"",
		ACCUSATIVE = "баррикаду \"Свармеров\"",
		INSTRUMENTAL = "баррикадой \"Свармеров\"",
		PREPOSITIONAL = "баррикаде \"Свармеров\""
	)

/**
 * Swarmer resource storage
 *
 * Increases modifier of metal collecting by swarmers. Stackable.
 */
/obj/structure/swarmer/resource_storage
	name = "swarmer resource storage"
	desc = "Хранилище ресурсов \"Свармеров\", позволяющее собирать больше материалов с объектов."
	swarmer_examine = "Увеличивает количество ресурсов, полученных с ручного собирания."
	icon_state = "metal_storage"
	max_integrity = 100

/obj/structure/swarmer/resource_storage/Initialize(mapload)
	. = ..()
	var/datum/team/swarmer_team/swarmer_team = GLOB.antagonist_teams[/datum/team/swarmer_team]
	if(!swarmer_team)
		swarmer_team = new

	swarmer_team.increase_modifier()

/obj/structure/swarmer/resource_storage/Destroy(force)
	var/datum/team/swarmer_team/swarmer_team = GLOB.antagonist_teams[/datum/team/swarmer_team]
	if(!swarmer_team)
		swarmer_team = new

	swarmer_team.decrease_modifier()
	return ..()

/obj/structure/swarmer/resource_storage/get_ru_names()
	return alist(
		NOMINATIVE = "хранилище ресурсов \"Свармеров\"",
		GENITIVE = "хранилища ресурсов \"Свармеров\"",
		DATIVE = "хранилищу ресурсов \"Свармеров\"",
		ACCUSATIVE = "хранилище ресурсов \"Свармеров\"",
		INSTRUMENTAL = "хранилищем ресурсов \"Свармеров\"",
		PREPOSITIONAL = "хранилище ресурсов \"Свармеров\""
	)

/**
 * Swarmer core field
 *
 * Used on core spawn and move.
 */
/obj/structure/swarmer/swarmer_core_field
	name = "core field"
	desc = "Защищает ядро Свармеров. Видно, что оно ослабевает с каждой прошедшей секундой."
	icon_state = "core_field"
	layer = HIGH_OBJ_LAYER
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | UNACIDABLE | ACID_PROOF
	swarmer_examine = "Временно защищает ядро от недоброжелателей. Пропадёт через время."
	swarmers_pass = TRUE

/obj/structure/swarmer/swarmer_core_field/get_ru_names()
	return alist(
		NOMINATIVE = "поле защиты ядра",
		GENITIVE = "поля защиты ядра",
		DATIVE = "полю защиты ядра",
		ACCUSATIVE = "полем защиты ядра",
		INSTRUMENTAL = "полем защиты ядра",
		PREPOSITIONAL = "поле защиты ядра",
	)

/obj/structure/swarmer/swarmer_core_field/Initialize(mapload, duration, new_dir)
	. = ..()
	if(new_dir)
		dir = new_dir
	if(duration)
		addtimer(CALLBACK(GLOBAL_PROC, GLOBAL_PROC_REF(qdel), src), duration)
	if(iswallturf(loc)) // just for pretty
		SET_PLANE(src, FLOOR_PLANE, loc)

/obj/structure/swarmer/swarmer_core_field/Destroy(force)
	if(prob(30))
		do_sparks(5, FALSE, loc)
	return ..()

/obj/structure/swarmer/swarmer_core_field/swarmer_help_act(mob/living/simple_animal/hostile/swarmer/swarmer)
	swarmer.balloon_alert(swarmer, "нельзя взаимодействовать!")

/obj/structure/swarmer/swarmer_core_field/swarmer_disarm_act(mob/living/simple_animal/hostile/swarmer/swarmer)
	swarmer.balloon_alert(swarmer, "это нельзя починить!")

/obj/structure/swarmer/swarmer_core_field/swarmer_grab_act(mob/living/simple_animal/hostile/swarmer/swarmer)
	swarmer.balloon_alert(swarmer, "это нельзя открутить!")

/obj/structure/swarmer/swarmer_core_field/swarmer_harm_act(mob/living/simple_animal/hostile/swarmer/swarmer)
	swarmer.balloon_alert(swarmer, "это нельзя уничтожить!")

/// Creates an unbreakable swarmer shield around a turf, with set duration
/proc/swarmer_shield_around_turf(turf/target_turf, shield_radius, shield_duration)
	var/list/shield_turfs = RANGE_EDGE_TURFS(shield_radius, target_turf)
	var/list/corner_turfs = list(shield_turfs[1], shield_turfs[1 + 2 * shield_radius], shield_turfs[2 + 2 * shield_radius], shield_turfs[2 + 4 * shield_radius])
	var/list/non_corner_turfs = shield_turfs - corner_turfs

	var/static/alist/quotient_to_edge_dir = alist(0 = EAST, 1 = WEST, 2 = NORTH, 3 = SOUTH)
	var/static/alist/index_to_corner_dir = alist(1 = NORTHEAST, 2 = SOUTHEAST, 3 = NORTHWEST, 4 = SOUTHWEST)

	// Amount of shields per side without corners
	var/shields_per_side = length(non_corner_turfs) / 4
	for(var/i in 1 to length(non_corner_turfs))
		var/turf/field_turf = non_corner_turfs[i]
		var/dir = quotient_to_edge_dir[floor((i - 1) / shields_per_side)]
		new /obj/structure/swarmer/swarmer_core_field(field_turf, shield_duration, dir)

	for(var/i in 1 to length(corner_turfs))
		var/turf/field_turf = corner_turfs[i]
		var/dir = index_to_corner_dir[i]
		new /obj/structure/swarmer/swarmer_core_field(field_turf, shield_duration, dir)
