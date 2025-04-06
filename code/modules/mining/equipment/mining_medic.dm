/*
Almost every mining medic related stuff
*/

/obj/item/clothing/accessory/camera
	name = "mining camera"
	desc = "Небольшая нагрудная видеокамера, обладающая массивным датчиком, позволяющим считывать датчики костюма с основной станции. \
			Данный тип камер позволяет вести трансляцию как на планшет шахтёрского врача, так и в развлекательную сеть станции."
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
	/// Main feed network
	var/feed = "mining"
	/// Can detect multiz sensors
	var/multiz = TRUE

/obj/item/clothing/accessory/camera/Destroy()
	GLOB.active_video_cameras -= src
	camera.c_tag = null
	QDEL_NULL(camera)
	return ..()

/obj/item/clothing/accessory/camera/examine(mob/user)
	. = ..()
	. += span_notice("Камера <b>[on ? "в" : "вы"]ключена</b>.")
	. += span_notice("Ретрансляция на станцию <b>[news_feed ? "в" : "вы"]ключена</b>. Используйте <b>Alt+ЛКМ</b>, чтобы переключить режим трансляции камеры в развлекательную сеть.")

/obj/item/clothing/accessory/camera/add_eatable_component()
	return

/obj/item/clothing/accessory/camera/attack_self(mob/user)
	. = ..()
	update_camera_state(user)

/obj/item/clothing/accessory/camera/on_attached(obj/item/clothing/under/new_suit, mob/attacher)
	. = ..()
	if(. && isliving(has_suit.loc) && multiz)
		var/mob/living/wearer = has_suit.loc
		ADD_TRAIT(wearer, TRAIT_MULTIZ_SUIT_SENSORS, UNIQUE_TRAIT_SOURCE(src))

/obj/item/clothing/accessory/camera/on_removed(mob/detacher)
	. = ..()
	if(.)
		var/obj/item/clothing/under/old_suit = .
		if(isliving(old_suit.loc) && multiz)
			var/mob/living/wearer = old_suit.loc
			REMOVE_TRAIT(wearer, TRAIT_MULTIZ_SUIT_SENSORS, UNIQUE_TRAIT_SOURCE(src))

/obj/item/clothing/accessory/camera/attached_equip(mob/living/user)
	if(isliving(user) && multiz)
		ADD_TRAIT(user, TRAIT_MULTIZ_SUIT_SENSORS, UNIQUE_TRAIT_SOURCE(src))

/obj/item/clothing/accessory/camera/attached_unequip(mob/living/user)
	if(isliving(user) && multiz)
		REMOVE_TRAIT(user, TRAIT_MULTIZ_SUIT_SENSORS, UNIQUE_TRAIT_SOURCE(src))

/obj/item/clothing/accessory/camera/proc/update_camera_state(mob/living/carbon/user, force = FALSE)
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
	if(!force)
		balloon_alert(user, "камера [on ? "в" : "вы"]ключена")

	for(var/obj/machinery/computer/security/telescreen/entertainment/TV in GLOB.machines)
		TV.update_icon(UPDATE_OVERLAYS)

/obj/item/clothing/accessory/camera/update_icon_state()
	. = ..()
	icon_state = "[initial(icon_state)][on ? "_on" : ""]"

/obj/item/clothing/accessory/camera/click_alt(mob/user)
	if(on)
		balloon_alert(user, "сначала выключите камеру!")
		return CLICK_ACTION_BLOCKING
	news_feed = !news_feed
	balloon_alert(user, "ретрансляция [news_feed ? "в" : "вы"]ключена")
	return CLICK_ACTION_SUCCESS

/obj/item/clothing/accessory/camera/emp_act(severity)
	. = ..()
	if(on)
		update_camera_state(force = TRUE)

