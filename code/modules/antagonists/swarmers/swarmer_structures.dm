/// List of all swarmer structures
GLOBAL_LIST_EMPTY(swarmer_objects)

/**
 * Swarmer structures
 *
 * Has 4 different interactions based on swarmer's intent, separated in swarmer_act().
 * All structures of this type allow swarmer projectiles to pass through them.
 */
/obj/structure/swarmer
	name = "swarmer structure"
	desc = "Вы не должны это видеть."
	icon = 'icons/obj/swarmer.dmi'
	layer = MOB_LAYER
	anchored = TRUE
	resistance_flags = FIRE_PROOF | UNACIDABLE | ACID_PROOF
	light_color = LIGHT_COLOR_CYAN
	max_integrity = 30
	anchored = TRUE
	density = 1
	/// Light range
	var/lon_range = 1
	/// Text shown on examine to swarmers
	var/swarmer_examine

/obj/structure/swarmer/Initialize(mapload)
	. = ..()
	GLOB.swarmer_objects += src
	set_light(lon_range)

/obj/structure/swarmer/Destroy(force)
	GLOB.swarmer_objects -= src
	return ..()

/obj/structure/swarmer/play_attack_sound(damage_amount, damage_type = BRUTE, damage_flag = 0)
	switch(damage_type)
		if(BRUTE)
			playsound(src, 'sound/weapons/egloves.ogg', 80, TRUE)
		if(BURN)
			playsound(src, 'sound/items/welder.ogg', 100, TRUE)

/// Special intent handling for swarmer clicks on swarmer structures. All structures are not interactable, if unanchored.
/obj/structure/swarmer/proc/swarmer_help_act(mob/living/simple_animal/hostile/swarmer/swarmer)
	SHOULD_CALL_PARENT(TRUE)
	if(!anchored)
		swarmer.balloon_alert(swarmer, "не прикручено!")
		return FALSE
	return TRUE

/// Special intent handling for swarmer clicks on swarmer structures. Used for repairing.
/obj/structure/swarmer/proc/swarmer_disarm_act(mob/living/simple_animal/hostile/swarmer/swarmer)
	SHOULD_CALL_PARENT(TRUE)
	swarmer.balloon_alert_to_viewers("чинит...", "починка...")
	if(!do_after(swarmer, SWARMER_REPAIR_DELAY(swarmer), src, max_interact_count = 1))
		swarmer.balloon_alert(swarmer, "сбито!")
		return
	if(!adjust_swarmer_metallic_resources(-SWARMER_REPAIR_COST))
		swarmer.balloon_alert(swarmer, "недостаточно ресурсов!")
		return
	if(!repair_damage(SWARMER_REPAIR_AMOUNT(swarmer)))
		swarmer.balloon_alert(swarmer, "полностью починено!")

/**
 * Special intent handling for swarmer clicks on swarmer structures. Used by builders for anchoring.
 *
 * Returns TRUE, if we successfully unanchored/anchored src.
 * Returns FALSE otherwise.
 */
/obj/structure/swarmer/proc/swarmer_grab_act(mob/living/simple_animal/hostile/swarmer/swarmer)
	SHOULD_CALL_PARENT(TRUE)
	if(!is_builderswarmer(swarmer))
		return FALSE
	var/message = anchored ? "открепляем..." : "прикрепляем..."
	swarmer.balloon_alert(swarmer, message)
	if(!do_after(swarmer, 3 SECONDS, src, max_interact_count = 1))
		swarmer.balloon_alert(swarmer, "сбито!")
		return FALSE
	swarmer.balloon_alert(swarmer, "успех!")
	playsound(loc, 'sound/effects/empulse.ogg', 75, TRUE)
	set_anchored(!anchored)
	update_icon(UPDATE_ICON_STATE)
	return TRUE

/// Special intent handling for swarmer clicks on swarmer structures. Used by builders for destroying.
/obj/structure/swarmer/proc/swarmer_harm_act(mob/living/simple_animal/hostile/swarmer/swarmer)
	SHOULD_CALL_PARENT(TRUE)
	if(!is_builderswarmer(swarmer))
		return FALSE
	var/confirm = tgui_alert(swarmer, "Вы уверены, что хотите РАЗОБРАТЬ [declent_ru(ACCUSATIVE)]?", "Разбор структуры", list("Да", "Нет"))
	if(confirm == "Нет")
		return
	swarmer.balloon_alert(swarmer, "уничтожаем...")
	if(!do_after(swarmer, 5 SECONDS, src, max_interact_count = 1))
		swarmer.balloon_alert(swarmer, "сбито!")
		return FALSE
	swarmer.balloon_alert(swarmer, "уничтожено!")
	var/obj/effect/temp_visual/swarmer/disintegration/disintegrate_effect = new(get_turf(src))
	disintegrate_effect.adjust_size(src)
	qdel(src)

