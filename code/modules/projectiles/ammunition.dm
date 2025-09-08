/obj/item/ammo_casing
	name = "bullet casing"
	desc = "Иногда гильза от пули - это просто гильза, и ничего более."
	ru_names = list(
		NOMINATIVE = "гильза от пули",
		GENITIVE = "гильзы от пули",
		DATIVE = "гильзе от пули",
		ACCUSATIVE = "гильзу от пули",
		INSTRUMENTAL = "гильзой от пули",
		PREPOSITIONAL = "гильзе от пули"
	)
	icon = 'icons/obj/weapons/ammo.dmi'
	icon_state = "s-casing"
	origin_tech = "materials=3;combat=3"
	flags = CONDUCT
	slot_flags = ITEM_SLOT_BELT
	throwforce = 1
	w_class = WEIGHT_CLASS_TINY
	materials = list(MAT_METAL = 1000)
	/// What sound should play when this ammo is fired
	var/fire_sound = null
	/// What sound should play when this ammo hits the ground
	var/casing_drop_sound = SFX_CASING_DROP
	/// Which kind of guns it can be loaded into
	var/caliber = null
	/// The bullet type to create when New() is called
	var/projectile_type = null
	/// The loaded bullet
	var/obj/projectile/BB = null
	/// Pellets for spreadshot
	var/pellets = 1
	/// Variance for inaccuracy fundamental to the casing
	var/variance = 0
	/// Delay for energy weapons
	var/delay = 0
	/// Randomspread for automatics
	var/randomspread = FALSE
	/// Override this to make your gun have a faster fire rate, in tenths of a second. 4 is the default gun cooldown.
	var/click_cooldown_override = 0
	/// pacifism check for boolet, set to FALSE if bullet is non-lethal
	var/harmful = TRUE
	/// Остается ли порох на руках и одежде?
	var/leaves_residue
	/// Wheter we can pick this shell by clicking on it with the ammo box
	var/can_be_box_inserted = TRUE

	/// What type of muzzle flash effect will be shown. If null then no effect and flash of light will be shown
	var/muzzle_flash_effect = /obj/effect/temp_visual/target_angled/muzzle_flash
	/// What color the flash has. If null then the flash won't cause lighting
	var/muzzle_flash_color = LIGHT_COLOR_TUNGSTEN
	/// What range the muzzle flash has
	var/muzzle_flash_range = MUZZLE_FLASH_RANGE_WEAK
	/// How strong the flash is
	var/muzzle_flash_strength = MUZZLE_FLASH_STRENGTH_WEAK


/obj/item/ammo_casing/Initialize(mapload)
	. = ..()
	if(projectile_type)
		BB = new projectile_type(src)
	pixel_x = rand(-10, 10)
	pixel_y = rand(-10, 10)
	dir = pick(GLOB.alldirs)
	update_appearance(UPDATE_ICON|UPDATE_DESC)

/obj/item/ammo_casing/Destroy()
	QDEL_NULL(BB)
	if(!isgun(loc))
		return ..()
	var/obj/item/gun/gun = loc
	if(gun.chambered != src)
		return ..()
	gun.chambered = null
	. = ..()

/obj/item/ammo_casing/update_icon_state()
	icon_state = "[initial(icon_state)][BB ? "-live" : ""]"


/obj/item/ammo_casing/update_desc(updates = ALL)
	. = ..()
	desc = "[initial(desc)][BB ? "" : " Эта гильза уже отстрелялась."]"


/obj/item/ammo_casing/proc/newshot(params) //For energy weapons, shotgun shells and wands (!).
	if(!BB)
		BB = new projectile_type(src, params)
	return

/obj/item/ammo_casing/decompile_act(obj/item/matter_decompiler/C, mob/user)
	if(!BB)
		qdel(src)
		return TRUE
	return ..()


