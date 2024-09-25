#define FREE_INJECT_TIME 10 SECONDS
#define TARGET_INJECT_TIME 3 SECONDS

/datum/affiliate/hematogenic
	name = "Hematogenic Industries"
	desc = "Вы один из представителей \"большой фирмы\" Hematogenic Industries, ваш наниматель \n\
			рассчитывает провести некоторые исследования на объекте NanoTrasen. \n\
			\"Кто первый надел халат - тот и врач\" на объекте вы работаете не один, будьте эффективнее своих оппонентов. \n\
			Как вам стоит работать: действуйте на свое усмотрение, главное, не забывайте про фармакологическую этику - не навреди Корпорации. \n\
			Для хирурга самое важное - его руки, поэтому для сотрудников Hematogenic Industries боевые искусства под запретом. \n\
			Но взамен Корпорация предлагает вам опробовать её передовую разработку Hemophagus Essence Auto Injector."

	objectives = list(/datum/objective/harvest_blood,
					/datum/objective/steal/hypo_or_defib,
					list(/datum/objective/steal = 60, /datum/objective/steal/hypo_or_defib = 40),
					/datum/objective/new_mini_vampire,
					list(/datum/objective/steal = 60, /datum/objective/maroon = 40),
					/datum/objective/escape
					)

/obj/item/hemophagus_extract
	name = "Bloody Injector"
	desc = "Инжектор странной формы, с неестественно двигающейся алой жидкостью внутри. На боку едва заметная гравировка \"Hematogenic Industries\". Конкретно на этом инжекторе установлена блокировка, не позволяющая исспользовать его на случайном гуманойде."
	icon = 'icons/obj/affiliates.dmi'
	icon_state = "hemophagus_extract"
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
	if(do_after(user, free_inject ? FREE_INJECT_TIME : TARGET_INJECT_TIME, target = user, max_interact_count = 1))
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
			update_icon(UPDATE_ICON_STATE)

			var/datum/antagonist/traitor/T = user.mind.has_antag_datum(/datum/antagonist/traitor)
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
			update_icon(UPDATE_ICON_STATE)

			var/datum/antagonist/traitor/T = user.mind.has_antag_datum(/datum/antagonist/traitor)
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

#undef FREE_INJECT_TIME
#undef TARGET_INJECT_TIME
