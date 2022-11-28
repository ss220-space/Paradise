/datum/training_task/basic_1_1
	description = list("Здравствуйте и добро пожаловать на начальный курс обучения СС220, где вас научат начальным навыкам управления.",
	"Я ваш интеллектуальный помощник в этом нелегком деле.",
	"Давайте начнем с основ передвижения!",
	"Для перемещния используюся клавиши WASD",
	"На клавишу TAB вы можете переключить режим хоткеев.",
	"Переключите режим если вам не удается перемещаться с помощью WASD")
	var/obj/machinery/door/airlock/glass/airlock
	var/turf/final_turf
	user_start_x = 2

/datum/training_task/basic_1_1/init_task()
	spawn_window(get_center().x, master.y + 1)
	spawn_window(get_center().x, master.y + 2)
	airlock = spawn_airlock(get_center().x, master.y + 3)
	spawn_window(get_center().x, master.y + 4)
	spawn_window(get_center().x, master.y + 5)
	airlock.lock()

	final_turf = get_turf(locate(master.get_max_coordinate().x - 2, master.get_center().y, master.z))
	final_turf.icon = 'icons/turf/decals.dmi'
	final_turf.icon_state = "delivery"
	..()

/datum/training_task/basic_1_1/instruction_end()
	airlock.unlock()

/datum/training_task/basic_1_1/check_func()
	if (user.x == final_turf.x && user.y == final_turf.y)
		on_task_success("Отлично")
		master.task_completed()
	else
		..()
