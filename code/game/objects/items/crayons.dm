/*
 * Crayons
 */

/obj/item/toy/crayon
	name = "crayon"
	desc = "A colourful crayon. Looks tasty. Mmmm..."
	icon = 'icons/obj/crayons.dmi'
	icon_state = "crayonred"
	w_class = WEIGHT_CLASS_TINY
	slot_flags = ITEM_SLOT_BELT|ITEM_SLOT_EARS
	attack_verb = list("атаковал", "тыкнул")
	toolspeed = 1
	var/colour = COLOR_RED
	var/drawtype = "rune"
	var/list/graffiti = list("body","amyjon","face","matt","revolution","engie","guy","end","dwarf","uboa","up","down","left","right","heart","borgsrogue","voxpox","shitcurity","catbeast","hieroglyphs1","hieroglyphs2","hieroglyphs3","security","syndicate1","syndicate2","nanotrasen","lie","valid","arrowleft","arrowright","arrowup","arrowdown","chicken","hailcrab","brokenheart","peace","scribble","scribble2","scribble3","skrek","squish","tunnelsnake","yip","youaredead")
	var/list/letters = list("a","b","c","d","e","f","g","h","i","j","k","l","m","n","o","p","q","r","s","t","u","v","w","x","y","z")
	var/uses = 30 //0 for unlimited uses
	var/instant = 0
	var/colourName = "red" //for updateIcon purposes
	var/dat = {"<!DOCTYPE html><meta charset="UTF-8">"}
	var/busy = FALSE
	var/list/validSurfaces = list(/turf/simulated/floor)
	var/nutrition_value = 5
	var/eat_message

/obj/item/toy/crayon/get_ru_names()
	return list(
		NOMINATIVE = "мелок",
		GENITIVE = "мелка",
		DATIVE = "мелку",
		ACCUSATIVE = "мелок",
		INSTRUMENTAL = "мелком",
		PREPOSITIONAL = "мелке"
	)

/obj/item/toy/crayon/suicide_act(mob/user)
	user.visible_message(span_suicide("[user] is jamming the [name] up [user.p_their()] nose and into [user.p_their()] brain. It looks like [user.p_theyre()] trying to commit suicide."))
	return BRUTELOSS|OXYLOSS

/obj/item/toy/crayon/Initialize(mapload)
	. = ..()
	drawtype = pick(pick(graffiti), pick(letters), "rune[rand(1, 8)]")
	eat_message = "Вы откусываете кусочек [declent_ru(GENITIVE)]. Вкусно!"

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
	graffiti.Find()
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
	if(usr.incapacitated() || HAS_TRAIT(usr, TRAIT_HANDS_BLOCKED) || !usr.is_in_active_hand(src))
		return
	drawtype = temp
	update_window(usr)

/obj/item/toy/crayon/afterattack(atom/target, mob/user, proximity, params)
	if(!proximity) return
	if(busy) return
	if(is_type_in_list(target,validSurfaces))
		var/temp = "руну"
		if(letters.Find(drawtype))
			temp = "букву"
		else if(graffiti.Find(drawtype))
			temp = "граффити"
		to_chat(user, span_notice("Вы начали рисовать [temp] на [target.declent_ru("PREPOSITIONAL")]."))
		busy = TRUE
		if(instant || do_after(user, 5 SECONDS * toolspeed, target, category = DA_CAT_TOOL))
			var/obj/effect/decal/cleanable/crayon/C = new /obj/effect/decal/cleanable/crayon(target,colour,drawtype,temp)
			C.add_hiddenprint(user)
			balloon_alert(usr, "Вы закончили рисовать [temp].")
			if(uses)
				uses--
				if(!uses)
					balloon_alert(usr, "[src.declent_ru(NOMINATIVE)] закончился!")
					qdel(src)
		busy = FALSE


/obj/item/toy/crayon/attack(mob/living/target, mob/living/carbon/human/user, params, def_zone, skip_attack_anim = FALSE)

	if(target != user)
		return ..()

	. = ATTACK_CHAIN_PROCEED

	if(ishuman(user) && !user.check_has_mouth())
		balloon_alert(usr, "Вы не имеете рта!")
		return .

	playsound(loc, 'sound/items/eatfood.ogg', 50, FALSE)
	to_chat(user, span_notice(replacetext(eat_message, "[declent_ru(GENITIVE)]", src.declent_ru(GENITIVE))))
	if(!isvampire(user))
		user.adjust_nutrition(nutrition_value)

	if(!uses)
		return .

	. |= ATTACK_CHAIN_SUCCESS

	uses -= 5
	if(uses <= 0)
		. = ATTACK_CHAIN_BLOCKED_ALL
		balloon_alert(usr, "Больше ничего не осталось!")
		qdel(src)


