/obj/machinery/computer/telescience
	name = "telepad control console"
	desc = "Используется для телепортации объектов на телепад и обратно."
	ru_names = list(
		NOMINATIVE = "консоль управления телепадом",
		GENITIVE = "консоли управления телепадом",
		DATIVE = "консоли управления телепадом",
		ACCUSATIVE = "консоль управления телепадом",
		INSTRUMENTAL = "консолью управления телепадом",
		PREPOSITIONAL = "консоли управления телепадом"
	)
	icon_keyboard = "telesci_key"
	icon_screen = "telesci"
	circuit = /obj/item/circuitboard/telesci_console
	req_access = list(ACCESS_RESEARCH)
	var/sending = 1
	var/obj/machinery/telepad/telepad = null
	var/temp_msg = "Консоль управления теле-наукой инициализирована.<br>Добро пожаловать."

	// VARIABLES //
	var/teles_left	// How many teleports left until it becomes uncalibrated
	var/datum/projectile_data/last_tele_data = null
	var/z_co = 1
	var/power_off
	var/rotation_off
	//var/angle_off
	var/last_target

	var/rotation = 0
	var/angle = 45
	var/power = 5

	// Based on the power used
	var/teleport_cooldown = 0 // every index requires a bluespace crystal
	var/list/power_options = list(5, 10, 20, 25, 30, 40, 50, 80)
	var/teleporting = 0
	var/crystals = 0
	var/max_crystals = 4
	var/obj/item/gps/inserted_gps

/obj/machinery/computer/telescience/New()
	..()
	recalibrate()

/obj/machinery/computer/telescience/Destroy()
	eject()
	if(inserted_gps)
		inserted_gps.forceMove(loc)
		inserted_gps = null
	return ..()

/obj/machinery/computer/telescience/examine(mob/user)
	. = ..()
	. += span_notice("В слотах для кристаллов [crystals ? "[crystals] кристалл[declension_ru(crystals,"","а","ов")]" : "нет кристаллов"] блюспейса.")


/obj/machinery/computer/telescience/attackby(obj/item/I, mob/user, params)
	if(user.a_intent == INTENT_HARM)
		return ..()

	if(istype(I, /obj/item/stack/ore/bluespace_crystal))
		add_fingerprint(user)
		var/obj/item/stack/ore/bluespace_crystal/crystal = I
		if(crystals >= max_crystals)
			to_chat(user, span_warning("Недостаточно слотов для кристаллов."))
			return ATTACK_CHAIN_PROCEED
		if(!crystal.use(1))
			to_chat(user, span_warning("Требуется хотя бы один [crystal.singular_name] для продолжения."))
			return ATTACK_CHAIN_PROCEED
		crystals++
		updateUsrDialog()
		user.visible_message(
			span_notice("[user] вставля[pluralize_ru(user.gender,"ет","ют")] [crystal.singular_name] в слот для кристаллов [src]."),
			span_notice("Вы вставляете [crystal.singular_name] в слот для кристаллов [src].")
		)
		return ATTACK_CHAIN_PROCEED_SUCCESS

	if(istype(I, /obj/item/gps))
		add_fingerprint(user)
		if(inserted_gps)
			to_chat(user, span_warning("Слот для GPS устройства уже занят."))
			return ATTACK_CHAIN_PROCEED
		if(!user.drop_transfer_item_to_loc(I, src))
			return ..()
		inserted_gps = I
		updateUsrDialog()
		user.visible_message(
			span_notice("[user] вставляет [I.declent_ru(ACCUSATIVE)] в слот для GPS устройства [src.declent_ru(GENITIVE)]."),
			span_notice("Вы вставляете [I.declent_ru(ACCUSATIVE)] в слот для GPS устройства [src.declent_ru(GENITIVE)].")
		)
		return ATTACK_CHAIN_BLOCKED_ALL

	return ..()


