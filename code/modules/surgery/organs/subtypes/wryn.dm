//WRYN ORGAN
/obj/item/organ/internal/wryn/hivenode
	species_type = /datum/species/wryn
	name = "antennae"
	desc = "Орган, отвечающий за телепатическую связь врина с его сородичами."
	ru_names = list(
		NOMINATIVE = "антенна",
		GENITIVE = "антенны",
		DATIVE = "антенне",
		ACCUSATIVE = "антенну",
		INSTRUMENTAL = "антенной",
		PREPOSITIONAL = "антенне"
	)
	icon = 'icons/obj/species_organs/wryn.dmi'
	icon_state = "antennae"
	parent_organ_zone = BODY_ZONE_HEAD
	slot = INTERNAL_ORGAN_HIVENODE
	species_restrictions = list(SPECIES_WRYN)
	/// Stored hair style, defines only on creation and changes original h_style when inserted
	var/hair_style = "Normal antennae"

/obj/item/organ/internal/wryn/hivenode/New(mob/living/carbon/carbon)
	if(istype(carbon))
		var/obj/item/organ/external/head/head_organ = carbon.get_organ(BODY_ZONE_HEAD)
		hair_style = head_organ.h_style

	return ..(carbon)

/obj/item/organ/internal/wryn/hivenode/insert(mob/living/carbon/human/human, special = ORGAN_MANIPULATION_DEFAULT)
	. = ..()
	human.add_language(LANGUAGE_WRYN)
	var/obj/item/organ/external/head/head_organ = human.get_organ(BODY_ZONE_HEAD)

	head_organ.h_style = hair_style
	human.update_hair()

/obj/item/organ/internal/wryn/hivenode/remove(mob/living/carbon/human/human, special = ORGAN_MANIPULATION_DEFAULT)
	human.remove_language(LANGUAGE_WRYN)
	var/obj/item/organ/external/head/head_organ = human.get_organ(BODY_ZONE_HEAD)

	head_organ.h_style = "Bald"
	human.update_hair()

	return ..()

/obj/item/organ/internal/wryn/glands
	species_type = /datum/species/wryn
	name = "wryn wax glands"
	desc = "Парные железы, выделяющие воск, который может использоваться вринами как строительный материал."
	ru_names = list(
		NOMINATIVE = "восковые железы",
		GENITIVE = "восковых желез",
		DATIVE = "восковым железам",
		ACCUSATIVE = "восковые железы",
		INSTRUMENTAL = "восковыми железами",
		PREPOSITIONAL = "восковых железах"
	)
	gender = PLURAL
	icon = 'icons/obj/species_organs/wryn.dmi'
	icon_state = "waxsac"
	item_state = "waxsac"
	parent_organ_zone = BODY_ZONE_PRECISE_MOUTH
	slot = INTERNAL_ORGAN_WAX_GLANDS
	var/datum/action/innate/wryn/build_wax/build_wax = new
	var/datum/action/innate/wryn/toggle_producing/toggle_producing = new
	var/wax = 25
	var/producing = FALSE

/obj/item/organ/internal/wryn/glands/on_life()
	if(!producing)
		return
	if(owner.nutrition > NUTRITION_LEVEL_STARVING && owner.getWax() < 75)
		owner.adjustWax(10)
		owner.set_nutrition(owner.nutrition - 25)
		if(prob(10))
			to_chat(owner, span_notice("Вы чувствуете лёгкое бурление в восковых железах."))

/obj/item/organ/internal/wryn/glands/insert(mob/living/carbon/M, special = ORGAN_MANIPULATION_DEFAULT)
	..()
	build_wax.Grant(M)
	toggle_producing.Grant(M)

/obj/item/organ/internal/wryn/glands/remove(mob/living/carbon/M, special = ORGAN_MANIPULATION_DEFAULT)
	build_wax.Remove(M)
	toggle_producing.Remove(M)
	. = ..()

/datum/action/innate/wryn/build_wax
	name = "Строительство из воска"
	desc = "Выделите воск для строительства"
	button_icon_state = "build"

/datum/action/innate/wryn/build_wax/Activate()
	var/mob/living/carbon/human/wryn/host = owner
	var/static/list/actions = list()

	if(!isnull(actions))
		continue
	for(var/name in GLOB.wryn_structures)
		var/datum/wryn_building/datum = GLOB.wryn_structures[name]
		actions[name] = datum.icon_state
		return actions

	var/choosen_type = show_radial_menu(host, host, actions, radius = 40)
	if(!choosen_type)
		return

