/obj/item/ammo_casing
	name = "bullet casing"
	desc = "A bullet casing."
	icon = 'icons/obj/weapons/ammo.dmi'
	icon_state = "s-casing"
	flags = CONDUCT
	slot_flags = SLOT_BELT
	throwforce = 1
	w_class = WEIGHT_CLASS_TINY
	materials = list(MAT_METAL = 1000)
	var/fire_sound = null						//What sound should play when this ammo is fired
	var/casing_drop_sound = "casingdrop"               //What sound should play when this ammo hits the ground
	var/caliber = null							//Which kind of guns it can be loaded into
	var/projectile_type = null					//The bullet type to create when New() is called
	var/obj/item/projectile/BB = null 			//The loaded bullet
	var/pellets = 1								//Pellets for spreadshot
	var/variance = 0							//Variance for inaccuracy fundamental to the casing
	var/delay = 0								//Delay for energy weapons
	var/randomspread = FALSE						//Randomspread for automatics
	var/click_cooldown_override = 0				//Override this to make your gun have a faster fire rate, in tenths of a second. 4 is the default gun cooldown.
	var/harmful = TRUE							//pacifism check for boolet, set to FALSE if bullet is non-lethal
	var/leaves_residue      		    		//Остается ли порох на руках и одежде?

	/// What type of muzzle flash effect will be shown. If null then no effect and flash of light will be shown
	var/muzzle_flash_effect = /obj/effect/temp_visual/target_angled/muzzle_flash
	/// What color the flash has. If null then the flash won't cause lighting
	var/muzzle_flash_color = LIGHT_COLOR_TUNGSTEN
	/// What range the muzzle flash has
	var/muzzle_flash_range = MUZZLE_FLASH_RANGE_WEAK
	/// How strong the flash is
	var/muzzle_flash_strength = MUZZLE_FLASH_STRENGTH_WEAK


/obj/item/ammo_casing/New()
	..()
	if(projectile_type)
		BB = new projectile_type(src)
	pixel_x = rand(-10, 10)
	pixel_y = rand(-10, 10)
	dir = pick(GLOB.alldirs)
	update_appearance(UPDATE_ICON|UPDATE_DESC)


/obj/item/ammo_casing/update_icon_state()
	icon_state = "[initial(icon_state)][BB ? "-live" : ""]"


/obj/item/ammo_casing/update_desc(updates = ALL)
	. = ..()
	desc = "[initial(desc)][BB ? "" : " This one is spent."]"


/obj/item/ammo_casing/proc/newshot(params) //For energy weapons, shotgun shells and wands (!).
	if(!BB)
		BB = new projectile_type(src, params)
	return

/obj/item/ammo_casing/decompile_act(obj/item/matter_decompiler/C, mob/user)
	if(!BB)
		qdel(src)
		return TRUE
	return ..()

/obj/item/ammo_casing/attackby(obj/item/I, mob/user, params)
	if(istype(I, /obj/item/ammo_box))
		var/obj/item/ammo_box/box = I
		if(isturf(loc))
			var/boolets = 0
			for(var/obj/item/ammo_casing/bullet in loc)
				if(box.stored_ammo.len >= box.max_ammo)
					break
				if(bullet.BB)
					if(box.give_round(bullet, FALSE))
						boolets++
				else
					continue
			if(boolets > 0)
				box.update_appearance(UPDATE_ICON|UPDATE_DESC)
				to_chat(user, span_notice("You collect [boolets] shell\s. [box] now contains [box.stored_ammo.len] shell\s."))
				playsound(src, 'sound/weapons/gun_interactions/bulletinsert.ogg', 50, 1)
			else
				to_chat(user, span_warning("You fail to collect anything!"))
	else
		if(I.tool_behaviour == TOOL_SCREWDRIVER)
			if(BB)
				if(initial(BB.name) == "bullet")
					var/tmp_label = ""
					var/label_text = sanitize(input(user, "Inscribe some text into \the [initial(BB.name)]","Inscription",tmp_label))
					if(length(label_text) > 20)
						to_chat(user, span_warning("The inscription can be at most 20 characters long."))
					else
						if(label_text == "")
							to_chat(user, span_notice("You scratch the inscription off of [initial(BB)]."))
							BB.name = initial(BB.name)
						else
							to_chat(user, span_notice("You inscribe \"[label_text]\" into \the [initial(BB.name)]."))
							BB.name = "[initial(BB.name)] \"[label_text]\""
				else
					to_chat(user, span_notice("You can only inscribe a metal bullet."))	//because inscribing beanbags is silly

			else
				to_chat(user, span_notice("There is no bullet in the casing to inscribe anything into."))
		..()

/obj/item/ammo_casing/proc/leave_residue(mob/living/carbon/human/H)
	if(QDELETED(H))
		return
	if(istype(H) && H.gloves)
		var/obj/item/clothing/G = H.gloves
		G.gunshot_residue = caliber
	else
		H.gunshot_residue = caliber

//Boxes of ammo
/obj/item/ammo_box
	name = "ammo box (generic)"
	desc = "A box of ammo?"
	icon_state = "357"
	icon = 'icons/obj/weapons/ammo.dmi'
	flags = CONDUCT
	slot_flags = SLOT_BELT
	item_state = "syringe_kit"
	materials = list(MAT_METAL = 500)
	throwforce = 2
	w_class = WEIGHT_CLASS_TINY
	throw_speed = 4
	throw_range = 10
	pickup_sound = 'sound/items/handling/ammobox_pickup.ogg'
	drop_sound = 'sound/items/handling/ammobox_drop.ogg'
	var/list/stored_ammo = list()
	var/ammo_type = /obj/item/ammo_casing
	var/max_ammo = 7
	var/multiple_sprites = 0
	var/icon_prefix // boxes with multiple sprites use this as their base
	var/caliber
	var/multiload = TRUE
	var/list/initial_mats
	var/replacing_sound = 'sound/weapons/gun_interactions/shotguninsert.ogg'
	var/remove_sound = 'sound/weapons/gun_interactions/remove_bullet.ogg'
	var/insert_sound = 'sound/weapons/gun_interactions/bulletinsert.ogg'
	var/load_sound = 'sound/weapons/gun_interactions/shotguninsert.ogg'

