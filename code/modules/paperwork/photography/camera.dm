/*
 * Camera
 */
/obj/item/camera //TODO: translate `/obj/item/flash/cameraflash` when this file getting translated
	name = "camera"
	desc = "A polaroid camera. 10 photos left."
	icon_state = "camera"
	item_state = "camera"
	w_class = WEIGHT_CLASS_SMALL
	slot_flags = ITEM_SLOT_BELT|ITEM_SLOT_NECK
	interaction_flags_click = NONE
	var/list/matter = list("metal" = 2000)
	var/pictures_max = 10
	var/pictures_left = 10
	var/on = 1
	var/icon_on = "camera"
	var/icon_off = "camera_off"
	var/item_on = "camera"
	var/item_off = "camera_off"
	var/picture_size = 3
	var/see_ghosts = 0 //for the spoop of it
	var/flashing_lights = TRUE

	sprite_sheets = list(
		SPECIES_GREY = 'icons/mob/clothing/species/grey/neck.dmi',
		SPECIES_KIDAN = 'icons/mob/clothing/species/kidan/neck.dmi',
		SPECIES_DRASK = 'icons/mob/clothing/species/drask/neck.dmi',
		SPECIES_VOX = 'icons/mob/clothing/species/vox/neck.dmi',
		SPECIES_MONKEY = 'icons/mob/clothing/species/monkey/neck.dmi',
		SPECIES_WRYN = 'icons/mob/clothing/species/wryn/neck.dmi',
	)

/obj/item/camera/get_ru_names()
	return list(
		NOMINATIVE = "фотоаппарат",
		GENITIVE = "фотоаппарата",
		DATIVE = "фотоаппарату",
		ACCUSATIVE = "фотоаппарат",
		INSTRUMENTAL = "фотоаппаратом",
		PREPOSITIONAL = "фотоаппарате"
	)

/obj/item/camera/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/shell,\
	list(new /obj/item/circuit_component/camera,\
	new /obj/item/circuit_component/remotecam/polaroid),\
	SHELL_CAPACITY_SMALL)

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

/obj/item/camera/click_alt(mob/user)
	if(!issilicon(user) && (user.incapacitated() || HAS_TRAIT(user, TRAIT_HANDS_BLOCKED))) // silicons have inbuilt cameras, that' why unique check here
		return

	var/new_picture_size = tgui_input_list(user, "Photo Size", "Pick a size of resulting photo.", list(1,3,5,7))
	if(new_picture_size)
		picture_size = new_picture_size
		to_chat(user, span_notice("Camera will now take [picture_size]x[picture_size] photos."))
	return CLICK_ACTION_SUCCESS

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
			if(see_ghosts && isobserver(M))
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
	if(istype(user) && user.client)		//To make shooting through security cameras possible
		viewer = user.client.eye
	var/can_see = (T in view(viewer)) //No x-ray vision cameras.
	return can_see

/obj/item/camera/proc/captureimage(atom/target, atom/user)
	var/turf/target_turf = get_turf(target)
	var/list/turfs = list()
	var/log = "Made by [user.name] in [get_area(user)]. "
	var/mobs = ""
	var/get_blueprints = FALSE
	var/range = picture_size * 2 + 1
	for(var/turf/placeholder as anything in CORNER_BLOCK_OFFSET(target_turf, range, range, -picture_size, -picture_size))
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

/obj/item/camera/proc/createpicture(atom/target, atom/user, list/turfs, mobs, logs, have_blueprints = FALSE)
	var/range = picture_size * 2 + 1
	var/clone_area = SSmapping.request_turf_block_reservation(range, range, 1)
	var/icon/photoimage = camera_get_icon(turfs, target, user, picture_size * 32, clone_area, picture_size, range)
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
	if(istype(src,/obj/item/camera/digital) && ishuman(user))
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
	P.fields["size"] = picture_size
	P.fields["log"] = logs
	P.fields["blueprints"] = have_blueprints

	return P

/obj/item/camera/proc/printpicture(mob/user, datum/picture/P)
	var/obj/item/photo/Photo = new/obj/item/photo()
	Photo.loc = user.loc
	if(istype(user) && !user.get_inactive_hand())
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
	SEND_SOUND(user, sound(pick(creepyasssounds)))

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
	. += span_notice("<b>Ctrl+ЛКМ</b> to print picture.")
	. += span_notice("<b>Ctrl+Shift+ЛКМ</b> to delete picture.")

