#define TURRET_COVER_IDLE_TIME (5 SECONDS)

/obj/item/turret_integration_module
	name = "turret integration module"
	desc = "Модуль, занимающий в корпусе турели место сенсора движения. Передаёт управление огнём интегральной схеме."
	icon = 'icons/obj/circuits.dmi'
	icon_state = "setup_device"
	item_state = "electronic"
	w_class = WEIGHT_CLASS_SMALL
	origin_tech = "programming=7;combat=7;engineering=6"

/obj/item/turret_integration_module/get_ru_names()
	return alist(
		NOMINATIVE = "интегральный модуль",
		GENITIVE = "интегрального модуля",
		DATIVE = "интегральному модулю",
		ACCUSATIVE = "интегральный модуль",
		INSTRUMENTAL = "интегральным модулем",
		PREPOSITIONAL = "интегральном модуле"
	)

/obj/machinery/porta_turret/integrated
	name = "integrated turret"
	desc = "Турель без собственной системы опознавания целей. Стреляет только по указанию интегральной схемы."
	targetting_is_configurable = FALSE
	check_access = FALSE
	check_arrest = FALSE
	check_records = FALSE
	check_anomalies = FALSE
	icon_state = "integrated_turretCover"
	salvage_sensor = /obj/item/turret_integration_module
	sprite_prefix = "integrated_"

/obj/machinery/porta_turret/integrated/get_ru_names()
	return alist(
		NOMINATIVE = "интегральная турель",
		GENITIVE = "интегральной турели",
		DATIVE = "интегральной турели",
		ACCUSATIVE = "интегральную турель",
		INSTRUMENTAL = "интегральной турелью",
		PREPOSITIONAL = "интегральной турели"
	)

/obj/machinery/porta_turret/integrated/Initialize(mapload)
	. = ..()
	AddComponent( \
		/datum/component/shell/turret, \
		unremovable_circuit_components = list(new /obj/item/circuit_component/turret), \
		capacity = SHELL_CAPACITY_LARGE, \
		shell_flags = SHELL_FLAG_REQUIRE_ANCHOR|SHELL_FLAG_USB_PORT, \
	)

/obj/machinery/porta_turret/integrated/update_icon_state()
	. = ..()
	if(lethal && !raised && !raising && !(stat & BROKEN))
		icon_state = "[sprite_prefix]turretCover_lethal"

/obj/machinery/porta_turret/integrated/ui_act(action, params)
	. = ..()
	if(!.)
		return
	iconholder = lethal
	update_icon(UPDATE_ICON_STATE)

/obj/machinery/porta_turret/integrated/HasProximity(atom/movable/entity)
	if(!enabled || (stat & (NOPOWER|BROKEN)))
		return
	if(entity.invisibility > SEE_INVISIBLE_LIVING || HAS_TRAIT(entity, TRAIT_NINJA_INVISIBILITY))
		return
	SEND_SIGNAL(src, COMSIG_TURRET_DETECTED_TARGET, entity)

/obj/machinery/porta_turret/integrated/process()
	if(enabled && !(stat & (NOPOWER|BROKEN)) && world.time < last_fired + TURRET_COVER_IDLE_TIME)
		return
	if(!always_up)
		popDown()

/obj/machinery/porta_turret/integrated/target(mob/living/target)
	if(!enabled || (stat & (NOPOWER|BROKEN)))
		return FALSE
	return ..()

/obj/machinery/porta_turret/integrated/shootAt(mob/living/target)
	. = ..()
	if(!.)
		return
	SEND_SIGNAL(src, COMSIG_TURRET_SHOT_AT, target)

/datum/component/shell/turret/on_examine(atom/movable/source, mob/user, list/examine_text)
	. = ..()
	if(attached_circuit && is_authorized(user))
		examine_text += span_notice("- <b>мультитул</b> извлекает схему, пока турель выключена.")

/datum/component/shell/turret/on_attack_by(atom/source, obj/item/item, mob/living/attacker)
	if(is_integrated_circuit(item) && !can_service(attacker))
		return COMPONENT_CANCEL_ATTACK_CHAIN
	return ..()

/datum/component/shell/turret/on_screwdriver_act(atom/source, mob/user, obj/item/tool)
	if(attached_circuit && !can_service(user))
		return TRUE
	return ..()

