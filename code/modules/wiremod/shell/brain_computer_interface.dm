/obj/item/organ/internal/cyberimp/brain/bci
	name = "brain-computer interface"
	desc = "Имплант, предназначенный для управления интегральными схемами напрямую. \
			Устанавливается в головной мозге, подключаясь к нейронной системе пользователя."
	icon = 'icons/obj/circuits.dmi'
	icon_state = "bci"
	slot = INTERNAL_ORGAN_BRAIN_COMPUTER_INTERFACE
	w_class = WEIGHT_CLASS_TINY

/obj/item/organ/internal/cyberimp/brain/bci/get_ru_names()
	return list(
		NOMINATIVE = "интерфейс \"Мозг-Компьютер\"",
		GENITIVE = "интерфейса \"Мозг-Компьютер\"",
		DATIVE = "интерфейсу \"Мозг-Компьютер\"",
		ACCUSATIVE = "интерфейс \"Мозг-Компьютер\"",
		INSTRUMENTAL = "интерфейсом \"Мозг-Компьютер\"",
		PREPOSITIONAL = "интерфейсе \"Мозг-Компьютер\""
	)

/obj/item/organ/internal/cyberimp/brain/bci/Initialize(mapload)
	. = ..()

	ADD_TRAIT(src, TRAIT_NO_CLONE_IN_EXPERIMENTATOR, INNATE_TRAIT)
	RegisterSignal(src, COMSIG_CIRCUIT_ACTION_COMPONENT_REGISTERED, PROC_REF(action_comp_registered))
	RegisterSignal(src, COMSIG_CIRCUIT_ACTION_COMPONENT_UNREGISTERED, PROC_REF(action_comp_unregistered))

	var/obj/item/integrated_circuit/circuit = new(src)
	circuit.add_component(new /obj/item/circuit_component/equipment_action(null, "One"))

	AddComponent(/datum/component/shell, list(
		new /obj/item/circuit_component/bci_core,
	), SHELL_CAPACITY_SMALL, starting_circuit = circuit)

/obj/item/organ/internal/cyberimp/brain/bci/insert(mob/living/carbon/target, special = ORGAN_MANIPULATION_DEFAULT)
	. = ..()
	// Organs are put in nullspace, but this breaks circuit interactions
	forceMove(target)

/obj/item/organ/internal/cyberimp/brain/bci/atom_say(message)
	if(!owner)
		return ..()

	// Otherwise say_dead will be called.
	// It's intentional that a circuit for a dead person does not speak from the shell.
	if(owner.stat != DEAD)
		return owner.say(message)


/obj/item/organ/internal/cyberimp/brain/bci/proc/action_comp_registered(datum/source, obj/item/circuit_component/equipment_action/action_comp)
	SIGNAL_HANDLER
	LAZYADD(actions, new/datum/action/innate/bci_action(src, action_comp))

/obj/item/organ/internal/cyberimp/brain/bci/proc/action_comp_unregistered(datum/source, obj/item/circuit_component/equipment_action/action_comp)
	SIGNAL_HANDLER

	var/datum/action/innate/bci_action/action = action_comp.granted_to[UID()]
	if(!istype(action))
		return
	LAZYREMOVE(actions, action)
	QDEL_LIST_ASSOC_VAL(action_comp.granted_to)

/datum/action/innate/bci_action
	name = "Действие"
	button_icon = 'icons/mob/actions/actions_bci.dmi'
	check_flags = AB_CHECK_CONSCIOUS
	button_icon_state = "bci_power"

	var/obj/item/organ/internal/cyberimp/brain/bci/bci
	var/obj/item/circuit_component/equipment_action/circuit_component

/datum/action/innate/bci_action/New(obj/item/organ/internal/cyberimp/brain/bci/_bci, obj/item/circuit_component/equipment_action/circuit_component)
	..()
	bci = _bci
	circuit_component.granted_to[_bci.UID()] = src
	src.circuit_component = circuit_component

/datum/action/innate/bci_action/Destroy()
	circuit_component.granted_to -= bci.UID()
	circuit_component = null

	return ..()

/datum/action/innate/bci_action/Activate()
	circuit_component.user.set_output(owner)
	circuit_component.signal.set_output(COMPONENT_SIGNAL)

