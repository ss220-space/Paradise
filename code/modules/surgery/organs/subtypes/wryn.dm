//WRYN ORGAN
/obj/item/organ/internal/wryn/hivenode
	species_type = /datum/species/wryn
	name = "antennae"
	icon = 'icons/mob/human_races/r_wryn.dmi'
	icon_state = "antennae"
	parent_organ_zone = BODY_ZONE_HEAD
	slot = INTERNAL_ORGAN_HIVENODE

/obj/item/organ/internal/wryn/hivenode/insert(mob/living/carbon/human/M, special = ORGAN_MANIPULATION_DEFAULT)
	..()
	M.add_language(LANGUAGE_WRYN)
	var/obj/item/organ/external/head/head_organ = M.get_organ(BODY_ZONE_HEAD)
	head_organ.h_style = "Antennae"
	M.update_hair()

/obj/item/organ/internal/wryn/hivenode/remove(mob/living/carbon/human/M, special = ORGAN_MANIPULATION_DEFAULT)
	M.remove_language(LANGUAGE_WRYN)
	var/obj/item/organ/external/head/head_organ = M.get_organ(BODY_ZONE_HEAD)
	head_organ.h_style = "Bald"
	M.update_hair()
	. = ..()

/obj/item/organ/internal/wryn/glands
	species_type = /datum/species/wryn
	name = "wryn wax glands"
	icon_state = "eggsac"
	parent_organ_zone = BODY_ZONE_PRECISE_MOUTH
	slot = INTERNAL_ORGAN_WAX_GLANDS
	var/datum/action/innate/honeycomb/honeycomb = new
	var/datum/action/innate/honeyfloor/honeyfloor = new
	var/datum/action/innate/toggle_producing/toggle_producing = new
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
	honeycomb.Grant(M)
	honeyfloor.Grant(M)
	toggle_producing.Grant(M)

/obj/item/organ/internal/wryn/glands/remove(mob/living/carbon/M, special = ORGAN_MANIPULATION_DEFAULT)
	honeycomb.Remove(M)
	honeyfloor.Remove(M)
	toggle_producing.Remove(M)
	. = ..()

/datum/action/innate/honeycomb
	name = "Secrete Wax"
	desc = "Secrete Wax"
	button_icon_state = "wax_wall"

/datum/action/innate/honeycomb/Activate()
	var/mob/living/carbon/human/wryn/host = owner

	if(host.getWax() >= 50)
		var/choice = input("Что бы построить...","Строительство") as null|anything in list("соты","прозрачные соты")

		if(!choice || host.getWax() < 50)	return

		if(do_after(usr, 5 SECONDS, usr))
			if(locate(/obj/structure/wryn/wax) in get_turf(owner))
				owner.balloon_alert(owner, "место уже занято!")
				return
			host.adjustWax(-50)
			host.visible_message(("[host] выделяет кучу воска и формирует из неё [choice]!"))
			switch(choice)
				if("соты")
					new /obj/structure/wryn/wax/wall(host.loc)
				if("прозрачные соты")
					new /obj/structure/wryn/wax/window(host.loc)

	else
		owner.balloon_alert(owner, "недостаточно воска!")

	return

/datum/action/innate/honeyfloor
	name = "Honey Floor"
	desc = "Honey Floor"
	button_icon_state = "wax_floor"

/datum/action/innate/honeyfloor/Activate()
	var/mob/living/carbon/human/wryn/host = owner

	if(host.getWax() >= 25)
		if(do_after(usr, 1 SECONDS, usr))
			if(locate(/obj/structure/wryn/floor) in get_turf(owner))
				owner.balloon_alert(owner, "уже покрыто воском")
				return
			host.adjustWax(-25)
			host.visible_message(span_alert("[owner] выделяет кучу воска и формирует из неё пол!"))
			new /obj/structure/wryn/floor(owner.loc)
	else
		owner.balloon_alert(owner, "недостаточно воска!")
	return

/datum/action/innate/toggle_producing
	name = "Toggle Wax Producing"
	button_icon_state = "wrynglands"

/datum/action/innate/toggle_producing/Activate()
	var/mob/living/carbon/human/host = owner
	host.toggle_producing()

/obj/item/organ/internal/eyes/wryn
	species_type = /datum/species/wryn
	see_in_dark = 3

/obj/item/organ/external/tail/wryn
	species_type = /datum/species/wryn
	name = "wryn tail"
	icon_name = "wryntail_s"
	max_damage = 35
	min_broken_damage = 25

/obj/item/organ/external/chest/wryn
	encased = "chitin armour"
	convertable_children = list(/obj/item/organ/external/groin/wryn)

/obj/item/organ/external/groin/wryn
	encased = "groin chitin"

/obj/item/organ/external/head/wryn
	species_type = /datum/species/wryn
	encased = "head chitin"
