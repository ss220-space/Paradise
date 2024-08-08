/datum/keybinding/robot
	category = KB_CATEGORY_ROBOT

/datum/keybinding/robot/can_use(client/user)
	return isrobot(user.mob)

/datum/keybinding/robot/module
	/// The module number.
	var/module_number

/datum/keybinding/robot/module/down(client/user)
	. = ..()
	if(.)
		return .
	var/mob/living/silicon/robot/robot = user.mob
	robot.toggle_module(module_number)
	return TRUE

/datum/keybinding/robot/module/slot_1
	name = "Ячейка 1"
	module_number = 1
	keys = list("1")

/datum/keybinding/robot/module/slot_2
	name = "Ячейка 2"
	module_number = 2
	keys = list("2")

/datum/keybinding/robot/module/slot_3
	name = "Ячейка 3"
	module_number = 3
	keys = list("3")

/datum/keybinding/robot/cycle_modules
	name = "Смена ячеек"
	keys = list("X")

/datum/keybinding/robot/cycle_modules/down(client/user)
	. = ..()
	if(.)
		return .
	var/mob/living/silicon/robot/robot = user.mob
	robot.cycle_modules()

/datum/keybinding/robot/drop_held_object
	name = "Выложить в хранилище"
	keys = list("Q")

/datum/keybinding/robot/drop_held_object/down(client/user)
	. = ..()
	if(.)
		return .
	var/mob/living/silicon/robot/robot = user.mob
	robot.on_drop_hotkey_press()
	return TRUE