/obj/item/circuit_component/bci_core
	display_name = "Ядро ИМК"
	desc = "Контролирует основные операции ИМК."

	/// A reference to the action button to look at charge/get info
	var/datum/action/innate/bci_charge_action/charge_action

	var/datum/port/input/message
	var/datum/port/input/send_message_signal
	var/datum/port/input/show_charge_meter

	var/datum/port/output/user_port

	var/obj/item/organ/internal/cyberimp/brain/bci/bci

/obj/item/circuit_component/bci_core/populate_ports()

	message = add_input_port("Сообщение", PORT_TYPE_STRING, trigger = null)
	send_message_signal = add_input_port("Отправить", PORT_TYPE_SIGNAL)
	show_charge_meter = add_input_port("Показать заряд", PORT_TYPE_NUMBER, trigger = PROC_REF(update_charge_action))

	user_port = add_output_port("Пользователь", PORT_TYPE_USER)

/obj/item/circuit_component/bci_core/Destroy()
	QDEL_NULL(charge_action)
	return ..()

/obj/item/circuit_component/bci_core/proc/update_charge_action()
	CIRCUIT_TRIGGER
	if(show_charge_meter.value)
		if(charge_action)
			return
		charge_action = new(src)
		if(bci.owner)
			charge_action.Grant(bci.owner)
		LAZYADD(bci.actions, charge_action)
	else
		if(!charge_action)
			return
		if(bci.owner)
			charge_action.Remove(bci.owner)
		LAZYREMOVE(bci.actions, charge_action)
		QDEL_NULL(charge_action)

/obj/item/circuit_component/bci_core/register_shell(atom/movable/shell)
	bci = shell

	show_charge_meter.set_value(TRUE)

	RegisterSignal(shell, COMSIG_ORGAN_IMPLANTED, PROC_REF(on_organ_implanted))
	RegisterSignal(shell, COMSIG_ORGAN_REMOVED, PROC_REF(on_organ_removed))

/obj/item/circuit_component/bci_core/unregister_shell(atom/movable/shell)
	bci = shell

	if(charge_action)
		if(bci.owner)
			charge_action.Remove(bci.owner)
		LAZYREMOVE(bci.actions, charge_action)
		QDEL_NULL(charge_action)

	UnregisterSignal(shell, list(
		COMSIG_ORGAN_IMPLANTED,
		COMSIG_ORGAN_REMOVED,
	))

/obj/item/circuit_component/bci_core/input_received(datum/port/input/port)
	if(!COMPONENT_TRIGGERED_BY(send_message_signal, port))
		return

	var/sent_message = trim(message.value)
	if(!sent_message)
		return

	if(isnull(bci.owner))
		return

	if(bci.owner.stat == DEAD)
		return

	to_chat(bci.owner, "<i>Вы слышите странный, роботизированный голос в своей голове...</i> \"[span_robot("[html_encode(sent_message)]")]\"")

/obj/item/circuit_component/bci_core/proc/on_organ_implanted(datum/source, mob/living/carbon/owner)
	SIGNAL_HANDLER

	update_charge_action()

	user_port.set_output(owner)

	RegisterSignal(owner, COMSIG_PARENT_EXAMINE, PROC_REF(on_examine))
	RegisterSignal(owner, COMSIG_PROCESS_BORGCHARGER_OCCUPANT, PROC_REF(on_borg_charge))
	RegisterSignal(owner, COMSIG_LIVING_ELECTROCUTE_ACT, PROC_REF(on_electrocute))

/obj/item/circuit_component/bci_core/proc/on_organ_removed(datum/source, mob/living/carbon/owner)
	SIGNAL_HANDLER

	if(charge_action)
		if(owner)
			charge_action.Remove(owner)
		bci.actions -= charge_action
		QDEL_NULL(charge_action)

	user_port.set_output(null)

	UnregisterSignal(owner, list(
		COMSIG_PARENT_EXAMINE,
		COMSIG_PROCESS_BORGCHARGER_OCCUPANT,
		COMSIG_LIVING_ELECTROCUTE_ACT,
	))

/obj/item/circuit_component/bci_core/proc/on_borg_charge(datum/source, recharge_speed)
	SIGNAL_HANDLER

	if(isnull(parent.cell))
		return

	parent.cell.charge = min(parent.cell.charge + recharge_speed, parent.cell.maxcharge)

