/*	Photography!
 *	Contains:
 *		Camera
 *		Camera Film
 *		Photos
 *		Photo Albums
 */

/*******
* film *
*******/
/obj/item/camera_film
	name = "film cartridge"
	icon = 'icons/obj/items.dmi'
	desc = "A camera film cartridge. Insert it into a camera to reload it."
	icon_state = "film"
	item_state = "electropack"
	w_class = WEIGHT_CLASS_TINY
	resistance_flags = FLAMMABLE


/********
* photo *
********/
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

/obj/item/photo/examine(mob/user)
	. = ..()
	if(in_range(user, src) || isobserver(user))
		show(user)
	else
		. += "<span class='notice'>It is too far away.</span>"

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

/obj/item/photo/verb/rename()
	set name = "Rename photo"
	set category = "Object"
	set src in usr

	if(usr.incapacitated() || !isAI(usr) && HAS_TRAIT(usr, TRAIT_HANDS_BLOCKED))
		return

	var/n_name = tgui_input_text(usr, "What would you like to label the photo?", "Photo Labelling", name)
	if(!n_name)
		return
	//loc.loc check is for making possible renaming photos in clipboards
	if((loc == usr || (loc.loc && loc.loc == usr)) && !usr.incapacitated() && !HAS_TRAIT(usr, TRAIT_HANDS_BLOCKED))
		name = "[(n_name ? text("[n_name]") : "photo")]"
		add_fingerprint(usr)


/**************
* photo album *
**************/
/obj/item/storage/photo_album
	name = "Photo album"
	icon = 'icons/obj/items.dmi'
	icon_state = "album"
	item_state = "briefcase"
	can_hold = list(/obj/item/photo)
	resistance_flags = FLAMMABLE
	drop_sound = 'sound/items/handling/book_drop.ogg'
	pickup_sound =  'sound/items/handling/book_pickup.ogg'


/*********
* camera *
*********/
/obj/item/camera
	name = "camera"
	icon = 'icons/obj/items.dmi'
	desc = "A polaroid camera. 10 photos left."
	icon_state = "camera"
	item_state = "camera"
	w_class = WEIGHT_CLASS_SMALL
	slot_flags = ITEM_SLOT_BELT|ITEM_SLOT_NECK
	var/list/matter = list("metal" = 2000)
	var/pictures_max = 10
	var/pictures_left = 10
	var/on = 1
	var/blueprints = 0
	var/icon_on = "camera"
	var/icon_off = "camera_off"
	var/item_on = "camera"
	var/item_off = "camera_off"
	var/size = 3
	var/see_ghosts = 0 //for the spoop of it
	var/flashing_lights = TRUE

	sprite_sheets = list(
		SPECIES_GREY = 'icons/mob/clothing/species/grey/neck.dmi',
		SPECIES_KIDAN = 'icons/mob/clothing/species/kidan/neck.dmi',
		SPECIES_DRASK = 'icons/mob/clothing/species/drask/neck.dmi',
		SPECIES_VOX = 'icons/mob/clothing/species/vox/neck.dmi',
		SPECIES_MONKEY = 'icons/mob/clothing/species/monkey/neck.dmi',
		SPECIES_WRYN = 'icons/mob/clothing/species/wryn/neck.dmi'
		)


/obj/item/camera/spooky/CheckParts(list/parts_list)
	..()
	var/obj/item/camera/C = locate(/obj/item/camera) in contents
	if(C)
		pictures_max = C.pictures_max
		pictures_left = C.pictures_left
		visible_message("[C] has been imbued with godlike power!")
		qdel(C)


GLOBAL_LIST_INIT(SpookyGhosts, list("ghost","shade","shade2","ghost-narsie","horror","shadow","ghostian2"))

/obj/item/camera/spooky
	name = "camera obscura"
	desc = "A polaroid camera, some say it can see ghosts!"
	see_ghosts = 1

