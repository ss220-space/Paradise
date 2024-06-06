/*
Destructive Analyzer

It is used to destroy hand-held objects and advance technological research. Controls are in the linked R&D console.

Note: Must be placed within 3 tiles of the R&D Console
*/
/obj/machinery/r_n_d/destructive_analyzer
	name = "Destructive Analyzer"
	desc = "Изучайте науку, разрушая предметы!"
	icon_state = "d_analyzer"
	base_icon_state = "d_analyzer"
	var/decon_mod = 0

/obj/machinery/r_n_d/destructive_analyzer/New()
	..()
	component_parts = list()
	component_parts += new /obj/item/circuitboard/destructive_analyzer(null)
	component_parts += new /obj/item/stock_parts/scanning_module(null)
	component_parts += new /obj/item/stock_parts/manipulator(null)
	component_parts += new /obj/item/stock_parts/micro_laser(null)
	RefreshParts()
	if(is_taipan(z))
		icon_state = "syndie_d_analyzer"
		base_icon_state = "syndie_d_analyzer"

/obj/machinery/r_n_d/destructive_analyzer/upgraded/New()
	..()
	component_parts = list()
	component_parts += new /obj/item/circuitboard/destructive_analyzer(null)
	component_parts += new /obj/item/stock_parts/scanning_module/phasic(null)
	component_parts += new /obj/item/stock_parts/manipulator/pico(null)
	component_parts += new /obj/item/stock_parts/micro_laser/ultra(null)
	RefreshParts()
	if(is_taipan(z))
		icon_state = "syndie_d_analyzer"
		base_icon_state = "syndie_d_analyzer"

/obj/machinery/r_n_d/destructive_analyzer/RefreshParts()
	var/T = 0
	for(var/obj/item/stock_parts/S in component_parts)
		T += S.rating
	decon_mod = T


/obj/machinery/r_n_d/destructive_analyzer/proc/ConvertReqString2List(list/source_list)
	var/list/temp_list = params2list(source_list)
	for(var/O in temp_list)
		temp_list[O] = text2num(temp_list[O])
	return temp_list


/obj/machinery/r_n_d/destructive_analyzer/attackby(obj/item/O, mob/user, params)
	if(shocked)
		add_fingerprint(user)
		if(shock(user,50))
			return TRUE
	if(default_deconstruction_screwdriver(user, "[base_icon_state]_t", base_icon_state, O))
		add_fingerprint(user)
		if(linked_console)
			linked_console.linked_destroy = null
			linked_console = null
		return

	if(exchange_parts(user, O))
		return

	if(default_deconstruction_crowbar(user, O))
		return

	if(disabled)
		return
	if(!linked_console)
		to_chat(user, "<span class='warning'>[src.name] сперва требуется подключить к R&D консоли!</span>")
		return
	if(busy)
		to_chat(user, "<span class='warning'>[src.name] сейчас занят.</span>")
		return
	if(isitem(O) && !loaded_item)
//Ядра аномалий можно разобрать только при улучшеном автомате. 3x4(femto-manipulator,quad-ultra micro-laser,triphasic scanning module)
		if(istype(O,/obj/item/assembly/signaler/anomaly) && (decon_mod < 12))
			to_chat(user, "<span class='warning'>[src.name] не может обработать такой сложный предмет!</span>")
			return
		if(!O.origin_tech)
			to_chat(user, "<span class='warning'>Предмет не имеет технологического происхождения!</span>")
			return
		var/list/temp_tech = ConvertReqString2List(O.origin_tech)
		if(temp_tech.len == 0)
			to_chat(user, "<span class='warning'>Вы не можете разобрать этот предмет!</span>")
			return
		if(!user.drop_transfer_item_to_loc(O, src))
			to_chat(user, "<span class='warning'>[O] прилип к вашей руке и вы не можете поместить его в [src.name]!</span>")
			return
		add_fingerprint(user)
		busy = TRUE
		flick("[base_icon_state]_la", src)
		loaded_item = O
		to_chat(user, "<span class='notice'>[O.name] установлен в [src.name]!</span>")
		addtimer(CALLBACK(src, PROC_REF(reset_processing)), 1 SECONDS)


/obj/machinery/r_n_d/destructive_analyzer/proc/reset_processing()
	busy = FALSE
	update_icon(UPDATE_ICON_STATE)


/obj/machinery/r_n_d/destructive_analyzer/update_icon_state()
	if(loaded_item)
		icon_state = "[base_icon_state]_l"
	else
		icon_state = base_icon_state

