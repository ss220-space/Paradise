/// Funeral shuttle addition goal

////////////////////////////////////////
// MARK:	Goal datum
////////////////////////////////////////

/datum/addition_goal/funeral
	id = "funeral"
	name = "Шаттл с трупами"
	var/corpse_count
	var/list/corpses = list()


/datum/addition_goal/funeral/setup()
	corpse_count = rand(3, 5)
	name += " ([corpse_count])"


/datum/addition_goal/funeral/spawn_shuttle_contain(list/turf/shuttle_turfs)
	message_admins("funeral addition goal: id=[id] begin spawn shuttle contain corpses=[corpse_count].")
	var/obj/effect/mob_spawn/human/spawner = new /obj/effect/mob_spawn/human/addition_goal/funeral(shuttle_turfs[1])
	for(var/i = 0; i < corpse_count; i++)
		var/turf/random_turf = pick(shuttle_turfs)
		shuttle_turfs -= random_turf
		var/obj/structure/closet/body_bag/body_bag = new /obj/structure/closet/body_bag(random_turf)
		body_bag.open()
		spawner.loc = random_turf
		var/mob/living/corpse = spawner.create()
		corpses += corpse
		body_bag.close()
		message_admins("funeral addition goal: created corpse [corpse.name] [ADMIN_COORDJMP(random_turf)].")
	qdel(spawner)
	return TRUE


/datum/addition_goal/funeral/format_accept_report(mob/user)
	var/text = {"<b>Запрос похорон</b><br>
		К вам отправлено [corpse_count] трупов для организации похорон.<br>
		Необходимо похоронить погибших согласно указанному списку:<br>"}
	var/number = 1
	for(var/mob/living/corpse as anything in corpses)
		text += "<br>[number]. [corpse.real_name] - необходимо кремировать."
		number++
	return text


/datum/addition_goal/funeral/check_completion(list/turf/shuttle_turfs)
	var/exists_corpses_count = 0
	for(var/mob/living/corpse in corpses)
		if(corpse && corpse.loc)
			exists_corpses_count += 1
	var/progress = (corpse_count - exists_corpses_count) / corpse_count * 100
	message_admins("funeral addition goal: check completition exists [exists_corpses_count] of [corpse_count] progress=[progress].")
	return progress




////////////////////////////////////////
// MARK:	Misc
////////////////////////////////////////

/obj/effect/mob_spawn/human/addition_goal/funeral
	death = TRUE
	uniform = /obj/item/clothing/under/suit_jacket/charcoal
	shoes = /obj/item/clothing/shoes/centcom
