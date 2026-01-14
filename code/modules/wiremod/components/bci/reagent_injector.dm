/**
 * # Reagent Injector Component
 *
 * Injects reagents into the user.
 * Requires a BCI shell.
 */

/obj/item/circuit_component/reagent_injector
	display_name = "Инъектор реагента"
	desc = "Компонент, который может вводить реагенты из хранилища реагентов ИМК."
	category = "BCI"
	circuit_flags = CIRCUIT_NO_DUPLICATES

	required_shells = list(/obj/item/organ/internal/cyberimp/brain/bci)

	var/datum/port/input/inject
	var/datum/port/input/transfer_amounts
	var/datum/port/output/injected

	var/obj/item/organ/internal/cyberimp/brain/bci/bci

/obj/item/circuit_component/reagent_injector/Initialize(mapload)
	. = ..()
	container_type = OPENCONTAINER
	create_reagents(15) //This is mostly used in the case of a BCI still having reagents in it when the component is removed.

/obj/item/circuit_component/reagent_injector/populate_ports()
	. = ..()
	inject = add_input_port("Вызов", PORT_TYPE_SIGNAL, trigger = PROC_REF(trigger_inject))
	transfer_amounts = add_input_port("Количество", PORT_TYPE_NUMBER, default = 15)
	injected = add_output_port("Вызвано", PORT_TYPE_SIGNAL)

/obj/item/circuit_component/reagent_injector/pre_input_received(datum/port/input/port)
	transfer_amounts.set_value(clamp(transfer_amounts.value, 1, 15))

/obj/item/circuit_component/reagent_injector/proc/trigger_inject()
	CIRCUIT_TRIGGER
	if(!bci.owner)
		return

	if(bci.owner.reagents.total_volume + transfer_amounts.value > bci.owner.reagents.maximum_volume)
		return

	if(!bci.reagents.total_volume)
		return

	var/fraction = min(transfer_amounts.value/bci.reagents.total_volume, 1)
	bci.reagents.reaction(bci.owner, REAGENT_INGEST, fraction, ignore_protection = TRUE)
	var/units = bci.reagents.trans_to(bci.owner, transfer_amounts.value)
	if(!units)
		return

	injected.set_output(COMPONENT_SIGNAL)
	add_attack_logs(bci.owner, bci.owner, "Injected with [name] containing [bci.reagents.log_list()], transfered [units] units", bci.reagents.harmless_helper() ? ATKLOG_ALMOSTALL : null)

/obj/item/circuit_component/reagent_injector/register_shell(atom/movable/shell)
	. = ..()
	if(!is_bci(shell))
		return

	bci = shell
	bci.container_type = OPENCONTAINER
	bci.create_reagents(15)
	if(!reagents.total_volume)
		return

	reagents.trans_to(bci, reagents.total_volume)

/obj/item/circuit_component/reagent_injector/unregister_shell(atom/movable/shell)
	. = ..()
	if(bci?.reagents)
		if(bci.reagents.total_volume)
			bci.reagents.trans_to(src, bci.reagents.total_volume)
		bci.container_type = NONE
		QDEL_NULL(bci.reagents)

	bci = null
