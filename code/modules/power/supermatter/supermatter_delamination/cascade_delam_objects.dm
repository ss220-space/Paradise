/obj/crystal_mass
	name = "crystal mass"
	desc = "You see this massive crystal mass looming towards you, cracking and screeching at every seemingly random movement."
	icon = 'icons/turf/walls.dmi'
	icon_state = "crystal_cascade_1"
	layer = AREA_LAYER
	plane = ABOVE_LIGHTING_PLANE
	density = TRUE
	anchored = TRUE
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | UNACIDABLE | ACID_PROOF | FREEZE_PROOF
	light_range = 5
	light_color = COLOR_VIVID_YELLOW
	light_system = MOVABLE_LIGHT
	move_resist = INFINITY
	var/list/possible_dirs
	///Cooldown on the expansion process
	COOLDOWN_DECLARE(sm_wall_cooldown)

/obj/crystal_mass/ComponentInitialize()
	AddElement(/datum/element/supermatter_crystal, null, null)

/obj/crystal_mass/Initialize(mapload, dir_to_remove)
	. = ..()
	icon_state = "crystal_cascade_[rand(1,6)]"
	START_PROCESSING(SSsupermatter_cascade, src)
	playsound(src, 'sound/misc/cracking_crystal.ogg', 45, TRUE)

	var/turf/our_turf = get_turf(src)

	if(our_turf)
		our_turf.opacity = FALSE
		possible_dirs = is_multi_z_level(our_turf.z)? GLOB.cardinals_multiz.Copy() : GLOB.cardinal.Copy()
		possible_dirs -= dir_to_remove

	// Ideally this'd be part of the SM component, but the SM itself snowflakes bullets (emitters are bullets).
	RegisterSignal(src, COMSIG_ATOM_BULLET_ACT, PROC_REF(eat_bullets))

/obj/crystal_mass/process()

	if(!COOLDOWN_FINISHED(src, sm_wall_cooldown))
		return


	COOLDOWN_START(src, sm_wall_cooldown, rand(0, 3 SECONDS))

	if(!possible_dirs)
		return PROCESS_KILL

	var/picked_dir = pick_n_take(possible_dirs)

	if(!picked_dir)
		possible_dirs = null
		return PROCESS_KILL

	var/turf/next_turf = get_step_multiz(src, picked_dir)

	icon_state = "crystal_cascade_[rand(1,6)]"

	if(!next_turf || (locate(/obj/crystal_mass) in next_turf))
		return

	for(var/atom/movable/checked_atom as anything in next_turf)
		if(isliving(checked_atom))
			SEND_SIGNAL(\
				src, \
				COMSIG_CRYSTAL_MASS_CONSUME,\
				checked_atom, \
				span_danger("\The [src] lunges out on [checked_atom], touching [checked_atom.p_them()]... [checked_atom.p_their()] body begins to shine with a brilliant light before crystallizing from the inside out and joining \the [src]!"),\
				span_userdanger("The crystal mass lunges on you and hits you in the chest. As your vision is filled with a blinding light, you think to yourself \"Damn it.\"")\
			)
		else if(istype(checked_atom, /obj/cascade_portal))
			checked_atom.visible_message(span_userdanger("\The [checked_atom] screeches and closes away as it is hit by \a [src]! Too late!"))
			var/turf/location = get_turf(checked_atom)
			playsound(location, 'sound/magic/charge.ogg', 50, TRUE)
			playsound(location, 'sound/effects/supermatter.ogg', 50, TRUE)
			qdel(checked_atom)
		else if(isitem(checked_atom))
			playsound(get_turf(checked_atom), 'sound/effects/supermatter.ogg', 50, TRUE)
			qdel(checked_atom)
		else if(iscloset(checked_atom))
			playsound(get_turf(checked_atom), 'sound/effects/supermatter.ogg', 50, TRUE)
			qdel(checked_atom, TRUE)

	new /obj/crystal_mass(next_turf, get_dir_multiz(next_turf, src))

/obj/crystal_mass/proc/eat_bullets(datum/source, obj/projectile/hitting_projectile)
	SIGNAL_HANDLER

	visible_message(
		span_warning("[hitting_projectile] flies into [src] with a loud crack, before rapidly flashing into ash."),
		null,
		span_hear("You hear a loud crack as you are washed with a wave of heat."),
	)

	playsound(src, 'sound/effects/supermatter.ogg', 50, TRUE)
	qdel(hitting_projectile)

