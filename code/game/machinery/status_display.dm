GLOBAL_LIST_EMPTY(status_displays)

GLOBAL_LIST_INIT(statdisp_picture_colors, list(
	"" = COLOR_GRAY,
	"outline" = COLOR_GRAY,
	"ai_awesome" = COLOR_DEEP_SKY_BLUE,
	"ai_beer" = COLOR_DEEP_SKY_BLUE,
	"ai_bsod" = COLOR_CYAN_BLUE,
	"ai_confused" = COLOR_DEEP_SKY_BLUE,
	"ai_dwarf" = COLOR_DEEP_SKY_BLUE,
	"ai_facepalm" = COLOR_WHEAT,
	"ai_fishtank" = COLOR_BLUE_LIGHT,
	"ai_friend" = COLOR_TITANIUM,
	"ai_happy" = COLOR_DEEP_SKY_BLUE,
	"ai_neutral" = COLOR_DEEP_SKY_BLUE,
	"ai_off" = COLOR_GRAY,
	"ai_plump" = COLOR_DEEP_SKY_BLUE,
	"ai_sad" = COLOR_DEEP_SKY_BLUE,
	"ai_surprised" = COLOR_DEEP_SKY_BLUE,
	"ai_tribunal" = COLOR_WHITE,
	"ai_tribunal_malf" = COLOR_WHITE,
	"ai_trollface" = COLOR_BLUE_LIGHT,
	"ai_unsure" = COLOR_DEEP_SKY_BLUE,
	"ai_urist" = COLOR_BLUE_LIGHT,
	"ai_veryhappy" = COLOR_DEEP_SKY_BLUE,
	"biohazard" = COLOR_RED_LIGHT,
	"default" = COLOR_CYAN_BLUE,
	"lockdown" = COLOR_YELLOW,
	"redalert" = COLOR_RED_LIGHT,
	"gammaalert" = COLOR_YELLOW_GRAY,
	"deltaalert" = COLOR_ORANGE,
	"epsilonalert" = COLOR_WHEAT,
	"radiation" = COLOR_YELLOW_GRAY
))

// Status display
// (formerly Countdown timer display)

// Use to show shuttle ETA/ETD times
// Alert status
// And arbitrary messages set by comms computer
/obj/machinery/status_display
	icon = 'icons/obj/status_display.dmi'
	icon_state = "frame"
	name = "дисплей статуса"
	anchored = TRUE
	density = FALSE
	use_power = IDLE_POWER_USE
	idle_power_usage = 10
	maptext_height = 26
	maptext_width = 32
	maptext_y = -1
	/// Status display mode
	VAR_PRIVATE/mode = STATUS_DISPLAY_TRANSFER_SHUTTLE_TIME
	/// Icon_state of alert picture
	var/picture_state
	/// Are we spooked?
	var/spookymode = FALSE
	/// Line 1 of a custom message, if any
	var/message1
	/// Line 2 of a custom message, if any
	var/message2
	/// Is this a supply display?
	var/is_supply = FALSE
	/// Track if Friend Computer mode
	var/friendc = FALSE
	/// Display indexes for scrolling messages, or 0 if non-scrolling
	var/index1
	var/index2


/obj/machinery/status_display/Initialize()
	. = ..()
	GLOB.status_displays |= src
	update_icon(UPDATE_OVERLAYS)


/obj/machinery/status_display/Destroy()
	GLOB.status_displays -= src
	return ..()


/obj/machinery/status_display/update_overlays()
	. = ..()
	underlays.Cut()

	if(stat & NOPOWER)
		return

	if(picture_state)
		. += picture_state

	underlays += emissive_appearance(icon, "lightmask", src)


/obj/machinery/status_display/power_change(forced = FALSE)
	if(!..())
		return
	update_display_light()
	update_icon(UPDATE_OVERLAYS)


/obj/machinery/status_display/process()
	if(stat & NOPOWER)
		remove_display()
		return

	if(spookymode)
		spookymode = FALSE
		remove_display()
		return

	update()


