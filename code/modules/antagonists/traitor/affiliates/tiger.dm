#define FREE_INJECT_TIME 10 SECONDS
#define TARGET_INJECT_TIME 3 SECONDS

/datum/affiliate/tiger
	name = "Tiger Cooperative"
	desc = "Вы - послушник культа генокрадопоклонников и член организации Tiger Cooperative. \n\
			Вышестоящие братья определили ваши задачи на станции NanoTrasen, не опозорьте их и явите миру новое дитя генокрада! \n\
			Как вам стоит работать: не раскрывайте свое присутсвие и присутствие генокрада, позаботьтесь о его успешном внидрении. \n\
			Особые условия: братья по вере не пользуются оружием дальнего боя, предпочитая стимуляторы и энергомечи. \n\
			Стандартные цели: Предоставить тело генокраду, принять особое ритуальное вещество, разобраться с указанны еретиком, вернуться к братьям."
	objectives = list(// заразить яйцом гены,
					// бахнуть дозу,
					/datum/objective/maroon,
					/datum/objective/escape
					)

/datum/affiliate/tiger/finalize_affiliate(datum/mind/owner)
	. = ..()
	ADD_TRAIT(owner, TRAIT_CHUNKYFINGERS, TIGER_TRAIT)

/obj/item/cling_extract
	name = "Egg Implanter"
	desc = "Looks like something moving inside it"
	var/mob/living/carbon/human/target
	var/free_inject = FALSE
	var/used = FALSE
	var/used_state

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
	if(do_after_once(user, free_inject ? FREE_INJECT_TIME : TARGET_INJECT_TIME, target = user))
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
	name = "Cling AutoInjector"
	desc = "Looks like something moving inside it"
	free_inject = TRUE

/obj/item/cling_extract/update_icon_state()
	icon_state = used ? used_state : initial(icon_state)

#undef FREE_INJECT_TIME
#undef TARGET_INJECT_TIME