/obj/item/ammo_box/New()
	..()
	if(ammo_type)
		for(var/i in 1 to max_ammo)
			stored_ammo += new ammo_type(src)
	update_appearance(UPDATE_ICON|UPDATE_DESC)
	initial_mats = materials.Copy()
	update_mat_value()

/obj/item/ammo_box/Destroy()
	QDEL_LIST(stored_ammo)
	stored_ammo = null
	return ..()

/obj/item/ammo_box/proc/get_round(keep = FALSE)
	if(!stored_ammo.len)
		return null
	else
		var/b = stored_ammo[stored_ammo.len]
		stored_ammo -= b
		if(keep)
			stored_ammo.Insert(1,b)
		update_mat_value()
		update_icon()
		return b

/obj/item/ammo_box/proc/give_round(obj/item/ammo_casing/R, replace_spent = FALSE)
	if(!ammo_suitability(R))
		return FALSE

	if(stored_ammo.len < max_ammo)
		stored_ammo += R
		R.loc = src
		playsound(src, insert_sound, 50, 1)
		update_mat_value()
		return TRUE
	//for accessibles magazines (e.g internal ones) when full, start replacing spent ammo
	else if(replace_spent)
		for(var/obj/item/ammo_casing/AC in stored_ammo)
			if(!AC.BB)//found a spent ammo
				stored_ammo -= AC
				AC.loc = get_turf(loc)

				stored_ammo += R
				R.loc = src
				playsound(src, replacing_sound, 50, 1)
				update_mat_value()
				return TRUE

	return FALSE

/obj/item/ammo_box/proc/ammo_suitability(obj/item/ammo_casing/bullet)
	// Boxes don't have a caliber type, magazines do. Not sure if it's intended or not, but if we fail to find a caliber, then we fall back to ammo_type.
	if(!bullet || (caliber && bullet.caliber != caliber) || (!caliber && bullet.type != ammo_type))
		return FALSE
	return TRUE

/obj/item/ammo_box/proc/can_load(mob/user)
	return TRUE

/obj/item/ammo_box/attackby(obj/item/A, mob/user, params, silent = FALSE, replace_spent = FALSE)
	var/num_loaded = 0
	if(!can_load(user))
		return
	if(istype(A, /obj/item/ammo_box))
		var/obj/item/ammo_box/AM = A
		for(var/obj/item/ammo_casing/AC in AM.stored_ammo)
			var/did_load = give_round(AC, replace_spent)
			if(did_load)
				AM.stored_ammo -= AC
				num_loaded++
			if(!multiload || !did_load)
				break
		AM.update_mat_value()
	if(istype(A, /obj/item/ammo_casing))
		var/obj/item/ammo_casing/AC = A
		if(give_round(AC, replace_spent))
			user.drop_transfer_item_to_loc(AC, src)
			num_loaded++
	if(num_loaded)
		if(!silent)
			to_chat(user, span_notice("You load [num_loaded] shell\s into \the [src]!"))
		playsound(src, load_sound, 50, 1)
		A.update_appearance(UPDATE_ICON|UPDATE_DESC)
		update_appearance(UPDATE_ICON|UPDATE_DESC)

	return num_loaded

/obj/item/ammo_box/attack_self(mob/user)
	var/obj/item/ammo_casing/A = get_round()
	if(A)
		user.put_in_hands(A)
		playsound(src, remove_sound, 50, 1)
		to_chat(user, span_notice("You remove a round from \the [src]!"))
		update_appearance(UPDATE_ICON|UPDATE_DESC)


/obj/item/ammo_box/update_desc(updates = ALL)
	. = ..()
	desc = "[initial(desc)] There are [length(stored_ammo)] shell\s left!"


/obj/item/ammo_box/update_icon_state()
	var/icon_base = initial(icon_prefix) ? initial(icon_prefix) : initial(icon_state)
	switch(multiple_sprites)
		if(1)
			icon_state = "[icon_base]-[length(stored_ammo)]"
		if(2)
			icon_state = "[icon_base]-[length(stored_ammo) ? "[max_ammo]" : "0"]"


/obj/item/ammo_box/update_materials_coeff(new_coeff)
	. = ..()
	for(var/obj/item/ammo_casing/ammo in stored_ammo)
		if(!ammo.BB || !length(ammo.materials)) //Skip any casing which are empty
			continue
		ammo.update_materials_coeff(materials_coeff)
	update_mat_value()

/obj/item/ammo_box/proc/update_mat_value()
	materials = initial_mats.Copy()
	for(var/material in materials)
		materials[material] *= materials_coeff
	for(var/obj/item/ammo_casing/ammo in stored_ammo)
		if(!ammo.BB || !length(ammo.materials)) //Skip any casing which are empty
			continue
		for(var/material in ammo.materials)
			materials[material] += ammo.materials[material]

//Behavior for magazines
/obj/item/ammo_box/magazine/proc/ammo_count(countempties = TRUE)
	return length(stored_ammo)

/obj/item/ammo_box/magazine/proc/empty_magazine()
	var/turf_mag = get_turf(src)
	for(var/obj/item/ammo in stored_ammo)
		ammo.forceMove(turf_mag)
		stored_ammo -= ammo
