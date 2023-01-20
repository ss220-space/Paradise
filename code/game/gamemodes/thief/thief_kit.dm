// ========== STORAGE BOX WITH CHOOSEN ITEMS ==========
/obj/item/storage/box/thief_kit
	name = "набор гильдии воров"
	desc = "Ничем не примечательная коробка"
	icon_state = "box_thief"
	item_state = "syringe_kit"

/obj/item/storage/box/thief_kit/New(var/list/choosen_kit_list)
	..()
	new /obj/item/clothing/gloves/color/black/thief(src)
	new /obj/item/storage/backpack/satchel_flat(src)
	for(var/obj/item/item in choosen_kit_list)
		new item(src)


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
	/// Choosen items for spawn
	var/list/choosen_kit_list = list()
	/// List of categories with items inside
	//var/list/categories_kits = list()
	/// List of all items in total
	var/list/all_kits

/obj/item/thief_kit/five/possible_uses = 5
/obj/item/thief_kit/ten/possible_uses = 10
/obj/item/thief_kit/twenty/possible_uses = 20
/obj/item/thief_kit/fifty/possible_uses = 50

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

	// Actual items
	//if(!categories_kits || !all_kits)
	//	generate_kit_lists()
	if(!all_kits)
		all_kits = subtypesof(/datum/thief_kit)

	data["kits"] = all_kits

	var/list/test = subtypesof(/datum/thief_kit)
	message_admins(test)

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
			SStgui.close_uis(src)
			openKit(usr)
		if("clear")
			clearKit(usr)
		if("randomKit")
			pickKit(pick(all_kits))
		if("takeKit")
			pickKit(params["item"])
		if("undoKit")
			undoKit(params["item"])



/obj/item/thief_kit/proc/openKit(var/mob/user)
	if(uses >= possible_uses)
		var/obj/item/storage/box/thief_kit/kit = new(src, choosen_kit_list)
		kit.AltClick(user)
		qdel(src)
	else
		to_chat(user,"<span class = 'warning'>Вы не определили все предметы в коробке!</span>")

/obj/item/thief_kit/proc/clearKit(var/mob/user)
	uses = 0
	choosen_kit_list = list()
	to_chat(user,"<span class = 'warning'>Вы очистили выбор! Наверное в коробке лежали другие наборы?</span>")
	message_admins("Очищен [src.name]")

/obj/item/thief_kit/proc/pickKit(var/datum/thief_kit/kit)
	uses++
	choosen_kit_list.Add(kit)

/obj/item/thief_kit/proc/undoKit(var/datum/thief_kit/kit)
	uses--
	choosen_kit_list.Remove(kit)






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
	var/list/kit = list()
	var/was_taken = FALSE

/datum/thief_kit/chamelleon
	name = "Набор Хамелеона"
	desc = "Набор одежды-хамелеона для скрытных внедрений. Нескользящие ботинки в комплект не включены."
	kit = list(
		/obj/item/flag/chameleon,
		/obj/item/storage/box/syndie_kit/chameleon
		///obj/item/card/id/syndicate,
		)

/datum/thief_kit/falsification
	name = "Набор Подделки"
	desc = "Набор для подделывания подписей и печатей. И  облика."
	kit = list(
		/obj/item/stamp/chameleon,
		/obj/item/pen/fakesign
		)

/datum/thief_kit/projector
	name = "Голографический Набор"
	desc = "Набор для скрытия за голограммой."
	kit = list(
		/obj/item/chameleon,
		)

/datum/thief_kit/radio
	name = "Набор Связиста"
	desc = "Набор для подслушивания переговоров."
	kit = list(
		/obj/item/encryptionkey/syndicate
		)
