/*
 * Crayons
 */
#define SPRAYCAN_MODE_TEXT "text"
#define SPRAYCAN_MODE_GRAFFITI "graffiti"
#define SPRAYCAN_MODE_RUNE "rune"
#define SPRAYCAN_MODE_LETTERS "letters"

#define SPRAYCAN_OUTLINE_DARK "dark"
#define SPRAYCAN_OUTLINE_LIGHT "light"
#define SPRAYCAN_OUTLINE_NONE "none"
#define SPRAYCAN_OUTLINE_CUSTOM "custom"

#define SPRAYCAN_MAX_TEXT_LENGTH 64
#define SPRAYCAN_MIN_ANGLE -180
#define SPRAYCAN_MAX_ANGLE 180
#define SPRAYCAN_MIN_SCALE 0.25
#define SPRAYCAN_MAX_SCALE 2
#define SPRAYCAN_SCALE_STEP 0.25
#define SPRAYCAN_TILE_SIZE 32
#define SPRAYCAN_HALF_TILE 16
#define SPRAYCAN_ALLOWED_CHARS "АБВГДЕЁЖЗИЙКЛМНОПРСТУФХЦЧШЩЪЫЬЭЮЯабвгдеёжзийклмнопрстуфхцчшщъыьэюяABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789 .,!?-+:;()/\"'№=*#&%$@^~<>"

#define NORMAL_CRAYONS_USES 42
#define BETTER_CRAYONS_USES 60 //0 for unlimited uses
#define SINGLEUSE_CRAYONS_USES 1
/obj/item/toy/crayon
	name = "crayon"
	desc = "A colourful crayon. Looks tasty. Mmmm..."
	icon = 'icons/obj/crayons.dmi'
	icon_state = "crayonred"
	w_class = WEIGHT_CLASS_TINY
	slot_flags = ITEM_SLOT_BELT|ITEM_SLOT_EARS
	attack_verb = list("атаковал", "тыкнул")
	interaction_flags_atom = parent_type::interaction_flags_atom | INTERACT_ATOM_IGNORE_MOBILITY
	var/colour = COLOR_RED
	var/drawtype = "rune"
	var/static/list/graffiti = list(
		"body",
		"amyjon",
		"face",
		"matt",
		"revolution",
		"engie",
		"guy",
		"end",
		"dwarf",
		"uboa",
		"up",
		"down",
		"left",
		"right",
		"heart",
		"borgsrogue",
		"voxpox",
		"shitcurity",
		"catbeast",
		"hieroglyphs1",
		"hieroglyphs2",
		"hieroglyphs3",
		"security",
		"syndicate1",
		"syndicate2",
		"nanotrasen",
		"lie",
		"valid",
		"arrowleft",
		"arrowright",
		"arrowup",
		"arrowdown",
		"chicken",
		"hailcrab",
		"brokenheart",
		"peace",
		"scribble",
		"scribble2",
		"scribble3",
		"skrek",
		"squish",
		"tunnelsnake",
		"yip",
		"youaredead",
		"cyka",
		"antilizard",
		"Tunnel",
		"Gib",
		"space",
		"prolizard",
		"no_cake",
	)
	var/list/letters = list("a","b","c","d","e","f","g","h","i","j","k","l","m","n","o","p","q","r","s","t","u","v","w","x","y","z")
	var/uses = NORMAL_CRAYONS_USES
	var/instant = 0
	var/colourName = "red" //for updateIcon purposes
	var/dat = {"<!DOCTYPE html><meta charset="UTF-8">"}
	var/busy = FALSE
	var/list/validSurfaces = list(/turf/simulated/floor)
	var/can_change_colour = FALSE

/obj/item/toy/crayon/suicide_act(mob/user)
	user.visible_message(span_suicide("[user] is jamming the [name] up [user.p_their()] nose and into [user.p_their()] brain. It looks like [user.p_theyre()] trying to commit suicide."))
	return BRUTELOSS|OXYLOSS

/obj/item/toy/crayon/Initialize(mapload)
	. = ..()
	drawtype = pick(pick(graffiti), pick(letters), "rune[rand(1, 8)]")

