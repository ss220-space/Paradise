/**
 * Gun modification UI
 * Opening tgui window from gun examine.
 * Gun modification window
 */

#define GUN_MODIFICATION_ICON_SIZE_X 64
#define GUN_MODIFICATION_ICON_SIZE_Y 64
#define GUN_MODIFICATION_GUN_ORIGIN_X 16
#define GUN_MODIFICATION_GUN_ORIGIN_Y 16

/// Module class to -> attachment slot bitflags
GLOBAL_LIST_INIT(gun_module_slot_flags, list(
	ATTACHMENT_SLOT_MUZZLE = GUN_MODULE_CLASS_ANY_MUZZLE,
	ATTACHMENT_SLOT_RAIL = GUN_MODULE_CLASS_PISTOL_RAIL | GUN_MODULE_CLASS_SHOTGUN_RAIL | GUN_MODULE_CLASS_RIFLE_RAIL | GUN_MODULE_CLASS_SNIPER_RAIL,
	ATTACHMENT_SLOT_UNDER = GUN_MODULE_CLASS_PISTOL_UNDER | GUN_MODULE_CLASS_SHOTGUN_UNDER | GUN_MODULE_CLASS_RIFLE_UNDER | GUN_MODULE_CLASS_SNIPER_UNDER,
	ATTACHMENT_SLOT_STOCK = GUN_MODULE_CLASS_SMG_STOCK,
	ATTACHMENT_SLOT_LOCKING_PIN = GUN_MODULE_CLASS_LOCKING_PIN | GUN_MODULE_CLASS_ENERGY_WEAPON,
))

/// Default offsets for attachments (prevent runtimes)
GLOBAL_LIST_INIT(gun_module_default_offsets, list(
	ATTACHMENT_SLOT_MUZZLE = list(ATTACHMENT_OFFSET_X = 21, ATTACHMENT_OFFSET_Y = 12),
	ATTACHMENT_SLOT_RAIL = list(ATTACHMENT_OFFSET_X = 10, ATTACHMENT_OFFSET_Y = 22),
	ATTACHMENT_SLOT_UNDER = list(ATTACHMENT_OFFSET_X = 10, ATTACHMENT_OFFSET_Y = 6),
	ATTACHMENT_SLOT_STOCK = list(ATTACHMENT_OFFSET_X = 2, ATTACHMENT_OFFSET_Y = 12),
	ATTACHMENT_SLOT_LOCKING_PIN = list(ATTACHMENT_OFFSET_X = 10, ATTACHMENT_OFFSET_Y = 4),
))

/obj/item/gun/proc/invalidate_gun_modification_asset()
	gun_modification_asset = null

/obj/item/gun/proc/get_gun_modification_asset()
	if(gun_modification_asset)
		return gun_modification_asset

	var/datum/universal_icon/gun_icon = build_gun_modification_icon(src)
	if(!gun_icon)
		return null

	var/icon/gun_file = get_icon_from_uni_icon(gun_icon, UID())
	var/asset_name = "[GENERATE_ASSET_NAME(gun_file)].png"
	gun_modification_asset = new /datum/asset/simple/gun_modification(gun_file, asset_name)
	return gun_modification_asset

/obj/item/gun/proc/build_gun_modification_icon(obj/item/gun/gun)
	var/datum/universal_icon/canvas = uni_icon('icons/blanks/96x96.dmi', "nothing")
	canvas.crop(1, 1, GUN_MODIFICATION_ICON_SIZE_X, GUN_MODIFICATION_ICON_SIZE_Y)

	var/datum/universal_icon/flat_gun = get_flat_uni_icon(gun, SOUTH)
	var/origin_x = round((GUN_MODIFICATION_ICON_SIZE_X - ICON_SIZE_X) / 2)
	var/origin_y = round((GUN_MODIFICATION_ICON_SIZE_Y - ICON_SIZE_Y) / 2)
	canvas.blend_icon(flat_gun, ICON_OVERLAY, origin_x + 1, origin_y + 1)
	return canvas

