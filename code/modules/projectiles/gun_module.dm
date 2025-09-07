/**
 * MARK: Basic module
 */
/obj/item/gun_module
	name = "unknown gun module"
	desc = "Неизвестный модуль для оружия."
	gender = MALE
	icon = 'icons/obj/weapons/attachments.dmi'
	lefthand_file = 'icons/mob/inhands/attachments_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/attachments_righthand.dmi'
	w_class = WEIGHT_CLASS_SMALL
	materials = list(MAT_METAL = 100, MAT_GLASS = 50)
	var/slot
	var/class
	var/overlay_state = "comp"
	var/overlay_offset
	var/buffered_overlay = null
	//attached state variables
	var/obj/item/gun/gun = null

/obj/item/gun_module/Destroy()
	. = ..()
	gun = null
	if(buffered_overlay)
		QDEL_NULL(buffered_overlay)


/// Try attach module to gun, return TRUE if success
/obj/item/gun_module/proc/try_attach(obj/item/gun/target_gun, mob/user)
	if(!istype(target_gun, /obj/item/gun))
		user.balloon_alert(user, "несовместимо с модулями")
		return FALSE
	var/obj/item/gun/gun = target_gun
	var/allowed = gun.attachable_allowed & class
	if(!allowed)
		user.balloon_alert(user, "несовместимое оружие")
		return FALSE
	if(gun.attachments_by_slot[slot] != null)
		user.balloon_alert(user, "слот для модуля занят")
		return FALSE
	return attach_without_check(gun, user)

/// Attaching module to gun without check, use try_attach(/obj/item/gun/target, mob/user) for checks
/obj/item/gun_module/proc/attach_without_check(obj/item/gun/target_gun, mob/user)
	if(!do_after(user, 1 SECONDS, target_gun))
		return FALSE
	target_gun.attachments_by_slot[slot] = src
	target_gun.add_attachment_overlay(src)
	user.drop_transfer_item_to_loc(src, target_gun)
	gun = target_gun
	src.on_attach(target_gun, user)
	user.balloon_alert(user, "модуль установлен")
	return TRUE

/// Detaching module from gun without check, use try_detach(/obj/item/gun/target, mob/user) for checks
/obj/item/gun_module/proc/detach_without_check(obj/item/gun/target_gun, mob/user)
	if(!do_after(user, 1 SECONDS, target_gun))
		return FALSE
	target_gun.attachments_by_slot[slot] = null
	target_gun.remove_attachment_overlay(src)
	src.on_detach(target_gun, user)
	user.put_in_hands(src)
	gun = null
	user.balloon_alert(user, "модуль снят")
	return TRUE

/obj/item/gun_module/proc/create_overlay()
	if(!buffered_overlay)
		buffered_overlay = mutable_appearance(icon, overlay_state, layer = FLOAT_LAYER - 1)
	return buffered_overlay

/obj/item/gun_module/proc/on_attach(obj/item/gun/target_gun, mob/user)
	return

/obj/item/gun_module/proc/on_detach(obj/item/gun/target_gun, mob/user)
	return


/**
 * MARK: Muzzle
 */
/obj/item/gun_module/muzzle
	slot = ATTACHMENT_SLOT_MUZZLE

/obj/item/gun_module/muzzle/suppressor
	name = "suppressor"
	desc = "Глушитель, совместимый с широким диапазоном огнестрельного оружия. Существенно снижает шум, производимый при выстреле и интенсивность вспышки."
	icon_state = "supp"
	item_state = "supp"
	overlay_state = "supp_o"
	overlay_offset = list("x" = -1, "y" = 0)
	class = GUN_MODULE_CLASS_PISTOL_MUZZLE | GUN_MODULE_CLASS_RIFLE_MUZZLE
	var/oldsound
	var/initial_w_class

/obj/item/gun_module/muzzle/suppressor/get_ru_names()
	return list(
		NOMINATIVE = "универсальный глушитель",
		GENITIVE = "универсального глушителя",
		DATIVE = "универсальному глушителю",
		ACCUSATIVE = "универсальный глушитель",
		INSTRUMENTAL = "универсальным глушителем",
		PREPOSITIONAL = "универсальном глушителе"
	)

