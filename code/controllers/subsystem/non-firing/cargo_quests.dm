#define NUMBER_OF_CC_QUEST 8
#define NUMBER_OF_CORP_QUEST 4
#define NUMBER_OF_PLASMA_QUEST 1

//Abandon hope, everyone who enters here

//This place is cursed, don't try to understand it and change it. It will kill you

//Reading the lines more and more, I realize that I shouldn't have come here.

//THERE IS NO GOD BEYOND THAT
SUBSYSTEM_DEF(cargo_quests)
	name = "Cargo Quests"
	flags = SS_NO_FIRE
	cpu_display = SS_CPUDISPLAY_LOW
	ss_id = "cargo_quests"
	init_order = INIT_ORDER_CARGO_QUESTS

	var/list/centcomm_departaments = list()
	var/list/corporations = list()
	var/list/plasma_departaments = list()
	var/list/quest_storages = list()
	var/list/plasma_quests = list()
	var/list/difficulties = list()
	var/list/easy_mode_difficulties = list()

/datum/controller/subsystem/cargo_quests/Initialize()

	for(var/typepath in subtypesof(/datum/quest_customer/centcomm))
		var/datum/quest_customer/departament = new typepath()
		if(!departament.departament_name)
			continue
		centcomm_departaments += departament

	for(var/typepath in subtypesof(/datum/quest_customer/corp))
		var/datum/quest_customer/corp/corp = new typepath()
		if(!corp.departament_name)
			continue
		corporations += corp

	for(var/typepath in subtypesof(/datum/quest_customer/plasma))
		var/datum/quest_customer/plasma/plasma_dep = new typepath()
		if(!plasma_dep.departament_name)
			continue
		plasma_departaments += plasma_dep

	for(var/typepath in subtypesof(/datum/quest_difficulty))
		var/datum/quest_difficulty/quest_difficulty = new typepath()
		if(!quest_difficulty.weight)
			continue
		difficulties += quest_difficulty
		difficulties[quest_difficulty] = quest_difficulty.weight
		if(quest_difficulty.for_easy_mode)
			easy_mode_difficulties += quest_difficulty
			easy_mode_difficulties[quest_difficulty] = quest_difficulty.weight

	return SS_INIT_SUCCESS


/datum/controller/subsystem/cargo_quests/proc/roll_start_quests()
	for(var/I = 1 to NUMBER_OF_CC_QUEST)
		create_new_quest(pick(centcomm_departaments), easy_mode = TRUE)
	for(var/I = 1 to NUMBER_OF_CORP_QUEST)
		create_new_quest(pick(corporations), easy_mode = TRUE)
	for(var/I = 1 to NUMBER_OF_PLASMA_QUEST)
		create_new_quest(pick(plasma_departaments), easy_mode = TRUE)

/datum/controller/subsystem/cargo_quests/proc/get_customer_list(datum/quest_customer/customer)
	if(customer in centcomm_departaments)
		return centcomm_departaments
	if(customer in corporations)
		return corporations
	if(customer in plasma_departaments)
		return plasma_departaments

/datum/controller/subsystem/cargo_quests/proc/remove_quest(quest_uid, reroll, complete, list/modificators, new_reward)
	var/datum/cargo_quests_storage/quest = locateUID(quest_uid)
	if(!istype(quest))
		return
	if(QDELETED(quest))
		return
	new_reward = new_reward || quest.reward
	quest_storages.Remove(quest)
	if(quest.quest_check_timer)
		deltimer(quest.quest_check_timer)
		quest.quest_check_timer = null
	if(!reroll && quest.active)
		for(var/obj/machinery/computer/supplyquest/workers/cargo_announcer in GLOB.cargo_announcers)
			cargo_announcer.print_report(quest, complete, modificators, new_reward)

	if(!reroll && (quest.customer in plasma_departaments))
		addtimer(CALLBACK(src, PROC_REF(create_new_quest), pick(get_customer_list(quest.customer))), 10 MINUTES)
	else
		create_new_quest(pick(get_customer_list(quest.customer)), reroll, quest.quest_difficulty)
	qdel(quest)

/datum/controller/subsystem/cargo_quests/proc/create_new_quest(customer, reroll, old_difficulty, easy_mode)
	var/datum/cargo_quests_storage/new_quest = new()
	new_quest.customer = customer
	if(GLOB.security_level > SEC_LEVEL_RED)
		easy_mode = TRUE
	if(reroll && !easy_mode)
		new_quest.quest_difficulty = old_difficulty
		new_quest.can_reroll = FALSE
	new_quest.generate(easy_mode)
	quest_storages += new_quest

	return new_quest