/*	var/static/list/new_structure = list("Соты (50)" = image(icon = 'icons/mob/actions/actions.dmi', icon_state = "wax_wall"),
								"Прозрачные соты (50)" = image(icon = 'icons/mob/actions/actions.dmi', icon_state = "wax_window"),
								"Пол из воска (25)" = image(icon = 'icons/mob/actions/actions.dmi', icon_state = "wax_floor"),
								"Дверь из сот (75)" = image(icon = 'icons/mob/actions/actions.dmi', icon_state = "wax_door"))
	var/choosen_type = show_radial_menu(host, host, new_structure, src, radius = 40)
	if(!choosen_type)
		return
	if(locate(/obj/structure/wryn) in get_turf(host))
		host.balloon_alert(host, "место уже занято!")
		return

	switch(choosen_type)
		if("Соты")
			if(host.getWax() < 50)
				host.balloon_alert(host, "недостаточно воска!")
				return
			if(do_after(usr, 5 SECONDS, usr))
				host.adjustWax(-50)
				host.visible_message(("[host] выделя[pluralize_ru(host.gender, "ет", "ют")] кучу воска и формиру[pluralize_ru(host.gender, "ет", "ют")] из неё соты."))
				new /obj/structure/wryn/wax/wall(host.loc)
		if("Прозрачные соты")
			if(host.getWax() < 50)
				host.balloon_alert(host, "недостаточно воска!")
				return
			if(do_after(usr, 5 SECONDS, usr))
				host.adjustWax(-50)
				host.visible_message(("[host] выделя[pluralize_ru(host.gender, "ет", "ют")] кучу воска и формиру[pluralize_ru(host.gender, "ет", "ют")] из неё прозрачные соты."))
				new /obj/structure/wryn/wax/window(host.loc)
		if("Пол из воска")
			if(host.getWax() < 25)
				host.balloon_alert(host, "недостаточно воска!")
				return
			if(do_after(usr, 1 SECONDS, usr))
				host.adjustWax(-25)
				host.visible_message(("[host] выделя[pluralize_ru(host.gender, "ет", "ют")] кучу воска и формиру[pluralize_ru(host.gender, "ет", "ют")] из неё пол из воска."))
				new /obj/structure/wryn/floor(host.loc)
		if("Дверь из сот")
			if(host.getWax() < 75)
				host.balloon_alert(host, "недостаточно воска!")
				return
			if(do_after(usr, 10 SECONDS, usr))
				host.adjustWax(-75)
				host.visible_message(("[host] выделя[pluralize_ru(host.gender, "ет", "ют")] кучу воска и формиру[pluralize_ru(host.gender, "ет", "ют")] из неё дверь из сот."))
				new /obj/structure/alien/resin/door/wax(host.loc)*/

/datum/action/innate/wryn/toggle_producing
	name = "Переключить секрецию воска"
	button_icon_state = "glands"

/datum/action/innate/toggle_producing/Activate()
	var/mob/living/carbon/human/host = owner
	host.toggle_producing()

/obj/item/organ/internal/brain/wryn
	desc = "Основной орган центральной нервной системы гуманоида. Фактически, именно здесь и находится разум. Этот принадлежал врину."
	ru_names = list(
		NOMINATIVE = "мозг врина",
		GENITIVE = "мозга врина",
		DATIVE = "мозгу врина",
		ACCUSATIVE = "мозг врина",
		INSTRUMENTAL = "мозгом врина",
		PREPOSITIONAL = "мозге врина"
	)
	icon = 'icons/obj/species_organs/wryn.dmi'
	icon_state = "brain2"
	item_state = "wryn_brain"
	mmi_icon = 'icons/obj/species_organs/wryn.dmi'
	mmi_icon_state = "mmi_full"

/obj/item/organ/internal/heart/wryn
	species_type = /datum/species/wryn
	name = "wryn heart"
	desc = "Орган, качающий кровь или её заменяющую субстанцию по организму гуманоида. Это принадлежало врину."
	ru_names = list(
		NOMINATIVE = "сердце врина",
		GENITIVE = "сердца врина",
		DATIVE = "сердцу врина",
		ACCUSATIVE = "сердце врина",
		INSTRUMENTAL = "сердцем врина",
		PREPOSITIONAL = "сердце врина"
	)
	icon = 'icons/obj/species_organs/wryn.dmi'
	item_state = "wryn_heart-on"
	item_base = "wryn_heart"

/obj/item/organ/internal/eyes/wryn
	species_type = /datum/species/wryn
	name = "wryn eyes"
	desc = "Парный орган, отвечающий за зрение - восприятие света и его трансформацию в видимое изображение. Эти принадлежали врину."
	ru_names = list(
		NOMINATIVE = "глаза врина",
		GENITIVE = "глаз врина",
		DATIVE = "глазам врина",
		ACCUSATIVE = "глаза врина",
		INSTRUMENTAL = "глазами врина",
		PREPOSITIONAL = "глазах врина"
	)
	icon = 'icons/obj/species_organs/wryn.dmi'
	item_state = "wryn_eyes"
	see_in_dark = 3

/obj/item/organ/internal/ears/wryn
	species_type = /datum/species/wryn
	name = "wryn ears"
	desc = "Парный орган, отвечающий за аудиальное восприятие окружающей среды и получение информации о положении гуманоида в пространстве. Эти принадлежали врину."
	ru_names = list(
		NOMINATIVE = "уши врина",
		GENITIVE = "ушей врина",
		DATIVE = "ушам врина",
		ACCUSATIVE = "уши врина",
		INSTRUMENTAL = "ушами врина",
		PREPOSITIONAL = "ушах врина"
	)

/obj/item/organ/external/tail/wryn
	species_type = /datum/species/wryn
	name = "wryn tail"
	desc = "Хвост. Этот принадлежал врину."
	ru_names = list(
		NOMINATIVE = "хвост врина",
		GENITIVE = "хвоста врина",
		DATIVE = "хвосту врина",
		ACCUSATIVE = "хвост врина",
		INSTRUMENTAL = "хвостом врина",
		PREPOSITIONAL = "хвосте врина"
	)
	icon_name = "wryntail_s"
	max_damage = 35
	min_broken_damage = 25

/obj/item/organ/external/chest/wryn
	encased = "хитиновую оболочку на груди"
	convertable_children = list(/obj/item/organ/external/groin/wryn)

/obj/item/organ/external/groin/wryn
	encased = "хитиновую оболочку на животе"

/obj/item/organ/external/head/wryn
	species_type = /datum/species/wryn
	encased = "хитиновую оболочку на голове"
