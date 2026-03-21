/// Global list of all cameras used for entertainment monitors
GLOBAL_LIST_EMPTY(active_entertainment_cameras)

#define BROADCAST_CAMERA_ACTION_TOGGLE "Переключить режим камеры"
#define BROADCAST_CAMERA_ACTION_CARTRIDGE "Вытащить ленту"

/obj/item/broadcast_camera
	name = "broadcast camera"
	desc = "Камера, что принимает киноленты и может быть установлена на штатив."
	icon = 'icons/obj/tripod_camera.dmi'
	icon_state = "broadcast_camera_off"
	item_state = "broadcast_camera_off"
	w_class = WEIGHT_CLASS_SMALL
	gender = FEMALE
	materials = list(MAT_METAL=2000)
	slot_flags = ITEM_SLOT_BELT
	/// The tape inside the camera. Required for being active
	var/obj/item/tape/tape
	/// Are we currently "filming"?
	var/active = FALSE
	/// Sound loop of the camera working
	var/datum/looping_sound/film_roll/soundloop
	/// The camera itself
	var/obj/machinery/camera/portable/no_ai/camera
	/// What network is used for the camera
	var/static/camera_network = "news"
	/// Range of sound capturing
	var/canhear_range = 7
	/// How often can we toggle it off and on
	var/toggle_cooldown_duration = 2 SECONDS
	/// The cooldown for toggling.
	COOLDOWN_DECLARE(toggle_cooldown)

/obj/item/broadcast_camera/Initialize(mapload)
	. = ..()
	soundloop = new(src, FALSE)

/obj/item/broadcast_camera/get_ru_names()
	return list(
		NOMINATIVE = "трансляционная камера",
		GENITIVE = "трансляционной камеры",
		DATIVE = "трансляционной камере",
		ACCUSATIVE = "трансляционную камеру",
		INSTRUMENTAL = "трансляционной камерой",
		PREPOSITIONAL = "трансляционной камере",
	)

/obj/item/broadcast_camera/Destroy(force)
	if(camera) // null until toggled on
		GLOB.active_entertainment_cameras -= camera
		QDEL_NULL(camera)

	QDEL_NULL(soundloop)

	if(tape)
		var/turf/our_turf = get_turf(src)
		our_turf ? tape.forceMove(our_turf) : qdel(tape)
		tape = null

	return ..()

/obj/item/broadcast_camera/attackby(obj/item/I, mob/user, params)
	if(!istype(I, /obj/item/tape))
		return ..()

	. = ATTACK_CHAIN_BLOCKED_ALL
	add_fingerprint(user)
	if(tape)
		loc.balloon_alert(user, "уже вставлено")
		return

	var/obj/item/tape/new_tape = I
	if(new_tape.ruined)
		loc.balloon_alert(user, "лента неисправна!")
		return
	if(!new_tape.remaining_capacity)
		loc.balloon_alert(user, "лента забита!")
		return

	if(!user.drop_transfer_item_to_loc(new_tape, src))
		return

	tape = new_tape
	loc.balloon_alert(user, "вставлено")
	playsound(loc, 'sound/items/taperecorder/taperecorder_close.ogg', 50, FALSE)

/obj/item/broadcast_camera/attack_self(mob/user)
	. = ..()
	var/list/possible_actions = list(BROADCAST_CAMERA_ACTION_TOGGLE)
	if(tape)
		possible_actions += BROADCAST_CAMERA_ACTION_CARTRIDGE

	var/choice = tgui_alert(user, "Что вы хотите сделать?", "Выбор действия", possible_actions)
	switch(choice)
		if(BROADCAST_CAMERA_ACTION_TOGGLE)
			toggle(user)
		if(BROADCAST_CAMERA_ACTION_CARTRIDGE)
			eject(user)

/// Proc to eject tape from the camera.
/obj/item/broadcast_camera/proc/eject(mob/user)
	if(!tape)
		return FALSE

	if(active)
		toggle(force = TRUE)

	loc.balloon_alert(user, "вытащено")
	playsound(src, 'sound/items/taperecorder/taperecorder_open.ogg', 50, FALSE)
	tape.forceMove_turf()
	if(user)
		user.put_in_hands(tape)
	tape = null
	return TRUE

/// Proc used to toggle the state of the camera.
/obj/item/broadcast_camera/proc/toggle(mob/user, force = FALSE)
	if(!force && !COOLDOWN_FINISHED(src, toggle_cooldown))
		user?.balloon_alert(user, "перегрев...")
		return

	if(!active)
		if(!tape)
			user?.balloon_alert(user, "требуется лента!")
			return
		init_camera(user)
		soundloop.start()
		START_PROCESSING(SSprocessing, src)
	else
		soundloop.stop()
		STOP_PROCESSING(SSprocessing, src)

	active = !active
	COOLDOWN_START(src, toggle_cooldown, toggle_cooldown_duration)
	update_appearance(UPDATE_ICON_STATE)
	update_feeds()

	if(!user)
		return

	var/message = active ? "включено" : "отключено"
	user.balloon_alert(user, message)
	user.update_held_items()

// Process the tape usage. Should probably be tape code but well
/obj/item/broadcast_camera/process(seconds_per_tick)
	if(!active || !tape)
		return PROCESS_KILL

	tape.used_capacity += seconds_per_tick
	tape.remaining_capacity = max(0, tape.max_capacity - tape.used_capacity)
	if(!tape.remaining_capacity)
		eject()
		return PROCESS_KILL

/// Proc used to initialize the internal camera
/obj/item/broadcast_camera/proc/init_camera(mob/user)
	if(!camera)
		var/camera_name = "broadcast [rand(100, 999)]"
		if(user)
			camera_name = tgui_input_text(user, "Введите название трансляции", "Название трансляции", user.name) || user.name
		camera = new(src, list(camera_network), camera_name)
		camera.toggle_cam(null, FALSE)
		GLOB.cameranet.cameras -= camera // removes camera from lists as well
		return

	if(!user)
		return

	var/change_broadcast_name = tgui_alert(user, "Желаете ли вы сменить название трансляции? Текущее название: \"[camera.c_tag]\".", "Смена названия трансляции", list("Да", "Нет"))
	if(change_broadcast_name == "Да")
		var/new_name = tgui_input_text(user, "Введите название трансляции", "Название трансляции", camera.c_tag) || user.name
		camera.c_tag = new_name

/// Proc used to update enternainment monitors about our existence and the cameranet about current state
/obj/item/broadcast_camera/proc/update_feeds()
	if(!camera)
		return

	if(active)
		GLOB.active_entertainment_cameras += camera
		GLOB.cameranet.cameras += camera // adds camera to monitor list
	else
		GLOB.active_entertainment_cameras -= camera
		GLOB.cameranet.cameras -= camera

	camera.toggle_cam(null, FALSE)

/obj/item/broadcast_camera/hear_talk(mob/speaker, list/message_pieces)
	. = ..()
	if(!camera || !active)
		return

	camera.hear_talk(speaker, message_pieces)

/obj/item/broadcast_camera/update_icon_state()
	if(active)
		icon_state = "broadcast_camera_on"
		item_state = "broadcast_camera_on"
		return
	icon_state = "broadcast_camera_off"
	item_state = "broadcast_camera_off"

#undef BROADCAST_CAMERA_ACTION_TOGGLE
#undef BROADCAST_CAMERA_ACTION_CARTRIDGE