/obj/item/circuit_component/bci_core/proc/on_electrocute(datum/source, shock_damage, shock_source, siemens_coefficient, flags)
	SIGNAL_HANDLER

	if(isnull(parent.cell))
		return

	if(flags & SHOCK_ILLUSION)
		return

	parent.cell.give(shock_damage * 2)
	to_chat(source, span_notice("Часть электрошока поглощается вашим [parent.declent_ru(INSTRUMENTAL)]!"))

/obj/item/circuit_component/bci_core/proc/on_examine(datum/source, mob/mob, list/examine_text)
	SIGNAL_HANDLER

	if(isobserver(mob))
		examine_text += span_notice("Показать имплантированную <a href='byond://?src=[UID()];open_bci=1'>интегральную схему.</a>")

/obj/item/circuit_component/bci_core/Topic(href, list/href_list)
	..()

	if(!isobserver(usr))
		return

	if(href_list["open_bci"])
		parent.ui_interact(usr)

/datum/action/innate/bci_charge_action
	name = "Проверить заряд ИМК"
	button_icon = 'icons/obj/engines_and_power/power.dmi'
	button_icon_state = "cell"

	var/obj/item/circuit_component/bci_core/circuit_component

/datum/action/innate/bci_charge_action/New(obj/item/circuit_component/bci_core/circuit_component)
	..()

	src.circuit_component = circuit_component

	build_all_button_icons()

	START_PROCESSING(SSobj, src)

/datum/action/innate/bci_charge_action/create_button()
	var/atom/movable/screen/movable/action_button/button = ..()
	button.maptext_x = 2
	button.maptext_y = 0
	return button

/datum/action/innate/bci_charge_action/Destroy()
	circuit_component.charge_action = null
	circuit_component = null

	STOP_PROCESSING(SSobj, src)

	return ..()

/datum/action/innate/bci_charge_action/Trigger(left_click = TRUE, trigger_flags)
	var/obj/item/stock_parts/cell/cell = circuit_component.parent.cell

	if(isnull(cell))
		to_chat(owner, span_boldwarning("[circuit_component.parent.declent_ru(NOMINATIVE)] \
		не име[PLUR_ET_UT(circuit_component.parent)] элемента питания."))
	else
		to_chat(owner, span_notice("В [cell.declent_ru(PREPOSITIONAL)] \
		[circuit_component.parent.declent_ru(GENITIVE)] \
		осталось <b>[round(cell.percent(), 1)]%</b> заряда."))

/datum/action/innate/bci_charge_action/process(seconds_per_tick)
	build_all_button_icons(UPDATE_BUTTON_STATUS)

/datum/action/innate/bci_charge_action/update_button_status(atom/movable/screen/movable/action_button/button, force = FALSE)
	. = ..()
	var/obj/item/stock_parts/cell/cell = circuit_component.parent.cell
	button.maptext = cell ? MAPTEXT("[round(cell.percent(), 1)]%") : ""

/obj/machinery/bci_implanter
	name = "brain-computer interface manipulation chamber"
	desc = "Машина, которая при наличии интерфейса \"Мозг-Компьютер\" имплантирует его в тело гуманоида. \
			В противном случае она удалит все имеющиеся ИМК."
	icon = 'icons/obj/machines/bci_implanter.dmi'
	icon_state = "bci_implanter"
	base_icon_state = "bci_implanter"
	layer = ABOVE_WINDOW_LAYER
	anchored = TRUE
	density = TRUE

	var/busy = FALSE
	var/busy_icon_state
	var/locked = FALSE

	var/mob/living/carbon/occupant = null
	var/obj/item/organ/internal/cyberimp/brain/bci/bci_to_implant

	COOLDOWN_DECLARE(message_cooldown)

/obj/machinery/bci_implanter/get_ru_names()
	return list(
		NOMINATIVE = "камера манипуляций интерфейсом \"Мозг-компьютер\"",
		GENITIVE = "камеры манипуляций интерфейсом \"Мозг-компьютер\"",
		DATIVE = "камере манипуляций интерфейсом \"Мозг-компьютер\"",
		ACCUSATIVE = "камеру манипуляций интерфейсом \"Мозг-компьютер\"",
		INSTRUMENTAL = "камерой манипуляций интерфейсом \"Мозг-компьютер\"",
		PREPOSITIONAL = "камере манипуляций интерфейсом \"Мозг-компьютер\""
	)

