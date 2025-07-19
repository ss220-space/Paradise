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
	var/complete = FALSE


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
	var/complete_count = 0
	for(var/mob/living/prisoner as anything in prisoners)
		var/datum/addition_goal_prisoner_data/data = prisoners_data[prisoner.name]
		if(data.complete)
			complete_count++
	var/progress = (complete_count) / prisoners_count * 100
	message_admins("prisioners addition goal: check completition [complete_count] of [prisoners_count] progress=[progress].")
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
