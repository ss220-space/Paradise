/datum/keybinding/ai
	abstract_type = /datum/keybinding/ai
	category = KB_CATEGORY_AI
	weight = WEIGHT_AI

/datum/keybinding/ai/can_use(client/user)
	return isAI(user.mob)

/datum/keybinding/ai/set_cameras_by_index
	abstract_type = /datum/keybinding/ai/set_cameras_by_index
	var/camera_index

/datum/keybinding/ai/set_cameras_by_index/down(client/user, turf/target, mousepos_x, mousepos_y)
	. = ..()
	if(.)
		return .
	var/mob/living/silicon/ai/AI = user.mob
	if(AI.set_camera_by_index(user, camera_index))
		AI.update_binded_camera(user)
	return TRUE

/datum/keybinding/ai/set_cameras_by_index/cam1
	name = "ai_cam1"
	full_name = "Выбрать камеру по номеру 1 (ИИ)"
	description = "Переключает на камеру по номеру 1 при нажатии"
	hotkey_keys = list("Shift1")
	camera_index = 1
	keybind_signal = COMSIG_KB_AI_CAM1_DOWN

/datum/keybinding/ai/set_cameras_by_index/cam2
	name = "ai_cam2"
	full_name = "Выбрать камеру по номеру 2 (ИИ)"
	description = "Переключает на камеру по номеру 2 при нажатии"
	hotkey_keys = list("Shift2")
	camera_index = 2
	keybind_signal = COMSIG_KB_AI_CAM2_DOWN

/datum/keybinding/ai/set_cameras_by_index/cam3
	name = "ai_cam3"
	full_name = "Выбрать камеру по номеру 3 (ИИ)"
	description = "Переключает на камеру по номеру 3 при нажатии"
	hotkey_keys = list("Shift3")
	camera_index = 3
	keybind_signal = COMSIG_KB_AI_CAM3_DOWN

/datum/keybinding/ai/set_cameras_by_index/cam4
	name = "ai_cam4"
	full_name = "Выбрать камеру по номеру 4 (ИИ)"
	description = "Переключает на камеру по номеру 4 при нажатии"
	hotkey_keys = list("Shift4")
	camera_index = 4
	keybind_signal = COMSIG_KB_AI_CAM4_DOWN

/datum/keybinding/ai/set_cameras_by_index/cam5
	name = "ai_cam5"
	full_name = "Выбрать камеру по номеру 5 (ИИ)"
	description = "Переключает на камеру по номеру 5 при нажатии"
	hotkey_keys = list("Shift5")
	camera_index = 5
	keybind_signal = COMSIG_KB_AI_CAM5_DOWN

/datum/keybinding/ai/set_cameras_by_index/cam6
	name = "ai_cam6"
	full_name = "Выбрать камеру по номеру 6 (ИИ)"
	description = "Переключает на камеру по номеру 6 при нажатии"
	hotkey_keys = list("Shift6")
	camera_index = 6
	keybind_signal = COMSIG_KB_AI_CAM6_DOWN

/datum/keybinding/ai/set_cameras_by_index/cam7
	name = "ai_cam7"
	full_name = "Выбрать камеру по номеру 7 (ИИ)"
	description = "Переключает на камеру по номеру 7 при нажатии"
	hotkey_keys = list("Shift7")
	camera_index = 7
	keybind_signal = COMSIG_KB_AI_CAM7_DOWN

/datum/keybinding/ai/set_cameras_by_index/cam8
	name = "ai_cam8"
	full_name = "Выбрать камеру по номеру 8 (ИИ)"
	description = "Переключает на камеру по номеру 8 при нажатии"
	hotkey_keys = list("Shift8")
	camera_index = 8
	keybind_signal = COMSIG_KB_AI_CAM8_DOWN

/datum/keybinding/ai/set_cameras_by_index/cam9
	name = "ai_cam9"
	full_name = "Выбрать камеру по номеру 9 (ИИ)"
	description = "Переключает на камеру по номеру 9 при нажатии"
	hotkey_keys = list("Shift9")
	camera_index = 9
	keybind_signal = COMSIG_KB_AI_CAM9_DOWN

/datum/keybinding/ai/set_cameras_by_index/cam10
	name = "ai_cam10"
	full_name = "Выбрать камеру по номеру 10 (ИИ)"
	description = "Переключает на камеру по номеру 10 при нажатии"
	hotkey_keys = list("Shift0")
	camera_index = 10
	keybind_signal = COMSIG_KB_AI_CAM10_DOWN

/datum/keybinding/ai/next_camera
	name = "next_camera"
	full_name = "Следующая камера (ИИ)"
	description = "Переключает на следующую камеру из списка при нажатии"
	hotkey_keys = list("N")
	keybind_signal = COMSIG_KB_AI_NEXT_CAMERA_DOWN

/datum/keybinding/ai/next_camera/down(client/user, turf/target, mousepos_x, mousepos_y)
	. = ..()
	if(.)
		return .
	var/mob/living/silicon/ai/AI = user.mob
	if(AI.check_for_binded_cameras(user))
		AI.current_camera_next(user)
		AI.update_binded_camera(user)
	return TRUE

/datum/keybinding/ai/prev_camera
	name = "prev_camera"
	full_name = "Предыдущая камера (ИИ)"
	description = "Переключает на предыдущую камеру из списка при нажатии"
	hotkey_keys = list("B")
	keybind_signal = COMSIG_KB_AI_PREV_CAMERA_DOWN

/datum/keybinding/ai/prev_camera/down(client/user, turf/target, mousepos_x, mousepos_y)
	. = ..()
	if(.)
		return .
	var/mob/living/silicon/ai/AI = user.mob
	if(AI.check_for_binded_cameras(user))
		AI.current_camera_back(user)
		AI.update_binded_camera(user)
	return TRUE
