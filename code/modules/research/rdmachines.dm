//All devices that link into the R&D console fall into thise type for easy identification and some shared procs.

/obj/machinery/r_n_d
	name = "R&D Device"
	icon = 'icons/obj/machines/research.dmi'
	var/icon_open = null
	var/icon_closed = null
	density = TRUE
	anchored = TRUE
	var/busy = 0
	var/hacked = 0
	var/disabled = 0
	var/shocked = 0
	var/obj/machinery/computer/rdconsole/linked_console
	var/obj/item/loaded_item = null
	var/datum/component/material_container/materials	//Store for hyper speed!
	var/efficiency_coeff = 1
	var/list/categories = list()
	var/datum/wires/r_n_d_machine_wires
	var/datum/wires/wires_type = /datum/wires/rnd

/obj/machinery/r_n_d/Initialize(mapload)
	. = ..()
	materials = AddComponent(/datum/component/material_container, list(MAT_METAL, MAT_GLASS, MAT_SILVER, MAT_GOLD, MAT_DIAMOND, MAT_PLASMA, MAT_URANIUM, MAT_BANANIUM, MAT_TRANQUILLITE, MAT_TITANIUM, MAT_BLUESPACE, MAT_PLASTIC), 0, TRUE, /obj/item/stack, CALLBACK(src, PROC_REF(is_insertion_ready)), CALLBACK(src, PROC_REF(AfterMaterialInsert)))
	materials.precise_insertion = TRUE
	r_n_d_machine_wires = new wires_type(src)

/obj/machinery/r_n_d/Destroy()
	if(loaded_item)
		loaded_item.forceMove(get_turf(src))
		loaded_item = null
	linked_console = null
	materials = null
	QDEL_NULL(r_n_d_machine_wires)
	return ..()

/obj/machinery/r_n_d/multitool_act(mob/living/user, obj/item/tool)
	if(panel_open)
		r_n_d_machine_wires.Interact(user)
		return TRUE
	return FALSE

/obj/machinery/r_n_d/wirecutter_act(mob/living/user, obj/item/tool)
	if(panel_open)
		r_n_d_machine_wires.Interact(user)
		return TRUE
	return FALSE

/obj/machinery/r_n_d/attack_hand(mob/user)
	if(shocked)
		shock(user, 50)
	return ..()

/obj/machinery/r_n_d/item_interaction(mob/living/user, obj/item/tool, list/modifiers)
	if(shocked)
		shock(user, 50)
	return ..()

//whether the machine can have an item inserted in its current state.
/obj/machinery/r_n_d/proc/is_insertion_ready(mob/user)
	if(panel_open)
		balloon_alert(user, "техпанель открыта!")
		return FALSE
	if(disabled)
		return FALSE
	if(!linked_console)
		balloon_alert(user, "не подключено к консоли!")
		return FALSE
	if(busy)
		balloon_alert(user, "в работе!")
		return FALSE
	if(stat & BROKEN)
		balloon_alert(user, "сломано!")
		return FALSE
	if(stat & NOPOWER)
		balloon_alert(user, "нет энергии!")
		return FALSE
	if(loaded_item)
		balloon_alert(user, "слот для предмета занят!")
		return FALSE
	return TRUE

/obj/machinery/r_n_d/proc/AfterMaterialInsert(type_inserted, id_inserted, amount_inserted)
	var/stack_name
	var/obj/item/stack/S = type_inserted
	if(ispath(type_inserted, /obj/item/stack/ore/bluespace_crystal))
		use_power(MINERAL_MATERIAL_AMOUNT / 10)
	else
		use_power(min(1000, (amount_inserted / 100)))
	stack_name = S.protolathe_name
	flick_overlay_view(mutable_appearance(icon, "[base_icon_state]_[stack_name]"), 1.5 SECONDS)

/obj/machinery/r_n_d/proc/check_mat(datum/design/being_built, M)
	return 0 // number of copies of design beign_built you can make with material M