/obj/item/gun_module/muzzle/suppressor/on_attach(obj/item/gun/target_gun, mob/user)
	target_gun.suppressed = TRUE
	target_gun.suppress_muzzle_flash = TRUE
	oldsound = target_gun.fire_sound
	initial_w_class = target_gun.w_class
	if(target_gun.w_class < WEIGHT_CLASS_NORMAL)
		target_gun.w_class = WEIGHT_CLASS_NORMAL

/obj/item/gun_module/muzzle/suppressor/on_detach(obj/item/gun/target_gun, mob/user)
	target_gun.suppressed = FALSE
	target_gun.suppress_muzzle_flash = FALSE
	target_gun.w_class = initial_w_class

/obj/item/gun_module/muzzle/suppressor/shotgun
	name = "shotgun suppressor"
	desc = "Тяжёлый квадратный глушитель, предназначенный для дробовиков и ружей, позволяет значительно снизить шум от выстрелов и интенсивность вспышки."
	icon_state = "suppshotgun"
	overlay_state = "suppshotgun_o"
	class = GUN_MODULE_CLASS_SHOTGUN_MUZZLE

/obj/item/gun_module/muzzle/suppressor/shotgun/get_ru_names()
	return list(
		NOMINATIVE = "ружейный глушитель",
		GENITIVE = "ружейного глушителя",
		DATIVE = "ружейному глушителю",
		ACCUSATIVE = "ружейный глушитель",
		INSTRUMENTAL = "ружейным глушителем",
		PREPOSITIONAL = "ружейном глушителе"
	)

/obj/item/gun_module/muzzle/suppressor/heavy
	name = "heavy suppressor"
	desc = "Массивный глушитель, предназначенный для крупнокалиберных винтовок, снижает шум выстрелов и интенсивность вспышки."
	icon_state = "suppheavy"
	overlay_state = "suppheavy_o"
	class = GUN_MODULE_CLASS_SNIPER_MUZZLE

/obj/item/gun_module/muzzle/suppressor/heavy/get_ru_names()
	return list(
		NOMINATIVE = "тяжёлый глушитель",
		GENITIVE = "тяжёлого глушителя",
		DATIVE = "тяжёлому глушителю",
		ACCUSATIVE = "тяжёлый глушитель",
		INSTRUMENTAL = "тяжёлым глушителем",
		PREPOSITIONAL = "тёжёлом глушителе"
	)

/obj/item/gun_module/muzzle/compensator
	name = "compensator"
	desc = "Компенсатор, совместимый с широким диапазоном огнестрельного оружия. Уменьшает дульную вспышку и отдачу, производимую при выстреле, тем самым немного повышая точность стрельбы."
	icon_state = "comp"
	item_state = "comp"
	overlay_state = "comp_o"
	overlay_offset = list("x" = -3, "y" = 0)
	class = GUN_MODULE_CLASS_PISTOL_MUZZLE | GUN_MODULE_CLASS_RIFLE_MUZZLE
	var/bonus_accuracy = 10
	var/initial_w_class
	var/spread_decrease = 0
	var/initial_recoil

/obj/item/gun_module/muzzle/compensator/get_ru_names()
	return list(
		NOMINATIVE = "универсальный компенсатор",
		GENITIVE = "универсального компенсатора",
		DATIVE = "универсальному компенсатору",
		ACCUSATIVE = "универсальный компенсатор",
		INSTRUMENTAL = "универсальным компенсатором",
		PREPOSITIONAL = "универсальном компенсаторе"
	)

