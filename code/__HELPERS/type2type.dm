/*
 * Holds procs designed to change one type of value, into another.
 * Contains:
 *			file2list
 *			angle2dir
 *			angle2text
 *			worldtime2text
 */

/// Splits the text of a file at seperator and returns them in a list.
/// returns an empty list if the file doesn't exist
/world/proc/file2list(filename, seperator="\n", trim = TRUE)
	if(trim)
		return splittext(trim(file2text(filename)),seperator)
	return splittext(file2text(filename),seperator)

/// Returns an integer value for R of R/G/B given a hex color input.
/proc/color2R(hex)
	if(!(istext(hex)))
		return

	return hex2num(copytext(hex, 2, 4)) // Returning R

/// Returns an integer value for G of R/G/B given a hex color input.
/proc/color2G(hex)
	if(!(istext(hex)))
		return

	return hex2num(copytext(hex, 4, 6)) // Returning G

/// Returns an integer value for B of R/G/B given a hex color input.
/proc/color2B(hex)
	if(!(istext(hex)))
		return

	return hex2num(copytext(hex, 6, 8)) // Returning B

/proc/text2numlist(text, delimiter="\n")
	var/list/num_list = list()
	for(var/x in splittext(text, delimiter))
		num_list += text2num(x)
	return num_list

/// Returns a string the last bit of a type, without the preceeding '/'
/proc/type2top(the_type)
	// handle the builtins manually
	if(!ispath(the_type))
		return
	switch(the_type)
		if(/datum)
			return "datum"
		if(/atom)
			return "atom"
		if(/obj)
			return "obj"
		if(/mob)
			return "mob"
		if(/area)
			return "area"
		if(/turf)
			return "turf"
		else // regex everything else (works for /proc too)
			return lowertext(replacetext("[the_type]", "[type2parent(the_type)]/", ""))

/// Turns a direction into eng text
/proc/dir2text(direction)
	switch(direction)
		if(1)
			return "north"
		if(2)
			return "south"
		if(4)
			return "east"
		if(8)
			return "west"
		if(5)
			return "northeast"
		if(6)
			return "southeast"
		if(9)
			return "northwest"
		if(10)
			return "southwest"

	return NONE

/// Turns a direction into ru text
/proc/dir2rustext(direction)
	switch(direction)
		if(1)
			return "север"
		if(2)
			return "юг"
		if(4)
			return "восток"
		if(8)
			return "запад"
		if(5)
			return "северо-восток"
		if(6)
			return "юго-восток"
		if(9)
			return "северо-запад"
		if(10)
			return "юго-запад"

	return NONE

/// Turns text into proper directions
/proc/text2dir(direction)
	switch(uppertext(direction))
		if(DIR_NAME_ENG_NORTH)
			return 1
		if(DIR_NAME_ENG_SOUTH)
			return 2
		if(DIR_NAME_ENG_EAST)
			return 4
		if(DIR_NAME_ENG_WEST)
			return 8
		if(DIR_NAME_ENG_NORTHEAST)
			return 5
		if(DIR_NAME_ENG_NORTHWEST)
			return 9
		if(DIR_NAME_ENG_SOUTHEAST)
			return 6
		if(DIR_NAME_ENG_SOUTHWEST)
			return 10

	return NONE

/// Turns text into proper directions
/proc/text2dir_rus(direction)
	switch(uppertext(direction))
		if(DIR_NAME_RUS_NORTH)
			return 1
		if(DIR_NAME_RUS_SOUTH)
			return 2
		if(DIR_NAME_RUS_EAST)
			return 4
		if(DIR_NAME_RUS_WEST)
			return 8
		if(DIR_NAME_RUS_NORTHEAST)
			return 5
		if(DIR_NAME_RUS_NORTHWEST)
			return 9
		if(DIR_NAME_RUS_SOUTHEAST)
			return 6
		if(DIR_NAME_RUS_SOUTHWEST)
			return 10

	return NONE

/// Converts an angle (degrees) into an ss13 direction
GLOBAL_LIST_INIT(modulo_angle_to_dir, list(NORTH,NORTHEAST,EAST,SOUTHEAST,SOUTH,SOUTHWEST,WEST,NORTHWEST))
#define angle2dir(X) (GLOB.modulo_angle_to_dir[round((((X%360)+382.5)%360)/45)+1])

/proc/angle2dir_cardinal(angle)
	switch(round(angle, 0.1))
		if(315.5 to 360, 0 to 45.5)
			return NORTH
		if(45.6 to 135.5)
			return EAST
		if(135.6 to 225.5)
			return SOUTH
		if(225.6 to 315.5)
			return WEST

