#define FREE_INJECT_TIME 10 SECONDS
#define TARGET_INJECT_TIME 3 SECONDS

/datum/affiliate/tiger
	name = "Tiger Cooperative"
	affil_info = list("Преимущества: ",
			"Скидка 25% на имплант адреналина",
			"Скидка 50% на прототип импланта адреналина",
			"Скидка 30% на лазерный меч",
			"Новый предмет - \"Egg Implanter\"",
			"Недостатки: ",
			"Вы не можете купить или использовать оружие дальнего боя",
			"Стандартные цели:",
			"Сделать члена экипажа генокрадом вколов в его труп яйца генокрада",
			"Увеличить популяцию бореров",
			"Украсть пару ценных вещей",
			"Убить пару еретиков")
	objectives = list(/datum/objective/new_mini_changeling, // Oh, sorry, I forgot to make that stupid drug objective...
					/datum/objective/borers,
					list(/datum/objective/steal = 60, /datum/objective/maroon = 40),
					list(/datum/objective/steal = 60, /datum/objective/maroon = 40),
					/datum/objective/maroon,
					/datum/objective/escape
					)

/datum/affiliate/tiger/get_weight(mob/living/carbon/human/H)
	return (!ismachineperson(H)) * 2

/datum/affiliate/tiger/finalize_affiliate(datum/mind/owner)
	. = ..()
	ADD_TRAIT(owner.current, TRAIT_NO_GUNS, TIGER_TRAIT)
	add_discount_item(/datum/uplink_item/dangerous/sword, 0.70)
	add_discount_item(/datum/uplink_item/implants/adrenal, 0.75)
	add_discount_item(/datum/uplink_item/implants/adrenal/prototype, 0.5)

/obj/item/cling_extract
	name = "Egg Implanter"
	desc = "Кажется, внутри что-то двигается. На боку этикетка \"Tiger Cooperative\""
	icon = 'icons/obj/affiliates.dmi'
	icon_state = "cling_extract"
	item_state = "inj_ful"
	lefthand_file = 'icons/obj/affiliates.dmi'
	righthand_file = 'icons/obj/affiliates.dmi'
	var/used_state = "cling_extract_used"
	var/datum/mind/target
	var/free_inject = FALSE
	var/used = FALSE
	origin_tech = "biotech=7;syndicate=3"

/obj/item/cling_extract/attack(mob/living/target, mob/living/user, def_zone)
	return

/obj/item/cling_extract/afterattack(atom/target, mob/user, proximity, params)
	if(used)
		return

	if(!ishuman(target))
		return

	if((src.target && target != src.target) || !free_inject)
		to_chat(user, span_warning("You can't use [src] to [target]!"))
		return

	var/mob/living/carbon/human/H = target
	if(H.stat != DEAD && !free_inject)
		to_chat(user, span_warning("You can't use [src] to [target]!"))
		return

	if(do_after(user, free_inject ? FREE_INJECT_TIME : TARGET_INJECT_TIME, user, max_interact_count = 1))
		inject(user, H)

/obj/item/cling_extract/proc/inject(mob/living/user, mob/living/carbon/human/target)
	if(target.stat == DEAD)
		if(!free_inject)
			var/list/mob/dead/observer/candidates = SSghost_spawns.poll_candidates("Вы хотите поиграть за генокрада?", ROLE_CHANGELING, FALSE, 10 SECONDS, source = src, role_cleanname = "Генокрад")
			var/mob/dead/observer/theghost = null
			if(candidates.len)
				theghost = pick(candidates)
				theghost.mind.transfer_to(target)
			else
				to_chat(user, span_notice("[target] body rejects [src]"))
				return

		if(target.mind)
			playsound(src, 'sound/goonstation/items/hypo.ogg', 80)
			target.rejuvenate()
			var/datum/antagonist/changeling/cling = new()
			cling.give_objectives = FALSE
			target.mind.add_antag_datum(cling)
			to_chat(user, span_notice("You inject [target] with [src]"))
			used = TRUE
			item_state = "inj_used"
			update_icon(UPDATE_ICON_STATE)
		else
			to_chat(user, span_notice("[target] body rejects [src]"))
		return
	else
		if(target.mind)
			playsound(src, 'sound/goonstation/items/hypo.ogg', 80)
			var/datum/antagonist/changeling/cling = new()
			cling.give_objectives = FALSE
			target.mind.add_antag_datum(cling)
			to_chat(user, span_notice("You inject [target == user ? "yourself" : target] with [src]"))
			used = TRUE
			item_state = "inj_used"
			update_icon(UPDATE_ICON_STATE)
		else
			to_chat(user, span_notice("[target] body rejects [src]"))

/obj/item/cling_extract/examine(mob/user)
	. = ..()
	if (target)
		. += span_info("It is intended for [target]")

/obj/item/cling_extract/self
	free_inject = TRUE

/obj/item/cling_extract/update_icon_state()
	icon_state = used ? used_state : initial(icon_state)

/obj/item/reagent_containers/food/snacks/egg/borer
	filling_color = "#C0C021"
	list_reagents = list("protein" = 3, "egg" = 5, "rotatium" = 5)
	origin_tech = "biotech=6;syndicate=1"

// looks like normal
/obj/item/reagent_containers/food/snacks/egg/borer/attack_self(mob/living/carbon/human/user)
	. = ..()
	var/mob/living/simple_animal/borer/borer = new /mob/living/simple_animal/borer(get_turf(src))
	borer.master_name = user.real_name
	to_chat(user, span_notice("You squashed [src]. There was a [borer] inside."))
	qdel(src)


#undef FREE_INJECT_TIME
#undef TARGET_INJECT_TIME