/obj/item/camera/AltShiftClick(mob/user)
	if(!issilicon(usr) && (usr.incapacitated() || HAS_TRAIT(usr, TRAIT_HANDS_BLOCKED)))
		return

	flashing_lights = !flashing_lights

	to_chat(usr, span_notice("You turned [src] flashing lights [flashing_lights ? "on" : "off"], making natural light [flashing_lights ? "invisible" : "visible"]"))

/obj/item/camera/verb/change_size()
	set name = "Set Photo Focus"
	set category = "Object"

	if(!issilicon(usr) && (usr.incapacitated() || HAS_TRAIT(usr, TRAIT_HANDS_BLOCKED)))
		return

	var/nsize = tgui_input_list(usr, "Photo Size", "Pick a size of resulting photo.", list(1,3,5,7))
	if(nsize)
		size = nsize
		to_chat(usr, "<span class='notice'>Camera will now take [size]x[size] photos.</span>")


/obj/item/camera/attack(mob/living/target, mob/living/user, params, def_zone, skip_attack_anim = FALSE)
	return ATTACK_CHAIN_PROCEED


/obj/item/camera/attack_self(mob/user)
	on = !on
	update_icon(UPDATE_ICON_STATE)
	to_chat(user, "You switch the camera [on ? "on" : "off"].")
	return

/obj/item/camera/update_icon_state()
	icon_state = on ? icon_on : icon_off
	item_state = on ? item_on : item_off


/obj/item/camera/attackby(obj/item/I, mob/user, params)
	if(istype(I, /obj/item/camera_film))
		add_fingerprint(user)
		if(pictures_left)
			to_chat(user, span_warning("The [name] still has some film in it."))
			return ATTACK_CHAIN_PROCEED
		if(!user.drop_transfer_item_to_loc(I, src))
			return ..()
		to_chat(user, span_notice("You have fully refilled [src]'s film amount."))
		pictures_left = pictures_max
		qdel(I)
		return ATTACK_CHAIN_BLOCKED_ALL

	return ..()


/obj/item/camera/examine(mob/user)
	. = ..()
	. += span_notice("Press Alt + Shift + Left Click on [src] to toggle camera flashing")