/obj/item/toy/crayon/red
	name = "red crayon"
	icon_state = "crayonred"
	colour = COLOR_RED
	colourName = "red"
	dye_color = DYE_RED

/obj/item/toy/crayon/red/get_ru_names()
	return list(
		NOMINATIVE = "красный мелок",
		GENITIVE = "красного мелка",
		DATIVE = "красному мелку",
		ACCUSATIVE = "красный мелок",
		INSTRUMENTAL = "красным мелком",
		PREPOSITIONAL = "красном мелке"
	)

/obj/item/toy/crayon/orange
	name = "orange crayon"
	icon_state = "crayonorange"
	colour = COLOR_ORANGE
	colourName = "orange"
	dye_color = DYE_ORANGE

/obj/item/toy/crayon/orange/get_ru_names()
	return list(
		NOMINATIVE = "оранжевый мелок",
		GENITIVE = "оранжевого мелка",
		DATIVE = "оранжевому мелку",
		ACCUSATIVE = "оранжевый мелок",
		INSTRUMENTAL = "оранжевым мелком",
		PREPOSITIONAL = "оранжевом мелке"
	)

/obj/item/toy/crayon/yellow
	name = "yellow crayon"
	icon_state = "crayonyellow"
	colour = COLOR_YELLOW
	colourName = "yellow"
	dye_color = DYE_YELLOW

/obj/item/toy/crayon/yellow/get_ru_names()
	return list(
		NOMINATIVE = "жёлтый мелок",
		GENITIVE = "жёлтого мелка",
		DATIVE = "жёлтому мелку",
		ACCUSATIVE = "жёлтый мелок",
		INSTRUMENTAL = "жёлтым мелком",
		PREPOSITIONAL = "жёлтом мелке"
	)

/obj/item/toy/crayon/green
	name = "green crayon"
	icon_state = "crayongreen"
	colour = COLOR_GREEN
	colourName = "green"
	dye_color = DYE_GREEN

/obj/item/toy/crayon/green/get_ru_names()
	return list(
		NOMINATIVE = "зелёный мелок",
		GENITIVE = "зелёного мелка",
		DATIVE = "зелёному мелку",
		ACCUSATIVE = "зелёный мелок",
		INSTRUMENTAL = "зелёным мелком",
		PREPOSITIONAL = "зелёном мелке"
	)

/obj/item/toy/crayon/blue
	name = "blue crayon"
	icon_state = "crayonblue"
	colour = COLOR_BLUE
	colourName = "blue"
	dye_color = DYE_BLUE

/obj/item/toy/crayon/blue/get_ru_names()
	return list(
		NOMINATIVE = "синий мелок",
		GENITIVE = "синего мелка",
		DATIVE = "синему мелку",
		ACCUSATIVE = "синий мелок",
		INSTRUMENTAL = "синим мелком",
		PREPOSITIONAL = "синем мелке"
	)

/obj/item/toy/crayon/purple
	name = "purple crayon"
	icon_state = "crayonpurple"
	colour = COLOR_PURPLE
	colourName = "purple"
	dye_color = DYE_PURPLE

/obj/item/toy/crayon/purple/get_ru_names()
	return list(
		NOMINATIVE = "фиолетовый мелок",
		GENITIVE = "фиолетового мелка",
		DATIVE = "фиолетовому мелку",
		ACCUSATIVE = "фиолетовый мелок",
		INSTRUMENTAL = "фиолетовым мелком",
		PREPOSITIONAL = "фиолетовом мелке"
	)

/obj/item/toy/crayon/random/New()
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
	..()

/obj/item/toy/crayon/black
	name = "black crayon"
	icon_state = "crayonblack"
	colour = "#000000"
	colourName = "black"
	dye_color = DYE_BLACK

/obj/item/toy/crayon/black/get_ru_names()
	return list(
		NOMINATIVE = "чёрный мелок",
		GENITIVE = "чёрного мелка",
		DATIVE = "чёрному мелку",
		ACCUSATIVE = "чёрный мелок",
		INSTRUMENTAL = "чёрным мелком",
		PREPOSITIONAL = "чёрном мелке"
	)

