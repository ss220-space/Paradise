/*
Almost every mining medic related stuff
*/

/obj/item/clothing/accessory/mining_camera
	name = "mining camera"
	desc = "Небольшая нагрудная видеокамера, обладающая массивным датчиком, позволяющим считывать датчики костюма с основной станции."
	ru_names = list(
		NOMINATIVE = "шахтёрская видеокамера",
		GENITIVE = "шахтёрской видеокамеры",
		DATIVE = "шахтёрской видеокамере",
		ACCUSATIVE = "шахтёрскую видеокамеру",
		INSTRUMENTAL = "шахтёрской видеокамерой",
		PREPOSITIONAL = "шахтёрской видеокамере"
	)
	gender = FEMALE
	lefthand_file = 'icons/mob/inhands/lavaland/misc_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/lavaland/misc_righthand.dmi'
	icon_state = "mining_camera"
	item_state = "mining_camera"
	allow_duplicates = FALSE
	slot = ACCESSORY_SLOT_UTILITY
	actions_types = list(/datum/action/item_action/accessory/mining_camera)

	/// Is our camera on
	var/on = FALSE
	/// Our portable camera
	var/obj/machinery/camera/portable/camera
	/// Can we see camera from intertainment network?
	var/news_feed = FALSE
	/// Fluff examine variable
	var/where_to = "планшет шахтёрского врача"
	/// Main feed network
	var/feed = "mining"

/obj/item/clothing/accessory/mining_camera/Destroy()
	if(on)
		update_camera_state()
	return ..()

/obj/item/clothing/accessory/mining_camera/examine(mob/user)
	. = ..()
	. += span_notice("Данный тип камер позволяет вести трансляцию как на [where_to], так и в развлекательную сеть станции. На текущий момент камера <b>[on ? "в" : "вы"]ключена</b>.")
	. += span_notice("Используйте <b>Alt+ЛКМ</b> чтобы переключить режим трансляции камеры в развлекательную сеть. На текущий момент ретрансляция на станцию <b>[news_feed ? "в" : "вы"]ключена</b>.")

/obj/item/clothing/accessory/mining_camera/add_eatable_component()
	return


/obj/item/clothing/accessory/mining_camera/attack_self(mob/user)
	. = ..()
	update_camera_state(user)

/obj/item/clothing/accessory/mining_camera/on_attached(obj/item/clothing/under/new_suit, mob/attacher)
	. = ..()
	if(. && isliving(has_suit.loc))
		var/mob/living/wearer = has_suit.loc
		ADD_TRAIT(wearer, TRAIT_MULTIZ_SUIT_SENSORS, UNIQUE_TRAIT_SOURCE(src))

/obj/item/clothing/accessory/mining_camera/on_removed(mob/detacher)
	. = ..()
	if(.)
		var/obj/item/clothing/under/old_suit = .
		if(isliving(old_suit.loc))
			var/mob/living/wearer = old_suit.loc
			REMOVE_TRAIT(wearer, TRAIT_MULTIZ_SUIT_SENSORS, UNIQUE_TRAIT_SOURCE(src))

/obj/item/clothing/accessory/mining_camera/attached_equip(mob/living/user)
	if(isliving(user))
		ADD_TRAIT(user, TRAIT_MULTIZ_SUIT_SENSORS, UNIQUE_TRAIT_SOURCE(src))

/obj/item/clothing/accessory/mining_camera/attached_unequip(mob/living/user)
	if(isliving(user))
		REMOVE_TRAIT(user, TRAIT_MULTIZ_SUIT_SENSORS, UNIQUE_TRAIT_SOURCE(src))

/obj/item/clothing/accessory/mining_camera/proc/update_camera_state(mob/living/carbon/user)
	if(on)
		if(news_feed)
			GLOB.active_video_cameras -= src
		camera.c_tag = null
		QDEL_NULL(camera)
	else
		if(news_feed)
			camera = new(src, list(feed, "news"), user.name)
			GLOB.active_video_cameras |= src
		else
			camera = new(src, list(feed), user.name)
	on = !on
	update_icon(UPDATE_ICON_STATE)
	to_chat(user, span_notice("Вы [on ? "в" : "вы"]ключили камеру. Ретрансляция на станцию [news_feed ? "в" : "вы"]ключена."))

	for(var/obj/machinery/computer/security/telescreen/entertainment/TV in GLOB.machines)
		TV.update_icon(UPDATE_OVERLAYS)

/obj/item/clothing/accessory/mining_camera/update_icon_state()
	. = ..()
	icon_state = "mining_camera[on ? "_on" : ""]"

/obj/item/clothing/accessory/mining_camera/click_alt(mob/user)
	if(on)
		balloon_alert(user, "сначала выключите камеру!")
		return CLICK_ACTION_BLOCKING
	else
		news_feed = !news_feed
		balloon_alert(user, "ретрансляция [news_feed ? "в" : "вы"]ключена!")
		return CLICK_ACTION_SUCCESS

/obj/item/storage/box/mining_cameras
	name = "mining camera box"
	desc = "Небольшая коробка, предназначенная для хранения шахтёрских видеокамер."
	ru_names = list(
		NOMINATIVE = "коробка с шахтёрскими видеокамерами",
		GENITIVE = "коробки с шахтёрскими видеокамерами",
		DATIVE = "коробке с шахтёрскими видеокамерами",
		ACCUSATIVE = "коробку с шахтёрскими видеокамерами",
		INSTRUMENTAL = "коробкой с шахтёрскими видеокамерами",
		PREPOSITIONAL = "коробке с шахтёрскими видеокамерами"
	)
	icon_state = "mining_camera_box"
	storage_slots =  12
	max_combined_w_class = INFINITY
	can_hold = list(
		/obj/item/clothing/accessory/mining_camera
	)

/obj/storage/box/mining_cameras/populate_contents()
	for(var/i in 1 to 12)
		new /obj/item/clothing/accessory/mining_camera(src)

/obj/item/camera_bug/mining
	name = "mining camera monitor"
	desc = "Небольшое устройство, считывающее данные с шахтёрских видеокамер. Позволяет следить за тем, как шахтёры борятся за жизнь на просторах Лаваленда."
	ru_names = list(
		NOMINATIVE = "шахтёрский монитор видеокамер",
		GENITIVE = "шахтёрского монитора видеокамер",
		DATIVE = "шахтёрскму монитору видеокамер",
		ACCUSATIVE = "шахтёрский монитор видеокамер",
		INSTRUMENTAL = "шахтёрским монитором видеокамер",
		PREPOSITIONAL = "шахтёрском мониторе видеокамер"
	)
	icon_state = "mining_monitor"
	lefthand_file = 'icons/mob/inhands/lavaland/misc_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/lavaland/misc_righthand.dmi'
	item_state	= "mining_monitor"
	origin_tech = "engineering=3"

/obj/item/camera_bug/mining/Initialize(mapload)
	. = ..()
	integrated_console.network = list("mining")
