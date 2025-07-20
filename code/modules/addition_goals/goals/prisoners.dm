// Prisoners addition goal shuttle


/datum/addition_goal/prisoners
	id = "prisoners"
	name = "Шаттл с заключенными"
	var/prisoners_count
	var/list/prisoners = list()
	var/list/prisoners_data = list()
	var/obj/effect/mob_spawn/human/spawner

/datum/addition_goal_prisoner_data
	var/crimes = "202"
	var/duration = 10
	var/complete_percent = 0


/datum/addition_goal/prisoners/setup()
	prisoners_count = rand(3, 5)
	name += " ([prisoners_count])"


/datum/addition_goal/prisoners/spawn_shuttle_contain(list/turf/shuttle_turfs)
	message_admins("prisoners addition goal: id=[id] begin spawn shuttle contain prisoners=[prisoners_count].")
	spawner = new /obj/effect/mob_spawn/human/addition_goal/prisoners(shuttle_turfs[1])
	for(var/i = 0; i < prisoners_count; i++)
		var/turf/random_turf = pick(shuttle_turfs)
		shuttle_turfs -= random_turf
		create_prisoner_at(random_turf)
	qdel(spawner)
	return TRUE

/datum/addition_goal/prisoners/proc/create_prisoner_at(turf/location)
	spawner.loc = location
	var/mob/living/carbon/human/prisoner = spawner.create()
	prisoners += prisoner
	var/obj/structure/chair/chair = new /obj/structure/chair(location)
	addtimer(CALLBACK(chair, TYPE_PROC_REF(/atom/movable/, buckle_mob), prisoner, TRUE, FALSE), 1)
	handcuff_prisoner(prisoner)
	switch_ai_to_angry_mode(prisoner)
	create_prisoner_data(prisoner)
	create_crimes_paper(location, prisoner)
	register_complete_signal_handler(prisoner)

/datum/addition_goal/prisoners/proc/switch_ai_to_angry_mode(mob/living/prisoner)
	prisoner.ai_controller = /datum/ai_controller/monkey/angry
	prisoner.InitializeAIController()

/datum/addition_goal/prisoners/proc/handcuff_prisoner(mob/living/carbon/target)
	var/obj/item/restraints/handcuffs/cable/zipties/cuffs = new (target.loc)
	target.equip_to_slot(cuffs, ITEM_SLOT_HANDCUFFED)

/datum/addition_goal/prisoners/proc/create_prisoner_data(mob/living/prisoner)
	var/list/hard_crimes = list("300", "302", "303", "304", "305", "306", "307", "308")
	var/list/middle_crimes = list("200", "201", "202", "203", "204", "205", "206", "207")
	var/list/light_crimes = list("100", "101", "102", "103", "104", "105", "106", "107", "108")
	var/datum/addition_goal_prisoner_data/crime = new()
	prisoners_data[prisoner.name] = crime
	if(prob(30))
		crime.crimes = "[pick(hard_crimes)]"
		crime.duration = rand(10, 15)
		return
	if(prob(50))
		crime.crimes = "[pick(middle_crimes)], [pick(light_crimes)]"
		crime.duration = rand(10, 15)
	var/crime1 = pick(light_crimes)
	light_crimes -= crime1
	var/crime2 = pick(light_crimes)
	light_crimes -= crime2
	var/crime3 = pick(light_crimes)
	crime.crimes = "[crime1], [crime2], [crime3]"
	crime.duration = rand(10, 15)