/obj/machinery/status_display/emp_act(severity)
	if(stat & (BROKEN|NOPOWER))
		..(severity)
		return
	set_picture("ai_bsod")
	..(severity)


/obj/machinery/status_display/flicker()
	if(stat & (NOPOWER | BROKEN))
		return FALSE

	spookymode = TRUE
	return TRUE


// set what is displayed
/obj/machinery/status_display/proc/update()
	if(friendc)
		if(picture_state != "ai_friend")
			mode = STATUS_DISPLAY_ALERT
			set_picture("ai_friend")
		return

	switch(mode)
		// Blank
		if(STATUS_DISPLAY_BLANK)
			remove_display()
			return

		// Emergency shuttle timer
		if(STATUS_DISPLAY_TRANSFER_SHUTTLE_TIME)
			var/use_warn = FALSE

			if(SSshuttle.emergency && SSshuttle.emergency.timer)
				use_warn = TRUE
				message1 = "-[SSshuttle.emergency.getModeStr()]-"
				message2 = SSshuttle.emergency.getTimerStr()

				if(length(message2) > DISPLAY_CHARS_PER_LINE)
					message2 = "Error!"

			else
				message1 = "ВРЕМЯ"
				message2 = station_time_timestamp("hh:mm")
			update_display(message1, message2, use_warn)

		// Custom messages
		if(STATUS_DISPLAY_MESSAGE)
			var/line1
			var/line2

			if(!index1)
				line1 = message1
			else
				line1 = copytext_char(message1+"|"+message1, index1, index1+DISPLAY_CHARS_PER_LINE)
				var/message1_len = length_char(message1)

				index1 += DISPLAY_SCROLL_SPEED

				if(index1 > message1_len)
					index1 -= message1_len

			if(!index2)
				line2 = message2

			else
				line2 = copytext_char(message2+"|"+message2, index2, index2+DISPLAY_CHARS_PER_LINE)
				var/message2_len = length_char(message2)

				index2 += DISPLAY_SCROLL_SPEED

				if(index2 > message2_len)
					index2 -= message2_len

			update_display(line1, line2)

		// Just time
		if(STATUS_DISPLAY_TIME)
			message1 = "ВРЕМЯ"
			message2 = station_time_timestamp("hh:mm")
			update_display(message1, message2)


/obj/machinery/status_display/examine(mob/user)
	. = ..()
	if(stat & (BROKEN|NOPOWER))
		return
	if(mode != STATUS_DISPLAY_BLANK && mode != STATUS_DISPLAY_ALERT)
		. += span_notice("На дисплее написано: <br>\t[sanitize(message1)]<br>\t[sanitize(message2)].")
	if(mode == STATUS_DISPLAY_ALERT)
		. += span_notice("Текущий уровень угрозы: [get_security_level_ru()]. ")


/obj/machinery/status_display/proc/set_message(m1, m2)
	if(m1)
		index1 = (length_char(m1) > DISPLAY_CHARS_PER_LINE)
		message1 = m1
	else
		message1 = ""
		index1 = 0

	if(m2)
		index2 = (length_char(m2) > DISPLAY_CHARS_PER_LINE)
		message2 = m2
	else
		message2 = ""
		index2 = 0


// Always call update() after using this
/obj/machinery/status_display/proc/set_mode(newmode)
	mode = newmode
	if(mode == STATUS_DISPLAY_ALERT)
		// Its an alert image, clear all text
		set_message(null, null)
	else
		// Not an alert image, clear any leftover image
		set_picture(null)


/obj/machinery/status_display/proc/set_picture(state)
	maptext = null
	picture_state = state
	update_icon(UPDATE_OVERLAYS)


/obj/machinery/status_display/proc/remove_display()
	picture_state = null
	update_icon(UPDATE_OVERLAYS)


/obj/machinery/status_display/proc/update_display(line1, line2, warning = FALSE)
	line1 = uppertext(line1)
	line2 = uppertext(line2)
	var/new_text = {"<div style="font-size:[DISPLAY_FONT_SIZE];color:[warning ? DISPLAY_WARNING_FONT_COLOR : DISPLAY_FONT_COLOR];font:'[DISPLAY_FONT_STYLE]';text-align:center;" valign="top">[line1]<br>[line2]</div>"}
	if(maptext != new_text)
		maptext = new_text
		update_display_light()


