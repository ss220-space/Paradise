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
	/// Team that we send signals to
	var/datum/team/swarmer_team/team

/obj/structure/swarmer/resource_storage/Initialize(mapload)
	. = ..()
	team = GLOB.antagonist_teams[/datum/team/swarmer_team]
	if(!team)
		team = new
	SEND_SIGNAL(team, COMSIG_SWARMER_STORAGE_INITIALIZED)

/obj/structure/swarmer/resource_storage/Destroy(force)
	SEND_SIGNAL(team, COMSIG_SWARMER_STORAGE_DESTROYED)
	team = null
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
	if(iswallturf(loc))
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
