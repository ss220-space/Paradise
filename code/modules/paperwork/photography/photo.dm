/obj/item/photo
	name = "photo"
	icon = 'icons/obj/items.dmi'
	icon_state = "photo"
	item_state = "paper"
	w_class = WEIGHT_CLASS_SMALL
	resistance_flags = FLAMMABLE
	max_integrity = 50
	var/blueprints = 0 // Does this have the blueprints?
	var/icon/img	//Big photo image
	var/scribble	//Scribble on the back.
	var/icon/tiny
	var/photo_size = 3
	var/log_text = "" //Used for sending to Discord and just logging

/obj/item/photo/examine(mob/user)
	. = ..()
	if(in_range(user, src) || isobserver(user))
		show(user)
		. += span_notice("Alt-Click to rename photo.")
	else
		. += "<span class='notice'>It is too far away.</span>"

/obj/item/photo/attack_self(mob/user)
	user.examinate(src)

/obj/item/photo/attackby(obj/item/I, mob/user, params)
	if(is_pen(I) || istype(I, /obj/item/toy/crayon))
		add_fingerprint(user)
		if(!user.is_literate())
			to_chat(user, span_warning("You don't know how to write!"))
			return ATTACK_CHAIN_PROCEED
		var/txt = tgui_input_text(user, "What would you like to write on the back?", "Photo Writing")
		if(!txt || !Adjacent(user) || user.incapacitated() || HAS_TRAIT(user, TRAIT_HANDS_BLOCKED))
			return ATTACK_CHAIN_PROCEED
		scribble = txt
		return ATTACK_CHAIN_PROCEED_SUCCESS

	if(istype(I, /obj/item/lighter))
		burnphoto(I, user)
		return ATTACK_CHAIN_BLOCKED_ALL

	return ..()

/obj/item/photo/AltClick(mob/user)
	if(user.incapacitated() || !isAI(usr) && HAS_TRAIT(user, TRAIT_HANDS_BLOCKED))
		return

	var/n_name = tgui_input_text(user, "What would you like to label the photo?", "Photo Labelling", name)
	if(!n_name)
		return
	//loc.loc check is for making possible renaming photos in clipboards
	if((loc == user || (loc.loc && loc.loc == user)) && !user.incapacitated() && !HAS_TRAIT(user, TRAIT_HANDS_BLOCKED))
		name = "[(n_name ? text("[n_name]") : "photo")]"
		add_fingerprint(user)

/obj/item/photo/proc/burnphoto(obj/item/lighter/P, mob/user)
	var/class = "<span class='warning'>"

	if(P.lit && !user.incapacitated() && !HAS_TRAIT(user, TRAIT_HANDS_BLOCKED))
		if(istype(P, /obj/item/lighter/zippo))
			class = "<span class='rose'>"

		user.visible_message("[class][user] holds \the [P] up to \the [src], it looks like [user.p_theyre()] trying to burn it!", \
		"[class]You hold [P] up to [src], burning it slowly.")

		spawn(20)
			if(get_dist(src, user) < 2 && user.get_active_hand() == P && P.lit)
				user.visible_message("[class][user] burns right through \the [src], turning it to ash. It flutters through the air before settling on the floor in a heap.", \
				"[class]You burn right through \the [src], turning it to ash. It flutters through the air before settling on the floor in a heap.")

				if(user.is_in_inactive_hand(src))
					user.temporarily_remove_item_from_inventory(src)

				new /obj/effect/decal/cleanable/ash(get_turf(src))
				qdel(src)

			else
				to_chat(user, "<span class='warning'>You must hold \the [P] steady to burn \the [src].</span>")

/obj/item/photo/proc/show(mob/user)
	var/icon/img_shown = new/icon(img)
	var/colormatrix = user.get_screen_colour()
	// Apply colorblindness effects, if any.
	if(islist(colormatrix))
		img_shown.MapColors(
			colormatrix[1], colormatrix[2], colormatrix[3],
			colormatrix[4], colormatrix[5], colormatrix[6],
			colormatrix[7], colormatrix[8], colormatrix[9],
		)
	usr << browse_rsc(img_shown, "tmp_photo.png")
	usr << browse({"<html><meta charset="UTF-8"><head><title>[name]</title></head>"} \
		+ "<body style='overflow:hidden;margin:0;text-align:center'>" \
		+ "<img src='tmp_photo.png' width='[64*photo_size]' style='-ms-interpolation-mode:nearest-neighbor' />" \
		+ "[scribble ? "<br>Written on the back:<br><i>[scribble]</i>" : ""]"\
		+ "</body></html>", "window=Photo[UID()];size=[64*photo_size]x[scribble ? 400 : 64*photo_size]")
	onclose(usr, "Photo[UID()]")
	return

/obj/item/photo/proc/construct(datum/picture/P)
	name = P.fields["name"]
	icon = P.fields["icon"]
	tiny = P.fields["tiny"]
	img = P.fields["img"]
	desc = P.fields["desc"]
	pixel_x = P.fields["pixel_x"]
	pixel_y = P.fields["pixel_y"]
	photo_size = P.fields["size"]
	log_text = P.fields["log"]
	blueprints = P.fields["blueprints"]

/obj/item/photo/proc/copy()
	var/obj/item/photo/p = new/obj/item/photo()

	p.icon = icon(icon, icon_state)
	p.img = icon(img)
	p.tiny = icon(tiny)
	p.name = name
	p.desc = desc
	p.scribble = scribble
	p.blueprints = blueprints

	return p
