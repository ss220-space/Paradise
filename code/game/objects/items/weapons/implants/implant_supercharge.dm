/obj/item/implant/supercharge
	name = "supercharge bio-chip"
	desc = "Removes all stuns and knockdowns."
	icon_state = "adrenal_old"
	implant_state = "implant-syndicate"
	origin_tech = "materials=3;combat=5;syndicate=2"
	activated = BIOCHIP_ACTIVATED_ACTIVE
	uses = 3
	implant_data = /datum/implant_fluff/adrenaline


/obj/item/implant/supercharge/activate(cause)
	uses--
	to_chat(imp_in, span_notice("You feel an electric sensation as your components enter overdrive!"))
	imp_in.SetStunned(0)
	imp_in.SetWeakened(0)
	imp_in.SetImmobilized(0)
	imp_in.SetParalysis(0)
	imp_in.adjustStaminaLoss(-100)
	imp_in.lying = 0
	imp_in.update_canmove()

	imp_in.reagents.add_reagent("surge_plus", 10)
	imp_in.reagents.add_reagent("liquid_solder", 10)
	imp_in.reagents.add_reagent("combatlube", 10)

	if(!uses)
		qdel(src)


/obj/item/implanter/supercharge
	name = "bio-chip implanter (supercharge)"
	imp = /obj/item/implant/supercharge


/obj/item/implantcase/supercharge
	name = "bio-chip case - 'supercharge'"
	desc = "A glass case containing an supercharge bio-chip."
	imp = /obj/item/implant/supercharge

