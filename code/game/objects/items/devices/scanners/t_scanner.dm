/obj/item/t_scanner
	name = "T-ray scanner"
	desc = "A terahertz-ray emitter and scanner used to detect underfloor objects such as cables and pipes."
	gender = MALE
	icon = 'icons/obj/device.dmi'
	icon_state = "t-ray0"
	base_icon_state = "t-ray"
	var/on = FALSE
	slot_flags = ITEM_SLOT_BELT
	w_class = WEIGHT_CLASS_SMALL
	item_state = "electronic"
	materials = list(MAT_METAL=150)
	origin_tech = "magnets=1;engineering=1"
	toolbox_radial_menu_compatibility = TRUE
	var/scan_range = 1
	var/pulse_duration = 1 SECONDS

/obj/item/t_scanner/extended_range
	name = "T-ray сканер расширенной дальности"
	desc = "Излучатель и сканер терагерцевого излучения, используемый для обнаружения скрытых объектов и объектов под полом, таких как кабели и трубы. \
	\nДанная модель обладает расширенным радиусом действия."
	icon_state = "t-ray-range0"
	base_icon_state = "t-ray-range"
	scan_range = 3
	origin_tech = "magnets=2;engineering=3"
	materials = list(MAT_METAL=300)

/obj/item/t_scanner/longer_pulse
	name = "T-ray сканер с продолжительным импульсом"
	desc = "Излучатель и сканер терагерцевого излучения, используемый для обнаружения скрытых объектов и объектов под полом, таких как кабели и трубы. \
	\nДанная модель способна генерировать более продолжительные импульсы."
	icon_state = "t-ray-pulse0"
	base_icon_state = "t-ray-pulse"
	pulse_duration = 5 SECONDS
	origin_tech = "magnets=2;engineering=3"
	materials = list(MAT_METAL=300)

/obj/item/t_scanner/advanced
	name = "Продвинутый T-ray сканер"
	desc = "Излучатель и сканер терагерцевого излучения, используемый для обнаружения скрытых объектов и объектов под полом, таких как кабели и трубы. \
	\nДанная модель способна генерировать более продолжительные импульсы и обладает расширенным радиусом действия."
	icon_state = "t-ray-advanced0"
	base_icon_state = "t-ray-advanced"
	scan_range = 3
	pulse_duration = 5 SECONDS
	origin_tech = "magnets=3;engineering=3"
	materials = list(MAT_METAL=300)

/obj/item/t_scanner/science
	name = "Научный T-ray сканер"
	desc = "Излучатель и сканер терагерцевого излучения, используемый для обнаружения скрытых объектов и объектов под полом, таких как кабели и трубы. \
	\nВысокотехнологичная модель, способная генерировать очень продолжительные импульсы в пределах большого радиуса."
	icon_state = "t-ray-science0"
	base_icon_state = "t-ray-science"
	scan_range = 5
	pulse_duration = 10 SECONDS
	origin_tech = "magnets=4;engineering=5"
	materials = list(MAT_METAL=500)

/obj/item/t_scanner/experimental	//a high-risk that cannot be disassembled, since this garbage was invented by, well, you know who.
	name = "Экспериментальный T-ray сканер"
	desc = "Излучатель и сканер терагерцевого излучения, используемый для обнаружения скрытых объектов и объектов под полом, таких как кабели и трубы. \
	\nЭкспериментальный образец, обладающий расширенным радиусом действия и более продолжительным импульсом. \
	\nСудя по его виду, эта вещь была собрана безумными учеными в ходе спонтанных экспериментов."
	icon_state = "t-ray-experimental0"
	base_icon_state = "t-ray-experimental"
	scan_range = 3
	pulse_duration = 8 SECONDS
	origin_tech = null
	materials = list()
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | ACID_PROOF

/obj/item/t_scanner/Destroy()
	if(on)
		STOP_PROCESSING(SSobj, src)
	return ..()

/obj/item/t_scanner/update_icon_state()
	icon_state = "[base_icon_state][on]"

/obj/item/t_scanner/proc/toggle_mode()
	playsound(src, SFX_INDUSTRIAL_SCAN, 20, TRUE, -2, TRUE, FALSE)
	on = !on
	update_icon(UPDATE_ICON_STATE)
	if(on)
		START_PROCESSING(SSobj, src)
	else
		STOP_PROCESSING(SSobj, src)

/obj/item/t_scanner/attack_self(mob/user)
	toggle_mode()

/obj/item/t_scanner/process()
	if(!on)
		STOP_PROCESSING(SSobj, src)
		return null
	scan()

/obj/item/t_scanner/proc/scan()
	t_ray_scan(loc, pulse_duration, scan_range)

/proc/t_ray_scan(mob/viewer, flick_time, distance)
	if(!ismob(viewer) || !viewer.client)
		return
	var/list/t_ray_images = list()
	for(var/atom/movable/in_turf_atom in orange(distance, viewer))
		if(!isobj(in_turf_atom) && !isliving(in_turf_atom))
			continue

		if(isobj(in_turf_atom))
			var/obj/in_turf_object = in_turf_atom
			if(in_turf_object.level != 1)
				continue

			if(in_turf_object.invisibility != INVISIBILITY_MAXIMUM && in_turf_object.invisibility != INVISIBILITY_ANOMALY)
				continue

		if(isliving(in_turf_atom))
			var/mob/living/in_turf_living = in_turf_atom
			if(!(in_turf_living.alpha < 255 || in_turf_living.invisibility == INVISIBILITY_LEVEL_TWO))
				continue

		var/turf/turf = get_turf(in_turf_atom)
		var/image/img = new(loc = turf)
		var/mutable_appearance/MA = new(in_turf_atom)
		MA.alpha = isliving(in_turf_atom) ? 255 : 128
		MA.dir = in_turf_atom.dir
		if(MA.layer < TURF_LAYER)
			MA.layer += TRAY_SCAN_LAYER_OFFSET
		MA.plane = GAME_PLANE
		SET_PLANE_EXPLICIT(MA, GAME_PLANE, turf)
		img.appearance = MA
		t_ray_images += img

	if(length(t_ray_images))
		flick_overlay(t_ray_images, list(viewer.client), flick_time)