/obj/item/ammo_casing/attackby(obj/item/item, mob/user, params)
	if(!istype(item, /obj/item/ammo_box) || !can_be_box_inserted)
		return ..()
	add_fingerprint(user)
	var/obj/item/ammo_box/box = item
	if(!isturf(loc))
		balloon_alert(user, "не получилось собрать")
		return ATTACK_CHAIN_PROCEED
	if(length(box.stored_ammo) >= box.max_ammo)
		balloon_alert(user, "уже заполнено")
		return ATTACK_CHAIN_PROCEED
	var/boolets = 0
	for(var/obj/item/ammo_casing/bullet in loc)
		if(length(box.stored_ammo) >= box.max_ammo)
			break
		if(!bullet.BB)
			continue
		if(!box.can_fast_load)
			playsound(box, box.insert_sound, 50, TRUE)
			if(!do_after(user, box.bullet_load_duration, box, max_interact_count = 1))
				break
			box.update_appearance(UPDATE_ICON|UPDATE_DESC)
		if(box.give_round(bullet, FALSE))
			boolets++
	if(!boolets)
		balloon_alert(user, "не получилось собрать")
		return ATTACK_CHAIN_PROCEED
	box.update_appearance(UPDATE_ICON|UPDATE_DESC)
	to_chat(user, span_notice("Вы собрали [boolets] гильз[declension_ru(boolets,"у","ы","")]. Теперь в [box.declent_ru(GENITIVE)] [length(box.stored_ammo)] гильз[declension_ru(length(box.stored_ammo),"а","ы","")]."))
	if(box.can_fast_load)
		playsound(src, 'sound/weapons/gun_interactions/bulletinsert.ogg', 50, TRUE)
	return ATTACK_CHAIN_PROCEED_SUCCESS


/obj/item/ammo_casing/screwdriver_act(mob/living/user, obj/item/I)
	. = TRUE
	if(!BB)
		to_chat(user, span_warning("В гильзе нет пули для нанесения гравировки."))
		return .
	if(initial(BB.name) != BULLET)
		to_chat(user, span_notice("Вы можете гравировать только металлические пули."))		//because inscribing beanbags is silly
		return .
	if(!I.use_tool(src, user, volume = I.tool_volume))
		return .
	var/label_text = tgui_input_text(user, "Нанесите текст на патрон", "Гравировка", "", 20)
	if(isnull(label_text))
		return .
	if(label_text == "")
		to_chat(user, span_notice("Вы соскабливаете гравировку с патрона."))
		BB.name = initial(BB.name)
	else
		to_chat(user, span_notice("Вы наносите \"[label_text]\" на патрон."))
		BB.ru_names = list(
			NOMINATIVE = "пуля \"[label_text]\"",
			GENITIVE = "пули \"[label_text]\"",
			DATIVE = "пуле \"[label_text]\"",
			ACCUSATIVE = "пулю \"[label_text]\"",
			INSTRUMENTAL = "пулей \"[label_text]\"",
			PREPOSITIONAL = "пуле \"[label_text]\""
		)


/obj/item/ammo_casing/proc/leave_residue(mob/living/carbon/human/H)
	if(QDELETED(H))
		return
	if(istype(H) && H.gloves)
		var/obj/item/clothing/G = H.gloves
		G.gunshot_residue = caliber
	else
		H.gunshot_residue = caliber

/obj/item/ammo_casing/proc/after_fire()
	return

//Boxes of ammo
/obj/item/ammo_box
	name = "ammo box (generic)"
	desc = "Э-э... коробка с патронами?"
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

	var/ammo_box = istype(I, /obj/item/ammo_box) && I != src
	var/ammo_casing = istype(I, /obj/item/ammo_casing)

	if(ammo_box)
		var/obj/item/ammo_box/box = I
		for(var/obj/item/ammo_casing/casing in box.stored_ammo)
			if(!can_fast_load)
				playsound(src, insert_sound, 50, TRUE)
				if(!do_after(user, bullet_load_duration, src, DA_IGNORE_USER_LOC_CHANGE, max_interact_count = 1))
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
	if(istype(I, /obj/item/ammo_box) || istype(I, /obj/item/ammo_casing))
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
		to_chat(user, span_notice("Вы достали патрон из [src.declent_ru(GENITIVE)]!"))
		update_appearance(UPDATE_ICON|UPDATE_DESC)
		user.put_in_hands(casing)


/obj/item/ammo_box/update_desc(updates = ALL)
	. = ..()
	desc = "[initial(desc)] В ней осталось [length(stored_ammo)] патрон[declension_ru(length(stored_ammo), "", "а", "ов")] из [max_ammo] возможных!"


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


//Behavior for magazines
/obj/item/ammo_box/magazine/proc/ammo_count(countempties = TRUE)
	return length(stored_ammo)


/obj/item/ammo_box/magazine/proc/empty_magazine()
	var/atom/drop_loc = drop_location()
	for(var/obj/item/ammo in stored_ammo)
		ammo.forceMove(drop_loc)
		stored_ammo -= ammo
