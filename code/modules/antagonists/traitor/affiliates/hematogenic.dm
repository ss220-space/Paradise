#define FREE_INJECT_TIME 10 SECONDS
#define TARGET_INJECT_TIME 3 SECONDS
#define BLOOD_HARVEST_VOLUME 200
#define BLOOD_HARVEST_TIME 10 SECONDS

/datum/affiliate/hematogenic
	name = "Hematogenic Industries"
	desc = "Вы один из представителей \"большой фирмы\" Hematogenic Industries, ваш наниматель \n\
			рассчитывает провести некоторые исследования на объекте NanoTrasen. \n\
			\"Кто первый надел халат - тот и врач\" на объекте вы работаете не один, будьте эффективнее своих оппонентов. \n\
			Как вам стоит работать: действуйте на свое усмотрение, главное, не забывайте про фармакологическую этику - не навреди Корпорации. \n\
			Для хирурга самое важное - его руки, поэтому для сотрудников Hematogenic Industries боевые искусства под запретом. \n\
			Но взамен Корпорация предлагает вам опробовать её передовую разработку Hemophagus Essence Auto Injector.\n\
			Стандартные цели: Собрать крови полной духовной энергии, украсть передовое медицинское снаряжение, сделать одного из членов экипажа вампиром, украсть что-то или убить кого-то."
	tgui_icon = "hematogenic"
	hij_desc = "Вы - опытный наёмный агент Hematogenic Industries.\n\
			Основатель Hematogenic Industries высоко оценил ваши прошлые заслуги, а потому, дал вам возможность купить инжектор наполненный его собственной кровью... \n\
			Вас предупредили, что после инъекции вы будете продолжительное время испытывать сильный голод. \n\
			Ваша задача - утолить этот голод.\n\
			Возможны помехи от агентов других корпораций - действуйте на свое усмотрение."
	hij_obj = /datum/objective/blood/ascend
	objectives = list(/datum/objective/harvest_blood,
					/datum/objective/steal/hypo_or_defib,
					list(/datum/objective/steal = 60, /datum/objective/steal/hypo_or_defib = 40),
					/datum/objective/new_mini_vampire,
					list(/datum/objective/steal = 60, /datum/objective/maroon = 40),
					/datum/objective/escape
					)

/datum/affiliate/hematogenic/get_weight(mob/living/carbon/human/H)
	return (!ismachineperson(H)) * 2

/obj/item/hemophagus_extract
	name = "Bloody Injector"
	desc = "Инжектор странной формы, с неестественно двигающейся алой жидкостью внутри. На боку едва заметная гравировка \"Hematogenic Industries\". Конкретно на этом инжекторе установлена блокировка, не позволяющая исспользовать его на случайном гуманойде."
	icon = 'icons/obj/affiliates.dmi'
	icon_state = "hemophagus_extract"
	item_state = "inj_ful"
	lefthand_file = 'icons/obj/affiliates.dmi'
	righthand_file = 'icons/obj/affiliates.dmi'
	w_class = WEIGHT_CLASS_TINY
	var/datum/mind/target
	var/free_inject = FALSE
	var/used = FALSE
	var/used_state = "hemophagus_extract_used"

/obj/item/hemophagus_extract/attack(mob/living/target, mob/living/user, def_zone)
	return

/obj/item/hemophagus_extract/afterattack(atom/target, mob/user, proximity, params)
	if(used)
		return
	if(!ishuman(target))
		return
	var/mob/living/carbon/human/H = target
	if(H.stat == DEAD)
		return
	if((src.target && target != src.target) || !free_inject)
		to_chat(user, span_warning("You can't use [src] to [target]!"))
		return
	if(do_after(user, free_inject ? FREE_INJECT_TIME : TARGET_INJECT_TIME, target = target, max_interact_count = 1))
		inject(user, H)

/obj/item/hemophagus_extract/proc/inject(mob/living/user, mob/living/carbon/human/target)
	if(!free_inject)
		if(target.mind)
			target.rejuvenate()
			var/datum/antagonist/vampire/vamp = new()
			vamp.give_objectives = FALSE
			target.mind.add_antag_datum(vamp)
			to_chat(user, span_notice("You inject [target] with [src]"))
			used = TRUE
			item_state = "inj_used"
			update_icon(UPDATE_ICON_STATE)

			var/datum/antagonist/traitor/T = user.mind.has_antag_datum(/datum/antagonist/traitor)
			if (!T)
				return
			for(var/datum/objective/new_mini_vampire/objective in T.objectives)
				if(target.mind == objective.target)
					objective.made = TRUE
		else
			to_chat(user, span_notice("[target] body rejects [src]"))
		return
	else
		if(target.mind)
			var/datum/antagonist/vampire/vamp = new()
			vamp.give_objectives = FALSE
			target.mind.add_antag_datum(vamp)
			to_chat(user, span_notice("You inject [target == user ? "yourself" : target] with [src]"))
			used = TRUE
			item_state = "inj_used"
			update_icon(UPDATE_ICON_STATE)

			var/datum/antagonist/traitor/T = user.mind.has_antag_datum(/datum/antagonist/traitor)
			if (!T)
				return
			for(var/datum/objective/new_mini_vampire/objective in T.objectives)
				if(target.mind == objective.target)
					objective.made = TRUE
		else
			to_chat(user, span_notice("[target] body rejects [src]"))