/obj/item/toy/crayon/attack_self(mob/living/user as mob)
	update_window(user)

/obj/item/toy/crayon/proc/update_window(mob/living/user as mob)
	dat += "<center><h2>Currently selected: [drawtype]</h2><br>"
	dat += "<a href='byond://?src=[UID()];type=random_letter'>Random letter</a><a href='byond://?src=[UID()];type=letter'>Pick letter</a>"
	dat += "<hr>"
	dat += "<h3>Runes:</h3><br>"
	dat += "<a href='byond://?src=[UID()];type=random_rune'>Random rune</a>"
	for(var/i = 1; i <= 8; i++)
		dat += "<a href='byond://?src=[UID()];type=rune[i]'>Rune [i]</a>"
		if(!((i + 1) % 3)) //3 buttons in a row
			dat += "<br>"
	dat += "<hr>"
	graffiti.Find(null)
	dat += "<h3>Graffiti:</h3><br>"
	dat += "<a href='byond://?src=[UID()];type=random_graffiti'>Random graffiti</a>"
	var/c = 1
	for(var/T in graffiti)
		dat += "<a href='byond://?src=[UID()];type=[T]'>[T]</a>"
		if(!((c + 1) % 3)) //3 buttons in a row
			dat += "<br>"
		c++
	dat += "<hr>"
	var/datum/browser/popup = new(user, "crayon", name, 300, 500)
	popup.set_content(dat)
	popup.open()
	dat = {"<meta charset="UTF-8">"}

/obj/item/toy/crayon/Topic(href, href_list, hsrc)
	var/temp = "a"
	switch(href_list["type"])
		if("random_letter")
			temp = pick(letters)
		if("letter")
			temp = tgui_input_list(usr, "Choose the letter.", "Scribbles", letters)
		if("random_rune")
			temp = "rune[rand(1,10)]"
		if("random_graffiti")
			temp = pick(graffiti)
		else
			temp = href_list["type"]
	if(INCAPACITATED_IGNORING(usr, NONE) || HAS_TRAIT(usr, TRAIT_HANDS_BLOCKED) || !usr.is_in_active_hand(src))
		return
	drawtype = temp
	update_window(usr)

/obj/item/toy/crayon/afterattack(atom/target, mob/user, proximity_flag, list/modifiers, status)
	if(!proximity_flag)
		return

	if(busy)
		return

	if(is_type_in_list(target,validSurfaces))
		var/temp = "rune"
		if(letters.Find(drawtype))
			temp = "letter"
		else if(graffiti.Find(drawtype))
			temp = "graffiti"
		to_chat(user, span_notice("You start drawing a [temp] on the [target.name]."))
		busy = TRUE
		if(instant || do_after(user, 5 SECONDS * toolspeed, target, category = DA_CAT_TOOL))
			var/obj/effect/decal/cleanable/crayon/C = new /obj/effect/decal/cleanable/crayon(target,colour,drawtype,temp)
			C.add_hiddenprint(user)
			to_chat(user, span_notice("You finish drawing [temp]."))
			if(uses)
				uses--
				if(!uses)
					to_chat(user, span_danger("You used up your [name]!"))
					qdel(src)
		busy = FALSE

/obj/item/toy/crayon/attack(mob/living/target, mob/living/carbon/human/user, params, def_zone, skip_attack_anim = FALSE)

	if(target != user)
		return ..()

	. = ATTACK_CHAIN_PROCEED

	if(ishuman(user) && !user.check_has_mouth())
		to_chat(user, span_warning("You do not have a mouth!"))
		return .

	var/huffable = istype(src, /obj/item/toy/crayon/spraycan)
	playsound(loc, 'sound/items/eatfood.ogg', 50, FALSE)
	to_chat(user, span_notice("You take a [huffable ? "huff" : "bite"] of the [name]. Delicious!"))
	if(!isvampire(user))
		user.adjust_nutrition(5)

	if(!uses)
		return .

	. |= ATTACK_CHAIN_SUCCESS

	uses -= 5
	if(uses <= 0)
		. = ATTACK_CHAIN_BLOCKED_ALL
		to_chat(user, span_warning("There is no more of [huffable ? "paint in " : ""][name] left!"))
		qdel(src)