/datum/addition_goal/prisoners/proc/create_crimes_paper(turf/location, mob/living/prisoner)
	var/datum/addition_goal_prisoner_data/data = prisoners_data[prisoner.name]
	var/obj/item/paper/paper = new (location)
	var/number = "[rand(100, 999)]-[rand(1000, 9999)]"
	paper.name = "Приказ о заключении под стражу №[number]"
	paper.info = {"<center><b>Приказ о заключении [number]</b></center><br>
		Настоящим подтверждается, что гражданин [prisoner.real_name] подлежит тюремному заключению сроком в [data.duration] минут в камере брига.<br>
		<b>Вменяемые статьи:</b> [data.crimes]."}

/datum/addition_goal/prisoners/proc/register_complete_signal_handler(mob/living/prisoner)
	RegisterSignal(prisoner, COMSIG_DOOR_TIMER_FINISH, PROC_REF(on_prisoner_timer_finish))

/datum/addition_goal/prisoners/proc/on_prisoner_timer_finish(mob/living/prisoner, crimes, duration_min)
	SIGNAL_HANDLER
	message_admins("on_prisoner_timer_finish  prisoner=[prisoner.name] crimes='[crimes]' duration_min=[duration_min]")
	var/datum/addition_goal_prisoner_data/data = prisoners_data[prisoner.name]
	if(!data)
		message_admins("not found prisoner crimes data for [prisoner.name]")
		return
	data.complete_percent = 100
	if(data.crimes != crimes) {
		data.complete_percent -= 10
	}
	if(duration_min < data.duration) {
		data.complete_percent -= 50
	}
	if(duration_min > data.duration) {
		data.complete_percent -= 10
	}
	message_admins("prisoner [prisoner.name] brig cell complete crimes='[crimes]' duration_min=[duration_min] complete=[data.complete_percent]%")


/datum/addition_goal/prisoners/format_accept_report(mob/user)
	var/text = {"<center><b>Запрос на временное заключение</b></center><br>
		В ваш адрес направлены [prisoners_count] заключенных для отбытия наказания.<br>
		Прсим произвести заключение в соответствии с нижеуказанным списком:<br>"}
	var/number = 1
	for(var/mob/living/prisoner as anything in prisoners)
		var/datum/addition_goal_prisoner_data/data = prisoners_data[prisoner.name]
		text += "<br>[number]. [prisoner.real_name] - [data.crimes] ([data.duration] минут заключения)."
		number++
	return text


/datum/addition_goal/prisoners/check_completion(list/turf/shuttle_turfs)
	var/summary_complete_percent = 0
	for(var/mob/living/carbon/prisoner as anything in prisoners)
		var/datum/addition_goal_prisoner_data/data = prisoners_data[prisoner.name]
		if(!data) //not exists crimes data, skip this prisoner
			message_admins("prisioners addition goal: prisoner [prisoner.name] not found crimes data!")
			continue
		if(!prisoner.loc) //prisoner not exists in game (gibbed, cremated ...)
			message_admins("prisioners addition goal: prisoner [prisoner.name] not not exists!")
			continue
		if(!contains_in_shuttle(prisoner)) //prisoner not in shuttle!
			message_admins("prisioners addition goal: prisoner [prisoner.name] not in shuttle!")
			data.complete_percent = max(0, data.complete_percent - 50)
		if(prisoner.health <= 100 || prisoner.stat != CONSCIOUS) //prisoner hearts
			message_admins("prisioners addition goal: prisoner [prisoner.name] have deceases!")
			data.complete_percent = max(0, data.complete_percent - 25)
		if(!prisoner.handcuffed)
			message_admins("prisioners addition goal: prisoner [prisoner.name] not hancuffed!")
			data.complete_percent = max(0, data.complete_percent - 10)
		summary_complete_percent += data.complete_percent
		message_admins("prisioners addition goal: check completition [prisoner.name] progress=[data.complete_percent].")
	var/progress = (summary_complete_percent) / prisoners_count
	message_admins("prisioners addition goal: check completition progress=[progress].")
	return progress



////////////////////////////////////////
// MARK:	Misc
////////////////////////////////////////

/obj/effect/mob_spawn/human/addition_goal/prisoners
	death = FALSE
	mob_type = /mob/living/carbon/human/monkeybrain
	uniform = /obj/item/clothing/under/prison
	shoes = /obj/item/clothing/shoes/prison
	head = /obj/item/clothing/head/prison
	id = /obj/item/card/id/prisoner
