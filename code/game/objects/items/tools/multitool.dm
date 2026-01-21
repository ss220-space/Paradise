#define PROXIMITY_NONE ""
#define PROXIMITY_ON_SCREEN "_red"
#define PROXIMITY_NEAR "_yellow"

/obj/item/multitool
	name = "multimeter"
	desc = "Электрический прибор для измерения параметров тока и прозвонки электрических цепей. \
			Результаты ЭКГ, снятого данным аппаратом, не признаются ни одной клиникой."
	gender = MALE
	icon = 'icons/obj/device.dmi'
	icon_state = "multitool"
	righthand_file = 'icons/mob/inhands/tools_righthand.dmi'
	lefthand_file = 'icons/mob/inhands/tools_lefthand.dmi'
	belt_icon = "multitool"
	flags = CONDUCT
	force = 5.0
	slot_flags = ITEM_SLOT_BELT
	w_class = WEIGHT_CLASS_SMALL
	throw_speed = 3
	drop_sound = 'sound/items/handling/drop/multitool_drop.ogg'
	pickup_sound = 'sound/items/handling/pickup/multitool_pickup.ogg'
	materials = list(MAT_METAL=50, MAT_GLASS=20)
	origin_tech = "magnets=1;engineering=2"
	tool_behaviour = TOOL_MULTITOOL
	toolbox_radial_menu_compatibility = TRUE
	hitsound = 'sound/weapons/tap.ogg'
	/// Shows what a wire does if set to TRUE
	var/shows_wire_information = FALSE
	/// Simple machine buffer for device linkage
	var/obj/machinery/buffer
	var/datum/multitool_menu_host/menu
	var/emp_shielded = FALSE
	var/broken_type = /obj/item/multitool_broken

/obj/item/multitool/get_ru_names()
	return list(
		NOMINATIVE = "мультиметр",
		GENITIVE = "мультиметра",
		DATIVE = "мультиметру",
		ACCUSATIVE = "мультиметр",
		INSTRUMENTAL = "мультиметром",
		PREPOSITIONAL = "мультиметре",
	)

/obj/item/multitool/Initialize(mapload)
	. = ..()
	menu = new(src)

/obj/item/multitool/emp_act(severity)
	if(emp_shielded)
		return
	var/obj/item/broken_item = new broken_type(drop_location())
	if(ismob(loc))
		var/mob/holder = loc
		holder.temporarily_remove_item_from_inventory(src)
		holder.put_in_hands(broken_item)
	qdel(src)

/obj/item/multitool/proc/IsBufferA(typepath)
	if(!buffer)
		return 0
	return istype(buffer,typepath)

/obj/item/multitool/multitool_check_buffer(user, silent = FALSE)
	return TRUE

/// Loads a machine into memory, returns TRUE if it does
/obj/item/multitool/proc/set_multitool_buffer(mob/user, obj/machinery/M)
	if(!ismachinery(M))
		balloon_alert(user, "неподходящий объект!")
		return
	buffer = M
	balloon_alert(user, "данные загружены в буфер")
	return TRUE

/obj/item/multitool/attack_self(mob/user)
	menu.interact(user)

/obj/item/multitool/Destroy()
	buffer = null
	QDEL_NULL(menu)
	return ..()

/obj/item/multitool_broken
	name = "broken multimeter"
	desc = "Электрический прибор для измерения параметров тока и прозвонки электрических цепей. \
			Похоже, что он полностью сгорел."
	icon = 'icons/obj/device.dmi'
	icon_state = "multitool_broken"
	belt_icon = "multitool_broken"
	righthand_file = 'icons/mob/inhands/tools_righthand.dmi'
	lefthand_file = 'icons/mob/inhands/tools_lefthand.dmi'
	w_class = WEIGHT_CLASS_SMALL
	materials = list(MAT_METAL=50, MAT_GLASS=20)

/obj/item/multitool_broken/get_ru_names()
	return list(
		NOMINATIVE = "сломанный мультиметр",
		GENITIVE = "сломанного мультиметра",
		DATIVE = "сломанному мультиметру",
		ACCUSATIVE = "сломанный мультиметр",
		INSTRUMENTAL = "сломанным мультиметром",
		PREPOSITIONAL = "сломанном мультиметре",
	)

// Syndicate device disguised as a multitool; it will turn red when an AI camera is nearby.
/obj/item/multitool/ai_detect
	var/track_cooldown = 0
	/// How often it checks for proximity
	var/track_delay = 10
	var/detect_state = PROXIMITY_NONE
	/// Glows red when inside
	var/rangealert = 8
	/// Glows yellow when inside
	var/rangewarning = 20
	origin_tech = "magnets=1;engineering=2;syndicate=1"
	emp_shielded = TRUE

/obj/item/multitool/ai_detect/New()
	..()
	START_PROCESSING(SSobj, src)