// Allows for all swarmer structures to be shoot through with swarmer projectiles.
/obj/structure/swarmer/CanAllowThrough(atom/movable/mover, border_dir)
	. = ..()
	if(is_swarmerprojectile(mover))
		return TRUE

// All swarmer structures get damaged on emp_act.
/obj/structure/swarmer/emp_act(severity)
	..()
	take_damage(SWARMER_EMP_DAMAGE)

// Extra info shown to swarmers
/obj/structure/swarmer/examine(mob/user)
	. = ..()
	if(swarmer_examine)
		. += span_swarmer(swarmer_examine)

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
	density = 0

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
	desc = "Баррикада быстрой сборки. Свободно пропускает свармеров и их выстрелы."
	icon_state = "barricade"
	light_range = MINIMUM_USEFUL_LIGHT_RANGE
	max_integrity = 60

// Allows swarmers to pass barricades.
/obj/structure/swarmer/blockade/CanAllowThrough(atom/movable/mover, border_dir)
	. = ..()
	if(isswarmer(mover))
		return TRUE

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
 * Swarmer transport hub
 *
 * Allows swarmers to teleport between them.
 * Works the same way cult teleport runes work.
 */
/obj/structure/swarmer/transport_hub
	name = "swarmer hub"
	desc = "Телепортер \"Свармеров\", позволяющий им телепортироваться к другим телепортерам."
	swarmer_examine = "Можно использовать, нажав на телепортер в интенте \"Помощь\""
	icon_state = "hub_enabled"
	max_integrity = 100
	/// Key name of our hub, created on init and changed after on spell cast
	var/listkey
	/// Spark system (since we use them a lot)
	var/datum/effect_system/spark_spread/spark_system
	/// Current state (for emp act)
	var/enabled = TRUE

/obj/structure/swarmer/transport_hub/Initialize(mapload)
	. = ..()
	var/area/A = get_area(src)
	var/locname = initial(A.name)
	listkey = "[locname]" // Can be changed on conjure by a swarmer
	spark_system = new
	spark_system.set_up(5, 0, src)
	spark_system.attach(src)

/obj/structure/swarmer/transport_hub/Destroy()
	QDEL_NULL(spark_system)
	return ..()

/// Switches enabled var value
/obj/structure/swarmer/transport_hub/proc/toggle_enabled()
	enabled = !enabled
	update_icon(UPDATE_ICON_STATE)

// Turns off the hub for 10 * severity seconds
/obj/structure/swarmer/transport_hub/emp_act(severity)
	..()
	if(!enabled)
		return
	toggle_enabled()
	addtimer(CALLBACK(src, PROC_REF(toggle_enabled)), SWARMER_STRUCTURE_EMP_DURATION * severity, TIMER_DELETE_ME)

// Changes sprite based on if we are emped or unanchored
/obj/structure/swarmer/transport_hub/update_icon_state()
	icon_state = (enabled && anchored) ? initial(icon_state) : "hub_disabled"

/**
 * Main teleport proc
 *
 * Works the same way blood cult runes work.
 */
/obj/structure/swarmer/transport_hub/swarmer_help_act(mob/living/simple_animal/hostile/swarmer/swarmer)
	. = ..()
	if(!.)
		return
	if(!enabled) // Emped
		swarmer.balloon_alert(swarmer, "калибруется!")
		return

	var/list/potential_hubs = get_hub_list()
	if(!length(potential_hubs))
		swarmer.balloon_alert(swarmer, "отсутствуют другие хабы!")
		return

	var/input_hub_key = tgui_input_list(swarmer, "Выберите хаб для телепорта.", "Выбор хаба", potential_hubs) //we know what key they picked
	var/obj/structure/swarmer/transport_hub/actual_selected_hub = potential_hubs[input_hub_key] //what hub does that key correspond to?
	if(!Adjacent(swarmer) || QDELETED(src) || !actual_selected_hub)
		return

	if(!do_after(swarmer, SWARMER_TELEPORT_DELAY(swarmer), src, max_interact_count = 1))
		swarmer.balloon_alert(swarmer, "нельзя двигаться!")
		return
	var/turf/target_turf = get_turf(actual_selected_hub)
	swarmer.forceMove(target_turf)
	spark_system.start()
	actual_selected_hub.spark_system.start()