/obj/item/t_scanner/security
	name = "Противо-маскировочное ТГц устройство"
	desc = "Излучатель терагерцевого типа используемый для сканирования области на наличие замаскированных биоорганизмов. Устройство уязвимо для ЭМИ излучения."
	item_state = "sb_t-ray"
	icon_state = "sb_t-ray0"
	base_icon_state = "sb_t-ray"
	scan_range = 2
	var/was_alerted = FALSE // Protection against spam alerts from this scanner
	var/burnt = FALSE // Did emp break us?
	var/datum/effect_system/spark_spread/spark_system	//The spark system, used for generating... sparks?
	origin_tech = "combat=3;magnets=5;biotech=5"

/obj/item/t_scanner/security/Initialize(mapload)
	. = ..()
	//Sets up a spark system
	spark_system = new /datum/effect_system/spark_spread
	spark_system.set_up(5, 0, src)
	spark_system.attach(src)

/obj/item/t_scanner/security/Destroy()
	QDEL_NULL(spark_system)
	. = ..()

/obj/item/t_scanner/security/update_icon_state()
	if(burnt)
		icon_state = "[base_icon_state]_burnt"
		return
	icon_state = "[base_icon_state][on]"

/obj/item/t_scanner/security/update_desc(updates = ALL)
	. = ..()
	if(!burnt)
		desc = initial(desc)
		return
	desc = "Излучатель терагерцевого типа используемый для сканирования области на наличие замаскированных биоорганизмов. Устройство сгорело, теперь можно обнаружить разве что крошки от пончика оставшиеся на нём..."

/obj/item/t_scanner/security/attack_self(mob/user)
	if(!burnt)
		on = !on
		update_icon(UPDATE_ICON_STATE)

	if(on)
		START_PROCESSING(SSprocessing, src)
	else
		STOP_PROCESSING(SSprocessing, src)

/obj/item/t_scanner/security/emp_act(severity)
	. = ..()
	if(prob(25) && !burnt)
		burnt = TRUE
		on = FALSE
		update_appearance(UPDATE_ICON_STATE|UPDATE_DESC)
		playsound(loc, SFX_SPARKS, 50, TRUE, 5)
		spark_system.start()

/obj/item/t_scanner/security/scan()
	var/mob/viewer = loc
	if(!ismob(viewer) || !viewer.client)
		return
	new /obj/effect/temp_visual/scan(get_turf(src))
	var/list/t_ray_images = list()

	for(var/atom/movable/invisible_object in view(scan_range, get_turf(src)))
		if(!(istype(invisible_object, /obj/structure/closet/cardboard/agent/) || isliving(invisible_object)))
			continue
		if(!(invisible_object.alpha < 255 || invisible_object.invisibility == INVISIBILITY_LEVEL_TWO))
			continue
		var/image/I = new(loc = get_turf(invisible_object))
		var/mutable_appearance/MA = new(invisible_object)
		MA.alpha = 255
		MA.dir = invisible_object.dir
		if(MA.layer < TURF_LAYER)
			MA.layer += TRAY_SCAN_LAYER_OFFSET
		MA.plane = GAME_PLANE
		I.appearance = MA
		t_ray_images += I
		alert_searchers(invisible_object)

	if(length(t_ray_images))
		flick_overlay(t_ray_images, list(viewer.client), pulse_duration)

/obj/item/t_scanner/security/proc/alert_searchers(mob/living/found_mob)
	var/list/alerted = viewers(7, found_mob)
	if(alerted && !was_alerted)
		for(var/mob/living/alerted_mob in alerted)
			if(!alerted_mob.stat)
				do_alert_animation(alerted_mob)
				alerted_mob.playsound_local(alerted, 'sound/machines/chime.ogg', 15, FALSE)
		was_alerted = TRUE
		addtimer(CALLBACK(src, PROC_REF(end_alert_cd)), 1 MINUTES)

/obj/item/t_scanner/security/proc/end_alert_cd()
	was_alerted = FALSE

/proc/chemscan(mob/living/user, mob/living/M)
	if(ishuman(M))
		var/mob/living/carbon/human/H = M
		if(H.reagents)
			if(length(H.reagents.reagent_list))
				to_chat(user, span_notice("Subject contains the following reagents:"))
				for(var/datum/reagent/R in H.reagents.reagent_list)
					to_chat(user, "[span_notice("[R.volume]u of [R.name]")][R.overdosed ? " – [span_boldannounceic("OVERDOSING")]" : "[span_notice(".")]"]")
			else
				to_chat(user, span_notice("Subject contains no reagents."))
			if(length(H.reagents.addiction_list))
				to_chat(user, span_danger("Subject is addicted to the following reagents:"))
				for(var/datum/reagent/R in H.reagents.addiction_list)
					to_chat(user, span_danger("[R.name] Stage: [R.addiction_stage]/5"))
			else
				to_chat(user, span_notice("Subject is not addicted to any reagents."))