/obj/item/toy/crayon/white
	name = "white crayon"
	icon_state = "crayonwhite"
	colour = "#FFFFFF"
	colourName = "white"
	dye_color = DYE_WHITE

/obj/item/toy/crayon/white/get_ru_names()
	return list(
		NOMINATIVE = "белый мелок",
		GENITIVE = "белого мелка",
		DATIVE = "белому мелку",
		ACCUSATIVE = "белый мелок",
		INSTRUMENTAL = "белым мелком",
		PREPOSITIONAL = "белом мелке"
	)

/obj/item/toy/crayon/mime
	name = "mime crayon"
	desc = "A very sad-looking crayon."
	icon_state = "crayonmime"
	colour = "#FFFFFF"
	colourName = "mime"
	uses = 0
	dye_color = DYE_MIME

/obj/item/toy/crayon/mime/get_ru_names()
	return list(
		NOMINATIVE = "мимский мелок",
		GENITIVE = "мимского мелка",
		DATIVE = "мимскому мелку",
		ACCUSATIVE = "мимский мелок",
		INSTRUMENTAL = "мимским мелком",
		PREPOSITIONAL = "мимском мелке"
	)


/obj/item/toy/crayon/mime/attack_self(mob/living/user as mob)
	update_window(user)

/obj/item/toy/crayon/mime/update_window(mob/living/user as mob)
	dat += "<center><span style='border:1px solid #161616; background-color: [colour];'>&nbsp;&nbsp;&nbsp;</span><a href='byond://?src=[UID()];color=1'>Change color</a></center>"
	..()

/obj/item/toy/crayon/mime/Topic(href,href_list)
	if(!Adjacent(usr) || usr.incapacitated())
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
	uses = 0
	dye_color = DYE_RAINBOW

/obj/item/toy/crayon/rainbow/get_ru_names()
	return list(
		NOMINATIVE = "радужный мелок",
		GENITIVE = "радужного мелка",
		DATIVE = "радужному мелку",
		ACCUSATIVE = "радужный мелок",
		INSTRUMENTAL = "радужным мелком",
		PREPOSITIONAL = "радужном мелке"
	)

/obj/item/toy/crayon/rainbow/attack_self(mob/living/user as mob)
	update_window(user)

/obj/item/toy/crayon/rainbow/update_window(mob/living/user as mob)
	dat += "<center><span style='border:1px solid #161616; background-color: [colour];'>&nbsp;&nbsp;&nbsp;</span><a href='byond://?src=[UID()];color=1'>Change color</a></center>"
	..()

/obj/item/toy/crayon/rainbow/Topic(href,href_list[])
	if(!Adjacent(usr) || usr.incapacitated())
		return
	if(href_list["color"])
		var/temp = tgui_input_color(usr, "Please select colour.", "Crayon colour")
		if(isnull(temp))
			return
		colour = temp
		update_window(usr)
	else
		..()

/obj/item/toy/crayon/bloodred
	name = "blood-red crayon"
	desc = "Мелок, пахнущий кровью, выглядит так, будто сделан из неё."
	icon_state = "crayonbloodred"
	colour = COLOR_CULT_RED
	colourName = "blood"
	uses = 0
	dye_color = DYE_BLOOD
	nutrition_value = 10

/obj/item/toy/crayon/bloodred/get_ru_names()
	return list(
		NOMINATIVE = "кроваво-красный мелок",
		GENITIVE = "кроваво-красного мелка",
		DATIVE = "кроваво-красному мелку",
		ACCUSATIVE = "кроваво-красный мелок",
		INSTRUMENTAL = "кроваво-красным мелком",
		PREPOSITIONAL = "кроваво-красном мелке"
	)

/obj/item/toy/crayon/bloodred/Initialize(mapload)
	. = ..()
	eat_message = "Вы откусываете кроваво-красный мелок. На вкус как кровь. У вас остается металлический привкус на языке."

