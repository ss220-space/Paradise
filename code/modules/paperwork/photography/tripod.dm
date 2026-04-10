/**
 * Contains the following:
 *
 * Folded and assemblied tripods
 *
 * Most of the stuff is inherited. The folded tripod item takes actions straight from the camera, and then the unfolded tripod takes
 * everything from the folded tripod that ends up inside the unfolded one.
 */

#define FOLDED_TRIPOD_ACTION_ASSEMBLY "Собрать штатив"
#define FOLDED_TRIPOD_ACTION_REMOVE_CAMERA "Снять камеру"
#define FOLDED_TRIPOD_ACTION_CAMERA "Другие действия с камерой"

/obj/item/tripod
	name = "folded tripod"
	desc = "Складной штатив для фиксации трансляционной камеры. Не требует инструментов для установки."
	icon = 'icons/obj/tripod_camera.dmi'
	icon_state = "broadcast_camera_tripod"
	item_state = "tripod"
	max_integrity = 150
	w_class = WEIGHT_CLASS_BULKY
	gender = MALE
	/// If the tripod structure was folded into this item, then we have it stored here and in contents
	var/obj/structure/tripod/built_tripod
	/// Camera attached to the tripod
	var/obj/item/broadcast_camera/camera

/obj/item/tripod/get_ru_names_cached()
	return camera ? list(
		NOMINATIVE = "сложенный штатив с камерой",
		GENITIVE = "сложенного штатива с камерой",
		DATIVE = "сложенному штативу с камерой",
		ACCUSATIVE = "сложенный штатив с камерой",
		INSTRUMENTAL = "сложенным штативом с камерой",
		PREPOSITIONAL = "сложенном штативе с камерой",
	) : list(
		NOMINATIVE = "сложенный штатив",
		GENITIVE = "сложенного штатива",
		DATIVE = "сложенному штативу",
		ACCUSATIVE = "сложенный штатив",
		INSTRUMENTAL = "сложенным штативом",
		PREPOSITIONAL = "сложенном штативе",
	)

/obj/item/tripod/Destroy()
	QDEL_NULL(built_tripod)
	if(camera)
		var/turf/our_turf = get_turf(src)
		our_turf ? camera.forceMove(our_turf) : qdel(camera)
		UnregisterSignal(camera, COMSIG_ATOM_UPDATE_APPEARANCE)
		camera = null
	return ..()

/obj/item/tripod/attack_self(mob/user)
	. = ..()
	var/list/possible_actions = list()
	if(loc != built_tripod) // Since the unfolded tripod takes actions from here, check if we are folded or not.
		possible_actions += FOLDED_TRIPOD_ACTION_ASSEMBLY
	if(camera)
		possible_actions += FOLDED_TRIPOD_ACTION_REMOVE_CAMERA
		possible_actions += FOLDED_TRIPOD_ACTION_CAMERA

	var/choice = tgui_alert(user, "Что вы хотите сделать?", "Выбор действия", possible_actions)
	switch(choice)
		if(FOLDED_TRIPOD_ACTION_ASSEMBLY)
			assembly(user, get_turf(src))
		if(FOLDED_TRIPOD_ACTION_REMOVE_CAMERA)
			try_detach_camera(user)
		if(FOLDED_TRIPOD_ACTION_CAMERA)
			camera.attack_self(user)

/obj/item/tripod/attackby(obj/item/I, mob/user, params)
	if(istype(I, /obj/item/broadcast_camera))
		try_attach_camera(I, user)
		return ATTACK_CHAIN_BLOCKED_ALL

	if(!camera)
		return ..()

	. = camera.attackby(I, user, params)
	if(!ATTACK_CHAIN_CANCEL_CHECK(.))
		return ..()

