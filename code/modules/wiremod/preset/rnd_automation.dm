/obj/item/circuit_component/rd_search
/obj/item/circuit_component/rd_lathe
/obj/item/circuit_component/rd_destructor

/obj/item/integrated_circuit/loaded/rnd_automation
	display_name = "Интегральная схема: Авто-НИО"
	desc = "Плата автоматического перебора чертежей, печати и утилизации для базовой прокачки технологий."

	var/obj/item/circuit_component/speech/say_start
	var/obj/item/circuit_component/speech/say_tech
	var/obj/item/circuit_component/speech/say_fail
	var/obj/item/circuit_component/speech/say_done
	var/obj/item/circuit_component/speech/say_warn
	var/obj/item/circuit_component/speech/say_mid_msg
	var/obj/item/circuit_component/foreach/loop
	var/obj/item/circuit_component/split/splitter
	var/obj/item/circuit_component/compare/toggle/toggler
	var/obj/item/circuit_component/delay/delay_start_loop
	var/obj/item/circuit_component/delay/delay_search_pre
	var/obj/item/circuit_component/delay/delay_tech_1
	var/obj/item/circuit_component/delay/delay_tech_2
	var/obj/item/circuit_component/delay/delay_fail_post
	var/wiring_done = FALSE

/obj/item/integrated_circuit/loaded/rnd_automation/Initialize(mapload)
	. = ..()

	if(src.cell)
		qdel(src.cell)
	src.cell = new /obj/item/stock_parts/cell/super(src)

	toggler = new()
	add_component(toggler)
	toggler.rel_x = 40
	toggler.rel_y = 200

	say_warn = new()
	add_component(say_warn)
	say_warn.rel_x = 240
	say_warn.rel_y = 100
	if(say_warn.message)
		say_warn.message.set_input("Перед повторным нажатием, загрузите ресурсы и разберите toolbox и welding_tool")

	say_start = new()
	add_component(say_start)
	say_start.rel_x = 40
	say_start.rel_y = 340
	if(say_start.message)
		say_start.message.set_input("Запуск списка!")

	delay_start_loop = new()
	add_component(delay_start_loop)
	delay_start_loop.rel_x = 40
	delay_start_loop.rel_y = 460
	if(delay_start_loop.delay_amount)
		delay_start_loop.delay_amount.set_input(2)

	splitter = new()
	add_component(splitter)
	splitter.rel_x = 40
	splitter.rel_y = 580
	if(splitter.input_port)
		var/datum/port/input/string_input = splitter.input_port
		string_input.set_input("basic_capacitor,micro_mani,basic_micro_laser,Beacon,high_cell,Reagent_scanner,health_hud,security_hud,telesci_gps,circuit_imprinter,adv_capacitor,adv_matter_bin,adv_reagent_scanner,holosign,large_grenade,cybernetic_heart,cybernetic_heart,superpacman,teleconsole,gygax_targ,quantumpad,mrspacman,tele_hub,robo_quantumpad")
	if(splitter.separator)
		splitter.separator.set_input(",")

	say_done = new()
	add_component(say_done)
	say_done.rel_x = 440
	say_done.rel_y = 100
	if(say_done.message)
		say_done.message.set_input("Список завершен!")

	loop = new()
	add_component(loop)
	loop.rel_x = 340
	loop.rel_y = 340

	delay_search_pre = new()
	add_component(delay_search_pre)
	delay_search_pre.rel_x = 340
	delay_search_pre.rel_y = 480
	if(delay_search_pre.delay_amount)
		delay_search_pre.delay_amount.set_input(1)

	say_tech = new()
	add_component(say_tech)
	say_tech.rel_x = 640
	say_tech.rel_y = 100
	if(say_tech.message)
		say_tech.message.set_input("Повышение технологий!")

	delay_tech_1 = new()
	add_component(delay_tech_1)
	delay_tech_1.rel_x = 640
	delay_tech_1.rel_y = 220
	if(delay_tech_1.delay_amount)
		delay_tech_1.delay_amount.set_input(1)

	delay_tech_2 = new()
	add_component(delay_tech_2)
	delay_tech_2.rel_x = 840
	delay_tech_2.rel_y = 220
	if(delay_tech_2.delay_amount)
		delay_tech_2.delay_amount.set_input(2)

	say_mid_msg = new()
	add_component(say_mid_msg)
	say_mid_msg.rel_x = 640
	say_mid_msg.rel_y = 340
	if(say_mid_msg.message)
		say_mid_msg.message.set_input("Сообщение")

	delay_fail_post = new()
	add_component(delay_fail_post)
	delay_fail_post.rel_x = 640
	delay_fail_post.rel_y = 480
	if(delay_fail_post.delay_amount)
		delay_fail_post.delay_amount.set_input(2)

	say_fail = new()
	add_component(say_fail)
	say_fail.rel_x = 640
	say_fail.rel_y = 600
	if(say_fail.message)
		say_fail.message.set_input("Провал изучений!")

	if(loop.list_to_iterate && splitter.output)
		loop.list_to_iterate.connect(splitter.output)

	if(say_done && loop)
		var/datum/port/input/in_speech_done = say_done.find_input_port_by_name("Вызов")
		if(in_speech_done && loop.on_finished)
			in_speech_done.connect(loop.on_finished)

	if(say_mid_msg)
		var/datum/port/input/in_mid = say_mid_msg.find_input_port_by_name("Вызов")
		if(in_mid && loop.on_next_index)
			in_mid.connect(loop.on_next_index)

		var/datum/port/input/in_mid_msg = say_mid_msg.message
		var/datum/port/output/out_loop_el = loop.find_output_port_by_name("Результат")
		if(in_mid_msg && out_loop_el)
			in_mid_msg.connect(out_loop_el)

	if(delay_search_pre)
		var/datum/port/input/in_del_search = delay_search_pre.find_input_port_by_name("Вызов")
		if(in_del_search && loop.on_next_index)
			in_del_search.connect(loop.on_next_index)

	if(say_tech && delay_tech_2)
		var/datum/port/input/in_del_tech2 = delay_tech_2.find_input_port_by_name("Вызов")
		var/datum/port/output/out_tech_sp = say_tech.find_output_port_by_name("Вызвано")
		if(in_del_tech2 && out_tech_sp)
			in_del_tech2.connect(out_tech_sp)

	if(delay_tech_2 && loop)
		var/datum/port/output/out_del_tech2 = delay_tech_2.find_output_port_by_name("Вызвано")
		if(loop.next_index && out_del_tech2)
			loop.next_index.connect(out_del_tech2)

	if(delay_fail_post && loop)
		var/datum/port/output/out_del_fail = delay_fail_post.find_output_port_by_name("Вызвано")
		if(loop.next_index && out_del_fail)
			loop.next_index.connect(out_del_fail)