/obj/item/clothing/accessory/camera/security
	name = "security camera"
	desc = "Небольшая нагрудная камера с логотипом НаноТрейзен. Окрашена в чёрные цвета. Позволяет демонстрировать ваше пренебрежение законом в прямом эфире. \
			Данный тип камер позволяет вести трансляцию как на планшет службы безопасности, так и в развлекательную сеть станции."
	ru_names = list(
		NOMINATIVE = "нагрудная видеокамера",
		GENITIVE = "нагрудной видеокамеры",
		DATIVE = "нагрудной видеокамере",
		ACCUSATIVE = "нагрудную видеокамеру",
		INSTRUMENTAL = "нагрудной видеокамерой",
		PREPOSITIONAL = "нагрудной видеокамере"
	)
	icon_state = "sec_camera"
	item_state = "sec_camera"
	slot = ACCESSORY_SLOT_DECOR //No one will remove their holster for a camera
	feed = "secfeed"
	multiz = TRUE //maybe change that, for now true

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
		/obj/item/clothing/accessory/camera
	)

/obj/item/storage/box/mining_cameras/populate_contents()
	for(var/i in 1 to 12)
		new /obj/item/clothing/accessory/camera(src)

/obj/item/storage/box/sec_cameras
	name = "mining camera box"
	desc = "Небольшая коробка, предназначенная для хранения нагрудных видеокамер службы безопасности."
	ru_names = list(
		NOMINATIVE = "коробка с нагрудными видеокамерами",
		GENITIVE = "коробки с нагрудными видеокамерами",
		DATIVE = "коробке с нагрудными видеокамерами",
		ACCUSATIVE = "коробку с нагрудными видеокамерами",
		INSTRUMENTAL = "коробкой с нагрудными видеокамерами",
		PREPOSITIONAL = "коробке с нагрудными видеокамерами"
	)
	icon_state = "security_camera_box"

/obj/item/storage/box/sec_cameras/populate_contents()
	for(var/i in 1 to 12)
		new /obj/item/clothing/accessory/camera/security(src)

/obj/item/camera_bug/mining
	name = "mining camera monitor"
	desc = "Небольшое устройство, считывающее данные с шахтёрских видеокамер. Позволяет следить за тем, как шахтёры борятся за жизнь на просторах Лаваленда."
	ru_names = list(
		NOMINATIVE = "шахтёрский монитор видеокамер",
		GENITIVE = "шахтёрского монитора видеокамер",
		DATIVE = "шахтёрскому монитору видеокамер",
		ACCUSATIVE = "шахтёрский монитор видеокамер",
		INSTRUMENTAL = "шахтёрским монитором видеокамер",
		PREPOSITIONAL = "шахтёрском мониторе видеокамер"
	)
	icon_state = "mining_monitor"
	lefthand_file = 'icons/mob/inhands/lavaland/misc_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/lavaland/misc_righthand.dmi'
	item_state = "mining_monitor"
	origin_tech = "engineering=3"

/obj/item/camera_bug/mining/Initialize(mapload)
	. = ..()
	integrated_console.network = list("mining")

/obj/item/camera_bug/security
	name = "security camera monitor"
	desc = "Небольшой планшет, считывающий данные с нагрудных камер службы безопасности. Позволяет вам наблюдать в прямом эфире, как ваши офицеры поддерживают закон и порядок на станции. Данная модель крайне уязвима к ионным бурям."
	ru_names = list(
		NOMINATIVE = "офицерский монитор видеокамер",
		GENITIVE = "офицерского монитора видеокамер",
		DATIVE = "офицерскому монитору видеокамер",
		ACCUSATIVE = "офицерский монитор видеокамер",
		INSTRUMENTAL = "офицерским монитором видеокамер",
		PREPOSITIONAL = "офицерском мониторе видеокамер"
	)
	icon_state = "sec_monitor"
	lefthand_file = 'icons/mob/inhands/lavaland/misc_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/lavaland/misc_righthand.dmi'
	item_state = "sec_monitor"
	origin_tech = "engineering=3"

/obj/item/camera_bug/security/Initialize(mapload)
	. = ..()
	integrated_console.network = list("secfeed")
	integrated_console.affected_by_blackout = TRUE
