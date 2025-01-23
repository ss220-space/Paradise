/client/proc/bluespace_artillery(mob/living/target in GLOB.mob_list)
	set name = "Bluespace Artillery"
	set category = "Event"

	if(!check_rights(R_ADMIN|R_EVENT))
		return

	if(!isliving(target))
		to_chat(usr, span_warning("Это можно использовать только на объектах типа /mob/living"), confidential = TRUE)
		return

	if(tgui_alert(usr, "Вы уверены, что хотите выстрелить по [key_name(target)] из Блюспейс Артиллерии?",  "Подтверждение выстрела?" , list("Да" , "Нет")) != "Да")
		return

	if(GLOB.BSACooldown)
		to_chat(usr, "Подождите. Идет цикл перезарядки. Артиллерийские расчеты будут готовы через пять секунд!")
		return

	GLOB.BSACooldown = 1
	spawn(50)
		GLOB.BSACooldown = 0

	to_chat(target, "По вам попала блюспейс артиллерия!")
	log_admin("[key_name(target)] has been hit by Bluespace Artillery fired by [key_name(usr)]")
	message_admins("[key_name_admin(target)] has been hit by Bluespace Artillery fired by [key_name_admin(usr)]")

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

