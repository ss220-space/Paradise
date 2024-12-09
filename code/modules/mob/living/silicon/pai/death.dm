/mob/living/silicon/pai/death(gibbed, cleanWipe)
	if(can_die())
		if(!cleanWipe)
			force_fold_out()
			visible_message(span_warning("[name] издаёт последний протяжный писк прежде, чем теряет питание и рассыпается на части.."))
		else
			card.visible_message(span_warning("Экран персонального ИИ медленно угасает, когда личность покидает устройство..."))

		name = "pAI debris"
		desc = "Дымящиеся останки какого-то несчастного персонального ИИ."
		icon_state = "[chassis]_dead"
		silence_time = null

	// Only execute the below if we successfully died
	. = ..(gibbed)
	if(!.)
		return FALSE

	if(icon_state != "[chassis]_dead" || cleanWipe)
		qdel(src)
