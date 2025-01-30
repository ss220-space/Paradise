/**********************Mining Scanner**********************/
/obj/item/mining_scanner
	desc = "Устройство, которое сканирует окружающие породы на наличие полезных минералов, также может быть использован для предотвращения взрывов гибтонита.\
	 Для достижения наилучших результатов рекомендуется применять мезонные очки. Этот сканер оснащён динамиком, который можно переключать, используя сочетание клавиш <b>Alt+Click</b>"
	name = "manual mining scanner"
	ru_names = list(
        NOMINATIVE = "ручной шахтерский сканер",
        GENITIVE = "ручного шахтерского сканера",
        DATIVE = "ручному шахтерскому сканеру",
        ACCUSATIVE = "ручной шахтерский сканер",
        INSTRUMENTAL = "ручным шахтерским сканером",
        PREPOSITIONAL = "ручном шахтерском сканере"
	)
	icon = 'icons/obj/device.dmi'
	icon_state = "miningmanual"
	item_state = "analyzer"
	w_class = WEIGHT_CLASS_SMALL
	flags = CONDUCT
	slot_flags = ITEM_SLOT_BELT
	var/cooldown = 35
	var/current_cooldown = 0
	var/speaker = TRUE // Speaker that plays a sound when pulsed.
	var/soundone = 'sound/lavaland/area_scan1.ogg'
	var/soundtwo = 'sound/lavaland/area_scan2.ogg'

	origin_tech = "engineering=1;magnets=1"

/obj/item/mining_scanner/click_alt(mob/user)
	speaker = !speaker
	to_chat(user, span_notice("Вы переключаете режим работы динамика [declent_ru(GENITIVE)] на [speaker ? "<b>ВКЛ</b>" : "<b>ВЫКЛ</b>"]."))

/obj/item/mining_scanner/attack_self(mob/user)
	if(!user.client)
		return
	if(current_cooldown <= world.time)
		current_cooldown = world.time + cooldown
		mineral_scan_pulse(get_turf(user), 5)
		if(speaker)
			playsound(src, pick(soundone, soundtwo), 35)


//Debug item to identify all ore spread quickly
/obj/item/mining_scanner/admin

/obj/item/mining_scanner/admin/attack_self(mob/user)
	for(var/turf/simulated/mineral/M in world)
		if(M.scan_state)
			M.icon_state = M.scan_state
	qdel(src)

/obj/item/t_scanner/adv_mining_scanner
	desc = "Устройство, которое автоматически сканирует окружающие породы на наличие полезных минералов, также может быть использован для предотвращения взрывов гибтонита.\
	 Для достижения наилучших результатов рекомендуется применять мезонные очки.\
	 Этот сканер отличается расширенным радиусом действия и оснащён динамиком, который можно переключать, используя сочетание клавиш <b>Alt+Click</b>"
	name = "advanced automatic mining scanner"
	ru_names = list(
        NOMINATIVE = "продвинутый автоматический шахтерский сканер",
        GENITIVE = "продвинутого автоматического шахтерского сканера",
        DATIVE = "продвинутому автоматическому шахтерскому сканеру",
        ACCUSATIVE = "продвинутый автоматический шахтерский сканер",
        INSTRUMENTAL = "продвинутым автоматическим шахтерским сканером",
        PREPOSITIONAL = "продвинутом автоматическом шахтерском сканере"
	)
	icon_state = "adv_mining0"
	base_icon_state = "adv_mining"
	item_state = "analyzer"
	w_class = WEIGHT_CLASS_SMALL
	flags = CONDUCT
	slot_flags = ITEM_SLOT_BELT
	var/cooldown = 1 SECONDS
	var/current_cooldown = 0
	var/range = 9
	var/speaker = TRUE // Speaker that plays a sound when pulsed.
	var/soundone = 'sound/lavaland/area_scan1.ogg'
	var/soundtwo = 'sound/lavaland/area_scan2.ogg'

	origin_tech = "engineering=3;magnets=3"

/obj/item/t_scanner/adv_mining_scanner/click_alt(mob/user)
	speaker = !speaker
	to_chat(user, span_notice("Вы переключаете режим работы динамика [declent_ru(GENITIVE)] на [speaker ? "<b>ВКЛ</b>" : "<b>ВЫКЛ</b>"]."))

/obj/item/t_scanner/adv_mining_scanner/cyborg
	flags = CONDUCT
	speaker = FALSE //you know...


