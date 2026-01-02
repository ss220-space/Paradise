/**
 * # Server
 *
 * Immobile (but not dense) shells that can interact with
 * world.
 */
/obj/structure/wiremod_manipulator
	name = "manipulator"
	icon = 'icons/obj/circuits.dmi'
	icon_state = "setup_stationary"
  var/can_move_mobs_and_structures = FALSE
  var/move_speed = 2
  
	density = TRUE
	light_system = MOVABLE_LIGHT
	light_on = FALSE

/obj/structure/server/get_ru_names()
	return list(
		NOMINATIVE = "манипулятор",
		GENITIVE = "манипулятора",
		DATIVE = "манипулятору",
		ACCUSATIVE = "манипулятор",
		INSTRUMENTAL = "манипулятором",
		PREPOSITIONAL = "манипуляторе"
	)

/obj/structure/server/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/shell, null, SHELL_CAPACITY_VERY_LARGE, SHELL_FLAG_REQUIRE_ANCHOR|SHELL_FLAG_USB_PORT)

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
	if(!istype(shell, /obj/structure/painting_printer))
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
  if(!target_atom || get_dist(attached_bot, target_atom) > 1 || attached_bot.z != target_atom.z)
    return

  if((!isliving(target_atom) && !isstructure(target_atom)) || can_move_mobs_and_machinery)
    if(!target_atom.anchored)
      visible_message(span_notice("[src] хватает [target_atom]."))
      addtimer(CALLBACK(src, PROC_REF(move_object), target_atom, target_x, target_y), move_speed)

/obj/structure/wiremod_manipulator/proc/move_object(atom/target_atom, target_pos_x, target_pos_y)
  if(!target_atom)
    return
  
  var/turf/target_turf = locate(target_pos_x, target_pos_y, target_atom.z)
  target_atom.forceMove(target_turf)
  visible_message(span_notice("[src] с громким жужжанием перемещает [target_atom]."))

/obj/structure/server/wrench_act(mob/living/user, obj/item/tool)
	set_anchored(!anchored)
	tool.play_tool_sound(src)
	balloon_alert(user, "[anchored ? "" : "не"]закреплено")
	return TRUE
