/*
Protolathe

Similar to an autolathe, you load glass and metal sheets (but not other objects) into it to be used as raw materials for the stuff
it creates. All the menus and other manipulation commands are in the R&D console.

Note: Must be placed west/left of and R&D console to function.

*/
/obj/machinery/r_n_d/protolathe
	name = "Protolathe"
	desc = "Converts raw materials into useful objects."
	icon_state = "protolathe"
	base_icon_state = "protolathe"
	container_type = OPENCONTAINER

	categories = list(
								"Bluespace",
								"Equipment",
								"Janitorial",
								"Medical",
								"Mining",
								"Miscellaneous",
								"Power",
								"Stock Parts",
								"Weapons",
								"ILLEGAL",
								)

	reagents = new()


/obj/machinery/r_n_d/protolathe/New()
	..()
	component_parts = list()
	component_parts += new /obj/item/circuitboard/protolathe(null)
	component_parts += new /obj/item/stock_parts/matter_bin(null)
	component_parts += new /obj/item/stock_parts/matter_bin(null)
	component_parts += new /obj/item/stock_parts/manipulator(null)
	component_parts += new /obj/item/stock_parts/manipulator(null)
	component_parts += new /obj/item/reagent_containers/glass/beaker/large(null)
	component_parts += new /obj/item/reagent_containers/glass/beaker/large(null)
	RefreshParts()
	if(is_taipan(z))
		icon_state = "syndie_protolathe"
		base_icon_state = "syndie_protolathe"
	reagents.my_atom = src

/obj/machinery/r_n_d/protolathe/upgraded/New()
	..()
	component_parts = list()
	component_parts += new /obj/item/circuitboard/protolathe(null)
	component_parts += new /obj/item/stock_parts/matter_bin/super(null)
	component_parts += new /obj/item/stock_parts/matter_bin/super(null)
	component_parts += new /obj/item/stock_parts/manipulator/pico(null)
	component_parts += new /obj/item/stock_parts/manipulator/pico(null)
	component_parts += new /obj/item/reagent_containers/glass/beaker/large(null)
	component_parts += new /obj/item/reagent_containers/glass/beaker/large(null)
	RefreshParts()
	if(is_taipan(z))
		icon_state = "syndie_protolathe"
		base_icon_state = "syndie_protolathe"
	reagents.my_atom = src

/obj/machinery/r_n_d/protolathe/RefreshParts()
	var/T = 0
	for(var/obj/item/reagent_containers/glass/G in component_parts)
		G.reagents.trans_to(src, G.reagents.total_volume)
	for(var/obj/item/stock_parts/matter_bin/M in component_parts)
		T += M.rating
	materials.max_amount = T * 75000
	T = 1.2
	for(var/obj/item/stock_parts/manipulator/M in component_parts)
		T -= M.rating/10
	efficiency_coeff = min(max(0, T), 1)

/obj/machinery/r_n_d/protolathe/check_mat(datum/design/being_built, M)	// now returns how many times the item can be built with the material
	var/A = materials.amount(M)
	if(!A)
		A = reagents.get_reagent_amount(M)
		A = A / max(1, (being_built.reagents_list[M] * efficiency_coeff))
	else
		A = A / max(1, (being_built.materials[M] * efficiency_coeff))
	return A


/obj/machinery/r_n_d/protolathe/attackby(obj/item/I, mob/user, params)
	if(shocked && shock(user, 50))
		add_fingerprint(user)
		return ATTACK_CHAIN_BLOCKED_ALL

	var/is_open_container = I.is_open_container()
	if(user.a_intent == INTENT_HARM)
		if(is_open_container)
			return ..() | ATTACK_CHAIN_NO_AFTERATTACK
		return ..()

	if(exchange_parts(user, I))
		return ATTACK_CHAIN_PROCEED_SUCCESS

	if(is_open_container)
		if(panel_open)
			to_chat(user, span_warning("Close the maintenance panel first."))
			return ATTACK_CHAIN_PROCEED|ATTACK_CHAIN_NO_AFTERATTACK
		return ATTACK_CHAIN_PROCEED	// afterattack will handle this

	return ..()


/obj/machinery/r_n_d/protolathe/screwdriver_act(mob/living/user, obj/item/I)
	if(shocked && shock(user, 50))
		add_fingerprint(user)
		return TRUE
	. = default_deconstruction_screwdriver(user, "[base_icon_state]_t", base_icon_state, I)
	if(. && linked_console)
		linked_console.linked_lathe = null
		linked_console = null


/obj/machinery/r_n_d/protolathe/crowbar_act(mob/living/user, obj/item/I)
	. = TRUE
	if(shocked && shock(user, 50))
		add_fingerprint(user)
		return .
	if(!panel_open)
		add_fingerprint(user)
		to_chat(user, span_warning("Open the maintenance panel first."))
		return .
	var/atom/drop_loc = drop_location()
	for(var/obj/component as anything in component_parts)
		if(istype(component, /obj/item/reagent_containers/glass/beaker))
			reagents.trans_to(component, reagents.total_volume)
		component.forceMove(drop_loc)
	materials.retrieve_all()
	default_deconstruction_crowbar(user, I)

