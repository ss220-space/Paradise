#define QUEST_TYPE_VIRUS /datum/cargo_quest/thing/virus
#define QUEST_TYPE_XENOBIO /datum/cargo_quest/thing/xenobio
#define QUEST_TYPE_REAGENTS /datum/cargo_quest/reagents
#define QUEST_TYPE_BOTANY /datum/cargo_quest/thing/botanygenes
#define QUEST_TYPE_SEEDS /datum/cargo_quest/thing/seeds
#define QUEST_TYPE_ORGANS /datum/cargo_quest/thing/organs
#define QUEST_TYPE_GENES /datum/cargo_quest/thing/genes
#define QUEST_TYPE_DRINKS /datum/cargo_quest/reagents/drinks
#define QUEST_TYPE_FOODS /datum/cargo_quest/thing/foods
#define QUEST_TYPE_MINERALS /datum/cargo_quest/thing/minerals
#define QUEST_TYPE_MINER /datum/cargo_quest/thing/miner


/datum/cargo_quests_storage
	/// List of purchase order categories.
	var/list/current_quests = list()

	var/static/list/easy_quest_types = list(
		QUEST_TYPE_VIRUS,
		QUEST_TYPE_XENOBIO,
		QUEST_TYPE_REAGENTS,
		QUEST_TYPE_BOTANY,
		QUEST_TYPE_SEEDS,
		QUEST_TYPE_DRINKS,
		QUEST_TYPE_FOODS,
		QUEST_TYPE_MINERALS,
		QUEST_TYPE_MINER
	)
	var/static/list/normal_quest_types = list(
		QUEST_TYPE_VIRUS,
		QUEST_TYPE_XENOBIO,
		QUEST_TYPE_REAGENTS,
		QUEST_TYPE_BOTANY,
		QUEST_TYPE_ORGANS,
		QUEST_TYPE_DRINKS,
		QUEST_TYPE_MINERALS,
		QUEST_TYPE_MINER
	)
	var/static/list/hard_quest_types = list(
		QUEST_TYPE_VIRUS,
		QUEST_TYPE_XENOBIO,
		QUEST_TYPE_BOTANY,
		QUEST_TYPE_SEEDS,
		QUEST_TYPE_ORGANS,
		QUEST_TYPE_GENES,
		QUEST_TYPE_MINERALS
	)
	var/static/list/very_hard_quest_types = list(
		QUEST_TYPE_ORGANS,
		QUEST_TYPE_MINER
	)

	///	Difficultly of task, e.g. QUEST_DIFFICULTLY_EASY.
	var/quest_difficulty
	/// If current quest storage is active, we will check it when the cargo shuttle is moving.
	var/active = FALSE
	/// The time it takes to complete this.
	var/quest_time = -1
	/// The time when it appeared.
	var/time_start
	/// Bonus for quick execution, if FALSE, then there is no bonus.
	var/fast_failed = FALSE
	/// The required department for the order, for possible departments see centcomm_departamets.dm
	var/target_departament
	/// Order category, this distributes orders to different tabs in the console.
	var/customer

	/// The timer, when it expires, we will not receive a bonus for fast delivery.
	var/fast_check_timer
	/// The timer, when it expires, we will fail the quest.
	var/quest_check_timer

	/// Reward for quest.
	var/reward
	/// Name of the person who accepted the order.
	var/idname = "*None Provided*"
	/// Name of the person who accepted the order.
	var/idrank = "*None Provided*"
	///	If TRUE we can reroll this quest.
	var/can_reroll = TRUE
	///	Color, using in interface.
	var/reward_color = "Green"

/datum/cargo_quests_storage/New(customer, quest_type, difficulty)
	src.customer = customer
	quest_difficulty = difficulty
	if(customer == "plasma")
		quest_type = /datum/cargo_quest/thing/minerals/plasma
		quest_difficulty = QUEST_DIFFICULTY_NORMAL
	if(!quest_difficulty)
		generate_difficulty()
	generate_timer()
	generate_departament(customer)

	for(var/I in 1 to rand(2,4))
		var/datum/cargo_quest/cargo_quest = generate_quest(quest_type)
		if(cargo_quest)
			current_quests += cargo_quest

	generate_reward_color()

