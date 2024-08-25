/obj/item/taperecorder
	name = "universal recorder"
	desc = "A device that can record to cassette tapes, and play them. It automatically translates the content in playback."
	icon = 'icons/obj/device.dmi'
	icon_state = "taperecorder_empty"
	item_state = "analyzer"
	w_class = WEIGHT_CLASS_SMALL
	slot_flags = ITEM_SLOT_BELT
	materials = list(MAT_METAL = 60, MAT_GLASS = 30)
	force = 2
	throwforce = 0
	drop_sound = 'sound/items/handling/taperecorder_drop.ogg'
	pickup_sound = 'sound/items/handling/taperecorder_pickup.ogg'
	tts_seed = "Xenia"
	/// If its currently recording.
	var/recording = FALSE
	/// If its playing back auto via atom_say.
	var/playing = FALSE
	/// The amount of time between something said during playback.
	var/playsleepseconds = 0
	/// The tape we are recording to.
	var/obj/item/tape/mytape
	/// The next worldtime we'll be able to print.
	var/cooldown = 0
	/// Self-explanatory.
	var/starts_with_tape = TRUE
	/// Sound loop that plays when recording or playing back.
	var/datum/looping_sound/tape_recorder_hiss/soundloop


/obj/item/taperecorder/empty
	starts_with_tape = FALSE


/obj/item/taperecorder/New()
	..()
	if(starts_with_tape)
		mytape = new /obj/item/tape/random(src)
		update_icon(UPDATE_ICON_STATE)
	soundloop = new(list(src))


/obj/item/taperecorder/Destroy()
	QDEL_NULL(mytape)
	QDEL_NULL(soundloop)
	return ..()


/obj/item/taperecorder/examine(mob/user)
	. = ..()
	if(in_range(user, src) && mytape)
		if(mytape.ruined)
			. += span_notice("[mytape]'s internals are unwound.'.")
		if(mytape.max_capacity <= mytape.used_capacity)
			. += span_notice("[mytape] is full.")
		else if((mytape.remaining_capacity % 60) == 0) // if there is no seconds (modulo = 0), then only show minutes
			. += span_notice("[mytape] has [mytape.remaining_capacity / 60] minutes remaining.")
		else
			if(mytape.used_capacity >= mytape.max_capacity - 60)
				. += span_notice("[mytape] has [mytape.remaining_capacity] seconds remaining.") // to avoid having 0 minutes
			else
				. += span_notice("[mytape] has [seconds_to_time(mytape.remaining_capacity)] remaining.")
		. += span_info("<b>Alt-Click</b> to access the tape.")


/obj/item/taperecorder/proc/update_sound()
	if(!playing && !recording)
		soundloop.stop()
	else
		soundloop.start()


/obj/item/taperecorder/update_icon_state()
	if(!mytape)
		icon_state = "taperecorder_empty"
	else if(recording)
		icon_state = "taperecorder_recording"
	else if(playing)
		icon_state = "taperecorder_playing"
	else
		icon_state = "taperecorder_idle"


/obj/item/taperecorder/fire_act(datum/gas_mixture/air, exposed_temperature, exposed_volume, global_overlay = TRUE)
	mytape?.ruin() //Fires destroy the tape
	return ..()


/obj/item/taperecorder/attackby(obj/item/I, mob/user, params)
	if(istype(I, /obj/item/tape))
		add_fingerprint(user)
		if(mytape)
			to_chat(user, span_warning("There is already [mytape] inserted!"))
			return ATTACK_CHAIN_PROCEED
		if(!user.drop_transfer_item_to_loc(I, src))
			return ..()
		mytape = I
		to_chat(user, span_notice("You insert [I] into [src]."))
		playsound(loc, 'sound/items/taperecorder/taperecorder_close.ogg', 50, FALSE)
		update_icon(UPDATE_ICON_STATE)
		return ATTACK_CHAIN_BLOCKED_ALL

	return ..()


/obj/item/taperecorder/attack_hand(mob/user)
	if(loc == user && mytape)
		if(!user.is_in_hands(src))
			..()
			return
		eject(user)
		return
	..()