/// Proc used to get a list of all active hubs
/obj/structure/swarmer/transport_hub/proc/get_hub_list()
	var/list/potential_hubs = list()
	var/list/hub_names = list()
	var/list/duplicate_hub_count = list()
	for(var/obj/structure/swarmer/transport_hub/hub in GLOB.swarmer_objects)
		if(!hub.enabled)
			continue
		var/resultkey = hub.listkey
		if(resultkey in hub_names)
			duplicate_hub_count[resultkey]++
			resultkey = "[resultkey] ([duplicate_hub_count[resultkey]])"
		else
			hub_names += resultkey
			duplicate_hub_count[resultkey] = 1
		if(hub != src)
			potential_hubs[resultkey] = hub
	return potential_hubs

/obj/structure/swarmer/transport_hub/get_ru_names()
	return alist(
		NOMINATIVE = "телепортатор \"Свармеров\"",
		GENITIVE = "телепортатора \"Свармеров\"",
		DATIVE = "телепортатору \"Свармеров\"",
		ACCUSATIVE = "телепортатор \"Свармеров\"",
		INSTRUMENTAL = "телепортатором \"Свармеров\"",
		PREPOSITIONAL = "телепортаторе \"Свармеров\""
	)

/**
 * Swarmer organic processer
 *
 * Allows swarmers to process organic items, like
 * fruits, vegetables, or reagents in containers.
 * All items that can be processed
 * are listed in /mob/living/simple_animal/hostile/swarmer/proc/on_attack_target.
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
	/// Spark system (since we use them a lot)
	var/datum/effect_system/spark_spread/spark_system

/obj/structure/swarmer/organic_processer/Initialize(mapload)
	. = ..()
	RegisterSignal(src, COMSIG_SWARMER_PROCESS_ORGANIC_ITEM_CHECK, PROC_REF(try_load_item))
	spark_system = new
	spark_system.set_up(5, 0, src)
	spark_system.attach(src)

/obj/structure/swarmer/organic_processer/Destroy(force)
	UnregisterSignal(src, COMSIG_SWARMER_PROCESS_ORGANIC_ITEM_CHECK)
	QDEL_NULL(spark_system)
	for(var/atom/movable/AM in src)
		AM.forceMove(loc)
	return ..()

// Restarts the process timer after a while
/obj/structure/swarmer/organic_processer/emp_act(severity)
	..()
	if(!currently_processing)
		return
	var/new_delay = SWARMER_ORGANIC_ITEM_PROCESS_DELAY + SWARMER_STRUCTURE_EMP_DURATION * severity
	animate(src, transform=matrix()) // Reset animation if disabled
	addtimer(CALLBACK(src, PROC_REF(finish_processing)), new_delay, TIMER_UNIQUE | TIMER_OVERRIDE | TIMER_NO_HASH_WAIT | TIMER_DELETE_ME)
	addtimer(CALLBACK(src, TYPE_PROC_REF(/atom, spasm_animation)), SWARMER_STRUCTURE_EMP_DURATION * severity, TIMER_UNIQUE | TIMER_OVERRIDE | TIMER_NO_HASH_WAIT | TIMER_DELETE_ME)

/**
 * Main signal proc of this structure.
 *
 * Handles loading in items, checks if we have any space for them.
 * Returns TRUE if we have space.
 * Returns FALSE otherwise.
 */