/obj/machinery/status_display/proc/update_display_light()
	if(stat & (NOPOWER|BROKEN))
		set_light_on(FALSE)
		return

	if(mode == STATUS_DISPLAY_ALERT)
		set_light(1, 1, GLOB.statdisp_picture_colors[picture_state], l_on = TRUE)
	else
		var/lum = 0.4
		if(index1)
			lum += 0.4
		if(index2)
			lum += 0.4
		set_light(1, lum, (SSshuttle.emergency && SSshuttle.emergency.timer) ? COLOR_SUN : COLOR_LIGHT_CYAN, l_on = TRUE)

GLOBAL_LIST_EMPTY(ai_displays)

/obj/machinery/ai_status_display
	icon = 'icons/obj/status_display.dmi'
	icon_state = "frame"
	name = "AI display"
	anchored = TRUE
	density = FALSE
	/// Current mode
	var/mode = AI_DISPLAY_MODE_BLANK
	/// Target icon state
	var/picture_state
	/// Current emotion, used to calculate an icon state
	var/emotion = "Neutral"

/obj/machinery/ai_status_display/Initialize(mapload)
	. = ..()
	GLOB.ai_displays |= src


/obj/machinery/ai_status_display/Destroy()
	GLOB.ai_displays -= src
	return ..()


/obj/machinery/ai_status_display/attack_ai(mob/living/silicon/ai/user)
	if(isAI(user))
		user.ai_statuschange()


/obj/machinery/ai_status_display/emp_act(severity)
	if(!(stat & (BROKEN|NOPOWER)))
		mode = AI_DISPLAY_MODE_BSOD
	update_icon(UPDATE_OVERLAYS)
	..(severity)


/obj/machinery/ai_status_display/power_change(forced = FALSE)
	. = ..()
	if(.)
		update_icon(UPDATE_OVERLAYS)


/obj/machinery/ai_status_display/flicker()
	if(stat & (NOPOWER|BROKEN))
		return FALSE

	emotion = "Tribunal Malf"
	update_icon(UPDATE_OVERLAYS)
	return TRUE


/obj/machinery/ai_status_display/update_overlays()
	. = ..()

	var/new_display

	underlays.Cut()

	if(stat & NOPOWER)
		return

	switch(mode)
		// Blank
		if(AI_DISPLAY_MODE_BLANK)
			new_display = "ai_off"

		// AI emoticon
		if(AI_DISPLAY_MODE_EMOTE)
			switch(emotion)
				if("Very Happy")
					new_display = "ai_veryhappy"
				if("Happy")
					new_display = "ai_happy"
				if("Neutral")
					new_display = "ai_neutral"
				if("Unsure")
					new_display = "ai_unsure"
				if("Confused")
					new_display = "ai_confused"
				if("Sad")
					new_display = "ai_sad"
				if("Surprised")
					new_display = "ai_surprised"
				if("Upset")
					new_display = "ai_upset"
				if("Angry")
					new_display = "ai_angry"
				if("BSOD")
					new_display = "ai_bsod"
				if("Blank")
					new_display = "ai_off"
				if("Problems?")
					new_display = "ai_trollface"
				if("Awesome")
					new_display = "ai_awesome"
				if("Dorfy")
					new_display = "ai_urist"
				if("Facepalm")
					new_display = "ai_facepalm"
				if("Friend Computer")
					new_display = "ai_friend"
				if("Beer")
					new_display = "ai_beer"
				if("Dwarf")
					new_display = "ai_dwarf"
				if("Fish Tank")
					new_display = "ai_fishtank"
				if("Plump")
					new_display = "ai_plump"
				if("Tribunal")
					new_display = "ai_tribunal"
				if("Tribunal Malf")
					new_display = "ai_tribunal_malf"

		// BSOD
		if(AI_DISPLAY_MODE_BSOD)
			new_display = "ai_bsod"

	. += new_display
	underlays += emissive_appearance(icon, "lightmask", src)