/obj/item/camera/proc/get_icon(list/turfs, turf/center, mob/user)

	//Bigger icon base to capture those icons that were shifted to the next tile
	//i.e. pretty much all wall-mounted machinery
	var/icon/res = icon('icons/effects/96x96.dmi', "")
	res.Scale(size*32, size*32)
	// Initialize the photograph to black.
	res.Blend("#000", ICON_OVERLAY)

	var/atoms[] = list()
	for(var/turf/the_turf in turfs)
		// Add ourselves to the list of stuff to draw
		atoms.Add(the_turf)
		// As well as anything that isn't invisible.

		for(var/atom/A in the_turf)
			if(istype(A, /atom/movable/lighting_object))
				if(flashing_lights)
					continue //Do not apply lighting, making whole image full bright.

			if(A.invisibility)
				if(see_ghosts && istype(A,/mob/dead/observer))
					var/mob/dead/observer/O = A
					if(O.orbiting)
						continue
					if(user.mind && !(user.mind.assigned_role == JOB_TITLE_CHAPLAIN))
						atoms.Add(image('icons/mob/mob.dmi', O.loc, pick(GLOB.SpookyGhosts), 4, SOUTH))
					else
						atoms.Add(image('icons/mob/mob.dmi', O.loc, "ghost", 4, SOUTH))
				else//its not a ghost
					continue
			else//not invisable, not a spookyghost add it.
				var/disguised = null
				if(user.viewing_alternate_appearances && user.viewing_alternate_appearances.len && ishuman(A) && A.alternate_appearances && A.alternate_appearances.len) //This whole thing and the stuff below just checks if the atom is a Solid Snake cosplayer.
					for(var/datum/alternate_appearance/alt_appearance in user.viewing_alternate_appearances)
						if(alt_appearance.owner == A) //If it turns out they are, don't blow their cover. That'd be rude.
							atoms.Add(image(alt_appearance.img, A.loc, layer = 4, dir = A.dir)) //Render their disguise.
							atoms.Remove(A) //Don't blow their cover.
							disguised = 1
							continue
				if(!disguised) //If they aren't, treat them normally.
					atoms.Add(A)


	// Sort the atoms into their layers
	var/list/sorted = sort_atoms_by_layer(atoms)
	var/center_offset = (size-1)/2 * 32 + 1
	for(var/i; i <= sorted.len; i++)
		var/atom/A = sorted[i]
		if(istype(A, /atom/movable/lighting_object))
			continue //Lighting objects render last, need to be above all atoms and turfs displayed
		if(A)
			var/icon/img = getFlatIcon(A)//build_composite_icon(A)
			if(istype(A, /obj/item/areaeditor/blueprints/ce))
				blueprints = 1

			// If what we got back is actually a picture, draw it.
			if(isicon(img))
				// Check if we're looking at a mob that's lying down
				if(isliving(A))
					var/mob/living/living = A
					if(living.body_position == LYING_DOWN)
						// If they are, apply that effect to their picture.
						img.BecomeLying()

				// Calculate where we are relative to the center of the photo
				var/xoff = (A.x - center.x) * 32 + center_offset
				var/yoff = (A.y - center.y) * 32 + center_offset
				if(ismovable(A))
					xoff+=A:step_x
					yoff+=A:step_y

				res.Blend(img, blendMode2iconMode(A.blend_mode),  A.pixel_x + xoff, A.pixel_y + yoff)

	// Render any contained effects on top.
	for(var/turf/the_turf in turfs)
		// Calculate where we are relative to the center of the photo
		var/xoff = (the_turf.x - center.x) * 32 + center_offset
		var/yoff = (the_turf.y - center.y) * 32 + center_offset
		res.Blend(getFlatIcon(the_turf.loc), blendMode2iconMode(the_turf.blend_mode),xoff,yoff)

	// Render lighting objects to make picture look nice
	for(var/atom/movable/lighting_object/light in sorted)
		var/xoff = (light.x - center.x) * 32 + center_offset
		var/yoff = (light.y - center.y) * 32 + center_offset
		res.Blend(getFlatIcon(light), blendMode2iconMode(BLEND_MULTIPLY),  light.pixel_x + xoff, light.pixel_y + yoff)

	return res


/obj/item/camera/proc/get_mobs(turf/the_turf)
	var/mob_detail
	for(var/mob/M in the_turf)
		if(M.invisibility)
			if(see_ghosts && istype(M,/mob/dead/observer))
				var/mob/dead/observer/O = M
				if(O.orbiting)
					continue
				if(!mob_detail)
					mob_detail = "You can see a g-g-g-g-ghooooost! "
				else
					mob_detail += "You can also see a g-g-g-g-ghooooost!"
			else
				continue

		var/holding = null

		if(iscarbon(M))
			var/mob/living/carbon/A = M
			if(A.l_hand || A.r_hand)
				if(A.l_hand) holding = "They are holding \a [A.l_hand]"
				if(A.r_hand)
					if(holding)
						holding += " and \a [A.r_hand]"
					else
						holding = "They are holding \a [A.r_hand]"

			if(!mob_detail)
				mob_detail = "You can see [A] on the photo[A:health < 75 ? " - [A] looks hurt":""].[holding ? " [holding]":"."]. "
			else
				mob_detail += "You can also see [A] on the photo[A:health < 75 ? " - [A] looks hurt":""].[holding ? " [holding]":"."]."
	return mob_detail

/obj/item/camera/proc/add_log(turf/the_turf)
	var/mob_detail
	for(var/mob/M in the_turf)
		var/holding = null
		if(iscarbon(M))
			var/mob/living/carbon/A = M
			if(A.l_hand || A.r_hand)
				if(A.l_hand) holding = "holding [A.l_hand]"
				if(A.r_hand)
					if(holding)
						holding += " and [A.r_hand]"
					else
						holding = "holding [A.r_hand]"
			if(!mob_detail)
				mob_detail = "[A.client ? "[A.client.ckey]/" : "nockey"]([A]) on photo[A:health < 75 ? " hurt":""].[holding ? " [holding]":"."]. "
			else
				mob_detail += "Also [A.client ? "[A.client.ckey]/" : "nockey"]([A]) on the photo[A:health < 75 ? " hurt":""].[holding ? " [holding]":"."]."
	return mob_detail