/obj/machinery/computer/telescience/multitool_act(mob/living/user, obj/item/I)
	if(!istype(I, /obj/item/multitool))
		return FALSE
	. = TRUE
	var/obj/item/multitool/multitool = I
	if(!istype(multitool.buffer, /obj/machinery/telepad))
		add_fingerprint(user)
		to_chat(user, span_warning("Буфер [multitool.declent_ru(GENITIVE)] не содержит валидных данных."))
		return .
	if(!I.use_tool(src, user, volume = I.tool_volume))
		return .
	telepad = multitool.buffer
	multitool.buffer = null
	updateUsrDialog()
	to_chat(user, span_notice("Вы загрузили данные из буфера [multitool.declent_ru(GENITIVE)]."))


/obj/machinery/computer/telescience/emag_act(mob/user)
	if(!emagged)
		if(user)
			to_chat(user, span_notice("Вы шифруете ключ аутентификации телепортации с неизвестным сигналом. Теперь у вас есть возможность перемещаться в ещё больше мест!"))
		emagged = 1
	else if(user)
		to_chat(user, span_warning("Машина никак не реагирует на проведение картой..."))

/obj/machinery/computer/telescience/attack_ai(mob/user)
	src.attack_hand(user)

/obj/machinery/computer/telescience/attack_hand(mob/user)
	if(isgolem(user)) //this is why we can't have nice things free golems
		to_chat(user, span_warning("Вы не можете разобраться, как использовать эту консоль."))
		return
	if(..())
		return
	interact(user)

/obj/machinery/computer/telescience/interact(mob/user)
	user.set_machine(src)
	var/t
	if(!telepad)
		in_use = 0     //Yeah so if you deconstruct teleporter while its in the process of shooting it wont disable the console
		t += "<div class='statusDisplay'>No telepad located. <br>Please add telepad data.</div><br>"
	else
		if(inserted_gps)
			t += "<a href='byond://?src=[UID()];ejectGPS=1'>Eject GPS</a>"
			t += "<a href='byond://?src=[UID()];setMemory=1'>Set GPS memory</a>"
		else
			t += "<span class='linkOff'>Eject GPS</span>"
			t += "<span class='linkOff'>Set GPS memory</span>"
		t += "<div class='statusDisplay'>[temp_msg]</div><br>"
		t += "<a href='byond://?src=[UID()];setrotation=1'>Set Bearing</a>"
		t += "<div class='statusDisplay'>[rotation] degrees</div>"
		t += "<a href='byond://?src=[UID()];setangle=1'>Set Elevation</a>"
		t += "<div class='statusDisplay'>[angle] degrees</div>"
		t += "<span class='linkOn'>Set Power</span>"
		t += "<div class='statusDisplay'>"

		for(var/i = 1; i <= power_options.len; i++)
			if(crystals + telepad.efficiency < i)
				t += "<span class='linkOff'>[power_options[i]]</span>"
				continue
			if(power == power_options[i])
				t += "<span class='linkOn'>[power_options[i]]</span>"
				continue
			t += "<a href='byond://?src=[UID()];setpower=[i]'>[power_options[i]]</a>"
		t += "</div>"

		t += "<a href='byond://?src=[UID()];setz=1'>Set Sector</a>"
		t += "<div class='statusDisplay'>[z_co ? z_co : "NULL"]</div>"

		t += "<br><a href='byond://?src=[UID()];send=1'>Send</a>"
		t += " <a href='byond://?src=[UID()];receive=1'>Receive</a>"
		t += "<br><a href='byond://?src=[UID()];recal=1'>Recalibrate Crystals</a> <a href='byond://?src=[UID()];eject=1'>Eject Crystals</a>"

		// Information about the last teleport
		t += "<br><div class='statusDisplay'>"
		if(!last_tele_data)
			t += "No teleport data found."
		else
			t += "Source Location: ([last_tele_data.src_x], [last_tele_data.src_y])<br>"
			//t += "Distance: [round(last_tele_data.distance, 0.1)]m<br>"
			t += "Time: [round(last_tele_data.time, 0.1)] secs<br>"
		t += "</div>"

	var/datum/browser/popup = new(user, "telesci", name, 300, 500)
	popup.set_content(t)
	popup.open()
	return

/obj/machinery/computer/telescience/proc/sparks()
	if(telepad)
		do_sparks(5, 1, get_turf(telepad))
	else
		return

/obj/machinery/computer/telescience/proc/telefail()
	sparks()
	visible_message(span_warning("Телепад слабо потрескивает."))
	return