/obj/machinery/bci_implanter/examine(mob/user)
	. = ..()
	if(isnull(bci_to_implant))
		. += span_notice("ИМК не вставлен.")
	else
		. += span_notice("Используйте <b>ALT+ЛКМ</b>, чтобы удалить текущий ИМК.")

/obj/machinery/bci_implanter/Initialize(mapload)
	. = ..()
	component_parts = list()
	component_parts += new /obj/item/circuitboard/bci_implanter(null)
	component_parts += new /obj/item/stock_parts/micro_laser(null)
	component_parts += new /obj/item/stock_parts/micro_laser(null)
	component_parts += new /obj/item/stock_parts/manipulator(null)
	component_parts += new /obj/item/stack/cable_coil(null)
	component_parts += new /obj/item/stack/sheet/glass(null)
	update_icon()

/obj/machinery/bci_implanter/on_deconstruction(disassembled)
	drop_stored_bci()

/obj/machinery/bci_implanter/Destroy(force)
	go_out(force = TRUE)
	qdel(bci_to_implant)
	return ..()

/obj/machinery/bci_implanter/crowbar_act(mob/user, obj/item/tool)
	if(default_deconstruction_crowbar(user, tool))
		for(var/obj/thing in contents) // in case there is something in the scanner
			thing.forceMove(loc)
		return TRUE

/obj/machinery/bci_implanter/screwdriver_act(mob/user, obj/item/tool)
	if(occupant)
		balloon_alert(user, "панель заблокирована!")
		return TRUE
	if(default_deconstruction_screwdriver(user, "[initial(icon_state)]", "[initial(icon_state)]", tool))
		update_icon()
		return TRUE

/obj/machinery/bci_implanter/update_icon_state()
	if(occupant)
		icon_state = busy ? busy_icon_state : "[base_icon_state]_occupied"
		return ..()
	icon_state = base_icon_state
	return ..()

/obj/machinery/bci_implanter/update_overlays()
	. = ..()

	if((stat & MAINT) || panel_open)
		. += "maint"
		return

	if(stat & (NOPOWER|BROKEN))
		return

	if(busy || locked)
		. += "red"
		if(locked)
			. += "bolted"
		return

	. += "green"


/obj/machinery/bci_implanter/attackby(obj/item/weapon, mob/user, params)
	if(user.a_intent == INTENT_HARM)
		return ..()

	var/obj/item/organ/internal/cyberimp/brain/bci/new_bci = weapon
	if(istype(new_bci))
		if(!(locate(/obj/item/integrated_circuit) in new_bci))
			balloon_alert(user, UNLINT("ИМК не имеет схемы!"))
			return ATTACK_CHAIN_PROCEED

		var/obj/item/organ/internal/cyberimp/brain/bci/previous_bci_to_implant = bci_to_implant

		user.transfer_item_to_loc(weapon, src)
		bci_to_implant = weapon

		if(isnull(previous_bci_to_implant))
			balloon_alert(user, UNLINT("ИМК установлен"))
		else
			balloon_alert(user, UNLINT("ИМК заменён"))
			user.put_in_hands(previous_bci_to_implant)

		return ATTACK_CHAIN_PROCEED

	return ATTACK_CHAIN_PROCEED_SUCCESS

/obj/machinery/bci_implanter/attack_hand(mob/user)
	if(user.incapacitated() || HAS_TRAIT(user, TRAIT_HANDS_BLOCKED) || ..())
		return FALSE

	if(istype(occupant))
		var/obj/item/organ/internal/cyberimp/brain/bci/bci_organ = occupant.get_int_organ(/obj/item/organ/internal/cyberimp/brain/bci)
		if(isnull(bci_organ) && isnull(bci_to_implant))
			atom_say("Интерфейс \"Мозг-Компьютер\" не установлен в слот! Для имплантации ИМК в цель необходимо установить установить его в соответствующий слот.")
			playsound(src, 'sound/machines/buzz-sigh.ogg', 30, TRUE)
			return FALSE
		if(HAS_TRAIT(occupant, TRAIT_NO_CYBERIMPLANTS))
			atom_say("Невозможно имплантировать интерфейс \"Мозг-Компьютер\" в организм цели!")
			playsound(src, 'sound/machines/buzz-sigh.ogg', 30, TRUE)
			return FALSE

	addtimer(CALLBACK(src, PROC_REF(start_process)), 1 SECONDS)
	return TRUE

