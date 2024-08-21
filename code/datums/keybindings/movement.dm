/datum/keybinding/movement
	category = KB_CATEGORY_MOVEMENT
	/// The direction to move to when held.
	var/move_dir

/datum/keybinding/movement/north
	name = "Идти наверх"
	keys = list("W", "North")
	move_dir = NORTH

/datum/keybinding/movement/south
	name = "Идти вниз"
	keys = list("S", "South")
	move_dir = SOUTH

/datum/keybinding/movement/east
	name = "Идти вправо"
	keys = list("D", "East")
	move_dir = EAST

/datum/keybinding/movement/west
	name = "Идти влево"
	keys = list("A", "West")
	move_dir = WEST

/datum/keybinding/lock
	name = "Остановиться (зажать)"
	category = KB_CATEGORY_MOVEMENT
	keys = list("Ctrl")


/datum/keybinding/lock/down(client/user)
	. = ..()
	if(.)
		return .
	user.movement_locked = TRUE


/datum/keybinding/lock/up(client/user)
	. = ..()
	if(.)
		return .
	user.movement_locked = FALSE