/obj/item/hemophagus_extract/self
 	name = "Hemophagus Essence Auto Injector"
 	desc = "Инжектор странной формы, с неестественно двигающейся алой жидкостью внутри. На боку едва заметная гравировка \"Hematogenic Industries\"."
 	free_inject = TRUE

/obj/item/hemophagus_extract/update_icon_state()
 	icon_state = used ? used_state : initial(icon_state)

/obj/item/blood_harvester
	name = "Blood harvester"
	desc = "Большой шприц для быстрого сбора больших объемов крови. На боку едва заметная гравировка \"Hematogenic Industries\""
	icon = 'icons/obj/affiliates.dmi'
	icon_state = "blood_harvester"
	item_state = "blood1_used"
	lefthand_file = 'icons/obj/affiliates.dmi'
	righthand_file = 'icons/obj/affiliates.dmi'
	var/used = FALSE
	var/used_state = "blood_harvester_used"
	var/datum/mind/target
	w_class = WEIGHT_CLASS_TINY

/obj/item/blood_harvester/attack(mob/living/target, mob/living/user, def_zone)
	return

/obj/item/blood_harvester/proc/can_harvest(mob/living/carbon/human/target, mob/user)
	. = FALSE
	if(!istype(target))
		user.balloon_alert(src, "Не подходящая цель")
		return
	if(used)
		to_chat(user, span_warning("[src] is already used!"))
		return
	if (HAS_TRAIT(target, TRAIT_NO_BLOOD) || HAS_TRAIT(target, TRAIT_EXOTIC_BLOOD))
		user.balloon_alert(target, "Кровь не обнаружена!")
		return
	if(target.blood_volume < BLOOD_HARVEST_VOLUME)
		user.balloon_alert(target, "Недостаточно крови!")
		return
	if(!target.mind)
		user.balloon_alert(target, "Разум не обнаружен!")
		return
	return TRUE

/obj/item/blood_harvester/afterattack(atom/target, mob/user, proximity, params)
	if (!can_harvest(target, user))
		return
	var/mob/living/carbon/human/H = target

	to_chat(target, span_danger("[user] started collecting your blood using [src]!"))
	user.visible_message(span_warning("[user] started collecting [target]'s blood using [src]!"))
	if(do_after(user, BLOOD_HARVEST_TIME, target = target, max_interact_count = 1))
		harvest(user, H)

/obj/item/blood_harvester/proc/harvest(mob/living/carbon/human/user, mob/living/carbon/human/target)
	if (!can_harvest(target, user))
		return

	to_chat(target, span_danger("[user] collected your blood using [src]!"))
	user.visible_message(span_warning("[user] collected [target]'s blood using [src]!"))
	target.emote("scream")
	for (var/i = 0; i < 3; ++i)
		if (prob(60))
			continue
		var/obj/item/organ/external/bodypart = pick(target.bodyparts)
		bodypart.internal_bleeding() // no blood collection from metafriends.

	target.blood_volume -= BLOOD_HARVEST_VOLUME
	src.target = target.mind
	used = TRUE
	item_state = "blood1_ful"
	update_icon(UPDATE_ICON_STATE)

/obj/item/blood_harvester/update_icon_state()
 	icon_state = used ? used_state : initial(icon_state)

/obj/item/blood_harvester/attack_self(mob/user)
	. = ..()
	if (!used)
		user.balloon_alert(src, "уже пусто")
		return

	var/new_gender = tgui_alert(user, "Очистить сборщик крови?", "Подтверждение", list("Продолжить", "Отмена"))
	if(new_gender == "Продолжить")
		target = null
		used = FALSE
		item_state = "blood1_used"
		update_icon(UPDATE_ICON_STATE)

/obj/item/blood_harvester/examine(mob/user)
	. = ..()

	if (!used)
		. += span_info("Кровь не собрана.")
		return
	if (user?.mind.has_antag_datum(/datum/antagonist/traitor))
		. += span_info("Собрана кровь с отпечатком души [target.name].")
	else
		. += span_info("Кровь собрана.")

#undef FREE_INJECT_TIME
#undef TARGET_INJECT_TIME
