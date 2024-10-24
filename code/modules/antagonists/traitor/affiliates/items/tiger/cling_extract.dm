#define FREE_INJECT_TIME 10 SECONDS
#define TARGET_INJECT_TIME 3 SECONDS

/obj/item/cling_extract
	name = "Egg Implanter"
	desc = "Кажется, внутри что-то двигается. На боку этикетка \"Tiger Cooperative\""
	icon = 'icons/obj/affiliates.dmi'
	icon_state = "cling_extract"
	item_state = "inj_ful"
	lefthand_file = 'icons/obj/affiliates_l.dmi'
	righthand_file = 'icons/obj/affiliates_r.dmi'
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
			if(!candidates.len)
				to_chat(user, span_notice("[target] body rejects [src]"))
				return

			theghost = pick(candidates)
			theghost.mind.transfer_to(target)


		if(target.mind)
			playsound(src, 'sound/goonstation/items/hypo.ogg', 80)
			target.rejuvenate()
			var/datum/antagonist/changeling/cling = new()
			cling.give_objectives = FALSE
			cling.add_objective(/datum/objective/escape/escape_with_identity)
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
			cling.add_objective(/datum/objective/escape/escape_with_identity)
			target.mind.add_antag_datum(cling)
			to_chat(user, span_notice("You inject [target == user ? "yourself" : target] with [src]"))
			used = TRUE
			item_state = "inj_used"
			update_icon(UPDATE_ICON_STATE)
		else
			to_chat(user, span_notice("[target] body rejects [src]"))

/obj/item/cling_extract/examine(mob/user)
	. = ..()
	if(target)
		. += span_info("It is intended for [target]")

/obj/item/cling_extract/self
	free_inject = TRUE

/obj/item/cling_extract/update_icon_state()
	icon_state = used ? used_state : initial(icon_state)

#undef FREE_INJECT_TIME
#undef TARGET_INJECT_TIME
