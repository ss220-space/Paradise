/**
 * # Thought Listener Component
 *
 * Allows user to input a string.
 * Requires a BCI shell.
 */

/obj/item/circuit_component/thought_listener
	display_name = "Детектор мыслей"
	desc = "Компонент, позволяющий пользователю отправлять сигнал силой мысли. \
			Требуется ИМК-оболочка."
	category = "BCI"

	required_shells = list(/obj/item/organ/internal/cyberimp/brain/bci)

	var/datum/port/input/input_name
	var/datum/port/input/input_desc

	var/datum/port/output/output
	var/datum/port/output/failure

	circuit_flags = CIRCUIT_FLAG_INPUT_SIGNAL

	var/obj/item/organ/internal/cyberimp/brain/bci/bci
	var/ready = TRUE

/obj/item/circuit_component/thought_listener/populate_ports()
	input_name = add_input_port("Название", PORT_TYPE_STRING)
	input_desc = add_input_port("Описание", PORT_TYPE_STRING)
	output = add_output_port("Мысль", PORT_TYPE_STRING)
	trigger_output = add_output_port("Вызвано", PORT_TYPE_SIGNAL)
	failure = add_output_port("Провал", PORT_TYPE_SIGNAL)

/obj/item/circuit_component/thought_listener/register_shell(atom/movable/shell)
	if(!is_bci(shell))
		return

	bci = shell

/obj/item/circuit_component/thought_listener/unregister_shell(atom/movable/shell)
	bci = null

/obj/item/circuit_component/thought_listener/input_received(datum/port/input/port)
	if(!ready)
		failure.set_output(COMPONENT_SIGNAL)
		return

	if(!bci)
		failure.set_output(COMPONENT_SIGNAL)
		return

	var/mob/living/owner = bci.owner

	if(!owner || !istype(owner) || !owner.client)
		failure.set_output(COMPONENT_SIGNAL)
		return

	INVOKE_ASYNC(src, PROC_REF(thought_listen), owner)
	ready = FALSE

/obj/item/circuit_component/thought_listener/proc/thought_listen(mob/living/owner)
	var/message = tgui_input_text(owner, input_desc.value ? input_desc.value : "", input_name.value ? input_name.value : "Thought Listener", "", max_length = MAX_MESSAGE_LEN)
	if(QDELETED(owner))
		return
	output.set_output(message)
	trigger_output.set_output(COMPONENT_SIGNAL)
	ready = TRUE
