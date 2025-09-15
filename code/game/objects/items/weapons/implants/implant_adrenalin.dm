/obj/item/implant/adrenalin
	name = "adrenal bio-chip"
	desc = "Removes all stuns and knockdowns."
	icon_state = "adrenal_old"
	implant_state = "implant-syndicate"
	origin_tech = "materials=2;biotech=4;combat=3;syndicate=2"
	activated = BIOCHIP_ACTIVATED_ACTIVE
	implant_data = /datum/implant_fluff/adrenaline
	actions_types = null
	base_cooldown = 120 SECONDS

/obj/item/implant/adrenalin/Initialize(mapload)
	. = ..()
	if(!action)
		action = new(src)

/obj/item/implant/adrenalin/Destroy()
	. = ..()
	QDEL_NULL(action)

/obj/item/implant/adrenalin/create_new_cooldown()
	var/datum/implant_cooldown/charges/C = new
	C.max_charges = 2
	C.recharge_duration = base_cooldown
	C.charge_duration = 1 SECONDS
	return C

/obj/item/implant/adrenalin/activate()
	var/datum/implant_cooldown/charges/charges_cooldown = cooldown_system

	if(charges_cooldown.is_on_cooldown())
		return FALSE

	if(charges_cooldown.current_charges <= 0)
		balloon_alert(imp_in, "нет зарядов")
		return FALSE

	if(uses != -1 && uses <= 0)
		return FALSE

	charges_cooldown.start_recharge()
	balloon_alert(imp_in, "энергия переполняет тебя")

	imp_in.SetStunned(0)
	imp_in.SetWeakened(0)
	imp_in.SetKnockdown(0)
	imp_in.SetImmobilized(0)
	imp_in.SetParalysis(0)
	imp_in.setStaminaLoss(0)
	imp_in.set_resting(FALSE, instant = TRUE)
	imp_in.get_up(instant = TRUE)

	imp_in.reagents.add_reagent("synaptizine", 5)
	imp_in.reagents.add_reagent("omnizine", 5)
	imp_in.reagents.add_reagent("stimulative_agent", 5)
	imp_in.reagents.add_reagent("adrenaline", 3)

	imp_in.apply_status_effect(/datum/status_effect/adrenaline)

	imp_in.AdjustBlood(-67.2)
	imp_in.adjust_nutrition(-150)

	return TRUE


/obj/item/implanter/adrenalin
	name = "bio-chip implanter (adrenalin)"
	imp = /obj/item/implant/adrenalin

/obj/item/implantcase/adrenaline
	name = "bio-chip case - 'Adrenaline'"
	desc = "A glass case containing an adrenaline bio-chip."
	imp = /obj/item/implant/adrenalin

/obj/item/implant/adrenalin/prototype
	name = "prototype adrenalin bio-chip"
	desc = "Use it to escape child support. Works only once!"
	origin_tech = "combat=5;magnets=3;biotech=3;syndicate=1"
	implant_data = /datum/implant_fluff/protoadrenaline
	uses = 1

/obj/item/implant/adrenalin/prototype/activate()
	uses--

	balloon_alert(imp_in, "энергия переполняет тебя")

	imp_in.SetStunned(0)
	imp_in.SetWeakened(0)
	imp_in.SetKnockdown(0)
	imp_in.SetImmobilized(0)
	imp_in.SetParalysis(0)
	imp_in.setStaminaLoss(0)
	imp_in.set_resting(FALSE, instant = TRUE)
	imp_in.get_up(instant = TRUE)

	imp_in.reagents.add_reagent("synaptizine", 5)
	imp_in.reagents.add_reagent("omnizine", 5)
	imp_in.reagents.add_reagent("stimulative_agent", 5)
	imp_in.reagents.add_reagent("adrenaline", 3)

	imp_in.apply_status_effect(/datum/status_effect/adrenaline)

	if(!uses)
		qdel(src)

/obj/item/implanter/adrenalin/prototype
	name = "bio-chip implanter (proto-adrenalin)"
	imp = /obj/item/implant/adrenalin/prototype

/obj/item/implantcase/adrenalin/prototype
	name = "bio-chip case - 'Proto-Adrenalin'"
	desc = "A glass case containing a prototype adrenalin bio-chip."
	imp = /obj/item/implant/adrenalin/prototype