/// Proc to check if we can assembly the tripod by a given user on a given turf.
/obj/item/tripod/proc/assembly_checks(mob/user, turf/target_turf)
	if(!user || !target_turf)
		return FALSE

	if(!user.IsAdvancedToolUser())
		user.balloon_alert(user, "слишком сложно")
		return FALSE

	if(!target_turf.Adjacent(user))
		user.balloon_alert(user, "слишком далеко")
		return FALSE
	if(!issimulatedturf(target_turf))
		user.balloon_alert(user, "не подходящий пол")
		return FALSE
	if(isopenspaceturf(target_turf)) // No point in checking if its a spaceturf
		user.balloon_alert(user, "нет пола")
		return FALSE

	return TRUE

/**
 * Proc to assembly the tripod.
 *
 * If we have the build tripod stored, then we use that, or create a new one.
 * Afterwards we move src into the tripod for later use.
 */
/obj/item/tripod/proc/assembly(mob/user, turf/target_turf)
	if(!assembly_checks(user, target_turf))
		return

	user.balloon_alert(user, "сборка...")
	user.visible_message(
		span_notice("[user] начина[PLUR_ET_UT(user)] собирать [declent_ru(ACCUSATIVE)]."),
		ignored_mobs = user,
	)

	if(!do_after(user, 5 SECONDS, user, NONE, max_interact_count = 1, cancel_on_max = TRUE))
		return

	if(!user.drop_item_ground(src, silent = TRUE))
		user.balloon_alert(user, "приклеено к руке")
		return

	user.balloon_alert(user, "сборка завершена")
	user.visible_message(
		span_notice("[user] заверша[PLUR_ET_UT(user)] сборку [declent_ru(ACCUSATIVE)]."),
		ignored_mobs = user,
	)

	if(!built_tripod)
		built_tripod = new(src) // MUST be created inside src to work correctly

	contents -= built_tripod // avoiding cycling contents
	built_tripod.forceMove(target_turf)
	built_tripod.tripod_item = src
	forceMove(built_tripod)

/// Proc used to try to detach the camera from the tripod and put it in the remover's hands.
/obj/item/tripod/proc/try_detach_camera(mob/user)
	if(!camera)
		return

	user.balloon_alert(user, "открепление камеры...")
	user.visible_message(
		span_notice("[user] начина[PLUR_ET_UT(user)] откреплять [camera.declent_ru(ACCUSATIVE)] от [declent_ru(GENITIVE)]."),
		ignored_mobs = user,
	)

	if(!do_after(user, 3 SECONDS, user, NONE, max_interact_count = 1, cancel_on_max = TRUE))
		return

	user.balloon_alert(user, "камера откреплена")
	user.visible_message(
		span_notice("[user] открепля[PLUR_ET_UT(user)] [camera.declent_ru(ACCUSATIVE)] от [declent_ru(GENITIVE)]."),
		ignored_mobs = user,
	)

	detach_camera(user)

/// Helper proc to detach the camera. User argument is not required
/obj/item/tripod/proc/detach_camera(mob/user)
	if(!camera)
		return

	UnregisterSignal(camera, COMSIG_ATOM_UPDATE_APPEARANCE)
	camera.forceMove_turf()

	if(!user) // Some code repetition since the order of operations matters
		camera = null
		update_appearance()
		return

	user.put_in_hands(camera)
	camera = null
	update_appearance()
	user.update_held_items()

/**
 * Proc to attempt to attach a camera to the tripod.
 */
/obj/item/tripod/proc/try_attach_camera(obj/item/broadcast_camera/new_camera, mob/user)
	if(camera)
		user.balloon_alert(user, "уже есть!")
		return

	user.balloon_alert(user, "прикрепление камеры...")
	user.visible_message(
		span_notice("[user] начина[PLUR_ET_UT(user)] прикреплять [new_camera.declent_ru(ACCUSATIVE)] к [declent_ru(DATIVE)]."),
		ignored_mobs = user,
	)

	if(!do_after(user, 3 SECONDS, user, NONE, max_interact_count = 1, cancel_on_max = TRUE))
		return

	if(!user.drop_item_ground(new_camera, silent = TRUE))
		user.balloon_alert(user, "приклеено к руке")
		return

	user.balloon_alert(user, "камера прикреплена")
	user.visible_message(
		span_notice("[user] прикрепля[PLUR_ET_UT(user)] [new_camera.declent_ru(ACCUSATIVE)] к [declent_ru(DATIVE)]."),
		ignored_mobs = user,
	)

	attach_camera(new_camera, user)