/obj/structure/swarmer/organic_processer/proc/try_load_item(datum/source, obj/item)
	SIGNAL_HANDLER
	if(!anchored)
		return FALSE
	if(currently_processing >= process_limit)
		return FALSE
	if(!currently_processing) // Start the timer if we dont have one currently
		addtimer(CALLBACK(src, PROC_REF(finish_processing)), SWARMER_ORGANIC_ITEM_PROCESS_DELAY, TIMER_UNIQUE | TIMER_OVERRIDE | TIMER_NO_HASH_WAIT | TIMER_DELETE_ME)
	if(item) // Sometimes we are putting "nothing", which is intended. Example: Clearing out hydroponic trays.
		item.forceMove(src)
	currently_processing += 1
	spark_system.start()
	spasm_animation()
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
	playsound(loc, 'sound/machines/ding.ogg', 50, TRUE)
	adjust_swarmer_organic_resources(SWARMER_ORGANIC_ITEM_PROCESS_GAIN)
	currently_processing -= 1
	if(currently_processing) // Restart the timer
		addtimer(CALLBACK(src, PROC_REF(finish_processing)), SWARMER_ORGANIC_ITEM_PROCESS_DELAY, TIMER_UNIQUE | TIMER_OVERRIDE | TIMER_NO_HASH_WAIT | TIMER_DELETE_ME)
		return
	animate(src, transform=matrix()) // Reset animation if no work

/obj/structure/swarmer/organic_processer/get_ru_names()
	return alist(
		NOMINATIVE = "переработчик органики \"Свармеров\"",
		GENITIVE = "переработчика органики \"Свармеров\"",
		DATIVE = "переработчику органики \"Свармеров\"",
		ACCUSATIVE = "переработчик органики \"Свармеров\"",
		INSTRUMENTAL = "переработчиком органики \"Свармеров\"",
		PREPOSITIONAL = "переработчике органики \"Свармеров\""
	)

/**
 * Swarmer mob analyzer
 *
 * Allows swarmers to analyze mobs for organic resources.
 */
/obj/structure/swarmer/organic_analyzer
	name = "swarmer organic analyzer"
	desc = "Устройство \"Свармеров\", которое вырабатывает ресурсы, извлекая из живых существ некритически важные органы и части тела."
	swarmer_examine = "Анализирует живых существ. Не делает этого в открученном состоянии. Загрузка в эту машину происходит через Ctrl + Click по существу свармером."
	icon_state = "bio_analyzer"
	max_integrity = 150
	/// Current mob in src
	var/mob/living/occupant
	/// Spark system (since we use them a lot)
	var/datum/effect_system/spark_spread/spark_system
	/// Organ removal chance for non-machine carbons
	var/organ_removal_chance = SWARMER_ANALYZE_ORGAN_REMOVE_CHANCE
	/// How many bodyparts we take from machine carbons
	var/machine_organ_take = SWARMER_ANALYZE_FINISH_MACHINE_TAKE

/obj/structure/swarmer/organic_analyzer/Initialize(mapload)
	. = ..()
	RegisterSignal(src, COMSIG_SWARMER_ANALYZE_MOB_CHECK, PROC_REF(try_load_mob))
	spark_system = new
	spark_system.set_up(5, 0, src)
	spark_system.attach(src)

/obj/structure/swarmer/organic_analyzer/Destroy(force)
	UnregisterSignal(src, COMSIG_SWARMER_ANALYZE_MOB_CHECK)
	QDEL_NULL(spark_system)
	if(occupant)
		occupant.forceMove(loc)
		occupant.SetParalysis(0)
		occupant.SetSleeping(10 SECONDS)
	occupant = null
	return ..()

// Restarts the analyze timer after a while
/obj/structure/swarmer/organic_analyzer/emp_act(severity)
	..()
	if(!occupant)
		return
	var/new_delay = SWARMER_ANALYZE_DELAY(occupant) + SWARMER_STRUCTURE_EMP_DURATION * severity
	animate(src, transform=matrix()) // Reset animation if disabled
	addtimer(CALLBACK(src, TYPE_PROC_REF(/atom, spasm_animation)), SWARMER_STRUCTURE_EMP_DURATION * severity, TIMER_UNIQUE | TIMER_OVERRIDE | TIMER_NO_HASH_WAIT | TIMER_DELETE_ME)
	addtimer(CALLBACK(src, PROC_REF(finish_analyzing)), new_delay, TIMER_UNIQUE | TIMER_OVERRIDE | TIMER_NO_HASH_WAIT | TIMER_DELETE_ME)
	occupant.SetParalysis(new_delay + 1 SECONDS, TRUE) // Extra second just incase
	occupant.SetSleeping(new_delay + 1 SECONDS) // Extra second just incase

// Updates icon state based on occupant
/obj/structure/swarmer/organic_analyzer/update_icon_state()
	icon_state = occupant ? "[initial(icon_state)]_mob" : initial(icon_state)

/**
 * Main signal proc of this structure.
 *
 * Handles loading in a mob, checks if we have any space for them.
 * Returns TRUE if we have space.
 * Returns FALSE otherwise.
 */
