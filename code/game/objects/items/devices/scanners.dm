/*
CONTAINS:
T-RAY
DETECTIVE SCANNER
HEALTH ANALYZER
PLANT ANALYZER
REAGENT SCANNER
*/
/obj/item/t_scanner
	name = "T-ray scanner"
	desc = "A terahertz-ray emitter and scanner used to detect underfloor objects such as cables and pipes."
	icon = 'icons/obj/device.dmi'
	icon_state = "t-ray0"
	base_icon_state = "t-ray"
	var/on = FALSE
	slot_flags = ITEM_SLOT_BELT
	w_class = WEIGHT_CLASS_SMALL
	item_state = "electronic"
	materials = list(MAT_METAL=150)
	origin_tech = "magnets=1;engineering=1"
	var/scan_range = 1
	var/pulse_duration = 1 SECONDS

/obj/item/t_scanner/extended_range
	name = "T-ray сканер расширенной дальности"
	desc = "Излучатель и сканер терагерцевого излучения, используемый для обнаружения скрытых объектов и объектов под полом, таких как кабели и трубы. \
	\nДанная модель обладает расширенным радиусом действия."
	icon_state = "t-ray-range0"
	base_icon_state = "t-ray-range"
	scan_range = 3
	origin_tech = "magnets=3;engineering=3"
	materials = list(MAT_METAL=300)

/obj/item/t_scanner/longer_pulse
	name = "T-ray сканер с продолжительным импульсом"
	desc = "Излучатель и сканер терагерцевого излучения, используемый для обнаружения скрытых объектов и объектов под полом, таких как кабели и трубы. \
	\nДанная модель способна генерировать более продолжительные импульсы."
	icon_state = "t-ray-pulse0"
	base_icon_state = "t-ray-pulse"
	pulse_duration = 5 SECONDS
	origin_tech = "magnets=5;engineering=3"
	materials = list(MAT_METAL=300)

/obj/item/t_scanner/advanced
	name = "Продвинутый T-ray сканер"
	desc = "Излучатель и сканер терагерцевого излучения, используемый для обнаружения скрытых объектов и объектов под полом, таких как кабели и трубы. \
	\nДанная модель способна генерировать более продолжительные импульсы и обладает расширенным радиусом действия."
	icon_state = "t-ray-advanced0"
	base_icon_state = "t-ray-advanced"
	scan_range = 3
	pulse_duration = 5 SECONDS
	origin_tech = "magnets=7;engineering=3"
	materials = list(MAT_METAL=300)

/obj/item/t_scanner/science
	name = "Научный T-ray сканер"
	desc = "Излучатель и сканер терагерцевого излучения, используемый для обнаружения скрытых объектов и объектов под полом, таких как кабели и трубы. \
	\nВысокотехнологичная модель, способная генерировать очень продолжительные импульсы в пределах большого радиуса."
	icon_state = "t-ray-science0"
	base_icon_state = "t-ray-science"
	scan_range = 5
	pulse_duration = 10 SECONDS
	origin_tech = "magnets=8;engineering=5"
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

		var/turf/T = get_turf(in_turf_atom)
		var/image/I = new(loc = T)
		var/mutable_appearance/MA = new(in_turf_atom)
		MA.alpha = isliving(in_turf_atom) ? 255 : 128
		MA.dir = in_turf_atom.dir
		if(MA.layer < TURF_LAYER)
			MA.layer += TRAY_SCAN_LAYER_OFFSET
		MA.plane = GAME_PLANE
		SET_PLANE_EXPLICIT(MA, GAME_PLANE, T)
		I.appearance = MA
		t_ray_images += I

	if(length(t_ray_images))
		flick_overlay(t_ray_images, list(viewer.client), flick_time)

/obj/item/t_scanner/security
	name = "Противо-маскировочное ТГц устройство"
	desc = "Излучатель терагерцевого типа используемый для сканирования области на наличие замаскированных биоорганизмов. Устройство уязвимо для ЭМИ излучения."
	icon = 'icons/obj/device.dmi'
	lefthand_file = 'icons/mob/inhands/items_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/items_righthand.dmi'
	item_state = "sb_t-ray"
	icon_state = "sb_t-ray0"
	base_icon_state = "sb_t-ray"
	scan_range = 2
	var/was_alerted = FALSE // Protection against spam alerts from this scanner
	var/burnt = FALSE // Did emp break us?
	var/datum/effect_system/spark_spread/spark_system	//The spark system, used for generating... sparks?
	origin_tech = "combat=3;magnets=5;biotech=5"


/obj/item/t_scanner/security/Initialize()
	. = ..()
	//Sets up a spark system
	spark_system = new /datum/effect_system/spark_spread
	spark_system.set_up(5, 0, src)
	spark_system.attach(src)


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
		playsound(loc, "sparks", 50, TRUE, 5)
		spark_system.start()


/obj/item/t_scanner/security/scan()
	var/mob/viewer = loc
	if(!ismob(viewer) || !viewer.client)
		return
	new /obj/effect/temp_visual/scan(get_turf(src))
	var/list/t_ray_images = list()

	for(var/atom/movable/invisible_object as anything in view(scan_range, get_turf(src)))
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
				alerted_mob.playsound_local(alerted, 'sound/machines/chime.ogg', 15, 0)
		was_alerted = TRUE
		addtimer(CALLBACK(src, PROC_REF(end_alert_cd)), 1 MINUTES)

/obj/item/t_scanner/security/proc/end_alert_cd()
	was_alerted = FALSE

/proc/chemscan(mob/living/user, mob/living/M)
	if(ishuman(M))
		var/mob/living/carbon/human/H = M
		if(H.reagents)
			if(H.reagents.reagent_list.len)
				to_chat(user, "<span class='notice'>Subject contains the following reagents:</span>")
				for(var/datum/reagent/R in H.reagents.reagent_list)
					to_chat(user, "<span class='notice'>[R.volume]u of [R.name][R.overdosed ? "</span> - [span_boldannounceic("OVERDOSING")]" : ".</span>"]")
			else
				to_chat(user, "<span class = 'notice'>Subject contains no reagents.</span>")
			if(H.reagents.addiction_list.len)
				to_chat(user, "<span class='danger'>Subject is addicted to the following reagents:</span>")
				for(var/datum/reagent/R in H.reagents.addiction_list)
					to_chat(user, "<span class='danger'>[R.name] Stage: [R.addiction_stage]/5</span>")
			else
				to_chat(user, "<span class='notice'>Subject is not addicted to any reagents.</span>")