/// returns the north-zero clockwise angle in degrees, given a direction
/proc/dir2angle(dir)
	switch(dir)
		if(NORTH)
			return 0
		if(SOUTH)
			return 180
		if(EAST)
			return 90
		if(WEST)
			return 270
		if(NORTHEAST)
			return 45
		if(SOUTHEAST)
			return 135
		if(NORTHWEST)
			return 315
		if(SOUTHWEST)
			return 225
		else
			return null

/// Returns the angle in english
/proc/angle2text(degree)
	return dir2text(angle2dir(degree))

/// Converts a blend_mode constant to one acceptable to icon.Blend()
/proc/blendMode2iconMode(blend_mode)
	switch(blend_mode)
		if(BLEND_MULTIPLY)
			return ICON_MULTIPLY
		if(BLEND_ADD)
			return ICON_ADD
		if(BLEND_SUBTRACT)
			return ICON_SUBTRACT
		else
			return ICON_OVERLAY

/// Converts a rights bitfield into a string
/proc/rights2text(rights, seperator = "")
	if(rights & R_BUILDMODE)
		. += "[seperator]+BUILDMODE"
	if(rights & R_ADMIN)
		. += "[seperator]+ADMIN"
	if(rights & R_BAN)
		. += "[seperator]+BAN"
	if(rights & R_EVENT)
		. += "[seperator]+EVENT"
	if(rights & R_SERVER)
		. += "[seperator]+SERVER"
	if(rights & R_DEBUG)
		. += "[seperator]+DEBUG"
	if(rights & R_POSSESS)
		. += "[seperator]+POSSESS"
	if(rights & R_PERMISSIONS)
		. += "[seperator]+PERMISSIONS"
	if(rights & R_STEALTH)
		. += "[seperator]+STEALTH"
	if(rights & R_REJUVINATE)
		. += "[seperator]+REJUVINATE"
	if(rights & R_VAREDIT)
		. += "[seperator]+VAREDIT"
	if(rights & R_SOUNDS)
		. += "[seperator]+SOUND"
	if(rights & R_SPAWN)
		. += "[seperator]+SPAWN"
	if(rights & R_PROCCALL)
		. += "[seperator]+PROCCALL"
	if(rights & R_MOD)
		. += "[seperator]+MODERATOR"
	if(rights & R_MENTOR)
		. += "[seperator]+MENTOR"
	if(rights & R_VIEWRUNTIMES)
		. += "[seperator]+VIEWRUNTIMES"
	if(rights & R_SKINS)
		. += "[seperator]+SKINS"
	return .

/proc/rights2text_tgui(rights)
	. = list()
	if(rights & R_BUILDMODE)
		. += R_BUILDMODE_NAME
	if(rights & R_ADMIN)
		. += R_ADMIN_NAME
	if(rights & R_BAN)
		. += R_BAN_NAME
	if(rights & R_EVENT)
		. += R_EVENT_NAME
	if(rights & R_SERVER)
		. += R_SERVER_NAME
	if(rights & R_DEBUG)
		. += R_DEBUG_NAME
	if(rights & R_POSSESS)
		. += R_POSSESS_NAME
	if(rights & R_PERMISSIONS)
		. += R_PERMISSIONS_NAME
	if(rights & R_STEALTH)
		. += R_STEALTH_NAME
	if(rights & R_REJUVINATE)
		. += R_REJUVINATE_NAME
	if(rights & R_VAREDIT)
		. += R_VAREDIT_NAME
	if(rights & R_SOUNDS)
		. += R_SOUNDS_NAME
	if(rights & R_SPAWN)
		. += R_SPAWN_NAME
	if(rights & R_PROCCALL)
		. += R_PROCCALL_NAME
	if(rights & R_MOD)
		. += R_MOD_NAME
	if(rights & R_MENTOR)
		. += R_MENTOR_NAME
	if(rights & R_VIEWRUNTIMES)
		. += R_VIEWRUNTIMES_NAME
	if(rights & R_SKINS)
		. += R_SKINS_NAME
	return .

