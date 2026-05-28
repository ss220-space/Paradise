//All devices that link into the R&D console fall into thise type for easy identification and some shared procs.

/obj/machinery/r_n_d
	name = "R&D Device"
	icon = 'icons/obj/machines/research.dmi'
	var/icon_open = null
	var/icon_closed = null
	density = TRUE
	anchored = TRUE
	var/busy = 0
	var/hacked = 0
	var/disabled = 0
	var/shocked = 0
	var/list/wires = list()
	var/hack_wire
	var/disable_wire
	var/shock_wire
	var/obj/machinery/computer/rdconsole/linked_console
	var/obj/item/loaded_item = null
	var/datum/component/material_container/materials	//Store for hyper speed!
	var/efficiency_coeff = 1
	var/list/categories = list()

/obj/machinery/r_n_d/Initialize(mapload)
	. = ..()
	materials = AddComponent(/datum/component/material_container, list(MAT_METAL, MAT_GLASS, MAT_SILVER, MAT_GOLD, MAT_DIAMOND, MAT_PLASMA, MAT_URANIUM, MAT_BANANIUM, MAT_TRANQUILLITE, MAT_TITANIUM, MAT_BLUESPACE, MAT_PLASTIC), 0, TRUE, /obj/item/stack, CALLBACK(src, PROC_REF(is_insertion_ready)), CALLBACK(src, PROC_REF(AfterMaterialInsert)))
	materials.precise_insertion = TRUE
	wires["Красный"] = 0
	wires["Синий"] = 0
	wires["Зелёный"] = 0
	wires["Жёлтый"] = 0
	wires["Чёрный"] = 0
	wires["Белый"] = 0
	var/list/w = list("Красный", "Синий", "Зелёный", "Жёлтый", "Чёрный", "Белый")
	hack_wire = pick_n_take(w)
	shock_wire = pick_n_take(w)
	disable_wire = pick_n_take(w)

/obj/machinery/r_n_d/Destroy()
	if(loaded_item)
		loaded_item.forceMove(get_turf(src))
		loaded_item = null
	linked_console = null
	materials = null
	return ..()

/obj/machinery/r_n_d/attack_hand(mob/user as mob)
	if(..())
		return TRUE
	add_fingerprint(user)
	if(shocked)
		shock(user,50)
	if(panel_open)
		var/list/dat = list()
		dat += "Проводка [declent_ru(GENITIVE)]:<br>"
		for(var/wire in wires)
			dat += "[wire] провод: <a href='byond://?src=[UID()];wire=[wire];cut=1'>[wires[wire] ? "Восстановить" : "Перекусить"]</a> <a href='byond://?src=[UID()];wire=[wire];pulse=1'>Прозвонка</a><br>"

		dat += "Красная лампочка <b>[disabled ? "не" : ""]</b> горит.<br>"
		dat += "Зелёная лампочка <b>[shocked ? "не" : ""]</b> горит.<br>"
		dat += "Синяя лампочка <b>[hacked ? "не" : ""]</b> горит.<br>"
		var/datum/browser/popup = new(user, "hack_win", "Проводка [declent_ru(GENITIVE)]")
		popup.set_content(dat.Join(""))
		popup.open(FALSE)
	return

/obj/machinery/r_n_d/Topic(href, href_list)
	if(..())
		return
	usr.set_machine(src)
	add_fingerprint(usr)
	if(href_list["pulse"])
		var/temp_wire = href_list["wire"]
		if(!ismultitool(usr.get_active_hand()))
			balloon_alert(usr, "неподходящий инструмент!")
		else
			if(wires[temp_wire])
				balloon_alert(usr, "провод перекусан!")
			else
				if(hack_wire == href_list["wire"])
					hacked = !hacked
					spawn(100) hacked = !hacked
				if(disable_wire == href_list["wire"])
					disabled = !disabled
					shock(usr,50)
					spawn(100) disabled = !disabled
				if(shock_wire == href_list["wire"])
					shocked = !shocked
					shock(usr,50)
					spawn(100) shocked = !shocked
	if(href_list["cut"])
		if(!iswirecutter(usr.get_active_hand()))
			balloon_alert(usr, "неподходящий инструмент!")
		else
			var/temp_wire = href_list["wire"]
			wires[temp_wire] = !wires[temp_wire]
			if(hack_wire == temp_wire)
				hacked = !hacked
			if(disable_wire == temp_wire)
				disabled = !disabled
				shock(usr,50)
			if(shock_wire == temp_wire)
				shocked = !shocked
				shock(usr,50)
	updateUsrDialog()

//whether the machine can have an item inserted in its current state.
/obj/machinery/r_n_d/proc/is_insertion_ready(mob/user)
	if(panel_open)
		balloon_alert(user, "техпанель открыта!")
		return FALSE
	if(disabled)
		return FALSE
	if(!linked_console)
		balloon_alert(user, "не подключено к консоли!")
		return FALSE
	if(busy)
		balloon_alert(user, "в работе!")
		return FALSE
	if(stat & BROKEN)
		balloon_alert(user, "сломано!")
		return FALSE
	if(stat & NOPOWER)
		balloon_alert(user, "нет энергии!")
		return FALSE
	if(loaded_item)
		balloon_alert(user, "слот для предмета занят!")
		return FALSE
	return TRUE

/obj/machinery/r_n_d/proc/AfterMaterialInsert(type_inserted, id_inserted, amount_inserted)
	var/stack_name
	var/obj/item/stack/S = type_inserted
	if(ispath(type_inserted, /obj/item/stack/ore/bluespace_crystal))
		use_power(MINERAL_MATERIAL_AMOUNT / 10)
	else
		use_power(min(1000, (amount_inserted / 100)))
	stack_name = S.protolathe_name
	flick_overlay_view(mutable_appearance(icon, "[base_icon_state]_[stack_name]"), 1.5 SECONDS)

/obj/machinery/r_n_d/proc/check_mat(datum/design/being_built, M)
	return 0 // number of copies of design beign_built you can make with material M
