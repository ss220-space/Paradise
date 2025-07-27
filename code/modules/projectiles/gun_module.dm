//----------------------------------------------------------
			//							    \\
			//         Basic module         \\
			//							    \\
			//						   	    \\
//----------------------------------------------------------
/obj/item/gun_module
	name = "unknown gun module"
	desc = "Неизветный модуль для оружия"
	icon = 'icons/obj/weapons/attachments.dmi'
	w_class = WEIGHT_CLASS_SMALL
	origin_tech = "combat=2;engineering=2"
	var/slot
	var/class
	var/overlay_state = "comp"
	var/overlay_offset


/// Try attach module to gun, return TRUE if success
/obj/item/gun_module/proc/try_attach(obj/item/gun/target_gun, mob/user)
	if(!istype(target_gun, /obj/item/gun))
		to_chat(user, "[capitalize(target_gun.declent_ru(NOMINATIVE))] не поддерживает установку модулей.")
		return FALSE
	var/obj/item/gun/gun = target_gun
	var/allowed = gun.attachable_allowed & class
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
	icon_state = "supp"
	item_state = "supp"
	overlay_state = "supp"
	overlay_offset = list("x" = -1, "y" = 0)
	slot = ATTACHMENT_SLOT_MUZZLE
	class = GUN_MODULE_CLASS_PISTOL_MUZZLE | GUN_MODULE_CLASS_RIFLE_MUZZLE | GUN_MODULE_CLASS_SNIPER_MUZZLE
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
	overlay_offset = list("x" = -3, "y" = 0)
	slot = ATTACHMENT_SLOT_MUZZLE
	class = GUN_MODULE_CLASS_PISTOL_MUZZLE | GUN_MODULE_CLASS_RIFLE_MUZZLE | GUN_MODULE_CLASS_SNIPER_MUZZLE
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
	slot = ATTACHMENT_SLOT_RAIL
	origin_tech = "combat=3;engineering=4"
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
	icon_state = "coll"
	item_state = "coll"
	overlay_state = "coll"
	overlay_offset = list("x" = -5, "y" = 0)
	class = GUN_MODULE_CLASS_PISTOL_RAIL | GUN_MODULE_CLASS_SHOTGUN_RAIL | GUN_MODULE_CLASS_RIFLE_RAIL | GUN_MODULE_CLASS_SNIPER_RAIL
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
	icon_state = "x4"
	item_state = "x4"
	overlay_state = "x4"
	overlay_offset = list("x" = -5, "y" = 0)
	class = GUN_MODULE_CLASS_SHOTGUN_RAIL | GUN_MODULE_CLASS_RIFLE_RAIL | GUN_MODULE_CLASS_SNIPER_RAIL
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
	icon_state = "x8"
	item_state = "x8"
	overlay_state = "x8"
	overlay_offset = list("x" = -5, "y" = 0)
	class = GUN_MODULE_CLASS_RIFLE_RAIL | GUN_MODULE_CLASS_SNIPER_RAIL
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
	icon_state = "x16"
	item_state = "x16"
	overlay_state = "x16"
	overlay_offset = list("x" = -3, "y" = 0)
	class = GUN_MODULE_CLASS_RIFLE_RAIL | GUN_MODULE_CLASS_SNIPER_RAIL
	zoom_amount = 11
	bonus_accuracy = 50


/obj/item/gun_module/hud
	slot = ATTACHMENT_SLOT_RAIL
	origin_tech = "combat=3;engineering=4"
	var/hud_type

/obj/item/gun_module/hud/on_attach(obj/item/gun/target_gun, mob/user)
	RegisterSignal(target_gun, COMSIG_ITEM_EQUIPPED, PROC_REF(equip_gun_check))
	RegisterSignal(target_gun, COMSIG_ITEM_DROPPED, PROC_REF(drop_gun_check))
	if(user.is_in_hands(target_gun))
		equip_gun_check(null, user, ITEM_SLOT_HANDS)

/obj/item/gun_module/hud/on_detach(obj/item/gun/target_gun, mob/user)
	UnregisterSignal(target_gun, COMSIG_ITEM_EQUIPPED)
	UnregisterSignal(target_gun, COMSIG_ITEM_DROPPED)
	remove_hud(user)

/obj/item/gun_module/hud/proc/equip_gun_check(datum/source, mob/user, slot)
	if(!(slot & ITEM_SLOT_HANDS))
		remove_hud(user)
		return
	grant_hud(user)