/obj/item/gun_module/muzzle/compensator/on_attach(obj/item/gun/target_gun, mob/user)
	target_gun.suppress_muzzle_flash = TRUE
	initial_w_class = target_gun.w_class
	if(target_gun.w_class < WEIGHT_CLASS_NORMAL)
		target_gun.w_class = WEIGHT_CLASS_NORMAL
	target_gun.accuracy.add_accuracy(bonus_accuracy)
	if(!target_gun.accuracy.max_spread)
		return
	spread_decrease = initial(target_gun.accuracy.max_spread) * 0.15
	target_gun.accuracy.max_spread = target_gun.accuracy.max_spread - spread_decrease
	initial_recoil = target_gun.recoil.strength
	target_gun.recoil.strength = target_gun.recoil.strength * 0.2

/obj/item/gun_module/muzzle/compensator/on_detach(obj/item/gun/target_gun, mob/user)
	target_gun.suppress_muzzle_flash = FALSE
	target_gun.w_class = initial_w_class
	target_gun.accuracy.add_accuracy(-bonus_accuracy)
	target_gun.accuracy.max_spread += spread_decrease
	spread_decrease = 0
	target_gun.recoil.strength = initial_recoil
	initial_recoil = 0


/**
 * MARK: Rail
 */

/obj/item/gun_module/rail
	slot = ATTACHMENT_SLOT_RAIL

/obj/item/gun_module/rail/scope
	/// 'zoom' distance
	var/zoom_amount = 1
	var/spread_decrease_mod = 0.50
	var/movespeed_slowdown = 1.5
	/// bonus accuracy for gun
	var/bonus_accuracy = 0
	var/old_zoom_amount
	var/spread_decrease
	var/movespeed_mod

/obj/item/gun_module/rail/scope/on_attach(obj/item/gun/target_gun, mob/user)
	target_gun.zoomable = TRUE
	old_zoom_amount = target_gun.zoom_amt
	target_gun.zoom_amt = zoom_amount
	target_gun.build_zooming()
	if(user.is_in_hands(target_gun))
		target_gun.ZoomGrantCheck(null, user, ITEM_SLOT_HANDS)
	RegisterSignal(target_gun, COMSIG_GUN_ZOOM_TOGGLE, PROC_REF(zoom_toogle))

/obj/item/gun_module/rail/scope/on_detach(obj/item/gun/target_gun, mob/user)
	target_gun.zoomable = FALSE
	target_gun.zoom_amt = old_zoom_amount
	target_gun.destroy_zooming()
	UnregisterSignal(target_gun, COMSIG_GUN_ZOOM_TOGGLE)

/obj/item/gun_module/rail/scope/proc/zoom_toogle(datum/source, mob/user)
	if(gun.zoomed)
		on_enter_sight_mode(user)
	else
		on_leave_sight(user)

/obj/item/gun_module/rail/scope/proc/on_enter_sight_mode(mob/user)
	gun.accuracy.add_accuracy(bonus_accuracy)
	spread_decrease = initial(gun.accuracy.max_spread) * spread_decrease_mod
	gun.accuracy.max_spread = max(gun.accuracy.max_spread - spread_decrease, 0)
	var/mob/living/carbon/human/human = user
	if(istype(human))
		movespeed_mod = new /datum/movespeed_modifier/sight_mode(slowdown = movespeed_slowdown)
		human.add_movespeed_modifier(movespeed_mod)

/obj/item/gun_module/rail/scope/proc/on_leave_sight(mob/user)
	gun.accuracy.add_accuracy(-bonus_accuracy)
	gun.accuracy.max_spread += spread_decrease
	spread_decrease = 0
	var/mob/living/carbon/human/human = user
	if(istype(human) && movespeed_mod)
		human.remove_movespeed_modifier(movespeed_mod)
		movespeed_mod = null


/obj/item/gun_module/rail/scope/collimator
	name = "collimator scope"
	desc = "Коллиматорный прицел, предназначенный для установки на прицельную планку стрелкового оружия. Несовместим с пистолетами. Повышает удобство и точность стрельбы."
	icon_state = "coll"
	item_state = "coll"
	overlay_state = "coll_o"
	overlay_offset = list("x" = -5, "y" = 0)
	class = GUN_MODULE_CLASS_SHOTGUN_RAIL | GUN_MODULE_CLASS_RIFLE_RAIL | GUN_MODULE_CLASS_SNIPER_RAIL
	zoom_amount = 3
	bonus_accuracy = 10
	spread_decrease_mod = 0.30
	movespeed_slowdown = 1.3