/proc/ui_style2icon(ui_style)
	switch(ui_style)
		if(UI_THEME_RETRO)
			return 'icons/mob/screen_retro.dmi'
		if(UI_THEME_PLASMAFIRE)
			return 'icons/mob/screen_plasmafire.dmi'
		if(UI_THEME_SLIMECORE)
			return 'icons/mob/screen_slimecore.dmi'
		if(UI_THEME_OPERATIVE)
			return 'icons/mob/screen_operative.dmi'
		if(UI_THEME_WHITE)
			return 'icons/mob/screen_white.dmi'
		if(UI_THEME_MIDNIGHT)
			return 'icons/mob/screen_midnight.dmi'
		if(UI_THEME_CLOCKWORK)
			return 'icons/mob/screen_clockwork.dmi'
		else
			return 'icons/mob/screen_midnight.dmi'

/// colour formats
/proc/rgb2hsl(red, green, blue)
	red /= 255;green /= 255;blue /= 255;
	var/max = max(red,green,blue)
	var/min = min(red,green,blue)
	var/range = max-min

	var/hue=0;var/saturation=0;var/lightness=0;
	lightness = (max + min)/2
	if(range != 0)
		if(lightness < 0.5)	saturation = range/(max+min)
		else				saturation = range/(2-max-min)

		var/dred = ((max-red)/(6*max)) + 0.5
		var/dgreen = ((max-green)/(6*max)) + 0.5
		var/dblue = ((max-blue)/(6*max)) + 0.5

		if(max==red)		hue = dblue - dgreen
		else if(max==green)	hue = dred - dblue + (1/3)
		else				hue = dgreen - dred + (2/3)
		if(hue < 0)			hue++
		else if(hue > 1)	hue--

	return list(hue, saturation, lightness)

/proc/hsl2rgb(hue, saturation, lightness)
	var/red;var/green;var/blue;
	if(saturation == 0)
		red = lightness * 255
		green = red
		blue = red
	else
		var/a;var/b;
		if(lightness < 0.5)	b = lightness*(1+saturation)
		else				b = (lightness+saturation) - (saturation*lightness)
		a = 2*lightness - b

		red = round(255 * hue2rgb(a, b, hue+(1/3)))
		green = round(255 * hue2rgb(a, b, hue))
		blue = round(255 * hue2rgb(a, b, hue-(1/3)))

	return list(red, green, blue)

/proc/hue2rgb(a, b, hue)
	if(hue < 0)			hue++
	else if(hue > 1)	hue--
	if(6*hue < 1)	return (a+(b-a)*6*hue)
	if(2*hue < 1)	return b
	if(3*hue < 2)	return (a+(b-a)*((2/3)-hue)*6)
	return a

/proc/num2septext(theNum, sigFig = 7, sep=",") // default sigFig (1,000,000)
	var/finalNum = num2text(theNum, sigFig)

	/// Start from the end, or from the decimal point
	var/end = findtextEx(finalNum, ".") || length(finalNum) + 1

	/// Moving towards start of string, insert comma every 3 characters
	for(var/pos = end - 3, pos > 1, pos -= 3)
		finalNum = copytext(finalNum, 1, pos) + sep + copytext(finalNum, pos)

	return finalNum

/// heat2color functions. Adapted from: http://www.tannerhelland.com/4435/convert-temperature-rgb-algorithm-code/
/proc/heat2color(temp)
	return rgb(heat2color_r(temp), heat2color_g(temp), heat2color_b(temp))

/proc/heat2color_r(temp)
	temp /= 100
	if(temp <= 66)
		. = 255
	else
		. = max(0, min(255, 329.698727446 * (temp - 60) ** -0.1332047592))

/proc/heat2color_g(temp)
	temp /= 100
	if(temp <= 66)
		. = max(0, min(255, 99.4708025861 * log(temp) - 161.1195681661))
	else
		. = max(0, min(255, 288.1221695283 * ((temp - 60) ** -0.0755148492)))

/proc/heat2color_b(temp)
	temp /= 100
	if(temp >= 66)
		. = 255
	else
		if(temp <= 16)
			. = 0
		else
			. = max(0, min(255, 138.5177312231 * log(temp - 10) - 305.0447927307))

/// Argument: Give this a space-separated string consisting of 6 numbers. Returns null if you don't
/proc/text2matrix(matrixtext)
	var/list/matrixtext_list = splittext(matrixtext, " ")
	var/list/matrix_list = list()
	for(var/item in matrixtext_list)
		var/entry = text2num(item)
		if(entry == null)
			return null
		matrix_list += entry
	if(length(matrix_list) < 6)
		return null
	var/a = matrix_list[1]
	var/b = matrix_list[2]
	var/c = matrix_list[3]
	var/d = matrix_list[4]
	var/e = matrix_list[5]
	var/f = matrix_list[6]
	return matrix(a, b, c, d, e, f)

