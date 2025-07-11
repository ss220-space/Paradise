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
	for(var/option in available_dispatch_messages)
		available_dispatch_messages[option] = image(icon = 'icons/effects/aiming.dmi', icon_state = option)
	var/message = show_radial_menu(user, user, available_dispatch_messages, require_near = TRUE)
	var/location_name = get_location_name(src, TRUE)
	if(!message)
		return
	on_cooldown = TRUE
	addtimer(CALLBACK(src, PROC_REF(reboot)), dispatch_cooldown)
	for(var/atom/movable/hailer in GLOB.sechailers)
		var/security_channel_found = FALSE
		if(!hailer.loc || !ismob(hailer.loc))
			continue
		for(var/obj/item/radio/my_radio in user)
			for(var/chan in 1 to length(my_radio.channels))
				var/channel_name = my_radio.channels[chan]
				if(channel_name == SEC_FREQ_NAME)
					security_channel_found = TRUE
					break
		if(security_channel_found)
			sleep(1 SECONDS)
			playsound(hailer.loc, "sound/voice/dispatch_please_respond.ogg", 60, FALSE)
			sleep(1 SECONDS)
			radio.autosay("[user] запрашивает подкрепление! Совершается [message], местоположение: [location_name].", "Экстренное сообщение", SEC_FREQ_NAME)
			break
		else
			balloon_alert(user, "нет связи!")

/obj/item/clothing/mask/gas/sechailer/proc/reboot()
	on_cooldown = FALSE
	emped = FALSE

/obj/item/clothing/mask/gas/sechailer/ui_action_click(mob/user, actiontype)
	. = ..()
	if(actiontype == /datum/action/item_action/dispatch)
		dispatch(user)

/obj/item/clothing/mask/gas/sechailer/emp_act(severity)
	if(on_cooldown)
		return
	on_cooldown = TRUE
	emped = TRUE
	addtimer(CALLBACK(src, PROC_REF(reboot)), dispatch_cooldown)
	if(ishuman(loc))
		var/mob/living/carbon/human/user = loc
		to_chat(user, span_userdanger("Обнаружен электромагнитный импульс! Система временно отключена с целью сохранения работоспособности."))
