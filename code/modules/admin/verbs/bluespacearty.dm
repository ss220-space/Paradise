ADMIN_VERB(bluespace_artillery, R_ADMIN|R_EVENT, "Bluespace Artillery", "Выстрелить из БСА.", ADMIN_CATEGORY_FUN, mob/living/target in GLOB.mob_list)
	if(!isliving(target))
		to_chat(user, span_warning("Это можно использовать только на объектах типа /mob/living"), confidential = TRUE)
		return

	if(tgui_alert(user, "Вы уверены, что хотите выстрелить по [key_name(target)] из Блюспейс Артиллерии?",  "Подтверждение выстрела?" , list("Да" , "Нет")) != "Да")
		return

	if(GLOB.BSACooldown)
		to_chat(user, "Подождите. Идет цикл перезарядки. Артиллерийские расчеты будут готовы через пять секунд!")
		return

	GLOB.BSACooldown = 1
	spawn(50)
		GLOB.BSACooldown = 0

	to_chat(target, "По вам попала блюспейс артиллерия!")
	log_admin("[key_name(target)] has been hit by Bluespace Artillery fired by [key_name(user)]")
	message_admins("[key_name_admin(target)] has been hit by Bluespace Artillery fired by [key_name_admin(user)]")

	var/turf/simulated/floor/T = get_turf(target)
	if(istype(T))
		if(prob(80))
			T.break_tile_to_plating()
		else
			T.break_tile()

	if(target.health <= 1)
		target.gib()
	else
		target.adjustBruteLoss(min(99,(target.health - 1)))
		target.Weaken(40 SECONDS)
		target.Stuttering(40 SECONDS)