/obj/item/healthanalyzer
	name = "health analyzer"
	icon = 'icons/obj/device.dmi'
	icon_state = "health"
	item_state = "healthanalyzer"
	belt_icon = "health_analyzer"
	desc = "Ручной сканер тела, способный определить жизненные показатели субъекта."
	flags = CONDUCT
	item_flags = NOBLUDGEON
	slot_flags = ITEM_SLOT_BELT
	throwforce = 3
	w_class = WEIGHT_CLASS_TINY
	throw_speed = 3
	throw_range = 7
	materials = list(MAT_METAL=200)
	origin_tech = "magnets=1;biotech=1"
	var/mode = 1
	var/advanced = FALSE

	var/scan_title
	var/scan_data
	//For displaying scans
	var/window_width = 400
	var/window_height = 85
	var/testlength

	var/reports_printed = 0
	var/reports_per_device = 20

	var/isPrinting = FALSE


/obj/item/healthanalyzer/attack(mob/living/target, mob/living/user, params, def_zone, skip_attack_anim = FALSE)
	add_fingerprint(user)
	scan_title = "Сканирование: [target]"
	scan_data = medical_scan_action(user, target, src, mode, advanced)
	show_results(user)
	return ATTACK_CHAIN_PROCEED_SUCCESS


/obj/item/healthanalyzer/attack_self(mob/user)
	if(!scan_data)
		to_chat(user, "<span class='notice'>[src] не содержит сохраненных данных.</span>")
		return
	show_results(user)

/obj/item/healthanalyzer/Topic(href, href_list)
	var/mob/living/user
	if(href_list["user"])
		user = locateUID(href_list["user"])
	if(!user) return
	winset(user, "mapwindow.map", "focus=true")

	if(!in_range(user, src))
		to_chat(user, "<span class='notice'>Нужно подойти ближе, чтобы нажать на кнопку.</span>")
		return

	if(href_list["print"])
		if(!isPrinting)
			print_report(user)
		return 1
	if(href_list["mode"])
		toggle_mode()
		return 1
	if(href_list["clear"])
		to_chat(user, "Вы очистили буфер данных [src].")
		scan_data = null
		scan_title = null
		user << browse(null, "window=scanner")
		return 1

/obj/item/healthanalyzer/proc/print_report_verb()
	set name = "Печать отчета"
	set category = "Object"
	set src = usr

	var/mob/user = usr
	if(!istype(user))
		return
	if (user.incapacitated())
		return
	print_report(user)

/obj/item/healthanalyzer/proc/print_report(var/mob/living/user)
	if(!scan_data)
		to_chat(user, "Нет данных для печати.")
		return
	isPrinting = TRUE
	if(reports_printed > reports_per_device || GLOB.copier_items_printed >= GLOB.copier_max_items)
		visible_message("<span class='warning'>Nothing happens. Printing device is broken?</span>")
		if(!GLOB.copier_items_printed_logged)
			message_admins("Photocopier cap of [GLOB.copier_max_items] papers reached, all photocopiers/printers are now disabled. This may be the cause of any lag.")
			GLOB.copier_items_printed_logged = TRUE
		sleep(3 SECONDS)
		isPrinting = FALSE
		return

	playsound(loc, 'sound/goonstation/machines/printer_dotmatrix.ogg', 50, TRUE)
	flick("health_anim", src)
	sleep(3 SECONDS)
	var/obj/item/paper/P = new(drop_location())
	P.name = scan_title
	P.header += "<center><b>[scan_title]</b></center><br>"
	P.header += "<b>Время сканирования:</b> [station_time_timestamp()]<br><br>"
	P.header += "[scan_data]"
	P.info += "<br><br><b>Заметки:</b><br>"
	if(in_range(user, src))
		user.put_in_hands(P, ignore_anim = FALSE)
		user.visible_message("<span class='notice'>[src.declent_ru(NOMINATIVE)] [pluralize_ru(src.gender,"выдаёт","выдают")] лист с отчётом.</span>")
	GLOB.copier_items_printed++
	reports_printed++
	isPrinting = FALSE

/obj/item/healthanalyzer/proc/show_results(mob/user)
	var/datum/browser/popup = new(user, "scanner", scan_title, window_width, window_height)
	popup.set_content("[get_header(user)]<hr>[scan_data]")
	popup.open(no_focus = 1)

/obj/item/healthanalyzer/proc/get_header(mob/user)
	return "<a href='byond://?src=[src.UID()];user=[user.UID()];clear=1'>Очистить</a><a href='byond://?src=[src.UID()];user=[user.UID()];mode=1'>Локализация</a>[advanced ? "<a href='byond://?src=[src.UID()];user=[user.UID()];print=1'>Печать отчета</a>" : ""]"

/obj/item/healthanalyzer/examine(mob/user)
	. = ..()
	if(scan_data)
		if(in_range(user, src) || istype(user, /mob/dead/observer))
			show_results(user)
		else
			. += "<span class='notice'>Нужно подойти ближе, чтобы прочесть содержимое.</span>"

