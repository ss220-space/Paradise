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
	qdel(cell)
	cell = new /obj/item/stock_parts/cell/super(src)

	toggler = create_component(/obj/item/circuit_component/compare/toggle, 40, 200)
	say_warn = create_component(/obj/item/circuit_component/speech, 240, 100, list("Сообщение" = "Перед повторным нажатием, загрузите ресурсы и разберите toolbox и welding_tool"))
	say_start = create_component(/obj/item/circuit_component/speech, 40, 340, list("Сообщение" = "Запуск списка!"))
	delay_start_loop = create_component(/obj/item/circuit_component/delay, 40, 460, list("Задержка" = 1))
	splitter = create_component(/obj/item/circuit_component/split, 40, 580)
	splitter.input_port?.set_input("basic_capacitor,micro_mani,basic_micro_laser,Beacon,high_cell,Reagent_scanner,health_hud,security_hud,telesci_gps,circuit_imprinter,adv_capacitor,adv_matter_bin,adv_reagent_scanner,holosign,large_grenade,cybernetic_heart,superpacman,teleconsole,gygax_targ,quantumpad,mrspacman,tele_hub,robo_quantumpad")
	splitter.separator?.set_input(",")

	say_done = create_component(/obj/item/circuit_component/speech, 440, 100, list("Сообщение" = "Список завершен!"))
	loop = create_component(/obj/item/circuit_component/foreach, 340, 340)
	delay_search_pre = create_component(/obj/item/circuit_component/delay, 340, 480, list("Задержка" = 1))

	say_tech = create_component(/obj/item/circuit_component/speech, 640, 100, list("Сообщение" = "Повышение технологий!"))
	delay_tech_1 = create_component(/obj/item/circuit_component/delay, 640, 220, list("Задержка" = 1))
	delay_tech_2 = create_component(/obj/item/circuit_component/delay, 840, 220, list("Задержка" = 1))
	say_mid_msg = create_component(/obj/item/circuit_component/speech, 640, 340, list("Сообщение" = "Сообщение"))
	delay_fail_post = create_component(/obj/item/circuit_component/delay, 640, 480, list("Задержка" = 1))
	say_fail = create_component(/obj/item/circuit_component/speech, 640, 600, list("Сообщение" = "Провал изучений!"))

	loop.list_to_iterate.connect(splitter.output)
	connect_ports(loop, loop.on_finished, say_done, "Вызов")
	connect_ports(loop, loop.on_next_index, say_mid_msg, "Вызов")
	connect_ports(loop, "Результат", say_mid_msg, say_mid_msg.message)
	connect_ports(loop, loop.on_next_index, delay_search_pre, "Вызов")
	connect_ports(say_tech, "Вызвано", delay_tech_2, "Вызов")
	connect_ports(delay_tech_2, "Вызвано", loop, loop.next_index)
	connect_ports(delay_fail_post, "Вызвано", loop, loop.next_index)

	connect_ports(toggler, toggler.true, say_warn, "Вызов")
	connect_ports(toggler, toggler.false, say_start, "Вызов")
	connect_ports(say_start, "Вызвано", delay_start_loop, delay_start_loop.trigger)
	connect_ports(delay_start_loop, delay_start_loop.output, splitter, "Вызов")
	connect_ports(splitter, "Вызвано", loop, loop.reset_index)

/obj/item/integrated_circuit/loaded/rnd_automation/proc/create_component(component_type, position_x, position_y, list/initial_inputs)
	var/obj/item/circuit_component/created_component = new component_type(src)
	add_component(created_component)
	created_component.rel_x = position_x
	created_component.rel_y = position_y
	for(var/port_name in initial_inputs)
		var/datum/port/input/target_port = created_component.find_input_port_by_name(port_name)
		target_port?.set_input(initial_inputs[port_name])
	return created_component

/obj/item/integrated_circuit/loaded/rnd_automation/proc/connect_ports(obj/item/circuit_component/source_component, source_port_or_name, obj/item/circuit_component/target_component, target_port_or_name)
	var/datum/port/output/output_port = istext(source_port_or_name) ? source_component?.find_output_port_by_name(source_port_or_name) : source_port_or_name
	var/datum/port/input/input_port = istext(target_port_or_name) ? target_component?.find_input_port_by_name(target_port_or_name) : target_port_or_name
	if(output_port && input_port)
		input_port.connect(output_port)

/obj/item/integrated_circuit/loaded/rnd_automation/ui_interact(mob/user, datum/tgui/ui)
	try_wire()
	return ..()

/obj/item/integrated_circuit/loaded/rnd_automation/proc/try_wire()
	if(wiring_done || !attached_components)
		return

	var/obj/item/circuit_component/bot/bot_component = locate() in attached_components
	var/obj/item/circuit_component/rd_search/search_component = locate() in attached_components
	var/obj/item/circuit_component/rd_lathe/lathe_component = locate() in attached_components
	var/obj/item/circuit_component/rd_destructor/destructor_component = locate() in attached_components

	if(bot_component)
		bot_component.rel_x = 40
		bot_component.rel_y = 60
		connect_ports(bot_component, "Вызвано", toggler, toggler.toggle_and_compare)

	if(search_component)
		search_component.rel_x = 340
		search_component.rel_y = 620
		search_component.input_id.connect(loop.element)
		search_component.input_search.connect(delay_search_pre.output)

	if(lathe_component)
		lathe_component.rel_x = 540
		lathe_component.rel_y = 620
		if(search_component)
			lathe_component.input_print.connect(search_component.output_found)
			lathe_component.input_design.connect(search_component.output_design)

	if(destructor_component)
		destructor_component.rel_x = 740
		destructor_component.rel_y = 620
		destructor_component.input_recycle.connect(destructor_component.output_item_inserted)
		delay_tech_1.trigger.connect(destructor_component.output_tech_up)
		connect_ports(delay_tech_1, delay_tech_1.output, say_tech, "Вызов")
		connect_ports(destructor_component, "Провал изучений", say_fail, "Вызов")
		connect_ports(say_fail, "Вызвано", delay_fail_post, "Вызов")
		if(lathe_component)
			destructor_component.input_recycle.connect(lathe_component.output_printed)
			destructor_component.input_item.connect(lathe_component.output_item)

	if(bot_component && search_component && lathe_component && destructor_component)
		wiring_done = TRUE

/obj/item/integrated_circuit/loaded/rnd_automation/add_component(obj/item/circuit_component/to_add, mob/living/user)
	. = ..()
	if(. && !wiring_done)
		try_wire()