/obj/item/paint_palette/set_painting_tool_color(chosen_color)
	. = ..()
	current_color = chosen_color

/obj/item/toy/crayon/red
	name = "red crayon"
	dye_color = DYE_RED

/obj/item/toy/crayon/orange
	name = "orange crayon"
	icon_state = "crayonorange"
	colour = COLOR_ORANGE
	colourName = "orange"
	dye_color = DYE_ORANGE

/obj/item/toy/crayon/yellow
	name = "yellow crayon"
	icon_state = "crayonyellow"
	colour = COLOR_YELLOW
	colourName = "yellow"
	dye_color = DYE_YELLOW

/obj/item/toy/crayon/green
	name = "green crayon"
	icon_state = "crayongreen"
	colour = COLOR_GREEN
	colourName = "green"
	dye_color = DYE_GREEN

/obj/item/toy/crayon/blue
	name = "blue crayon"
	icon_state = "crayonblue"
	colour = COLOR_BLUE
	colourName = "blue"
	dye_color = DYE_BLUE

/obj/item/toy/crayon/purple
	name = "purple crayon"
	icon_state = "crayonpurple"
	colour = COLOR_PURPLE
	colourName = "purple"
	dye_color = DYE_PURPLE

/obj/item/toy/crayon/random/Initialize(mapload)
	. = ..()
	icon_state = pick(list("crayonred", "crayonorange", "crayonyellow", "crayongreen", "crayonblue", "crayonpurple"))
	switch(icon_state)
		if("crayonred")
			name = "red crayon"
			colour = COLOR_RED
			colourName = "red"
			dye_color = DYE_RED
		if("crayonorange")
			name = "orange crayon"
			colour = COLOR_ORANGE
			colourName = "orange"
			dye_color = DYE_ORANGE
		if("crayonyellow")
			name = "yellow crayon"
			colour = COLOR_YELLOW
			colourName = "yellow"
			dye_color = DYE_YELLOW
		if("crayongreen")
			name = "green crayon"
			colour =COLOR_GREEN
			colourName = "green"
			dye_color = DYE_GREEN
		if("crayonblue")
			name = "blue crayon"
			colour = COLOR_BLUE
			colourName = "blue"
			dye_color = DYE_BLUE
		if("crayonpurple")
			name = "purple crayon"
			colour = COLOR_PURPLE
			colourName = "purple"
			dye_color = DYE_PURPLE

/obj/item/toy/crayon/black
	name = "black crayon"
	icon_state = "crayonblack"
	colour = "#000000"
	colourName = "black"
	dye_color = DYE_BLACK

/obj/item/toy/crayon/white
	name = "white crayon"
	icon_state = "crayonwhite"
	colour = "#FFFFFF"
	colourName = "white"
	dye_color = DYE_WHITE

/obj/item/toy/crayon/mime
	name = "mime crayon"
	desc = "A very sad-looking crayon."
	icon_state = "crayonmime"
	colour = "#FFFFFF"
	colourName = "mime"
	uses = BETTER_CRAYONS_USES
	dye_color = DYE_MIME

/obj/item/toy/crayon/mime/attack_self(mob/living/user as mob)
	update_window(user)

/obj/item/toy/crayon/mime/update_window(mob/living/user as mob)
	dat += "<center><span style='border:1px solid #161616; background-color: [colour];'>&nbsp;&nbsp;&nbsp;</span><a href='byond://?src=[UID()];color=1'>Change color</a></center>"
	..()

/obj/item/toy/crayon/mime/Topic(href,href_list)
	if(!Adjacent(usr) || usr.incapacitated)
		return
	if(href_list["color"])
		if(colour != COLOR_WHITE)
			colour = COLOR_WHITE
		else
			colour = COLOR_BLACK
		update_window(usr)
	else
		..()

