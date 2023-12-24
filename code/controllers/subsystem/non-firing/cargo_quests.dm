#define NUMBER_OF_CC_QUEST 8
#define NUMBER_OF_CORP_QUEST 4
#define NUMBER_OF_PLASMA_QUEST 1

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


	for(var/I = 1 to NUMBER_OF_CC_QUEST)
		create_new_quest(pick(centcomm_departaments))
	for(var/I = 1 to NUMBER_OF_CORP_QUEST)
		create_new_quest(pick(corporations))
	for(var/I = 1 to NUMBER_OF_PLASMA_QUEST)
		create_new_quest(pick(plasma_departaments))

/datum/controller/subsystem/cargo_quests/proc/get_customer_list(datum/quest_customer/customer)
	if(customer in centcomm_departaments)
		return centcomm_departaments
	if(customer in corporations)
		return corporations
	if(customer in plasma_departaments)
		return plasma_departaments

/datum/controller/subsystem/cargo_quests/proc/remove_quest(quest_uid, reroll, complete, list/modificators, old_reward)
	var/datum/cargo_quests_storage/quest = locateUID(quest_uid)
	if(!istype(quest))
		return
	if(QDELETED(quest))
		return
	old_reward = old_reward || quest.reward
	quest_storages.Remove(quest)
	if(quest.quest_check_timer)
		deltimer(quest.quest_check_timer)
		quest.quest_check_timer = null
	if(!reroll && quest.active)
		for(var/obj/machinery/computer/supplyquest/workers/cargo_announcer in GLOB.cargo_announcers)
			cargo_announcer.print_report(quest, complete, modificators)

	if(!reroll && (quest.customer in plasma_departaments))
		addtimer(CALLBACK(src, PROC_REF(create_new_quest), pick(get_customer_list(quest.customer))), 25 MINUTES)
	else
		create_new_quest(pick(get_customer_list(quest.customer)), reroll, quest.quest_difficulty)
	qdel(quest)

/datum/controller/subsystem/cargo_quests/proc/create_new_quest(customer, reroll, old_difficulty)
	var/datum/cargo_quests_storage/new_quest = new()
	new_quest.customer = customer
	if(reroll)
		new_quest.quest_difficulty = old_difficulty
		new_quest.can_reroll = FALSE
	new_quest.generate()
	quest_storages += new_quest

	return new_quest

/datum/controller/subsystem/cargo_quests/proc/check_delivery(obj/structure/bigDelivery/delivery)
	for(var/order in quest_storages)
		var/datum/cargo_quests_storage/storage = order
		if(!storage.active)
			continue
		var/reward = storage.check_quest_completion(delivery)
		if(!reward)
			continue
		if(storage.customer.send_reward(reward))
			return
		return reward

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

/datum/quest_difficulty/proc/generate_timer(datum/cargo_quests_storage/q_storage)
	q_storage.time_start = world.time
	q_storage.quest_time = rand(min_quest_time, max_quest_time) MINUTES
	q_storage.quest_check_timer = addtimer(CALLBACK(SScargo_quests, TYPE_PROC_REF(/datum/controller/subsystem/cargo_quests, remove_quest), q_storage.UID()), q_storage.quest_time, TIMER_STOPPABLE)
	q_storage.fast_check_timer = addtimer(VARSET_CALLBACK(q_storage, fast_failed, TRUE), 0.4 * q_storage.quest_time, TIMER_STOPPABLE)

/datum/quest_difficulty/easy
	diff_flag = QUEST_DIFFICULTY_EASY
	weight = 45
	min_quest_time = 15
	max_quest_time = 25

/datum/quest_difficulty/normal
	diff_flag = QUEST_DIFFICULTY_NORMAL
	weight = 35
	min_quest_time = 20
	max_quest_time = 30

/datum/quest_difficulty/normal/generate_timer(datum/cargo_quests_storage/q_storage)
	q_storage.quest_time = rand(20, 30) MINUTES
	..()

/datum/quest_difficulty/hard
	diff_flag = QUEST_DIFFICULTY_HARD
	weight = 15
	min_quest_time = 30
	max_quest_time = 40

/datum/quest_difficulty/very_hard
	diff_flag = QUEST_DIFFICULTY_VERY_HARD
	weight = 5
	min_quest_time = 30
	max_quest_time = 60


#undef NUMBER_OF_CC_QUEST
#undef NUMBER_OF_CORP_QUEST
#undef NUMBER_OF_PLASMA_QUEST