/obj/item/camera/afterattack(atom/target, mob/user, flag, params)
	if(!on || !pictures_left || ismob(target.loc))
		return
	captureimage(target, user, flag)

	playsound(loc, pick('sound/items/polaroid1.ogg', 'sound/items/polaroid2.ogg'), 75, 1, -3)
	if(flashing_lights)
		set_light(3, 2, LIGHT_COLOR_TUNGSTEN, l_on = TRUE)
		addtimer(CALLBACK(src, TYPE_PROC_REF(/atom, set_light), 0), 2)
	pictures_left--
	desc = "A polaroid camera. It has [pictures_left] photos left."
	to_chat(user, "<span class='notice'>[pictures_left] photos left.</span>")
	on = FALSE
	update_icon(UPDATE_ICON_STATE)
	if(istype(src, /obj/item/camera/spooky))
		if(user.mind && user.mind.assigned_role == JOB_TITLE_CHAPLAIN && see_ghosts)
			if(prob(24))
				handle_haunt(user)
	addtimer(CALLBACK(src, PROC_REF(delayed_turn_on)), 6.4 SECONDS)


/obj/item/camera/proc/delayed_turn_on()
	on = TRUE
	update_icon(UPDATE_ICON_STATE)


/obj/item/camera/proc/can_capture_turf(turf/T, mob/user)
	var/viewer = user
	if(user.client)		//To make shooting through security cameras possible
		viewer = user.client.eye
	var/can_see = (T in view(viewer)) //No x-ray vision cameras.
	return can_see

/obj/item/camera/proc/captureimage(atom/target, mob/user, flag)
	var/x_c = target.x - (size-1)/2
	var/y_c = target.y + (size-1)/2
	var/z_c	= target.z
	var/list/turfs = list()
	var/log = "Made by [user.name] in [get_area(user)]. "
	var/mobs = ""
	for(var/i = 1; i <= size; i++)
		for(var/j = 1; j <= size; j++)
			var/turf/T = locate(x_c, y_c, z_c)
			if(isopenspaceturf(T))
				T = GET_TURF_BELOW(T) // Multi-Z
			if(can_capture_turf(T, user))
				turfs.Add(T)
				mobs += get_mobs(T)
				log += add_log(T)
			x_c++
		y_c--
		x_c = x_c - size

	var/datum/picture/P = createpicture(target, user, turfs, mobs, flag, blueprints, log)
	printpicture(user, P)

/obj/item/camera/proc/createpicture(atom/target, mob/user, list/turfs, mobs, flag, blueprints, logs)
	var/icon/photoimage = get_icon(turfs, target, user)

	var/icon/small_img = icon(photoimage)
	var/icon/tiny_img = icon(photoimage)
	var/icon/ic = icon('icons/obj/items.dmi',"photo")
	var/icon/pc = icon('icons/obj/bureaucracy.dmi', "photo")
	small_img.Scale(8, 8)
	tiny_img.Scale(4, 4)
	ic.Blend(small_img,ICON_OVERLAY, 10, 13)
	pc.Blend(tiny_img,ICON_OVERLAY, 12, 19)

	var/datum/picture/P = new()
	if(istype(src,/obj/item/camera/digital))
		P.fields["name"] = tgui_input_text(user, "Name photo:", "Photo", encode = FALSE)
		P.name = P.fields["name"]//So the name is displayed on the print/delete list.
	else
		P.fields["name"] = "photo"
	P.fields["author"] = user
	P.fields["icon"] = ic
	P.fields["tiny"] = pc
	P.fields["img"] = photoimage
	P.fields["desc"] = mobs
	P.fields["pixel_x"] = rand(-10, 10)
	P.fields["pixel_y"] = rand(-10, 10)
	P.fields["size"] = size
	P.fields["log"] = logs

	return P