/obj/structure/swarmer/organic_analyzer/proc/try_load_mob(datum/source, mob/living/target)
	SIGNAL_HANDLER
	if(!anchored)
		return FALSE
	if(occupant)
		return FALSE
	occupant = target
	var/delay = SWARMER_ANALYZE_DELAY(target)
	occupant.Paralyse(delay + 1 SECONDS, TRUE) // Extra second just incase
	occupant.Sleeping(delay + 1 SECONDS) // Extra second just incase
	occupant.forceMove(src)
	addtimer(CALLBACK(src, PROC_REF(finish_analyzing)), delay, TIMER_UNIQUE | TIMER_OVERRIDE | TIMER_NO_HASH_WAIT | TIMER_DELETE_ME)
	spark_system.start()
	update_icon(UPDATE_ICON_STATE)
	spasm_animation()
	return TRUE

/**
 * Callback proc from signal proc
 *
 * Deletes a random non critical bodypart/organ,
 * adjusts swarmer resources,
 * teleports the target to a safe place.
 */
/obj/structure/swarmer/organic_analyzer/proc/finish_analyzing()
	if(QDELETED(occupant))
		occupant = null
		return
	if(!(locate(occupant) in src))
		occupant = null
		return
	balloon_alert_to_viewers("обработано!")
	animate(src, transform=matrix()) // Reset animation if no work
	playsound(loc, 'sound/machines/ding.ogg', 50, TRUE)
	take_random_organs()
	adjust_resources()
	teleport_to_safe()
	if(iscarbon(occupant))
		var/mob/living/carbon/target = occupant
		if(target.handcuffed)
			target.clear_cuffs(target.handcuffed)
	occupant = null
	update_icon(UPDATE_ICON_STATE)

/**
 * Proc used to adjust resources based on occupant mob
 *
 * Adjusts twice less from corpses.
 */
/obj/structure/swarmer/organic_analyzer/proc/adjust_resources()
	var/modifier = occupant.is_dead() ? 0.5 : 1 // We get less from corpses
	if(ismachineperson(occupant))
		return adjust_swarmer_metallic_resources(SWARMER_ANALYZE_MACHINE_GAIN * modifier)
	if(iscarbon(occupant))
		modifier = occupant.mind ? 1 : 0.3 // Much less from carbons with no mind
		return adjust_swarmer_organic_resources(SWARMER_ANALYZE_CARBON_GAIN * modifier)
	if(ishostile(occupant))
		return adjust_swarmer_organic_resources(SWARMER_ANALYZE_HOSTILE_GAIN * modifier)
	if(isliving(occupant))
		return adjust_swarmer_organic_resources(SWARMER_ANALYZE_LIVING_GAIN * modifier)

/**
 * Proc used to get rid of random bodyparts and organs
 *
 * Removes [machine_organ_take] bodyparts from machine carbons, removes
 * safe to remove organs and bodyparts from other carbons with a chance one by one.
 *
 * Adjusts metallic resources if there was
 * a robotic organ removed on non-machine analyze.
 */