/// Helper proc to attach a camera to the tripod. User argument is not required
/obj/item/tripod/proc/attach_camera(obj/item/broadcast_camera/new_camera, mob/user)
	if(!new_camera || camera)
		return

	camera = new_camera
	RegisterSignal(camera, COMSIG_ATOM_UPDATE_APPEARANCE, PROC_REF(on_camera_toggle))
	update_appearance()
	camera.forceMove(src)
	if(user)
		user.update_held_items()

/// Signal proc to listen from the camera to change stuff based on its active state
/obj/item/tripod/proc/on_camera_toggle(datum/source, updates)
	SIGNAL_HANDLER
	update_appearance()

/obj/item/tripod/hear_talk(mob/speaker, list/message_pieces)
	. = ..()
	camera?.hear_talk(speaker, message_pieces)

/obj/item/tripod/update_name(updates = ALL)
	. = ..()
	if(camera)
		name = "[initial(name)] with a camera"
	else
		name = initial(name)

/obj/item/tripod/update_desc(updates = ALL)
	. = ..()
	if(camera)
		desc = "[initial(desc)] На нём установлен[GEND_A_O_Y(camera)] [camera.declent_ru(NOMINATIVE)], котор[GEND_YI_AYA_OE_YE(camera)] сейчас [camera.active ? "включен[GEND_A_O_Y(camera)]" : "отключен[GEND_A_O_Y(camera)]"]."
	else
		desc = initial(desc)

/obj/item/tripod/update_icon_state()
	if(!camera)
		icon_state = initial(icon_state)
		item_state = initial(item_state)
		return

	if(camera.active)
		icon_state = "tripod_camera_on"
		item_state = "tripod_camera_on"
	else
		icon_state = "tripod_camera_off"
		item_state = "tripod_camera_off"

// Tripod with a camera by default
/obj/item/tripod/camera

/obj/item/tripod/camera/Initialize(mapload)
	. = ..()
	var/obj/item/broadcast_camera/new_camera = new
	attach_camera(new_camera)

#undef FOLDED_TRIPOD_ACTION_ASSEMBLY
#undef FOLDED_TRIPOD_ACTION_REMOVE_CAMERA
#undef FOLDED_TRIPOD_ACTION_CAMERA


#define TRIPOD_ACTION_FOLD "Сложить штатив"
#define TRIPOD_ACTION_CAMERA "Действия с камерой"

/obj/structure/tripod
	name = "tripod"
	desc = "Складной штатив для фиксации трансляционной камеры. Не требует инструментов для складывания."
	icon = 'icons/obj/tripod_camera.dmi'
	icon_state = "tripod_onground"
	max_integrity = 150
	gender = MALE
	anchored = TRUE
	density = TRUE
	/// If the tripod was built, then we have the folded tripod item stored in contents and in this variable
	var/obj/item/tripod/tripod_item

/obj/structure/tripod/Initialize(mapload)
	. = ..()
	if(istype(loc, /obj/item/tripod))
		tripod_item = loc
		update_appearance()
	else
		tripod_item = new(src)
	RegisterSignal(tripod_item, COMSIG_ATOM_UPDATE_APPEARANCE, PROC_REF(on_parent_item_update))

/obj/structure/tripod/Destroy(force)
	UnregisterSignal(tripod_item, COMSIG_ATOM_UPDATE_APPEARANCE)
	QDEL_NULL(tripod_item)
	return ..()