/obj/item/gun_module/hud/proc/drop_gun_check(datum/source, mob/user)
	remove_hud(user)

/obj/item/gun_module/hud/proc/grant_hud(mob/user)
	if(islist(hud_type))
		for(var/new_hud in hud_type)
			var/datum/atom_hud/hud = GLOB.huds[new_hud]
			hud.add_hud_to(user)
		return .
	var/datum/atom_hud/hud = GLOB.huds[hud_type]
	hud.add_hud_to(user)

/obj/item/gun_module/hud/proc/remove_hud(mob/user)
	if(islist(hud_type))
		for(var/new_hud in hud_type)
			var/datum/atom_hud/hud = GLOB.huds[new_hud]
			hud.remove_hud_from(user)
		return .
	var/datum/atom_hud/hud = GLOB.huds[hud_type]
	hud.remove_hud_from(user)


/obj/item/gun_module/hud/medical
	name = "med hud scope"
	desc = "Медицинский худ в виде коллиматорного прицела"
	ru_names = list(
		NOMINATIVE = "медицинский коллиматор",
		GENITIVE = "медицинского коллиматора",
		DATIVE = "медицинскому коллиматору",
		ACCUSATIVE = "медицинский коллиматор",
		INSTRUMENTAL = "медицинским коллиматором",
		PREPOSITIONAL = "медицинском коллиматоре"
	)
	icon_state = "coll"
	item_state = "coll"
	overlay_state = "coll"
	overlay_offset = list("x" = -5, "y" = 0)
	hud_type = DATA_HUD_MEDICAL_ADVANCED
	class = GUN_MODULE_CLASS_PISTOL_RAIL | GUN_MODULE_CLASS_SHOTGUN_RAIL | GUN_MODULE_CLASS_RIFLE_RAIL | GUN_MODULE_CLASS_SNIPER_RAIL

/obj/item/gun_module/hud/security
	name = "security hud scope"
	desc = "Худ службы безопасности в виде коллиматорного прицела"
	ru_names = list(
		NOMINATIVE = "худ СБ коллиматор",
		GENITIVE = "худ СБ коллиматора",
		DATIVE = "худ СБ коллиматору",
		ACCUSATIVE = "худ СБ коллиматор",
		INSTRUMENTAL = "худ СБ коллиматором",
		PREPOSITIONAL = "худ СБ коллиматоре"
	)
	icon_state = "coll_p"
	item_state = "coll_p"
	overlay_state = "coll_p"
	overlay_offset = list("x" = -5, "y" = 0)
	hud_type = DATA_HUD_SECURITY_ADVANCED
	class = GUN_MODULE_CLASS_PISTOL_RAIL | GUN_MODULE_CLASS_SHOTGUN_RAIL | GUN_MODULE_CLASS_RIFLE_RAIL | GUN_MODULE_CLASS_SNIPER_RAIL



//----------------------------------------------------------
			//							    \\
			//       Under modules          \\
			//	  (bayonet,light,laser)		\\
			//						   	    \\
//----------------------------------------------------------

/obj/item/gun_module/under
	icon = 'icons/obj/weapons/attachments/underbarrel.dmi'
	slot = ATTACHMENT_SLOT_UNDER
	origin_tech = "combat=2;engineering=2"
	icon_state = "uflashlight"
	item_state = "uflashlight"
	overlay_state = "uflashlight"

/obj/item/gun_module/under/flashlight
	icon_state = "uflashlight"
	item_state = "uflashlight"
	overlay_state = "uflashlight"
	var/obj/item/flashlight/seclite/internal
	class = GUN_MODULE_CLASS_PISTOL_UNDER | GUN_MODULE_CLASS_SHOTGUN_UNDER | GUN_MODULE_CLASS_RIFLE_UNDER

/obj/item/gun_module/under/flashlight/Initialize(mapload)
	. = ..()
	internal = new()

/obj/item/gun_module/under/flashlight/attack_self(mob/user)
	. = ..()
	internal.attack_self(user)

/obj/item/gun_module/under/flashlight/on_attach(obj/item/gun/target_gun, mob/user)
	target_gun.set_gun_light(internal)


/obj/item/gun_module/under/flashlight/on_detach(obj/item/gun/target_gun, mob/user)
	target_gun.set_gun_light(null)
	internal.forceMove(src)

