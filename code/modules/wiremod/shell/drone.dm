/**
 * # Drone
 *
 * A movable mob that can be fed inputs on which direction to travel.
 */
/mob/living/simple_animal/circuit_drone
	name = "drone"
	icon = 'icons/obj/circuits.dmi'
	icon_state = "setup_medium_med"
	health = 25
	maxHealth = 25
	damage_coeff = list(BRUTE = 0.5, BURN = 0.7, TOX = 0, CLONE = 0, STAMINA = 0, OXY = 0)
	atmos_requirements = list("min_oxy" = 0, "max_oxy" = 0, "min_tox" = 0, "max_tox" = 0, "min_co2" = 0, "max_co2" = 0, "min_n2" = 0, "max_n2" = 0)
	light_system = MOVABLE_LIGHT_DIRECTIONAL
	pass_flags = PASSTABLE
	light_on = FALSE
	AIStatus = AI_OFF
	can_collar = TRUE
	del_on_death = TRUE
	healable = FALSE

/mob/living/simple_animal/circuit_drone/get_ru_names()
	return list(
		NOMINATIVE = "программируемый дрон",
		GENITIVE = "программируемого дрона",
		DATIVE = "программируемому дрону",
		ACCUSATIVE = "программируемый дрон",
		INSTRUMENTAL = "программируемым дроном",
		PREPOSITIONAL = "программируемом дроне"
	)

/mob/living/simple_animal/circuit_drone/Destroy()
	visible_message(span_userdanger("[DECLENT_RU_CAP(src, NOMINATIVE)] разлета[PLUR_ET_UT(src)]ся на части!"))
	do_sparks(3, TRUE, src)
	new /obj/effect/decal/cleanable/blood/oil(loc)
	return ..()

/mob/living/simple_animal/circuit_drone/ComponentInitialize()
	AddComponent( \
		/datum/component/animal_temperature, \
		maxbodytemp = 500, \
		minbodytemp = 0, \
	)
	AddComponent(/datum/component/shell, list(
		new /obj/item/circuit_component/bot_circuit(),
		new /obj/item/circuit_component/remotecam/drone()
	), SHELL_CAPACITY_LARGE)

/mob/living/simple_animal/circuit_drone/examine(mob/user)
	. = ..()
	if(health >= maxHealth)
		. += span_notice("[DECLENT_RU_CAP(src, NOMINATIVE)] в отличном состоянии.")
		return

	if(health > maxHealth / 3)
		. += span_notice("[DECLENT_RU_CAP(src, NOMINATIVE)] выглядит слегка повреждённым.")
		return

	. += span_warning("[DECLENT_RU_CAP(src, NOMINATIVE)] выглядит сильно повреждённым!")

/mob/living/simple_animal/circuit_drone/welder_act(mob/living/user, obj/item/tool)
	. = ..()
	if(user.a_intent != INTENT_HELP)
		return FALSE

	if(health == maxHealth)
		balloon_alert(user, "ремонт не требуется!")
		return TRUE

	if(tool.use_tool(src, user, 1 SECONDS, volume = tool.tool_volume))
		adjustHealth(-5)

	return TRUE

/obj/item/circuit_component/bot_circuit
	display_name = "Дрон"
	desc = "Используется для отправки сигналов движения на оболочку дрона."

	/// The inputs to allow for the drone to move
	var/datum/port/input/north
	var/datum/port/input/east
	var/datum/port/input/south
	var/datum/port/input/west

	// Done like this so that travelling diagonally is more simple
	COOLDOWN_DECLARE(north_delay)
	COOLDOWN_DECLARE(east_delay)
	COOLDOWN_DECLARE(south_delay)
	COOLDOWN_DECLARE(west_delay)

	/// Delay between each movement
	var/move_delay = 0.4 SECONDS

/obj/item/circuit_component/bot_circuit/register_shell(atom/movable/shell)
	. = ..()
	if(!ismob(shell))
		return

	RegisterSignal(shell, COMSIG_PROCESS_BORGCHARGER_OCCUPANT, PROC_REF(on_borg_charge))

/obj/item/circuit_component/bot_circuit/unregister_shell(atom/movable/shell)
	UnregisterSignal(shell, COMSIG_PROCESS_BORGCHARGER_OCCUPANT)
	return ..()

/obj/item/circuit_component/bot_circuit/proc/on_borg_charge(datum/source, recharge_speed)
	SIGNAL_HANDLER
	if(isnull(parent.cell))
		return

	parent.cell.charge = min(parent.cell.charge + recharge_speed, parent.cell.maxcharge)

/obj/item/circuit_component/bot_circuit/populate_ports()
	north = add_input_port("Север", PORT_TYPE_SIGNAL)
	south = add_input_port("Юг", PORT_TYPE_SIGNAL)
	west = add_input_port("Запад", PORT_TYPE_SIGNAL)
	east = add_input_port("Восток", PORT_TYPE_SIGNAL)

/obj/item/circuit_component/bot_circuit/input_received(datum/port/input/port)

	var/mob/living/simple_animal/shell = parent.shell
	if(!istype(shell) || shell.stat)
		return

	var/direction

	if(COMPONENT_TRIGGERED_BY(north, port) && COOLDOWN_FINISHED(src, north_delay))
		direction = NORTH
		COOLDOWN_START(src, north_delay, move_delay)
	else if(COMPONENT_TRIGGERED_BY(east, port) && COOLDOWN_FINISHED(src, east_delay))
		direction = EAST
		COOLDOWN_START(src, east_delay, move_delay)
	else if(COMPONENT_TRIGGERED_BY(south, port) && COOLDOWN_FINISHED(src, south_delay))
		direction = SOUTH
		COOLDOWN_START(src, south_delay, move_delay)
	else if(COMPONENT_TRIGGERED_BY(west, port) && COOLDOWN_FINISHED(src, west_delay))
		direction = WEST
		COOLDOWN_START(src, west_delay, move_delay)

	if(!direction)
		return

	if(ismovable(shell.loc)) //Inside an object, tell it we moved
		var/atom/loc_atom = shell.loc
		loc_atom.relaymove(shell, direction)
		return

	if(shell.Process_Spacemove(direction))
		shell.Move(get_step(shell, direction), direction)
