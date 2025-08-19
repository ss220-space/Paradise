/obj/item/enginepicker
	name = "Bluespace Engine Delivery Device"
	desc = "Система доставки двигателя, основанная на блюспейс-технологиях. Есть возможность выбрать только один вариант. Устройство самоуничтожается после использования."
	icon = 'icons/obj/device.dmi'
	icon_state = "enginepicker"

	var/list/list_enginebeacons
	var/isactive = FALSE

/obj/item/enginepicker/get_ru_names()
	return list(
		NOMINATIVE = "Блюспейс устройство доставки двигателя",
		GENITIVE = "Блюспейс устройства доставки двигателя",
		DATIVE = "Блюспейс устройству доставки двигателя",
		ACCUSATIVE = "Блюспейс устройство доставки двигателя",
		INSTRUMENTAL = "Блюспейс устройством доставки двигателя",
		PREPOSITIONAL = "Блюспейс устройстве доставки двигателя"
	)

/obj/item/enginepicker/Destroy()
	LAZYCLEARLIST(list_enginebeacons)
	return ..()

/obj/item/enginepicker/attack_self(mob/living/carbon/user)
	if(user.incapacitated())
		return

	if(!isactive)
		isactive = TRUE	//Self-attack spam exploit prevention
	else
		return

	locatebeacons()
	var/E = tgui_input_list(user, "Выберите двигатель станции:", "[declent_ru(NOMINATIVE)]", list_enginebeacons)
	if(E)
		processchoice(E, user)
	else
		isactive = FALSE
		return

//This proc re-assigns all of engine beacons in the global list to a local list.
/obj/item/enginepicker/proc/locatebeacons()
	LAZYCLEARLIST(list_enginebeacons)
	for(var/obj/item/radio/beacon/engine/B in GLOB.engine_beacon_list)
		if(B && !QDELETED(B))	//This ensures that the input pop-up won't have any qdeleted beacons
			LAZYADD(list_enginebeacons, B)

//Spawns and logs / announces the appropriate engine based on the choice made
/obj/item/enginepicker/proc/processchoice(var/obj/item/radio/beacon/engine/choice, mob/living/carbon/user)
	var/issuccessful = FALSE	//Check for a successful choice
	var/engtype					//Engine type
	var/G						//Generator that will be spawned
	var/turf/T = get_turf(choice)

	if(choice.enginetype.len > 1)	//If the beacon has multiple engine types
		var/E = tgui_input_list(user, "Вы выбрали комбинированный маяк, какой вариант вы бы предпочли?", "[declent_ru(NOMINATIVE)]", choice.enginetype)
		if(E)
			engtype = E
			issuccessful = TRUE
		else
			isactive = FALSE
			return

	if(!engtype)				//If it has only one type
		engtype = DEFAULTPICK(choice.enginetype, null)	//This should(?) account for a possibly scrambled list with a single entry
	switch(engtype)
		if(ENGTYPE_TESLA)
			G = /obj/machinery/the_singularitygen/tesla
		if(ENGTYPE_SING)
			G = /obj/machinery/the_singularitygen

	if(G)	//This can only be not-null if the switch operation was successful
		issuccessful = TRUE

	if(issuccessful)
		clearturf(T)	//qdels all items / gibs all mobs on the turf. Let's not have an SM shard spawn on top of a poor sod.
		new G(T)		//Spawns the switch-selected engine on the chosen beacon's turf

		var/ailist[] = list()
		for(var/mob/living/silicon/ai/A in GLOB.alive_mob_list)
			ailist += A
		if(length(ailist))
			var/mob/living/silicon/ai/announcer = pick(ailist)
			announcer.say(";Произведена доставка двигателя типа: [engtype].")	//Let's announce the terrible choice to everyone

		visible_message(span_notice("[capitalize(declent_ru(NOMINATIVE))] начинает сильно вибрировать и шипеть, а затем быстро распадается!"))
		qdel(src)	//Self-destructs to prevent crew from spawning multiple engines.
	else
		visible_message(span_notice("[capitalize(declent_ru(NOMINATIVE))] гудит! Маяк не найден или не выбран!"))
		isactive = FALSE
		return

/// Deletes objects and mobs from the beacon's turf.
/obj/item/enginepicker/proc/clearturf(var/turf/T)
	for(var/obj/item/I in T)
		I.visible_message("[capitalize(I.declent_ru(NOMINATIVE))] превращается в пыль!")
		qdel(I)

	for(var/mob/living/M in T)
		M.visible_message("[capitalize(M.declent_ru(NOMINATIVE))] уничтожается!")
		M.gib()
