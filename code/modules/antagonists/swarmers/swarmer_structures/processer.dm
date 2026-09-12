/// How many organic items an organic processer can process at a time
#define SWARMER_ORGANIC_ITEM_PROCESS_LIMIT 5
/// How long does it take to process one organic item in organic processer
#define SWARMER_ORGANIC_ITEM_PROCESS_DELAY 10 SECONDS
/// How many organic resources we gain on item processing
#define SWARMER_ORGANIC_ITEM_PROCESS_GAIN (rand(1, 5))

/**
 * Swarmer organic processer
 *
 * Allows swarmers to process organic items, like
 * fruits, vegetables, or reagents in containers.
 * All items that can be processed
 * are listed in code/modules/antagonists/swarmers/swarmer_acts/core_swarmer_acts.dm
 */
/obj/structure/swarmer/organic_processer
	name = "swarmer organic processer"
	desc = "Переработчик, позволяющий обрабатывать органику в ресурсы \"Свармеров\"."
	swarmer_examine = "Обрабатывает овощи, реагенты. Не делает этого в открученном состоянии. Загрузка в эту машину происходит через атаку по данным предметам."
	icon_state = "bio_processer"
	max_integrity = 70
	/// How many items we are currently processing
	var/currently_processing = 0
	/// How much stuff can we process at once
	var/process_limit = SWARMER_ORGANIC_ITEM_PROCESS_LIMIT
	/// Active processing sound loop
	var/datum/looping_sound/swarmer_processer/sound_loop
	/// Spark system (since we use them a lot)
	var/datum/effect_system/spark_spread/spark_system

/obj/structure/swarmer/organic_processer/Initialize(mapload)
	. = ..()
	sound_loop = new(src, FALSE)
	spark_system = new
	spark_system.set_up(5, 0, src)
	spark_system.attach(src)

/obj/structure/swarmer/organic_processer/Destroy(force)
	QDEL_NULL(spark_system)
	QDEL_NULL(sound_loop)
	for(var/atom/movable/AM in src)
		AM.forceMove(loc)
	return ..()

// Restarts the process timer after a while
/obj/structure/swarmer/organic_processer/emp_act(severity)
	..()
	if(!currently_processing)
		return

	sound_loop.stop()
	addtimer(CALLBACK(sound_loop, TYPE_PROC_REF(/datum/looping_sound, start)), SWARMER_STRUCTURE_EMP_DURATION * severity, TIMER_UNIQUE | TIMER_OVERRIDE | TIMER_NO_HASH_WAIT | TIMER_DELETE_ME)
	animate(src, transform=matrix())
	addtimer(CALLBACK(GLOBAL_PROC, GLOBAL_PROC_REF(animate_rumble), src), SWARMER_STRUCTURE_EMP_DURATION * severity, TIMER_UNIQUE | TIMER_OVERRIDE | TIMER_NO_HASH_WAIT | TIMER_DELETE_ME)

	var/new_delay = SWARMER_ORGANIC_ITEM_PROCESS_DELAY + SWARMER_STRUCTURE_EMP_DURATION * severity
	addtimer(CALLBACK(src, PROC_REF(finish_processing)), new_delay, TIMER_UNIQUE | TIMER_OVERRIDE | TIMER_NO_HASH_WAIT | TIMER_DELETE_ME)

/**
 * Handles loading in items, checks if we have any space for them.
 * Returns TRUE if we have space.
 * Returns FALSE otherwise.
 */
/obj/structure/swarmer/organic_processer/proc/try_load_item(obj/item)
	if(!anchored)
		return FALSE
	if(currently_processing >= process_limit)
		return FALSE
	if(!currently_processing) // Start the timer if we dont have one currently
		addtimer(CALLBACK(src, PROC_REF(finish_processing)), SWARMER_ORGANIC_ITEM_PROCESS_DELAY, TIMER_UNIQUE | TIMER_OVERRIDE | TIMER_NO_HASH_WAIT | TIMER_DELETE_ME)
		sound_loop.start()
	if(item) // Sometimes we are putting "nothing", which is intended. Example: Clearing out hydroponic trays.
		item.forceMove(src)
	currently_processing += 1
	spark_system.start()
	animate_rumble(src)
	return TRUE

/**
 * Timer callback proc
 *
 * Deletes one item, if there are any in contents.
 * Adjusts organic resources.
 * If we have anything else to process, we restart the timer.
 */
/obj/structure/swarmer/organic_processer/proc/finish_processing()
	if(length(contents))
		var/obj/item = contents[1]
		contents -= item
		if(!QDELETED(item))
			qdel(item)
	balloon_alert_to_viewers("обработано!")
	spark_system.start()
	adjust_swarmer_organic_resources(SWARMER_ORGANIC_ITEM_PROCESS_GAIN)
	currently_processing -= 1
	if(currently_processing) // Restart the timer
		addtimer(CALLBACK(src, PROC_REF(finish_processing)), SWARMER_ORGANIC_ITEM_PROCESS_DELAY, TIMER_UNIQUE | TIMER_OVERRIDE | TIMER_NO_HASH_WAIT | TIMER_DELETE_ME)
		return

	sound_loop.stop()
	playsound(loc, 'sound/machines/ding.ogg', 50, TRUE)
	animate(src, transform=matrix()) // Reset animation if no work

/obj/structure/swarmer/organic_processer/swarmer_grab_act(mob/living/simple_animal/hostile/swarmer/swarmer)
	if(!currently_processing)
		return ..()

	swarmer.balloon_alert(swarmer, "не открутить, работает!")

/obj/structure/swarmer/organic_processer/get_ru_names()
	return alist(
		NOMINATIVE = "переработчик органики \"Свармеров\"",
		GENITIVE = "переработчика органики \"Свармеров\"",
		DATIVE = "переработчику органики \"Свармеров\"",
		ACCUSATIVE = "переработчик органики \"Свармеров\"",
		INSTRUMENTAL = "переработчиком органики \"Свармеров\"",
		PREPOSITIONAL = "переработчике органики \"Свармеров\""
	)

#undef SWARMER_ORGANIC_ITEM_PROCESS_LIMIT
#undef SWARMER_ORGANIC_ITEM_PROCESS_DELAY
#undef SWARMER_ORGANIC_ITEM_PROCESS_GAIN
