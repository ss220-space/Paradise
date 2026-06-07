/**
 * # laser pointer Component
 *
 * Points a laser at a tile or mob
 */
/obj/item/circuit_component/laserpointer
	display_name = "Лазерный указатель"
	desc = "Компонент, который направляет лазерный луч на цель."
	category = "Action"
	circuit_flags = CIRCUIT_FLAG_INPUT_SIGNAL|CIRCUIT_FLAG_OUTPUT_SIGNAL

	/// The input port
	var/datum/port/input/target_input
	var/datum/port/input/image_pixel_x
	var/datum/port/input/image_pixel_y

	var/max_range = 7

	var/datum/port/input/option/lasercolour_option

	var/laser_cooldown = 1 SECONDS

/obj/item/circuit_component/laserpointer/Destroy()
	target_input = null
	image_pixel_x = null
	image_pixel_y = null
	lasercolour_option = null
	. = ..()

/obj/item/circuit_component/laserpointer/get_ui_notices()
	. = ..()
	. += create_ui_notice("Максимальная дальность: [max_range] тайл[DECL_CREDIT(max_range)]", "orange", "info")
	. += create_ui_notice("Перезарядка: [DisplayTimeText(laser_cooldown)]", "orange", "stopwatch")

/obj/item/circuit_component/laserpointer/populate_options()
	var/static/component_options = list(
		"red",
		"green",
		"blue",
		"purple",
	)
	lasercolour_option = add_option_port("Цвет лазера", component_options)

/obj/item/circuit_component/laserpointer/populate_ports()
	target_input = add_input_port("Цель", PORT_TYPE_ATOM)
	image_pixel_x = add_input_port("X", PORT_TYPE_NUMBER)
	image_pixel_y = add_input_port("Y", PORT_TYPE_NUMBER)

/obj/item/circuit_component/laserpointer/input_received(datum/port/input/port)
	if(TIMER_COOLDOWN_RUNNING(parent.shell, COOLDOWN_CIRCUIT_LASER))
		return

	var/atom/target = target_input.value
	var/atom/movable/shell = parent.shell
	var/turf/target_location = get_turf(target)

	var/pointer_icon_state = lasercolour_option.value

	var/turf/current_turf = get_location()
	if(get_dist(current_turf, target) > max_range || current_turf.z != target.z)
		return

	// only has cyborg flashing since felinid moving spikes time dilation when spammed and the other two features of laserpointers would be unbalanced when spammed
	if(isrobot(target))
		var/mob/living/silicon/robot/silicon = target
		add_attack_logs(shell, silicon, "shone [src] in their eyes")
		silicon.flash_eyes(affect_silicon = TRUE) /// no stunning, just a blind
		to_chat(silicon, span_danger("Ваши датчики были перегружены лазером, испускаемым [shell.declent_ru(PREPOSITIONAL)]!"))

	var/mutable_appearance/laser_location = mutable_appearance('icons/obj/weapons/guns/projectiles.dmi', "[pointer_icon_state]_laser", target.layer + 0.01)

	laser_location.pixel_w = clamp(target.pixel_x + image_pixel_x.value, -15, 15)
	laser_location.pixel_z = clamp(target.pixel_y + image_pixel_y.value, -15, 15)

	target_location.flick_overlay_view(laser_location, 1 SECONDS)

	TIMER_COOLDOWN_START(shell, COOLDOWN_CIRCUIT_LASER, laser_cooldown)