/obj/item/toy/crayon/rainbow
	name = "rainbow crayon"
	icon_state = "crayonrainbow"
	colour = "#FFF000"
	colourName = "rainbow"
	uses = BETTER_CRAYONS_USES
	dye_color = DYE_RAINBOW
	can_change_colour = TRUE

/obj/item/toy/crayon/rainbow/attack_self(mob/living/user as mob)
	update_window(user)

/obj/item/toy/crayon/rainbow/update_window(mob/living/user as mob)
	dat += "<center><span style='border:1px solid #161616; background-color: [colour];'>&nbsp;&nbsp;&nbsp;</span><a href='byond://?src=[UID()];color=1'>Change color</a></center>"
	..()

/obj/item/toy/crayon/rainbow/Topic(href,href_list[])
	if(!Adjacent(usr) || usr.incapacitated)
		return
	if(href_list["color"])
		var/temp = tgui_input_color(usr, "Please select colour.", "Crayon colour")
		if(isnull(temp))
			return
		colour = temp
		update_window(usr)
	else
		..()

//Spraycan stuff

/obj/item/toy/crayon/spraycan
	name = "Nanotrasen-brand Rapid Paint Applicator"
	icon_state = "spraycan"
	desc = "Металлический аэрозольный баллончик с быстрой краской производства \"Нанотрейзен\"."
	/// Current state of the cap
	var/capped = TRUE
	/// List of icon_state and names for paint welding mask
	var/list/weld_icons = list("Flame" = "welding_redflame",
								"Blue Flame" = "welding_blueflame",
								"White Flame" = "welding_white")
	instant = TRUE
	validSurfaces = list(/turf/simulated/floor, /turf/simulated/wall)
	var/spray_mode = SPRAYCAN_MODE_GRAFFITI
	var/spray_text = "nt"
	var/spray_font = "Small Fonts"
	var/outline_mode = SPRAYCAN_OUTLINE_NONE
	var/outline_color = "#111111"
	var/static/list/spray_fonts = list(
		"Минималистичный" = "Small Fonts",
		"Verdana" = "Verdana",
		"Arial" = "Arial",
		"Arial Black" = "Arial Black",
		"Comic Sans MS" = "Comic Sans MS",
		"Impact" = "Impact",
		"Lucida Sans" = "Lucida Sans Unicode",
		"Tahoma" = "Tahoma",
		"Trebuchet MS" = "Trebuchet MS",
		"Courier New" = "Courier New",
		"Lucida Console" = "Lucida Console",
	)
	var/text_index = 1
	var/loop_text = TRUE
	var/rotation = 0
	var/scale = 1
	var/max_uses = 42

/obj/item/toy/crayon/spraycan/get_ru_names()
	return alist(
		NOMINATIVE = "баллончик с краской \"Нанотрейзен\"",
		GENITIVE = "баллончика с краской \"Нанотрейзен\"",
		DATIVE = "баллончику с краской \"Нанотрейзен\"",
		ACCUSATIVE = "баллончик с краской \"Нанотрейзен\"",
		INSTRUMENTAL = "баллончиком с краской \"Нанотрейзен\"",
		PREPOSITIONAL = "баллончике с краской \"Нанотрейзен\"",
	)

/obj/item/toy/crayon/spraycan/Initialize(mapload)
	. = ..()
	max_uses = uses
	update_icon()

/obj/item/toy/crayon/spraycan/proc/toggle_cap(mob/user)
	capped = !capped
	if(user)
		to_chat(user, span_notice("Вы [capped ? "надели" : "сняли"] колпачок [declent_ru(GENITIVE)]."))
	update_icon(UPDATE_OVERLAYS)

/obj/item/toy/crayon/spraycan/click_alt(mob/user)
	if(INCAPACITATED_IGNORING(user, NONE))
		return NONE
	toggle_cap(user)
	return CLICK_ACTION_SUCCESS

/obj/item/toy/crayon/spraycan/attack_self(mob/user)
	ui_interact(user)

/obj/item/toy/crayon/spraycan/ui_state(mob/user)
	return GLOB.inventory_state

/obj/item/toy/crayon/spraycan/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "Spraycan", capitalize(declent_ru(NOMINATIVE)))
		ui.open()

