// Ported from TG
/obj/item/paperplane
	name = "paper plane"
	desc = "Paper, folded in the shape of a plane."
	icon = 'icons/obj/bureaucracy.dmi'
	icon_state = "paperplane"
	throw_range = 7
	throw_speed = 1
	throwforce = 0
	w_class = WEIGHT_CLASS_TINY
	resistance_flags = FLAMMABLE
	max_integrity = 50
	no_spin_thrown = TRUE

	var/obj/item/paper/internal_paper


/obj/item/paperplane/New(loc, obj/item/paper/new_paper)
	..()
	pixel_y = rand(-8, 8)
	pixel_x = rand(-9, 9)
	if(new_paper)
		internal_paper = new_paper
		flags = new_paper.flags
		color = new_paper.color
		new_paper.forceMove(src)
	else
		internal_paper = new /obj/item/paper(src)
	update_icon(UPDATE_OVERLAYS)


/obj/item/paperplane/Destroy()
	QDEL_NULL(internal_paper)
	return ..()


/obj/item/paperplane/suicide_act(mob/living/user)
	user.Stun(20 SECONDS)
	user.visible_message("<span class='suicide'>[user] jams [name] in [user.p_their()] nose. It looks like [user.p_theyre()] trying to commit suicide!</span>")
	user.EyeBlurry(12 SECONDS)
	var/obj/item/organ/internal/eyes/E = user.get_int_organ(/obj/item/organ/internal/eyes)
	if(E)
		E.take_damage(8, 1)
	sleep(10)
	return BRUTELOSS


/obj/item/paperplane/update_overlays()
	. = ..()
	var/list/stamped = internal_paper.stamped
	if(LAZYLEN(stamped))
		for(var/obj/item/stamp/stamp_path as anything in stamped)
			. += "paperplane_[initial(stamp_path.icon_state)]"


/obj/item/paperplane/attack_self(mob/user) // Unfold the paper plane
	to_chat(user, "<span class='notice'>You unfold [src].</span>")
	if(internal_paper)
		internal_paper.forceMove(get_turf(src))
		user.put_in_hands(internal_paper)
		internal_paper = null
		qdel(src)


/obj/item/paperplane/attackby(obj/item/I, mob/living/user, params)
	if(resistance_flags & ON_FIRE)
		return ATTACK_CHAIN_BLOCKED_ALL

	if(is_pen(I) || istype(I, /obj/item/toy/crayon))
		add_fingerprint(user)
		to_chat(user, span_warning("You should unfold [src] before changing it."))
		return ATTACK_CHAIN_PROCEED

	if(istype(I, /obj/item/stamp)) 	//we don't randomize stamps on a paperplane
		add_fingerprint(user)
		internal_paper.attackby(I, user, params) //spoofed attack to update internal paper.
		update_icon(UPDATE_OVERLAYS)
		return ATTACK_CHAIN_PROCEED_SUCCESS

	. = ..()
	if(ATTACK_CHAIN_CANCEL_CHECK(.) || !is_hot(I) || !Adjacent(user))
		return .

	. |= ATTACK_CHAIN_BLOCKED_ALL
	add_fingerprint(user)
	if(HAS_TRAIT(user, TRAIT_CLUMSY) && prob(10))
		user.visible_message(
			span_warning("[user] accidentally ignites [user.p_them()]self!"),
			span_userdanger("You miss the paperplane and accidentally light yourself on fire!"),
		)
		user.drop_item_ground(I)
		user.adjust_fire_stacks(1)
		user.IgniteMob()
		return .

	user.drop_item_ground(src)
	user.visible_message(
		span_danger("[user] lights [src] ablaze with [I]!"),
		span_danger("You light [src] on fire!"),
	)
	fire_act()


/obj/item/paperplane/throw_impact(atom/hit_atom, datum/thrownthing/throwingdatum)
	if(..())
		return
	if(!ishuman(hit_atom))
		return
	var/mob/living/carbon/human/H = hit_atom
	if(prob(2))
		if(H.head && H.head.flags_cover & HEADCOVERSEYES)
			return
		if(H.wear_mask && H.wear_mask.flags_cover & MASKCOVERSEYES)
			return
		if(H.glasses && H.glasses.flags_cover & GLASSESCOVERSEYES)
			return
		visible_message("<span class='danger'>[src] hits [H] in the eye!</span>")
		H.EyeBlurry(12 SECONDS)
		H.Weaken(4 SECONDS)
		var/obj/item/organ/internal/eyes/E = H.get_int_organ(/obj/item/organ/internal/eyes)
		if(E)
			E.take_damage(8, 1)
		H.emote("scream")


/obj/item/paper/proc/ProcFoldPlane(mob/living/carbon/user, obj/item/paper)
	if(ishuman(user))
		if(!Adjacent(user) || user.incapacitated())
			return
		to_chat(user, "<span class='notice'>You fold [src] into the shape of a plane!</span>")
		user.drop_item_ground(src)
		paper = new /obj/item/paperplane(user, src)
		user.put_in_hands(paper, ignore_anim = FALSE)
	else
		to_chat(user, "<span class='notice'>You lack the dexterity to fold [src].</span>")

