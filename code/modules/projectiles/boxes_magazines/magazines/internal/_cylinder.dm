/obj/item/ammo_box/magazine/internal/cylinder
	name = "revolver cylinder"
	ammo_type = /obj/item/ammo_casing/a357
	caliber = CALIBER_DOT_357

/obj/item/ammo_box/magazine/internal/cylinder/Initialize(mapload)
	. = ..()
	if(start_empty)
		for(var/i in 1 to max_ammo)
			stored_ammo += null	// thats right, we fill empty cylinders with nulls

/obj/item/ammo_box/magazine/internal/cylinder/ammo_count(countempties = TRUE)
	. = 0
	for(var/obj/item/ammo_casing/bullet in stored_ammo)
		if(bullet.BB || countempties)
			.++

/obj/item/ammo_box/magazine/internal/cylinder/get_round(keep = FALSE)
	rotate()

	var/b = stored_ammo[1]
	if(!keep)
		stored_ammo[1] = null

	return b

/obj/item/ammo_box/magazine/internal/cylinder/proc/rotate()
	var/b = stored_ammo[1]
	stored_ammo.Cut(1,2)
	stored_ammo.Insert(0, b)

/obj/item/ammo_box/magazine/internal/cylinder/proc/spin()
	for(var/i in 1 to rand(0, max_ammo*2))
		rotate()

/obj/item/ammo_box/magazine/internal/cylinder/give_round(obj/item/ammo_casing/new_casing, replace_spent = FALSE, count_chambered = FALSE, mob/user)
	if(!ammo_suitability(new_casing))
		return FALSE

	for(var/i in 1 to length(stored_ammo))
		var/obj/item/ammo_casing/casing = stored_ammo[i]
		if(!casing || !casing.BB) // found a spent ammo
			if(user && new_casing.loc == user && !user.drop_transfer_item_to_loc(new_casing, src))
				return FALSE
			stored_ammo[i] = new_casing
			if(new_casing.loc != src)
				new_casing.forceMove(src)
			if(casing)
				casing.forceMove(get_turf(user))
				playsound(casing.loc, casing.casing_drop_sound, 60, TRUE)
				casing.pixel_x = rand(-10, 10)
				casing.pixel_y = rand(-10, 10)
				casing.setDir(pick(GLOB.alldirs))
				casing.update_appearance()
				casing.SpinAnimation(10, 1)
			return TRUE

	return FALSE