/obj/item/camera/digital/afterattack(atom/target, mob/user)
	if(!on || !pictures_left || ismob(target.loc)) return
	captureimage(target, user)

	playsound(loc, pick('sound/items/polaroid1.ogg', 'sound/items/polaroid2.ogg'), 75, 1, -3)

	desc = "A digital camera. A small screen shows that there are currently [length(saved_pictures)] pictures stored."
	on = FALSE
	update_icon(UPDATE_ICON_STATE)
	addtimer(CALLBACK(src, TYPE_PROC_REF(/obj/item/camera, delayed_turn_on)), 6.4 SECONDS)

/obj/item/camera/digital/captureimage(atom/target, mob/user)
	if(length(saved_pictures) >= max_storage)
		to_chat(user, span_notice("Maximum photo storage capacity reached."))
		return
	to_chat(user, "Picture saved.")
	var/turf/target_turf = get_turf(target)
	var/list/turfs = list()
	var/log = "Made by [user.name] in [get_area(user)]. "
	var/mobs = ""
	var/get_blueprints = FALSE
	var/range = picture_size * 2 + 1
	for(var/turf/placeholder as anything in CORNER_BLOCK_OFFSET(target_turf, range, range, -picture_size, -picture_size))
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
	if(length(saved_pictures) == 0)
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
	if(length(saved_pictures) == 0)
		to_chat(user, span_warning("No images saved"))
		return
	var/datum/picture/P = tgui_input_list(user, "Select image to delete", "Delete image", saved_pictures)
	if(P)
		saved_pictures -= P


#define MIN_PICTURE_SIZE 1
#define MAX_PICTURE_SIZE 7
/obj/item/circuit_component/camera
	display_name = "Камера"
	desc = "Камера Polaroid, делающая снимки при вызове. \
			Порты координат изображения определяются относительно положения камеры."
	circuit_flags = CIRCUIT_FLAG_INPUT_SIGNAL

	/// The atom that was photographed from either user click or trigger input.
	var/datum/port/output/photographed_atom
	/// The item that was added/removed.
	var/datum/port/output/picture_taken
	/// If set, the trigger input will target this atom.
	var/datum/port/input/picture_target
	/// If the above is unset, these coordinates will be used.
	var/datum/port/input/picture_coord_x
	var/datum/port/input/picture_coord_y
	/// Adjusts the picture_size variable of the camera.
	var/datum/port/input/adjust_size

	/// The camera this circut is attached to.
	var/obj/item/camera/camera

/obj/item/circuit_component/camera/Destroy()
	if(camera)
		unregister_usb_parent(camera)
	photographed_atom = null
	picture_taken = null
	picture_target = null
	picture_coord_x = null
	picture_coord_y = null
	adjust_size = null
	. = ..()

/obj/item/circuit_component/camera/populate_ports()
	picture_taken = add_output_port("Снимок сделан", PORT_TYPE_SIGNAL)
	photographed_atom = add_output_port("Цель", PORT_TYPE_ATOM)

	picture_target = add_input_port("Цель", PORT_TYPE_ATOM)
	picture_coord_x = add_input_port("X", PORT_TYPE_NUMBER)
	picture_coord_y = add_input_port("Y", PORT_TYPE_NUMBER)
	adjust_size = add_input_port("Размер", PORT_TYPE_NUMBER, trigger = PROC_REF(sanitize_picture_size))

/obj/item/circuit_component/camera/register_shell(atom/movable/shell)
	. = ..()
	camera = shell
	RegisterSignal(shell, COMSIG_CAMERA_IMAGE_CAPTURED, PROC_REF(on_image_captured))

/obj/item/circuit_component/camera/unregister_shell(atom/movable/shell)
	UnregisterSignal(shell, COMSIG_CAMERA_IMAGE_CAPTURED)
	camera = null
	return ..()

/obj/item/circuit_component/camera/proc/sanitize_picture_size()
	camera.picture_size = clamp(adjust_size.value, MIN_PICTURE_SIZE, MAX_PICTURE_SIZE)


/obj/item/circuit_component/camera/proc/on_image_captured(obj/item/camera/source, atom/target, mob/user)
	SIGNAL_HANDLER
	photographed_atom.set_output(target)
	picture_taken.set_output(COMPONENT_SIGNAL)

/obj/item/circuit_component/camera/input_received(datum/port/input/port)
	var/atom/target = picture_target.value
	if(!target)
		var/turf/our_turf = get_location()
		target = locate(our_turf.x + picture_coord_x.value, our_turf.y + picture_coord_y.value, our_turf.z)
		if(!target)
			return

	INVOKE_ASYNC(camera, TYPE_PROC_REF(/obj/item/camera, captureimage), target, parent.shell)

#undef MIN_PICTURE_SIZE
#undef MAX_PICTURE_SIZE