/**
* This is a weird one:
* It returns a list of all var names found in the string
* These vars must be in the [var_name] format
* It's only a proc because it's used in more than one place

* Takes a string and a datum
* The string is well, obviously the string being checked
* The datum is used as a source for var names, to check validity
* Otherwise every single word could technically be a variable!
**/
/proc/string2listofvars(t_string, datum/var_source)
	if(!t_string || !var_source)
		return list()

	. = list()

	var/var_found = findtext(t_string, "\[") //Not the actual variables, just a generic "should we even bother" check
	if(var_found)
		// Find var names

		// "A dog said hi [name]!"
		// splittext() --> list("A dog said hi ","name]!"
		// jointext() --> "A dog said hi name]!"
		// splittext() --> list("A","dog","said","hi","name]!")

		t_string = replacetext(t_string, "\[", "\[ ")//Necessary to resolve "word[var_name]" scenarios
		var/list/list_value = splittext(t_string, "\[")
		var/intermediate_stage = jointext(list_value, null)

		list_value = splittext(intermediate_stage, " ")
		for(var/value in list_value)
			if(findtext(value, "]"))
				value = splittext(value, "]") //"name]!" --> list("name","!")
				for(var/A in value)
					if(var_source.vars.Find(A))
						. += A

/proc/type2parent(child)
	var/string_type = "[child]"
	var/last_slash = findlasttext(string_type, "/")
	if(last_slash == 1)
		switch(child)
			if(/datum)
				return null
			if(/obj, /mob)
				return /atom/movable
			if(/area, /turf)
				return /atom
			else
				return /datum
	return text2path(copytext(string_type, 1, last_slash))

// Doesn't work with right/left hands (diffrent var is used), l_/r_ stores and PDA (they dont have icons)
/proc/slot_string_to_slot_bitfield(input_string)
	switch(input_string)
		if(ITEM_SLOT_EAR_LEFT_STRING)
			return ITEM_SLOT_EAR_LEFT
		if(ITEM_SLOT_EAR_RIGHT_STRING)
			return ITEM_SLOT_EAR_RIGHT
		if(ITEM_SLOT_BELT_STRING)
			return ITEM_SLOT_BELT
		if(ITEM_SLOT_BACK_STRING)
			return ITEM_SLOT_BACK
		if(ITEM_SLOT_CLOTH_OUTER_STRING)
			return ITEM_SLOT_CLOTH_OUTER
		if(ITEM_SLOT_CLOTH_INNER_STRING)
			return ITEM_SLOT_CLOTH_INNER
		if(ITEM_SLOT_EYES_STRING)
			return ITEM_SLOT_EYES
		if(ITEM_SLOT_MASK_STRING)
			return ITEM_SLOT_MASK
		if(ITEM_SLOT_HEAD_STRING)
			return ITEM_SLOT_HEAD
		if(ITEM_SLOT_FEET_STRING)
			return ITEM_SLOT_FEET
		if(ITEM_SLOT_ID_STRING)
			return ITEM_SLOT_ID
		if(ITEM_SLOT_NECK_STRING)
			return ITEM_SLOT_NECK
		if(ITEM_SLOT_GLOVES_STRING)
			return ITEM_SLOT_GLOVES
		if(ITEM_SLOT_SUITSTORE_STRING)
			return ITEM_SLOT_SUITSTORE
		if(ITEM_SLOT_HANDCUFFED_STRING)
			return ITEM_SLOT_HANDCUFFED
		if(ITEM_SLOT_LEGCUFFED_STRING)
			return ITEM_SLOT_LEGCUFFED
		if(ITEM_SLOT_ACCESSORY_STRING)
			return ITEM_SLOT_ACCESSORY