/obj/item/camera/proc/printpicture(mob/user, var/datum/picture/P)
	var/obj/item/photo/Photo = new/obj/item/photo()
	Photo.loc = user.loc
	if(!user.get_inactive_hand())
		user.put_in_inactive_hand(Photo)

	if(blueprints)
		Photo.blueprints = 1
		blueprints = 0
	Photo.construct(P)

/obj/item/photo/proc/construct(var/datum/picture/P)
	name = P.fields["name"]
	icon = P.fields["icon"]
	tiny = P.fields["tiny"]
	img = P.fields["img"]
	desc = P.fields["desc"]
	pixel_x = P.fields["pixel_x"]
	pixel_y = P.fields["pixel_y"]
	photo_size = P.fields["size"]
	log_text = P.fields["log"]

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


///hauntings, like hallucinations but more spooky
/obj/item/camera/proc/handle_haunt(mob/user)
	var/static/list/creepyasssounds = list(
		'sound/effects/ghost.ogg',
		'sound/effects/ghost2.ogg',
		'sound/effects/heartbeat.ogg',
		'sound/effects/screech.ogg',
		'sound/hallucinations/behind_you1.ogg',
		'sound/hallucinations/behind_you2.ogg',
		'sound/hallucinations/far_noise.ogg',
		'sound/hallucinations/growl1.ogg',
		'sound/hallucinations/growl2.ogg',
		'sound/hallucinations/growl3.ogg',
		'sound/hallucinations/im_here1.ogg',
		'sound/hallucinations/im_here2.ogg',
		'sound/hallucinations/i_see_you1.ogg',
		'sound/hallucinations/i_see_you2.ogg',
		'sound/hallucinations/look_up1.ogg',
		'sound/hallucinations/look_up2.ogg',
		'sound/hallucinations/over_here1.ogg',
		'sound/hallucinations/over_here2.ogg',
		'sound/hallucinations/over_here3.ogg',
		'sound/hallucinations/turn_around1.ogg',
		'sound/hallucinations/turn_around2.ogg',
		'sound/hallucinations/veryfar_noise.ogg',
		'sound/hallucinations/wail.ogg',
	)
	SEND_SOUND(user, pick(creepyasssounds))


/*****************
* digital camera *
******************/
/obj/item/camera/digital
	name = "digital camera"
	desc = "A digital camera. A small screen shows there is space for 10 photos left."
	var/list/datum/picture/saved_pictures = list()
	pictures_left = 30
	var/max_storage = 10


/obj/item/camera/digital/afterattack(atom/target, mob/user, flag, params)
	if(!on || !pictures_left || ismob(target.loc)) return
	captureimage(target, user, flag)

	playsound(loc, pick('sound/items/polaroid1.ogg', 'sound/items/polaroid2.ogg'), 75, 1, -3)

	desc = "A digital camera. A small screen shows that there are currently [length(saved_pictures)] pictures stored."
	on = FALSE
	update_icon(UPDATE_ICON_STATE)
	addtimer(CALLBACK(src, TYPE_PROC_REF(/obj/item/camera, delayed_turn_on)), 6.4 SECONDS)


/obj/item/camera/digital/captureimage(atom/target, mob/user, flag)
	if(saved_pictures.len >= max_storage)
		to_chat(user, "<span class='notice'>Maximum photo storage capacity reached.</span>")
		return
	to_chat(user, "Picture saved.")
	var/x_c = target.x - (size-1)/2
	var/y_c = target.y + (size-1)/2
	var/z_c	= target.z
	var/list/turfs = list()
	var/log = "Made by [user.name] in [get_area(user)]. "
	var/mobs = ""
	for(var/i = 1; i <= size; i++)
		for(var/j = 1; j <= size; j++)
			var/turf/T = locate(x_c, y_c, z_c)
			if(can_capture_turf(T, user))
				turfs.Add(T)
				mobs += get_mobs(T)
				log += add_log(T)
			x_c++
		y_c--
		x_c = x_c - size

	var/datum/picture/P = createpicture(target, user, turfs, mobs, flag, blueprints, log)
	saved_pictures += P