/obj/machinery/bci_implanter/click_alt(mob/user)
	if(!user.Adjacent(src))
		return CLICK_ACTION_BLOCKING

	if(locked)
		balloon_alert(user, "заблокировано!")
		return CLICK_ACTION_BLOCKING

	if(isnull(bci_to_implant))
		balloon_alert(user, UNLINT("ИМК не вставлен!"))
	else
		user.put_in_hands(bci_to_implant)
		bci_to_implant = null
		balloon_alert(user, UNLINT("ИМК извлечён"))

	return CLICK_ACTION_SUCCESS

/obj/machinery/bci_implanter/MouseDrop_T(mob/living/target, mob/living/user, params)
	if(!ishuman(target))
		return

	if(target.loc == user) //no you can't pull things out of your ass
		return

	if(user.incapacitated() || HAS_TRAIT(user, TRAIT_HANDS_BLOCKED)) //are you cuffed, dying, lying, stunned or other
		return

	if(target.anchored || get_dist(user, src) > 1 || get_dist(user, target) > 1 || user.contents.Find(src)) // is the mob anchored, too far away from you, or are you too far away from the source
		return

	if(!ishuman(user) && !isrobot(user)) //No ghosts or mice putting people into the implanter
		return

	if(user.loc == null) // just in case someone manages to get a closet into the blue light dimension, as unlikely as that seems
		return

	if(!isturf(user.loc) || !isturf(target.loc)) // are you in a container/closet/pod/etc?
		return

	if(occupant)
		balloon_alert(user, "внутри кто-то есть!")
		return TRUE

	if(target.buckled)
		return

	if(target.abiotic())
		balloon_alert(user, "руки субъекта заняты!")
		return TRUE

	if(target.has_buckled_mobs()) //mob attached to us
		to_chat(user, span_warning("[target] не помест[PLUR_IT_YAT(target)]ся в [declent_ru(ACCUSATIVE)], пока на [GEND_ON_IN_HIM(target)] сидит слайм!"))
		return TRUE

	put_in(target, user)
	return TRUE

/obj/machinery/bci_implanter/grab_attack(mob/living/grabber, atom/movable/grabbed_thing)
	. = TRUE
	if(grabber.grab_state < GRAB_AGGRESSIVE || !ismob(grabbed_thing))
		return .

	if(panel_open)
		balloon_alert(grabber, "техпанель открыта!")
		return .

	var/mob/target = grabbed_thing

	if(occupant)
		balloon_alert(grabber, "внутри кто-то есть!")
		return .

	if(target.abiotic())
		balloon_alert(grabber, "руки субъекта заняты!")
		return .

	if(target.has_buckled_mobs()) //mob attached to us
		to_chat(grabber, span_warning("[target] не помест[PLUR_IT_YAT(target)]ся в [declent_ru(ACCUSATIVE)], пока на [GEND_ON_IN_HIM(target)] сидит слайм!"))
		return .

	put_in(target, grabber)
	add_fingerprint(grabber)

/obj/machinery/bci_implanter/proc/put_in(mob/target, mob/living/user)
	add_fingerprint(user)

	if(target == user)
		visible_message("[user] начина[PLUR_ET_UT(user)] залезать в [declent_ru(ACCUSATIVE)].")
	else
		visible_message("[user] начина[PLUR_ET_UT(user)] укладывать [target.declent_ru(ACCUSATIVE)] в [declent_ru(ACCUSATIVE)].")

	if(!do_after(user, 2 SECONDS, target))
		return

	if(occupant)
		balloon_alert(user, "внутри кто-то есть!")
		return

	if(!istype(target) || target.buckled)
		return

	if(target.abiotic())
		balloon_alert(user, "руки субъекта заняты!")
		return

	if(target.has_buckled_mobs()) //mob attached to us
		to_chat(user, span_warning("[target] не помест[PLUR_IT_YAT(target)]ся в [declent_ru(ACCUSATIVE)], пока на [GEND_ON_IN_HIM(target)] сидит слайм!"))
		return

	if(target.forceMove(src))
		occupant = target
		icon_state = "bci_implanter_occupied"

