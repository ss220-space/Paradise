/datum/keybinding/robot
	abstract_type = /datum/keybinding/robot
	category = KB_CATEGORY_ROBOT
	weight = WEIGHT_ROBOT

/datum/keybinding/robot/can_use(client/user)
	return isrobot(user.mob)

/datum/keybinding/robot/module
	abstract_type = /datum/keybinding/robot/module
	/// The module number.
	var/module_number

/datum/keybinding/robot/module/down(client/user, turf/target, mousepos_x, mousepos_y)
	. = ..()
	if(.)
		return .
	var/mob/living/silicon/robot/robot = user.mob
	robot.toggle_module(module_number)
	return TRUE

/datum/keybinding/robot/module/slot_1
	name = "module_one"
	full_name = "Ячейка 1"
	description = "Equips or unequips the first module"
	module_number = 1
	hotkey_keys = list("1")
	keybind_signal = COMSIG_KB_SILICON_TOGGLEMODULEONE_DOWN

/datum/keybinding/robot/module/slot_2
	name = "module_two"
	full_name = "Ячейка 2"
	description = "Equips or unequips the second module"
	module_number = 2
	hotkey_keys = list("2")
	keybind_signal = COMSIG_KB_SILICON_TOGGLEMODULETWO_DOWN

/datum/keybinding/robot/module/slot_3
	name = "module_three"
	full_name = "Ячейка 3"
	description = "Equips or unequips the third module"
	module_number = 3
	hotkey_keys = list("3")
	keybind_signal = COMSIG_KB_SILICON_TOGGLEMODULETHREE_DOWN

/datum/keybinding/robot/cycle_modules
	name = "cycle_modules"
	full_name = "Смена ячеек"
	description = "Циклически переключает активные модули робота при нажатии"
	hotkey_keys = list("X")
	keybind_signal = COMSIG_KB_ROBOT_CYCLE_MODULES_DOWN

/datum/keybinding/robot/cycle_modules/down(client/user, turf/target, mousepos_x, mousepos_y)
	. = ..()
	if(.)
		return .
	var/mob/living/silicon/robot/robot = user.mob
	robot.cycle_modules()

/datum/keybinding/robot/drop_held_object
	name = "drop_held_object"
	full_name = "Выложить в хранилище"
	description = "Выкладывает удерживаемый объект в хранилище робота при нажатии"
	hotkey_keys = list("Q")
	keybind_signal = COMSIG_KB_ROBOT_DROP_HELD_OBJECT_DOWN

/datum/keybinding/robot/drop_held_object/down(client/user, turf/target, mousepos_x, mousepos_y)
	. = ..()
	if(.)
		return .
	var/mob/living/silicon/robot/robot = user.mob
	robot.on_drop_hotkey_press()
	return TRUE
