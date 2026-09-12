/datum/keybinding/emote
	category = KB_CATEGORY_EMOTE_GENERIC
	weight = WEIGHT_EMOTE
	keybind_signal = COMSIG_KB_EMOTE
	var/emote_key

/datum/keybinding/emote/proc/link_to_emote(datum/emote/faketype)
	hotkey_keys = list(UNBOUND_KEY)
	classic_keys = list(UNBOUND_KEY)
	emote_key = initial(faketype.key)
	name = initial(faketype.key)
	full_name = capitalize(initial(faketype.name))
	keybind_signal = COMSIG_KB_EMOTE_KEY(emote_key)
	category = faketype.keybind_category

/datum/keybinding/emote/down(client/user, turf/target, mousepos_x, mousepos_y)
	. = ..()
	if(.)
		return
	return user.mob.emote(emote_key, intentional = TRUE)

/**
 * MARK: Custom
 */
/datum/keybinding/custom
	abstract_type = /datum/keybinding/custom
	category = KB_CATEGORY_EMOTE_CUSTOM
	keybind_signal = COMSIG_KB_EMOTE
	var/default_emote_text = "Введите текст вашей эмоции"
	var/donor_exclusive = FALSE

/datum/keybinding/custom/down(client/user, turf/target, mousepos_x, mousepos_y)
	. = ..()
	if(.)
		return .
	if(!user.prefs?.custom_emotes) //Checks the current character save for any custom emotes
		return TRUE

	var/desired_emote = user.prefs.custom_emotes[name] //check the custom emotes list for this keybind name

	if(!desired_emote)
		return TRUE

	user.mob.me_verb(html_decode(desired_emote)) //do the thing!
	return TRUE

/datum/keybinding/custom/can_use(client/user)
	if(donor_exclusive && !((user.donator_level >= 2) || user.holder || user.prefs?.unlock_content)) //is this keybind restricted to donors/byond members/admins, and are you one or not?
		return FALSE
	return isliving(user.mob)

/datum/keybinding/custom/one
	name = "custom_one"
	full_name = "Пользовательская эмоция №1"

/datum/keybinding/custom/two
	name = "custom_two"
	full_name = "Пользовательская эмоция №2"

/datum/keybinding/custom/three
	name = "custom_three"
	full_name = "Пользовательская эмоция №3"

/datum/keybinding/custom/four
	name = "custom_four"
	full_name = "Пользовательская эмоция №4"
	donor_exclusive = TRUE

/datum/keybinding/custom/five
	name = "custom_five"
	full_name = "Пользовательская эмоция №5"
	donor_exclusive = TRUE

/datum/keybinding/custom/six
	name = "custom_six"
	full_name = "Пользовательская эмоция №6"
	donor_exclusive = TRUE

/datum/keybinding/custom/seven
	name = "custom_seven"
	full_name = "Пользовательская эмоция №7"
	donor_exclusive = TRUE

/datum/keybinding/custom/eight
	name = "custom_eight"
	full_name = "Пользовательская эмоция №8"
	donor_exclusive = TRUE

/datum/keybinding/custom/nine
	name = "custom_nine"
	full_name = "Пользовательская эмоция №9"
	donor_exclusive = TRUE

/datum/keybinding/custom/ten
	name = "custom_ten"
	full_name = "Пользовательская эмоция №10"
	donor_exclusive = TRUE
