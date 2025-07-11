GLOBAL_LIST_EMPTY(sechailers)

/datum/action/item_action/dispatch
	name = "Экстренное сообщение"
	button_icon_state = "dispatch"
	icon_icon = 'icons/mob/actions/actions.dmi'
	use_itemicon = FALSE

/obj/item/clothing/mask/gas/sechailer
	var/obj/item/radio/radio
	var/dispatch_cooldown = 30 SECONDS
	var/on_cooldown = FALSE
	var/emped = FALSE
	var/static/list/available_dispatch_messages = list(
		"убийство",
		"сопротивление аресту",
		"вторжение",
		"безоружное нападение",
		"вооружённое нападение")

/obj/item/clothing/mask/gas/sechailer/Destroy()
	qdel(radio)
	GLOB.sechailers -= src
	. = ..()

/obj/item/clothing/mask/gas/sechailer/Initialize(mapload)
	. = ..()
	GLOB.sechailers += src
	radio = new /obj/item/radio(src)
	radio.listening = FALSE
	radio.config(list(SEC_FREQ_NAME = 0))
	radio.follow_target = src

/obj/item/clothing/mask/gas/sechailer/proc/dispatch(mob/user)
	if(on_cooldown)
		balloon_alert(user, "сейчас нельзя!")
		return
	var/list/radial_options = list()
	for(var/option in available_dispatch_messages)
		radial_options[option] = image(icon = 'icons/effects/aiming.dmi', icon_state = option)
	var/message = show_radial_menu(user, user, radial_options, require_near = TRUE)
	if(!message)
		return
	var/location_name = get_area_name(user, TRUE)
	on_cooldown = TRUE
	addtimer(CALLBACK(src, PROC_REF(reboot)), dispatch_cooldown)
	addtimer(CALLBACK(src, PROC_REF(send_report), user, message, location_name), 1 SECONDS)

/obj/item/clothing/mask/gas/sechailer/proc/send_report(mob/user, message, location)
	if(QDELETED(src) || !radio)
		return
	var/datum/radio_frequency/freq = SSradio.return_frequency(SEC_FREQ)
	if(!freq)
		balloon_alert(user, "нет связи!")
		return
	radio.autosay("[user] запрашивает подкрепление! Совершается [message], местоположение: [location].", "Экстренное сообщение", SEC_FREQ_NAME)
	for(var/atom/movable/hailer in GLOB.sechailers)
		if(ismob(hailer.loc))
			playsound(hailer.loc, "sound/voice/dispatch_please_respond.ogg", 60, FALSE)


/obj/item/clothing/mask/gas/sechailer/ui_action_click(mob/user, actiontype)
	. = ..()
	if(actiontype == /datum/action/item_action/dispatch)
		dispatch(user)

/obj/item/clothing/mask/gas/sechailer/emp_act(severity)
	if(on_cooldown)
		return
	on_cooldown = TRUE
	emped = TRUE
	var/datum/radio_frequency/freq = SSradio.return_frequency(SEC_FREQ)
	if(!freq)
		return
	for(var/atom/movable/hailer in GLOB.sechailers)
		if(ismob(hailer.loc))
			playsound(hailer.loc, "sound/voice/dispatch_please_respond.ogg", 60, FALSE)
	var/obj/item/radio/secure_radio = new /obj/item/radio(src)
	secure_radio.listening = TRUE
	secure_radio.config(list(SEC_FREQ_NAME = 1))
	secure_radio.follow_target = src
	var/username = ismob(loc) ? loc.name : "Неизвестный"
	var/fake_message = pick(available_dispatch_messages)
	var/fake_area = pick(GLOB.teleportlocs)
	secure_radio.autosay("[username] запрашивает подкрепление! Совершается [fake_message], местоположение: [fake_area].", "Экстренное сообщение", SEC_FREQ_NAME)
	QDEL_IN(secure_radio, 5 SECONDS)
	addtimer(CALLBACK(src, PROC_REF(reboot)), dispatch_cooldown)
	if(ishuman(loc))
		var/mob/living/carbon/human/user = loc
		to_chat(user, span_userdanger("Обнаружен электромагнитный импульс! Система оповещения временно отключена."))
		balloon_alert(user, "система выведена из строя")

/obj/item/clothing/mask/gas/sechailer/proc/reboot()
	on_cooldown = FALSE
	emped = FALSE
	if(ismob(loc))
		var/mob/user = loc
		balloon_alert(user, "система вновь активна")
