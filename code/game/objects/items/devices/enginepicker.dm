/obj/item/enginepicker
	name = "bluespace engine delivery device"
	desc = "Система доставки двигателя, основанная на блюспейс-технологиях. Есть возможность выбрать только один вариант. Устройство самоуничтожается после использования."
	icon = 'icons/obj/device.dmi'
	icon_state = "enginepicker"

	/// Engine beacons available to choose from; rebuilt from the global list each time the device is used.
	var/list/list_engine_beacons
	/// Whether a pick is already in progress. Blocks self-attack spam from spawning multiple engines.
	var/is_active = FALSE

/obj/item/enginepicker/get_ru_names()
	return alist(
		NOMINATIVE = "блюспейс устройство доставки двигателя",
		GENITIVE = "блюспейс устройства доставки двигателя",
		DATIVE = "блюспейс устройству доставки двигателя",
		ACCUSATIVE = "блюспейс устройство доставки двигателя",
		INSTRUMENTAL = "блюспейс устройством доставки двигателя",
		PREPOSITIONAL = "блюспейс устройстве доставки двигателя",
	)

/obj/item/enginepicker/Destroy()
	LAZYCLEARLIST(list_engine_beacons)
	return ..()

/obj/item/enginepicker/attack_self(mob/living/carbon/user)
	if(user.incapacitated())
		return
	if(is_active) // Self-attack spam exploit prevention.
		return
	is_active = TRUE

	locate_beacons()
	var/obj/item/beacon/engine/chosen_beacon = tgui_input_list(user, "Выберите двигатель станции:", "[declent_ru(NOMINATIVE)]", list_engine_beacons)
	if(!chosen_beacon)
		is_active = FALSE
		return
	process_choice(chosen_beacon, user)

/// Re-assigns all of the engine beacons in the global list to a local list.
/obj/item/enginepicker/proc/locate_beacons()
	LAZYCLEARLIST(list_engine_beacons)
	for(var/obj/item/beacon/engine/beacon in GLOB.engine_beacon_list)
		if(QDELETED(beacon)) // Keep qdeleted beacons out of the input pop-up.
			continue
		LAZYADD(list_engine_beacons, beacon)

/// Spawns and logs / announces the appropriate engine based on the choice made.
/obj/item/enginepicker/proc/process_choice(obj/item/beacon/engine/choice, mob/living/carbon/user)
	var/engine_type
	var/turf/target_turf = get_turf(choice)

	if(length(choice.enginetype) > 1) // Combined beacon: let the user pick which engine.
		engine_type = tgui_input_list(user, "Вы выбрали комбинированный маяк, какой вариант вы бы предпочли?", "[declent_ru(NOMINATIVE)]", choice.enginetype)
		if(!engine_type)
			is_active = FALSE
			return
	else
		engine_type = DEFAULTPICK(choice.enginetype, null) // Accounts for a possibly scrambled list with a single entry.

	var/generator_type
	switch(engine_type)
		if(ENGTYPE_TESLA)
			generator_type = /obj/machinery/the_singularitygen/tesla
		if(ENGTYPE_SING)
			generator_type = /obj/machinery/the_singularitygen
		if(ENGTYPE_TEG)
			generator_type = /obj/structure/closet/crate/secure/engineering/teg

	if(!generator_type)
		visible_message(span_notice("[DECLENT_RU_CAP(src, NOMINATIVE)] гудит! Маяк не найден или не выбран!"))
		is_active = FALSE
		return

	clearturf(target_turf) // qdels items / gibs mobs so an SM shard doesn't spawn on top of a poor sod.
	new generator_type(target_turf)

	announce_delivery(engine_type)

	visible_message(span_notice("[DECLENT_RU_CAP(src, NOMINATIVE)] начинает сильно вибрировать и шипеть, а затем быстро распадается!"))
	qdel(src) // Self-destructs to prevent crew from spawning multiple engines.

/// Announces the delivered engine type through a random living AI, if any are present.
/obj/item/enginepicker/proc/announce_delivery(engine_type)
	var/list/ai_mobs = list()
	for(var/mob/living/silicon/ai/ai_mob in GLOB.alive_mob_list)
		ai_mobs += ai_mob
	if(!length(ai_mobs))
		return
	var/mob/living/silicon/ai/announcer = pick(ai_mobs)
	announcer.say(";Произведена доставка двигателя типа: [engine_type].")

/// Deletes objects and mobs from the beacon's turf.
/obj/item/enginepicker/proc/clearturf(turf/target_turf)
	for(var/obj/item/item in target_turf)
		item.visible_message("[DECLENT_RU_CAP(item, NOMINATIVE)] превращается в пыль!")
		qdel(item)

	for(var/mob/living/living_mob in target_turf)
		living_mob.visible_message("[DECLENT_RU_CAP(living_mob, NOMINATIVE)] уничтожается!")
		living_mob.gib()
