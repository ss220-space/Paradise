/datum/keybinding/silicon
	category = KB_CATEGORY_SILICON

/datum/keybinding/silicon/can_use(client/user)
	return issilicon(user.mob)

/datum/keybinding/silicon/switch_intent
	name = "Смена Intents"
	keys = list("4")

/datum/keybinding/silicon/switch_intent/down(client/user)
	. = ..()
	if(.)
		return .
	var/mob/living/silicon/silicon = user.mob
	silicon.a_intent_change(INTENT_HOTKEY_LEFT)
	return TRUE

/datum/keybinding/silicon/ai/can_use(client/user)
	return isAI(user.mob)


/datum/keybinding/silicon/ai/set_cameras_by_index
	var/camera_index


/datum/keybinding/silicon/ai/set_cameras_by_index/down(client/user)
	. = ..()
	if(.)
		return .
	var/mob/living/silicon/ai/AI = user.mob
	if(AI.set_camera_by_index(user, camera_index))
		AI.update_binded_camera(user)
	return TRUE


/datum/keybinding/silicon/ai/set_cameras_by_index/cam1
	name = "Выбрать камеру по номеру 1 (ИИ)"
	keys = list("Shift1")
	camera_index = 1


/datum/keybinding/silicon/ai/set_cameras_by_index/cam2
	name = "Выбрать камеру по номеру 2 (ИИ)"
	keys = list("Shift2")
	camera_index = 2


/datum/keybinding/silicon/ai/set_cameras_by_index/cam3
	name = "Выбрать камеру по номеру 3 (ИИ)"
	keys = list("Shift3")
	camera_index = 3


/datum/keybinding/silicon/ai/set_cameras_by_index/cam4
	name = "Выбрать камеру по номеру 4 (ИИ)"
	keys = list("Shift4")
	camera_index = 4


/datum/keybinding/silicon/ai/set_cameras_by_index/cam5
	name = "Выбрать камеру по номеру 5 (ИИ)"
	keys = list("Shift5")
	camera_index = 5


/datum/keybinding/silicon/ai/set_cameras_by_index/cam6
	name = "Выбрать камеру по номеру 6 (ИИ)"
	keys = list("Shift6")
	camera_index = 6


/datum/keybinding/silicon/ai/set_cameras_by_index/cam7
	name = "Выбрать камеру по номеру 7 (ИИ)"
	keys = list("Shift7")
	camera_index = 7


/datum/keybinding/silicon/ai/set_cameras_by_index/cam8
	name = "Выбрать камеру по номеру 8 (ИИ)"
	keys = list("Shift8")
	camera_index = 8


/datum/keybinding/silicon/ai/set_cameras_by_index/cam9
	name = "Выбрать камеру по номеру 9 (ИИ)"
	keys = list("Shift9")
	camera_index = 9


/datum/keybinding/silicon/ai/set_cameras_by_index/cam10
	name = "Выбрать камеру по номеру 10 (ИИ)"
	keys = list("Shift0")
	camera_index = 10


/datum/keybinding/silicon/ai/next_camera
	name = "Следующая камера (ИИ)"
	keys = list("N")


/datum/keybinding/silicon/ai/next_camera/down(client/user)
	. = ..()
	if(.)
		return .
	var/mob/living/silicon/ai/AI = user.mob
	if(AI.check_for_binded_cameras(user))
		AI.current_camera_next(user)
		AI.update_binded_camera(user)
	return TRUE


/datum/keybinding/silicon/ai/prev_camera
	name = "Предыдущая камера (ИИ)"
	keys = list("B")


/datum/keybinding/silicon/ai/prev_camera/down(client/user)
	. = ..()
	if(.)
		return .
	var/mob/living/silicon/ai/AI = user.mob
	if(AI.check_for_binded_cameras(user))
		AI.current_camera_back(user)
		AI.update_binded_camera(user)
	return TRUE
