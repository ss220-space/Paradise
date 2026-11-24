//This is the output of the stringpercent(print) proc, and means about 80% of
//the print must be there for it to be complete.  (Prints are 32 digits)

//microscope code itself
/obj/machinery/microscope
	name = "Электронный микроскоп"
	desc = "Высокотехнологичный микроскоп, способный увеличивать изображение до 3000 раз."
	icon = 'icons/obj/forensics.dmi'
	icon_state = "microscope"
	anchored = TRUE
	density = TRUE

	var/obj/item/sample = null
	var/report_num = 0
	var/fingerprint_complete = 6

/obj/machinery/microscope/Initialize(mapload)
	. = ..()
	component_parts = list()
	component_parts += new /obj/item/circuitboard/microscope(null)
	component_parts += new /obj/item/stock_parts/micro_laser(null)
	component_parts += new /obj/item/stack/sheet/glass(null)

/obj/machinery/microscope/attackby(obj/item/I, mob/user, params)
	if(user.a_intent == INTENT_HARM)
		return ..()

	if(istype(I, /obj/item/forensics/swab)|| istype(I, /obj/item/sample/fibers) || istype(I, /obj/item/sample/print))
		add_fingerprint(user)
		if(sample)
			to_chat(user, span_warning("В микроскопе уже есть образец."))
			return ATTACK_CHAIN_PROCEED
		if(!user.drop_transfer_item_to_loc(I, src))
			return ..()
		to_chat(user, span_notice("Вы вставляете образец в микроскоп."))
		sample = I
		update_icon(UPDATE_ICON_STATE)
		return ATTACK_CHAIN_BLOCKED_ALL

	return ..()

/obj/machinery/microscope/attack_hand(mob/user)

	if(!sample)
		to_chat(user, span_warning("В микроскопе нет образца для анализа."))
		return

	add_fingerprint(user)
	to_chat(user, span_notice("Микроскоп жужжит, пока вы анализируете \the [sample]."))

	if(!do_after(user, 2.5 SECONDS, src) || !sample)
		to_chat(user, span_notice("Вы перестаёте анализировать \the [sample]."))
		return

	to_chat(user, span_notice("Печать отчета..."))
	var/obj/item/paper/report = new(get_turf(src))
	report.stamp(/obj/item/stamp)
	report_num++

	if(istype(sample, /obj/item/forensics/swab))
		var/obj/item/forensics/swab/swab = sample

		report.name = ("Криминалистический отчет №[++report_num]: [swab.name]")
		report.add_raw_text("**Анализируемый объект:**\n[swab.name]\n\n")

		if(swab.gsr)
			report.add_raw_text("Определен остаток от пули [swab.gsr] калибра.")
		else
			report.add_raw_text("Пороховой остаток от пули не найден.")

	else if(istype(sample, /obj/item/sample/fibers))
		var/obj/item/sample/fibers/fibers = sample
		report.name = ("Отчет по фрагменту ткани №[++report_num]: [fibers.name]")
		report.add_raw_text("**Анализируемый объект:**\n[fibers.name]\n\n")
		if(fibers.evidence)
			report.add_raw_text("Молекулярный анализ на предоставленном образце определил наличие уникальных волоконных струн.\n\n")
			for(var/fiber in fibers.evidence)
				report.add_raw_text("[span_notice("Наиболее вероятное совпадение: [fiber]")]\n\n")
		else
			report.add_raw_text("Волокна не найдены.")
	else if(istype(sample, /obj/item/sample/print))
		report.name = ("Отчет по анализу отпечатков пальцев №[report_num]: [sample.name]")
		report.add_raw_text("**Отчет об анализе отпечатков пальцев №[report_num]**: [sample.name]\n")
		var/obj/item/sample/print/card = sample
		if(card.evidence && length(card.evidence))
			report.add_raw_text("\nПоверхностный анализ определил следующие уникальные строки отпечатков пальцев:\n\n")
			for(var/prints in card.evidence)
				report.add_raw_text(span_notice("Строка отпечатков пальцев: "))
				if(!is_complete_print(prints))
					report.add_raw_text("НЕПОЛНЫЙ ОТПЕЧАТОК")
				else
					report.add_raw_text("[prints]")
				report.add_raw_text("\n")
		else
			report.add_raw_text("Информация по анализу отсутствует.")

	if(report)
		report.update_icon()
		if(!report.is_empty())
			to_chat(user, report.get_raw_text())
	return

/obj/machinery/microscope/proc/remove_sample(mob/living/remover)
	if(!istype(remover) || remover.incapacitated || HAS_TRAIT(remover, TRAIT_HANDS_BLOCKED) || !Adjacent(remover))
		return
	if(!sample)
		to_chat(remover, span_warning("Внутри микроскопа нет образца!"))
		return
	to_chat(remover, span_notice("Вы вытащили \the [sample] из микроскопа."))
	sample.forceMove_turf()
	remover.put_in_hands(sample, ignore_anim = FALSE)
	sample = null
	update_icon(UPDATE_ICON_STATE)

/obj/machinery/microscope/proc/is_complete_print(print)
	return stringpercent(print) <= fingerprint_complete

/obj/machinery/microscope/click_alt(mob/user)
	remove_sample(user)
	return CLICK_ACTION_SUCCESS

/obj/machinery/microscope/mouse_drop_dragged(atom/over_object, mob/user, src_location, over_location, params)
	if(user != over_object)
		return
	remove_sample(user)

/obj/machinery/microscope/update_icon_state()
	icon_state = "microscope"
	if(sample)
		icon_state += "_slide"

/obj/machinery/microscope/screwdriver_act(mob/user, obj/item/I)
	if(sample)
		return
	. = TRUE
	default_deconstruction_screwdriver(user, "microscope_off", "microscope", I)

/obj/machinery/microscope/wrench_act(mob/user, obj/item/I)
	. = TRUE
	default_unfasten_wrench(user, I)

/obj/machinery/microscope/crowbar_act(mob/user, obj/item/I)
	if(sample)
		return
	. = TRUE
	default_deconstruction_crowbar(user, I)