/datum/component/shell/turret/on_multitool_act(atom/source, mob/user, obj/item/tool)
	if(is_circuit_multitool(tool))
		return ..()
	if(!attached_circuit || !is_authorized(user))
		return
	if(!can_service(user))
		return TRUE
	if(locked)
		source.balloon_alert(user, "закрыто!")
		return TRUE
	tool.play_tool_sound(parent)
	source.balloon_alert(user, "схема извлечена")
	remove_circuit()
	return TRUE

/datum/component/shell/turret/proc/can_service(mob/user)
	var/obj/machinery/porta_turret/turret = parent
	if(!turret.enabled)
		return TRUE
	turret.balloon_alert(user, "турель включена!")
	return FALSE

/obj/item/circuit_component/turret
	display_name = "Турель"
	desc = "Ведёт огонь по цели, поданной на вход \"Цель\", когда на \"Вызов\" приходит сигнал. \
			Об объектах, вошедших в зону обнаружения турели, сообщают выходы \"Обнаруженный объект\" и \"Обнаружение\". \
			Состоявшийся выстрел подтверждается выходами \"Обстрелянная цель\" и \"Выстрел\"."
	circuit_flags = CIRCUIT_FLAG_INPUT_SIGNAL|CIRCUIT_FLAG_OUTPUT_SIGNAL
	required_shells = list(/obj/machinery/porta_turret/integrated)

	var/datum/port/input/target
	var/datum/port/output/detected
	var/datum/port/output/detected_signal
	var/datum/port/output/shot
	var/datum/port/output/shot_signal
	var/obj/machinery/porta_turret/integrated/attached_turret

/obj/item/circuit_component/turret/Destroy()
	target = null
	detected = null
	detected_signal = null
	shot = null
	shot_signal = null
	attached_turret = null
	return ..()

/obj/item/circuit_component/turret/populate_ports()
	target = add_input_port("Цель", PORT_TYPE_ATOM)
	detected = add_output_port("Обнаруженный объект", PORT_TYPE_ATOM)
	detected_signal = add_output_port("Обнаружение", PORT_TYPE_SIGNAL)
	shot = add_output_port("Обстрелянная цель", PORT_TYPE_ATOM)
	shot_signal = add_output_port("Выстрел", PORT_TYPE_SIGNAL)

/obj/item/circuit_component/turret/get_ui_notices()
	. = ..()
	var/shot_delay = attached_turret ? attached_turret.shot_delay : /obj/machinery/porta_turret/integrated::shot_delay
	var/scan_range = attached_turret ? attached_turret.scan_range : /obj/machinery/porta_turret/integrated::scan_range
	. += create_ui_notice("Задержка между выстрелами: [DisplayTimeText(shot_delay)]", "orange", "stopwatch")
	. += create_ui_notice("Дальность стрельбы: [scan_range] тайлов", "orange", "crosshairs")

/obj/item/circuit_component/turret/register_shell(atom/movable/shell)
	if(!istype(shell, /obj/machinery/porta_turret/integrated))
		return
	attached_turret = shell
	RegisterSignal(shell, COMSIG_TURRET_DETECTED_TARGET, PROC_REF(on_detected))
	RegisterSignal(shell, COMSIG_TURRET_SHOT_AT, PROC_REF(on_shot))

/obj/item/circuit_component/turret/unregister_shell(atom/movable/shell)
	UnregisterSignal(shell, list(COMSIG_TURRET_DETECTED_TARGET, COMSIG_TURRET_SHOT_AT))
	attached_turret = null

/obj/item/circuit_component/turret/proc/on_detected(atom/source, atom/movable/entity)
	SIGNAL_HANDLER
	detected.set_output(entity)
	detected_signal.set_output(COMPONENT_SIGNAL)

/obj/item/circuit_component/turret/proc/on_shot(atom/source, atom/victim)
	SIGNAL_HANDLER
	shot.set_output(victim)
	shot_signal.set_output(COMPONENT_SIGNAL)

/obj/item/circuit_component/turret/input_received(datum/port/input/port)
	if(!attached_turret)
		return
	var/atom/victim = target.value
	if(!victim || victim == attached_turret)
		return
	if(!attached_turret.can_see(victim, attached_turret.scan_range))
		return
	INVOKE_ASYNC(attached_turret, TYPE_PROC_REF(/obj/machinery/porta_turret, target), victim)

#undef TURRET_COVER_IDLE_TIME
