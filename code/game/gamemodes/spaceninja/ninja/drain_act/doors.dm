/obj/machinery/door/ninjadrain_act(obj/item/clothing/suit/space/space_ninja/ninja_suit, mob/living/carbon/human/ninja, obj/item/clothing/gloves/space_ninja/ninja_gloves)
	if(!ninja_suit || !ninja || !ninja_gloves || drain_act_protected)
		return INVALID_DRAIN
	if(is_admin_level(src.z))
		to_chat(ninja, span_warning("Не стоит взламывать двери здесь!"))
		return INVALID_DRAIN
	if(!operating && density && hasPower() && !(on_blueprints & emagged))
		emag_act()