/obj/structure/tripod/get_ru_names_cached()
	return (tripod_item.camera) ? list(
		NOMINATIVE = "штатив с камерой",
		GENITIVE = "штатива с камерой",
		DATIVE = "штативу с камерой",
		ACCUSATIVE = "штатив с камерой",
		INSTRUMENTAL = "штативом с камерой",
		PREPOSITIONAL = "штативе с камерой",
	) : list(
		NOMINATIVE = "штатив",
		GENITIVE = "штатива",
		DATIVE = "штативу",
		ACCUSATIVE = "штатив",
		INSTRUMENTAL = "штативом",
		PREPOSITIONAL = "штативе",
	)

/// Signal proc called on tripod_item appearance update.
/obj/structure/tripod/proc/on_parent_item_update(datum/source, updates)
	SIGNAL_HANDLER
	update_appearance()

/obj/structure/tripod/attack_hand(mob/living/user, list/modifiers)
	. = ..()
	var/list/possible_actions = list(TRIPOD_ACTION_FOLD)
	if(tripod_item.camera)
		possible_actions += TRIPOD_ACTION_CAMERA

	var/choice = tgui_alert(user, "Что вы хотите сделать?", "Выбор действия", possible_actions)
	switch(choice)
		if(TRIPOD_ACTION_FOLD)
			try_fold(user)
		if(TRIPOD_ACTION_CAMERA)
			tripod_item.attack_self(user)

/**
 * Proc to fold the tripod.
 *
 * If we have the tripod item stored already, we use that, or we create a new one.
 * Afterwards we forcemove src into the item for later use, and put the item into user's hands.
 */
/obj/structure/tripod/proc/try_fold(mob/living/user)
	balloon_alert(user, "складывание штатива...")
	user.visible_message(
		span_notice("[user] начина[PLUR_ET_UT(user)] складывать [declent_ru(ACCUSATIVE)]."),
		ignored_mobs = user,
	)

	if(!do_after(user, 3 SECONDS, src, NONE, max_interact_count = 1, cancel_on_max = TRUE))
		return

	user.balloon_alert(user, "складывание завершено")
	user.visible_message(
		span_notice("[user] складыва[PLUR_ET_UT(user)] [declent_ru(ACCUSATIVE)]."),
		ignored_mobs = user,
	)

	contents -= tripod_item // avoiding cycling contents
	tripod_item.built_tripod = src
	forceMove(tripod_item)
	user.put_in_hands(tripod_item)

/obj/structure/tripod/attackby(obj/item/I, mob/user, params)
	. = tripod_item.attackby(I, user, params)
	if(!ATTACK_CHAIN_CANCEL_CHECK(.))
		return ..()

/obj/structure/tripod/wrench_act(mob/living/user, obj/item/I)
	. = TRUE
	if(!I.use_tool(src, user, 0, volume = I.tool_volume))
		return
	if(!anchored && !isinspace())
		set_anchored(TRUE)
		WRENCH_ANCHOR_MESSAGE
	else if(anchored)
		set_anchored(FALSE)
		WRENCH_UNANCHOR_MESSAGE
	playsound(src, 'sound/items/deconstruct.ogg', 50, TRUE)

/obj/structure/tripod/hear_talk(mob/speaker, list/message_pieces)
	. = ..()
	tripod_item.hear_talk(speaker, message_pieces)

/obj/structure/tripod/update_name(updates = ALL)
	. = ..()
	if(tripod_item.camera)
		name = "[initial(name)] with a camera"
	else
		name = initial(name)

/obj/structure/tripod/update_desc(updates = ALL)
	. = ..()
	if(tripod_item)
		desc = tripod_item.desc
	else
		desc = initial(desc)

/obj/structure/tripod/update_icon_state()
	if(!tripod_item.camera)
		icon_state = initial(icon_state)
		return

	if(tripod_item.camera.active)
		icon_state = "tripod_onground_camera_on"
	else
		icon_state = "tripod_onground_camera_off"

#undef TRIPOD_ACTION_FOLD
#undef TRIPOD_ACTION_CAMERA
