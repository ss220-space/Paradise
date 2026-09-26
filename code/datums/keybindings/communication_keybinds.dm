/datum/keybinding/client/communication
	abstract_type = /datum/keybinding/client/communication
	category = KB_CATEGORY_COMMUNICATION
	/// Used to store special rights if required by a keybind, such as R_ADMIN
	var/required_rights
	/// Used to map muted categories to channels
	var/mute_category = MUTE_OOC
	var/command = ""

/datum/keybinding/client/communication/New()
	keybind_signal = COMSIG_KB_CLIENT_COMMUNICATION(name)
	full_name = name
	..()

/datum/keybinding/client/communication/down(client/C)
	. = ..()
	if(required_rights && !check_rights(required_rights, FALSE, C.mob))
		return

	if(mute_category && check_mute(C.ckey, mute_category))
		to_chat(C, span_danger("You cannot use [name] (muted)."), MESSAGE_TYPE_WARNING)
		return

	if(C.prefs?.toggles2 & PREFTOGGLE_2_DISABLE_TGUI_INPUT)
		winset(C, null, "command=[command]")
		return TRUE

	winset(C, null, "command=[C.tgui_say_create_open_command(name)];")
	winset(C, SKIN_TGUISAY_BROWSER, "focus=true")

/datum/keybinding/client/communication/ooc
	name = OOC_CHANNEL
	hotkey_keys = list("O")
	command = VERB_OOC

/datum/keybinding/client/communication/ooc/down(client/C)
	if(check_rights(R_ADMIN, FALSE, C.mob)) // You may pass
		return ..()

	if(!CONFIG_GET(flag/ooc_allowed))
		to_chat(C, span_danger("OOC is globally muted."), MESSAGE_TYPE_WARNING)
		return

	if(!CONFIG_GET(flag/dooc_allowed))
		to_chat(C, span_danger("OOC for dead mobs has been turned off."), MESSAGE_TYPE_WARNING)
		return

	return ..()

/datum/keybinding/client/communication/looc
	name = LOOC_CHANNEL
	hotkey_keys = list("L")
	command = VERB_LOOC

/datum/keybinding/client/communication/say
	name = SAY_CHANNEL
	hotkey_keys = list("T")
	mute_category = MUTE_IC
	command = VERB_SAY

/datum/keybinding/client/communication/me
	name = ME_CHANNEL
	hotkey_keys = list("M")
	mute_category = MUTE_EMOTE
	command = VERB_ME

/datum/keybinding/client/communication/whisper
	name = WHISPER_CHANNEL
	hotkey_keys = list("ShiftT")
	mute_category = MUTE_IC
	command = VERB_WHISPER

/datum/keybinding/client/communication/radio
	name = RADIO_CHANNEL
	hotkey_keys = list("Y")
	mute_category = MUTE_IC
	command = VERB_SAY

/datum/keybinding/client/communication/msay
	name = MENTOR_CHANNEL
	hotkey_keys = list("F4")
	required_rights = R_MENTOR | R_ADMIN

/datum/keybinding/client/communication/asay
	name = ADMIN_CHANNEL
	hotkey_keys = list("F5")
	required_rights = R_ADMIN | R_MOD

/datum/keybinding/client/communication/dsay
	name = DSAY_CHANNEL
	hotkey_keys = list("F10")
	required_rights = R_ADMIN | R_MOD

/datum/keybinding/client/communication/devsay
	name = DEV_CHANNEL
	hotkey_keys = list("F2")
	required_rights = R_VIEWRUNTIMES | R_ADMIN

/datum/keybinding/client/communication/pray
	hotkey_keys = list("P")
	name = PRAY_CHANNEL
	command = VERB_PRAY

/datum/keybinding/client/communication/pray/can_use(client/user)
	return isliving(user.mob)