/obj/item/camera/digital/verb/print_picture()
	set name = "Print picture"
	set category = "Object"
	set src in usr

	if(saved_pictures.len == 0)
		to_chat(usr, "<span class='userdanger'>No images saved.</span>")
		return
	if(pictures_left == 0)
		to_chat(usr, "<span class='userdanger'>There is no film left to print.</span>")
		return

	var/datum/picture/P = null
	P = tgui_input_list(usr, "Select image to print", "Print image", saved_pictures)
	if(P)
		printpicture(usr,P)
		pictures_left --

/obj/item/camera/digital/verb/delete_picture()
	set name = "Delete picture"
	set category = "Object"
	set src in usr

	if(saved_pictures.len == 0)
		to_chat(usr, "<span class='userdanger'>No images saved</span>")
		return
	var/datum/picture/P = null
	P = tgui_input_list(usr, "Select image to delete", "Delete image", saved_pictures)
	if(P)
		saved_pictures -= P

/**************
*video camera *
***************/
#define CAMERA_STATE_COOLDOWN 2 SECONDS
GLOBAL_LIST_EMPTY(active_video_cameras)

/obj/item/videocam
	name = "video camera"
	icon = 'icons/obj/items.dmi'
	desc = "video camera that can send live feed to the entertainment network."
	icon_state = "videocam"
	item_state = "videocam"
	w_class = WEIGHT_CLASS_SMALL
	slot_flags = ITEM_SLOT_BELT
	materials = list(MAT_METAL=2000)
	var/on = FALSE
	var/video_cooldown = 0
	var/obj/machinery/camera/portable/camera
	var/canhear_range = 7


/obj/item/videocam/Destroy()
	if(on)
		camera_state()
	return ..()


/obj/item/videocam/update_icon_state()
	icon_state = "videocam[on ? "_on" : ""]"


/obj/item/videocam/proc/update_feeds()
	if(on)
		GLOB.active_video_cameras |= src
	else
		GLOB.active_video_cameras -= src

	for(var/obj/machinery/computer/security/telescreen/entertainment/TV in GLOB.machines)
		TV.update_icon(UPDATE_OVERLAYS)


/obj/item/videocam/proc/camera_state(mob/living/carbon/user)
	if(on)
		camera.c_tag = null
		QDEL_NULL(camera)
	else
		camera = new(src, list("news"), user.name)
	on = !on
	update_icon(UPDATE_ICON_STATE)
	visible_message(span_notice("The video camera has been turned [on ? "on" : "off"]."))
	update_feeds()


/obj/item/videocam/attack_self(mob/user)
	if(world.time < video_cooldown)
		to_chat(user, span_warning("[src] is overheating, give it some time."))
		return
	camera_state(user)


/obj/item/videocam/dropped(mob/user, slot, silent = FALSE)
	. = ..()
	if(on)
		camera_state()


/obj/item/videocam/examine(mob/user)
	. = ..()
	if(in_range(user, src))
		. += span_notice("This video camera can send live feeds to the entertainment network. It's [on ? "" : "in"]active.")


/obj/item/videocam/hear_talk(mob/M, list/message_pieces)
	var/msg = multilingual_to_message(message_pieces)
	if(camera && on)
		if(get_dist(src, M) <= canhear_range)
			talk_into(M, msg)
		for(var/obj/machinery/computer/security/telescreen/T in GLOB.machines)
			if(T.watchers[M] == camera)
				T.atom_say(msg)


/obj/item/videocam/hear_message(mob/M, msg)
	if(camera && on)
		for(var/obj/machinery/computer/security/telescreen/T in GLOB.machines)
			if(T.watchers[M] == camera)
				T.atom_say(msg)


/obj/item/videocam/advanced
	name = "advanced video camera"
	desc = "This video camera allows you to send live feeds even when attached to a belt."
	slot_flags = ITEM_SLOT_BELT