/obj/machinery/computer/telescience/proc/doteleport(mob/user)

	if(teleport_cooldown > world.time)
		temp_msg = "Телепад перезаряжается.<br>Подождите [round((teleport_cooldown - world.time) / 10)] сек."
		return

	if(teleporting)
		temp_msg = "Телепад используется.<br>Подождите."
		return

	if(telepad)

		var/truePower = clamp(power + power_off, 1, 1000)
		var/trueRotation = rotation + rotation_off
		var/trueAngle = clamp(angle, 1, 90)

		var/datum/projectile_data/proj_data = projectile_trajectory(telepad.x, telepad.y, trueRotation, trueAngle, truePower)
		last_tele_data = proj_data

		var/trueX = clamp(round(proj_data.dest_x, 1), 1, world.maxx)
		var/trueY = clamp(round(proj_data.dest_y, 1), 1, world.maxy)
		var/spawn_time = round(proj_data.time) * 10

		var/turf/target = locate(trueX, trueY, z_co)
		last_target = target
		var/area/A = get_area(target)
		flick("[initial(telepad.icon_state)]-beam", telepad)

		if(spawn_time > 15) // 1.5 seconds
			playsound(telepad.loc, 'sound/weapons/flash.ogg', 25, TRUE)
			// Wait depending on the time the projectile took to get there
			teleporting = 1
			temp_msg = "Зарядка кристаллов блюспейса.<br>Подождите."


		spawn(round(proj_data.time) * 10) // in seconds
			if(!telepad)
				return
			if(telepad.stat & NOPOWER)
				return
			teleporting = 0
			teleport_cooldown = world.time + (power * 2)
			teles_left -= 1

			// use a lot of power
			use_power(power * 10)

			do_sparks(5, 1, get_turf(telepad))

			temp_msg = "Телепортация успешна.<br>"
			if(teles_left < 10)
				temp_msg += "<br>Требуется калибровка."
			else
				temp_msg += "Данные напечатаны ниже."

			var/sparks = get_turf(target)
			do_sparks(5, 1, sparks)

			var/turf/source = target
			var/turf/dest = get_turf(telepad)
			var/log_msg = ""
			log_msg += ": [key_name(user)] телепортировал "

			if(sending)
				source = dest
				dest = target

			flick("[initial(telepad.icon_state)]-beam", telepad)
			playsound(telepad.loc, 'sound/weapons/emitter2.ogg', 50, TRUE)
			for(var/atom/movable/ROI in source)
				// if is anchored, don't let through
				if(ROI.anchored)
					if(isliving(ROI))
						var/mob/living/L = ROI
						if(L.buckled)
							// TP people on office chairs
							if(L.buckled.anchored)
								continue

							log_msg += "[key_name(L)] (на стуле), "
						else
							continue
					else if(!isobserver(ROI))
						continue
				if(ismob(ROI))
					var/mob/T = ROI
					log_msg += "[key_name(T)], "
				else
					log_msg += "[ROI.name]"
					if(istype(ROI, /obj/structure/closet))
						var/obj/structure/closet/C = ROI
						log_msg += " ("
						for(var/atom/movable/Q as mob|obj in C)
							if(ismob(Q))
								log_msg += "[key_name(Q)], "
							else
								log_msg += "[Q.name], "
						if(dd_hassuffix(log_msg, "("))
							log_msg += "пусто)"
						else
							log_msg = dd_limittext(log_msg, length(log_msg) - 2)
							log_msg += ")"
					log_msg += ", "
				do_teleport(ROI, dest)

			if(dd_hassuffix(log_msg, ", "))
				log_msg = dd_limittext(log_msg, length(log_msg) - 2)
			else
				log_msg += "ничего"
			log_msg += " [sending ? "в" : "из"] [trueX], [trueY], [z_co] ([A ? A.name : "null area"])"
			updateUsrDialog()