/obj/item/t_scanner/adv_mining_scanner/cyborg/Initialize(mapload)
	. = ..()
	ADD_TRAIT(src, TRAIT_NODROP, CYBORG_ITEM_TRAIT)


/obj/item/t_scanner/adv_mining_scanner/lesser
	desc = "Устройство, которое автоматически сканирует окружающие породы на наличие полезных минералов, также может быть использован для предотвращения взрывов гибтонита.\
	 Для достижения наилучших результатов рекомендуется применять мезонные очки. Этот сканер оснащён динамиком, который можно переключать, используя сочетание клавиш <b>Alt+Click</b>"
	name = "automatic mining scanner"
	ru_names = list(
        NOMINATIVE = "автоматический шахтерский сканер",
        GENITIVE = "автоматического шахтерского сканера",
        DATIVE = "автоматическому шахтерскому сканеру",
        ACCUSATIVE = "автоматический шахтерский сканер",
        INSTRUMENTAL = "автоматическим шахтерским сканером",
        PREPOSITIONAL = "автоматическом шахтерском сканере"
	)
	icon_state = "mining0"
	base_icon_state = "mining"
	range = 4
	cooldown = 50

/obj/item/mining_scanner/cyborg
	cooldown = 50
	flags = CONDUCT
	speaker = FALSE


/obj/item/mining_scanner/cyborg/Initialize(mapload)
	. = ..()
	ADD_TRAIT(src, TRAIT_NODROP, CYBORG_ITEM_TRAIT)


/obj/item/t_scanner/adv_mining_scanner/scan()
	if(current_cooldown <= world.time)
		current_cooldown = world.time + cooldown
		var/turf/t = get_turf(src)
		mineral_scan_pulse(t, range)
		if(speaker)
			playsound(src, pick(soundone, soundtwo), 35)

/proc/mineral_scan_pulse(turf/T, range = world.view)
	var/list/minerals = list()
	for(var/turf/simulated/mineral/M in range(range, T))
		if(M.scan_state)
			minerals += M
	if(LAZYLEN(minerals))
		for(var/turf/simulated/mineral/M in minerals)
			var/obj/effect/temp_visual/mining_overlay/oldC = locate(/obj/effect/temp_visual/mining_overlay) in M
			if(oldC)
				qdel(oldC)
			var/obj/effect/temp_visual/mining_overlay/C = new /obj/effect/temp_visual/mining_overlay(M)
			C.icon_state = M.scan_state

/obj/effect/temp_visual/mining_overlay
	plane = FULLSCREEN_PLANE
	layer = FLASH_LAYER
	icon = 'icons/effects/ore_visuals.dmi'
	appearance_flags = LONG_GLIDE //to avoid having TILE_BOUND in the flags, so that the 480x480 icon states let you see it no matter where you are
	duration = 35
	pixel_x = -224
	pixel_y = -224

/obj/effect/temp_visual/mining_overlay/Initialize(mapload)
	. = ..()
	animate(src, alpha = 0, time = duration, easing = EASE_IN)

/obj/item/t_scanner/adv_mining_scanner/bleary_eye
	name = "bleary eye"
	desc = "Глаз, вырванный из тела массивного сернистого странника. Даже спустя долгое время, он всё ещё движется и внимательно осматривает местность в поисках руды."
	ru_names = list(
		NOMINATIVE = "затуманенный глаз",
		GENITIVE = "затуманенного глаза",
		DATIVE = "затуманенному глазу",
		ACCUSATIVE = "затуманенный глаз",
		INSTRUMENTAL = "затуманенным глазом",
		PREPOSITIONAL = "затуманенном глазе"
	)
	icon = 'icons/obj/lavaland/lava_fishing.dmi'
	icon_state = "bleary_eye"
	lefthand_file = 'icons/mob/inhands/lavaland/fish_items_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/lavaland/fish_items_righthand.dmi'
	item_state = "bleary_eye"
	flags = NONE
	materials = null
	origin_tech = "magnets=6;biotech=6"
	speaker = FALSE
	range = 4
	cooldown = 3 SECONDS

/obj/item/t_scanner/adv_mining_scanner/bleary_eye/Initialize(mapload)
	. = ..()
	toggle_mode()

/obj/item/t_scanner/adv_mining_scanner/bleary_eye/update_icon_state()
	return

/obj/item/t_scanner/adv_mining_scanner/bleary_eye/attack_self(mob/user)
	return

/obj/item/t_scanner/adv_mining_scanner/bleary_eye/click_alt(mob/user)
	return NONE
