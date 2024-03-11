/mob/living/carbon/human/gib()
	if(!death(TRUE) && stat != DEAD)
		return FALSE
	var/atom/movable/overlay/animation = null
	notransform = 1
	canmove = FALSE
	icon = null
	invisibility = INVISIBILITY_ABSTRACT
	if(!ismachineperson(src))
		animation = new(loc)
		animation.icon_state = "blank"
		animation.icon = 'icons/mob/mob.dmi'
		animation.master = src

		playsound(src.loc, 'sound/goonstation/effects/gib.ogg', 50, 1)
	else
		playsound(src.loc, 'sound/goonstation/effects/robogib.ogg', 50, 1)

	var/drop_loc = drop_location()
	for(var/obj/item/organ/internal/organ as anything in internal_organs)
		var/atom/movable/thing = organ.remove(src)
		if(!QDELETED(thing))
			thing.forceMove(drop_loc)
			if(isturf(thing.loc))
				thing.throw_at(get_edge_target_turf(src, pick(GLOB.alldirs)), rand(1,3), 5)

	for(var/obj/item/organ/external/bodypart as anything in bodyparts)
		if(istype(bodypart, /obj/item/organ/external/chest))
			continue
		// Only make the limb drop if it's not too damaged
		if(prob(100 - bodypart.get_damage()))
			// Override the current limb status and don't cause an explosion
			bodypart.droplimb()

	for(var/mob/M in src)
		LAZYREMOVE(stomach_contents, M)
		M.forceMove(drop_loc)
		visible_message("<span class='danger'>[M] bursts out of [src]!</span>")

	if(!ismachineperson(src))
		flick("gibbed-h", animation)
		hgibs(loc, dna)
	else
		new /obj/effect/decal/cleanable/blood/gibs/robot(loc)
		do_sparks(3, 1, src)
	QDEL_IN(animation, 15)
	QDEL_IN(src, 0)
	return TRUE

/mob/living/carbon/human/dust()
	if(!death(TRUE) && stat != DEAD)
		return FALSE
	notransform = 1
	canmove = FALSE
	icon = null
	invisibility = INVISIBILITY_ABSTRACT
	dust_animation()
	QDEL_IN(src, 0)
	return TRUE

/mob/living/carbon/human/dust_animation()
	var/atom/movable/overlay/animation = null

	animation = new(loc)
	animation.icon_state = "blank"
	animation.icon = 'icons/mob/mob.dmi'
	animation.master = src

	flick("dust-h", animation)
	new dna.species.remains_type(get_turf(src))
	QDEL_IN(animation, 15)
	return TRUE

/mob/living/carbon/human/melt()
	if(!death(TRUE) && stat != DEAD)
		return FALSE
	var/atom/movable/overlay/animation = null
	notransform = 1
	canmove = FALSE
	icon = null
	invisibility = INVISIBILITY_ABSTRACT

	animation = new(loc)
	animation.icon_state = "blank"
	animation.icon = 'icons/mob/mob.dmi'
	animation.master = src

	flick("liquify", animation)
	QDEL_IN(src, 0)
	QDEL_IN(animation, 15)
	//new /obj/effect/decal/remains/human(loc)
	return TRUE

/mob/living/carbon/human/death(gibbed)

	// Only execute the below if we successfully died
	. = ..(gibbed)
	if(!.)
		return FALSE

	set_heartattack(FALSE)
	SSmobs.cubemonkeys -= src
	if(dna.species)
		//Handle species-specific deaths.
		dna.species.handle_death(gibbed, src)

	if(SSticker && SSticker.mode)
		SSblackbox.ReportDeath(src)


/mob/living/carbon/human/update_revive(updating, defib_revive)
	. = ..()
	if(. && healthdoll)
		// We're alive again, so re-build the entire healthdoll
		healthdoll.cached_healthdoll_overlays.Cut()
		update_health_hud()
		update_stamina_hud()
	// Update healthdoll
	if(dna.species)
		dna.species.update_sight(src)


/mob/living/carbon/human/proc/makeSkeleton()
	var/obj/item/organ/external/head/head_organ = get_organ(BODY_ZONE_HEAD)
	if(SKELETON in mutations)
		return

	if(head_organ)
		head_organ.disfigure()
		if(head_organ.f_style)
			head_organ.f_style = initial(head_organ.f_style)
		if(head_organ.h_style)
			head_organ.h_style = initial(head_organ.h_style)
		if(head_organ.ha_style)
			head_organ.ha_style = initial(head_organ.ha_style)
		if(head_organ.alt_head)
			head_organ.alt_head = initial(head_organ.alt_head)
			head_organ.handle_alt_icon()
	m_styles = DEFAULT_MARKING_STYLES
	update_fhair()
	update_hair()
	update_head_accessory()
	update_markings()

	mutations.Add(SKELETON)
	mutations.Add(NOCLONE)
	update_body()
	update_mutantrace()


/mob/living/carbon/human/proc/ChangeToHusk()

	// If the target has no DNA to begin with, its DNA can't be damaged beyond repair.
	if(NO_DNA in dna.species.species_traits)
		return
	if(HUSK in mutations)
		return

	var/obj/item/organ/external/head/head_organ = get_organ(BODY_ZONE_HEAD)
	if(head_organ)
		head_organ.disfigure()	//makes them unknown without fucking up other stuff like admintools
		if(head_organ.f_style)
			head_organ.f_style = "Shaved"		//we only change the icon_state of the hair datum, so it doesn't mess up their UI/UE
		if(head_organ.h_style)
			head_organ.h_style = "Bald"
	update_fhair()
	update_hair()

	mutations.Add(HUSK)
	update_body()
	update_mutantrace()


/mob/living/carbon/human/proc/Drain()
	ChangeToHusk()
	mutations |= NOCLONE


/mob/living/carbon/human/proc/cure_husk()
	mutations.Remove(HUSK)
	var/obj/item/organ/external/head/head_organ = get_organ(BODY_ZONE_HEAD)
	head_organ?.disfigure()
	update_body()
	update_mutantrace()
	UpdateAppearance() // reset hair from DNA