/obj/item/taperecorder/attack_self(mob/user)
	if(!mytape || mytape.ruined)
		return
	if(recording)
		stop()
	else
		record()


/obj/item/taperecorder/AltClick(mob/living/user)
	if(istype(user) && mytape && !user.incapacitated() && !HAS_TRAIT(user, TRAIT_HANDS_BLOCKED) && Adjacent(user))
		var/list/options = list( "Playback Tape" = image(icon = 'icons/obj/device.dmi', icon_state = "taperecorder_playing"),
						"Print Transcript" = image(icon = 'icons/obj/bureaucracy.dmi', icon_state = "paper_words"),
						"Eject Tape" = image(icon = 'icons/obj/device.dmi', icon_state = "[mytape.icon_state]")
						)
		var/choice = show_radial_menu(user, src, options, require_near = TRUE)
		if(!choice || user.incapacitated())
			return
		switch(choice)
			if("Playback Tape")
				play(user)
			if("Print Transcript")
				print_transcript(user)
			if("Eject Tape")
				eject(user)


/obj/item/taperecorder/proc/recorder_say(message, datum/tape_piece/record_datum)
	if(record_datum)
		tts_seed = record_datum.tts_seed
		atom_say_verb = record_datum.message_verb || "says"
		atom_say("[record_datum.message]")
	else
		tts_seed = initial(tts_seed)
		atom_say_verb = "says"
		atom_say("[message]")


/obj/item/taperecorder/proc/eject(mob/user)
	if(mytape)
		playsound(src, 'sound/items/taperecorder/taperecorder_open.ogg', 50, FALSE)
		to_chat(user, span_notice("You remove [mytape] from [src]."))
		stop()
		mytape.forceMove_turf()
		user.put_in_hands(mytape, ignore_anim = FALSE)
		mytape = null
		update_icon(UPDATE_ICON_STATE)


/obj/item/taperecorder/proc/record()
	if(!mytape || mytape.ruined)
		return
	if(recording)
		return
	if(playing)
		return

	playsound(src, 'sound/items/taperecorder/taperecorder_play.ogg', 50, FALSE)

	if(mytape.used_capacity < mytape.max_capacity)
		recording = TRUE
		recorder_say("Запись началась.")
		update_sound()
		update_icon(UPDATE_ICON_STATE)
		mytape.timestamp += mytape.used_capacity
		var/datum/tape_piece/piece = new()
		piece.time = mytape.used_capacity
		piece.speaker_name = null
		piece.message = "Запись началась."
		piece.message_verb = null
		piece.tts_seed = initial(tts_seed)
		mytape.storedinfo += piece
		var/used = mytape.used_capacity	//to stop runtimes when you eject the tape
		var/max = mytape.max_capacity
		for(used, used < max)
			if(recording == FALSE)
				break
			mytape.used_capacity++
			used++
			mytape.remaining_capacity = mytape.max_capacity - mytape.used_capacity
			sleep(1 SECONDS)
		stop()
	else
		recorder_say("Кассета заполнена.")
		playsound(src, 'sound/items/taperecorder/taperecorder_stop.ogg', 50, FALSE)


/obj/item/taperecorder/proc/stop(playback_override = FALSE)
	if(recording)
		mytape.timestamp += mytape.used_capacity
		var/datum/tape_piece/piece = new()
		piece.time = mytape.used_capacity
		piece.speaker_name = null
		piece.message = "Запись остановлена."
		piece.message_verb = null
		piece.tts_seed = initial(tts_seed)
		mytape.storedinfo += piece
		playsound(src, 'sound/items/taperecorder/taperecorder_stop.ogg', 50, FALSE)
		recorder_say("Запись остановлена.")
		recording = FALSE
	else if(playing)
		playsound(src, 'sound/items/taperecorder/taperecorder_stop.ogg', 50, FALSE)
		if(!playback_override)
			recorder_say("Проигрывание остановлено.")
		playing = FALSE
	update_icon(UPDATE_ICON_STATE)
	update_sound()