/obj/item/toy/crayon/spraycan/ui_static_data(mob/user)
	var/list/data = list()
	data["max_uses"] = max_uses
	data["font_list"] = spray_fonts
	data["graffiti_list"] = graffiti
	data["rune_list"] = list("rune1", "rune2", "rune3", "rune4", "rune5", "rune6", "rune7", "rune8")
	data["valid_letters"] = list("a", "b", "c", "d", "e", "f", "g", "h", "i", "j", "k", "l", "m", "n", "o", "p", "q", "r", "s", "t", "u", "v", "w", "x", "y", "z")
	return data

/obj/item/toy/crayon/spraycan/ui_data(mob/user)
	var/list/data = list()
	data["outline_mode"] = outline_mode
	data["outline_color"] = outline_color
	data["spray_font"] = spray_font
	data["capped"] = capped
	data["colour"] = colour
	data["uses"] = uses
	data["spray_mode"] = spray_mode
	data["spray_text"] = spray_text
	data["text_index"] = text_index
	data["loop_text"] = loop_text
	data["drawtype"] = drawtype
	data["rotation"] = rotation
	data["scale"] = scale
	return data

/obj/item/toy/crayon/spraycan/proc/sanitize_spray_text(raw_text)
	if(!istext(raw_text))
		return ""
	var/static/regex/allowed_chars = regex(@"[^a-zA-Zа-яА-ЯёЁ0-9 .,!?\-_+=:;/\(\)\[\]*#@%&~]", "g")
	var/cleaned = replacetext(raw_text, allowed_chars, "")
	return copytext_char(cleaned, 1, SPRAYCAN_MAX_TEXT_LENGTH + 1)

/obj/item/toy/crayon/spraycan/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	. = ..()
	if(.)
		return

	switch(action)
		if("toggle_cap")
			toggle_cap(usr)
			return TRUE
		if("set_color")
			var/new_color = params["color"]
			if(istext(new_color) && length(new_color) == 7 && copytext(new_color, 1, 2) == "#")
				colour = new_color
				update_icon(UPDATE_OVERLAYS)
			return TRUE
		if("custom_color")
			var/new_color = tgui_input_color(usr, "Выберите цвет краски", "Цвет баллончика", colour)
			if(!isnull(new_color))
				colour = new_color
				update_icon(UPDATE_OVERLAYS)
			return TRUE
		if("set_rotation")
			var/new_angle = text2num(params["rotation"])
			if(!isnull(new_angle))
				rotation = clamp(round(new_angle), SPRAYCAN_MIN_ANGLE, SPRAYCAN_MAX_ANGLE)
			return TRUE
		if("set_scale")
			var/new_scale = text2num(params["scale"])
			if(!isnull(new_scale))
				scale = clamp(round(new_scale, SPRAYCAN_SCALE_STEP), SPRAYCAN_MIN_SCALE, SPRAYCAN_MAX_SCALE)
			return TRUE
		if("set_mode")
			var/new_mode = params["mode"]
			if(new_mode in list(SPRAYCAN_MODE_TEXT, SPRAYCAN_MODE_LETTERS, SPRAYCAN_MODE_GRAFFITI, SPRAYCAN_MODE_RUNE))
				spray_mode = new_mode
				if(spray_mode == SPRAYCAN_MODE_RUNE && !findtext(drawtype, "rune"))
					drawtype = "rune1"
				else if(spray_mode == SPRAYCAN_MODE_GRAFFITI && !(drawtype in graffiti))
					drawtype = graffiti[1]
				else if(spray_mode == SPRAYCAN_MODE_LETTERS && !(drawtype in letters))
					drawtype = letters[1]
			return TRUE
		if("set_text")
			spray_text = sanitize_spray_text(params["text"])
			text_index = 1
			advance_to_drawable_char()
			return TRUE
		if("random_letter")
			drawtype = pick(letters)
			spray_mode = SPRAYCAN_MODE_LETTERS
			return TRUE
		if("set_index")
			var/new_idx = text2num(params["index"])
			var/text_len = length_char(spray_text)
			if(!isnull(new_idx) && text_len > 0)
				text_index = clamp(round(new_idx), 1, text_len)
			return TRUE
		if("toggle_loop")
			loop_text = !loop_text
			return TRUE
		if("select_drawtype")
			var/picked = params["drawtype"]
			if(istext(picked) && ((picked in graffiti) || (picked in letters) || findtext(picked, "rune")))
				drawtype = picked
			return TRUE
		if("random_graffiti")
			drawtype = pick(graffiti)
			spray_mode = SPRAYCAN_MODE_GRAFFITI
			return TRUE
		if("random_rune")
			drawtype = "rune[rand(1, 8)]"
			spray_mode = SPRAYCAN_MODE_RUNE
			return TRUE
		if("set_font")
			var/picked_font = params["font"]
			if(istext(picked_font))
				for(var/font_name, font_family in spray_fonts)
					if(font_family == picked_font)
						spray_font = picked_font
						break
			return TRUE
		if("set_outline_mode")
			var/new_outline_mode = params["mode"]
			if(new_outline_mode in list(SPRAYCAN_OUTLINE_DARK, SPRAYCAN_OUTLINE_LIGHT, SPRAYCAN_OUTLINE_NONE))
				outline_mode = new_outline_mode
			else if(new_outline_mode == SPRAYCAN_OUTLINE_CUSTOM)
				var/picked_outline = input(usr, "Выберите цвет обводки текста:", "Цвет обводки", outline_color) as color|null
				if(picked_outline)
					outline_color = picked_outline
					outline_mode = SPRAYCAN_OUTLINE_CUSTOM
			return TRUE