// Doesn't work with right/left hands (diffrent var is used), l_/r_ stores and PDA (they dont render)
/proc/slot_bitfield_to_slot_string(input_bitfield)
	switch(input_bitfield)
		if(ITEM_SLOT_EAR_LEFT)
			return ITEM_SLOT_EAR_LEFT_STRING
		if(ITEM_SLOT_EAR_RIGHT)
			return ITEM_SLOT_EAR_RIGHT_STRING
		if(ITEM_SLOT_BELT)
			return ITEM_SLOT_BELT_STRING
		if(ITEM_SLOT_BACK)
			return ITEM_SLOT_BACK_STRING
		if(ITEM_SLOT_CLOTH_OUTER)
			return ITEM_SLOT_CLOTH_OUTER_STRING
		if(ITEM_SLOT_CLOTH_INNER)
			return ITEM_SLOT_CLOTH_INNER_STRING
		if(ITEM_SLOT_GLOVES)
			return ITEM_SLOT_GLOVES_STRING
		if(ITEM_SLOT_EYES)
			return ITEM_SLOT_EYES_STRING
		if(ITEM_SLOT_MASK)
			return ITEM_SLOT_MASK_STRING
		if(ITEM_SLOT_HEAD)
			return ITEM_SLOT_HEAD_STRING
		if(ITEM_SLOT_FEET)
			return ITEM_SLOT_FEET_STRING
		if(ITEM_SLOT_ID)
			return ITEM_SLOT_ID_STRING
		if(ITEM_SLOT_NECK)
			return ITEM_SLOT_NECK_STRING
		if(ITEM_SLOT_SUITSTORE)
			return ITEM_SLOT_SUITSTORE_STRING
		if(ITEM_SLOT_HANDCUFFED)
			return ITEM_SLOT_HANDCUFFED_STRING
		if(ITEM_SLOT_LEGCUFFED)
			return ITEM_SLOT_LEGCUFFED_STRING
		if(ITEM_SLOT_ACCESSORY)
			return ITEM_SLOT_ACCESSORY_STRING

/**
 * Returns the clean name of an audio channel.
 *
 * Arguments:
 * * channel - The channel number.
 */
/proc/get_channel_name(channel)
	switch(channel)
		if(CHANNEL_GENERAL)
			return "Основные звуки"
		if(CHANNEL_LOBBYMUSIC)
			return "Музыка в лобби"
		if(CHANNEL_ADMIN)
			return "Админские MIDI"
		if(CHANNEL_VOX)
			return "Оповещения ИИ"
		if(CHANNEL_JUKEBOX)
			return "Танцевальные машины"
		if(CHANNEL_HEARTBEAT)
			return "Сердцебиение"
		if(CHANNEL_BUZZ)
			return "Белый шум"
		if(CHANNEL_AMBIENCE)
			return "Эмбиент"
		if(CHANNEL_TTS_LOCAL)
			return "TTS рядом"
		if(CHANNEL_TTS_RADIO)
			return "TTS в радиосвязи"
		if(CHANNEL_RADIO_NOISE)
			return "Звуки радиосвязи"
		if(CHANNEL_INTERACTION_SOUNDS)
			return "Звуки взаимодействия с предметами"
		if(CHANNEL_BOSS_MUSIC)
			return "Музыка боссов"

///Get the dir to the RIGHT of dir if they were on a clock
///NORTH --> NORTHEAST
/proc/get_clockwise_dir(dir)
	. = angle2dir(dir2angle(dir)+45)

///Get the dir to the LEFT of dir if they were on a clock
///NORTH --> NORTHWEST
/proc/get_anticlockwise_dir(dir)
	. = angle2dir(dir2angle(dir)-45)

/proc/reverse_direction(dir)
	switch(dir)
		if(NORTH)
			return SOUTH
		if(NORTHEAST)
			return SOUTHWEST
		if(EAST)
			return WEST
		if(SOUTHEAST)
			return NORTHWEST
		if(SOUTH)
			return NORTH
		if(SOUTHWEST)
			return NORTHEAST
		if(WEST)
			return EAST
		if(NORTHWEST)
			return SOUTHEAST
		if(UP)
			return DOWN
		if(DOWN)
			return UP

/proc/parse_zone(zone)
	switch(zone)
		if(BODY_ZONE_HEAD)
			return "голова"
		if(BODY_ZONE_CHEST)
			return "грудь"
		if(BODY_ZONE_L_ARM)
			return "левая рука"
		if(BODY_ZONE_R_ARM)
			return "правая рука"
		if(BODY_ZONE_L_LEG)
			return "левая нога"
		if(BODY_ZONE_R_LEG)
			return "правая нога"
		if(BODY_ZONE_TAIL)
			return "хвост"
		if(BODY_ZONE_WING)
			return "крылья"
		if(BODY_ZONE_PRECISE_EYES)
			return "глаза"
		if(BODY_ZONE_PRECISE_MOUTH)
			return "рот"
		if(BODY_ZONE_PRECISE_GROIN)
			return "живот"
		if(BODY_ZONE_PRECISE_L_HAND)
			return "левая кисть"
		if(BODY_ZONE_PRECISE_R_HAND)
			return "правая кисть"
		if(BODY_ZONE_PRECISE_L_FOOT)
			return "левая ступня"
		if(BODY_ZONE_PRECISE_R_FOOT)
			return "правая ступня"
		else
			stack_trace("Wrong zone input.")