/proc/medical_scan_action(mob/living/user, atom/target, var/obj/item/healthanalyzer/scanner, var/mode, var/advanced)
	if (!user.IsAdvancedToolUser())
		to_chat(user, "<span class='warning'>Вы не достаточно ловки, чтобы использовать это устройство.</span>")
		return

	scanner.window_height = initial(scanner.window_height)
	if((HAS_TRAIT(user, TRAIT_CLUMSY) || user.getBrainLoss() >= 60) && prob(50))
		. = list()
		user.visible_message("<span class='warning'>[user] анализирует жизненные показатели пола!</span>", "<span class='notice'>Вы по глупости анализировали жизненные показатели пола!</span>")
		. += "Общий статус: <b>100% Здоров</b>"
		. += "Тип повреждений: <font color='#0080ff'>Удушение</font>/<font color='green'>Токсины</font>/<font color='#FF8000'>Ожоги</font>/<font color='red'>Физ.</font>"
		. += "Уровень повреждений: <font color='#0080ff'>0</font> - <font color='green'>0</font> - <font color='#FF8000'>0</font> - <font color='red'>0</font>"
		. += "Температура тела: ---&deg;C (---&deg;F)"
		if(mode == 1)
			. += "Локализация повреждений, <font color='red'>Физ.</font>/<font color='#FF8000'>Ожоги</font>:"
		. += "Уровень крови: --- %, --- cl, тип: ---"
		. += "Пульс: <font color='#0080ff'>--- bpm.</font>"
		. += "Гены не обнаружены."
		scanner.window_height += length(.) * 20
		scanner.scan_title = "Сканирование: Пол"
		return "<span class='highlight'>[jointext(., "<br>")]</span>"

	var/mob/living/carbon/human/scan_subject = null
	if (ishuman(target))
		scan_subject = target
	else if (istype(target, /obj/structure/closet/body_bag))
		var/obj/structure/closet/body_bag/B = target
		if(!B.opened)
			var/list/scan_content = list()
			for(var/mob/living/L in B.contents)
				scan_content.Add(L)

			if (scan_content.len == 1)
				for(var/mob/living/carbon/human/L in scan_content)
					scan_subject = L
			else if (scan_content.len > 1)
				to_chat(user, "<span class='warning'>[scanner] обнаружил несколько субъектов внутри [target], слишком близко для нормального сканирования.</span>")
				return
			else
				to_chat(user, "[scanner] не обнаружил никого внутри [target].")
				return

	if(!scan_subject)
		return

	if(user == target)
		user.visible_message("<span class='notice'>[user.declent_ru(NOMINATIVE)] анализиру[pluralize_ru(user.gender,"ет","ют")] свои жизненные показатели.</span>", "<span class='notice'>[pluralize_ru(user.gender,"Ты анализируешь","Вы анализируете")] свои жизненные показатели.</span>")
	else
		user.visible_message("<span class='notice'>[user.declent_ru(NOMINATIVE)] анализиру[pluralize_ru(user.gender,"ет","ют")] жизненные показатели [target.declent_ru(ACCUSATIVE)].</span>", "<span class='notice'>[pluralize_ru(user.gender,"Ты анализируешь","Вы анализируете")] жизненные показатели [target.declent_ru(ACCUSATIVE)].</span>")

	. = medical_scan_results(scan_subject, mode, advanced)
	scanner.window_height += length(.) * 20
	. = "<span class='highlight'>[jointext(., "<br>")]</span>"

/proc/medical_scan_results(var/mob/living/M, var/mode = 1, var/advanced = FALSE)
	. = list()
	if(!ishuman(M) || ismachineperson(M))
		//these sensors are designed for organic life
		. += "Общий статус: <span class='danger'>ОШИБКА</span></span>"
		. += "Тип повреждений: <font color='#0080ff'>Удушение</font>/<font color='green'>Токсины</font>/<font color='#FF8000'>Ожоги</font>/<font color='red'>Физ.</font></span>"
		. += "Уровень повреждений: <font color='#0080ff'>?</font> - <font color='green'>?</font> - <font color='#FF8000'>?</font> - <font color='red'>?</font></span>"
		. += "Температура тела: [M.bodytemperature-T0C]&deg;C ([M.bodytemperature*1.8-459.67]&deg;F)</span>"
		if(mode == 1)
			. += "Локализация повреждений, <font color='red'>Физ.</font>/<font color='#FF8000'>Ожоги</font>:</span>"
		. += "Уровень крови: --- %, --- cl, тип: ---</span>"
		. += "Пульс: <font color='#0080ff'>--- bpm.</font></span>"
		. += "Гены не обнаружены."
		return .

	var/mob/living/carbon/human/H = M
	var/fake_oxy = max(rand(1,40), H.getOxyLoss(), (300 - (H.getToxLoss() + H.getFireLoss() + H.getBruteLoss())))
	var/OX = H.getOxyLoss() > 50 	? 	"<b>[H.getOxyLoss()]</b>" 		: H.getOxyLoss()
	var/TX = H.getToxLoss() > 50 	? 	"<b>[H.getToxLoss()]</b>" 		: H.getToxLoss()
	var/BU = H.getFireLoss() > 50 	? 	"<b>[H.getFireLoss()]</b>" 		: H.getFireLoss()
	var/BR = H.getBruteLoss() > 50 	? 	"<b>[H.getBruteLoss()]</b>" 	: H.getBruteLoss()
	var/DNR = !H.ghost_can_reenter()
	if(H.stat == DEAD)
		if(DNR)
			. += "Общий статус: <span class='danger'>МЕРТВ <b>\[DNR]</b></span>"
		else
			. += "Общий статус: <span class='danger'>МЕРТВ</span>"
	else //Если живой или отключка
		if(HAS_TRAIT(H, TRAIT_FAKEDEATH))
			OX = fake_oxy > 50 			? 	"<b>[fake_oxy]</b>" 			: fake_oxy
			. += "Общий статус: <span class='danger'>МЕРТВ</span>"
		else
			. += "Общий статус: [H.stat > 1 ? "<span class='danger'>МЕРТВ</span>" : H.health > 0 ? "[H.health]%" : "<span class='danger'>[H.health]%</span>"]"
	. += "Тип повреждений: <font color='#0080ff'>Удушение</font>/<font color='green'>Токсины</font>/<font color='#FF8000'>Ожоги</font>/<font color='red'>Физ.</font>"
	. += "Уровень повреждений: <font color='#0080ff'>[OX]</font> - <font color='green'>[TX]</font> - <font color='#FF8000'>[BU]</font> - <font color='red'>[BR]</font>"
	. += "Температура тела: [H.bodytemperature-T0C]&deg;C ([H.bodytemperature*1.8-459.67]&deg;F)"
	if(H.timeofdeath && (H.stat == DEAD || HAS_TRAIT(H, TRAIT_FAKEDEATH)))
		. += "Время смерти: [station_time_timestamp("hh:mm:ss", H.timeofdeath)]"
		var/tdelta = round(world.time - H.timeofdeath)
		if(tdelta < DEFIB_TIME_LIMIT && !DNR)
			. += "<span class='danger'>&emsp;Субъект умер [DisplayTimeText(tdelta)] назад"
			. += "&emsp;Дефибриляция возможна!</span>"
		else
			. += "<span class='danger'>&emsp;Субъект умер [DisplayTimeText(tdelta)] назад</span>"

	if(mode == 1)
		var/list/damaged = H.get_damaged_organs(1,1)
		. += "Локализация повреждений, <font color='#FF8000'>Ожоги</font>/<font color='red'>Физ.</font>:"
		if(length(damaged) > 0)
			for(var/obj/item/organ/external/org as anything in damaged)
				. += "&emsp;<span class='info'>[capitalize(org.name)]</span>: [(org.burn_dam > 0) ? "<font color='#FF8000'>[org.burn_dam]</font>" : "<font color='#FF8000'>0</font>"] - [(org.brute_dam > 0) ? "<font color='red'>[org.brute_dam]</font>" : "<font color='red'>0</font>"]"
