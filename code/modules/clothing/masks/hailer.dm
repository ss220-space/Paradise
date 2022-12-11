/datum/action/item_action/dispatch
	name = "Signal dispatch"
	desc = "Opens up a quick select wheel for reporting crimes, including your current location, to your fellow security officers."
	button_icon_state = "dispatch"
	icon_icon = 'icons/mob/actions/actions.dmi'

/obj/item/clothing/mask/gas/sechailer
	var/obj/item/radio/headset/radio //For engineering alerts.
	var/radio_key = /obj/item/encryptionkey/headset_sec
	var/channel = "Security"
	var/dispatch_cooldown = 20
	var/last_dispatch = 0

/obj/item/clothing/mask/gas/sechailer/Destroy()
	qdel(radio)
	qdel(radio_key)
	GLOB.sechailers -= src
	. = ..()

/obj/item/clothing/mask/gas/sechailer/Initialize()
	. = ..()
	GLOB.sechailers += src
	radio = new(src)
	radio.ks1type = new radio_key
	radio.listening = TRUE
	radio.recalculateChannels()

/obj/item/clothing/mask/gas/sechailer/proc/IsVocal()
	return TRUE

/obj/item/clothing/mask/gas/sechailer/proc/dispatch(mob/user)
	var/area/A = get_area(src)
	if(world.time < last_dispatch + dispatch_cooldown)
		to_chat(user, "<span class='notice'>Dispatch radio broadcasting systems are recharging.</span>")
		return FALSE
	var/list/options = list()
	for(var/option in list("601 (Murder)", "101 (Resisting arrest)", "310 (Breaking and entering)", "306 (Riot)", "401 (Assault, Officer)"))
		options[option] = image(icon = 'icons/effects/aiming.dmi', icon_state = option)
	var/message = show_radial_menu(user, user, options)
	last_dispatch = world.time
	for(var/atom/movable/hailer in GLOB.sechailers)
		if(hailer.loc &&ismob(hailer.loc))
			playsound(hailer.loc, "sound/voice/dispatch_please_respond.ogg", 100, FALSE)
			radio.talk_into(user, "Dispatch, code [message] in progress in [A], requesting assistance.", channel)
