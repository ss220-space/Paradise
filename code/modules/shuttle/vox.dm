/obj/machinery/computer/shuttle/vox
	name = "skipjack control console"
	req_access = list(ACCESS_VOX)
	shuttleId = "vox_shuttle"
	possible_destinations = "vox_shuttle_away;skipjack_custom"
	resistance_flags = INDESTRUCTIBLE
	obj_flags = NODECONSTRUCT

/obj/machinery/computer/camera_advanced/shuttle_docker/vox
	name = "skipjack navigation computer"
	desc = "Используется, чтобы указать точное местоположение для отправки Скипджека."
	shuttleId = "vox_shuttle"
	shuttlePortId = "skipjack_custom"
	view_range = 13
	x_offset = 4
	y_offset = -8
	resistance_flags = INDESTRUCTIBLE
	obj_flags = NODECONSTRUCT

/obj/docking_port/mobile/scavenger
	id = "vox_shuttle"
	name = "scavenger shuttle"
	dir = SOUTH
	width = 19
	height = 18
	dwidth = 13
