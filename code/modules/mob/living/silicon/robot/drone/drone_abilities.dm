// DRONE ABILITIES
/mob/living/silicon/robot/drone/verb/set_mail_tag()
	set name = "Почтовый тег"
	set desc = "Пометьте себя для доставки через систему утилизации."
	set category = "Drone"

	var/tag = input("Выберите желаемое место назначения.", "Установка почтового тега", null) as null|anything in GLOB.TAGGERLOCATIONS

	if(!tag || GLOB.TAGGERLOCATIONS[tag])
		mail_destination = 0
		return

	to_chat(src, span_notice("Вы настраиваете внутренний маячок, помечая себя для доставки в \"[tag]\"."))
	mail_destination = GLOB.TAGGERLOCATIONS.Find(tag)

	//Auto flush if we use this verb inside a disposal chute.
	var/obj/machinery/disposal/D = src.loc
	if(istype(D))
		to_chat(src, "<span class='notice'>\The [D] acknowledges your signal.</span>")
		D.flush_count = D.flush_every_ticks


/mob/living/silicon/robot/drone/verb/hide()
	set name = "Спрятаться"
	set desc = "Позволяет спрятаться под столами или определёнными предметами. Включается или выключается."
	set category = "Drone"

	var/datum/action/innate/hide/drone/hide = locate() in actions
	if(!hide)
		return

	hide.Activate()


/mob/living/silicon/robot/drone/verb/light()
	set name = "Свет вкл/выкл"
	set desc = "Активирует маломощный всенаправленный светодиод. Включается или выключается."
	set category = "Drone"

	if(lamp_intensity)
		lamp_intensity = lamp_max // setting this to lamp_max will make control_headlamp shutoff the lamp
	control_headlamp()

//Actual picking-up event.
/mob/living/silicon/robot/drone/attack_hand(mob/living/carbon/human/M)
	if(M.a_intent == INTENT_HELP)
		get_scooped(M)
	else
		..()

/mob/living/silicon/robot/drone/verb/customize()
	set name = "Настройка шасси"
	set desc = "Переконфигурируйте своё шасси в кастомную версию."
	set category = "Drone"

	if(!custom_sprite) //Check to see if custom sprite time, checking the appopriate file to change a var
		var/file = file2text("config/custom_sprites.txt")
		var/lines = splittext(file, "\n")

		for(var/line in lines)
		// split & clean up
			var/list/Entry = splittext(line, ":")
			for(var/i = 1 to Entry.len)
				Entry[i] = trim(Entry[i])

			if(Entry.len < 2 || Entry[1] != "drone")
				continue

			if (Entry[2] == ckey) //Custom holograms
				custom_sprite = 1  // option is given in hologram menu

	if(!custom_sprite)
		to_chat(src, span_warning("Ошибка 404: Кастомное шасси не найдено. Отмена опции настройки."))
	else
		icon = 'icons/mob/custom_synthetic/custom-synthetic.dmi'
		icon_state = "[ckey]-drone"
		to_chat(src, span_notice("Вы переконфигурируете своё шасси и улучшаете станцию своими новыми эстетическими изменениями."))
	remove_verb(src, /mob/living/silicon/robot/drone/verb/customize)

/mob/living/silicon/robot/drone/get_scooped(mob/living/carbon/grabber)
	var/obj/item/holder/H = ..()
	if(!istype(H))
		return
	if(resting)
		set_resting(FALSE, instant = TRUE)
	if(custom_sprite)
		H.icon = 'icons/mob/custom_synthetic/custom-synthetic.dmi'
		H.onmob_sheets[ITEM_SLOT_HEAD_STRING] = 'icons/mob/custom_synthetic/custom_head.dmi'
		H.lefthand_file = 'icons/mob/custom_synthetic/custom_lefthand.dmi'
		H.righthand_file = 'icons/mob/custom_synthetic/custom_righthand.dmi'
		H.item_state = "[icon_state]_hand"
	else if(emagged)
		H.item_state = "drone-emagged"
	else
		H.item_state = "drone"
	grabber.put_in_active_hand(H, ignore_anim = FALSE)//for some reason unless i call this it dosen't work
	grabber.update_inv_l_hand()
	grabber.update_inv_r_hand()

	return H
