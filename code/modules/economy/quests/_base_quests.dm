
#define MIN_PLAYERS_FOR_MIX 35

/datum/cargo_quests_storage
	/// List of purchase order categories.
	var/list/current_quests = list()
	///	Difficultly of task, datum
	var/datum/quest_difficulty/quest_difficulty
	/// If current quest storage is active, we will check it when the cargo shuttle is moving.
	var/active = FALSE
	/// The time it takes to complete this.
	var/quest_time = -1
	/// The time when it appeared.
	var/time_start
	/// Bonus for quick execution, if FALSE, then there is no bonus.
	var/fast_failed = FALSE
	/// Order customer, this distributes orders to different tabs in the console.
	var/datum/quest_customer/customer

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
	/// Date when the order was accepted
	var/order_date
	/// Time when the order was accepted
	var/order_time
	/// List of quest modificators
	var/list/modificators
	/// How many times we add time for order
	var/time_add_count = -1

/datum/cargo_quests_storage/proc/generate(easy_mode)
	if(!quest_difficulty)
		quest_difficulty = customer.get_difficulty()
	if(!quest_difficulty)
		quest_difficulty = easy_mode ? pickweight(SScargo_quests.easy_mode_difficulties) : pickweight(SScargo_quests.difficulties)
	quest_difficulty.generate_timer(src)
	for(var/I in 1 to rand(MIN_QUEST_LEN, MAX_QUEST_LEN))
		var/datum/cargo_quest/cargo_quest = add_quest()
		if(cargo_quest)
			current_quests += cargo_quest

	if(GLOB.security_level > SEC_LEVEL_RED)
		reward *= 2
	customer.change_reward(src)
	customer.special(src)

/datum/cargo_quests_storage/proc/add_quest(quest_type)

	if(length(customer.can_order))
		quest_type = pick(customer.can_order)


	if(!quest_type)
		var/list/possible_types = list()
		if((num_station_players() < MIN_PLAYERS_FOR_MIX) && (length(current_quests) == 2))
			for(var/datum/cargo_quest/quest as anything in current_quests)
				possible_types += quest.type
		else
			for(var/path in subtypesof(/datum/cargo_quest) - /datum/cargo_quest/thing)
				var/datum/cargo_quest/cargo_quest = path
				if(!(initial(cargo_quest.difficultly_flags) & quest_difficulty.diff_flag))
					continue
				possible_types += path
			possible_types.Remove(customer.cant_order)
		quest_type = pick(possible_types)

	for(var/datum/cargo_quest/quest as anything in current_quests)
		if(quest.type != quest_type)
			continue
		quest.add_goal(difficultly = quest_difficulty.diff_flag)
		quest.update_interface_icon()
		return

	return new quest_type(src)


/datum/cargo_quests_storage/proc/after_activated()
	if(!fast_check_timer)
		return
	add_time()
	if(world.time - time_start - 0.4 * quest_time + 120 SECONDS >= 0)
		deltimer(fast_check_timer)
		fast_check_timer = addtimer(VARSET_CALLBACK(src, fast_failed, TRUE), 120 SECONDS, TIMER_STOPPABLE)

/datum/cargo_quests_storage/proc/add_time(time = 3 MINUTES)
	var/timeleft = time_start + quest_time - world.time
	deltimer(quest_check_timer)
	quest_time += time
	quest_check_timer = addtimer(CALLBACK(SScargo_quests, TYPE_PROC_REF(/datum/controller/subsystem/cargo_quests, remove_quest), UID()), timeleft + time, TIMER_STOPPABLE)
	time_add_count++

/datum/cargo_quests_storage/proc/check_quest_completion(obj/structure/bigDelivery/closet, failed_quest_length, mismatch_content, quest_len)
	var/new_reward = reward
	modificators = list()

	if(closet.cc_tag != customer.departament_name)
		new_reward -= reward * 0.2
		modificators["departure_mismatch"] = TRUE

	if(mismatch_content)
		new_reward -= reward * 0.3 * mismatch_content
		modificators["content_mismatch"] = mismatch_content

	if(failed_quest_length)
		new_reward -= reward * (1/quest_len) * failed_quest_length
		modificators["content_missing"] = failed_quest_length
		modificators["quest_len"] = quest_len

	if(!failed_quest_length && !fast_failed)
		new_reward += reward * 0.4
		modificators["quick_shipment"] = TRUE

	if(time_add_count)
		new_reward -= time_add_count * reward * 0.1

	if(!modificators["departure_mismatch"] && !failed_quest_length && !mismatch_content)
		if(fast_failed)
			customer.set_sale(modificator = 1)
		else
			customer.set_sale(modificator = 2)

	if(new_reward <= 0)
		new_reward = 1

	new_reward = round(new_reward)

	return new_reward

/datum/cargo_quest
	/// Quest name, using in interface.
	var/quest_type_name = "generic"
	/// Link to the storage.
	var/datum/cargo_quests_storage/q_storage
	/// Quest desc, using in interface.
	var/list/desc = list()
	/// Item, which icon, used for category in interface.
	var/item_for_show
	/// Quest interface images, using in interface.
	var/list/interface_images = list()
	/// Requested order's item types, unless otherwise specified.
	var/list/req_items = list()
	///possible difficultly
	var/difficultly_flags
	
	
	var/cargo_quest_reward = 0 			//The reward for the quest, consider the debut of the roflcat
	var/list/bounty_jobs = list() 		//Positions that will be paid. (Noooo I won't do part of this in new)
	var/linked_departament = "Cargo" 	//The department key is specified to take it from the global list, no, I will not upload to new, I'm afraid to break even

/datum/cargo_quest/New(storage, read_datum = FALSE)
	if(!read_datum)
		q_storage = storage
		add_goal(difficultly = q_storage.quest_difficulty.diff_flag)
		update_interface_icon()

/datum/cargo_quest/proc/generate_goal_list(difficultly)
	return

/datum/cargo_quest/proc/add_goal(difficultly)
	return

/datum/cargo_quest/proc/length_quest()
	return

/datum/cargo_quest/proc/update_interface_icon()
	return

/datum/cargo_quest/proc/check_required_item(atom/movable/check_item)
	return

/datum/cargo_quest/proc/after_check()
	return TRUE

/datum/cargo_quest/proc/completed_quest()
	return TRUE

#undef MIN_PLAYERS_FOR_MIX