/obj/item/gun/ui_state(mob/user)
	return GLOB.deep_inventory_state

/obj/item/gun/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "GunModification", "Модификация оружия")
		ui.open()

/obj/item/gun/ui_assets(mob/user)
	var/datum/asset/simple/gun_modification/asset = get_gun_modification_asset()
	if(asset)
		return list(asset)
	return list()

/obj/item/gun/ui_data(mob/user)
	var/list/data = list()
	data["hasGun"] = TRUE
	data["gunIcon"] = null
	data["imageWidth"] = GUN_MODIFICATION_ICON_SIZE_X
	data["imageHeight"] = GUN_MODIFICATION_ICON_SIZE_Y
	data["gunOriginX"] = round((GUN_MODIFICATION_ICON_SIZE_X - get_cached_width()) / 2)
	data["gunOriginY"] = round((GUN_MODIFICATION_ICON_SIZE_Y - get_cached_height()) / 2)
	data["gunName"] = DECLENT_RU_CAP(src, NOMINATIVE)
	data["slots"] = get_slots_ui_data(src)
	data["stats"] = get_gun_stats_ui_data(src)
	data["availableModules"] = isliving(user) ? get_available_modules_ui_data(src, user) : list()

	var/datum/asset/simple/gun_modification/asset = get_gun_modification_asset()
	if(asset)
		data["gunIcon"] = SSassets.transport.get_asset_url(asset.asset_name)
		var/datum/tgui/ui = SStgui.get_open_ui(user, src)
		if(ui && ui.window && ui.window.sent_assets && !(asset in ui.window.sent_assets))
			ui.send_asset(asset)

	return data

/obj/item/gun/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	. = ..()
	if(.)
		return

	if(!isliving(ui.user))
		return TRUE

	var/mob/living/user = ui.user

	switch(action)
		if("install_module")
			var/slot = params["slot"]
			if(!slot)
				return TRUE

			var/obj/item/gun_module/module = locateUID(params["module"])
			if(!istype(module) || QDELETED(module) || module.gun || module.slot != slot)
				return TRUE

			if(!(module in user.get_all_contents()))
				return TRUE

			if(!(attachable_allowed & module.class))
				return TRUE

			if(attachments_by_slot[slot])
				return TRUE

			module.try_attach(src, user, instant = TRUE)
			return TRUE

		if("detach_module")
			var/slot = params["slot"]
			var/obj/item/gun_module/module = attachments_by_slot[slot]
			if(!istype(module) || QDELETED(module))
				return TRUE

			if(!module.can_detach)
				user.balloon_alert(user, "модуль нельзя снять")
				return TRUE

			if(module.detach_without_check(src, user, put_in_hands = FALSE, instant = TRUE) && !QDELETED(module))
				store_detached_module(module, user)

			return TRUE

	return TRUE

/obj/item/gun/proc/get_slots_ui_data(obj/item/gun/gun)
	var/list/slots = list()

	for(var/slot, slot_flags in GLOB.gun_module_slot_flags)
		var/obj/item/gun_module/module = gun.attachments_by_slot[slot]
		if(QDELETED(module))
			module = null
		if(!module && !(gun.attachable_allowed & slot_flags))
			continue
		if(!module && slot == ATTACHMENT_SLOT_LOCKING_PIN && isenergygun(gun) && !(gun.attachable_allowed & GUN_MODULE_CLASS_LOCKING_PIN))
			var/obj/item/gun/energy/energy_gun = gun
			if(!energy_gun.can_add_sibyl_system)
				continue

		var/list/offset = get_slot_ui_offset(gun, slot)
		var/list/module_data = null
		if(module)
			module_data = list(
				"ref" = module.UID(),
				"name" = DECLENT_RU_CAP(module, NOMINATIVE),
				"desc" = module.desc,
				"icon" = module.icon,
				"icon_state" = module.icon_state,
				"can_detach" = module.can_detach,
			)

		slots += list(list(
			"slot" = slot,
			"name" = GLOB.gun_module_slot_ru_name[slot] || slot,
			"class_name" = get_slot_class_name(gun, slot_flags),
			"x" = offset[ATTACHMENT_OFFSET_X] + ICON_SIZE_X / 2,
			"y" = offset[ATTACHMENT_OFFSET_Y] + ICON_SIZE_Y / 2,
			"installed" = module_data,
		))

	return slots

