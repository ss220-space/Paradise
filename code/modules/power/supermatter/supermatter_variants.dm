/// Normal SM designated as main engine.
/obj/machinery/power/supermatter_crystal/engine
	is_main_engine = TRUE

/// Shard SM.
/obj/machinery/power/supermatter_crystal/shard
	name = "supermatter shard"
	desc = "Странно полупрозрачный и переливающийся кристалл, который выглядит так, будто когда-то был частью более крупной структуры."
	base_icon_state = "sm_shard"
	icon_state = "sm_shard"
	anchored = FALSE
	absorption_ratio = 0.125
	explosion_power = 12
	layer = ABOVE_MOB_LAYER
	moveable = TRUE

/obj/machinery/power/supermatter_crystal/shard/get_ru_names()
	return list(
		NOMINATIVE = "осколок суперматерии",
		GENITIVE = "осколка суперматерии",
		DATIVE = "осколку суперматерии",
		ACCUSATIVE = "осколок суперматерии",
		INSTRUMENTAL = "осколком суперматерии",
		PREPOSITIONAL = "осколке суперматерии"
	)

/obj/machinery/power/supermatter_crystal/shard/Initialize(mapload)
	. = ..()
	register_context()

/obj/machinery/power/supermatter_crystal/shard/add_context(atom/source, list/context, obj/item/held_item, mob/user)
	. = ..()
	if(held_item?.tool_behaviour == TOOL_WRENCH)
		context[SCREENTIP_CONTEXT_LMB] = anchored ? "Unanchor" : "Anchor"
		return CONTEXTUAL_SCREENTIP_SET

/// Shard SM designated as the main engine.
/obj/machinery/power/supermatter_crystal/shard/engine
	name = "anchored supermatter shard"
	is_main_engine = TRUE
	anchored = TRUE
	moveable = FALSE

/obj/machinery/power/supermatter_crystal/shard/engine/get_ru_names()
	return list(
		NOMINATIVE = "закрепленный осколок суперматерии",
		GENITIVE = "закрепленного осколка суперматерии",
		DATIVE = "закрепленному осколку суперматерии",
		ACCUSATIVE = "закрепленный осколок суперматерии",
		INSTRUMENTAL = "закрепленным осколком суперматерии",
		PREPOSITIONAL = "закрепленном осколке суперматерии"
	)

/// When you wanna make a supermatter shard for the dramatic effect, but don't want it exploding suddenly
/obj/machinery/power/supermatter_crystal/shard/hugbox
	name = "anchored supermatter shard"
	disable_damage = TRUE
	disable_gas =  TRUE
	disable_power_change = TRUE
	disable_process = SM_PROCESS_DISABLED
	moveable = FALSE
	anchored = TRUE

/obj/machinery/power/supermatter_crystal/shard/hugbox/get_ru_names()
	return list(
		NOMINATIVE = "закрепленный осколок суперматерии",
		GENITIVE = "закрепленного осколка суперматерии",
		DATIVE = "закрепленному осколку суперматерии",
		ACCUSATIVE = "закрепленный осколок суперматерии",
		INSTRUMENTAL = "закрепленным осколком суперматерии",
		PREPOSITIONAL = "закрепленном осколке суперматерии"
	)
