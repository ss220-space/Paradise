// ========== STORAGE BOX WITH CHOOSEN ITEMS ==========
/obj/item/storage/box/thief_kit
	name = "набор гильдии воров"
	desc = "Ничем не примечательная коробка"
	icon_state = "box_thief"
	item_state = "syringe_kit"

/obj/item/storage/box/thief_kit/New()
	..()
	new /obj/item/clothing/gloves/color/black/thief(src)
	new /obj/item/storage/backpack/satchel_flat(src)

// ========== CHOOSE ITEMS ==========
/obj/item/thief_kit
	name = "набор гильдии воров"
	desc = "Ничем не примечательная увесистая коробка. Тяжелая. Набор вора-шредингера. Неизвестно что внутри, пока не заглянешь и не определишься."
	icon = 'icons/obj/storage.dmi'
	icon_state = "box_thief"
	item_state = "syringe_kit"
	w_class = WEIGHT_CLASS_TINY
	var/possible_uses = 2
	var/uses = 0
	var/multi_uses = FALSE
	var/list/datum/thief_kit/choosen_kit_list = list()
	var/list/datum/thief_kit/all_kits = list()

/obj/item/thief_kit/multi/multi_uses = TRUE
/obj/item/thief_kit/five/possible_uses = 5
/obj/item/thief_kit/five/multi/multi_uses = TRUE
/obj/item/thief_kit/ten/possible_uses = 10
/obj/item/thief_kit/ten/multi/multi_uses = TRUE
/obj/item/thief_kit/twenty
	possible_uses = 20
	multi_uses = TRUE
/obj/item/thief_kit/fifty
	possible_uses = 50
	multi_uses = TRUE

/obj/item/thief_kit/ui_interact(mob/user, ui_key = "main", datum/tgui/ui = null, force_open = FALSE, datum/tgui/master_ui = null, datum/ui_state/state = GLOB.inventory_state)
	ui = SStgui.try_update_ui(user, src, ui_key, ui, force_open)
	if(!ui)
		ui = new(user, src, ui_key, "ThiefKit", name, 600, 600, master_ui, state)
		ui.open()

/obj/item/thief_kit/ui_data(mob/user)
	var/list/data = list()

	data["uses"] = uses
	data["possible_uses"] = possible_uses

	return data

/obj/item/thief_kit/ui_static_data(mob/user)
	var/list/data = list()

	if(!length(all_kits))
		//var/index_count = 0
		for(var/kit_type in subtypesof(/datum/thief_kit))
			var/datum/thief_kit/kit = new kit_type
			message_admins("[kit] [kit.name]")
			all_kits.Add(kit)

	data["kits"] = list()
	for(var/datum/thief_kit/kit in all_kits)
		data["kits"] += list(list(
			"name" = kit.name,
			"desc" = kit.desc,
			"was_taken" = kit.was_taken,
			"type" = kit.type
		))

	data["choosen_kits"] = list()
	for(var/datum/thief_kit/kit in choosen_kit_list)
		data["choosen_kits"] += list(list(
			"name" = kit.name,
			"desc" = kit.desc,
			"was_taken" = kit.was_taken,
			"type" = kit.type
		))

	return data

/obj/item/thief_kit/attack_self(mob/user)
	interact(user)

/obj/item/thief_kit/interact(mob/user)
	if(!ishuman(user))
		to_chat(user, "Вы даже не гуманоид... Вы не понимаете как это открыть")
		return 0

	if(user.stat || user.restrained())
		return 0

	if(loc == user || (in_range(src, user) && isturf(loc)))
		ui_interact(user)

/obj/item/thief_kit/ui_act(action, list/params)
	if(..())
		return

	. = TRUE
	switch(action)
		if("open")
			openKit(usr)
		if("clear")
			clearKit(usr)
		if("randomKit")
			randomKit()
		if("takeKit")
			pickKit(params["item"])
		if("undoKit")
			undoKit(params["item"])

/obj/item/thief_kit/proc/openKit(var/mob/user)
	if(uses >= possible_uses)
		var/obj/item/storage/box/thief_kit/kit = new(src)

		for(var/datum/thief_kit/kit_type in choosen_kit_list)
			for(var/item_type in kit_type.item_list)
				kit.contents.Add(new item_type(src))

		user.put_in_hands(kit)
		kit.AltClick(user)
		SStgui.close_uis(src)
		qdel(src)
	else
		to_chat(user,"<span class = 'warning'>Вы не определили все предметы в коробке!</span>")

/obj/item/thief_kit/proc/clearKit(var/mob/user)
	for(var/datum/thief_kit/kit in choosen_kit_list)
		undoKit(kit)
	uses = 0
	to_chat(user,"<span class = 'warning'>Вы очистили выбор! Наверное в коробке лежали другие наборы?</span>")
	message_admins("Очищен [src.name]")

/obj/item/thief_kit/proc/pickKit(var/kit_type)
	var/datum/thief_kit/kit = convert_kit_type(kit_type)
	if(kit)
		SStgui.update_uis(src)
		choosen_kit_list.Add(kit)
		if(!multi_uses)
			kit.was_taken = TRUE
		uses++

/obj/item/thief_kit/proc/undoKit(var/kit_type)
	var/datum/thief_kit/kit = convert_kit_type(kit_type)
	if(kit)
		SStgui.update_uis(src)
		choosen_kit_list.Remove(kit)
		kit.was_taken = FALSE
		uses--

