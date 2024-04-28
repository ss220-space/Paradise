/datum/affiliate/hematogenic
	name = "Hematogenic Industries"
	desc = "Вы один из представителей \"большой фармы\" Hematogenic Industries, ваш наниматель \n\
			рассчитывает провести некоторые исследования на объекте NanoTrasen. \n\
			\"Кто первый надел халат - тот и врач\" на объекте вы работаете не один, будьте эффективнее своих оппонентов. \n\
			Как вам стоит работать: действуйте на свое усмотрение, главное не забывайте про фармакологическую этику - не навреди Корпорации. \n\
			Для хирурга самое важное - его руки, поэтому для сотрудников Hematogenic Industries боевые искусства под запретом. \n\
			Но в замен Корпорация предлагает вам опробовать её передовую разработку Hemophagus Essence Auto Injector. \n\
			Стандартные цели: заполучить несколько пакетов крови от разных рас, захватить высокотехнологичное мед оборудование, \n\
			провести гематогенные исследования над указанной целью, покинуть объект."

	objectives = list(// получить пакеты с кровью,
					// украсть дефию/гиппо смо,
					// заразить главу,
					/datum/objective/escape
					)

/obj/item/hemophagus_extract
	name = "Bloody Injector"
	desc = "Looks like something moving inside it"
	var/mob/living/carbon/human/target
	var/free_inject = FALSE
	var/used = FALSE
	var/used_state

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
	if(do_after_once(user, free_inject ? FREE_INJECT_TIME : TARGET_INJECT_TIME, target = user))
		inject(user, H)

/obj/item/hemophagus_extractt/proc/inject(mob/living/user, mob/living/carbon/human/target)
	if(!free_inject)
		if(target.mind)
			target.rejuvenate()
			var/datum/antagonist/vampire/vamp = new()
			vamp.give_objectives = FALSE
			target.mind.add_antag_datum(vamp)
			to_chat(user, span_notice("You inject [target] with [src]"))
			used = TRUE
			update_icon(UPDATE_ICON_STATE)
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
		else
			to_chat(user, span_notice("[target] body rejects [src]"))

/obj/item/hemophagus_extract/self
	name = "Hemophagus Essence Auto Injector"
	desc = "Looks like something moving inside it"
	free_inject = TRUE

/obj/item/hemophagus_extract/update_icon_state()
	icon_state = used ? used_state : initial(icon_state)

