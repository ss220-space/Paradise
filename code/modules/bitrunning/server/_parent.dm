/obj/machinery/quantum_server
	name = "quantum server"
	desc = "Громоздкая вычислительная машина, собирающая виртуальные домены из чистых данных."
	icon = 'icons/obj/machines/bitrunning.dmi'
	icon_state = "qserver"
	base_icon_state = "qserver"
	density = TRUE
	anchored = TRUE
	max_integrity = 300
	idle_power_usage = 200
	active_power_usage = 1500
	var/capacitor_coefficient = 1
	var/glitch_chance = 0.2
	var/threat_prob_max = 15
	var/datum/lazy_template/virtual_domain/generated_domain
	var/datum/turf_reservation/domain_reservation
	var/domain_complete = FALSE
	var/domain_randomized = FALSE
	var/is_ready = TRUE
	var/list/datum/weakref/avatar_connection_refs = list()
	var/multiplayer_bonus = 1.1
	var/nohit_bonus = 0.8
	var/points = 0
	var/retries_spent = 0
	var/scanner_tier = 1
	var/server_cooldown_time = 2 MINUTES
	var/servo_bonus = 0
	var/threat = 0
	var/list/datum/weakref/mutation_candidate_refs = list()
	var/list/datum/weakref/spawned_threat_refs = list()
	var/list/turf/exit_turfs = list()
	var/list/turf/goal_turfs = list()
	var/list/mob/polled_ghosts
	var/broadcasting = FALSE
	COOLDOWN_DECLARE(broadcast_toggle_cd)
	COOLDOWN_DECLARE(polling_cooldown)

/obj/machinery/quantum_server/Initialize(mapload)
	. = ..()
	component_parts = list()
	component_parts += new /obj/item/circuitboard/machine/quantum_server(null)
	component_parts += new /obj/item/stock_parts/capacitor(null)
	component_parts += new /obj/item/stock_parts/scanning_module(null)
	component_parts += new /obj/item/stock_parts/manipulator(null)
	component_parts += new /obj/item/stack/cable_coil(null, 2)
	RefreshParts()
	register_context()

/obj/machinery/quantum_server/Destroy()
	sever_connections()
	if(generated_domain)
		scrub_vdom()
	avatar_connection_refs.Cut()
	mutation_candidate_refs.Cut()
	spawned_threat_refs.Cut()
	exit_turfs.Cut()
	goal_turfs.Cut()
	polled_ghosts = null
	return ..()

/obj/machinery/quantum_server/on_deconstruction()
	if(is_ready)
		return
	var/obj/item/circuitboard/machine/quantum_server/board = locate() in component_parts
	if(board)
		component_parts -= board
		qdel(board)

/obj/machinery/quantum_server/get_ru_names()
	return alist(
		NOMINATIVE = "квантовый сервер",
		GENITIVE = "квантового сервера",
		DATIVE = "квантовому серверу",
		ACCUSATIVE = "квантовый сервер",
		INSTRUMENTAL = "квантовым сервером",
		PREPOSITIONAL = "квантовом сервере",
	)

/obj/machinery/quantum_server/add_context(atom/source, list/context, obj/item/held_item, mob/user)
	. = ..()
	if(isnull(held_item))
		return

	if(held_item.tool_behaviour == TOOL_SCREWDRIVER)
		context[SCREENTIP_CONTEXT_LMB] = panel_open ? "Закрыть панель" : "Открыть панель"
		return CONTEXTUAL_SCREENTIP_SET

	if(held_item.tool_behaviour == TOOL_CROWBAR && panel_open)
		context[SCREENTIP_CONTEXT_LMB] = "Разобрать"
		return CONTEXTUAL_SCREENTIP_SET