/obj/item/toy/crayon/spraycan/proc/advance_to_drawable_char()
	var/cached_text = spray_text
	var/text_len = length_char(cached_text)
	if(!text_len)
		text_index = 1
		return
	var/checked = 0
	while(checked < text_len)
		var/current_char = copytext_char(cached_text, text_index, text_index + 1)
		if(current_char != " ")
			return
		text_index++
		checked++
		if(text_index > text_len)
			if(loop_text)
				text_index = 1
			else
				text_index = text_len
				return

/obj/item/toy/crayon/spraycan/proc/step_next_char()
	var/text_len = length_char(spray_text)
	if(!text_len)
		return
	text_index++
	if(text_index > text_len)
		text_index = loop_text ? 1 : text_len
		if(!loop_text)
			return
	advance_to_drawable_char()

/obj/item/toy/crayon/spraycan/afterattack(atom/target, mob/user, proximity_flag, list/modifiers, status)
	if(!proximity_flag)
		return
	if(!can_paint(target, user))
		return

	if(istype(target, /obj/effect/decal/cleanable/crayon) && !LAZYACCESS(modifiers, RIGHT_CLICK))
		var/turf/underlying_turf = get_turf(target)
		if(is_type_in_list(underlying_turf, validSurfaces))
			spray_surface(underlying_turf, user, modifiers, target.pixel_x, target.pixel_y)
		return

	if(isobj(target))
		target.balloon_alert_to_viewers("закрашивание...")
		if(!do_after(user, 5 SECONDS, target, NONE))
			return

		if(!can_paint(target, user))
			return

		uses--
		playsound(src, 'sound/effects/spray.ogg', 20, TRUE)
		SEND_SIGNAL(target, COMSIG_OBJ_PAINTED, colour)
		return ..()

	if(iscarbon(target))
		if(uses - 10 > 0)
			uses = uses - 10
			var/mob/living/carbon/human/C = target
			user.visible_message(span_danger("[user] sprays [src] into the face of [target]!"))
			if(C.client)
				C.EyeBlurry(6 SECONDS)
				C.EyeBlind(2 SECONDS)
				if(C.check_eye_prot() <= FLASH_PROTECTION_NONE) // no eye protection? ARGH IT BURNS.
					C.Confused(6 SECONDS)
					C.Weaken(6 SECONDS)
			C.lip_style = "spray_face"
			C.lip_color = colour
			C.update_body()
		if(loc == user) //sound play only if it in user hands
			playsound(user.loc, 'sound/effects/spray.ogg', 5, TRUE, 5)
		return ..()

	if(is_type_in_list(target, validSurfaces))
		spray_surface(target, user, modifiers)
		return

	return ..()

