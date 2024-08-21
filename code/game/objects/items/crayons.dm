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
	attack_verb = list("attacked", "coloured")
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

/obj/item/toy/crayon/suicide_act(mob/user)
	user.visible_message("<span class='suicide'>[user] is jamming the [name] up [user.p_their()] nose and into [user.p_their()] brain. It looks like [user.p_theyre()] trying to commit suicide.</span>")
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
			temp = input("Choose the letter.", "Scribbles") in letters
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
		var/temp = "rune"
		if(letters.Find(drawtype))
			temp = "letter"
		else if(graffiti.Find(drawtype))
			temp = "graffiti"
		to_chat(user, "<span class='info'>You start drawing a [temp] on the [target.name].</span>")
		busy = TRUE
		if(instant || do_after(user, 5 SECONDS * toolspeed, target, category = DA_CAT_TOOL))
			var/obj/effect/decal/cleanable/crayon/C = new /obj/effect/decal/cleanable/crayon(target,colour,drawtype,temp)
			C.add_hiddenprint(user)
			to_chat(user, "<span class='info'>You finish drawing [temp].</span>")
			if(uses)
				uses--
				if(!uses)
					to_chat(user, "<span class='danger'>You used up your [name]!</span>")
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
	to_chat(user, span_notice("YYou take a [huffable ? "huff" : "bite"] of the [name]. Delicious!"))
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


/obj/item/toy/crayon/red
	name = "red crayon"
	icon_state = "crayonred"
	colour = COLOR_RED
	colourName = "red"
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
	uses = 0
	dye_color = DYE_MIME

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

/obj/item/toy/crayon/rainbow/attack_self(mob/living/user as mob)
	update_window(user)

/obj/item/toy/crayon/rainbow/update_window(mob/living/user as mob)
	dat += "<center><span style='border:1px solid #161616; background-color: [colour];'>&nbsp;&nbsp;&nbsp;</span><a href='byond://?src=[UID()];color=1'>Change color</a></center>"
	..()

/obj/item/toy/crayon/rainbow/Topic(href,href_list[])
	if(!Adjacent(usr) || usr.incapacitated())
		return
	if(href_list["color"])
		var/temp = input(usr, "Please select colour.", "Crayon colour") as color
		colour = temp
		update_window(usr)
	else
		..()


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

/obj/item/toy/crayon/spraycan/Initialize(mapload)
	. = ..()
	update_icon()

/obj/item/toy/crayon/spraycan/attack_self(mob/living/user as mob)
	var/choice = input(user,"Spraycan options") in list("Toggle Cap","Change Drawing","Change Color")
	switch(choice)
		if("Toggle Cap")
			to_chat(user, "<span class='notice'>You [capped ? "Remove" : "Replace"] the cap of the [src]</span>")
			capped = !capped
			update_icon()
		if("Change Drawing")
			..()
		if("Change Color")
			colour = input(user,"Choose Color") as color
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
				user.visible_message("<span class='danger'> [user] sprays [src] into the face of [target]!</span>")
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
