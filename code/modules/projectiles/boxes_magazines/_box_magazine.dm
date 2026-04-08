// MARK: Ammo box
/obj/item/ammo_box
	name = "ammo box (generic)"
	desc = "Э-э... коробка с патронами?"
	gender = FEMALE
	icon_state = "357"
	icon = 'icons/obj/weapons/ammo.dmi'
	origin_tech = "materials=3;combat=3"
	flags = CONDUCT
	slot_flags = ITEM_SLOT_BELT
	item_state = "syringe_kit"
	materials = list(MAT_METAL = 500)
	throwforce = 2
	w_class = WEIGHT_CLASS_TINY
	throw_speed = 4
	throw_range = 10
	pickup_sound = 'sound/items/handling/pickup/ammobox_pickup.ogg'
	drop_sound = 'sound/items/handling/drop/ammobox_drop.ogg'
	override_notes = TRUE
	var/list/stored_ammo = list()
	var/ammo_type = /obj/item/ammo_casing
	var/start_empty = FALSE
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
	/// Reload ammo box without progress bar
	var/can_fast_load = TRUE
	/// One bullet load duration
	var/bullet_load_duration = 0.4 SECONDS
	/// Use bullet type overlay
	var/use_bullet_type_overlay = FALSE

/obj/item/ammo_box/Initialize(mapload)
	. = ..()

	if(!start_empty && ammo_type)
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
	if(!length(stored_ammo))
		return null

	var/bullet = stored_ammo[length(stored_ammo)]
	stored_ammo -= bullet
	if(keep)
		stored_ammo.Insert(1, bullet)
	update_mat_value()
	update_icon()
	return bullet

/obj/item/ammo_box/add_weapon_description()
	AddElement(/datum/element/weapon_description, attached_proc = PROC_REF(add_notes_box))

/obj/item/ammo_box/proc/add_notes_box()
	var/list/readout = list()

	if(caliber && max_ammo) // Text references a 'мазагин' as only magazines generally have the caliber variable initialized
		readout += "<b><u>ВМЕСТИМОСТЬ</u></b>"
		readout += "- Вмещает в себя вплоть до <b>[max_ammo]</b> патрон[declension_ru(max_ammo, "а", "ов", "ов")] калибра <b>[caliber]</b>."

	var/obj/item/ammo_casing/mag_ammo = get_round(TRUE)

	if(istype(mag_ammo))
		readout += "[mag_ammo.add_notes_ammo()]"

	return readout.Join("\n")

/obj/item/ammo_box/update_overlays()
	. = ..()
	if(!use_bullet_type_overlay)
		return
	var/ammo = length(stored_ammo)
	if(!ammo)
		return
	var/bullet_type = get_bullet_type()
	if(!bullet_type)
		return
	. += image('icons/obj/weapons/ammo_type_overlay.dmi', icon_state = bullet_type)

/obj/item/ammo_box/proc/get_bullet_type()
	var/ammo = length(stored_ammo)
	if(!ammo)
		return null
	var/obj/item/ammo_casing/last_bullet = stored_ammo[length(stored_ammo)]
	if(!istype(last_bullet))
		return null
	return last_bullet.bullet_type

/obj/item/ammo_box/proc/give_round(obj/item/ammo_casing/new_casing, replace_spent = FALSE, count_chambered = FALSE, mob/user)
	if(!ammo_suitability(new_casing))
		return FALSE

	var/current_ammo = length(stored_ammo)
	if(count_chambered && isgun(loc))
		var/obj/item/gun/our_holder = loc
		if(our_holder.chambered)
			current_ammo += 1

	if(current_ammo < max_ammo)
		if(user && new_casing.loc == user && !user.drop_transfer_item_to_loc(new_casing, src, silent = TRUE))
			return FALSE
		stored_ammo += new_casing
		if(new_casing.loc != src)
			new_casing.forceMove(src)
		var/chosen_sound = insert_sound
		if(islist(insert_sound) && length(insert_sound))
			chosen_sound = pick(insert_sound)
		playsound(loc, chosen_sound, 50, TRUE)
		update_mat_value()
		return TRUE

	//for accessibles magazines (e.g internal ones) when full, start replacing spent ammo
	else if(replace_spent)
		for(var/obj/item/ammo_casing/stored_casing in stored_ammo)
			if(!stored_casing.BB)//found a spent ammo
				if(user && new_casing.loc == user && !user.drop_transfer_item_to_loc(new_casing, src, silent = TRUE))
					return FALSE
				stored_ammo -= stored_casing
				stored_casing.forceMove(drop_location())
				stored_casing.pixel_x = rand(-10, 10)
				stored_casing.pixel_y = rand(-10, 10)
				stored_casing.setDir(pick(GLOB.alldirs))
				stored_casing.update_appearance()
				stored_casing.SpinAnimation(10, 1)
				playsound(stored_casing.loc, stored_casing.casing_drop_sound, 60, TRUE)
				stored_ammo += new_casing
				if(new_casing.loc != src)
					new_casing.forceMove(src)
				var/chosen_sound = replacing_sound
				if(islist(replacing_sound) && length(replacing_sound))
					chosen_sound = pick(replacing_sound)
				playsound(loc, chosen_sound, 50, TRUE)
				update_mat_value()
				return TRUE

	return FALSE