/obj/item/toy/crayon/spraycan/proc/spray_surface(turf/target, mob/user, list/modifiers)
	var/click_x = 0
	var/click_y = 0
	if(LAZYACCESS(modifiers, ICON_X))
		click_x = clamp(text2num(modifiers[ICON_X]) - SPRAYCAN_HALF_TILE, -SPRAYCAN_HALF_TILE, SPRAYCAN_HALF_TILE)
	if(LAZYACCESS(modifiers, ICON_Y))
		click_y = clamp(text2num(modifiers[ICON_Y]) - SPRAYCAN_HALF_TILE, -SPRAYCAN_HALF_TILE, SPRAYCAN_HALF_TILE)

	var/base_half_extent = (spray_mode == SPRAYCAN_MODE_TEXT) ? (SPRAYCAN_HALF_TILE / 2) : SPRAYCAN_HALF_TILE
	var/half_extent = round(base_half_extent * scale)
	var/min_x = -SPRAYCAN_HALF_TILE
	var/max_x = SPRAYCAN_HALF_TILE
	var/min_y = -SPRAYCAN_HALF_TILE
	var/max_y = SPRAYCAN_HALF_TILE

	var/turf/east_turf = get_step(target, EAST)
	var/turf/west_turf = get_step(target, WEST)
	var/turf/north_turf = get_step(target, NORTH)
	var/turf/south_turf = get_step(target, SOUTH)

	if(!east_turf || isgroundlessturf(east_turf))
		max_x = SPRAYCAN_HALF_TILE - half_extent
	if(!west_turf || isgroundlessturf(west_turf))
		min_x = half_extent - SPRAYCAN_HALF_TILE
	if(!north_turf || isgroundlessturf(north_turf))
		max_y = SPRAYCAN_HALF_TILE - half_extent
	if(!south_turf || isgroundlessturf(south_turf))
		min_y = half_extent - SPRAYCAN_HALF_TILE

	if(min_x > max_x || min_y > max_y)
		to_chat(user, span_warning("Слишком крупный масштаб для нанесения у края космоса!"))
		return

	var/raw_click_x = click_x
	var/raw_click_y = click_y
	click_x = clamp(click_x, min_x, max_x)
	click_y = clamp(click_y, min_y, max_y)
	if(click_x != raw_click_x || click_y != raw_click_y)
		to_chat(user, span_notice("Рисунок был сдвинут от края космоса."))

	var/chosen_state = drawtype
	var/decal_name = "graffiti"
	var/text_char = null

	switch(spray_mode)
		if(SPRAYCAN_MODE_RUNE)
			decal_name = "rune"
		if(SPRAYCAN_MODE_LETTERS)
			decal_name = "letter"
		if(SPRAYCAN_MODE_TEXT)
			var/text_len = length_char(spray_text)
			if(!text_len || text_index < 1 || text_index > text_len)
				to_chat(user, span_warning("Введите текст в меню баллончика!"))
				return
			var/char = copytext_char(spray_text, text_index, text_index + 1)
			if(char == " ")
				advance_to_drawable_char()
				char = copytext_char(spray_text, text_index, text_index + 1)
				if(char == " ")
					to_chat(user, span_warning("Введите хотя бы один символ в меню баллончика."))
					return
			chosen_state = null
			decal_name = "letter"
			text_char = char
			step_next_char()

	var/resolved_outline_color = null
	if(text_char)
		switch(outline_mode)
			if(SPRAYCAN_OUTLINE_DARK)
				resolved_outline_color = (lowertext(colour) == "#282828") ? "#555555" : BlendRGB(colour, "#000000", 0.65)
			if(SPRAYCAN_OUTLINE_LIGHT)
				resolved_outline_color = (lowertext(colour) == "#ffffff") ? "#bbbbbb" : BlendRGB(colour, "#ffffff", 0.65)
			if(SPRAYCAN_OUTLINE_CUSTOM)
				resolved_outline_color = outline_color

	var/final_rotation = rotation
	var/vertical_stretch = 1
	if(text_char)
		final_rotation += rand(-10, 10)
		vertical_stretch = 1.25

	var/obj/effect/decal/cleanable/crayon/decal = new(target, colour, chosen_state, decal_name, final_rotation, scale, text_char, spray_font, resolved_outline_color, vertical_stretch)
	decal.pixel_x = click_x
	decal.pixel_y = click_y

	decal.add_hiddenprint(user)
	draw_paint(user)
	SStgui.update_uis(src)

