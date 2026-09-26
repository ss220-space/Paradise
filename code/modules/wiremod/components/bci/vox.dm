/**
 * # VOX Announcement Component
 *
 * These play a VOX announcement with inputed words from either a string or a list.
 * Requires a BCI shell.
 */

/obj/item/circuit_component/vox
	display_name = "ВОКС"
	desc = "Компонент, воспроизводящий локальное ВОКС-объявление для пользователя. \
			Требуется ИМК-оболочка."
	category = "BCI"

	required_shells = list(/obj/item/organ/internal/cyberimp/brain/bci)

	var/datum/port/input/option/type_option
	var/current_type

	var/datum/port/input/word_list

	circuit_flags = CIRCUIT_FLAG_INPUT_SIGNAL

	var/obj/item/organ/internal/cyberimp/brain/bci/bci

/obj/item/circuit_component/vox/Destroy()
	if(bci)
		unregister_shell(bci)
	type_option = null
	word_list = null
	. = ..()

/obj/item/circuit_component/vox/populate_options()
	type_option = add_option_port("тип ВОКС-а", list(PORT_TYPE_LIST(PORT_TYPE_STRING), PORT_TYPE_STRING))

/obj/item/circuit_component/vox/populate_ports()
	word_list = add_input_port("Слова", PORT_TYPE_LIST(PORT_TYPE_STRING))

/obj/item/circuit_component/vox/register_shell(atom/movable/shell)
	if(!is_bci(shell))
		return

	bci = shell

/obj/item/circuit_component/vox/unregister_shell(atom/movable/shell)
	bci = null

/obj/item/circuit_component/vox/pre_input_received(datum/port/input/port)
	var/current_option = type_option.value
	if(current_type == current_option)
		return

	current_type = current_option
	word_list.set_datatype(current_type)

/obj/item/circuit_component/vox/input_received(datum/port/input/port)
	if(!bci)
		return

	var/mob/living/owner = bci.owner

	if(!owner || !istype(owner) || !owner.client || !word_list.value)
		return

	var/list/words_list
	words_list = islist(word_list.value) ? word_list.value : splittext(trim(word_list.value), " ")

	for(var/word in words_list)
		play_vox_word(word, only_listener = owner)