/obj/item/gun_module/rail/scope/collimator/get_ru_names()
	return list(
		NOMINATIVE = "коллиматорный прицел",
		GENITIVE = "коллиматорного прицела",
		DATIVE = "коллиматорному прицелу",
		ACCUSATIVE = "коллиматорный прицел",
		INSTRUMENTAL = "коллиматорным прицелом",
		PREPOSITIONAL = "коллиматорном прицеле"
	)

/obj/item/gun_module/rail/scope/collimator/pistol
	name = "pistol collimator scope"
	desc = "Коллиматорный прицел, предназначенный для установки на прицельную планку пистолета. Повышает удобство и точность стрельбы."
	icon_state = "coll_p"
	item_state = "coll_p"
	overlay_state = "coll_p_o"
	class = GUN_MODULE_CLASS_PISTOL_RAIL

/obj/item/gun_module/rail/scope/collimator/pistol/get_ru_names()
	return list(
		NOMINATIVE = "пистолетный коллиматорный прицел",
		GENITIVE = "пистолетного коллиматорного прицела",
		DATIVE = "пистолетному коллиматорному прицелу",
		ACCUSATIVE = "пистолетный коллиматорный прицел",
		INSTRUMENTAL = "пистолетным коллиматорным прицелом",
		PREPOSITIONAL = "пистолетном коллиматорном прицеле"
	)

/obj/item/gun_module/rail/scope/x4
	name = "optical scope x4"
	desc = "Оптический прицел с 4-кратным увеличением, предназначенный для установки на прицельную планку стрелкового оружия. Повышает точность при стрельбе на дальние дистанции."
	icon_state = "x4"
	item_state = "x4"
	overlay_state = "x4_o"
	overlay_offset = list("x" = -5, "y" = 0)
	class = GUN_MODULE_CLASS_SHOTGUN_RAIL | GUN_MODULE_CLASS_RIFLE_RAIL | GUN_MODULE_CLASS_SNIPER_RAIL
	zoom_amount = 5
	bonus_accuracy = 10
	spread_decrease_mod = 0.40
	movespeed_slowdown = 1.6

/obj/item/gun_module/rail/scope/x4/get_ru_names()
	return list(
		NOMINATIVE = "оптический прицел х4",
		GENITIVE = "оптического прицела х4",
		DATIVE = "оптическому прицелу х4",
		ACCUSATIVE = "оптический прицел х4",
		INSTRUMENTAL = "оптическим прицелом х4",
		PREPOSITIONAL = "оптическом прицеле х4"
	)

/obj/item/gun_module/rail/scope/x8
	name = "optical scope x8"
	desc = "Оптический прицел с 8-кратным увеличением, предназначенный для установки на прицельную планку стрелкового оружия. Повышает точность при стрельбе на дальние дистанции."
	icon_state = "x8"
	item_state = "x8"
	overlay_state = "x8_o"
	overlay_offset = list("x" = -5, "y" = 0)
	class = GUN_MODULE_CLASS_RIFLE_RAIL | GUN_MODULE_CLASS_SNIPER_RAIL
	zoom_amount = 7
	bonus_accuracy = 30
	spread_decrease_mod = 0.50
	movespeed_slowdown = 2

/obj/item/gun_module/rail/scope/x8/get_ru_names()
	return list(
		NOMINATIVE = "оптический прицел х8",
		GENITIVE = "оптического прицела х8",
		DATIVE = "оптическому прицелу х8",
		ACCUSATIVE = "оптический прицел х8",
		INSTRUMENTAL = "оптическим прицелом х8",
		PREPOSITIONAL = "оптическом прицеле х8"
	)