/obj/structure/swarmer/organic_analyzer/proc/take_random_organs()
	if(!ishuman(occupant))
		return
	var/mob/living/carbon/human/target = occupant
	if(ismachineperson(target)) // Machine handling
		var/removed_amount = 0
		while(removed_amount < machine_organ_take)
			var/obj/item/organ/external/bodypart = pick(target.bodyparts)
			if(ischest(bodypart) || isgroin(bodypart))
				continue
			removed_amount += 1
			var/atom/movable/thing = bodypart.remove(target)
			if(!QDELETED(thing))
				qdel(thing)
		target.UpdateAppearance()
		return
	for(var/obj/item/organ/external/bodypart as anything in target.bodyparts) // Non machine handling
		if(isgroin(bodypart)) // groin gets skipped
			continue
		if(ischest(bodypart)) // Liver, kidneys
			var/list/organ_list = target.get_organs_zone(BODY_ZONE_CHEST)
			for(var/obj/item/organ/internal/organ as anything in organ_list)
				if(!istype(organ, /obj/item/organ/internal/liver) && !istype(organ, /obj/item/organ/internal/kidneys))
					continue
				if(!prob(organ_removal_chance))
					continue
				if(organ.is_robotic())
					adjust_swarmer_metallic_resources(SWARMER_ANALYZE_ROBOTIC_ORGAN_GAIN)
				var/atom/movable/thing = organ.remove(target)
				if(!QDELETED(thing))
					qdel(thing)
			continue
		if(ishead(bodypart)) // Eyes, ears
			var/list/organ_list = target.get_organs_zone(BODY_ZONE_HEAD)
			for(var/obj/item/organ/internal/organ as anything in organ_list)
				if(!istype(organ, /obj/item/organ/internal/eyes) && !istype(organ, /obj/item/organ/internal/ears))
					continue
				if(!prob(organ_removal_chance))
					continue
				if(organ.is_robotic())
					adjust_swarmer_metallic_resources(SWARMER_ANALYZE_ROBOTIC_ORGAN_GAIN)
				var/atom/movable/thing = organ.remove(target)
				if(!QDELETED(thing))
					qdel(thing)
			continue
		if(!prob(organ_removal_chance)) // / Arms, legs, tails, wings
			continue
		if(!bodypart.owner) // Trying to remove removed bodypart child, and thats bad
			continue
		if(bodypart.is_robotic())
			adjust_swarmer_metallic_resources(SWARMER_ANALYZE_ROBOTIC_ORGAN_GAIN)
		var/atom/movable/thing = bodypart.remove(target)
		if(!QDELETED(thing))
			qdel(thing)
	target.UpdateAppearance()

/// Proc used to get rid of the occupant (teleport it to a safe place)
/obj/structure/swarmer/organic_analyzer/proc/teleport_to_safe()
	var/turf/safe_turf = find_safe_turf(z)
	if(!safe_turf)
		occupant.forceMove(loc)
		return
	playsound(src, 'sound/effects/sparks4.ogg', 50, TRUE)
	occupant.SetSleeping(5 SECONDS)
	do_teleport(occupant, safe_turf)

/obj/structure/swarmer/organic_analyzer/get_ru_names()
	return alist(
		NOMINATIVE = "анализатор \"Свармеров\"",
		GENITIVE = "анализатора \"Свармеров\"",
		DATIVE = "анализатору \"Свармеров\"",
		ACCUSATIVE = "анализатор \"Свармеров\"",
		INSTRUMENTAL = "анализатором \"Свармеров\"",
		PREPOSITIONAL = "анализаторе \"Свармеров\""
	)

/**
 * Swarmer repair station
 *
 * Slowly repairs swarmer inside.
 */
/obj/structure/swarmer/repair_station
	name = "swarmer repair station"
	desc = "Ремонтная станция \"Свармеров\"."
	swarmer_examine = "Войти в ремонтную станцию можно с помощью нажатия на него в интенте \"Помощь\"."
	icon_state = "repair_station"
	max_integrity = 100
	/// Current swarmer in src
	var/mob/living/simple_animal/occupant
	/// Turf occupant entered from
	var/turf/enter_turf
	/// How much a swarmer gets healed per tick
	var/heal_per_tick = SWARMER_REPAIR_STATION_HEAL

/obj/structure/swarmer/repair_station/Destroy(force)
	go_out()
	if(datum_flags & DF_ISPROCESSING)
		STOP_PROCESSING(SSobj, src)
	return ..()

// Just kicks the swarmer out of the repair station on strong emp.
/obj/structure/swarmer/repair_station/emp_act(severity)
	..()
	if(!occupant)
		return
	if(severity <= 1)
		return
	go_out()

// Updates icon state based on occupant var
/obj/structure/swarmer/repair_station/update_icon_state()
	icon_state = occupant ? "[initial(icon_state)]_a" : initial(icon_state)

// Updates overlays based on occupant
/obj/structure/swarmer/repair_station/update_overlays()
	. = ..()
	if(!occupant)
		return .
	var/image/swarmer_image = image(icon = occupant.icon, icon_state = occupant.icon_state, layer = ABOVE_MOB_LAYER, dir = SOUTH)
	var/image/repair_image = image(icon = 'icons/effects/swarmer.dmi', icon_state = "repair_effect", layer = ABOVE_ALL_MOB_LAYER)
	. += swarmer_image
	. += repair_image