/obj/item/gun/proc/get_slot_class_name(obj/item/gun/gun, slot_flags)
	var/flags = slot_flags & gun.attachable_allowed
	if(!flags)
		return "нет"

	if((flags & GUN_MODULE_CLASS_ANY_MUZZLE) == GUN_MODULE_CLASS_ANY_MUZZLE)
		return "любой дульный модуль"

	var/alist/class_names = get_module_class_ru_names_list()
	var/list/names = list()
	for(var/flag, class_name in class_names)
		if(flags & flag)
			names += class_name

	return length(names) ? names.Join(", ") : "нет"

/obj/item/gun/proc/get_gun_stats_ui_data(obj/item/gun/gun)
	var/list/stats = list()
	var/datum/gun_accuracy/accuracy = gun.accuracy
	if(accuracy)
		stats["min_spread"] = accuracy.min_spread
		stats["max_spread"] = accuracy.max_spread
		stats["base_min_spread"] = initial(accuracy.min_spread)
		stats["base_max_spread"] = initial(accuracy.max_spread)
		stats["head"] = accuracy.head
		stats["base_head"] = initial(accuracy.head)
		stats["chest"] = accuracy.chest
		stats["base_chest"] = initial(accuracy.chest)
		stats["arms"] = accuracy.arms
		stats["base_arms"] = initial(accuracy.arms)
		stats["legs"] = accuracy.legs
		stats["base_legs"] = initial(accuracy.legs)
		stats["hands"] = accuracy.hands
		stats["base_hands"] = initial(accuracy.hands)
		stats["feet"] = accuracy.foots
		stats["base_feet"] = initial(accuracy.foots)
		stats["other"] = accuracy.other
		stats["base_other"] = initial(accuracy.other)
	else
		stats["min_spread"] = 0
		stats["max_spread"] = 0
		stats["base_min_spread"] = 0
		stats["base_max_spread"] = 0
		stats["head"] = 0
		stats["base_head"] = 0
		stats["chest"] = 0
		stats["base_chest"] = 0
		stats["arms"] = 0
		stats["base_arms"] = 0
		stats["legs"] = 0
		stats["base_legs"] = 0
		stats["hands"] = 0
		stats["base_hands"] = 0
		stats["feet"] = 0
		stats["base_feet"] = 0
		stats["other"] = 0
		stats["base_other"] = 0

	stats["caliber"] = get_gun_caliber(gun)
	stats["firemodes"] = get_gun_firemodes_ui_data(gun)
	stats["damage_mod"] = gun.damage_mod
	stats["stamina_mod"] = gun.stamina_mod
	stats["recoil"] = gun.recoil ? gun.recoil.strength : null
	stats["base_recoil"] = gun.recoil ? initial(gun.recoil.strength) : null
	stats["rpm"] = gun.fire_delay > 0 ? round(600 / gun.fire_delay) : null
	return stats

