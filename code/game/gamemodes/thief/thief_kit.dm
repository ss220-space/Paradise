/obj/item/thief_kit
	name = "набор вора"
	desc = "Ничем не примечательная увесистая коробка. Тяжелая. Набор вора-шредингера. Неизвестно что внутри, пока не заглянешь и не определишься."
	icon = 'icons/obj/storage.dmi'
	icon_state = "box_thief"
	item_state = "syringe_kit"
	w_class = WEIGHT_CLASS_TINY
	var/possible_uses = 2
	var/uses = 0
	var/list/choosen_items_list = list()

/obj/item/thief_kit/five/possible_uses = 5
/obj/item/thief_kit/ten
	possible_uses = 10
/obj/item/thief_kit/twenty
	possible_uses = 20

/obj/item/thief_kit/attack_self(mob/user as mob)
	user.set_machine(src)
	var/dat = {"<meta charset="UTF-8">"}

	for (var/datum/thief_kit/kit in subtypesof(/datum/thief_kit))
		dat += "<A href='byond://?src=[UID()];kit=[kit]'>[kit.name]</A><BR>"
		dat += "<I>[kit.desc]</I><BR>"

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
		if(href_list["kit"])
			for (var/datum/thief_kit/kit in subtypesof(/datum/thief_kit))
				if(!typesof(kit, href_list["kit"]))
					continue
				choosen_items_list.Add(kit)
				uses++
				if(uses >= possible_uses)
					var/obj/item/storage/box/thief_kit = new(src, choosen_items_list)
					thief_kit.AltClick(user)
					qdel(src)
	return

/datum/thief_kit
	var/name = "Безымянный кит (перешлите это разработчику)"
	var/desc = "Описание кита"
	var/list/kit = list()

/datum/thief_kit/chamelleon
	name = "Набор Хамелеона"
	desc = "Набор одежды-хамелеона. Нескользящие ботинки в комплект не включены."






/obj/item/storage/box/thief_kit
	name = "набор вора"
	desc = "Ничем не примечательная коробка"
	icon_state = "box_thief"
	item_state = "syringe_kit"


/obj/item/storage/box/thief_kit/New(var/list/choosen_items_list)
	..()
	new /obj/item/clothing/gloves/color/black/thief(src)
	new /obj/item/storage/backpack/satchel_flat(src)
	for(var/item in choosen_items_list)
		new item(src)
