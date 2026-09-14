/datum/keybinding/movement
	abstract_type = /datum/keybinding/movement
	category = KB_CATEGORY_MOVEMENT
	weight = WEIGHT_HIGHEST
	/// The direction to move to when held.
	var/move_dir

/datum/keybinding/movement/north
	name = "North"
	full_name = "Идти на север"
	description = "Moves your character north"
	hotkey_keys = list("W", "North")
	move_dir = NORTH
	keybind_signal = COMSIG_KB_MOVEMENT_NORTH_DOWN

/datum/keybinding/movement/south
	name = "south"
	full_name = "Идти на юг"
	description = "Двигает персонажа на юг при нажатии"
	hotkey_keys = list("S", "South")
	move_dir = SOUTH
	keybind_signal = COMSIG_KB_MOVEMENT_SOUTH_DOWN

/datum/keybinding/movement/east
	name = "east"
	full_name = "Идти на восток"
	description = "Двигает персонажа на восток при нажатии"
	hotkey_keys = list("D", "East")
	move_dir = EAST
	keybind_signal = COMSIG_KB_MOVEMENT_EAST_DOWN

/datum/keybinding/movement/west
	name = "west"
	full_name = "Идти на запад"
	description = "Двигает персонажа на запад при нажатии"
	hotkey_keys = list("A", "West")
	move_dir = WEST
	keybind_signal = COMSIG_KB_MOVEMENT_WEST_DOWN

/datum/keybinding/movement/zlevel_upwards
	hotkey_keys = list("Northeast") // PGUP
	name = "Upwards"
	full_name = "Подняться"
	description = "Moves your character up a z-level if possible"
	keybind_signal = COMSIG_KB_MOVEMENT_ZLEVEL_MOVEUP_DOWN

/datum/keybinding/movement/zlevel_upwards/down(client/user, turf/target, mousepos_x, mousepos_y)
	. = ..()
	if(.)
		return
	user.mob.move_up()
	return TRUE

/datum/keybinding/movement/zlevel_downwards
	hotkey_keys = list("Southeast") // PGDOWN
	name = "Downwards"
	full_name = "Спуститься"
	description = "Moves your character down a z-level if possible"
	keybind_signal = COMSIG_KB_MOVEMENT_ZLEVEL_MOVEDOWN_DOWN

/datum/keybinding/movement/zlevel_downwards/down(client/user, turf/target, mousepos_x, mousepos_y)
	. = ..()
	if(.)
		return
	user.mob.move_down()
	return TRUE
