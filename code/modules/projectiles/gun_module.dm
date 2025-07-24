//----------------------------------------------------------
			//							    \\
			//         Basic module         \\
			//							    \\
			//						   	    \\
//----------------------------------------------------------
/obj/item/gun_module
	name = "unknown gun module"
	desc = "Неизветный модуль для оружия"
	icon = 'icons/obj/weapons/attachments/muzzle.dmi'
	icon_state = "suppressor"
	item_state = "suppressor"
	w_class = WEIGHT_CLASS_SMALL
	origin_tech = "combat=2;engineering=2"
	var/slot
	var/overlay_state = "enforcer_supp"
	var/overlay_offset


/// Try attach module to gun, return TRUE if success
/obj/item/gun_module/proc/try_attach(obj/item/gun/target_gun, mob/user)
	if(!istype(target_gun, /obj/item/gun/projectile))
		to_chat(user, "[capitalize(target_gun.declent_ru(NOMINATIVE))] не поддерживает установку модулей.")
		return FALSE
	var/obj/item/gun/gun = target_gun
	var/allowed = FALSE
	for(var/allowed_slot as anything in gun.attachable_allowed)
		if(istype(src, allowed_slot))
			allowed = TRUE
			break
	if(!allowed)
		to_chat(user, "[capitalize(declent_ru(NOMINATIVE))] не может быть установлен на [gun.declent_ru(PREPOSITIONAL)]")
		return FALSE
	if(gun.attachments_by_slot[slot] != null)
		to_chat(user, "Слот [gun_module_slot_ru_name(slot)] уже занят другим модулем.")
		return FALSE
	attach_without_check(gun, user)
	return TRUE

/// Attaching module to gun without check, use try_attach(/obj/item/gun/target, mob/user) for checks
/obj/item/gun_module/proc/attach_without_check(obj/item/gun/target_gun, mob/user)
	to_chat(user, "You attach [name] to [target_gun.name]")
	//TODO progressbar
	target_gun.attachments_by_slot[slot] = src
	target_gun.add_attachment_overlay(src)
	user.drop_transfer_item_to_loc(src, target_gun)
	src.on_attach(target_gun, user)
	return TRUE

/// Detaching module from gun without check, use try_detach(/obj/item/gun/target, mob/user) for checks
/obj/item/gun_module/proc/detach_without_check(obj/item/gun/target_gun, mob/user)
	to_chat(user, "You detach [name] to [target_gun.name]")
	//TODO progressbar
	target_gun.attachments_by_slot[slot] = null
	target_gun.remove_attachment_overlay(src)
	src.on_detach(target_gun, user)
	user.put_in_hands(src)
	return TRUE

/obj/item/gun_module/proc/create_overlay()
	return mutable_appearance(icon, overlay_state)

/obj/item/gun_module/proc/on_attach(obj/item/gun/target_gun, mob/user)
	return

/obj/item/gun_module/proc/on_detach(obj/item/gun/target_gun, mob/user)
	return


//----------------------------------------------------------
			//							    \\
			//         Modules              \\
			//							    \\
			//						   	    \\
//----------------------------------------------------------

/obj/item/gun_module/supressor
	name = "suppressor"
	desc = "Универсальный глушитель для стрелкового оружия Синдиката — максимум скрытности для шпионажа."
	ru_names = list(
		NOMINATIVE = "универсальный глушитель",
		GENITIVE = "универсального глушителя",
		DATIVE = "универсальному глушителю",
		ACCUSATIVE = "универсальный глушитель",
		INSTRUMENTAL = "универсальным глушителем",
		PREPOSITIONAL = "универсальном глушителе"
	)
	icon_state = "suppressor"
	item_state = "suppressor"
	overlay_state = "suppressor"
	slot = ATTACHMENT_SLOT_MUZZLE
	origin_tech = "combat=2;engineering=2"
	var/oldsound
	var/initial_w_class


/obj/item/gun_module/supressor/on_attach(obj/item/gun/target_gun, mob/user)
	target_gun.suppressed = TRUE
	target_gun.suppress_muzzle_flash = TRUE
	oldsound = target_gun.fire_sound
	initial_w_class = target_gun.w_class
	target_gun.fire_sound = 'sound/weapons/gunshots/1suppres.ogg'
	target_gun.w_class = WEIGHT_CLASS_NORMAL

/obj/item/gun_module/supressor/on_detach(obj/item/gun/target_gun, mob/user)
	target_gun.suppressed = FALSE
	target_gun.suppress_muzzle_flash = FALSE
	target_gun.fire_sound = oldsound
	target_gun.w_class = initial_w_class



/obj/item/gun_module/muzzle_flash_supressor
	name = "muzzle flash suppressor"
	desc = "Универсальный пламегаситель для стрелкового оружия. Скрывает пламя при стрельбе с огнестрельного оружия."
	ru_names = list(
		NOMINATIVE = "универсальный пламегаситель",
		GENITIVE = "универсального пламегасителя",
		DATIVE = "универсальному пламегасителю",
		ACCUSATIVE = "универсальный пламегаситель",
		INSTRUMENTAL = "универсальным пламегасителем",
		PREPOSITIONAL = "универсальном пламегасителе"
	)
	icon_state = "comp"
	item_state = "comp"
	overlay_state = "comp"
	overlay_offset = list("x" = -2, "y" = 0)
	slot = ATTACHMENT_SLOT_MUZZLE
	origin_tech = "combat=2;engineering=2"
	var/initial_w_class


/obj/item/gun_module/muzzle_flash_supressor/on_attach(obj/item/gun/target_gun, mob/user)
	target_gun.suppress_muzzle_flash = TRUE
	initial_w_class = target_gun.w_class
	target_gun.w_class = WEIGHT_CLASS_NORMAL

/obj/item/gun_module/muzzle_flash_supressor/on_detach(obj/item/gun/target_gun, mob/user)
	target_gun.suppress_muzzle_flash = FALSE
	target_gun.w_class = initial_w_class


