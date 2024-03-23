/obj/item/implant/adrenalin
	name = "adrenal bio-chip"
	desc = "Removes all stuns and knockdowns."
	icon_state = "adrenal_old"
	implant_state = "implant-syndicate"
	origin_tech = "materials=2;biotech=4;combat=3;syndicate=2"
	activated = BIOCHIP_ACTIVATED_ACTIVE
	implant_data = /datum/implant_fluff/adrenaline
	uses = 3


/obj/item/implant/adrenalin/activate()
	uses--
	to_chat(imp_in, span_notice("You feel an electric sensation as your components enter overdrive!"))
	imp_in.SetStunned(0)
	imp_in.SetWeakened(0)
	imp_in.SetImmobilized(0)
	imp_in.SetParalysis(0)
	imp_in.adjustStaminaLoss(-100)
	imp_in.lying = 0
	imp_in.update_canmove()

	imp_in.reagents.add_reagent("synaptizine", 10)
	imp_in.reagents.add_reagent("omnizine", 10)
	imp_in.reagents.add_reagent("stimulative_agent", 10)
	imp_in.reagents.add_reagent("adrenaline", 2)

	if(!uses)
		qdel(src)


/obj/item/implanter/adrenalin
	name = "bio-chip implanter (adrenalin)"
	imp = /obj/item/implant/adrenalin


/obj/item/implantcase/adrenaline
	name = "bio-chip case - 'Adrenaline'"
	desc = "A glass case containing an adrenaline bio-chip."
	imp = /obj/item/implant/adrenalin

