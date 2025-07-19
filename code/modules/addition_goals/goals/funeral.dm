/// Funeral shuttle addition goal
#define CORPSE_METHOD_CREMATION "кремация"
#define CORPSE_METHOD_SPACE "космирование"

////////////////////////////////////////
// MARK:	Goal datum
////////////////////////////////////////

/datum/addition_goal/funeral
	id = "funeral"
	name = "Шаттл с трупами"
	var/corpse_count
	var/list/corpses = list()
	var/list/corpse_methods = list()


/datum/addition_goal/funeral/setup()
	corpse_count = rand(3, 5)
	name += " ([corpse_count])"


/datum/addition_goal/funeral/spawn_shuttle_contain(list/turf/shuttle_turfs)
	message_admins("funeral addition goal: id=[id] begin spawn shuttle contain corpses=[corpse_count].")
	var/obj/effect/mob_spawn/human/spawner = new /obj/effect/mob_spawn/human/addition_goal/funeral(shuttle_turfs[1])
	for(var/i = 0; i < corpse_count; i++)
		var/turf/random_turf = pick(shuttle_turfs)
		shuttle_turfs -= random_turf
		spawner.loc = random_turf
		var/mob/living/carbon/human/corpse = spawner.create()
		corpses += corpse
		var/preffered_method = rand(1, 2) == 1 ? CORPSE_METHOD_CREMATION : CORPSE_METHOD_SPACE
		corpse_methods[corpse.name] = preffered_method
		create_paper_about_preffered_method(random_turf, corpse, preffered_method)
		create_body_bag_and_close(random_turf)
		message_admins("funeral addition goal: created corpse [corpse.name] [ADMIN_COORDJMP(random_turf)].")
	qdel(spawner)
	return TRUE

/datum/addition_goal/funeral/proc/create_paper_about_preffered_method(turf/location, mob/living/carbon/human/corpse, preffered_method)
	var/obj/item/paper/paper = new (location)
	var/number = "[rand(100, 999)]-[rand(1000, 9999)]"
	paper.name = "Документ о проведении погребения №[number]"
	paper.info = {"<center><b>Документ о проведении погребения [number]</b></center><br>
		Настоящим подтверждается, что гражданин [corpse.real_name] подлежит захоронению в соответствии с указанным способом.<br>
		<b>Форма погребения:</b> [preffered_method]."}

/datum/addition_goal/funeral/proc/create_body_bag_and_close(turf/location)
	var/obj/structure/closet/body_bag/body_bag = new /obj/structure/closet/body_bag(location)
	body_bag.open()
	body_bag.close()


/datum/addition_goal/funeral/format_accept_report(mob/user)
	var/text = {"<center><b>Запрос на проведение погребения</b></center><br>
		В ваш адрес направлены [corpse_count] тел(а) для организации процедуры захоронения.<br>
		Прошу произвести погребение в соответствии с нижеуказанным списком:<br>"}
	var/number = 1
	for(var/mob/living/corpse as anything in corpses)
		var/preffered_method = corpse_methods[corpse.name]
		text += "<br>[number]. [corpse.real_name] - [preffered_method]."
		number++
	return text


/datum/addition_goal/funeral/check_completion(list/turf/shuttle_turfs)
	var/complete_count = 0
	for(var/mob/living/corpse in corpses)
		var/preffered_method = corpse_methods[corpse.name]
		switch(preffered_method)
			if(CORPSE_METHOD_CREMATION)
				if(!corpse || !corpse.loc)
					complete_count++
			if(CORPSE_METHOD_SPACE)
				if(!corpse || !corpse.loc)
					continue
				if(!istype(corpse.loc, /obj/structure/closet/coffin))
					continue
				var/obj/structure/closet/coffin/coffin = corpse.loc
				if(istype(coffin.loc, /turf/space))
					complete_count++
	var/progress = (complete_count) / corpse_count * 100
	message_admins("funeral addition goal: check completition [complete_count] of [corpse_count] progress=[progress].")
	return progress




////////////////////////////////////////
// MARK:	Misc
////////////////////////////////////////

/obj/effect/mob_spawn/human/addition_goal/funeral
	death = TRUE
	uniform = /obj/item/clothing/under/suit_jacket/charcoal
	shoes = /obj/item/clothing/shoes/centcom