/obj/item/toy/crayon/bloodred/afterattack(atom/target, mob/user, proximity, params)
	if(!proximity || busy)
		return
	if(!is_type_in_list(target, validSurfaces))
		return
	var/temp = "руну"
	if(letters.Find(drawtype))
		temp = "букву"
	else if(graffiti.Find(drawtype))
		temp = "граффити"
	to_chat(user, span_notice("Вы начали рисовать [temp] на [target.declent_ru("PREPOSITIONAL")]."))
	busy = TRUE
	if(instant || do_after(user, 5 SECONDS * toolspeed, target, category = DA_CAT_TOOL))
		var/obj/effect/decal/cleanable/crayon/C = new /obj/effect/decal/cleanable/crayon(target,colour,drawtype,temp)
		C.add_hiddenprint(user)
		balloon_alert(usr, "Вы закончили рисовать [temp].")
		if(uses)
			uses--
			if(!uses)
				balloon_alert(usr, "[src.declent_ru(NOMINATIVE)] закончился!")
				qdel(src)
	busy = FALSE


//Spraycan stuff

/obj/item/toy/crayon/spraycan
	name = "Nanotrasen-brand Rapid Paint Applicator"
	icon_state = "spraycan"
	desc = "A metallic container containing tasty paint."
	/// Current state of the cap
	var/capped = 1
	/// List of icon_state and names for paint welding mask
	var/list/weld_icons = list("Flame" = "welding_redflame",
					"Blue Flame" = "welding_blueflame",
					"White Flame" = "welding_white")
	instant = 1
	validSurfaces = list(/turf/simulated/floor,/turf/simulated/wall)

/obj/item/toy/crayon/spraycan/get_ru_names()
	return list(
		NOMINATIVE = "баллончик с краской",
		GENITIVE = "баллончика с краской",
		DATIVE = "баллончику с краской",
		ACCUSATIVE = "баллончик с краской",
		INSTRUMENTAL = "баллончиком с краской",
		PREPOSITIONAL = "баллончике с краской"
	)

/obj/item/toy/crayon/spraycan/Initialize(mapload)
	. = ..()
	eat_message = "Вы делаете затяжку от [declent_ru(GENITIVE)]. Вкусно!"
	update_icon()

/obj/item/toy/crayon/spraycan/attack_self(mob/living/user as mob)
	var/choice = tgui_input_list(user, "Spraycan options", , list("Toggle Cap", "Change Drawing", "Change Color"))
	switch(choice)
		if("Toggle Cap")
			balloon_alert(usr, "Вы [capped ? "сняли" : "вернули"] колпачок [src.declent_ru(GENITIVE)]")
			capped = !capped
			update_icon()
		if("Change Drawing")
			..()
		if("Change Color")
			var/new_color = tgui_input_color(user, "Choose Color")
			if(isnull(new_color))
				return
			colour = new_color
			update_icon()

/obj/item/toy/crayon/spraycan/afterattack(atom/target, mob/user, proximity, params)
	if(!proximity)
		return
	if(capped)
		return
	else
		if(iscarbon(target))
			if(uses-10 > 0)
				uses = uses - 10
				var/mob/living/carbon/human/C = target
				user.visible_message(span_danger(" [user] распыляет краску на лицо [target] [src.declent_ru(INSTRUMENTAL)]!"))
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
			playsound(user.loc, 'sound/effects/spray.ogg', 5, 1, 5)
		..()

/obj/item/toy/crayon/spraycan/update_overlays()
	. = ..()
	var/image/I = image('icons/obj/crayons.dmi', icon_state = "[capped ? "spraycan_cap_colors" : "spraycan_colors"]")
	I.color = colour
	. += I

/obj/item/toy/crayon/spraycan/proc/draw_paint(mob/living/user)
	uses--
	if(!uses)
		to_chat(user, span_warning("Вы израсходовали [name]!"))
		playsound(user.loc, 'sound/effects/spray.ogg', 5, 1, 5)
		qdel(src)

/obj/item/toy/crayon/spraycan/proc/can_paint(obj/object, mob/living/user)
	if(capped)
		to_chat(user, span_warning("Вы не можете раскрасить [object], если крышка баллона краски закрыта!"))
		return FALSE
	if(!uses)
		to_chat(user, span_warning("Не похоже, что бы осталось достаточно краски"))
		return FALSE
	return TRUE

/obj/item/toy/crayon/spraycan/paintkit
	colour = "#ffffff"
	uses = 1
	validSurfaces = null

/obj/item/toy/crayon/spraycan/paintkit/attack_self(mob/living/user as mob)
	to_chat(user, span_notice("Вы [capped ? "сняли" : "вернули"] колпачок [name]"))
	capped = !capped
	update_icon(UPDATE_OVERLAYS)

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
