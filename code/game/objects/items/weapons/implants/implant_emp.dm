/obj/item/implant/emp
	name = "emp bio-chip"
	desc = "Triggers an EMP."
	icon_state = "emp_old"
	origin_tech = "biotech=3;magnets=4;syndicate=1"
	activated = BIOCHIP_ACTIVATED_ACTIVE
	uses = 2
	implant_data = /datum/implant_fluff/emp
	implant_state = "implant-syndicate"


/obj/item/implant/emp/activate()
	uses--
	INVOKE_ASYNC(GLOBAL_PROC, /proc/empulse, get_turf(imp_in), 3, 5, TRUE, name)
	if(!uses)
		qdel(src)


/obj/item/implanter/emp
	name = "bio-chip implanter (EMP)"
	imp = /obj/item/implant/emp


/obj/item/implantcase/emp
	name = "bio-chip case - 'EMP'"
	desc = "A glass case containing an EMP bio-chip."
	imp = /obj/item/implant/emp

