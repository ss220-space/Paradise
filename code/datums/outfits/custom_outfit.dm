/datum/custom_outfit
	var/mob/target_mob
	var/datum/outfit/drip

/datum/custom_outfit/New(mob/target)
	target_mob = target
	drip = new /datum/outfit
	drip.name = "New Outfit"
	if(ishuman(target_mob))
		var/mob/living/carbon/human/H = target_mob
		if(H.w_uniform) drip.uniform = H.w_uniform.type
		if(H.wear_suit) drip.suit = H.wear_suit.type
		if(H.back) drip.back = H.back.type
		if(H.belt) drip.belt = H.belt.type
		if(H.gloves) drip.gloves = H.gloves.type
		if(H.shoes) drip.shoes = H.shoes.type
		if(H.head) drip.head = H.head.type
		if(H.wear_mask) drip.mask = H.wear_mask.type
		if(H.neck) drip.neck = H.neck.type
		if(H.l_ear) drip.l_ear = H.l_ear.type
		if(H.r_ear) drip.r_ear = H.r_ear.type
		if(H.glasses) drip.glasses = H.glasses.type
		if(H.wear_id) drip.id = H.wear_id.type
		if(H.wear_pda) drip.pda = H.wear_pda.type
		if(H.l_store) drip.l_pocket = H.l_store.type
		if(H.r_store) drip.r_pocket = H.r_store.type
		if(H.s_store) drip.suit_store = H.s_store.type
		if(H.l_hand) drip.l_hand = H.l_hand.type
		if(H.r_hand) drip.r_hand = H.r_hand.type

		if(isstorage(H.back))
			for(var/obj/item/I in H.back.contents)
				drip.backpack_contents[I.type] = (drip.backpack_contents[I.type] || 0) + 1

/datum/custom_outfit/ui_state(mob/user)
	return ADMIN_STATE(R_EVENT)

/datum/custom_outfit/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "CustomOutfit")
		ui.set_autoupdate(FALSE)
		ui.open()

/datum/custom_outfit/ui_data(mob/user)
	var/list/data = list()
	data["outfit"] = serialize_outfit()
	data["backpack_items"] = serialize_backpack()
	return data

/datum/custom_outfit/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	if(..())
		return
	. = TRUE

	switch(action)
		if("load")
			world.log << "Загрузка json"
		if("copy")
			world.log << "Копирование из select equip"
		if("save")
			world.log << "Сохранение в json"
		if("apply")
			apply_outfit()
		if("add_implant")
			world.log << "Добавление импланта"
		if("add_backpack_item")
			choose_backpack_item()
		if("remove_item")
			var/path = text2path(params["ref"])
			if(path && drip.backpack_contents[path])
				drip.backpack_contents[path]--
				if(drip.backpack_contents[path] <= 0)
					drip.backpack_contents -= path
		if("click")
			choose_item(params["slot"])
		if("clear")
			var/slot = params["slot"]
			if(drip.vars.Find(slot))
				drip.vars[slot] = null

/datum/custom_outfit/proc/entry(data)
	if(ispath(data, /obj/item))
		var/obj/item/item = data
		return list(
			"path" = "[item]",
			"name" = initial(item.name),
			"desc" = initial(item.desc),
			"icon" = initial(item.icon),
			"icon_state" = initial(item.icon_state),
		)
	return data

/datum/custom_outfit/proc/serialize_outfit()
	var/list/outfit_slots = drip.get_json_data()
	. = list()
	for(var/key in outfit_slots)
		var/val = outfit_slots[key]
		var/slot_key = key
		if(slot_key == "l_ear")
			slot_key = "ears"
		. += list("[slot_key]" = entry(val))

/datum/custom_outfit/proc/serialize_backpack()
	. = list()
	for(var/path in drip.backpack_contents)
		var/count = drip.backpack_contents[path]
		for(var/i in 1 to count)
			. += list(entry(path))

/datum/custom_outfit/proc/choose_backpack_item()
	var/obj/item/choice = pick_closest_path(FALSE)
	if(!choice)
		return
	if(drip.backpack_contents[choice])
		drip.backpack_contents[choice]++
	else
		drip.backpack_contents[choice] = 1

/datum/custom_outfit/proc/apply_outfit()
	if(!ishuman(target_mob))
		return
	var/mob/living/carbon/human/H = target_mob
	for(var/obj/item/I in H.get_all_slots())
		qdel(I)
	H.equipOutfit(drip)
	H.regenerate_icons()
	log_and_message_admins("changed the equipment of [key_name_admin(H)] via Custom Outfit.")

/datum/custom_outfit/proc/set_item(slot, obj/item/choice)
	if(!choice)
		return
	if(!ispath(choice))
		tgui_alert(usr, "Invalid item", "Custom Outfit", list("oh no"))
		return
	if(initial(choice.icon_state) == null)
		var/msg = "Warning: This item's icon_state is null, indicating it is very probably not actually a usable item."
		if(tgui_alert(usr, msg, "Custom Outfit", list("Use it anyway", "Cancel")) != "Use it anyway")
			return
	if(drip.vars.Find(slot))
		drip.vars[slot] = choice

/datum/custom_outfit/proc/choose_any_item(slot)
	var/obj/item/choice = pick_closest_path(FALSE)
	if(!choice)
		return
	set_item(slot, choice)

/datum/custom_outfit/proc/choose_item(slot)
	var/list/options = list()

	switch(slot)
		if("head")
			options = typesof(/obj/item/clothing/head)
		if("glasses")
			options = typesof(/obj/item/clothing/glasses)
		if("l_ear")
			options = typesof(/obj/item/radio/headset)
		if("neck")
			options = typesof(/obj/item/clothing/neck)
		if("mask")
			options = typesof(/obj/item/clothing/mask)
		if("uniform")
			options = typesof(/obj/item/clothing/under)
		if("suit")
			options = typesof(/obj/item/clothing/suit)
		if("gloves")
			options = typesof(/obj/item/clothing/gloves)
		if("suit_store")
			choose_any_item(slot)
			return
		if("belt")
			options = typesof(/obj/item/storage/belt)
		if("id")
			options = typesof(/obj/item/card/id)
		if("l_hand")
			choose_any_item(slot)
			return
		if("back")
			options = typesof(/obj/item/storage/backpack)
		if("r_hand")
			choose_any_item(slot)
			return
		if("l_pocket")
			choose_any_item(slot)
			return
		if("shoes")
			options = typesof(/obj/item/clothing/shoes)
		if("r_pocket")
			choose_any_item(slot)
			return

	if(!length(options))
		return
	var/option = tgui_input_list(usr, "Choose an item", "Custom Outfit", options)
	if(isnull(option))
		return
	set_item(slot, option)
