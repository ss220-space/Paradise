/obj/item/implantcase
	name = "bio-chip case"
	desc = "A glass case containing a bio-chip."
	icon = 'icons/obj/implants.dmi'
	icon_state = "implantcase"
	item_state = "implantcase"
	throw_speed = 2
	throw_range = 5
	w_class = WEIGHT_CLASS_TINY
	origin_tech = "materials=1;biotech=2"
	container_type = OPENCONTAINER|INJECTABLE|DRAWABLE
	materials = list(MAT_GLASS = 500)
	/// Path thats will be transformed into object on Initialize()
	var/obj/item/implant/imp


/obj/item/implantcase/Initialize(mapload)
	. = ..()
	if(ispath(imp, /obj/item/implant))
		imp = new imp(src)
	update_state()


/obj/item/implantcase/Destroy()
	if(imp)
		QDEL_NULL(imp)
	return ..()


/obj/item/implantcase/proc/update_state()
	if(imp)
		origin_tech = imp.origin_tech
		item_flags = imp.item_flags & ~DROPDEL
		reagents = imp.reagents
	else
		origin_tech = initial(origin_tech)
		item_flags = initial(item_flags)
		reagents = null
	update_icon(UPDATE_OVERLAYS)


/obj/item/implantcase/update_overlays()
	. = ..()
	if(imp)
		. += image('icons/obj/implants.dmi', imp.implant_state)


/obj/item/implantcase/attackby(obj/item/I, mob/user, params)
	if(is_pen(I))
		rename_interactive(user, I)
		return ATTACK_CHAIN_PROCEED_SUCCESS

	if(istype(I, /obj/item/implanter))
		add_fingerprint(user)
		var/obj/item/implanter/implater = I
		if(implater.imp)
			if(imp || implater.imp.implanted)
				return ATTACK_CHAIN_PROCEED
			implater.imp.forceMove(src)
			imp = implater.imp
			implater.imp = null
			update_state()
			implater.update_state()
			return ATTACK_CHAIN_PROCEED_SUCCESS
		if(imp)
			if(implater.imp)
				return ATTACK_CHAIN_PROCEED
			imp.forceMove(implater)
			implater.imp = imp
			imp = null
			update_state()
		implater.update_state()
		return ATTACK_CHAIN_PROCEED_SUCCESS

	return ..()

