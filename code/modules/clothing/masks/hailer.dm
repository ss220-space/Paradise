#define MURDER                 "601 (Murder)"
#define RESISTING_ARREST       "101 (Resisting arrest)"
#define BREAKING_AND_ENTERING  "310 (Breaking and entering)"
#define RIOT                   "306 (Riot)"
#define ASSAULT                "401 (Assault, Officer)"

/datum/action/item_action/dispatch
	name = "Signal dispatch"
	desc = "Opens up a quick select wheel for reporting crimes, including your current location, to your fellow security officers."
	button_icon_state = "dispatch"
	icon_icon = 'icons/mob/actions/actions.dmi'
	use_itemicon = FALSE

/obj/item/clothing/mask/gas/sechailer
	var/obj/item/radio/headset/headset_sec/radio
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
	var/list/message_types = list(
		MURDER = "murder",
		RESISTING_ARREST = "resisting_arrest",
		BREAKING_AND_ENTERING = "breaking_and_entering",
		RIOT = "riot",
		ASSAULT = "assault_on_an_officer"
	)
	var/list/options = list()
	for(var/option in message_types)
		var/image/arrest_image = image(icon='icons/effects/aiming.dmi', icon_state = message_types[option])
		options[option] = arrest_image
	var/choise = show_radial_menu(user, user, options)
	if(!choise)
		return FALSE
	last_dispatch = world.time
	for(var/atom/movable/hailer in GLOB.sechailers)
		if(hailer.loc &&ismob(hailer.loc))
			//playsound(hailer.loc, "sound/voice/dispatch_please_respond.ogg", 100, FALSE) ТТС на серверах, саунд не нужен :(
			radio.autosay("Dispatch, code [choise] in progress in [A], requesting assistance.", "Security Announcer", channel)
