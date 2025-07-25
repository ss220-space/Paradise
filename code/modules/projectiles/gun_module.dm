//----------------------------------------------------------
			//							    \\
			//         Basic module         \\
			//							    \\
			//						   	    \\
//----------------------------------------------------------
/obj/item/gun_module
	name = "unknown gun module"
	desc = "Неизветный модуль для оружия"
	icon_state = "lace"
	item_state = "lace"
	w_class = WEIGHT_CLASS_SMALL
	origin_tech = "combat=2;engineering=2"
	var/slot
	var/overlay_state = "lace"
	var/overlay_offset


/// Try attach module to gun, return TRUE if success
/obj/item/gun_module/proc/try_attach(obj/item/gun/target_gun, mob/user)
	if(!istype(target_gun, /obj/item/gun))
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
	return mutable_appearance(icon, overlay_state, layer = FLOAT_LAYER + 0.1)

/obj/item/gun_module/proc/on_attach(obj/item/gun/target_gun, mob/user)
	return

/obj/item/gun_module/proc/on_detach(obj/item/gun/target_gun, mob/user)
	return


//----------------------------------------------------------
			//							    \\
			//       Muzzle modules         \\
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
	icon = 'icons/obj/weapons/attachments/muzzle.dmi'
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
	icon = 'icons/obj/weapons/attachments/muzzle.dmi'
	icon_state = "comp"
	item_state = "comp"
	overlay_state = "comp"
	overlay_offset = list("x" = -2, "y" = 0)
	slot = ATTACHMENT_SLOT_MUZZLE
	origin_tech = "combat=2;engineering=2"
	var/bonus_accuracy = 10
	var/initial_w_class


/obj/item/gun_module/muzzle_flash_supressor/on_attach(obj/item/gun/target_gun, mob/user)
	target_gun.suppress_muzzle_flash = TRUE
	initial_w_class = target_gun.w_class
	target_gun.w_class = WEIGHT_CLASS_NORMAL
	//TODO apply bonus accuracy

/obj/item/gun_module/muzzle_flash_supressor/on_detach(obj/item/gun/target_gun, mob/user)
	target_gun.suppress_muzzle_flash = FALSE
	target_gun.w_class = initial_w_class
	//TODO remove bonus accuracy





//----------------------------------------------------------
			//							    \\
			//       Rail modules           \\
			//		  (scopes)				\\
			//						   	    \\
//----------------------------------------------------------

/obj/item/gun_module/scope
	icon = 'icons/obj/weapons/attachments/scope.dmi'
	slot = ATTACHMENT_SLOT_RAIL
	origin_tech = "combat=3;engineering=4"
	icon_state = "pmc"
	item_state = "pmc"
	overlay_state = "pmc"
	/// 'zoom' distance
	var/zoom_amount = 1
	/// bonus accuracy for gun
	var/bonus_accuracy = 0
	var/old_zoom_amount

/obj/item/gun_module/scope/on_attach(obj/item/gun/target_gun, mob/user)
	target_gun.zoomable = TRUE
	old_zoom_amount = target_gun.zoom_amt
	target_gun.zoom_amt = zoom_amount
	target_gun.build_zooming()
	if(user.is_in_hands(target_gun))
		target_gun.ZoomGrantCheck(null, user, ITEM_SLOT_HANDS)
	//TODO apply bonus accuracy

/obj/item/gun_module/scope/on_detach(obj/item/gun/target_gun, mob/user)
	target_gun.zoomable = FALSE
	target_gun.zoom_amt = old_zoom_amount
	target_gun.destroy_zooming()
	//TODO remove bonus accuracy


/obj/item/gun_module/scope/collimator
	name = "collimator scope"
	desc = "Коллиматорный прицел с универсальным креплением, подходит для большинства видов оружия. Позволяет удобнее целиться с оружия и повышает точность стрельбы."
	ru_names = list(
		NOMINATIVE = "коллиматорный прицел",
		GENITIVE = "коллиматорного прицела",
		DATIVE = "коллиматорному прицелу",
		ACCUSATIVE = "коллиматорный прицел",
		INSTRUMENTAL = "коллиматорным прицелом",
		PREPOSITIONAL = "коллиматорном прицеле"
	)
	icon_state = "t37"
	item_state = "t37"
	overlay_state = "t37"
	zoom_amount = 3
	bonus_accuracy = 10

/obj/item/gun_module/scope/x4
	name = "optical scope x4"
	desc = "Оптический прицел с 8-кратным увеличением и универсальным креплением, подходит для большинства видов оружия. Позволяет целиться гораздо дальше."
	ru_names = list(
		NOMINATIVE = "оптический прицел х4",
		GENITIVE = "оптического прицела х4",
		DATIVE = "оптическому прицелу х4",
		ACCUSATIVE = "оптический прицел х4",
		INSTRUMENTAL = "оптическим прицелом х4",
		PREPOSITIONAL = "оптическом прицеле х4"
	)
	icon_state = "mosin"
	item_state = "mosin"
	overlay_state = "mosin"
	zoom_amount = 5
	bonus_accuracy = 20

/obj/item/gun_module/scope/x8
	name = "optical scope x8"
	desc = "Оптический прицел с 8-кратным увеличением и универсальным креплением, подходит для большинства видов оружия. Позволяет целиться гораздо дальше."
	ru_names = list(
		NOMINATIVE = "оптический прицел х8",
		GENITIVE = "оптического прицела х8",
		DATIVE = "оптическому прицелу х8",
		ACCUSATIVE = "оптический прицел х8",
		INSTRUMENTAL = "оптическим прицелом х8",
		PREPOSITIONAL = "оптическом прицеле х8"
	)
	icon_state = "tes"
	item_state = "tes"
	overlay_state = "tes"
	zoom_amount = 7
	bonus_accuracy = 30

/obj/item/gun_module/scope/x16
	name = "optical scope x16"
	desc = "Оптический прицел с 16-кратным увеличением и универсальным креплением, подходит для большинства видов оружия. Позволяет целиться гораздо дальше."
	ru_names = list(
		NOMINATIVE = "оптический прицел х16",
		GENITIVE = "оптического прицела х16",
		DATIVE = "оптическому прицелу х16",
		ACCUSATIVE = "оптический прицел х16",
		INSTRUMENTAL = "оптическим прицелом х16",
		PREPOSITIONAL = "оптическом прицеле х16"
	)
	icon_state = "tl127_a"
	item_state = "tl127_a"
	overlay_state = "tl127_a"
	overlay_offset = list("x" = 0, "y" = 1)
	zoom_amount = 11
	bonus_accuracy = 50
