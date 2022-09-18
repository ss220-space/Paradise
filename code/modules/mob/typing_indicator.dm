#define TYPING_INDICATOR_LIFETIME 30 * 10	//grace period after which typing indicator disappears regardless of text in chatbar

/mob/var/hud_typing = 0 //set when typing in an input window instead of chatline
/mob/var/typing
/mob/var/last_typed
/mob/var/last_typed_time

GLOBAL_LIST_EMPTY(typing_indicator)

/**
  * Toggles the floating chat bubble above a players head.
  *
  * Arguments:
  * * state - Should a chat bubble be shown or hidden
  * * me - Is the bubble being caused by the 'me' emote command
  */
/mob/proc/set_typing_indicator(state, me)

	if(!GLOB.typing_indicator[bubble_icon])
		GLOB.typing_indicator[bubble_icon] = image('icons/mob/talk.dmi', null, "[bubble_icon]typing", FLY_LAYER)
		var/image/I = GLOB.typing_indicator[bubble_icon]
		I.appearance_flags = APPEARANCE_UI_IGNORE_ALPHA

	if(ishuman(src))
		var/mob/living/carbon/human/H = src
		if((MUTE in H.mutations) || H.silent)
			overlays -= GLOB.typing_indicator[bubble_icon]
			return

	if(client)
		if(stat != CONSCIOUS || is_muzzled() || (client.prefs.toggles & PREFTOGGLE_SHOW_TYPING) || (me && (client.prefs.toggles2 & PREFTOGGLE_2_EMOTE_BUBBLE)))
			overlays -= GLOB.typing_indicator[bubble_icon]
		else
			if(state)
				if(!typing)
					overlays += GLOB.typing_indicator[bubble_icon]
					typing = TRUE
			else
				if(typing)
					overlays -= GLOB.typing_indicator[bubble_icon]
					typing = FALSE
			return state

/mob/verb/say_wrapper()
	set name = ".Say"
	set hidden = 1

	set_typing_indicator(TRUE)
	hud_typing = 1
	var/message = typing_input(src, "", "say (text)")
	hud_typing = 0
	set_typing_indicator(FALSE)
	if(message)
		say_verb(message)

/mob/verb/say_new_wrapper()
	set name = ".SayNew"
	set hidden = 1

	set_typing_indicator(TRUE)
	hud_typing = 1
	ui_interact(usr)

/mob/ui_interact(mob/user, ui_key, datum/tgui/ui, force_open, datum/tgui/master_ui, datum/ui_state/state)
	ui = SStgui.try_update_ui(user, src, ui_key, ui, force_open)
	if (!ui)
		ui = new(user, src, ui_key, "SayInterface", " ", 350, 135, master_ui, state)
		ui.open()

/mob/ui_data(mob/user)
	var/list/data = list()
	data["channels"] = user.get_available_channels()
	data["languages"] = user.languages
	return data

/mob/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	if(..())
		return
	if(action == "Say")
		say_verb(params["text"])
		ui.close()
		. = TRUE

/mob/ui_close(mob/user)
	. = ..()
	hud_typing = 0
	set_typing_indicator(FALSE)

/mob/verb/me_wrapper()
	set name = ".Me"
	set hidden = 1


	set_typing_indicator(TRUE, TRUE)
	hud_typing = 1
	var/message = typing_input(src, "", "me (text)")
	hud_typing = 0
	set_typing_indicator(FALSE)
	if(message)
		me_verb(message)

/mob/verb/whisper_wrapper()
	set name = ".Whisper"
	set hidden = 1

	set_typing_indicator(1)
	hud_typing = 1
	var/message = typing_input(src, "", "whisper (text)")
	hud_typing = 0
	set_typing_indicator(0)
	if(message)
		whisper(message)

/mob/proc/handle_typing_indicator()
	if(client)
		if(!(client.prefs.toggles & PREFTOGGLE_SHOW_TYPING) && !hud_typing)
			var/temp = winget(client, "input", "text")

			if(temp != last_typed)
				last_typed = temp
				last_typed_time = world.time

			if(world.time > last_typed_time + TYPING_INDICATOR_LIFETIME)
				set_typing_indicator(FALSE)
				return
			if(length(temp) > 5 && findtext(temp, "Say \"", 1, 7))
				set_typing_indicator(TRUE)
			else if(length(temp) > 3 && findtext(temp, "Me ", 1, 5))
				set_typing_indicator(TRUE, TRUE)

			else
				set_typing_indicator(FALSE)

/client/verb/typing_indicator()
	set name = "Show/Hide Typing Indicator"
	set category = "Preferences"
	set desc = "Toggles showing an indicator when you are typing a message."
	prefs.toggles ^= PREFTOGGLE_SHOW_TYPING
	prefs.save_preferences(src)
	to_chat(src, "You will [(prefs.toggles & PREFTOGGLE_SHOW_TYPING) ? "no longer" : "now"] display a typing indicator.")

	// Clear out any existing typing indicator.
	if(prefs.toggles & PREFTOGGLE_SHOW_TYPING)
		if(istype(mob))
			mob.set_typing_indicator(FALSE)

	SSblackbox.record_feedback("tally", "toggle_verbs", 1, "Toggle Typing Indicator (Speech)") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!


/client/verb/emote_indicator()
	set name = "Show/Hide Emote Typing Indicator"
	set category = "Preferences"
	set desc = "Toggles showing an indicator when you are typing an emote."
	prefs.toggles2 ^= PREFTOGGLE_2_EMOTE_BUBBLE
	prefs.save_preferences(src)
	to_chat(src, "You will [(prefs.toggles2 & PREFTOGGLE_2_EMOTE_BUBBLE) ? "no longer" : "now"] display a typing indicator for emotes.")

	SSblackbox.record_feedback("tally", "toggle_verbs", 1, "Toggle Typing Indicator (Emote)") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

#undef TYPING_INDICATOR_LIFETIME