// Main enter proc
/obj/structure/swarmer/repair_station/swarmer_help_act(mob/living/simple_animal/hostile/swarmer/swarmer)
	. = ..()
	if(!.)
		return
	if(occupant)
		swarmer.balloon_alert(swarmer, "занято!")
		return
	swarmer.balloon_alert(swarmer, "входим...")
	if(!do_after(swarmer, SWARMER_REPAIR_STATION_DELAY, src, max_interact_count = 1))
		swarmer.balloon_alert(swarmer, "сбито!")
		return
	enter_turf = get_turf(swarmer)
	swarmer.forceMove(src)
	occupant = swarmer
	update_icon(UPDATE_ICON_STATE | UPDATE_OVERLAYS)
	START_PROCESSING(SSobj, src)

/obj/structure/swarmer/repair_station/process(seconds_per_tick)
	if(QDELETED(occupant))
		occupant = null
		update_icon(UPDATE_ICON_STATE | UPDATE_OVERLAYS)
		return PROCESS_KILL
	if(!(locate(occupant) in src)) // Extra precaution
		occupant = null
		update_icon(UPDATE_ICON_STATE | UPDATE_OVERLAYS)
		return PROCESS_KILL
	if(occupant.health == occupant.maxHealth) // Prevent afkers in repair stations
		to_chat(occupant, span_notice("Мы полностью вылечены! Выходим из ремонтной станции..."))
		go_out()
		return
	occupant.adjustHealth(-heal_per_tick)

/obj/structure/swarmer/repair_station/relaymove()
	go_out()

/// Exit repair station procs
/obj/structure/swarmer/repair_station/proc/go_out()
	if(!occupant)
		enter_turf = null
		return
	occupant.forceMove(enter_turf)
	occupant = null
	enter_turf = null
	update_icon(UPDATE_ICON_STATE | UPDATE_OVERLAYS)
	STOP_PROCESSING(SSobj, src)

/obj/structure/swarmer/repair_station/get_ru_names()
	return alist(
		NOMINATIVE = "станция починки \"Свармеров\"",
		GENITIVE = "станции починки \"Свармеров\"",
		DATIVE = "станции починки \"Свармеров\"",
		ACCUSATIVE = "станцию починки \"Свармеров\"",
		INSTRUMENTAL = "станцией починки \"Свармеров\"",
		PREPOSITIONAL = "станции починки \"Свармеров\""
	)

/**
 * Swarmer resource storage
 *
 * Increases modifier of metal collecting by swarmers. Stackable.
 */
/obj/structure/swarmer/resource_storage
	name = "swarmer resource storage"
	desc = "Хранилище ресурсов \"Свармеров\", позволяющее собирать больше материалов с объектов."
	swarmer_examine = "Увеличивает количество ресурсов, полученного с ручного собирания."
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
 * Swarmer ACP turret
 *
 * Slams the ground every few seconds on proximity with enemy mob,
 * dealing stamina damage, slowing with a chance, and stopping
 * reagent metabolization to all targets in specific range.
 */
/obj/structure/swarmer/acp_turret
	name = "swarmer ACP turret"
	desc = "Стационарная установка \"Свармеров\", которая способна оглушать и влиять на магнитное поле целей."
	swarmer_examine = "Бьёт всех по области, нанося урон стамине и останавливая метаболизацию реагентов."
	icon_state = "turret_acp"
	max_integrity = 200
	/// Overlay set on targets if we hit them
	var/static/mutable_appearance/strike_overlay
	/// Icon state for flick (when we strike)
	var/strike_icon_state = "turret_acp_strike"
	/// Cooldown of our turret
	COOLDOWN_DECLARE(cooldown)
	/// Our cooldown after turret striked
	var/cooldown_after_strike = SWARMER_ACP_COOLDOWN
	/// Range of our turret
	var/range = SWARMER_ACP_RANGE
	/// Basic damage of our turret
	var/damage = SWARMER_ACP_DAMAGE
	/// Slowed chance after hit
	var/slowed_chance = SWARMER_ACP_SLOWED_CHANCE
	/// Slowed duration after hit
	var/slowed_duration = SWARMER_ACP_SLOWED_DURATION
	/// Targets that are currently processed by turret. Used by process()
	var/list/processing_targets = list()

/obj/structure/swarmer/acp_turret/Initialize(mapload)
	. = ..()
	if(!strike_overlay)
		strike_overlay = mutable_appearance('icons/effects/swarmer.dmi', "acp_effect", ABOVE_ALL_MOB_LAYER)
	proximity_monitor = new(src, range)

/obj/structure/swarmer/acp_turret/Destroy(force)
	QDEL_NULL(proximity_monitor)
	if(datum_flags & DF_ISPROCESSING)
		STOP_PROCESSING(SSobj, src)
	return ..()

