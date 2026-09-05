///Proxy element that attaches components, elements and traits that are common to more or less all nullrods.
/datum/element/nullrod_core

/**
 * Called when the element is added to a datum. If the 'chaplain_spawnable' arg is TRUE and unit testing is enabled,
 * we check that the target is actually in the nullrod_variants global list
 */
/datum/element/nullrod_core/Attach(obj/item/target, chaplain_spawnable = TRUE, rune_remove_line = "BEGONE FOUL MAGIKS!!")
	. = ..()
	if(!istype(target))
		return ELEMENT_INCOMPATIBLE
	target.AddComponent(/datum/component/anti_magic, MAGIC_RESISTANCE|MAGIC_RESISTANCE_HOLY)
/*
	target.AddComponent(/datum/component/effect_remover, \
		success_feedback = "You disrupt the magic of %THEEFFECT with %THEWEAPON.", \
		success_forcesay = rune_remove_line, \
		tip_text = "Clear rune", \
		on_clear_callback = CALLBACK(src, PROC_REF(on_cult_rune_removed), target), \
		effects_we_clear = list(/obj/effect/rune), \
	)

	target.AddComponent(/datum/component/cult_kill_tracker)
	target.AddComponent(/datum/component/bane, affected_biotypes = MOB_SPIRIT, added_damage = 25)
*/
	ADD_TRAIT(target, TRAIT_NULLROD_ITEM, ELEMENT_TRAIT(type))

	if(!GLOB.nullrod_variants[target.type])
		stack_trace("[target.type] is absent from the nullrod_variants global list. Please include it.")
