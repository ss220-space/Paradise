/**
 * # Manipulator
 *
 * Immobile shells that can move objects
 * 
 */
/obj/structure/wiremod_manipulator
	name = "manipulator"
	icon = 'icons/obj/circuits.dmi'
	icon_state = "setup_large_arm"
	var/target_move_speed = 3.5

	density = TRUE
	light_system = MOVABLE_LIGHT
	light_on = FALSE

/obj/structure/wiremod_manipulator/get_ru_names()
	return list(
		NOMINATIVE = "манипулятор",
		GENITIVE = "манипулятора",
		DATIVE = "манипулятору",
		ACCUSATIVE = "манипулятор",
		INSTRUMENTAL = "манипулятором",
		PREPOSITIONAL = "манипуляторе"
	)

/obj/structure/wiremod_manipulator/Initialize(mapload)
	. = ..()
	AddComponent( \
		/datum/component/shell, \
		unremovable_circuit_components = list(new /obj/item/circuit_component/wiremod_manipulator), \
		capacity = SHELL_CAPACITY_LARGE, \
	)

/obj/item/circuit_component/wiremod_manipulator
	display_name = "Манипулятор"
	desc = "Используется для перемещения объектов."
	circuit_flags = CIRCUIT_FLAG_INPUT_SIGNAL|CIRCUIT_FLAG_OUTPUT_SIGNAL

	/// End point coordinates
	var/datum/port/input/image_pixel_x
	var/datum/port/input/image_pixel_y

	/// Target item
	var/datum/port/input/target

	var/obj/structure/wiremod_manipulator/attached_bot

/obj/item/circuit_component/wiremod_manipulator/populate_ports()
  target = add_input_port("Цель", PORT_TYPE_ATOM)
  image_pixel_x = add_input_port("X", PORT_TYPE_NUMBER)
  image_pixel_y = add_input_port("Y", PORT_TYPE_NUMBER)

/obj/item/circuit_component/wiremod_manipulator/register_shell(atom/movable/shell)
	. = ..()
	if(!istype(shell, /obj/structure/wiremod_manipulator))
		return

	attached_bot = shell

/obj/item/circuit_component/wiremod_manipulator/unregister_shell(atom/movable/shell)
	attached_bot = null
	return ..()

/obj/item/circuit_component/wiremod_manipulator/input_received(datum/port/input/port)
	if(!attached_bot)
		return

	var/atom/target_atom = target.value
	var/target_x = image_pixel_x.value
	var/target_y = image_pixel_y.value
	var/obj/target_obj = target.value
	var/turf/target_turf = locate(target_x, target_y, target_atom.z)
	if(!target_atom || get_dist(attached_bot, target_atom) > 1 || attached_bot.z != target_atom.z)
		return

	if(!target_obj.anchored && attached_bot.anchored && get_dist(attached_bot, target_turf) <= 1)
		attached_bot.visible_message(span_danger("[attached_bot] хватает [target_atom]"))
		playsound(attached_bot, 'sound/mecha/hydraulic.ogg', 50, TRUE)
		if(isliving(target_atom) || isstructure(target_atom))
			sleep(attached_bot.target_move_speed * 3)
		else
			sleep(attached_bot.target_move_speed)
		if(!target_atom || target_obj.anchored || !attached_bot.anchored || get_dist(attached_bot, target_atom) > 1)
			return
		
		attached_bot.visible_message(span_danger("[attached_bot] с громким жужжанием перемещает [target_atom]"))
		target_obj.forceMove(target_turf)
		target_obj.SpinAnimation(speed = 3, loops = 1, parallel = FALSE)

/obj/structure/wiremod_manipulator/wrench_act(mob/living/user, obj/item/tool)
	set_anchored(!anchored)
	tool.play_tool_sound(src)
	balloon_alert(user, "[anchored ? "" : "не"]закреплено")
	return TRUE
