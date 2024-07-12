/obj/machinery/cooker/foodgrill
	name = "grill"
	desc = "Backyard grilling, IN SPACE."
	icon = 'icons/obj/machines/cooking_machines.dmi'
	icon_state = "grill_off"
	thiscooktype = "grilled"
	burns = 1
	firechance = 20
	cooktime = 50
	foodcolor = "#A34719"
	onicon = "grill_on"
	officon = "grill_off"

/obj/machinery/cooker/foodgrill/putIn(obj/item/In, mob/chef)
	..()
	var/image/img = new(In.icon, In.icon_state)
	img.pixel_y = 5
	add_overlay(img)
	sleep(50)
	cut_overlay(img)
	img.color = "#C28566"
	add_overlay(img)
	sleep(50)
	cut_overlay(img)
	img.color = "#A34719"
	add_overlay(img)
	sleep(50)
	cut_overlay(img)