/*
	if(H.status_flags & FAKEDEATH)
		. += fake_oxy > 50 ? 		"<span class='danger'>Severe oxygen deprivation detected</span>" 	: 	"<span class='highlight'>Subject bloodstream oxygen level normal</span>"
	else
		. += H.getOxyLoss() > 50 ? 	"<font color='#0080ff'><b>Severe oxygen deprivation detected</b></font>" 		: 	"Subject bloodstream oxygen level normal"
	. += H.getToxLoss() > 50 ? 	"<font color='green'><b>Dangerous amount of toxins detected</b></font>" 	: 	"Subject bloodstream toxin level minimal"
	. += H.getFireLoss() > 50 ? 	"<font color='#FFA500'><b>Severe burn damage detected</b></font>" 			:	"Subject burn injury status O.K"
	. += H.getBruteLoss() > 50 ? "<font color='red'><b>Severe anatomical damage detected</b></font>" 		: 	"Subject brute-force injury status O.K"
*/
	if(advanced)
		if(H.reagents)
			if(H.reagents.reagent_list.len)
				. += "Обнаружены реагенты:"
				for(var/datum/reagent/R in H.reagents.reagent_list)
					. += "&emsp;[R.volume]u [R.name][R.overdosed ? " - [span_boldannounceic("ПЕРЕДОЗИРОВКА")]" : "."]"
			else
				. += "Реагенты не обнаружены."
			if(H.reagents.addiction_list.len)
				. += "<span class='danger'>Обнаружены зависимости от реагентов:</span>"
				for(var/datum/reagent/R in H.reagents.addiction_list)
					. += "<span class='danger'>&emsp;[R.name] Стадия: [R.addiction_stage]/5</span>"
			else
				. += "Зависимости от реагентов не обнаружены."
	for(var/thing in H.diseases)
		var/datum/disease/D = thing
		if(!(D.visibility_flags & HIDDEN_SCANNER))
			. += "<span class='warning'><b>Внимание: обнаружен [D.form]</b>"
			. += "&emsp;Название: [D.name]"
			. += "&emsp;Тип: [D.additional_info]"
			. += "&emsp;Стадия: [D.stage]/[D.max_stages]"
			. += "&emsp;Лечение: [D.cure_text]</span>"
	if(H.undergoing_cardiac_arrest())
		var/obj/item/organ/internal/heart/heart = H.get_int_organ(/obj/item/organ/internal/heart)
		if(heart && !heart.is_dead())
			. += "<span class='warning'><b>Внимание: Критическое состояние</b>"
			. += "&emsp;Название: Остановка сердца"
			. += "&emsp;Тип: Сердце пациента остановилось"
			. += "&emsp;Стадия: 1/1"
			. += "&emsp;Лечение: Электрический шок</span>"
		else if(heart && heart.is_dead())
			. += "<span class='alert'><b>Обнаружен некроз сердца!</b></span>"
		else if(!heart)
			. += "<span class='alert'><b>Сердце не обнаружено!</b></span>"

	if(H.getStaminaLoss())
		. += "<span class='info'>Обнаружено переутомление.</span>"
	if(H.getCloneLoss())
		. += "<span class='warning'>Обнаружено [H.getCloneLoss() > 30 ? "серьезное" : "незначительное"] клеточное повреждение.</span>"
	if(H.has_brain_worms())
		. += "<span class='warning'>Обнаружено отклонение в мозговой активности."
		. += "&emsp;Рекомендуется подробное сканирование.</span>"

	if(H.get_int_organ(/obj/item/organ/internal/brain))
		if(H.getBrainLoss() >= 100)
			. += "<span class='warning'>Мозг мертв.</span>"
		else if(H.getBrainLoss() >= 60)
			. += "<span class='warning'>Обнаружено серьезное повреждение мозга."
			. += "&emsp;У субъекта может быть слабоумие.</span>"
		else if(H.getBrainLoss() >= 10)
			. += "<span class='warning'>Обнаружено значительное повреждение мозга."
			. += "&emsp;У субъекта могло быть сотрясение мозга.</span>"
	else
		. += "<span class='warning'>Мозг не обнаружен.</span>"

	for(var/name in H.bodyparts_by_name)
		var/obj/item/organ/external/e = H.bodyparts_by_name[name]
		if(!e)
			continue
		var/limb = e.name
		if(e.has_fracture())
			var/list/check_list = list(BODY_ZONE_L_ARM, BODY_ZONE_R_ARM, BODY_ZONE_PRECISE_L_HAND, BODY_ZONE_PRECISE_R_HAND, BODY_ZONE_L_LEG, BODY_ZONE_R_LEG, BODY_ZONE_PRECISE_L_FOOT, BODY_ZONE_PRECISE_R_FOOT)
			if((e.limb_zone in check_list) && !e.is_splinted())
				. += "<span class='warning'>Незакрепленные переломы в [limb]."
				. += "&emsp;Рекомендуется применить шину.</span>"
		if(e.has_infected_wound())
			. += "<span class='warning'>Заражение в [limb]."
			. += "&emsp;Рекомендуется дезинфекция.</span>"

	for(var/name in H.bodyparts_by_name)
		var/obj/item/organ/external/e = H.bodyparts_by_name[name]
		if(!e)
			continue
		if(e.has_fracture())
			. += "<span class='warning'>Обнаружены переломы."
			. += "&emsp;Рекомендуется подробное сканирование.</span>"
			break
	for(var/obj/item/organ/external/e as anything in H.bodyparts)
		if(e.has_internal_bleeding())
			. += "<span class='warning'>Внутреннее кровотечение."
			. += "&emsp;Рекомендуется подробное сканирование.</span>"
			break
	var/blood_id = H.get_blood_id()
	if(blood_id)
		if(H.bleed_rate)
			. += "<span class='danger'>Обнаружено кровотечение!</span>"
		var/blood_percent =  round((H.blood_volume / BLOOD_VOLUME_NORMAL)*100)
		var/blood_type = H.dna.blood_type
		var/blood_species = H.dna.species.blood_species
		if(blood_id != "blood")//special blood substance
			var/datum/reagent/R = GLOB.chemical_reagents_list[blood_id]
			if(R)
				blood_type = R.name
			else
				blood_type = blood_id
		if(H.blood_volume <= BLOOD_VOLUME_SAFE && H.blood_volume > BLOOD_VOLUME_OKAY)
			. += "Уровень крови: <span class='danger'>НИЗКИЙ [blood_percent] %, [H.blood_volume] cl,</span> тип: [blood_type], кровь расы: [blood_species]"
		else if(H.blood_volume <= BLOOD_VOLUME_OKAY)
			. += "Уровень крови: <span class='danger'>КРИТИЧЕСКИЙ [blood_percent] %, [H.blood_volume] cl,</span> тип: [blood_type], кровь расы: [blood_species]"
		else
			. += "Уровень крови: [blood_percent] %, [H.blood_volume] cl, тип: [blood_type], кровь расы: [blood_species]"

	. += "Пульс: <font color='[H.pulse == PULSE_THREADY || H.pulse == PULSE_NONE ? "red" : "#0080ff"]'>[H.get_pulse(GETPULSE_TOOL)] bpm.</font>"
	var/list/implant_detect = list()
	for(var/obj/item/organ/internal/cyberimp/cybernetics in H.internal_organs)
		if(cybernetics.is_robotic())
			implant_detect += "&emsp;[cybernetics.name]"
	if(length(implant_detect))
		. += "Обнаружены кибернетические модификации:"
		. += implant_detect
	if(H.gene_stability < 40)
		. += "<span class='userdanger'>Гены быстро распадаются!</span>"
	else if(H.gene_stability < 70)
		. += "<span class='danger'>Возможно спонтанное генное разложение.</span>"
	else if(H.gene_stability < 85)
		. += "<span class='warning'>Признаки незначительной генной нестабильности.</span>"
	else
		. += "Гены стабильны."