/obj/item/multitool/ai_detect/Destroy()
	STOP_PROCESSING(SSobj, src)
	return ..()

/obj/item/multitool/ai_detect/update_icon_state()
	icon_state = "[initial(icon_state)][detect_state]"

/obj/item/multitool/ai_detect/process()
	if(track_cooldown > world.time)
		return
	detect_state = PROXIMITY_NONE
	multitool_detect()
	update_icon(UPDATE_ICON_STATE)
	track_cooldown = world.time + track_delay

/obj/item/multitool/ai_detect/proc/multitool_detect()
	var/turf/our_turf = get_turf(src)
	for(var/mob/living/silicon/ai/AI in GLOB.ai_list)
		if(AI.cameraFollow == src)
			detect_state = PROXIMITY_ON_SCREEN
			break

	if(!detect_state && GLOB.cameranet.chunkGenerated(our_turf.x, our_turf.y, our_turf.z))
		var/datum/camerachunk/chunk = GLOB.cameranet.getCameraChunk(our_turf.x, our_turf.y, our_turf.z)
		if(!chunk)
			return
		for(var/mob/camera/aiEye/A in chunk.seenby)
			if(!A.ai_detector_visible)
				continue
			var/turf/detect_turf = get_turf(A)
			if(get_dist(our_turf, detect_turf) < rangealert)
				detect_state = PROXIMITY_ON_SCREEN
				break
			if(get_dist(our_turf, detect_turf) < rangewarning)
				detect_state = PROXIMITY_NEAR
				break

/obj/item/multitool/ai_detect/admin
	desc = "Используется для подачи импульсов на провода, чтобы определить, какой из них перерезать. \
			Не одобряется врачами. Имеет странную бирку с надписью: \"Гриферить в удовольствие\"."
	track_delay = 5
	shows_wire_information = TRUE

/obj/item/multitool/ai_detect/admin/multitool_detect()
	var/turf/our_turf = get_turf(src)
	for(var/mob/J in urange(rangewarning, our_turf))
		if(check_rights(R_ADMIN, FALSE, J))
			detect_state = PROXIMITY_NEAR
			var/turf/detect_turf = get_turf(J)
			if(get_dist(our_turf, detect_turf) < rangealert)
				detect_state = PROXIMITY_ON_SCREEN
				break

/obj/item/multitool/cyborg
	desc = "Оптимизированная компактная версия стандартного мультиметра."
	toolspeed = 0.5
	emp_shielded = TRUE

/obj/item/multitool/abductor
	name = "alien multimeter"
	desc = "Прибор из неизвестного сплава с голографическим интерфейсом. \
			Похоже, что он предназначен для измерения показателей электрических объектов."
	icon = 'icons/obj/abductor.dmi'
	toolspeed = 0.1
	origin_tech = "magnets=5;engineering=5;abductor=3"
	shows_wire_information = TRUE
	emp_shielded = TRUE

/obj/item/multitool/abductor/get_ru_names()
	return list(
		NOMINATIVE = "чужеродный мультиметр",
		GENITIVE = "чужеродного мультиметра",
		DATIVE = "чужеродному мультиметру",
		ACCUSATIVE = "чужеродный мультиметр",
		INSTRUMENTAL = "чужеродным мультиметром",
		PREPOSITIONAL = "чужеродном мультиметре"
	)

/obj/item/multitool/brass
	name = "brass multimeter"
	desc = "Механический прибор из латуни, измеряющий показания тока. \
			Отсутствие электронных компонентов делает его невосприимчивым к ЭМИ."
	icon_state = "multitool_brass"
	toolspeed = 0.5
	resistance_flags = FIRE_PROOF | ACID_PROOF
	emp_shielded = TRUE

/obj/item/multitool/brass/get_ru_names()
	return list(
		NOMINATIVE = "латунный мультиметр",
		GENITIVE = "латунного мультиметра",
		DATIVE = "латунному мультиметру",
		ACCUSATIVE = "латунный мультиметр",
		INSTRUMENTAL = "латунным мультиметром",
		PREPOSITIONAL = "латунном мультиметре"
	)

/obj/item/multitool/old
	name = "old multimeter"
	desc = "Электрический прибор для измерения параметров тока и прозвонки электрических цепей. \
			Выглядит весьма устаревшим."
	icon_state = "multitool_old_wire"
	belt_icon = "multitool_old_wire"
	emp_shielded = TRUE

/obj/item/multitool/old/get_ru_names()
	return list(
		NOMINATIVE = "старый мультиметр",
		GENITIVE = "старого мультиметра",
		DATIVE = "старому мультиметру",
		ACCUSATIVE = "старый мультиметр",
		INSTRUMENTAL = "старым мультиметром",
		PREPOSITIONAL = "старом мультиметре",
	)

#undef PROXIMITY_NONE
#undef PROXIMITY_ON_SCREEN
#undef PROXIMITY_NEAR
