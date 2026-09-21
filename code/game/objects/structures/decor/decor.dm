// The purpose of "Decor" structures is to look like pre-existing objects without having functionality

/obj/structure/decor
	name = "Non-existent Decor"
	desc = "Yell at a coder!"
	anchored = TRUE
	density = TRUE

/obj/structure/decor/ifv
	name = "destroyed M34 IFV"
	desc = "Уничтоженная БМП. Так просто не поднять – сорок шесть тонн..."
	icon = 'icons/obj/structures/ifv_prop.dmi'
	icon_state = "ifv_destroyed"
	resistance_flags = INDESTRUCTIBLE

/obj/structure/decor/ifv/get_ru_names()
	return alist(
		NOMINATIVE = "уничтоженная БМП M34",
		GENITIVE = "уничтоженной БМП M34",
		DATIVE = "уничтоженной БМП M34",
		ACCUSATIVE = "уничтоженную БМП M34",
		INSTRUMENTAL = "уничтоженной БМП M34",
		PREPOSITIONAL = "уничтоженной БМП M34",
	)

/obj/structure/decor/ifv/Initialize(mapload, newdir)
	. = ..()
	if(newdir)
		setDir(newdir)
	switch(dir)
		if(NORTH, SOUTH)
			bound_width = 64
			bound_height = 128
		if(EAST, WEST)
			bound_width = 128
			bound_height = 64

/obj/structure/decor/destroyed_sensor
	name = "destroyed sensor"
	icon = 'icons/obj/structures/motion_sensor_v2.dmi'
	icon_state = "sensor_broken"
	resistance_flags = INDESTRUCTIBLE