// Это вывод в чат
/proc/healthscan(mob/user, mob/living/M, mode = 1, advanced = FALSE)
	var/scan_data = medical_scan_results(M, mode, advanced)
	to_chat(user, "[jointext(scan_data, "<br>")]")

/obj/item/healthanalyzer/verb/toggle_mode()
	set name = "Вкл/Выкл локализацию"
	set category = "Object"

	if(usr.incapacitated() || HAS_TRAIT(usr, TRAIT_HANDS_BLOCKED))
		return

	mode = !mode
	switch(mode)
		if(1)
			to_chat(usr, "Сканер теперь показывает повреждения конечностей.")
		if(0)
			to_chat(usr, "Сканер больше не показывает повреждения конечностей.")


/obj/item/healthanalyzer/update_overlays()
	. = ..()
	if(advanced)
		. += "advanced"


/obj/item/healthanalyzer/attackby(obj/item/I, mob/user, params)
	if(istype(I, /obj/item/healthupgrade))
		add_fingerprint(user)
		if(advanced)
			to_chat(user, span_warning("Продвинутый модуль сканирования уже установлен."))
			return ATTACK_CHAIN_PROCEED
		if(!user.drop_transfer_item_to_loc(I, src))
			return ..()
		to_chat(user, span_notice("Вы установили продвинутый модуль сканирования."))
		playsound(loc, I.usesound, 50, TRUE)
		advanced = TRUE
		update_icon(UPDATE_OVERLAYS)
		qdel(I)
		return ATTACK_CHAIN_BLOCKED_ALL

	return ..()


/obj/item/healthanalyzer/advanced
	advanced = TRUE

/obj/item/healthanalyzer/advanced/Initialize(mapload)
	. = ..()
	update_icon(UPDATE_OVERLAYS)


/obj/item/healthupgrade
	name = "Health Analyzer Upgrade"
	icon = 'icons/obj/device.dmi'
	icon_state = "healthupgrade"
	desc = "Модуль обновления, устанавливаемый на Health Analyzer для расширения функционала."
	w_class = WEIGHT_CLASS_TINY
	origin_tech = "magnets=2;biotech=2"
	usesound = 'sound/items/deconstruct.ogg'

/obj/item/reagent_scanner
	name = "reagent scanner"
	desc = "A hand-held reagent scanner which identifies chemical agents and blood types."
	icon = 'icons/obj/device.dmi'
	icon_state = "spectrometer"
	item_state = "analyzer"
	w_class = WEIGHT_CLASS_SMALL
	flags = CONDUCT
	slot_flags = ITEM_SLOT_BELT
	throwforce = 5
	throw_speed = 4
	throw_range = 20
	materials = list(MAT_METAL=30, MAT_GLASS=20)
	origin_tech = "magnets=2;biotech=1;plasmatech=2"
	var/details = FALSE
	var/datatoprint = ""
	var/scanning = TRUE
	actions_types = list(/datum/action/item_action/print_report)

/obj/item/reagent_scanner/afterattack(obj/O, mob/user, proximity, params)
	if(user.stat)
		return
	if(!user.IsAdvancedToolUser())
		to_chat(user, "<span class='warning'>You don't have the dexterity to do this!</span>")
		return
	if(!istype(O))
		return

	if(!isnull(O.reagents))
		var/dat = ""
		var/blood_type = ""
		var/blood_species = ""
		if(O.reagents.reagent_list.len > 0)
			var/one_percent = O.reagents.total_volume / 100
			for(var/datum/reagent/R in O.reagents.reagent_list)
				if(R.id != "blood")
					dat += "<br>[TAB]<span class='notice'>[R][details ? ": [R.volume / one_percent]%" : ""]</span>"
				else
					blood_species = R.data["blood_species"]
					blood_type = R.data["blood_type"]
					dat += "<br>[TAB]<span class='notice'>[R][blood_type ? " [blood_type]" : ""][blood_species ? " [blood_species]" : ""][details ? ": [R.volume / one_percent]%" : ""]</span>"
		if(dat)
			to_chat(user, "<span class='notice'>Chemicals found: [dat]</span>")
			datatoprint = dat
			scanning = FALSE
		else
			to_chat(user, "<span class='notice'>No active chemical agents found in [O].</span>")
	else
		to_chat(user, "<span class='notice'>No significant chemical agents found in [O].</span>")
	return

/obj/item/reagent_scanner/adv
	name = "advanced reagent scanner"
	icon_state = "adv_spectrometer"
	details = TRUE
	origin_tech = "magnets=4;biotech=3;plasmatech=3"

