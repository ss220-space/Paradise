//DNA machine
/obj/machinery/dnaforensics
	name = "Анализатор ДНК"
	desc = "Высокотехнологичная машина, которая предназначена для правильного считывания образцов ДНК."
	icon = 'icons/obj/forensics.dmi'
	icon_state = "dnaopen"
	layer = BELOW_OBJ_LAYER
	anchored = TRUE
	density = TRUE

	var/obj/item/forensics/swab = null
	var/scanning = 0
	var/report_num = 0

/obj/machinery/dnaforensics/Initialize(mapload)
	. = ..()
	component_parts = list()
	component_parts += new /obj/item/circuitboard/dnaforensics(null)
	component_parts += new /obj/item/stock_parts/micro_laser(null)
	component_parts += new /obj/item/stock_parts/manipulator(null)
	component_parts += new /obj/item/stock_parts/micro_laser(null)


/obj/machinery/dnaforensics/attackby(obj/item/I, mob/user, params)
	if(user.a_intent == INTENT_HARM)
		return ..()

	if(istype(I, /obj/item/forensics/swab))
		add_fingerprint(user)
		if(swab)
			to_chat(user, span_warning("Внутри сканера уже есть пробирка."))
			return ATTACK_CHAIN_PROCEED
		if(!user.drop_transfer_item_to_loc(I, src))
			return ..()
		to_chat(user, span_notice("Вы вставляете пробирку в ДНК анализатор."))
		swab = I
		update_icon(UPDATE_ICON_STATE)
		return ATTACK_CHAIN_BLOCKED_ALL

	return ..()


/obj/machinery/dnaforensics/attack_hand(mob/user)

	if(!swab)
		to_chat(user, "<span class='warning'>Сканер пуст!</span>")
		return
	add_fingerprint(user)
	scanning = TRUE
	update_icon(UPDATE_ICON_STATE)
	to_chat(user, "<span class='notice'>Сканер начинает с жужением анализировать содержимое пробирки \the [swab].</span>")

	if(!do_after(user, 2.5 SECONDS, src) || !swab)
		to_chat(user, "<span class='notice'>Вы перестали анализировать \the [swab].</span>")
		scanning = FALSE
		update_icon(UPDATE_ICON_STATE)

		return

	to_chat(user, "<span class='notice'>Печать отчета...</span>")
	var/obj/item/paper/report = new(get_turf(src))
	report.stamp(/obj/item/stamp)
	report_num++

	if(swab)
		var/obj/item/forensics/swab/bloodswab = swab
		report.name = ("Отчет ДНК сканера №[++report_num]: [bloodswab.name]")
		//dna data itself
		var/data = "Нет доступных данных по анализу."
		if(bloodswab.dna != null)
			data = "Спектрометрический анализ на предоставленном образце определил наличие нитей ДНК в количестве [bloodswab.dna.len].<br><br>"
			for(var/blood in bloodswab.dna)
				data += "<span class='notice'>Группа крови: [bloodswab.dna[blood]]<br>\nДНК: [blood]</span><br><br>"
		else
			data += "\nДНК не найдено.<br>"
		report.info = "<b>Отчет №[report_num] по \n[src]</b><br>"
		report.info += "<b>\nАнализируемый объект:</b><br>[bloodswab.name]<br>[bloodswab.desc]<br><br>" + data
		report.forceMove(src.loc)
		report.update_icon()
		scanning = FALSE
		update_icon(UPDATE_ICON_STATE)
	return

/obj/machinery/dnaforensics/proc/remove_sample(mob/living/remover)
	if(!istype(remover) || remover.incapacitated() || HAS_TRAIT(remover, TRAIT_HANDS_BLOCKED) || !Adjacent(remover))
		return
	if(!swab)
		to_chat(remover, "<span class='warning'>Внутри сканера нет образца!.</span>")
		return
	to_chat(remover, "<span class='notice'>Вы вытащили \the [swab] из сканера.</span>")
	swab.forceMove_turf()
	remover.put_in_hands(swab, ignore_anim = FALSE)
	swab = null
	update_icon(UPDATE_ICON_STATE)

/obj/machinery/dnaforensics/AltClick(mob/user)
	remove_sample(user)

/obj/machinery/dnaforensics/MouseDrop(atom/over_object, src_location, over_location, src_control, over_control, params)
	if(usr == over_object)
		remove_sample(usr)
		return FALSE
	return ..()

/obj/machinery/dnaforensics/update_icon_state()
	icon_state = "dnaopen"
	if(swab)
		icon_state = "dnaclosed"
		if(scanning)
			icon_state = "dnaworking"

/obj/machinery/dnaforensics/screwdriver_act(mob/user, obj/item/I)
	if(swab)
		return
	. = TRUE
	default_deconstruction_screwdriver(user, "dnaopenunpowered", "dnaopen", I)

/obj/machinery/dnaforensics/wrench_act(mob/user, obj/item/I)
	. = TRUE
	default_unfasten_wrench(user, I)

/obj/machinery/dnaforensics/crowbar_act(mob/user, obj/item/I)
	if(swab)
		return
	. = TRUE
	default_deconstruction_crowbar(user, I)
