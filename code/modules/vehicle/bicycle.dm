/obj/vehicle/bicycle
	name = "bicycle"
	desc = "Keep away from electricity."
	icon = 'icons/vehicles/bicycle.dmi'
	icon_state = "bicycle"
	generic_pixel_x = 0
	generic_pixel_y = 4
	vehicle_move_delay = 0.4

/obj/vehicle/bicycle/tesla_act()
	name = "fried bicycle"
	desc = "Well spent."
	color = rgb(63, 23, 4)
	for(var/m in buckled_mobs)
		unbuckle_mob(m,1)