/obj/item/reagent_scanner/proc/print_report()
	if(!scanning)
		usr.visible_message("<span class='warning'>[src] rattles and prints out a sheet of paper.</span>")
		playsound(loc, 'sound/goonstation/machines/printer_thermal.ogg', 50, 1)
		if(!details)
			flick("spectrometer_anim", src)
		else
			flick("adv_spectrometer_anim", src)
		sleep(50)

		var/obj/item/paper/P = new(drop_location())
		P.name = "Reagent Scanner Report: [station_time_timestamp()]"
		P.info = "<center><b>Reagent Scanner</b></center><br><center>Data Analysis:</center><br><hr><br><b>Chemical agents detected:</b><br> [datatoprint]<br><hr>"

		if(ismob(loc))
			var/mob/M = loc
			M.put_in_hands(P, ignore_anim = FALSE)
			to_chat(M, "<span class='notice'>Report printed. Log cleared.</span>")
			datatoprint = ""
			scanning = TRUE
	else
		to_chat(usr, "<span class='notice'>[src]  has no logs or is already in use.</span>")

/obj/item/reagent_scanner/ui_action_click(mob/user, datum/action/action, leftclick)
	print_report()

/obj/item/slime_scanner
	name = "slime scanner"
	icon = 'icons/obj/device.dmi'
	icon_state = "adv_spectrometer_s"
	item_state = "analyzer"
	origin_tech = "biotech=2"
	w_class = WEIGHT_CLASS_SMALL
	flags = CONDUCT
	throwforce = 0
	throw_speed = 3
	throw_range = 7
	materials = list(MAT_METAL=30, MAT_GLASS=20)

/obj/item/slime_scanner/attack(mob/living/target, mob/living/user, params, def_zone, skip_attack_anim = FALSE)
	. = ATTACK_CHAIN_PROCEED
	if(user.incapacitated() || user.AmountBlinded())
		return .
	if(!isslime(target))
		to_chat(user, span_warning("This device can only scan slimes!"))
		return .
	. |= ATTACK_CHAIN_SUCCESS
	slime_scan(target, user)

/proc/slime_scan(mob/living/simple_animal/slime/T, mob/living/user)
	to_chat(user, "========================")
	to_chat(user, "<b>Slime scan results:</b>")
	to_chat(user, "<span class='notice'>[T.colour] [T.age_state.age] slime</span>")
	to_chat(user, "Nutrition: [T.nutrition]/[T.get_max_nutrition()]")
	if(T.nutrition < T.get_starve_nutrition())
		to_chat(user, "<span class='warning'>Warning: slime is starving!</span>")
	else if(T.nutrition < T.get_hunger_nutrition())
		to_chat(user, "<span class='warning'>Warning: slime is hungry</span>")
	to_chat(user, "Electric change strength: [T.powerlevel]")
	to_chat(user, "Health: [round(T.health/T.maxHealth,0.01)*100]%")
	if(T.slime_mutation[4] == T.colour)
		to_chat(user, "This slime does not evolve any further.")
	else
		if(T.slime_mutation[3] == T.slime_mutation[4])
			if(T.slime_mutation[2] == T.slime_mutation[1])
				to_chat(user, "Possible mutation: [T.slime_mutation[3]]")
				to_chat(user, "Genetic destability: [T.mutation_chance/2] % chance of mutation on splitting")
			else
				to_chat(user, "Possible mutations: [T.slime_mutation[1]], [T.slime_mutation[2]], [T.slime_mutation[3]] (x2)")
				to_chat(user, "Genetic destability: [T.mutation_chance] % chance of mutation on splitting")
		else
			to_chat(user, "Possible mutations: [T.slime_mutation[1]], [T.slime_mutation[2]], [T.slime_mutation[3]], [T.slime_mutation[4]]")
			to_chat(user, "Genetic destability: [T.mutation_chance] % chance of mutation on splitting")
	if(T.cores > 1)
		to_chat(user, "Multiple cores detected")
	to_chat(user, "Growth progress: [clamp(T.amount_grown, 0, T.age_state.amount_grown)]/[T.age_state.amount_grown]")
	to_chat(user, "Split progress: [clamp(T.amount_grown, 0, T.age_state.amount_grown_for_split)]/[T.age_state.amount_grown_for_split]")
	to_chat(user, "Evolve: preparing for [(T.amount_grown < T.age_state.amount_grown_for_split) ? (T.age_state.stat_text) : (T.age_state.age != SLIME_ELDER ? T.age_state.stat_text_evolve : T.age_state.stat_text)]")
	if(T.effectmod)
		to_chat(user, "<span class='notice'>Core mutation in progress: [T.effectmod]</span>")
		to_chat(user, "<span class='notice'>Progress in core mutation: [T.applied] / [SLIME_EXTRACT_CROSSING_REQUIRED]</span>")
	to_chat(user, "========================")

/obj/item/bodyanalyzer
	name = "handheld body analyzer"
	icon = 'icons/obj/device.dmi'
	icon_state = "bodyanalyzer_0"
	base_icon_state = "bodyanalyzer"
	item_state = "healthanalyser"
	desc = "A handheld scanner capable of deep-scanning an entire body."
	slot_flags = ITEM_SLOT_BELT
	throwforce = 3
	w_class = WEIGHT_CLASS_TINY
	throw_speed = 5
	throw_range = 10
	origin_tech = "magnets=6;biotech=6"
	var/obj/item/stock_parts/cell/cell
	var/cell_type = /obj/item/stock_parts/cell/upgraded
	var/ready = TRUE // Ready to scan
	var/printing = FALSE
	var/time_to_use = 0 // How much time remaining before next scan is available.
	var/usecharge = 750
	var/scan_time = 10 SECONDS //how long does it take to scan
	var/scan_cd = 60 SECONDS //how long before we can scan again

/obj/item/bodyanalyzer/rnd
	icon_state = "bodyscan_0"
	item_state = "portable_bodyscan"
	base_icon_state = "bodyscan"

/obj/item/bodyanalyzer/get_cell()
	return cell

/obj/item/bodyanalyzer/advanced
	cell_type = /obj/item/stock_parts/cell/upgraded/plus

/obj/item/bodyanalyzer/borg
	name = "cyborg body analyzer"
	desc = "Scan an entire body to prepare for field surgery. Consumes power for each scan."

