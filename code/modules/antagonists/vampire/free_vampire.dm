/// Absolutely the same as a new_vampire, but has no antag objectives
/datum/antagonist/vampire/free_vampire
	name = "Free-Vampire"
	antag_datum_blacklist = list(/datum/antagonist/vampire)
	antag_menu_name = "Свободный вампир"
	upgrade_tiers = list(
		/obj/effect/proc_holder/spell/vampire/self/rejuvenate = 0,
		/obj/effect/proc_holder/spell/vampire/glare = 0,
		/datum/vampire_passive/vision = 100,
		/obj/effect/proc_holder/spell/vampire/self/specialize = 100,
		/datum/vampire_passive/regen = 200,
	)


/datum/antagonist/vampire/free_vampire/add_owner_to_gamemode()
	SSticker.mode.vampires += owner


/datum/antagonist/vampire/free_vampire/remove_owner_from_gamemode()
	SSticker.mode.vampires -= owner


/datum/antagonist/vampire/free_vampire/greet()
	SEND_SOUND(owner.current, sound('sound/ambience/antag/vampalert.ogg'))

	var/list/messages = list()
	messages.Add(span_danger("Вы — вампир!<br>"))
	messages.Add(span_danger("Вы были прокляты могущественным вампиром и восстали из мёртвых в \"новом\" для вас теле. Теперь вы вынуждены пить кровь, чтобы жить."))
	messages.Add(span_danger("Вы не подчиняетесь проклявшему вас вампиру и обладаете свободной волей."))
	messages.Add(span_danger("Вы не являетесь полноценным антагонистом и не должны убивать, за исключением случаев самообороны.<br>"))
	messages.Add("Чтобы укусить кого-то, нацельтесь на голову, выберите намерение <b>вреда (4)</b> и ударьте пустой рукой. Пейте кровь, чтобы получать новые силы. \
		Вы уязвимы перед святостью, огнём и звёздным светом. Не выходите в космос, избегайте священника, церкви и, особенно, святой воды.")
	return messages


/datum/antagonist/vampire/free_vampire/give_objectives()
	add_objective(/datum/objective/survive)


/proc/is_free_vampire(datum/source)
	if(!source)
		return FALSE

	if(istype(source, /datum/mind))
		var/datum/mind/our_mind = source
		return our_mind.has_antag_datum(/datum/antagonist/vampire/free_vampire)

	if(!ismob(source))
		return FALSE

	var/mob/mind_holder = source
	if(!mind_holder.mind)
		return FALSE

	return mind_holder.mind.has_antag_datum(/datum/antagonist/vampire/free_vampire)