/datum/cargo_quests_storage/proc/generate_difficulty()
	var/difficulty = rand(1, 100)

	switch(difficulty)
		if(1 to 40)
			quest_difficulty = QUEST_DIFFICULTY_EASY
		if(36 to 66)
			quest_difficulty = QUEST_DIFFICULTY_NORMAL
		if(67 to 92)
			quest_difficulty = QUEST_DIFFICULTY_HARD
		else
			quest_difficulty = QUEST_DIFFICULTY_VERY_HARD

/datum/cargo_quests_storage/proc/generate_departament(customer)
	switch(customer)
		if("centcomm")
			target_departament = pick(GLOB.centcomm_departaments - GLOB.corporations)
		if("corporation")
			target_departament = pick(GLOB.corporations)
		if("plasma")
			target_departament = pick(GLOB.plasma_departaments)
		else
			customer = "private person"
			target_departament = null

/datum/cargo_quests_storage/proc/generate_timer()
	switch(quest_difficulty)
		if(QUEST_DIFFICULTY_EASY)
			quest_time = rand(15, 25) MINUTES
		if(QUEST_DIFFICULTY_NORMAL)
			quest_time = rand(20, 30) MINUTES
		if(QUEST_DIFFICULTY_HARD)
			quest_time = rand(30, 40) MINUTES
		if(QUEST_DIFFICULTY_VERY_HARD)
			quest_time = rand(30, 60) MINUTES
	time_start = world.time
	quest_check_timer = addtimer(CALLBACK(src, PROC_REF(quest_expired)), quest_time, TIMER_STOPPABLE)
	fast_check_timer = addtimer(VARSET_CALLBACK(src, fast_failed, TRUE), 0.4 * quest_time, TIMER_STOPPABLE)

/datum/cargo_quests_storage/proc/quest_expired(reroll, complete, list/modificators, old_reward = reward)
	GLOB.quest_storages.Remove(src)
	if(active && !reroll)
		for(var/obj/machinery/cargo_announcer/cargo_announcer in GLOB.cargo_announcers)
			cargo_announcer.print_report(src, complete, modificators, old_reward)
	var/datum/cargo_quests_storage/quest = new /datum/cargo_quests_storage(customer = src.customer)
	if(reroll)
		quest.can_reroll = FALSE
	if(src in GLOB.plasma_quest_storages)
		GLOB.plasma_quest_storages.Remove(src)
		GLOB.plasma_quest_storages += quest
	qdel(src)
	GLOB.quest_storages += quest


/datum/cargo_quests_storage/proc/generate_quest(quest_type)
	if(!quest_type)
		switch(quest_difficulty)
			if(QUEST_DIFFICULTY_EASY)
				quest_type = pick(easy_quest_types)
			if(QUEST_DIFFICULTY_NORMAL)
				quest_type = pick(normal_quest_types)
			if(QUEST_DIFFICULTY_HARD)
				quest_type = pick(hard_quest_types)
			if(QUEST_DIFFICULTY_VERY_HARD)
				quest_type = pick(very_hard_quest_types)

	for(var/datum/cargo_quest/quest in current_quests)
		if(quest.type == quest_type)
			quest.generate_goal(difficultly = quest_difficulty)
			quest.update_interface_icon()
			return

	return new quest_type(src)

/datum/cargo_quests_storage/proc/after_activated()
	if(!fast_check_timer)
		return
	if(world.time - time_start - 0.4 * quest_time < 120 SECONDS)
		deltimer(fast_check_timer)
		fast_check_timer = addtimer(VARSET_CALLBACK(src, fast_failed, TRUE), 120 SECONDS, TIMER_STOPPABLE)

