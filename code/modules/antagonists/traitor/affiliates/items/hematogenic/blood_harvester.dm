#define BLOOD_HARVEST_VOLUME 200
#define BLOOD_HARVEST_TIME 10 SECONDS

/obj/item/blood_harvester
	name = "Blood harvester"
	desc = "Большой шприц для быстрого сбора больших объемов крови. На боку едва заметная гравировка \"Hematogenic Industries\""
	icon = 'icons/obj/affiliates.dmi'
	icon_state = "blood_harvester"
	item_state = "blood1_used"
	lefthand_file = 'icons/obj/affiliates_l.dmi'
	righthand_file = 'icons/obj/affiliates_r.dmi'
	var/used = FALSE
	var/used_state = "blood_harvester_used"
	var/datum/mind/target
	w_class = WEIGHT_CLASS_TINY
	origin_tech = "biotech=5;syndicate=1"

/obj/item/blood_harvester/attack(mob/living/target, mob/living/user, def_zone)
	return

/obj/item/blood_harvester/proc/can_harvest(mob/living/carbon/human/target, mob/user)
	. = FALSE
	if(!istype(target))
		user.balloon_alert(src, "Не подходящая цель")
		return

	if(used)
		to_chat(user, span_warning("[src] is already full!"))
		return

	if(HAS_TRAIT(target, TRAIT_NO_BLOOD) || HAS_TRAIT(target, TRAIT_EXOTIC_BLOOD))
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
	if(!can_harvest(target, user))
		return

	var/mob/living/carbon/human/H = target

	target.visible_message(span_warning("[user] started collecting [target]'s blood using [src]!"), span_danger("[user] started collecting your blood using [src]!"))
	if(do_after(user, BLOOD_HARVEST_TIME, target = target, max_interact_count = 1))
		harvest(user, H)

/obj/item/blood_harvester/proc/harvest(mob/living/carbon/human/user, mob/living/carbon/human/target)
	if(!can_harvest(target, user))
		return

	playsound(src, 'sound/goonstation/items/hypo.ogg', 80)
	target.visible_message(span_warning("[user] collected [target]'s blood using [src]!"), span_danger("[user] collected your blood using [src]!"))
	target.emote("scream")
	for (var/i = 0; i < 3; ++i)
		if(prob(60))
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
	if(!used)
		user.balloon_alert(src, "уже пусто")
		return

	var/new_gender = tgui_alert(user, "Очистить сборщик крови?", "Подтверждение", list("Продолжить", "Отмена"))
	if(new_gender == "Продолжить")
		target = null
		used = FALSE
		item_state = "blood1_used"
		update_icon(UPDATE_ICON_STATE)

	playsound(src, 'sound/goonstation/items/hypo.ogg', 80)
	user.visible_message(span_info("[user] cleared blood at [src]."), span_info("You cleared blood at [src]."))

/obj/item/blood_harvester/examine(mob/user)
	. = ..()

	if(!used)
		. += span_info("Кровь не собрана.")
		return

	if(user?.mind.has_antag_datum(/datum/antagonist/traitor))
		. += span_info("Собрана кровь с отпечатком души [target.name].")
	else
		. += span_info("Кровь собрана.")

#undef BLOOD_HARVEST_VOLUME
#undef BLOOD_HARVEST_TIME