/obj/item/gun_module/rail/scope/x16
	name = "optical scope x16"
	desc = "Оптический прицел с 16-кратным увеличением, предназначенный для установки на прицельную планку стрелкового оружия. Повышает точность при стрельбе на дальние дистанции."
	icon_state = "x16"
	item_state = "x16"
	overlay_state = "x16_o"
	overlay_offset = list("x" = -3, "y" = 0)
	class = GUN_MODULE_CLASS_RIFLE_RAIL | GUN_MODULE_CLASS_SNIPER_RAIL
	zoom_amount = 11
	bonus_accuracy = 50
	spread_decrease_mod = 0.75
	movespeed_slowdown = 2.5

/obj/item/gun_module/rail/scope/x16/get_ru_names()
	return list(
		NOMINATIVE = "оптический прицел х16",
		GENITIVE = "оптического прицела х16",
		DATIVE = "оптическому прицелу х16",
		ACCUSATIVE = "оптический прицел х16",
		INSTRUMENTAL = "оптическим прицелом х16",
		PREPOSITIONAL = "оптическом прицеле х16"
	)

/obj/item/gun_module/rail/hud
	var/hud_type
	var/granted = FALSE

/obj/item/gun_module/rail/hud/on_attach(obj/item/gun/target_gun, mob/user)
	RegisterSignal(target_gun, COMSIG_ITEM_EQUIPPED, PROC_REF(equip_gun_check))
	RegisterSignal(target_gun, COMSIG_ITEM_DROPPED, PROC_REF(drop_gun_check))
	if(user.is_in_hands(target_gun))
		equip_gun_check(null, user, ITEM_SLOT_HANDS)

/obj/item/gun_module/rail/hud/on_detach(obj/item/gun/target_gun, mob/user)
	UnregisterSignal(target_gun, COMSIG_ITEM_EQUIPPED)
	UnregisterSignal(target_gun, COMSIG_ITEM_DROPPED)
	remove_hud(user)

/obj/item/gun_module/rail/hud/proc/equip_gun_check(datum/source, mob/user, slot)
	if(!(slot & ITEM_SLOT_HANDS))
		remove_hud(user)
		return
	grant_hud(user)

/obj/item/gun_module/rail/hud/proc/drop_gun_check(datum/source, mob/user)
	remove_hud(user)

/obj/item/gun_module/rail/hud/proc/grant_hud(mob/user)
	if(granted)
		return
	granted = TRUE
	if(islist(hud_type))
		for(var/new_hud in hud_type)
			var/datum/atom_hud/hud = GLOB.huds[new_hud]
			hud.add_hud_to(user)
		return .
	var/datum/atom_hud/hud = GLOB.huds[hud_type]
	hud.add_hud_to(user)

/obj/item/gun_module/rail/hud/proc/remove_hud(mob/user)
	if(!granted)
		return
	granted = FALSE
	if(islist(hud_type))
		for(var/new_hud in hud_type)
			var/datum/atom_hud/hud = GLOB.huds[new_hud]
			hud.remove_hud_from(user)
		return .
	var/datum/atom_hud/hud = GLOB.huds[hud_type]
	hud.remove_hud_from(user)


/obj/item/gun_module/rail/hud/medical
	name = "med hud scope"
	desc = "Коллиматорный прицел с медицинским ИЛС, предназначенный для установки на прицельную планку стрелкового оружия. Несовместим с пистолетами."
	icon_state = "coll_med"
	item_state = "coll_med"
	overlay_state = "coll_med_o"
	overlay_offset = list("x" = -5, "y" = 0)
	hud_type = DATA_HUD_MEDICAL_ADVANCED
	class = GUN_MODULE_CLASS_PISTOL_RAIL | GUN_MODULE_CLASS_SHOTGUN_RAIL | GUN_MODULE_CLASS_RIFLE_RAIL | GUN_MODULE_CLASS_SNIPER_RAIL
	origin_tech = "biotech=2;magnets=3;combat=1;programming=1"

