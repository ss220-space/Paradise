//Сканеры для исследования разломов и передачи данных на сервера
//=============================
//Портативный сканер 1х1
//=============================
/obj/item/circuitboard/brs_scanner
	name = "Портативный сканер разлома (Computer Board)"
	build_path = /obj/machinery/brs_scanner
	icon_state = "scannerplat"
	origin_tech = "engineering=4;bluespace=3"
	req_components = list(
					/obj/item/stack/sheet/metal = 5,
					/obj/item/stock_parts/capacitor/super = 2,
					/obj/item/stock_parts/micro_laser/ultra = 1,
					/obj/item/stock_parts/scanning_module/phasic = 5,
					/obj/item/stack/ore/bluespace_crystal = 1
					)

/obj/machinery/brs_scanner
	name = "Портативный сканер разлома"
	icon = 'icons/obj/machines/BRS/scanner_dynamic.dmi'
	icon_state = "scanner"
	anchored = FALSE
	density = FALSE
	var/toggle = FALSE	//вывиднут/задвинут
	var/active = FALSE	//активность блюспейс-разлома
	var/toggle_sound = 'sound/effects/servostep.ogg'
	var/activate_sound = 'sound/effects/electheart.ogg'
	var/deactivate_sound = 'sound/effects/basscannon.ogg'
	var/alarm_sound = 'sound/effects/alert.ogg'
	//var/id = 0

/obj/machinery/brs_scanner/proc/change_active()
	active = !active
	if (active)
		playsound(loc, activate_sound, 100, 1)
	else
		playsound(loc, deactivate_sound, 100, 1)

/obj/machinery/brs_scanner/update_icon()
	var/prefix = initial(icon_state)
	if (anchored)
		if (toggle)
			if (active)
				if (emagged)
					icon_state = "[prefix]-act-emagged"
				else
					icon_state = "[prefix]-act"
			else
				icon_state = "[prefix]-on"
		else
			icon_state = "[prefix]-anchored"
	else
		icon_state = prefix

//Взаимодействия
/obj/machinery/brs_scanner/wrench_act(mob/living/user, obj/item/I)
	default_unfasten_wrench(user, I, 40)
	update_icon()
	return TRUE

/obj/machinery/brs_scanner/attack_hand(mob/user)
	if(..())
		return TRUE
	if(toggle || !anchored)
		return FALSE
	if(do_after(user, 20, target = src))
		playsound(loc, toggle_sound, 100, 1)
		toggle = !toggle
		density = !density
		update_icon()

//Перезапись протоколов безопасности.
/obj/machinery/brs_scanner/proc/rewrite_protocol()
	emagged = TRUE
	playsound(loc, 'sound/effects/sparks4.ogg', 60, TRUE)
	update_icon()
	// сканнер отрубает протоколы и может в крит зонах находиться, но вдали от дальней зоны - он бахнет.

/obj/machinery/brs_scanner/emag_act(mob/user)
	if(!emagged)
		rewrite_protocol()
		to_chat(user, "<span class='notice'>Протоколы безопасности сканнера перезаписаны.</span>")

/obj/machinery/brs_scanner/emp_act(severity)
	if(!emagged && prob(40 / severity))
		rewrite_protocol()

//=============================
//Статичный сканер 3х3
//=============================

/obj/item/circuitboard/brs_scanner/brs_scanner_static
	name = "Статичный сканер разлома (Computer Board)"
	build_path = /obj/machinery/brs_scanner/brs_scanner_static
	icon_state = "bluespace_scannerplat"
	origin_tech = "engineering=6;bluespace=5"
	req_components = list(
					/obj/item/stack/sheet/metal = 30,
					/obj/item/stock_parts/capacitor/super = 8,
					/obj/item/stock_parts/micro_laser/ultra = 2,
					/obj/item/stock_parts/scanning_module/phasic = 10,
					/obj/item/stack/ore/bluespace_crystal = 4
					)

/obj/machinery/brs_scanner/brs_scanner_static
	name = "Статичный сканер разлома"
	icon = 'icons/obj/machines/BRS/scanner_static.dmi'
	icon_state = "scanner"