/obj/item/bodyanalyzer/borg/syndicate
	scan_time = 5 SECONDS
	scan_cd = 20 SECONDS

/obj/item/bodyanalyzer/New()
	..()
	cell = new cell_type(src)
	cell.give(cell.maxcharge)
	update_icon()

/obj/item/bodyanalyzer/proc/setReady()
	ready = TRUE
	playsound(src, 'sound/machines/defib_saftyon.ogg', 50, 0)
	update_icon()


/obj/item/bodyanalyzer/update_icon_state()
	if(!cell)
		icon_state = "[base_icon_state]_0"
		return
	if(ready)
		icon_state = "[base_icon_state]_1"
	else
		icon_state = "[base_icon_state]_2"


/obj/item/bodyanalyzer/update_overlays()
	. = ..()
	var/percent = cell.percent()
	var/overlayid = round(percent / 10)
	. += "[base_icon_state]_charge[overlayid]"
	if(printing)
		. += "[base_icon_state]_printing"


/obj/item/bodyanalyzer/attack(mob/living/target, mob/living/user, params, def_zone, skip_attack_anim = FALSE)
	. = ATTACK_CHAIN_PROCEED

	if(user.incapacitated() || !user.Adjacent(target))
		return .

	if(!ready)
		to_chat(user, span_notice("The scanner beeps angrily at you! It's currently recharging - [round((time_to_use - world.time) * 0.1)] seconds remaining."))
		playsound(user.loc, 'sound/machines/buzz-sigh.ogg', 50, TRUE)
		return .

	if(cell.charge >= usecharge)
		. |= ATTACK_CHAIN_SUCCESS
		mobScan(target, user)
	else
		to_chat(user, span_notice("The scanner beeps angrily at you! It's out of charge!"))
		playsound(user.loc, 'sound/machines/buzz-sigh.ogg', 50, TRUE)


/obj/item/bodyanalyzer/borg/attack(mob/living/target, mob/living/silicon/robot/user, params, def_zone, skip_attack_anim = FALSE)
	. = ATTACK_CHAIN_PROCEED

	if(user.incapacitated() || !user.Adjacent(target))
		return .

	if(!ready)
		to_chat(user, span_notice("[src] is currently recharging - [round((time_to_use - world.time) * 0.1)] seconds remaining."))
		return .

	if(user.cell.charge >= usecharge)
		. |= ATTACK_CHAIN_SUCCESS
		mobScan(target, user)
	else
		to_chat(user, span_notice("You need to recharge before you can use [src]"))


/obj/item/bodyanalyzer/proc/mobScan(mob/living/M, mob/user)
	if(ishuman(M))
		var/report = generate_printing_text(M, user)
		user.visible_message("[user] begins scanning [M] with [src].", "You begin scanning [M].")
		if(do_after(user, scan_time, M))
			var/obj/item/paper/printout = new(drop_location())
			printout.info = report
			printout.name = "Scan report - [M.name]"
			playsound(user.loc, 'sound/goonstation/machines/printer_dotmatrix.ogg', 50, 1)
			user.put_in_hands(printout, ignore_anim = FALSE)
			time_to_use = world.time + scan_cd
			if(isrobot(user))
				var/mob/living/silicon/robot/R = user
				R.cell.use(usecharge)
			else
				cell.use(usecharge)
			ready = FALSE
			printing = TRUE
			update_icon()
			addtimer(CALLBACK(src, TYPE_PROC_REF(/obj/item/bodyanalyzer, setReady)), scan_cd)
			addtimer(VARSET_CALLBACK(src, printing, FALSE), 1.4 SECONDS)
			addtimer(CALLBACK(src, TYPE_PROC_REF(/atom, update_icon), UPDATE_OVERLAYS), 1.5 SECONDS)
	else if(iscorgi(M) && M.stat == DEAD)
		to_chat(user, "<span class='notice'>You wonder if [M.p_they()] was a good dog. <b>[src] tells you they were the best...</b></span>") // :'(
		playsound(loc, 'sound/machines/ping.ogg', 50, 0)
		ready = FALSE
		update_icon(UPDATE_ICON_STATE)
		addtimer(CALLBACK(src, TYPE_PROC_REF(/obj/item/bodyanalyzer, setReady)), scan_cd)
		time_to_use = world.time + scan_cd
	else
		to_chat(user, "<span class='notice'>Scanning error detected. Invalid specimen.</span>")