/obj/item/gun_module/rail/hud/medical/get_ru_names()
	return list(
		NOMINATIVE = "коллиматор с медицинским ИЛС",
		GENITIVE = "коллиматора с медицинским ИЛС",
		DATIVE = "коллиматору с медицинским ИЛС",
		ACCUSATIVE = "коллиматорс медицинским ИЛС",
		INSTRUMENTAL = "коллиматором с медицинским ИЛС",
		PREPOSITIONAL = "коллиматоре с медицинским ИЛС"
	)

/obj/item/gun_module/rail/hud/security
	name = "security hud scope"
	desc = "Коллиматорный прицел с охранным ИЛС, предназначенный для установки на прицельную планку стрелкового оружия. Несовместим с пистолетами."
	icon_state = "coll_sec"
	item_state = "coll_sec"
	overlay_state = "coll_sec_o"
	overlay_offset = list("x" = -5, "y" = 0)
	hud_type = DATA_HUD_SECURITY_ADVANCED
	class = GUN_MODULE_CLASS_PISTOL_RAIL | GUN_MODULE_CLASS_SHOTGUN_RAIL | GUN_MODULE_CLASS_RIFLE_RAIL | GUN_MODULE_CLASS_SNIPER_RAIL
	origin_tech = "combat=2;magnets=3;programming=1;materials=1"

/obj/item/gun_module/rail/hud/security/get_ru_names()
	return list(
		NOMINATIVE = "коллиматор с охранным ИЛС",
		GENITIVE = "коллиматора с охранным ИЛС",
		DATIVE = "коллиматору с охранным ИЛС",
		ACCUSATIVE = "коллиматор с охранным ИЛС",
		INSTRUMENTAL = "коллиматором с охранным ИЛС",
		PREPOSITIONAL = "коллиматоре с охранным ИЛС"
	)

/**
 * MARK: Under
 */
/obj/item/gun_module/under
	slot = ATTACHMENT_SLOT_UNDER

/obj/item/gun_module/under/flashlight
	var/obj/item/flashlight/seclite/internal
	var/buffered_overlay_on


/obj/item/gun_module/under/flashlight/Destroy()
	. = ..()
	if(buffered_overlay_on)
		QDEL_NULL(buffered_overlay_on)
	if(QDELETED(internal))
		QDEL_NULL(internal)

/obj/item/gun_module/under/flashlight/Initialize(mapload)
	. = ..()
	internal = new()
	internal.forceMove(src)
	internal.set_light_flags(internal.light_flags | LIGHT_ATTACHED)

/obj/item/gun_module/under/flashlight/attack_self(mob/user)
	. = ..()
	internal.attack_self(user)
	update_icon()

/obj/item/gun_module/under/flashlight/on_attach(obj/item/gun/target_gun, mob/user)
	target_gun.set_gun_light(internal)
	RegisterSignal(target_gun, COMSIG_GUN_LIGHT_TOGGLE, PROC_REF(udate_icon_and_overlay))

/obj/item/gun_module/under/flashlight/on_detach(obj/item/gun/target_gun, mob/user)
	target_gun.set_gun_light(null)
	internal.forceMove(src)
	internal.set_light_flags(internal.light_flags | LIGHT_ATTACHED)
	UnregisterSignal(target_gun, COMSIG_GUN_LIGHT_TOGGLE)

/obj/item/gun_module/under/flashlight/proc/udate_icon_and_overlay()
	SIGNAL_HANDLER
	if(!gun)
		return
	gun.add_attachment_overlay(src)

/obj/item/gun_module/under/flashlight/update_icon_state()
	if(internal.on)
		icon_state = "[initial(icon_state)]_on"
	else
		icon_state = "[initial(icon_state)]"

/obj/item/gun_module/under/flashlight/create_overlay()
	if(!internal.on)
		return ..()
	if(!buffered_overlay_on)
		buffered_overlay_on = mutable_appearance(icon, overlay_state + "_on", layer = FLOAT_LAYER - 1)
	return buffered_overlay_on

/obj/item/gun_module/under/flashlight/pistol
	name = "pistol underbarrel light"
	desc = "Фонарь, предназначенный для установки на цевьё пистолета. Несовместим с другими классами оружия."
	icon_state = "light"
	item_state = "light"
	overlay_state = "light_o"
	class = GUN_MODULE_CLASS_PISTOL_UNDER
	overlay_offset = list("x" = 0, "y" = 0)