/obj/item/gun/proc/get_gun_caliber(obj/item/gun/gun)
	if(gun.chambered)
		return gun.chambered.caliber

	if(is_projectilegun(gun))
		var/obj/item/gun/projectile/projectile_gun = gun
		if(projectile_gun.magazine)
			return projectile_gun.magazine.caliber
		var/mag_type_path = projectile_gun.mag_type
		if(ispath(mag_type_path))
			var/obj/item/ammo_box/magazine/magazine_type = mag_type_path
			return initial(magazine_type.caliber)

	if(isenergygun(gun))
		var/obj/item/gun/energy/energy_gun = gun
		if(length(energy_gun.ammo_type))
			var/select_index = energy_gun.select
			if(!select_index || select_index < 1 || select_index > length(energy_gun.ammo_type))
				select_index = 1
			var/shot_type = energy_gun.ammo_type[select_index]
			if(ispath(shot_type))
				var/obj/item/ammo_casing/energy/shot_type_path = shot_type
				return initial(shot_type_path.caliber)

	return null

/obj/item/gun/proc/get_gun_firemodes_ui_data(obj/item/gun/gun)
	var/list/modes = list()
	for(var/mode in gun.gun_firemode_list)
		switch(mode)
			if(GUN_FIREMODE_SEMIAUTO)
				modes += "полуавтоматический"
			if(GUN_FIREMODE_BURSTFIRE)
				modes += "очередь"
			if(GUN_FIREMODE_AUTOMATIC)
				modes += "автоматический"
			if(GUN_FIREMODE_AUTOBURST)
				modes += "авто-очередь"
	return modes

/obj/item/gun/proc/get_slot_ui_offset(obj/item/gun/gun, slot)
	var/list/offset = gun.attachable_offset ? gun.attachable_offset[slot] : null
	if(offset)
		var/x_offset = offset[ATTACHMENT_OFFSET_X] || 0
		var/y_offset = offset[ATTACHMENT_OFFSET_Y] || 0
		if(x_offset || y_offset)
			return list(ATTACHMENT_OFFSET_X = x_offset, ATTACHMENT_OFFSET_Y = y_offset)

	var/list/default_offset = GLOB.gun_module_default_offsets[slot]
	if(default_offset)
		return default_offset

	return list(ATTACHMENT_OFFSET_X = 0, ATTACHMENT_OFFSET_Y = 0)

/obj/item/gun/proc/get_available_modules_ui_data(obj/item/gun/gun, mob/living/user)
	var/list/modules = list()
	var/list/seen = list()

	for(var/obj/item/gun_module/module in user.get_all_contents())
		if(QDELETED(module) || module.gun || module.loc == gun || (module in seen))
			continue

		if(!module.slot || !(gun.attachable_allowed & module.class))
			continue

		if(gun.attachments_by_slot[module.slot])
			continue

		seen += module
		modules += list(list(
			"ref" = module.UID(),
			"name" = DECLENT_RU_CAP(module, NOMINATIVE),
			"desc" = module.desc,
			"icon" = module.icon,
			"icon_state" = module.icon_state,
			"slot" = module.slot,
		))

	return modules


/obj/item/gun/proc/store_detached_module(obj/item/gun_module/module, mob/living/user)
	for(var/obj/item/storage/storage in user.get_all_contents())
		if(!istype(storage))
			continue
		if(module.loc == storage)
			return TRUE
		if(storage.can_be_inserted(module, TRUE) && storage.handle_item_insertion(module, TRUE))
			to_chat(user, span_notice("Вы убираете [module.declent_ru(ACCUSATIVE)] в [storage.declent_ru(ACCUSATIVE)]."))
			return TRUE

	if(user.put_in_hands(module))
		to_chat(user, span_notice("Вы берёте [module.declent_ru(ACCUSATIVE)] в руку."))
		return TRUE

	module.forceMove(user.drop_location())
	to_chat(user, span_notice("[DECLENT_RU_CAP(module, NOMINATIVE)] падает на пол."))
	return TRUE

#undef GUN_MODIFICATION_ICON_SIZE_X
#undef GUN_MODIFICATION_ICON_SIZE_Y
#undef GUN_MODIFICATION_GUN_ORIGIN_X
#undef GUN_MODIFICATION_GUN_ORIGIN_Y
