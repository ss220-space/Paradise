/*
 * Camera
 */
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


/obj/item/camera/examine(mob/user)
	. = ..()
	. += span_notice("Alt-Click to change photo size.")
	. += span_notice("Alt-Shift-Click on [src] to toggle camera flashing")



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

/obj/item/camera/AltClick(mob/user)
	if(!issilicon(user) && (user.incapacitated() || HAS_TRAIT(user, TRAIT_HANDS_BLOCKED)))
		return

	var/nsize = tgui_input_list(user, "Photo Size", "Pick a size of resulting photo.", list(1,3,5,7))
	if(nsize)
		size = nsize
		to_chat(user, span_notice("Camera will now take [size]x[size] photos."))

/obj/item/camera/AltShiftClick(mob/user)
	if(!issilicon(usr) && (usr.incapacitated() || HAS_TRAIT(usr, TRAIT_HANDS_BLOCKED)))
		return

	flashing_lights = !flashing_lights

	to_chat(usr, span_notice("You turned [src] flashing lights [flashing_lights ? "on" : "off"], making natural light [flashing_lights ? "invisible" : "visible"]"))

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

/obj/item/camera/afterattack(atom/target, mob/user)
	if(!on || !pictures_left || ismob(target.loc))
		return

	playsound(loc, pick('sound/items/polaroid1.ogg', 'sound/items/polaroid2.ogg'), 75, 1, -3)
	if(flashing_lights)
		set_light(3, 2, LIGHT_COLOR_TUNGSTEN, l_on = TRUE)
		addtimer(CALLBACK(src, TYPE_PROC_REF(/atom, set_light), 0), 2)
	pictures_left--
	desc = "A polaroid camera. It has [pictures_left] photos left."
	to_chat(user, span_notice("[pictures_left] photos left."))
	on = FALSE
	update_icon(UPDATE_ICON_STATE)
	if(istype(src, /obj/item/camera/spooky))
		if(user.mind && user.mind.assigned_role == JOB_TITLE_CHAPLAIN && see_ghosts)
			if(prob(24))
				handle_haunt(user)
	addtimer(CALLBACK(src, PROC_REF(delayed_turn_on)), 6.4 SECONDS)
	captureimage(target, user) // It's expensive proc so that's why we do it after all the cheap ones


/obj/item/camera/proc/delayed_turn_on()
	on = TRUE
	update_icon(UPDATE_ICON_STATE)


/obj/item/camera/proc/can_capture_turf(turf/T, mob/user)
	var/viewer = user
	if(user.client)		//To make shooting through security cameras possible
		viewer = user.client.eye
	var/can_see = (T in view(viewer)) //No x-ray vision cameras.
	return can_see

/obj/item/camera/proc/captureimage(atom/target, mob/user)
	var/turf/target_turf = get_turf(target)
	var/list/turfs = list()
	var/log = "Made by [user.name] in [get_area(user)]. "
	var/mobs = ""
	var/get_blueprints = FALSE
	var/range = size * 2 + 1
	for(var/turf/placeholder as anything in CORNER_BLOCK_OFFSET(target_turf, range, range, -size, -size))
		while(isopenspaceturf(placeholder)) //Multi-z photography
			placeholder = GET_TURF_BELOW(placeholder)
			if(!placeholder)
				break

		if(placeholder && ((isAI(user) && GLOB.cameranet.checkTurfVis(placeholder)) || can_capture_turf(placeholder, user)))
			turfs += placeholder
			mobs += get_mobs(placeholder)
			log += add_log(placeholder)
			if(locate(/obj/item/areaeditor/blueprints) in placeholder)
				get_blueprints = TRUE

	var/datum/picture/P = createpicture(target, user, turfs, mobs, log, get_blueprints)
	printpicture(user, P)