/datum/controller/subsystem/cargo_quests/proc/check_delivery(obj/structure/bigDelivery/delivery)
	var/max_reward = 0
	var/datum/cargo_quests_storage/target_storage
	var/list/copmpleted_quests = list()

	for(var/order in quest_storages)
		var/datum/cargo_quests_storage/storage = order
		if(!storage.active)
			continue

		if(!istype(delivery.wrapped, /obj/structure/closet/crate))
			return FALSE

		if(!length(delivery.wrapped.contents))
			return FALSE

		var/failed_quest_length = 0
		for(var/datum/cargo_quest/quest in storage.current_quests)
			failed_quest_length += quest.length_quest()

		var/req_quantity = failed_quest_length
		var/extra_items = 0
		var/contents_length = length(delivery.wrapped.contents)
		for(var/atom/movable/item in delivery.wrapped.contents)
			var/has_extra_item = TRUE
			for(var/datum/cargo_quest/quest in storage.current_quests)
				if(!is_type_in_list(item, quest.req_items))
					continue
				if(quest.check_required_item(item))
					failed_quest_length--
					copmpleted_quests += quest
					has_extra_item = FALSE
					break

			if(has_extra_item)
				extra_items++
				continue

		if(extra_items == contents_length)
			continue

		for(var/datum/cargo_quest/quest in storage.current_quests)
			if(!quest.after_check())
				copmpleted_quests -= quest
				failed_quest_length++

		var/reward = storage.check_quest_completion(delivery, failed_quest_length, extra_items, req_quantity)
		if(storage.customer in corporations)
			reward = round(reward/10)

		if(reward > max_reward)
			max_reward = reward
			target_storage = storage

	if(!target_storage)
		return FALSE

	for(var/datum/cargo_quest/quest in target_storage.current_quests)
		quest.completed_quest()

	if(target_storage.customer in corporations)
		max_reward = max_reward * 10

	remove_quest(target_storage.UID(), complete = TRUE, modificators = target_storage.modificators, new_reward = max_reward)
	if(target_storage.customer.send_reward(max_reward, copmpleted_quests))
		return

	//Honestly, I don't want to do another procedure for this
	if(target_storage.quest_difficulty.bounty_for_difficulty)
		SScapitalism.total_station_bounty += target_storage.quest_difficulty.bounty_for_difficulty
		SScapitalism.base_account.credit(target_storage.quest_difficulty.bounty_for_difficulty, "Награда за выполнение корпоративного задания.", "Biesel TCD Terminal #[rand(111,333)]", "Отдел развития Нанотрейзен")

	return max_reward

/datum/controller/subsystem/cargo_quests/proc/remove_bfl_quests(count)
	for(var/I = 1 to count)
		var/datum/cargo_quests_storage/quest = pick_n_take(plasma_quests)
		quest_storages.Remove(quest)
		if(quest.quest_check_timer)
			deltimer(quest.quest_check_timer)
			quest.quest_check_timer = null
		qdel(quest)


/datum/quest_difficulty
	var/diff_flag
	var/weight
	var/min_quest_time
	var/max_quest_time
	var/for_easy_mode

	//How many shekels will be given for the complexity to the base_account account
	var/bounty_for_difficulty = 0

/datum/quest_difficulty/proc/generate_timer(datum/cargo_quests_storage/q_storage)
	q_storage.time_start = world.time
	q_storage.quest_time = rand(min_quest_time, max_quest_time) MINUTES
	q_storage.quest_check_timer = addtimer(CALLBACK(SScargo_quests, TYPE_PROC_REF(/datum/controller/subsystem/cargo_quests, remove_quest), q_storage.UID()), q_storage.quest_time, TIMER_STOPPABLE)
	q_storage.fast_check_timer = addtimer(VARSET_CALLBACK(q_storage, fast_failed, TRUE), 0.4 * q_storage.quest_time, TIMER_STOPPABLE)

/datum/quest_difficulty/easy
	diff_flag = QUEST_DIFFICULTY_EASY
	weight = 48
	min_quest_time = 15
	max_quest_time = 25
	for_easy_mode = TRUE
	bounty_for_difficulty = 150

/datum/quest_difficulty/normal
	diff_flag = QUEST_DIFFICULTY_NORMAL
	weight = 34
	min_quest_time = 20
	max_quest_time = 30
	for_easy_mode = TRUE
	bounty_for_difficulty = 300

/datum/quest_difficulty/hard
	diff_flag = QUEST_DIFFICULTY_HARD
	weight = 14
	min_quest_time = 30
	max_quest_time = 40
	bounty_for_difficulty = 500

/datum/quest_difficulty/very_hard
	diff_flag = QUEST_DIFFICULTY_VERY_HARD
	weight = 4
	min_quest_time = 30
	max_quest_time = 60
	bounty_for_difficulty = 1000


#undef NUMBER_OF_CC_QUEST
#undef NUMBER_OF_CORP_QUEST
#undef NUMBER_OF_PLASMA_QUEST
