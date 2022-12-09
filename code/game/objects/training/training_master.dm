/obj/training_master
	var/mob/living/silicon/ai_room_trainer/trainer
	var/mob/living/carbon/human/human_training/controlled_user
	var/datum/training_task/current_task
	var/current_task_type = "basic"
	var/current_task_block = 1
	var/current_task_id = 1

/obj/training_master/Initialize(mapload, user)
	. = ..()
	spawn_room(user)

/obj/training_master/proc/destroy_room()
	var/startX = src.x;
	var/startY = src.y;
	var/endX = src.x + controlled_user.room_size_x - 1;
	var/endY = src.y + controlled_user.room_size_y - 1;

	for(var/x = startX, x <= endX, x++)
		for(var/y = startY, y <= endY, y++)
			var/turf/turf = get_turf(locate(x, y, src.z))
			if (turf)
				for(var/A in turf.contents)
					if (A != src && A != controlled_user)
						qdel(A)
				new /turf/space(locate(x, y, src.z))
	qdel(src)

/obj/training_master/proc/spawn_room(var/mob/living/carbon/human/human_training/user)
	controlled_user = user

	var/startX = src.x;
	var/startY = src.y;
	var/endX = src.x + controlled_user.room_size_x - 1;
	var/endY = src.y + controlled_user.room_size_y - 1;

	for(var/x = startX, x <= endX, x++)
		for(var/y = startY, y <= endY, y++)
			var/turf/old_turf = get_turf(locate(x, y, src.y))
			for(var/A in old_turf.contents)
				if (A != src)
					qdel(A)
			if (x == startX || x == endX || y == startY || y == endY)
				old_turf.ChangeTurf(/turf/simulated/wall/indestructible)
			else
				old_turf.ChangeTurf(/turf/unsimulated/floor)

	var/datum/training_coords/center = get_center()
	trainer = new /mob/living/silicon/ai_room_trainer(locate(center.x, startY, src.y))
	trainer.anchored = TRUE
	trainer.status_flags |= GODMODE
	trainer.add_language("Galactic Common", 1)
	trainer.add_language("Sol Common", 1)
	trainer.add_language("Training Lang", 1)
	addtimer(CALLBACK(src, .proc/begin_user), 1 SECONDS)
	addtimer(CALLBACK(src, .proc/begin_task), 2 SECONDS)

/obj/training_master/proc/begin_user()
	var/datum/training_coords/center = get_center()
	controlled_user.setLoc(locate(src.x + 2, center.y, src.z), TRUE)
	controlled_user.reset_inventory()

/obj/training_master/proc/begin_task()
	var/path = text2path("/datum/training_task/[current_task_type]_[current_task_block]_[current_task_id]")
	if (path)
		current_task = new path(src, controlled_user)
		if (current_task_id == 1)
			current_task.reset_room()
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

/obj/training_master/proc/get_center()
	return new /datum/training_coords(src.x + (controlled_user.room_size_x / 2), src.y + (controlled_user.room_size_y / 2), src.z)

/obj/training_master/proc/get_max_coordinate()
	return new /datum/training_coords(src.x + controlled_user.room_size_x - 1, src.y + controlled_user.room_size_y - 1, src.z)

// TEST TASKS

/datum/training_coords //Simple datum for storing coordinates.
	var/x = 0
	var/y = 0
	var/z = 0

/datum/training_coords/New(x_loc, y_loc, z_loc)
	x = x_loc
	y = y_loc
	z = z_loc
/datum/training_task
	var/obj/training_master/master
	var/mob/living/carbon/human/human_training/user
	var/list/description
	var/user_start_x = 0
	var/user_start_y = 0

/datum/training_task/New(var/obj/training_master/master_ref, var/mob/living/carbon/human/human_training/user_ref)
		master = master_ref
		user = user_ref

/datum/training_task/proc/calculate_say_duration(message)
	return length(message) / 26

/datum/training_task/proc/init_task()
	for(var/index in 1 to description.len)
		var/message = description[index]
		var/sleep_duration = calculate_say_duration(message)
		master.trainer.say(message)

		if (index != description.len)
			sleep(sleep_duration SECONDS)
	instruction_end()
	check_func()

/datum/training_task/proc/instruction_end()

/datum/training_task/proc/check_func()
	addtimer(CALLBACK(src, .proc/check_func), 10)

/datum/training_task/proc/on_task_success(var/message = "Отлично")
	var/sleep_duration = calculate_say_duration(message)
	master.trainer.say(message)
	sleep(sleep_duration SECONDS)
	to_chat(user, "<span class ='green' style='font-size: 18px'>---------------------------------------</span>")

/datum/training_task/proc/clear_room()
	var/startX = master.x + 1;
	var/startY = master.y + 1;
	var/endX = master.x + user.room_size_x - 2;
	var/endY = master.y + user.room_size_y - 2;
	for(var/x = startX, x <= endX, x++)
		for(var/y = startY, y <= endY, y++)
			var/turf/turf = get_turf(locate(x, y, master.z))
			turf.ChangeTurf(/turf/unsimulated/floor)
			turf.icon = 'icons/turf/floors.dmi'
			turf.icon_state = "Floor3"
			for(var/A in turf.contents)
				if (A != user)
					qdel(A)

/datum/training_task/proc/reset_room()
	clear_room()
	user.reset_inventory()
	var/datum/training_coords/center = get_center()
	var/loc_x = user_start_x ? master.x + user_start_x : center.x
	var/loc_y = user_start_y ? master.y + user_start_y : center.y
	user.setLoc(locate(loc_x, loc_y, master.z), 1)

/datum/training_task/proc/get_center()
	return master.get_center()

/datum/training_task/proc/get_max_coordinate()
	return master.get_max_coordinate()

/datum/training_task/proc/spawn_window(x, y)
	var/obj/structure/window/full/reinforced/glass = new (locate(x, y, master.z))
	glass.resistance_flags = INDESTRUCTIBLE
	return glass

/datum/training_task/proc/spawn_airlock(x, y)
	var/obj/machinery/door/airlock/glass/airlock = new (locate(x, y, master.z))
	airlock.stat = 0
	airlock.resistance_flags = INDESTRUCTIBLE
	return airlock
