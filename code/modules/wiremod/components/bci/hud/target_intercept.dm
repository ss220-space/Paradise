/**
 * # Target Intercept Component
 *
 * When activated intercepts next click and outputs clicked atom.
 * Requires a BCI shell.
 */

/obj/item/circuit_component/target_intercept
	display_name = "Перехват цели"
	desc = "Требуется ИМК-оболочка. \
			При активации этот компонент позволит пользователю нацеливаться на объект выводить ссылку на него."
	category = "BCI"

	required_shells = list(/obj/item/organ/internal/cyberimp/brain/bci)

	var/datum/port/output/clicked_atom

	var/obj/item/organ/internal/cyberimp/brain/bci/bci
	var/intercept_cooldown = 1 SECONDS

/obj/item/circuit_component/target_intercept/populate_ports()
	trigger_input = add_input_port("Вызов", PORT_TYPE_SIGNAL)
	trigger_output = add_output_port("Вызвано", PORT_TYPE_SIGNAL)
	clicked_atom = add_output_port("Цель", PORT_TYPE_ATOM)

/obj/item/circuit_component/target_intercept/register_shell(atom/movable/shell)
	if(!is_bci(shell))
		return

	bci = shell
	RegisterSignal(shell, COMSIG_ORGAN_REMOVED, PROC_REF(on_organ_removed))

/obj/item/circuit_component/target_intercept/unregister_shell(atom/movable/shell)
	bci = null
	UnregisterSignal(shell, COMSIG_ORGAN_REMOVED)

/obj/item/circuit_component/target_intercept/input_received(datum/port/input/port)
	if(!bci)
		return

	if(!parent.shell)
		return

	var/mob/living/owner = bci.owner
	if(!owner || !istype(owner) || !owner.client || owner.stat >= UNCONSCIOUS)
		return

	if(TIMER_COOLDOWN_RUNNING(parent.shell, COOLDOWN_CIRCUIT_TARGET_INTERCEPT))
		return

	to_chat(owner, span_warning("Используйте <b>ЛКМ</b> для активации перехватчика цели!"))
	owner.client.click_intercept = src

/obj/item/circuit_component/target_intercept/proc/on_organ_removed(datum/source, mob/living/carbon/owner)
	SIGNAL_HANDLER

	if(owner.client && owner.client.click_intercept == src)
		owner.client.click_intercept = null

/obj/item/circuit_component/target_intercept/proc/InterceptClickOn(mob/user, params, atom/object)
	user.client.click_intercept = null
	clicked_atom.set_output(object)
	trigger_output.set_output(COMPONENT_SIGNAL)
	if(!parent.shell)
		return

	TIMER_COOLDOWN_START(parent.shell, COOLDOWN_CIRCUIT_TARGET_INTERCEPT, intercept_cooldown)

/obj/item/circuit_component/target_intercept/get_ui_notices()
	. = ..()
	. += create_ui_notice("Перезарядка перехвата цели: [DisplayTimeText(intercept_cooldown)]", "orange", "stopwatch")