// Restarts the cooldown. Doesn't increase the cooldown.
/obj/structure/swarmer/acp_turret/emp_act(severity)
	..()
	COOLDOWN_START(src, cooldown, cooldown_after_strike)

/obj/structure/swarmer/acp_turret/HasProximity(atom/movable/AM)
	handle_interloper(AM)

/// Updates targets on proximity
/obj/structure/swarmer/acp_turret/proc/handle_interloper(atom/movable/entity)
	if(entity.invisibility > SEE_INVISIBLE_LIVING || entity.alpha == NINJA_ALPHA_INVISIBILITY) // Let's not do typechecks and stuff on invisible things
		return
	if(!isliving(entity) || isswarmer(entity))
		return
	processing_targets[entity] = TRUE // Associative for performance
	if(!(datum_flags & DF_ISPROCESSING))
		START_PROCESSING(SSobj, src)

// Handles checking if targets are in range and calls the attack
/obj/structure/swarmer/acp_turret/process()
	if(!length(processing_targets))
		return PROCESS_KILL
	if(!anchored)
		return
	//Verify that targeted mobs are in our range. Otherwise, just remove them from processing.
	for(var/mob/mob as anything in processing_targets)
		if(!IN_GIVEN_RANGE(loc, mob, range))
			processing_targets -= mob
	if(!COOLDOWN_FINISHED(src, cooldown))
		return
	strike()
	COOLDOWN_START(src, cooldown, cooldown_after_strike)

/// Calculate effects for all targets, apply metabolize block status effect
/obj/structure/swarmer/acp_turret/proc/strike()
	flick(strike_icon_state, src)
	var/turf/our_turf = get_turf(src)
	new /obj/effect/temp_visual/acp_stomp(our_turf, range)
	for(var/mob/living/target as anything in processing_targets)
		apply_range_based_effects(target)
		target.apply_status_effect(STATUS_EFFECT_METABOLIZE_BLOCK, SWARMER_ACP_DISABLE_METABOLIZATION_DURATION, strike_overlay)

/// Applies stamina damage, slow duration and chance, together with effects based on distance relative to the turret
/obj/structure/swarmer/acp_turret/proc/apply_range_based_effects(mob/living/target)
	var/modifier = range - get_dist(src, target)
	var/increase_modifier = max((range - 1), 1)
	// Slow is guaranteed if target is next to the turret.
	var/slow_chance_increase_per_tile = (100 - slowed_chance) * (1 / increase_modifier)
	var/slow_duration_increase_per_tile = slowed_duration * (1 / increase_modifier)
	var/final_slowed_chance = round(slowed_chance + modifier * slow_chance_increase_per_tile)
	var/final_slowed_duration = round(slowed_duration + modifier * slow_duration_increase_per_tile)
	var/final_damage = damage + damage * modifier * SWARMER_ACP_RANGE_DAMAGE_MODIFIER

	target.apply_damage(final_damage, STAMINA)
	if(prob(final_slowed_chance))
		target.Slowed(final_slowed_duration, SWARMER_ACP_SLOWED_MULTIPLIER)

/obj/structure/swarmer/acp_turret/get_ru_names()
	return alist(
		NOMINATIVE = "стационарная турель \"Свармеров\"",
		GENITIVE = "стационарной турели \"Свармеров\"",
		DATIVE = "стационарной турели \"Свармеров\"",
		ACCUSATIVE = "стационарную турель \"Свармеров\"",
		INSTRUMENTAL = "стационарной турелью \"Свармеров\"",
		PREPOSITIONAL = "стационарной турели \"Свармеров\""
	)

// ACP strike effect
/obj/effect/temp_visual/acp_stomp
	icon = 'icons/effects/64x64.dmi'
	icon_state = "swarmer_acp"
	duration = 0.8 SECONDS
	pixel_y = -16
	pixel_x = -16

/obj/effect/temp_visual/acp_stomp/Initialize(mapload, range = 1)
	. = ..()
	// Reduce to 32x32
	var/matrix/M = matrix() * 0.5
	transform = M
	// Increase size based on range input + 1 (accounting for src tile)
	animate(src, transform = M * 2 * (range + 1), time = duration, alpha = 0)
	playsound(loc, 'sound/swarmer/acp_turret.ogg', 100, TRUE)