/obj/item/taperecorder/proc/play(mob/user)
	if(!mytape || mytape.ruined)
		return
	if(recording)
		return
	if(playing)
		stop()
		return

	if(!length(mytape.storedinfo))
		recorder_say("Кассета пуста.")
		playsound(src, 'sound/items/taperecorder/taperecorder_play.ogg', 50, FALSE)
		playsound(src, 'sound/items/taperecorder/taperecorder_stop.ogg', 50, FALSE)
		return

	playing = TRUE
	update_icon(UPDATE_ICON_STATE)
	update_sound()
	recorder_say("Проигрывание началось.")
	playsound(src, 'sound/items/taperecorder/taperecorder_play.ogg', 50, FALSE)
	var/used = mytape.used_capacity	//to stop runtimes when you eject the tape
	var/max = mytape.max_capacity
	for(var/i = 1, used <= max) // <= to let it play if the tape is full
		sleep(playsleepseconds)
		if(!mytape)
			break
		if(!playing)
			break
		if(length(mytape.storedinfo) < i)
			recorder_say("Конец записи.")
			break

		recorder_say(record_datum = mytape.storedinfo[i])

		if(length(mytape.storedinfo) < i + 1)
			playsleepseconds = 3 SECONDS
		else
			playsleepseconds = (mytape.timestamp[i + 1] - mytape.timestamp[i]) SECONDS
		if(playsleepseconds > 10 SECONDS)	// 10 seconds is a good number to prevent spam
			sleep(3 SECONDS)
			recorder_say("Пропуск [playsleepseconds / 10] секунд тишины.")
			playsleepseconds = 3 SECONDS
		i++

	stop(playback_override = TRUE)


/obj/item/taperecorder/hear_talk(mob/living/M, list/message_pieces)
	var/msg = multilingual_to_message(message_pieces)
	if(mytape && recording)
		var/ending = copytext(msg, length(msg))
		mytape.timestamp += mytape.used_capacity
		var/datum/tape_piece/piece = new()
		piece.time = mytape.used_capacity
		piece.speaker_name = M.name
		piece.message = msg
		piece.message_verb = "says"
		piece.tts_seed = M.tts_seed

		if(M.AmountStuttering())
			piece.message_verb = "stammers"
		else if(M.getBrainLoss() >= 60)
			piece.message_verb = "gibbers"
		else if(ending == "?")
			piece.message_verb = "asks"
		else if(ending == "!")
			piece.message_verb = "exclaims"
		mytape.storedinfo += piece


/obj/item/taperecorder/hear_message(mob/living/M, msg)
	if(mytape && recording)
		mytape.timestamp += mytape.used_capacity
		var/datum/tape_piece/piece = new()
		piece.time = mytape.used_capacity
		piece.speaker_name = M.name
		piece.message = msg
		piece.message_verb = null
		piece.tts_seed = initial(tts_seed)
		mytape.storedinfo += piece


/obj/item/taperecorder/proc/print_transcript(mob/user)
	if(!mytape)
		return
	if(world.time < cooldown)
		to_chat(user, span_notice("The recorder can't print that fast!"))
		return
	if(recording || playing)
		return
	if(!length(mytape.storedinfo))
		to_chat(user, span_notice("There is nothing recorded on [mytape]!"))
		return

	recorder_say("Распечатка в процессе...")
	playsound(loc, 'sound/goonstation/machines/printer_thermal.ogg', 50, 1)
	flick("taperecorder_anim", src)

	sleep(3 SECONDS) //prevent paper from being printed until the end of the animation
	if(QDELETED(src))
		return

	var/obj/item/paper/transcript = new /obj/item/paper(drop_location())

	var/list/paper_info = list("<B>Transcript:</B><BR><BR>")
	for(var/i = 1, length(mytape.storedinfo) >= i, i++)
		var/datum/tape_piece/piece = mytape.storedinfo[i]
		paper_info += "\[[time2text(piece.time * 10,"mm:ss")]\] "
		if(piece.speaker_name)
			paper_info += "[piece.speaker_name] "
		if(piece.message_verb)
			paper_info += "[piece.message_verb], \"[replace_characters(piece.message, list("+"))]\"<BR>"
		else
			paper_info += "[replace_characters(piece.message, list("+"))]<BR>"

	transcript.info = paper_info.Join("")
	transcript.name = "paper- 'Transcript'"
	cooldown = world.time + 3 SECONDS

	if(!QDELETED(user) && in_range(user, transcript))
		user.put_in_hands(transcript, ignore_anim = FALSE)


