/datum/custom_outfit
	var/mob/target_mob
	var/datum/outfit/drip
	var/list/augmentations = list()
	var/mindshielded = FALSE
	var/list/chem_reagents = list()

/datum/custom_outfit/New(mob/target)
	target_mob = target
	drip = new /datum/outfit
	drip.name = "New Outfit"
	if(ishuman(target_mob))
		var/mob/living/carbon/human/H = target_mob
		var/list/outfit_slot_map = list(
			"uniform" = "w_uniform",
			"suit" = "wear_suit",
			"back" = "back",
			"belt" = "belt",
			"gloves" = "gloves",
			"shoes" = "shoes",
			"head" = "head",
			"mask" = "wear_mask",
			"neck" = "neck",
			"l_ear" = "l_ear",
			"r_ear" = "r_ear",
			"glasses" = "glasses",
			"id" = "wear_id",
			"pda" = "wear_pda",
			"l_pocket" = "l_store",
			"r_pocket" = "r_store",
			"suit_store" = "s_store",
			"l_hand" = "l_hand",
			"r_hand" = "r_hand",
		)
		for(var/outfit_var in outfit_slot_map)
			var/human_var = outfit_slot_map[outfit_var]
			var/obj/item/I = H.vars[human_var]
			if(I)
				drip.vars[outfit_var] = I.type

		if(isstorage(H.back))
			for(var/obj/item/I in H.back.contents)
				drip.backpack_contents[I.type] = (drip.backpack_contents[I.type] || 0) + 1

		mindshielded = ismindshielded(H)
		for(var/obj/item/implant/I in H.contents)
			if(istype(I, /obj/item/implant/mindshield))
				continue
			drip.implants += I.type
		for(var/obj/item/organ/internal/cyberimp/I in H.internal_organs)
			drip.cybernetic_implants += I.type

		for(var/zone in list(BODY_ZONE_HEAD, BODY_ZONE_CHEST, BODY_ZONE_PRECISE_GROIN, BODY_ZONE_L_ARM, BODY_ZONE_R_ARM, BODY_ZONE_L_LEG, BODY_ZONE_R_LEG, BODY_ZONE_PRECISE_L_HAND, BODY_ZONE_PRECISE_R_HAND, BODY_ZONE_PRECISE_L_FOOT, BODY_ZONE_PRECISE_R_FOOT))
			var/obj/item/organ/external/O = H.get_organ(zone)
			if(O && O.is_robotic())
				augmentations[zone] = O.model
		for(var/obj/item/organ/internal/I in H.internal_organs)
			if(istype(I, /obj/item/organ/internal/cyberimp))
				continue
			if(I.is_robotic())
				augmentations[I.type] = ""

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
	data["implants"] = serialize_implants()
	data["augmentations"] = serialize_augmentations()
	data["mindshield"] = mindshielded
	var/list/dental_reagents = list()
	for(var/reagent_type in chem_reagents)
		var/datum/reagent/ref = reagent_type
		dental_reagents += list(list("name" = initial(ref.name), "amount" = chem_reagents[reagent_type]))
	data["dental_reagents"] = dental_reagents
	data["has_dental_implant"] = length(chem_reagents) > 0
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
			choose_implant()
		if("remove_implant")
			var/path = text2path(params["ref"])
			if(path)
				drip.implants -= path
				drip.cybernetic_implants -= path
		if("add_backpack_item")
			choose_backpack_item()
		if("remove_item")
			var/path = text2path(params["ref"])
			if(path && drip.backpack_contents[path])
				drip.backpack_contents[path]--
				if(drip.backpack_contents[path] <= 0)
					drip.backpack_contents -= path
		if("add_augmentation")
			choose_augmentation()
		if("remove_augmentation")
			var/zone = params["zone"]
			var/path_zone = text2path(zone)
			if(path_zone)
				augmentations -= path_zone
			else
				augmentations -= zone
		if("toggle_mindshield")
			mindshielded = !mindshielded
		if("dental_implant")
			if(length(chem_reagents))
				chem_reagents = list()
			else
				build_dental_pill()
		if("click")
			choose_item(params["slot"])
		if("clear")
			var/slot = params["slot"]
			if(drip.vars.Find(slot))
				drip.vars[slot] = null

	SStgui.try_update_ui(usr, src, ui)

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
		. += list("[slot_key]" = entry(val))

/datum/custom_outfit/proc/serialize_backpack()
	. = list()
	for(var/path in drip.backpack_contents)
		var/count = drip.backpack_contents[path]
		for(var/i in 1 to count)
			. += list(entry(path))

/datum/custom_outfit/proc/serialize_implants()
	. = list()
	for(var/path in drip.implants)
		. += list(entry(path))
	for(var/path in drip.cybernetic_implants)
		. += list(entry(path))

/datum/custom_outfit/proc/serialize_augmentations()
	. = list()
	for(var/zone in augmentations)
		var/model = augmentations[zone]
		var/datum/robolimb/R = GLOB.all_robolimbs[model]
		var/company = R ? R.company : "Кибернетическое"
		var/zone_name
		if(ispath(zone))
			var/obj/item/organ/internal/ref = zone
			zone_name = initial(ref.name)
		else
			zone_name = parse_zone(zone)
		. += list(list(
			"zone" = zone,
			"zone_name" = zone_name,
			"model" = model,
			"company" = company,
		))

/datum/custom_outfit/proc/choose_backpack_item()
	var/obj/item/choice = pick_closest_path(FALSE)
	if(!choice)
		return
	if(drip.backpack_contents[choice])
		drip.backpack_contents[choice]++
	else
		drip.backpack_contents[choice] = 1

