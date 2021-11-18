/obj/training_master
	icon = 'icons/mob/ai.dmi'
	icon_state = "ai"
	var/mob/living/controlled_user
	var/datum/training_task/current_task
	var/current_task_type = "basic"
	var/current_task_id = 1

/obj/training_master/Initialize(mapload, user)
	. = ..()
	src.setLoc(locate(src.loc.x + 5, src.loc.y, src.loc.z), TRUE)
	spawn_room(user)

/obj/training_master/proc/spawn_room(var/mob/living/user)
	var/startX = src.loc.x - 5;
	var/startY = src.loc.y - 5;
	var/endX = src.loc.x + 5;
	var/endY = src.loc.y;

	for(var/x = startX, x <= endX, x++)
		for(var/y = startY, y <= endY, y++)
			new /turf/simulated/floor/vault(locate(x, y, src.loc.z))
			if (x == startX || x == endX || y == startY || y == endY)
				new /turf/simulated/wall/indestructible(locate(x, y, src.loc.z))

	addtimer(CALLBACK(src, .proc/set_controlled_user, user), 1 SECONDS)
	addtimer(CALLBACK(src, .proc/begin_task, user), 2 SECONDS)

/obj/training_master/proc/set_controlled_user(var/mob/living/user)
	controlled_user = user
	controlled_user.setLoc(locate(src.loc.x, src.loc.y - 1, src.loc.z), TRUE)

/obj/training_master/proc/begin_task()
	var/path = text2path("/datum/training_task/[current_task_type]_[current_task_id]")
	if (path)
		current_task = new path(src, controlled_user)
		current_task.init_task(src, controlled_user)

/obj/training_master/proc/task_completed()
	current_task_id += 1
	begin_task()


// TEST TASKS

datum/training_task
	var
		var/obj/training_master/master
		var/mob/living/user
		description

	New(var/obj/training_master/master_ref, var/mob/living/user_ref)
		master = master_ref
		user = user_ref

	proc/init_task()
		for(var/text in description)
			sleep(1 SECONDS)
			print_task_text(text)
		check_func(master, user)

	proc/print_task_text(var/text)
		to_chat(user, "<span class ='info' style='font-size: 20px'>[text]</span>")

	proc/print_task_success(var/text)
		var/success_text = text || "Задача выполнена"
		to_chat(user, "<span class ='green' style='font-size: 20px'>[success_text]</span>")

	proc/check_func(var/obj/training_master/master, var/mob/living/user)
		addtimer(CALLBACK(src, .proc/check_func, master, user), 2)


datum/training_task/basic_1
	description = list("Добрый день",
	"Вас приветствует программа обучения новых сотрудников НТР",
	"Базовая тренировка рассчитана на людей совершенно лишенных знаний о работе на станции",
	"Начнем с базового управления",
	"У персонажа есть 2 руки (иконки внизу по центру экрана) Одна из них - активная.",
	"Попробуйте поменяйте руки с помощью клавиши <strong>X</strong>")
	var/saved_hand

	init_task(var/obj/training_master/master, var/mob/living/user)
		saved_hand = user.hand
		..()

	check_func(var/obj/training_master/master, var/mob/living/user)
		if (user.hand != saved_hand)
			print_task_success()
			master.task_completed()
		else
			..()

datum/training_task/basic_2
	description = list("А теперь возьмите ПДА в вашу руку нажатием на него ЛКМ")

	check_func(var/obj/training_master/master, var/mob/living/user)
		var/obj/item/I = user.get_active_hand()
		if (I && findtext(I.name, "PDA"))
			print_task_success()
			master.task_completed()
		else
			..()



// var/list/testvar = list("1", "2")

// mob/var/test = list("1")

// /mob/proc/testFunc()
// 	call(src, "testFunc[testvar[1]]")()
// 	message_admins(test[1])
