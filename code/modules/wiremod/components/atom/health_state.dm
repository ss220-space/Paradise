#define ALIVE "Норма"
#define CRIT "Критическое состояние"
#define UNCONS "Без сознания"
#define DECEASED "Смерть"

/**
 * # Compare Health State Component
 *
 * Returns true when state matches entity.
 */

/obj/item/circuit_component/compare/health_state
	display_name = "Сравнение состояния здоровья"
	desc = "Компонент, который сравнивает оценку состояния здоровья организма и возвращает значение \"истина\" или \"ложь\"."
	category = "Entity"

	/// The input port
	var/datum/port/input/input_port

	/// Compare state option
	var/datum/port/input/option/state_option

	var/max_range = 5

/obj/item/circuit_component/compare/health_state/get_ui_notices()
	. = ..()
	. += create_ui_notice("Максимальная дальность: [max_range] тайл[DECL_CREDIT(max_range)]", "orange", "info")

/obj/item/circuit_component/compare/health_state/populate_options()
	input_port = add_input_port("Организм", PORT_TYPE_ATOM)

	var/static/component_options = list(
		ALIVE,
		CRIT,
		UNCONS,
		DECEASED,
	)
	state_option = add_option_port("Параметр", component_options)

/obj/item/circuit_component/compare/health_state/do_comparisons()
	var/mob/living/organism = input_port.value
	var/turf/current_turf = get_location()
	var/turf/target_location = get_turf(organism)
	if(!istype(organism) || current_turf.z != target_location.z || get_dist(current_turf, target_location) > max_range)
		return FALSE

	var/current_option = state_option.value
	var/state = organism.stat
	switch(current_option)
		if(ALIVE)
			return state != DEAD && !HAS_TRAIT(organism, TRAIT_FAKEDEATH)

		if(CRIT)
			return organism.InCritical()

		if(UNCONS)
			return state == UNCONS

		if(DECEASED)
			return state == DEAD || HAS_TRAIT(organism, TRAIT_FAKEDEATH)
	//Unknown state, something fucked up really bad - just return false
	return FALSE

#undef ALIVE
#undef CRIT
#undef UNCONS
#undef DECEASED
