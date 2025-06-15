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
		. += span_notice("Альт-Клик чтобы переименовать фото.")
	else
		. += span_notice("Слишком далеко чтобы разглядеть")

/obj/item/photo/attack_self(mob/user)
	user.examinate(src)

/obj/item/photo/attackby(obj/item/I, mob/user, params)
	if(is_pen(I) || istype(I, /obj/item/toy/crayon))
		add_fingerprint(user)
		if(!user.is_literate())
			to_chat(user, span_warning("Вы не умеете писать!"))
			return ATTACK_CHAIN_PROCEED
		var/txt = tgui_input_text(user, "Что вы хотите написать на обратной стороне фото?", "Писать на фотографии")
		if(!txt || !Adjacent(user) || user.incapacitated() || HAS_TRAIT(user, TRAIT_HANDS_BLOCKED))
			return ATTACK_CHAIN_PROCEED
		scribble = txt
		return ATTACK_CHAIN_PROCEED_SUCCESS

	if(istype(I, /obj/item/lighter))
		burnphoto(I, user)
		return ATTACK_CHAIN_BLOCKED_ALL

	return ..()

/obj/item/photo/click_alt(mob/user)
	if(user.incapacitated() || !isAI(usr) && HAS_TRAIT(user, TRAIT_HANDS_BLOCKED))
		return NONE

	var/n_name = tgui_input_text(user, "Как вы хотите подписать фото?", "Подписать фотографию", name)
	if(!n_name)
		return CLICK_ACTION_BLOCKING
	//loc.loc check is for making possible renaming photos in clipboards
	if((loc == user || (loc.loc && loc.loc == user)) && !user.incapacitated() && !HAS_TRAIT(user, TRAIT_HANDS_BLOCKED))
		name = "[(n_name ? text("[n_name]") : "photo")]"
		add_fingerprint(user)
	return CLICK_ACTION_SUCCESS

/obj/item/photo/proc/burnphoto(obj/item/lighter/P, mob/user)
	var/class = "<span class='warning'>"

	if(P.lit && !user.incapacitated() && !HAS_TRAIT(user, TRAIT_HANDS_BLOCKED))
		if(istype(P, /obj/item/lighter/zippo))
			class = "<span class='rose'>"

		user.visible_message("[class][user] держит \the [P] над \the [src], похоже, что [user.p_theyre()] пытается её сжечь!", \
		"[class]Вы держите [P] над [src], медленно её сжигая.")

		spawn(20)
			if(get_dist(src, user) < 2 && user.get_active_hand() == P && P.lit)
				user.visible_message("[class][user] сжигает \the [src], превращая в пыль. Она немного летает в воздухе, прежде чем упасть на пол..", \
				"[class]Вы сожгли \the [src], превратив в пыль. Она немного пролетела в воздухе, прежде чем упасть на пол.")

				if(user.is_in_inactive_hand(src))
					user.temporarily_remove_item_from_inventory(src)

				new /obj/effect/decal/cleanable/ash(get_turf(src))
				qdel(src)

			else
				to_chat(user, span_warning("Вы должны держать \the [P] неподвижно, чтобы поджечь \the [src]."))

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
	var/datum/browser/popup = new(usr, "Фото[UID()]", null, 64 * photo_size, scribble ? 400 : 64 * photo_size)
	popup.set_content("<div class='photo-container' style='width: [64*photo_size]px; height: [64*photo_size]px;'> \
	<img src='tmp_photo.png' width='100%' height='100%'  /> \
	[scribble ? "<p>Надпись сзади:<br><i>[scribble]</i></p>" : ""] \
	</div>")
	popup.add_stylesheet("photo", 'html/css/photo.css')
	popup.open(TRUE)
	onclose(usr, "Photo[UID()]")
	return

/obj/item/photo/proc/construct(datum/picture/photo)
	name = photo.fields["name"]
	icon = photo.fields["icon"]
	tiny = photo.fields["tiny"]
	img = photo.fields["img"]
	desc = photo.fields["desc"]
	pixel_x = photo.fields["pixel_x"]
	pixel_y = photo.fields["pixel_y"]
	photo_size = photo.fields["size"]
	log_text = photo.fields["log"]
	blueprints = photo.fields["blueprints"]
	if(blueprints)
		AddElement(/datum/element/high_value_item)

/obj/item/photo/proc/copy()
	var/obj/item/photo/new_photo = new/obj/item/photo()

	new_photo.icon = icon(icon, icon_state)
	new_photo.img = icon(img)
	new_photo.tiny = icon(tiny)
	new_photo.name = name
	new_photo.desc = desc
	new_photo.scribble = scribble
	new_photo.blueprints = blueprints
	if(blueprints)
		new_photo.AddElement(/datum/element/high_value_item)

	return new_photo