/obj/item/tape
	name = "tape"
	desc = "A magnetic tape that can hold up to ten minutes of content."
	icon = 'icons/obj/device.dmi'
	icon_state = "tape_white"
	item_state = "analyzer"
	w_class = WEIGHT_CLASS_TINY
	materials = list(MAT_METAL = 20, MAT_GLASS = 5)
	force = 1
	throwforce = 0
	drop_sound = 'sound/items/handling/tape_drop.ogg'
	pickup_sound = 'sound/items/handling/tape_pickup.ogg'
	var/max_capacity = 600
	var/used_capacity = 0
	var/remaining_capacity = 600
	var/list/storedinfo = list()
	var/list/timestamp = list()
	var/ruined = FALSE


/obj/item/tape/random/New()
	..()
	icon_state = "tape_[pick("white", "blue", "red", "yellow", "purple")]"


/obj/item/tape/examine(mob/user)
	. = ..()
	if(in_range(user, src))
		if(ruined)
			. += span_notice("It's tape is all pulled out, it looks it could be <b>screwed</b> back into place.")
		else if(max_capacity <= used_capacity)
			. += span_notice("It is full.")
		else if((remaining_capacity % 60) == 0) // if there is no seconds (modulo = 0), then only show minutes
			. += span_notice("It has [remaining_capacity / 60] minutes remaining.")
		else
			if(used_capacity >= (max_capacity - 60))
				. += span_notice("It has [remaining_capacity] seconds remaining.") // to avoid having 0 minutes
			else
				. += span_notice("It has [seconds_to_time(remaining_capacity)] remaining.")


/obj/item/tape/update_overlays()
	. = ..()
	if(ruined)
		. += "ribbonoverlay"


/obj/item/tape/fire_act(datum/gas_mixture/air, exposed_temperature, exposed_volume, global_overlay = TRUE)
	..()
	ruin()


/obj/item/tape/attackby(obj/item/I, mob/user, params)
	if(is_pen(I))
		rename_interactive(user, I)
		return ATTACK_CHAIN_PROCEED_SUCCESS
	return ..()


/obj/item/tape/screwdriver_act(mob/living/user, obj/item/I)
	. = TRUE
	if(!ruined)
		return .
	to_chat(user, span_notice("You start winding the tape back in..."))
	if(!I.use_tool(src, user, 12 SECONDS, volume = I.tool_volume) || !ruined)
		return .
	to_chat(user, span_notice("You wind the tape back in!"))
	fix()


/obj/item/tape/attack_self(mob/user)
	if(!ruined)
		ruin(user)


/obj/item/tape/proc/ruin(mob/user)
	if(user)
		to_chat(user, span_notice("You start pulling the tape out."))
		if(!do_after(user, 1 SECONDS, user))
			return
		to_chat(user, span_notice("You pull the tape out of [src]."))

	if(!ruined)
		ruined = TRUE
		update_icon(UPDATE_OVERLAYS)


/obj/item/tape/proc/fix()
	if(ruined)
		ruined = FALSE
		update_icon(UPDATE_OVERLAYS)


/obj/item/tape/verb/wipe()
	set name = "Wipe Tape"
	set category = "Object"
	set src in view(1)

	var/mob/living/carbon/user = usr
	if(!istype(user) || user.incapacitated() || HAS_TRAIT(user, TRAIT_HANDS_BLOCKED))
		return
	if(ruined)
		return

	to_chat(usr, span_notice("You erase the data from [src]."))
	used_capacity = 0
	storedinfo.Cut()
	timestamp.Cut()


/**
 * Datum used to operate with message pieces.
 */
/datum/tape_piece
	var/time
	var/speaker_name
	var/message
	var/message_verb
	var/tts_seed
	var/transcript