/datum/custom_outfit/proc/choose_implant()
	var/list/options = typesof(/obj/item/organ/internal/cyberimp)
	if(!length(options))
		return
	var/path = tgui_input_list(usr, "Choose an implant", "Custom Outfit", options)
	if(isnull(path))
		return
	drip.cybernetic_implants += path

/datum/custom_outfit/proc/choose_augmentation()
	var/type_choice = tgui_input_list(usr, "Выберите тип аугментации", "Аугментация", list("Внешняя часть", "Внутренний орган"))
	if(!type_choice)
		return
	if(type_choice == "Внешняя часть")
		var/list/zones = list(BODY_ZONE_HEAD, BODY_ZONE_CHEST, BODY_ZONE_PRECISE_GROIN, BODY_ZONE_L_ARM, BODY_ZONE_R_ARM, BODY_ZONE_L_LEG, BODY_ZONE_R_LEG, BODY_ZONE_PRECISE_L_HAND, BODY_ZONE_PRECISE_R_HAND, BODY_ZONE_PRECISE_L_FOOT, BODY_ZONE_PRECISE_R_FOOT)
		var/zone = tgui_input_list(usr, "Выберите часть тела", "Аугментация", zones)
		if(!zone)
			return
		var/list/companies = list()
		for(var/limb_type in typesof(/datum/robolimb))
			var/datum/robolimb/R = new limb_type()
			if((zone in R.parts) && R.has_subtypes)
				companies[R.company] = R
		if(!length(companies))
			return
		var/company = tgui_input_list(usr, "Выберите фирму-изготовителя", "Аугментация", companies)
		if(!company)
			return
		augmentations[zone] = GLOB.all_robolimbs[company].company
		return

	var/list/organ_options = list(
		"Глаза" = /obj/item/organ/internal/eyes/cybernetic,
		"Уши" = /obj/item/organ/internal/ears/cybernetic,
		"Сердце" = /obj/item/organ/internal/heart/cybernetic,
		"Лёгкие" = /obj/item/organ/internal/lungs/cybernetic,
		"Печень" = /obj/item/organ/internal/liver/cybernetic,
		"Почки" = /obj/item/organ/internal/kidneys/cybernetic,
	)
	var/organ_name = tgui_input_list(usr, "Выберите орган", "Аугментация", organ_options)
	if(!organ_name)
		return
	var/base_path = organ_options[organ_name]
	var/list/cyber_options = list()
	for(var/path in typesof(base_path))
		if(findtext("[path]", "cybernetic"))
			var/obj/item/organ/internal/ref = path
			cyber_options[initial(ref.name)] = path
	if(!length(cyber_options))
		return
	var/cyber_name = tgui_input_list(usr, "Выберите вариант", "Аугментация", cyber_options)
	if(!cyber_name)
		return
	augmentations[cyber_options[cyber_name]] = ""

/datum/custom_outfit/proc/build_dental_pill()
	var/list/reagent_options = list()
	for(var/datum/reagent/reagent_type as anything in subtypesof(/datum/reagent))
		if(!reagent_type::name)
			continue
		reagent_options[reagent_type::name] = reagent_type

	while(TRUE)
		var/choice = tgui_input_list(usr, "Выберите реагент", "Зубной имплант", reagent_options)
		if(!choice)
			break
		var/reagent_type = reagent_options[choice]
		var/amount = tgui_input_number(usr, "Введите количество реагента (макс. 100)", "Количество", 5, 100, 1)
		if(!amount)
			continue
		chem_reagents[reagent_type] = amount
		var/again = tgui_alert(usr, "Добавить ещё реагент?", "Зубной имплант", list("Добавить ещё", "Закончить"))
		if(again != "Добавить ещё")
			break

/datum/custom_outfit/proc/apply_outfit()
	if(!ishuman(target_mob))
		return
	var/mob/living/carbon/human/H = target_mob
	for(var/obj/item/I in H.get_all_slots())
		qdel(I)
	for(var/obj/item/organ/internal/cyberimp/I in H.internal_organs.Copy())
		I.remove(H, ORGAN_MANIPULATION_NOEFFECT)
		qdel(I)
	for(var/obj/item/implant/I in H.contents.Copy())
		I.removed(H)
		qdel(I)
	H.dna.species.create_organs(H)
	for(var/zone in augmentations)
		var/model = augmentations[zone]
		if(ispath(zone))
			if(ispath(zone, /obj/item/organ/internal))
				new zone(H)
			else
				var/obj/item/organ/internal/I = locate(zone) in H.internal_organs.Copy()
				if(I && !I.is_robotic())
					I.robotize()
		else
			var/obj/item/organ/external/O = H.get_organ(zone)
			if(O && !O.is_robotic())
				O.robotize(company = model, convert_all = FALSE)
	H.equipOutfit(drip)

	if(mindshielded)
		if(!ismindshielded(H))
			var/obj/item/implant/mindshield/L = new /obj/item/implant/mindshield(H)
			L.implant(H)
	else
		for(var/obj/item/implant/mindshield/I in H.contents)
			if(I.implanted)
				qdel(I)

	for(var/obj/item/reagent_containers/food/pill/old_pill in H.contents)
		qdel(old_pill)
	if(length(chem_reagents))
		var/obj/item/reagent_containers/food/pill/P = new /obj/item/reagent_containers/food/pill(H)
		for(var/reagent_type in chem_reagents)
			P.reagents.add_reagent(reagent_type, chem_reagents[reagent_type])
		var/datum/action/item_action/hands_free/activate_pill/A = new(P, P.icon, P.icon_state)
		A.name = "Раскусить [P.declent_ru(ACCUSATIVE)]"
		A.Grant(H)

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
