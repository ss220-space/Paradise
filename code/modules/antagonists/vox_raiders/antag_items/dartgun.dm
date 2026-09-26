/obj/item/gun/syringe/dart_gun
	name = "dart gun"
	desc = "Компактный метатель дротиков для доставки химических коктейлей."
	icon = 'icons/obj/weapons/vox_guns.dmi'
	icon_state = "dartgun"
	item_state = "dartgun"
	max_syringes = 5
	restricted_species = (/datum/species/vox)
	var/cartridge_overlay = "dartgun_cartridge_overlay"
	var/list/valid_cartridge_types = list(
		/obj/item/storage/dart_cartridge,
		/obj/item/storage/dart_cartridge/combat,
		/obj/item/storage/dart_cartridge/drugs,
		/obj/item/storage/dart_cartridge/medical,
		/obj/item/storage/dart_cartridge/pain,
	)
	var/valid_dart_type = /obj/item/reagent_containers/syringe/dart
	var/obj/item/storage/dart_cartridge/cartridge_loaded
	var/pixel_y_overlay_div = 5	// сколько у нас делений для спрайта оверлея ("Позиций")
	var/pixel_y_overlay_offset = 2 // на сколько пикселей смещаем оверлей при полном делении

/obj/item/gun/syringe/dart_gun/Destroy()
	QDEL_NULL(cartridge_loaded)
	return ..()

/obj/item/gun/syringe/dart_gun/update_overlays()
	. = ..()
	if(!cartridge_loaded)
		return
	var/pixel_y_offset = 0
	var/num = length(syringes)
	if(num)
		pixel_y_offset = -(pixel_y_overlay_div - pixel_y_overlay_div * num / max_syringes) * pixel_y_overlay_offset
	. += image(icon = icon, icon_state = cartridge_overlay,  pixel_z = pixel_y_offset)
	if(cartridge_loaded.overlay_state_color)
		. += image(icon = icon, icon_state = "[cartridge_overlay]_[cartridge_loaded.overlay_state_color]",  pixel_z = pixel_y_offset)
	. += icon_state

/obj/item/gun/syringe/dart_gun/item_interaction(mob/living/user, obj/item/tool, list/modifiers)
	if(cartridge_loaded)
		for(var/hold_type in cartridge_loaded.can_hold)
			if(!istype(tool, hold_type))
				continue
			if(insert_syringe_to_cartridge(tool) && user && user.temporarily_remove_item_from_inventory(tool))
				to_chat(user, span_notice("Вы загрузили [tool.declent_ru(ACCUSATIVE)] в [cartridge_loaded.declent_ru(ACCUSATIVE)] внутри [declent_ru(GENITIVE)]!"))
				return ITEM_INTERACT_SUCCESS
		to_chat(user, "Картридж [declent_ru(GENITIVE)] полон!")
		return ITEM_INTERACT_FAILURE

	for(var/cartridge_type in valid_cartridge_types)
		if(istype(tool, cartridge_type))
			if(tool.type != cartridge_type)
				continue
			if(user && !user.temporarily_remove_item_from_inventory(tool))
				return TRUE
			to_chat(user, span_notice("Вы вставили [tool.declent_ru(ACCUSATIVE)] в [declent_ru(ACCUSATIVE)]!"))
			cartridge_load(tool)
			return ITEM_INTERACT_SUCCESS

	if(!chambered.BB && istype(tool, valid_dart_type) && length(syringes) < max_syringes)
		return ..()

	if(user)
		to_chat(user, "[DECLENT_RU_CAP(tool, NOMINATIVE)] не вмещается в [declent_ru(ACCUSATIVE)]!")
	return ITEM_INTERACT_FAILURE

/obj/item/gun/syringe/dart_gun/proc/insert_syringe_to_cartridge(obj/item/syringe)
	if(length(syringes) >= max_syringes)
		return FALSE
	syringe.forceMove(cartridge_loaded)
	syringes.Add(syringe)
	process_chamber()
	return TRUE

/obj/item/gun/syringe/dart_gun/proc/cartridge_load(obj/item/cartridge, mob/user)
	cartridge.forceMove(src)
	cartridge_loaded = cartridge
	for(var/obj/item/syringe in cartridge.contents)
		syringes.Add(syringe)
	process_chamber()

/obj/item/gun/syringe/dart_gun/proc/cartridge_unload(mob/user)
	if(!cartridge_loaded)
		return FALSE
	user.put_in_hands(cartridge_loaded)
	syringes.Cut()
	cartridge_loaded.update_appearance(UPDATE_ICON)
	cartridge_loaded = null
	update_appearance(UPDATE_ICON)

/obj/item/gun/syringe/dart_gun/attack_self(mob/living/user)
	if(cartridge_loaded)
		playsound(src, 'sound/weapons/m79_unload.ogg', 50, 1)
		to_chat(user, span_notice("Вы выгрузили [cartridge_loaded] с [src]."))
		cartridge_unload(user)
		process_chamber()
		return TRUE
	return ..()

/obj/item/gun/syringe/dart_gun/process_chamber()
	. = ..()
	if(!cartridge_loaded)
		update_icon()
		return

	if(!length(syringes))
		var/turf/current_turf = get_turf(src)
		cartridge_loaded.forceMove(current_turf)
		cartridge_loaded.throw_at(target = current_turf, range = 3, speed = 1)
		cartridge_loaded.pixel_x = rand(-10, 10)
		cartridge_loaded.pixel_y = rand(-4, 16)
		cartridge_loaded.update_appearance(UPDATE_ICON)
		cartridge_loaded = null
		update_appearance(UPDATE_ICON)
		playsound(src, 'sound/weapons/m79_break_open.ogg', 50, 1)
		return

	playsound(src, 'sound/weapons/m79_reload.ogg', 50, 1)
	update_appearance(UPDATE_ICON)

/obj/item/gun/syringe/dart_gun/extended
	name = "extended dart gun"
	desc = "Расширенный метатель дротиков и шприцов для доставки химических коктейлей."
	icon_state = "dartgun_ext"
	valid_cartridge_types = list(
		/obj/item/storage/dart_cartridge,
		/obj/item/storage/dart_cartridge/combat,
		/obj/item/storage/dart_cartridge/drugs,
		/obj/item/storage/dart_cartridge/medical,
		/obj/item/storage/dart_cartridge/pain,
		/obj/item/storage/dart_cartridge/extended,
	)

/obj/item/gun/syringe/dart_gun/big
	name = "capacious dart gun"
	desc = "Вместительный метатель дротиков для доставки химических коктейлей."
	icon_state = "dartgun_big"
	max_syringes = 10
	valid_cartridge_types = list(
		/obj/item/storage/dart_cartridge,
		/obj/item/storage/dart_cartridge/combat,
		/obj/item/storage/dart_cartridge/drugs,
		/obj/item/storage/dart_cartridge/medical,
		/obj/item/storage/dart_cartridge/pain,
		/obj/item/storage/dart_cartridge/big,
		/obj/item/storage/dart_cartridge/big/random,
	)