/obj/item/gun_module/under/flashlight/pistol/get_ru_names()
	return list(
		NOMINATIVE = "подствольный фонарь для пистолетов",
		GENITIVE = "подствольного фонаря для пистолетов",
		DATIVE = "подствольному фонарю для пистолетов",
		ACCUSATIVE = "подствольный фонарь для пистолетов",
		INSTRUMENTAL = "подствольным фонарём для пистолетов",
		PREPOSITIONAL = "подствольном фонаре для пистолетов"
	)

/obj/item/gun_module/under/flashlight/rifle
	name = "rifle underbarrel light"
	desc = "Фонарь, предназначенный для установки на цевьё. Несовместим с пистолетами."
	icon_state = "light_s"
	item_state = "light_s"
	overlay_state = "light_s_o"
	class = GUN_MODULE_CLASS_SHOTGUN_UNDER | GUN_MODULE_CLASS_RIFLE_UNDER
	overlay_offset = list("x" = 0, "y" = 0)

/obj/item/gun_module/under/flashlight/rifle/get_ru_names()
	return list(
		NOMINATIVE = "подствольный фонарь",
		GENITIVE = "подствольного фонаря",
		DATIVE = "подствольному фонарю",
		ACCUSATIVE = "подствольный фонарь",
		INSTRUMENTAL = "подствольным фонарём",
		PREPOSITIONAL = "подствольном фонаре"
	)

/obj/item/gun_module/under/hand
	class = GUN_MODULE_CLASS_SHOTGUN_UNDER | GUN_MODULE_CLASS_RIFLE_UNDER
	overlay_offset = list("x" = 0, "y" = 0)
	gender = FEMALE
	var/bonus_accuracy = 15
	var/spread_decrease = 0


/obj/item/gun_module/under/hand/on_attach(obj/item/gun/target_gun, mob/user)
	target_gun.accuracy.add_accuracy(bonus_accuracy)
	if(!target_gun.accuracy.max_spread)
		return
	spread_decrease = initial(target_gun.accuracy.max_spread) * 0.30
	target_gun.accuracy.max_spread = target_gun.accuracy.max_spread - spread_decrease

/obj/item/gun_module/under/hand/on_detach(obj/item/gun/target_gun, mob/user)
	target_gun.accuracy.add_accuracy(-bonus_accuracy)
	target_gun.accuracy.max_spread += spread_decrease
	spread_decrease = 0

/obj/item/gun_module/under/hand/angle
	name = "angled handle"
	desc = "Угловая рукоятка, предназначенная для установки на нижнюю планку цевья. Повышает удобство стрельбы."
	icon_state = "hand_a"
	item_state = "hand_a"
	overlay_state = "hand_a_o"

/obj/item/gun_module/under/hand/angle/get_ru_names()
	return list(
		NOMINATIVE = "угловая рукоятка",
		GENITIVE = "угловую рукоятку",
		DATIVE = "угловой рукоятке",
		ACCUSATIVE = "угловая рукоятка",
		INSTRUMENTAL = "угловой рукояткой",
		PREPOSITIONAL = "угловой рукоятке"
	)

/obj/item/gun_module/under/hand/foregrip
	name = "foregrip"
	desc = "Классическая прямая рукоятка, предназначенная для установки на нижнюю планку цевья. Повышает удобство стрельбы."
	icon_state = "foregrip"
	item_state = "foregrip"
	overlay_state = "foregrip_o"

/obj/item/gun_module/under/hand/foregrip/get_ru_names()
	return list(
		NOMINATIVE = "прямая рукоятка",
		GENITIVE = "прямую рукоятку",
		DATIVE = "прямую рукоятке",
		ACCUSATIVE = "прямая рукоятка",
		INSTRUMENTAL = "прямой рукояткой",
		PREPOSITIONAL = "прямой рукоятке"
	)
