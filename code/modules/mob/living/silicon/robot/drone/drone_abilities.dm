// DRONE ABILITIES
/mob/living/silicon/robot/drone/verb/set_mail_tag()
	set name = "Set Mail Tag"
	set desc = "Tag yourself for delivery through the disposals system."
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
	set name = "Hide"
	set desc = "Allows you to hide beneath tables or certain items. Toggled on or off."
	set category = "Drone"

	var/datum/action/innate/hide/drone/hide = locate() in actions
	if(!hide)
		return

	hide.Activate()


/mob/living/silicon/robot/drone/verb/light()
	set name = "Light On/Off"
	set desc = "Activate a low power omnidirectional LED. Toggled on or off."
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
	set name = "Customize Chassis"
	set desc = "Reconfigure your chassis into a customized version."
	set category = "Drone"

	to_chat(src, span_warning("Ошибка 404: Кастомное шасси не найдено. Отмена опции настройки."))
	remove_verb(src, /mob/living/silicon/robot/drone/verb/customize)

/mob/living/silicon/robot/drone/get_scooped(mob/living/carbon/grabber)
	var/obj/item/holder/H = ..()
	if(!istype(H))
		return
	if(resting)
		set_resting(FALSE, instant = TRUE)
	if(emagged)
		H.item_state = "drone-emagged"
	else
		H.item_state = "drone"
	grabber.put_in_active_hand(H, ignore_anim = FALSE)//for some reason unless i call this it dosen't work
	grabber.update_inv_l_hand()
	grabber.update_inv_r_hand()

	return H