//Unashamedly ripped from adv_med.dm
/obj/item/bodyanalyzer/proc/generate_printing_text(mob/living/M, mob/user)
	var/dat = ""
	var/mob/living/carbon/human/target = M

	dat = "<font color='blue'><b>Target Statistics:</b></font><br>"
	var/t1
	switch(target.stat) // obvious, see what their status is
		if(CONSCIOUS)
			t1 = "Conscious"
		if(UNCONSCIOUS)
			t1 = "Unconscious"
		else
			t1 = "*dead*"
	dat += "[target.health > 50 ? "<font color='blue'>" : "<font color='red'>"]\tHealth %: [target.health], ([t1])</font><br>"

	var/found_disease = FALSE
	for(var/thing in target.diseases)
		var/datum/disease/D = thing
		if(D.visibility_flags & HIDDEN_SCANNER)
			continue
		found_disease = TRUE
		break
	if(found_disease)
		dat += "<font color='red'>Disease detected in target.</font><BR>"

	var/extra_font = null
	extra_font = (target.getBruteLoss() < 60 ? "<font color='blue'>" : "<font color='red'>")
	dat += "[extra_font]\t-Brute Damage %: [target.getBruteLoss()]</font><br>"

	extra_font = (target.getOxyLoss() < 60 ? "<font color='blue'>" : "<font color='red'>")
	dat += "[extra_font]\t-Respiratory Damage %: [target.getOxyLoss()]</font><br>"

	extra_font = (target.getToxLoss() < 60 ? "<font color='blue'>" : "<font color='red'>")
	dat += "[extra_font]\t-Toxin Content %: [target.getToxLoss()]</font><br>"

	extra_font = (target.getFireLoss() < 60 ? "<font color='blue'>" : "<font color='red'>")
	dat += "[extra_font]\t-Burn Severity %: [target.getFireLoss()]</font><br>"

	extra_font = (target.radiation < 10 ?"<font color='blue'>" : "<font color='red'>")
	dat += "[extra_font]\tRadiation Level %: [target.radiation]</font><br>"

	extra_font = (target.getCloneLoss() < 1 ?"<font color='blue'>" : "<font color='red'>")
	dat += "[extra_font]\tGenetic Tissue Damage %: [target.getCloneLoss()]<br>"

	extra_font = (target.getBrainLoss() < 1 ?"<font color='blue'>" : "<font color='red'>")
	dat += "[extra_font]\tApprox. Brain Damage %: [target.getBrainLoss()]<br>"

	dat += "Paralysis Summary %: [target.AmountParalyzed()] ([round(target.AmountParalyzed() / 10)] seconds left!)<br>"
	dat += "Body Temperature: [target.bodytemperature-T0C]&deg;C ([target.bodytemperature*1.8-459.67]&deg;F)<br>"

	dat += "<hr>"

	if(target.has_brain_worms())
		dat += "Large growth detected in frontal lobe, possibly cancerous. Surgical removal is recommended.<br>"

	var/blood_percent =  round((target.blood_volume / BLOOD_VOLUME_NORMAL))
	blood_percent *= 100

	extra_font = (target.blood_volume > 448 ? "<font color='blue'>" : "<font color='red'>")
	dat += "[extra_font]\tBlood Level %: [blood_percent] ([target.blood_volume] units)</font><br>"

	if(target.reagents)
		dat += "Epinephrine units: [target.reagents.get_reagent_amount("Epinephrine")] units<BR>"
		dat += "Ether: [target.reagents.get_reagent_amount("ether")] units<BR>"

		extra_font = (target.reagents.get_reagent_amount("silver_sulfadiazine") < 30 ? "<font color='black'>" : "<font color='red'>")
		dat += "[extra_font]\tSilver Sulfadiazine: [target.reagents.get_reagent_amount("silver_sulfadiazine")]</font><br>"

		extra_font = (target.reagents.get_reagent_amount("styptic_powder") < 30 ? "<font color='black'>" : "<font color='red'>")
		dat += "[extra_font]\tStyptic Powder: [target.reagents.get_reagent_amount("styptic_powder")] units<BR>"

		extra_font = (target.reagents.get_reagent_amount("salbutamol") < 30 ? "<font color='black'>" : "<font color='red'>")
		dat += "[extra_font]\tSalbutamol: [target.reagents.get_reagent_amount("salbutamol")] units<BR>"

	dat += "<hr><table border='1'>"
	dat += "<tr>"
	dat += "<th>Organ</th>"
	dat += "<th>Burn Damage</th>"
	dat += "<th>Brute Damage</th>"
	dat += "<th>Other Wounds</th>"
	dat += "</tr>"

	for(var/obj/item/organ/external/e as anything in target.bodyparts)
		dat += "<tr>"
		var/AN = ""
		var/open = ""
		var/infected = ""
		var/robot = ""
		var/imp = ""
		var/bled = ""
		var/splint = ""
		var/internal_bleeding = ""
		var/lung_ruptured = ""
		if(e.has_internal_bleeding())
			internal_bleeding = "<br>Internal bleeding"
		if(istype(e, /obj/item/organ/external/chest) && target.is_lung_ruptured())
			lung_ruptured = "Lung ruptured:"
		if(e.is_splinted())
			splint = "Splinted:"
		if(e.has_fracture())
			AN = "[e.broken_description]:"
		if(e.is_robotic())
			robot = "Robotic:"
		if(e.open)
			open = "Open:"
		switch(e.germ_level)
			if(INFECTION_LEVEL_ONE to INFECTION_LEVEL_ONE + 200)
				infected = "Mild Infection:"
			if(INFECTION_LEVEL_ONE + 200 to INFECTION_LEVEL_ONE + 300)
				infected = "Mild Infection+:"
			if(INFECTION_LEVEL_ONE + 300 to INFECTION_LEVEL_ONE + 400)
				infected = "Mild Infection++:"
			if(INFECTION_LEVEL_TWO to INFECTION_LEVEL_TWO + 200)
				infected = "Acute Infection:"
			if(INFECTION_LEVEL_TWO + 200 to INFECTION_LEVEL_TWO + 300)
				infected = "Acute Infection+:"
			if(INFECTION_LEVEL_TWO + 300 to INFECTION_LEVEL_TWO + 400)
				infected = "Acute Infection++:"
			if(INFECTION_LEVEL_THREE to INFINITY)
				infected = "Septic:"

		if(LAZYLEN(e.embedded_objects) || e.hidden)
			imp += "Unknown body present:"
		if(!AN && !open && !infected && !imp)
			AN = "None:"
		dat += "<td>[e.name]</td><td>[e.burn_dam]</td><td>[e.brute_dam]</td><td>[robot][bled][AN][splint][open][infected][imp][internal_bleeding][lung_ruptured]</td>"
		dat += "</tr>"
	for(var/obj/item/organ/internal/organ as anything in target.internal_organs)
		var/mech = organ.desc
		var/infection = "None"
		switch(organ.germ_level)
			if(1 to INFECTION_LEVEL_ONE + 200)
				infection = "Mild Infection:"
			if(INFECTION_LEVEL_ONE + 200 to INFECTION_LEVEL_ONE + 300)
				infection = "Mild Infection+:"
			if(INFECTION_LEVEL_ONE + 300 to INFECTION_LEVEL_ONE + 400)
				infection = "Mild Infection++:"
			if(INFECTION_LEVEL_TWO to INFECTION_LEVEL_TWO + 200)
				infection = "Acute Infection:"
			if(INFECTION_LEVEL_TWO + 200 to INFECTION_LEVEL_TWO + 300)
				infection = "Acute Infection+:"
			if(INFECTION_LEVEL_TWO + 300 to INFINITY)
				infection = "Acute Infection++:"

		dat += "<tr>"
		dat += "<td>[organ.name]</td><td>N/A</td><td>[organ.damage]</td><td>[infection]:[mech]</td><td></td>"
		dat += "</tr>"
	dat += "</table>"
	if(HAS_TRAIT(target, TRAIT_BLIND))
		dat += "<font color='red'>Cataracts detected.</font><BR>"
	if(HAS_TRAIT(target, TRAIT_COLORBLIND))
		dat += "<font color='red'>Photoreceptor abnormalities detected.</font><BR>"
	if(HAS_TRAIT(target, TRAIT_NEARSIGHTED))
		dat += "<font color='red'>Retinal misalignment detected.</font><BR>"

	return dat
