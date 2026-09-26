/mob/living/Login()
	..()
	//Mind updates
	sync_mind()
	update_stat("mob login")
	update_sight()
	//Should update regardless of if we can ventcrawl, since we can end up in pipes in other ways.
	update_pipe_vision()

	var/turf/T = get_turf(src)
	if(isturf(T))
		update_z(T.z)

	//If they're SSD, remove it so they can wake back up.
	set_SSD(FALSE)
	//Vents
	if(is_ventcrawler(src))
		to_chat(src, span_notice("Вы можете ползать по вентиляции! Используйте <b>Alt+ЛКМ</b> на вентиляционных решётках для быстрого перемещения по станции."))

	if(ranged_ability)
		ranged_ability.add_ranged_ability(src, span_notice("У вас сейчас активно умение: <b>[ranged_ability]</b>!"))

	SStitle.hide_title_screen_from(client)

	return .