/obj/item/toy/crayon/spraycan/update_overlays()
	. = ..()
	var/image/I = image('icons/obj/crayons.dmi', icon_state = "[capped ? "spraycan_cap_colors" : "spraycan_colors"]")
	I.color = colour
	. += I

/obj/item/toy/crayon/spraycan/proc/draw_paint(mob/living/user)
	uses--
	if(loc == user)
		playsound(user.loc, 'sound/effects/spray.ogg', 5, TRUE, 5)
	if(uses <= 0)
		to_chat(user, span_warning("Вы израсходовали [declent_ru(ACCUSATIVE)]!"))
		qdel(src)

/obj/item/toy/crayon/spraycan/proc/can_paint(obj/object, mob/living/user)
	if(capped)
		to_chat(user, span_warning("Вы не можете раскрасить [object.declent_ru(ACCUSATIVE)], если крышка баллона краски закрыта!"))
		return FALSE
	if(uses <= 0)
		to_chat(user, span_warning("Не похоже, что бы осталось достаточно краски."))
		return FALSE
	if(isobj(object) && !(object.flags & UNPAINTABLE))
		return TRUE
	return TRUE

/obj/item/toy/crayon/spraycan/paintkit
	colour = "#ffffff"
	uses = SINGLEUSE_CRAYONS_USES
	validSurfaces = null

/obj/item/toy/crayon/spraycan/paintkit/attack_self(mob/user)
	toggle_cap(user)

/obj/item/toy/crayon/spraycan/paintkit/bigbrother
	name = "Paintkit «Big Brother»"
	desc = "Баллончик с черно-золотым корпусом. В комплекте идет одноразовый трафарет для покраски сварочного шлема. К нему прикреплена записка, на которой написано: «Eyes everywhere»."
	icon_state = "spraycan_bigbrother"
	weld_icons = list("Big Brother" = "welding_bigbrother")

/obj/item/toy/crayon/spraycan/paintkit/slavic
	name = "Paintkit «Slavic»"
	desc = "Баллончик с корпусом цвета хаки. В комплекте идет одноразовый трафарет для покраски сварочного шлема. К нему прикреплена записка, на которой написано: «Head, eyes, blyad»."
	icon_state = "spraycan_slavic"
	weld_icons = list("Slavic" = "welding_slavic")

#undef NORMAL_CRAYONS_USES
#undef BETTER_CRAYONS_USES
#undef SINGLEUSE_CRAYONS_USES
#undef SPRAYCAN_MODE_TEXT
#undef SPRAYCAN_MODE_LETTERS
#undef SPRAYCAN_MODE_GRAFFITI
#undef SPRAYCAN_MODE_RUNE
#undef SPRAYCAN_MAX_TEXT_LENGTH
#undef SPRAYCAN_MIN_ANGLE
#undef SPRAYCAN_MAX_ANGLE
#undef SPRAYCAN_MIN_SCALE
#undef SPRAYCAN_MAX_SCALE
#undef SPRAYCAN_SCALE_STEP
#undef SPRAYCAN_TILE_SIZE
#undef SPRAYCAN_HALF_TILE
#undef SPRAYCAN_ALLOWED_CHARS
#undef SPRAYCAN_OUTLINE_DARK
#undef SPRAYCAN_OUTLINE_LIGHT
#undef SPRAYCAN_OUTLINE_NONE
#undef SPRAYCAN_OUTLINE_CUSTOM

