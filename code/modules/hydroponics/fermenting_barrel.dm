/obj/structure/fermenting_barrel
	name = "wooden barrel"
	desc = "Большая дубовая бочка. Можно использовать для брожения фруктов или просто хранения жидкостей."
	icon = 'icons/obj/objects.dmi'
	icon_state = "barrel"
	density = TRUE
	anchored = TRUE
	pressure_resistance = 2 * ONE_ATMOSPHERE
	var/speed_multiplier = 1 //How fast it distills. Defaults to 100% (1.0). Lower is better.

/obj/structure/fermenting_barrel/get_ru_names()
	return alist(
		NOMINATIVE = "деревянная бочка",
		GENITIVE = "деревянной бочки",
		DATIVE = "деревянной бочке",
		ACCUSATIVE = "деревянную бочку",
		INSTRUMENTAL = "деревянной бочкой",
		PREPOSITIONAL = "деревянной бочке",
	)

/obj/structure/fermenting_barrel/Initialize(mapload)
	. = ..()
	create_reagents(300, DRAINABLE | REFILLABLE | AMOUNT_VISIBLE) //Bluespace beakers, but without the portability or efficiency in circuits.

/obj/structure/fermenting_barrel/add_debris_element()
	generate_debris_handler(DEBRIS_WOOD, -40, 5)

/obj/structure/fermenting_barrel/proc/makeWine(obj/item/reagent_containers/food/snacks/grown/G)
	if(G.reagents)
		G.reagents.trans_to(src, G.reagents.total_volume)
	var/amount = G.seed.potency / 4
	if(G.distill_reagent)
		reagents.add_reagent(G.distill_reagent, amount)
	else
		var/data = list()
		data["names"] = list("[initial(G.name)]" = 1)
		data["color"] = G.filling_color
		data["alcohol_perc"] = G.wine_power
		if(G.wine_flavor)
			data["tastes"] = list(G.wine_flavor = 1)
		else
			data["tastes"] = list(G.tastes[1] = 1)
		reagents.add_reagent("fruit_wine", amount, data)
	qdel(G)
	playsound(src, 'sound/effects/bubbles.ogg', 50, TRUE)

/obj/structure/fermenting_barrel/attackby(obj/item/I, mob/user, params)
	if(istype(I, /obj/item/reagent_containers/food/snacks/grown))
		add_fingerprint(user)
		var/obj/item/reagent_containers/food/snacks/grown/grown = I
		if(!grown.can_distill)
			to_chat(user, span_warning("Вы не можете перегнать [grown.declent_ru(ACCUSATIVE)] во что-то полезное."))
			return ATTACK_CHAIN_PROCEED
		if(!user.drop_transfer_item_to_loc(grown, src))
			return ..()
		to_chat(user, span_notice("Вы положили [grown.declent_ru(ACCUSATIVE)] в [declent_ru(ACCUSATIVE)] для брожения."))
		addtimer(CALLBACK(src, PROC_REF(makeWine), grown), rand(8 SECONDS, 12 SECONDS) * speed_multiplier)
		return ATTACK_CHAIN_BLOCKED_ALL

	if(I.is_refillable())
		return ATTACK_CHAIN_PROCEED // To refill via afterattack proc

	return ..()

/obj/structure/fermenting_barrel/crowbar_act(mob/living/user, obj/item/I)
	. = TRUE
	if(!I.use_tool(src, user, 0))
		return
	TOOL_ATTEMPT_DISMANTLE_MESSAGE
	if(I.use_tool(src, user, 50, volume = I.tool_volume))
		TOOL_DISMANTLE_SUCCESS_MESSAGE
		deconstruct(disassembled = TRUE)

/obj/structure/fermenting_barrel/wrench_act(mob/living/user, obj/item/I)
	. = TRUE
	default_unfasten_wrench(user, I, time = 20)

/obj/structure/fermenting_barrel/deconstruct(disassembled = FALSE)
	var/mat_drop = 15
	if(disassembled)
		mat_drop = 30
	new /obj/item/stack/sheet/wood(drop_location(), mat_drop)
	..()

/datum/crafting_recipe/fermenting_barrel
	name = "Wooden Barrel"
	result = /obj/structure/fermenting_barrel
	reqs = list(/obj/item/stack/sheet/wood = 30)
	time = 50
	category = CAT_PRIMAL
	subcategory = CAT_MISC2