/obj/crystal_mass/singularity_act()
	return

/obj/crystal_mass/attack_tk(mob/user)
	if(!iscarbon(user))
		return
	var/mob/living/carbon/jedi = user
	to_chat(jedi, span_userdanger("That was a really dense idea."))
	jedi.ghostize()
	var/obj/item/organ/internal/brain/rip_u = jedi.get_int_organ(/obj/item/organ/internal/brain)
	if(rip_u)
		rip_u.remove(jedi)
		qdel(rip_u)
	return COMPONENT_CANCEL_ATTACK_CHAIN

/obj/crystal_mass/Destroy()
	STOP_PROCESSING(SSsupermatter_cascade, src)
	return ..()

/obj/crystal_mass/attack_ai(mob/user)
	return


/obj/cascade_portal
	name = "bluespace rift"
	desc = "Your mind begins to spin as it tries to comprehend what it sees."
	icon = 'icons/effects/224x224.dmi'
	icon_state = "reality"
	anchored = TRUE
	appearance_flags = LONG_GLIDE
	density = TRUE
	plane = MASSIVE_OBJ_PLANE
	light_color = COLOR_RED
	light_power = 0.7
	light_range = 15
	move_resist = INFINITY
	pixel_x = -96
	pixel_y = -96
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | UNACIDABLE | ACID_PROOF | FREEZE_PROOF

/obj/cascade_portal/Initialize(mapload)
	. = ..()
	var/turf/location = get_turf(src)
	var/area_name = get_area_name(src)
	message_admins("Exit rift created at [area_name]. [ADMIN_VERBOSEJMP(location)]")
	log_game("Bluespace Exit Rift was created at [area_name].")
	investigate_log("created at [area_name].", INVESTIGATE_ENGINE)

/obj/cascade_portal/Destroy(force)
	var/turf/location = get_turf(src)
	var/area_name = get_area_name(src)
	message_admins("Exit rift at [area_name] deleted. [ADMIN_VERBOSEJMP(location)]")
	log_game("Bluespace Exit Rift at [area_name] was deleted.")
	investigate_log("was deleted.", INVESTIGATE_ENGINE)
	return ..()

/obj/cascade_portal/Bumped(atom/movable/hit_object)
	consume(hit_object)
	new /obj/effect/particle_effect/sparks(loc)
	playsound(loc, SFX_SPARKS, 50, TRUE, SHORT_RANGE_SOUND_EXTRARANGE)

/**
 * Proc to consume the objects colliding with the portal
 *
 * Arguments: atom/movable/consumed_object is the object hitting the portal
 */
/obj/cascade_portal/proc/consume(atom/movable/consumed_object)
	if(isliving(consumed_object))
		consumed_object.visible_message(
			span_danger("\The [consumed_object] walks into \the [src]... A blinding light covers [consumed_object.p_their()] body before disappearing completely!"),
			span_userdanger("You walk into \the [src] as your body is washed with a powerful blue light. You contemplate about this decision before landing face first onto the cold, hard floor."),
			span_hear("You hear a loud crack as a distortion passes through you."),
		)

		var/list/arrival_turfs = get_area_turfs(/area/centcom/evac)
		var/turf/arrival_turf
		do
			arrival_turf = pick_n_take(arrival_turfs)
		while(!is_safe_turf(arrival_turf))

		var/mob/living/consumed_mob = consumed_object
		message_admins("[key_name_admin(consumed_mob)] has entered [src] [ADMIN_VERBOSEJMP(src)].")
		investigate_log("was entered by [key_name(consumed_mob)].", INVESTIGATE_ENGINE)
		consumed_mob.forceMove(arrival_turf)
		consumed_mob.Paralyse(100)
		consumed_mob.adjustBruteLoss(30)
		consumed_mob.flash_eyes(1, TRUE, TRUE)

		new /obj/effect/particle_effect/sparks(consumed_object)
		playsound(consumed_object, SFX_SPARKS, 50, TRUE, SHORT_RANGE_SOUND_EXTRARANGE)
	else if(isitem(consumed_object))
		consumed_object.visible_message(span_danger("\The [consumed_object] smacks into \the [src] and disappears out of sight."), null,
			span_hear("You hear a loud crack as a small distortion passes through you."))

		qdel(consumed_object)
