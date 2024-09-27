#define FREE_INJECT_TIME 10 SECONDS
#define TARGET_INJECT_TIME 3 SECONDS

/datum/affiliate/tiger
	name = "Tiger Cooperative"
	desc = "Вы - послушник культа генокрадопоклонников и член организации Tiger Cooperative. \n\
			Вышестоящие братья определили ваши задачи на станции NanoTrasen, не опозорьте их и явите миру новое дитя генокрада! \n\
			Как вам стоит работать: не раскрывайте свое присутсвие и присутствие генокрада, позаботьтесь о его успешном внедрении. \n\
			Особые условия: братья по вере не пользуются оружием дальнего боя, предпочитая стимуляторы и энергомечи.\n\
			Стандартные цели: Сделать члена экипажа генокрадом вколов в его труп яйца генокрада, развести бореров, украсть пару вещей, убить пару еретиков."
	objectives = list(/datum/objective/new_mini_changeling, // Oh, sorry, I forgot to make that stupid drug objective...
					/datum/objective/borers,
					list(/datum/objective/steal = 60, /datum/objective/maroon = 40),
					list(/datum/objective/steal = 60, /datum/objective/maroon = 40),
					/datum/objective/maroon,
					/datum/objective/escape
					)

/datum/affiliate/tiger/finalize_affiliate(datum/mind/owner)
	. = ..()
	ADD_TRAIT(owner, TRAIT_NO_GUNS, TIGER_TRAIT)

/obj/item/cling_extract
	name = "Egg Implanter"
	desc = "Кажется, внутри что-то двигается. На боку этикетка \"Tiger Cooperative\""
	icon = 'icons/obj/affiliates.dmi'
	icon_state = "cling_extract"
	var/used_state = "cling_extract_used"
	var/datum/mind/target
	var/free_inject = FALSE
	var/used = FALSE

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
			target.rejuvenate()
			var/datum/antagonist/changeling/cling = new()
			cling.give_objectives = FALSE
			target.mind.add_antag_datum(cling)
			to_chat(user, span_notice("You inject [target] with [src]"))
			used = TRUE
			update_icon(UPDATE_ICON_STATE)
		else
			to_chat(user, span_notice("[target] body rejects [src]"))
		return
	else
		if(target.mind)
			var/datum/antagonist/changeling/cling = new()
			cling.give_objectives = FALSE
			target.mind.add_antag_datum(cling)
			to_chat(user, span_notice("You inject [target == user ? "yourself" : target] with [src]"))
			used = TRUE
			update_icon(UPDATE_ICON_STATE)
		else
			to_chat(user, span_notice("[target] body rejects [src]"))

/obj/item/cling_extract/self
	free_inject = TRUE

/obj/item/cling_extract/update_icon_state()
	icon_state = used ? used_state : initial(icon_state)

/obj/item/reagent_containers/food/snacks/egg/borer
	filling_color = "#C0C021"
	list_reagents = list("protein" = 3, "egg" = 5, "rotatium" = 5)

// looks like normal
/obj/item/reagent_containers/food/snacks/egg/borer/attack_self(mob/living/carbon/human/user)
	. = ..()
	var/mob/living/simple_animal/borer/borer = new /mob/living/simple_animal/borer(get_turf(src))
	borer.master_name = user.real_name
	to_chat(user, span_notice("You squashed [src]. There was a [borer] inside."))
	qdel(src)


#undef FREE_INJECT_TIME
#undef TARGET_INJECT_TIME
