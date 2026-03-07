/**
 * # String Contains Component
 *
 * Checks if a string contains a word/letter
 */
/obj/item/circuit_component/compare/contains
	display_name = "Вхождение подстроки"
	desc = "Проверяет, содержит ли строка подстроку. Возвращает индекс первого вхождения."
	category = "String"

	var/datum/port/input/needle
	var/datum/port/input/haystack

/obj/item/circuit_component/compare/contains/Destroy()
	needle = null
	haystack = null
	. = ..()

/obj/item/circuit_component/compare/contains/populate_custom_ports()
	haystack = add_input_port("Строка", PORT_TYPE_STRING)
	needle = add_input_port("Подстрока", PORT_TYPE_STRING)

/obj/item/circuit_component/compare/contains/do_comparisons()
	var/to_find = needle.value
	var/to_search = haystack.value

	if(!to_find || !to_search)
		return

	return findtext(to_search, to_find)