/obj/item/thief_kit/proc/randomKit(var/kit_type)
	var/list/possible_kits = list()
	for(var/datum/thief_kit/kit in all_kits)
		if(kit.was_taken)
			continue
		possible_kits.Add(kit)
	if(possible_kits)
		pickKit(pick(possible_kits))
	else
		to_chat(usr,"<span class = 'warning'>Превышен допустимый лимит наборов!</span>")

/obj/item/thief_kit/proc/convert_kit_type(var/kit_type)
	message_admins("Прибыл кит [kit_type]")
	message_admins("Прибыл кит [kit_type]")
	if(istype(kit_type, /datum/thief_kit))
		return kit_type
	for(var/datum/thief_kit/kit in all_kits)
		if("[kit.type]" == kit_type)
			return kit
	return FALSE





/*
/obj/item/thief_kit/proc/generate_kit_lists()
	var/list/cats = list()

	for(var/category in uplink_items)
		cats[++cats.len] = list("cat" = category, "items" = list())
		for(var/datum/uplink_item/I in uplink_items[category])
			if(I.job && I.job.len)
				if(!(I.job.Find(job)))
					continue
			cats[cats.len]["items"] += list(list("name" = sanitize(I.name), "desc" = sanitize(I.description()),"cost" = I.cost, "hijack_only" = I.hijack_only, "obj_path" = I.reference, "refundable" = I.refundable))
			uplink_items[I.reference] = I

	uplink_cats = cats
*/














/*
/obj/item/thief_kit/attack_self(mob/user as mob)
	user.set_machine(src)
	var/dat = {"<meta charset="UTF-8">"}

	dat += "<B>Воровской набор-шредингера:</B><BR>"
	dat += "<I>Увесистая коробка, в которой лежит снаряжение гильдии воров.</I><BR>"
	dat += "<I>Нельзя определить что в нём лежит, пока не заглянешь внутрь</I><BR>"

	dat += "<BR><B>Какое снаряжение в нём лежит?:</B><BR>"
	dat += "<I>Определено наборов: [uses]/[possible_uses]</I><BR>"

	var/list/kit_list = subtypesof(/datum/thief_kit)
	for(var/datum/thief_kit/kit in kit_list)
		message_admins("Рассматриваем кит: [kit.name]")
		dat += "<A href='byond://?src=[UID()];kit=[kit]'>[kit.name]</A><BR>"
		dat += "<I>[kit.desc]</I><BR>"

	dat += "Выбрано:<BR>"
	for (var/obj/item/I in choosen_kit_list)
		dat += "<I>[I.name]</I><BR>"

	dat += "<I>В комплект входят воровские перчатки и сумка</I><BR>"
	dat += "<b><font color='green'>ОТКРЫТЬ</font></b>|<a href='?src=[UID()];kit=open'> </a>"
	dat += "<b><font color='red'>СБРОСИТЬ</font></b>|<a href='?src=[UID()];kit=clear'> </a>"

	user << browse(dat, "window=radio")
	onclose(user, "radio")
	return

/obj/item/thief_kit/Topic(href, href_list)
	..()
	if(!ishuman(usr))
		to_chat(usr, "Вы даже не гуманоид... Вы не понимаете как это открыть")
		return 0

	var/mob/living/carbon/human/user = usr

	if(user.stat || user.restrained())
		return 0

	if(loc == user || (in_range(src, user) && isturf(loc)))
		user.set_machine(src)
		//if(!href_list["kit"])
		//	return

		switch(href_list["kit"])
			if("open")
				if(uses >= possible_uses)
					var/obj/item/storage/box/thief_kit = new(src, choosen_kit_list)
					thief_kit.AltClick(user)
					qdel(src)
				else
					to_chat(user,"<span class = 'warning'>Вы не определили все предметы в коробке!</span>")
			if("clear")
				uses = 0
				choosen_kit_list = list()
				to_chat(user,"<span class = 'warning'>Вы очистили выбор! Наверное в коробке лежали другие предметы?</span>")
				message_admins("Очищен [src.name]")

			else if(typesof(/obj/item/thief_kit, href_list["kit"]))
				//for(var/datum/thief_kit/kit in subtypesof(/datum/thief_kit))
				//	if(!typesof(kit, href_list["kit"]))
				//		continue
				var/obj/item/thief_kit/kit = href_list["kit"]
				message_admins("Выбран Кит [kit] [kit.name]")
				choosen_kit_list.Add(kit)
				uses++
	return
*/





//=============== KITS ================
/datum/thief_kit
	var/name = "Безымянный кит (перешлите это разработчику)"
	var/desc = "Описание кита"
	//var/icon/icon = 'icons/obj/storage.dmi'
	//var/icon_state = "box_thief"
	var/list/obj/item/item_list = list()
	var/was_taken = FALSE

/datum/thief_kit/chamelleon
	name = "Набор Хамелеона"
	desc = "Набор одежды-хамелеона для скрытных внедрений. Нескользящие ботинки в комплект не включены."
	item_list = list(
		/obj/item/flag/chameleon,
		/obj/item/storage/box/syndie_kit/chameleon,
		///obj/item/card/id/syndicate,
		)

/datum/thief_kit/falsification
	name = "Набор Подделки"
	desc = "Набор для подделывания подписей и печатей. И  облика."
	item_list = list(
		/obj/item/stamp/chameleon,
		/obj/item/pen/fakesign,
		)

/datum/thief_kit/projector
	name = "Голографический Набор"
	desc = "Набор для скрытия за голограммой."
	item_list = list(
		/obj/item/chameleon,
		)

/datum/thief_kit/radio
	name = "Набор Связиста"
	desc = "Набор для подслушивания переговоров."
	item_list = list(
		/obj/item/encryptionkey/syndicate,
		)