/datum/cargo_quests_storage/proc/generate_reward_color()
	if(!reward)
		return
	switch(reward)
		if(1 to 250)
			reward_color = "Green"
		if(251 to 500)
			reward_color = "Yellow"
		if(501 to 1100)
			reward_color = "Orange"
		else
			reward_color = "Purple"
/datum/cargo_quests_storage/proc/check_quest_completion(obj/structure/bigDelivery/closet)
	if(!istype(closet) || !istype(closet.wrapped, /obj/structure/closet/crate))
		return FALSE

	if(!length(closet.wrapped.contents))
		return FALSE

	var/req_quantity = 0
	for(var/datum/cargo_quest/quest in current_quests)
		req_quantity += quest.length_quest()

	var/extra_items = 0
	for(var/atom/movable/item in closet.wrapped.contents)
		var/has_extra_item = TRUE
		for(var/datum/cargo_quest/quest in current_quests)
			if(!is_type_in_list(item, quest.req_items))
				continue
			if(quest.check_required_item(item))
				has_extra_item = FALSE
				break

		if(has_extra_item)
			extra_items++
			continue

		req_quantity--

	if(extra_items == length(closet.wrapped.contents))
		return FALSE

	var/failed_quest_length
	for(var/datum/cargo_quest/quest in current_quests)
		failed_quest_length += quest.length_quest()

	var/old_reward = reward
	var/list/modificators = list()

	if(target_departament && (closet.cc_tag != target_departament))
		reward -= old_reward * 0.2
		modificators["departure_mismatch"] = TRUE

	if(extra_items)
		reward -= old_reward * 0.3 * extra_items
		modificators["content_mismatch"] = extra_items

	if(req_quantity < 0)
		reward -= old_reward * -0.3 * req_quantity
		modificators["content_mismatch"] += -req_quantity

	if(failed_quest_length)
		reward -= old_reward * 0.5 * failed_quest_length
		modificators["content_missing"] = failed_quest_length

	if(!failed_quest_length && !fast_failed)
		reward += old_reward * 0.4
		modificators["quick_shipment"] = TRUE
		if(target_departament && (closet.cc_tag == target_departament))
			var/datum/centcomm_departament/dept = GLOB.centcomm_departaments[target_departament]
			dept.set_sale()

	if(reward <= 0)
		reward = 1

	if(target_departament in GLOB.corporations)
		reward *= 10

	quest_expired(complete = TRUE, modificators = modificators, old_reward = old_reward)

	return reward

/datum/cargo_quest
	/// Quest name, using in interface.
	var/quest_type_name = "generic"
	/// Link to the storage.
	var/datum/cargo_quests_storage/q_storage
	/// Quest desc, using in interface.
	var/desc
	/// Quest interface icons, using in interface.
	var/list/interface_icons = list()
	/// Quest interface icon states, using in interface.
	var/list/interface_icon_states = list()
	/// Requested order's item types, unless otherwise specified.
	var/list/req_items = list()


/datum/cargo_quest/New(storage)
	q_storage = storage
	generate_goal(difficultly = q_storage.quest_difficulty)
	update_interface_icon()

/datum/cargo_quest/proc/generate_goal(difficultly)
	return

/datum/cargo_quest/proc/length_quest()
	return

/datum/cargo_quest/proc/update_interface_icon()
	return


/datum/cargo_quest/proc/check_required_item(atom/movable/check_item)
	return


#undef QUEST_TYPE_VIRUS
#undef QUEST_TYPE_XENOBIO
#undef QUEST_TYPE_REAGENTS
#undef QUEST_TYPE_BOTANY
#undef QUEST_TYPE_SEEDS
#undef QUEST_TYPE_ORGANS
#undef QUEST_TYPE_GENES
#undef QUEST_TYPE_DRINKS
#undef QUEST_TYPE_FOODS
#undef QUEST_TYPE_MINERALS
#undef QUEST_TYPE_MINER
