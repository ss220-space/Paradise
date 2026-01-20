/obj/item/implant/emergency_reboot
	name = "emergency_reboot bio-cheap"
	desc = "Removes all stuns and knockdowns."
	icon_state = "adrenal"
	implant_state = "implant-syndicate"
	origin_tech = "materials=2;biotech=4;combat=3;syndicate=2"
	implant_data = /datum/implant_fluff/emergency_reboot
	actions_types = null
	base_cooldown = 50 SECONDS

/obj/item/implant/emergency_reboot/Initialize(mapload)
	. = ..()
	if(!action)
		action = new /datum/action/item_action/hands_free/activate(src)

/obj/item/implant/emergency_reboot/Destroy()
	. = ..()
	QDEL_NULL(action)

/obj/item/implant/emergency_reboot/implant(mob/living/carbon/human/source, mob/user, force)
	add_item_action(action)
	. = ..()

/obj/item/implant/emergency_reboot/create_new_cooldown()
	var/datum/implant_cooldown/charges/C = new
	C.max_charges = 3
	C.recharge_duration = base_cooldown
	C.charge_duration = 1 SECONDS
	return C

/obj/item/implant/emergency_reboot/activate()
	var/datum/implant_cooldown/charges/charges_cooldown = cooldown_system

	if(charges_cooldown.is_on_cooldown())
		return FALSE

	if(charges_cooldown.current_charges <= 0)
		balloon_alert(imp_in, "нет зарядов")
		return FALSE

	if(uses != -1 && uses <= 0)
		return FALSE

	charges_cooldown.start_recharge()
	balloon_alert(imp_in, "вы чувствуете резкий прилив сил")

	imp_in.SetStunned(0)
	imp_in.SetWeakened(0)
	imp_in.SetKnockdown(0)
	imp_in.SetImmobilized(0)
	imp_in.SetParalysis(0)
	imp_in.setStaminaLoss(0)
	imp_in.SetConfused(0)
	imp_in.set_resting(FALSE, instant = TRUE)
	imp_in.get_up(instant = TRUE)

	imp_in.adjust_nutrition(-20)

	return TRUE

/obj/item/implanter/emergency_reboot
	name = "bio-chip implanter (emergency emergency_reboot)"
	imp = /obj/item/implant/emergency_reboot

/obj/item/implantcase/emergency_reboot
	name = "bio-chip case - emergency emergency_reboot"
	desc = "A glass case containing an emergency_reboot bio-chip."
	imp = /obj/item/implant/emergency_reboot


