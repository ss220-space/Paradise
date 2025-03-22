/datum/hud/simple_animal/facehugger/New(mob/user)
	. = ..()
	var/atom/movable/screen/using


	using = new /atom/movable/screen/language_menu(null, src)
	static_inventory += using
