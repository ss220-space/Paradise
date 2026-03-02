#define COMP_TYPECHECK_MOB "organism"
#define COMP_TYPECHECK_HUMAN "humanoid"

/**
 * # Typecheck Component
 *
 * Checks the type of a value
 */
/obj/item/circuit_component/compare/typecheck
	display_name = "Проверка типа"
	desc = "Компонент, проверяющий тип входных данных."
	category = "Utility"

	var/datum/port/input/option/typecheck_options

	/// Object to typecheck
	var/datum/port/input/thing_to_check

/obj/item/circuit_component/compare/typecheck/Destroy()
	typecheck_options = null
	thing_to_check = null
	. = ..()

/obj/item/circuit_component/compare/typecheck/populate_options()
	var/static/component_options = list(
		PORT_TYPE_STRING,
		PORT_TYPE_NUMBER,
		PORT_COMPOSITE_TYPE_LIST,
		PORT_TYPE_ATOM,
		COMP_TYPECHECK_MOB,
		COMP_TYPECHECK_HUMAN,
	)
	typecheck_options = add_option_port("Тип", component_options)

/obj/item/circuit_component/compare/typecheck/populate_custom_ports()
	thing_to_check = add_input_port("Ввод", PORT_TYPE_ANY)

/obj/item/circuit_component/compare/typecheck/do_comparisons()
	var/input_val = thing_to_check.value
	switch(typecheck_options.value)
		if(PORT_TYPE_STRING)
			return istext(input_val)
		if(PORT_TYPE_NUMBER)
			return isnum(input_val)
		if(PORT_COMPOSITE_TYPE_LIST)
			return islist(input_val)
		if(PORT_TYPE_ATOM)
			return isatom(input_val)
		if(COMP_TYPECHECK_MOB)
			return ismob(input_val)
		if(COMP_TYPECHECK_HUMAN)
			return ishuman(input_val)
	return FALSE

#undef COMP_TYPECHECK_MOB
#undef COMP_TYPECHECK_HUMAN