/obj/item/integrated_circuit/loaded/rnd_automation/ui_interact(mob/user, datum/tgui/ui)
	if(wiring_done)
		return ..()

	var/obj/item/circuit_component/bot/bot_comp
	var/obj/item/circuit_component/rd_search/search_comp
	var/obj/item/circuit_component/rd_lathe/lathe_comp
	var/obj/item/circuit_component/rd_destructor/destructor_comp

	if(src.attached_components)
		for(var/datum/datum_element in src.attached_components)
			if(istype(datum_element, /obj/item/circuit_component/bot))
				bot_comp = datum_element
			else if(istype(datum_element, /obj/item/circuit_component/rd_search))
				search_comp = datum_element
			else if(istype(datum_element, /obj/item/circuit_component/rd_lathe))
				lathe_comp = datum_element
			else if(istype(datum_element, /obj/item/circuit_component/rd_destructor))
				destructor_comp = datum_element

	if(bot_comp && toggler)
		bot_comp.rel_x = 40
		bot_comp.rel_y = 60
		var/datum/port/output/out_bot = bot_comp.find_output_port_by_name("Вызвано")
		if(out_bot && toggler.toggle_and_compare)
			toggler.toggle_and_compare.connect(out_bot)

	if(toggler && say_warn)
		var/datum/port/input/in_warn = say_warn.find_input_port_by_name("Вызов")
		if(in_warn && toggler.true)
			in_warn.connect(toggler.true)

	if(toggler && say_start)
		var/datum/port/input/in_start = say_start.find_input_port_by_name("Вызов")
		if(in_start && toggler.false)
			in_start.connect(toggler.false)

	if(say_start && delay_start_loop)
		var/datum/port/output/out_start = say_start.find_output_port_by_name("Вызвано")
		if(out_start && delay_start_loop.trigger)
			delay_start_loop.trigger.connect(out_start)

	if(delay_start_loop && splitter)
		var/datum/port/input/in_split = splitter.find_input_port_by_name("Вызов")
		if(in_split && delay_start_loop.output)
			in_split.connect(delay_start_loop.output)

	if(splitter && loop)
		var/datum/port/input/in_loop_reset = loop.reset_index
		var/datum/port/output/out_split = splitter.find_output_port_by_name("Вызвано")
		if(in_loop_reset && out_split)
			in_loop_reset.connect(out_split)

	if(search_comp)
		search_comp.rel_x = 340
		search_comp.rel_y = 620
		if(loop)
			var/obj/item/circuit_component/foreach/L = loop
			if(search_comp.input_id && L.element)
				search_comp.input_id.connect(L.element)
		if(delay_search_pre)
			if(search_comp.input_search && delay_search_pre.output)
				search_comp.input_search.connect(delay_search_pre.output)

	if(lathe_comp)
		lathe_comp.rel_x = 540
		lathe_comp.rel_y = 620
		if(search_comp)
			if(lathe_comp.input_print && search_comp.output_found)
				lathe_comp.input_print.connect(search_comp.output_found)
			if(lathe_comp.input_design && search_comp.output_design)
				lathe_comp.input_design.connect(search_comp.output_design)

	if(destructor_comp)
		destructor_comp.rel_x = 740
		destructor_comp.rel_y = 620

		if(delay_tech_1 && destructor_comp.output_tech_up)
			if(delay_tech_1.trigger)
				delay_tech_1.trigger.connect(destructor_comp.output_tech_up)

		if(say_tech && delay_tech_1)
			var/datum/port/input/in_tech = say_tech.find_input_port_by_name("Вызов")
			if(in_tech && delay_tech_1.output)
				in_tech.connect(delay_tech_1.output)

		if(say_fail && destructor_comp.output_error)
			var/datum/port/input/in_fail = say_fail.find_input_port_by_name("Вызов")
			if(in_fail)
				in_fail.connect(destructor_comp.output_error)

		if(delay_fail_post && say_fail)
			var/datum/port/input/in_del_fail = delay_fail_post.find_input_port_by_name("Вызов")
			var/datum/port/output/out_fail_sp = say_fail.find_output_port_by_name("Вызвано")
			if(in_del_fail && out_fail_sp)
				in_del_fail.connect(out_fail_sp)

		if(lathe_comp)
			if(destructor_comp.input_recycle && lathe_comp.output_printed)
				destructor_comp.input_recycle.connect(lathe_comp.output_printed)
			if(destructor_comp.input_item && lathe_comp.output_item)
				destructor_comp.input_item.connect(lathe_comp.output_item)

	if(bot_comp && search_comp && lathe_comp && destructor_comp)
		wiring_done = TRUE

	return ..()
