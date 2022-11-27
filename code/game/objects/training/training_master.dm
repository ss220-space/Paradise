/obj/training_master
	var/mob/living/silicon/trainer
	var/mob/living/carbon/human/human_training/controlled_user
	var/datum/training_task/current_task
	var/current_task_type = "basic"
	var/current_task_block = 1
	var/current_task_id = 1

/obj/training_master/Initialize(mapload, user)
	. = ..()
	src.setLoc(locate(src.loc.x + 5, src.loc.y, src.loc.z), TRUE)
	spawn_room(user)

/obj/training_master/proc/destroy_room()
	var/startX = src.loc.x - 5;
	var/startY = src.loc.y - 5;
	var/endX = src.loc.x + 5;
	var/endY = src.loc.y;

	for(var/x = startX, x <= endX, x++)
		for(var/y = startY, y <= endY, y++)
			var/turf/turf = get_turf(locate(x, y, src.loc.z))
			if (turf)
				for(var/A in turf.contents)
					if (A != src && A != controlled_user)
						qdel(A)
				new /turf/space(locate(x, y, src.loc.z))
	qdel(src)

/obj/training_master/proc/spawn_room(var/mob/living/carbon/human/human_training/user)
	controlled_user = user

	var/startX = src.loc.x;
	var/startY = src.loc.y;
	var/endX = src.loc.x + user.room_size_x;
	var/endY = src.loc.y + user.room_size_y;

	for(var/x = startX, x <= endX, x++)
		for(var/y = startY, y <= endY, y++)
			new /turf/unsimulated/floor(locate(x, y, src.loc.z))
			if (x == startX || x == endX || y == startY || y == endY)
				new /turf/simulated/wall/indestructible(locate(x, y, src.loc.z))

	trainer = new /mob/living/silicon(locate(src.loc.x + (controlled_user.room_size_x / 2), src.loc.y, src.loc.z))
	addtimer(CALLBACK(src, .proc/begin_user), 1 SECONDS)
	addtimer(CALLBACK(src, .proc/begin_task), 2 SECONDS)

/obj/training_master/proc/begin_user()
	controlled_user.setLoc(locate(src.loc.x + (controlled_user.room_size_x / 2), src.loc.y + (controlled_user.room_size_y / 2), src.loc.z), TRUE)
	controlled_user.delete_equipment()
	controlled_user.equip_to_slot_if_possible(new /obj/item/clothing/under/color/orange, slot_w_uniform)

/obj/training_master/proc/begin_task()
	var/path = text2path("/datum/training_task/[current_task_type]_[current_task_block]_[current_task_id]")
	if (path)
		current_task = new path(src, controlled_user)
		current_task.init_task(src, controlled_user)
	else
		current_task_block += 1
		current_task_id = 1
		path = text2path("/datum/training_task/[current_task_type]_[current_task_block]_[current_task_id]")
		if (path)
			current_task = new path(src, controlled_user)
			current_task.reset_room()
			current_task.init_task(src, controlled_user)

/obj/training_master/proc/task_completed()
	del current_task
	current_task_id += 1
	begin_task()


// TEST TASKS

datum/training_task
	var/obj/training_master/master
	var/mob/living/carbon/human/user
	var/list/description

datum/training_task/New(var/obj/training_master/master_ref, var/mob/living/carbon/human/user_ref)
		master = master_ref
		user = user_ref

datum/training_task/proc/init_task()
	for(var/index in 1 to description.len)
		sleep(0.5 SECONDS)
		master.trainer.say(description[index])
		// if (index == description.len)
		// 	print_task_text("<strong>[description[index]]</strong>")
		// else
		// 	print_task_text(description[index])
	check_func()

datum/training_task/proc/check_func()
	addtimer(CALLBACK(src, .proc/check_func), 10)

datum/training_task/proc/print_task_text(var/text)
	to_chat(user, "<span class ='info' style='font-size: 18px'>[text]</span>")

datum/training_task/proc/on_task_success(var/text)
	var/success_text = text || "Задача выполнена"
	to_chat(user, "<span class ='green' style='font-size: 18px'>[success_text]</span>")

datum/training_task/proc/clear_room()
	var/startX = master.loc.x - 4;
	var/startY = master.loc.y - 4;
	var/endX = master.loc.x + 4;
	var/endY = master.loc.y - 1;
	for(var/x = startX, x <= endX, x++)
		for(var/y = startY, y <= endY, y++)
			var/turf/turf = new /turf/unsimulated/floor(locate(x, y, master.loc.z))
			for(var/A in turf.contents)
				if (A != user)
					qdel(A)

datum/training_task/proc/reset_user_inventory()
	user.delete_equipment()
	user.equip_to_slot_if_possible(new /obj/item/clothing/under/color/orange, slot_w_uniform)

datum/training_task/proc/reset_room()
	clear_room()
	reset_user_inventory()
	user.setLoc(locate(master.loc.x, master.loc.y - 2, master.loc.z), TRUE)
