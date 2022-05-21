/mob/living/silicon/pai/death(gibbed, cleanWipe)
	if(can_die())
		if(!cleanWipe)
			force_fold_out()

		visible_message("<span class=warning>[src] изда[pluralize_ru(src.gender,"ёт","ют")] глухой бип, после чего отключа[pluralize_ru(src.gender,"ется","ются")] и пада[pluralize_ru(src.gender,"ет","ют")].</span>", "<span class=warning>Вы слышите глухой бип, а после него — звук бьющегося стекла.</span>")
		name = "pAI debris"
		desc = "Печальные обломки некоего бедного ПИИ."
		icon_state = "[chassis]_dead"

	// Only execute the below if we successfully died
	. = ..(gibbed)
	if(!.)
		return FALSE

	if(icon_state != "[chassis]_dead" || cleanWipe)
		qdel(src)