/obj/machinery/computer/telescience/proc/teleport(mob/user)
	if(rotation == null || angle == null || z_co == null)
		temp_msg = "ОШИБКА!<br>Установите угол, поворот и сектор."
		return
	if(power <= 0)
		telefail()
		temp_msg = "ОШИБКА!<br>Не выбрана мощность!"
		return
	if(angle < 1 || angle > 90)
		telefail()
		temp_msg = "ОШИБКА!<br>Угол меньше 1 или больше 90."
		return
	if(z_co == 2 || z_co < 1 || z_co > 6)
		if(z_co == 7 & emagged == 1)
		// This should be empty, allows for it to continue if the z-level is 7 and the machine is emagged.
		else
			telefail()
			temp_msg = "ОШИБКА! Сектор меньше 1, <br>больше [src.emagged ? "7" : "6"], или равен 2."
			return


	var/truePower = clamp(power + power_off, 1, 1000)
	var/trueRotation = rotation + rotation_off
	var/trueAngle = clamp(angle, 1, 90)

	var/datum/projectile_data/proj_data = projectile_trajectory(telepad.x, telepad.y, trueRotation, trueAngle, truePower)
	var/turf/target = locate(clamp(round(proj_data.dest_x, 1), 1, world.maxx), clamp(round(proj_data.dest_y, 1), 1, world.maxy), z_co)
	var/area/A = get_area(target)

	if(A.tele_proof == 1)
		telefail()
		temp_msg = "ОШИБКА! Цель недостижима из-за помех."
		return

	if(teles_left > 0)
		if(!doteleport(user))
			telefail()
			temp_msg = "ОШИБКА! Цель недостижима из-за помех."
			return
	else
		telefail()
		temp_msg = "ОШИБКА!<br>Требуется калибровка."
		return
	return

/obj/machinery/computer/telescience/proc/eject()
	var/to_eject
	for(var/i in 1 to crystals)
		to_eject += 1
		crystals -= 1
	new /obj/item/stack/ore/bluespace_crystal/artificial(drop_location(), to_eject)
	power = 0

/obj/machinery/computer/telescience/Topic(href, href_list)
	if(..())
		return
	if(!telepad)
		updateUsrDialog()
		return
	if(telepad.panel_open)
		temp_msg = "Телепад проходит обслуживание."

	if(href_list["setrotation"])
		var/new_rot = tgui_input_number(usr, "Введите желаемый азимут в градусах.", name, rotation)
		if(..()) // Check after we input a value, as they could've moved after they entered something
			return
		rotation = clamp(new_rot, -900, 900)
		rotation = round(rotation, 0.01)

	if(href_list["setangle"])
		var/new_angle = tgui_input_number(usr, "Введите желаемый угол возвышения в градусах.", name, angle)
		if(..())
			return
		angle = clamp(round(new_angle, 0.1), 1, 9999)

	if(href_list["setpower"])
		var/index = href_list["setpower"]
		index = text2num(index)
		if(index != null && power_options[index])
			if(crystals + telepad.efficiency >= index)
				power = power_options[index]

	if(href_list["setz"])
		var/new_z = tgui_input_number(usr, "Введите желаемый сектор.", name, z_co)
		if(..())
			return
		z_co = clamp(round(new_z), 1, 10)

	if(href_list["ejectGPS"])
		if(inserted_gps)
			inserted_gps.forceMove_turf()
			usr.put_in_hands(inserted_gps, ignore_anim = FALSE)
			inserted_gps = null

	if(href_list["setMemory"])
		if(last_target && inserted_gps)
			inserted_gps.locked_location = last_target
			temp_msg = "Локация сохранена."
		else
			temp_msg = "ОШИБКА!<br>Данные не сохранены."

	if(href_list["send"])
		sending = 1
		teleport(usr)

	if(href_list["receive"])
		sending = 0
		teleport(usr)

	if(href_list["recal"])
		recalibrate()
		sparks()
		temp_msg = "УВЕДОМЛЕНИЕ:<br>Калибровка успешна."

	if(href_list["eject"])
		eject()
		temp_msg = "УВЕДОМЛЕНИЕ:<br>Кристаллы блюспейса извлечены."

	updateUsrDialog()

/obj/machinery/computer/telescience/proc/recalibrate()
	teles_left = rand(30, 40)
	//angle_off = rand(-25, 25)
	power_off = rand(-4, 0)
	rotation_off = rand(-10, 10)
