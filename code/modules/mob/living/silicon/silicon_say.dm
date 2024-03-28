/mob/living/silicon/handle_message_mode(message_mode, list/message_pieces, verb, used_radios)
	add_say_logs(src, multilingual_to_message(message_pieces))
	if(..())
		return TRUE


/mob/living/silicon/robot/handle_message_mode(message_mode, list/message_pieces, verb, used_radios)
	if(..())
		return TRUE
	if(message_mode)
		used_radios += radio
		if(!is_component_functioning("radio"))
			to_chat(src, "<span class='warning'>Your radio isn't functional at this time.</span>")
			return FALSE
		if(message_mode == "general")
			message_mode = null
		return radio.talk_into(src,message_pieces,message_mode,verb)


/mob/living/silicon/ai/handle_message_mode(message_mode, list/message_pieces, verb, used_radios)
	if(..())
		return TRUE
	if(message_mode == "department")
		used_radios += aiRadio
		return holopad_talk(message_pieces, verb)
	else if(message_mode)
		used_radios += aiRadio
		if(aiRadio.disabledAi || aiRestorePowerRoutine || stat)
			to_chat(src, "<span class='danger'>System Error - Transceiver Disabled.</span>")
			return FALSE
		if(message_mode == "general")
			message_mode = null
		return aiRadio.talk_into(src, message_pieces, message_mode, verb)


/mob/living/silicon/pai/handle_message_mode(message_mode, list/message_pieces, verb, used_radios)
	if(..())
		return TRUE
	else if(message_mode == "whisper")
		whisper_say(message_pieces)
		return TRUE
	else if(message_mode)
		if(message_mode == "general")
			message_mode = null
		used_radios += radio
		return radio.talk_into(src, message_pieces, message_mode, verb)


/mob/living/silicon/say_quote(text)
	var/ending = copytext(text, length(text))

	if(ending == "?")
		return speak_query
	else if(ending == "!")
		return speak_exclamation

	return speak_statement


/mob/living/silicon/say_understands(mob/other, datum/language/speaking = null)
	//These only pertain to common. Languages are handled by mob/say_understands()
	if(..())
		return TRUE
	else
		return iscarbon(other) || issilicon(other) || isbot(other) || isbrain(other)


//For holopads only. Usable by AI.
/mob/living/silicon/ai/proc/holopad_talk(list/message_pieces, verb)
	add_say_logs(src, multilingual_to_message(message_pieces), language = "HPAD")

	var/obj/machinery/hologram/holopad/T = current
	if(istype(T) && T.masters[src])
		var/obj/effect/overlay/holo_pad_hologram/H = T.masters[src]
		var/message_clean = combine_message(message_pieces, src)
		message_clean = replace_characters(message_clean, list("+"))

		var/message = verb_message(message_pieces, message_clean, verb)
		var/message_tts = combine_message_tts(message_pieces, src)

		if((client?.prefs.toggles2 & PREFTOGGLE_2_RUNECHAT) && can_hear())
			create_chat_message(H, message_clean, TRUE, FALSE)
		INVOKE_ASYNC(GLOBAL_PROC, /proc/tts_cast, H, src, message_tts, tts_seed, FALSE, SOUND_EFFECT_NONE)
		log_debug("holopad_talk(): [message_clean]")
		for(var/mob/M in hearers(T.loc))//The location is the object, default distance.
			M.hear_holopad_talk(message_pieces, verb, src, H)
		to_chat(src, "<i><span class='game say'>Holopad transmitted, <span class='name'>[real_name]</span> [message]</span></i>")
	else
		to_chat(src, "No holopad connected.")
		return
	return TRUE


/mob/living/silicon/ai/proc/holopad_emote(message) //This is called when the AI uses the 'me' verb while using a holopad.
	message = trim(message)

	if(!message)
		return

	var/obj/machinery/hologram/holopad/T = current
	if(istype(T) && T.masters[src])
		var/rendered = "<span class='game say'><span class='name'>[name]</span> <span class='message'>[message]</span></span>"
		to_chat(src, "<i><span class='game say'>Holopad action relayed, <span class='name'>[real_name]</span> <span class='message'>[message]</span></span></i>")

		for(var/mob/M in viewers(T.loc))
			M.show_message(rendered, EMOTE_VISIBLE)

		log_emote("(HPAD) [message]", src)
	else //This shouldn't occur, but better safe then sorry.
		to_chat(src, "No holopad connected.")
		return
	return TRUE


/mob/living/silicon/ai/emote(emote_key, type_override = null, message = null, intentional = FALSE, force_silence = FALSE, ignore_cooldowns = FALSE)
	var/obj/machinery/hologram/holopad/T = current
	if(istype(T) && T.masters[src])//Is the AI using a holopad?
		holopad_emote(message)
	else //Emote normally, then.
		..()

