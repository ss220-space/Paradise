/obj/item/implant/heal
	name = "heal bio-chip"
	desc = "Heal overall damage."
	icon_state = "heal"
	implant_state = "implant-syndicate"
	origin_tech = "materials=2;biotech=4;combat=3;syndicate=2"
	implant_data = /datum/implant_fluff/heal
	actions_types = null
	base_cooldown = 120 SECONDS

/obj/item/implant/heal/Initialize(mapload)
	. = ..()
	if(!action)
		action = new(src)

/obj/item/implant/heal/Destroy()
	. = ..()
	QDEL_NULL(action)

/obj/item/implant/heal/can_implant(mob/source, mob/user)
	if(HAS_TRAIT(source, TRAIT_NO_HUNGER))
		return FALSE
	return ..()

/obj/item/implant/heal/implant(mob/living/carbon/human/source, mob/user, force)
	. = ..()
	if(.)
		add_item_action(action)

/obj/item/implant/heal/create_new_cooldown()
	var/datum/implant_cooldown/charges/charges_cooldown = new
	charges_cooldown.max_charges = 2
	charges_cooldown.recharge_duration = base_cooldown
	charges_cooldown.charge_duration = 1 SECONDS
	return charges_cooldown

/obj/item/implant/heal/activate()
	var/datum/implant_cooldown/charges/charges_cooldown = cooldown_system

	if(charges_cooldown.is_on_cooldown())
		return FALSE

	if(charges_cooldown.current_charges <= 0)
		balloon_alert(imp_in, "нет зарядов")
		return FALSE

	if(uses != -1 && uses <= 0)
		return FALSE

	charges_cooldown.start_recharge()
	balloon_alert(imp_in, "вы чувствуете облегчение")
	imp_in.reagents.add_reagent("epinephrine", 5)
	imp_in.reagents.add_reagent("traneksam_acid", 5)
	imp_in.apply_status_effect(/datum/status_effect/heal)
	imp_in.adjust_nutrition(-150)
	return TRUE

/obj/item/implanter/heal
	name = "bio-chip implanter (heal)"
	imp = /obj/item/implant/heal

/obj/item/implantcase/heal
	name = "bio-chip case - 'Heal'"
	desc = "A glass case containing an heal bio-chip."
	imp = /obj/item/implant/heal