/obj/item/ammo_box/proc/ammo_suitability(obj/item/ammo_casing/new_casing)
	// Boxes don't have a caliber type, magazines do. Not sure if it's intended or not, but if we fail to find a caliber, then we fall back to ammo_type.
	if(!new_casing || (caliber && new_casing.caliber != caliber) || (!caliber && new_casing.type != ammo_type))
		return FALSE
	return TRUE

/// Reloads ammo box and its child types - magazines. Returns the number of reloaded shells.
/obj/item/ammo_box/proc/reload(obj/item/I, mob/user, silent = FALSE, replace_spent = FALSE, count_chambered = FALSE)
	. = 0

	if(user)
		add_fingerprint(user)
		I.add_fingerprint(user)

	var/ammo_box = isammobox(I) && I != src
	var/ammo_casing = isammocasing(I)

	if(ammo_box)
		var/obj/item/ammo_box/box = I
		for(var/obj/item/ammo_casing/casing in box.stored_ammo)
			if(!can_fast_load)
				playsound(src, insert_sound, 50, TRUE)
				if(!do_after(user, bullet_load_duration, box, DA_IGNORE_USER_LOC_CHANGE, max_interact_count = 1))
					break
				box.update_appearance()
				box.update_equipped_item()
				update_appearance()
				update_equipped_item()
				if(!user.Adjacent(src))
					break
			var/did_load = give_round(casing, replace_spent, count_chambered, user)
			if(did_load)
				box.stored_ammo -= casing
				.++
			if(!multiload || !did_load)
				break
		if(.)
			box.update_mat_value()

	else if(ammo_casing)
		if(give_round(I, replace_spent, count_chambered, user))
			.++

	if(!.)
		if(!silent && user && (ammo_box || ammo_casing))
			balloon_alert(user, "не удалось!")
		return .
	if(!silent && user)
		balloon_alert(user, "[declension_ru(., "заряжен [.] патрон", "заряжено [.] патрона", "заряжено [.] патронов")]")
	var/chosen_sound = load_sound
	if(islist(load_sound) && length(load_sound))
		chosen_sound = pick(load_sound)
	playsound(loc, chosen_sound, 50, TRUE)
	I.update_appearance()
	I.update_equipped_item()
	update_appearance()
	update_equipped_item()

/obj/item/ammo_box/attackby(obj/item/I, mob/user, params)
	if(isammobox(I) || isammocasing(I))
		if(reload(I, user))
			return ATTACK_CHAIN_BLOCKED_ALL
		return ATTACK_CHAIN_PROCEED
	return ..()

/obj/item/ammo_box/attack_self(mob/user)
	var/obj/item/ammo_casing/casing = get_round()
	if(casing)
		casing.forceMove(drop_location())
		var/chosen_sound = remove_sound
		if(islist(remove_sound) && length(remove_sound))
			chosen_sound = pick(remove_sound)
		playsound(loc, chosen_sound, 50, TRUE)
		to_chat(user, span_notice("Вы достали патрон из [declent_ru(GENITIVE)]!"))
		update_appearance(UPDATE_ICON|UPDATE_DESC)
		user.put_in_hands(casing)

/obj/item/ammo_box/click_alt(mob/user)
	attack_self(user)

/obj/item/ammo_box/update_desc(updates = ALL)
	. = ..()
	desc = "[initial(desc)] В [GEND_EM_EI_EM_IH(src)] осталось [length(stored_ammo)] патрон[DECL_CREDIT(length(stored_ammo))] из [max_ammo] возможных!"

/obj/item/ammo_box/update_icon_state()
	var/icon_base = icon_prefix ? icon_prefix : initial(icon_state)
	icon_state = icon_base
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

// MARK: Мagazine
/obj/item/ammo_box/magazine
	gender = MALE
	materials = list(MAT_METAL = 2000)
	can_fast_load = FALSE
	use_bullet_type_overlay = TRUE

/obj/item/ammo_box/magazine/proc/ammo_count(countempties = TRUE)
	return length(stored_ammo)

/obj/item/ammo_box/magazine/proc/empty_magazine()
	var/atom/drop_loc = drop_location()
	for(var/obj/item/ammo in stored_ammo)
		ammo.forceMove(drop_loc)
		stored_ammo -= ammo