/obj/item/camera/proc/createpicture(atom/target, mob/user, list/turfs, mobs, logs, have_blueprints = FALSE)
	var/range = size * 2 + 1
	var/clone_area = SSmapping.request_turf_block_reservation(range, range, 1)
	var/icon/photoimage = camera_get_icon(turfs, target, user, size*32, clone_area, size, range)
	qdel(clone_area)
	photoimage.Blend("#000", ICON_UNDERLAY)


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
	P.fields["blueprints"] = have_blueprints

	return P

/obj/item/camera/proc/printpicture(mob/user, datum/picture/P)
	var/obj/item/photo/Photo = new/obj/item/photo()
	Photo.loc = user.loc
	if(!user.get_inactive_hand())
		user.put_in_inactive_hand(Photo)

	Photo.construct(P)

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


/*
 * Digital Camera
 */
/obj/item/camera/digital
	name = "digital camera"
	desc = "A digital camera. A small screen shows there is space for 10 photos left."
	var/list/datum/picture/saved_pictures = list()
	pictures_left = 30
	var/max_storage = 10

/obj/item/camera/digital/examine(mob/user)
	. = ..()
	. += span_notice("Ctrl-Click to print picture.")
	. += span_notice("Ctrl-Shift-Click to delete picture.")

/obj/item/camera/digital/afterattack(atom/target, mob/user)
	if(!on || !pictures_left || ismob(target.loc)) return
	captureimage(target, user)

	playsound(loc, pick('sound/items/polaroid1.ogg', 'sound/items/polaroid2.ogg'), 75, 1, -3)

	desc = "A digital camera. A small screen shows that there are currently [length(saved_pictures)] pictures stored."
	on = FALSE
	update_icon(UPDATE_ICON_STATE)
	addtimer(CALLBACK(src, TYPE_PROC_REF(/obj/item/camera, delayed_turn_on)), 6.4 SECONDS)


/obj/item/camera/digital/captureimage(atom/target, mob/user)
	if(saved_pictures.len >= max_storage)
		to_chat(user, span_notice("Maximum photo storage capacity reached."))
		return
	to_chat(user, "Picture saved.")
	var/turf/target_turf = get_turf(target)
	var/list/turfs = list()
	var/log = "Made by [user.name] in [get_area(user)]. "
	var/mobs = ""
	var/get_blueprints = FALSE
	var/range = size * 2 + 1
	for(var/turf/placeholder as anything in CORNER_BLOCK_OFFSET(target_turf, range, range, -size, -size))
		while(isopenspaceturf(placeholder)) //Multi-z photography
			placeholder = GET_TURF_BELOW(placeholder)
			if(!placeholder)
				break

		if(placeholder && ((isAI(user) && GLOB.cameranet.checkTurfVis(placeholder)) || can_capture_turf(placeholder, user)))
			turfs += placeholder
			mobs += get_mobs(placeholder)
			log += add_log(placeholder)
			if(locate(/obj/item/areaeditor/blueprints) in placeholder)
				get_blueprints = TRUE

	var/datum/picture/P = createpicture(target, user, turfs, mobs, get_blueprints, log)
	saved_pictures += P

/obj/item/camera/digital/CtrlClick(mob/user)
	if(saved_pictures.len == 0)
		to_chat(user, span_warning("No images saved."))
		return
	if(pictures_left == 0)
		to_chat(user, span_warning("There is no film left to print."))
		return
	var/datum/picture/P = tgui_input_list(user, "Select image to print", "Print image", saved_pictures)
	if(pictures_left == 0)
		to_chat(user, span_warning("There is no film left to print."))
		return
	if(P)
		printpicture(user, P)
		pictures_left--

/obj/item/camera/digital/CtrlShiftClick(mob/user)
	if(saved_pictures.len == 0)
		to_chat(user, span_warning("No images saved"))
		return
	var/datum/picture/P = tgui_input_list(user, "Select image to delete", "Delete image", saved_pictures)
	if(P)
		saved_pictures -= P