/obj/machinery/bci_implanter/verb/eject()
	set src in oview(1)
	set name = "Извлечь цель изнутри"

	if(usr.incapacitated() || HAS_TRAIT(usr, TRAIT_HANDS_BLOCKED))
		return
	go_out(usr)
	add_fingerprint(usr)


/obj/machinery/bci_implanter/force_eject_occupant(mob/target)
	go_out()


/obj/machinery/bci_implanter/relaymove(mob/user)
	var/message

	if(locked)
		message = "не влезает!"
	else if(user.stat != CONSCIOUS)
		message = "нет энергии!"

	if(!isnull(message))
		if(COOLDOWN_FINISHED(src, message_cooldown))
			COOLDOWN_START(src, message_cooldown, 5 SECONDS)
			balloon_alert(user, message)
		return

	go_out()

/obj/machinery/bci_implanter/proc/go_out(mob/user, force)
	if(!occupant)
		if(user)
			balloon_alert(user, "внутри никого!")
		return
	if(locked && !force)
		if(user)
			balloon_alert(user, "заблокировано!")
		return
	occupant.forceMove(loc)
	occupant = null
	icon_state = base_icon_state

/obj/machinery/bci_implanter/proc/start_process()
	if(stat & (NOPOWER|BROKEN))
		return
	if((stat & MAINT) || panel_open)
		return
	if(!occupant || busy)
		return

	update_use_power(ACTIVE_POWER_USE)

	var/locked_state = locked
	locked = TRUE

	set_busy(TRUE, "[initial(icon_state)]_raising")
	addtimer(CALLBACK(src, PROC_REF(set_busy), TRUE, "[initial(icon_state)]_active"), 1 SECONDS)
	addtimer(CALLBACK(src, PROC_REF(set_busy), TRUE, "[initial(icon_state)]_falling"), 2 SECONDS)
	addtimer(CALLBACK(src, PROC_REF(complete_process), locked_state), 3 SECONDS)

/obj/machinery/bci_implanter/proc/complete_process(locked_state)
	update_use_power(IDLE_POWER_USE)
	locked = locked_state
	set_busy(FALSE)

	var/mob/living/carbon/carbon_occupant = occupant
	if(!istype(carbon_occupant))
		return

	playsound(loc, 'sound/machines/ping.ogg', 30, FALSE)

	var/obj/item/organ/internal/cyberimp/brain/bci/bci_organ = carbon_occupant.get_int_organ(/obj/item/organ/internal/cyberimp/brain/bci)

	if(bci_organ)
		bci_organ.remove(carbon_occupant)

		if(isnull(bci_to_implant))
			atom_say("Предыдущий интерфейс \"Мозг-Компьютер\" цели был перемещён во внутреннее хранилище.")
			carbon_occupant.transfer_item_to_loc(bci_organ, src)
			bci_to_implant = bci_organ
		else
			atom_say("Предыдущий интерфейс \"Мозг-Компьютер\" цели был изъят.")
			bci_organ.forceMove(drop_location())
	else if(!isnull(bci_to_implant))
		atom_say("[DECLENT_RU_CAP(bci_to_implant, NOMINATIVE)] был имплантирован в организм цели.")
		bci_to_implant.insert(carbon_occupant)
		bci_to_implant = null

/obj/machinery/bci_implanter/proc/set_busy(status, working_icon)
	busy = status
	busy_icon_state = working_icon
	update_appearance()

/obj/machinery/bci_implanter/proc/drop_stored_bci()
	if(isnull(bci_to_implant))
		return
	bci_to_implant.forceMove(drop_location())

/obj/item/circuitboard/bci_implanter
	board_name = "Brain-Computer Interface Manipulation Chamber"
	build_path = /obj/machinery/bci_implanter
	greyscale_colors = CIRCUIT_COLOR_SCIENCE
	board_type = "machine"
	origin_tech = "programming=2;biotech=2"
	req_components = list(
		/obj/item/stock_parts/micro_laser = 2,
		/obj/item/stock_parts/manipulator = 1,
		/obj/item/stack/sheet/glass = 1,
		/obj/item/stack/cable_coil = 2,
	)