/obj/machinery/quantum_server/examine(mob/user)
	. = ..()
	. += span_notice("Потребляет много энергии. Убедитесь в достаточном питании.")

	if(capacitor_coefficient < 1)
		. += span_notice("Конденсаторы сокращают время остывания на [(1 - capacitor_coefficient) * 100]%.")
	if(servo_bonus > 0)
		. += span_notice("Манипуляторы увеличивают награду в [servo_bonus]x и смягчают травму от аварийного отключения.")
	if(!is_ready)
		. += span_warning("Сервер остывает. Дайте ему пару минут.")

	if(isobserver(user) && emagged)
		. += span_notice("Тревожные индикаторы мигают красным. В сервер кто-то залез.")

/obj/machinery/quantum_server/emag_act(mob/user)
	if(emagged)
		return

	emagged = TRUE
	glitch_chance *= 2
	threat_prob_max *= 2
	SEND_SIGNAL(src, COMSIG_BITRUNNER_SERVER_EMAGGED)

	balloon_alert(user, "система взломана...")
	playsound(src, 'sound/effects/sparks1.ogg', 35, TRUE)
	update_icon(UPDATE_OVERLAYS)

/obj/machinery/quantum_server/update_overlays()
	. = ..()
	if(emagged)
		. += mutable_appearance(icon, "emag_overlay")

/obj/machinery/quantum_server/update_icon_state()
	if(isnull(generated_domain) || !is_operational())
		icon_state = base_icon_state
		return

	if(panel_open)
		icon_state = "[base_icon_state]_panel"
		return

	icon_state = "[base_icon_state]_[is_ready ? "on" : "off"]"

/obj/machinery/quantum_server/update_appearance(updates = ALL)
	if(isnull(generated_domain) || !is_operational())
		set_light(l_on = FALSE)
		return ..()

	set_light(l_range = 2, l_power = 1.5, l_color = is_ready ? LIGHT_COLOR_BABY_BLUE : LIGHT_COLOR_FIRE, l_on = TRUE)
	return ..()

/obj/machinery/quantum_server/power_change(forced = FALSE)
	..()
	if(!is_operational())
		sever_connections()
	update_icon(UPDATE_ICON_STATE)

/obj/machinery/quantum_server/obj_break(damage_flag)
	. = ..()
	sever_connections()
	update_icon(UPDATE_ICON_STATE)

/obj/machinery/quantum_server/item_interaction(mob/living/user, obj/item/tool, list/modifiers)
	if(!istype(tool, /obj/item/bitrunning_debug))
		return ..()

	balloon_alert(user, "я в системе")
	emagged = TRUE
	glitch_chance = 0.5
	capacitor_coefficient = 0.1
	points = 100
	update_icon(UPDATE_OVERLAYS)
	return ITEM_INTERACT_SUCCESS

/obj/machinery/quantum_server/crowbar_act(mob/living/user, obj/item/tool)
	if(!is_ready)
		balloon_alert(user, "он раскалён!")
		return ITEM_INTERACT_BLOCKING

	if(length(avatar_connection_refs))
		balloon_alert(user, "сначала отключите всех!")
		return ITEM_INTERACT_BLOCKING

	return default_deconstruction_crowbar(user, tool)

/obj/machinery/quantum_server/screwdriver_act(mob/living/user, obj/item/tool)
	if(!is_ready)
		balloon_alert(user, "он раскалён!")
		return ITEM_INTERACT_BLOCKING

	if(default_deconstruction_screwdriver(user, "[base_icon_state]_panel", base_icon_state, tool))
		update_icon(UPDATE_ICON_STATE)
		return ITEM_INTERACT_SUCCESS

/obj/machinery/quantum_server/RefreshParts()
	var/capacitor_rating = 1.15
	for(var/obj/item/stock_parts/capacitor/capacitor in component_parts)
		capacitor_rating -= capacitor.rating * 0.15
	capacitor_coefficient = capacitor_rating

	for(var/obj/item/stock_parts/scanning_module/scanner in component_parts)
		scanner_tier = scanner.rating

	var/servo_rating = 0
	for(var/obj/item/stock_parts/manipulator/servo in component_parts)
		servo_rating += servo.rating * 0.1
	servo_bonus = servo_rating
