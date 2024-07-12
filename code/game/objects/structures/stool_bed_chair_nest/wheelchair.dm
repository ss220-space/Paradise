/obj/structure/chair/wheelchair
	name = "wheelchair"
	desc = "You sit in this. Helps with traumas."
	base_icon_state = "wheelchair"
	icon_state = "wheelchair"
	item_chair = null
	movable = TRUE
	pull_push_slowdown = 1
	/// Overlay used to overlap buckled mob.
	var/mutable_appearance/chair_overlay
	/// If set we cannot go lower than this delay.
	var/lowest_move_delay = 0.4 SECONDS
	/// Currently applied skin, it contains path, not an instance.
	var/obj/item/fluff/rapid_wheelchair_kit/applied_skin
	COOLDOWN_DECLARE(wheelchair_move_delay)


/obj/structure/chair/wheelchair/Initialize(mapload)
	. = ..()
	ADD_TRAIT(src, TRAIT_NO_IMMOBILIZE, INNATE_TRAIT)
	chair_overlay = mutable_appearance(icon, "wheelchair_overlay", ABOVE_MOB_LAYER)
	update_icon(UPDATE_OVERLAYS)


/obj/structure/chair/wheelchair/Destroy()
	chair_overlay = null
	applied_skin = null
	return ..()


/obj/structure/chair/wheelchair/proc/on_skin_apply(obj/item/fluff/rapid_wheelchair_kit/kit, mob/user)
	if(applied_skin && applied_skin == kit.type)
		to_chat(user, span_warning("This [name] is already modified by [kit]!."))
		return

	to_chat(user, span_notice("You modify the appearance of [src]."))
	applied_skin = kit.type
	chair_overlay = mutable_appearance(icon, kit.new_overlay, ABOVE_MOB_LAYER)
	update_appearance()
	qdel(kit)


/obj/structure/chair/wheelchair/update_icon_state()
	icon_state = applied_skin ? initial(applied_skin.new_icon_state) : base_icon_state


/obj/structure/chair/wheelchair/update_overlays()
	. = ..()
	. += chair_overlay


/obj/structure/chair/wheelchair/update_name(updates = ALL)
	. = ..()
	name = applied_skin ? initial(applied_skin.new_name) : initial(name)


/obj/structure/chair/wheelchair/update_desc(updates = ALL)
	. = ..()
	desc = applied_skin ? initial(applied_skin.new_desc) : initial(desc)


/obj/structure/chair/wheelchair/handle_layer()
	return


/obj/structure/chair/wheelchair/relaymove(mob/user, direction)
	if(!COOLDOWN_FINISHED(src, wheelchair_move_delay))
		return FALSE
	var/turf/next_step = get_step(src, direction)
	if(!next_step || propelled || !Process_Spacemove(direction) || !has_gravity(loc) || !isturf(loc) || !has_buckled_mobs() || user != buckled_mobs[1])
		COOLDOWN_START(src, wheelchair_move_delay, 0.5 SECONDS)
		return FALSE

	var/calculated_move_delay = user.cached_multiplicative_slowdown

	if(ishuman(user))
		var/mob/living/carbon/human/driver = user
		if(!driver.num_hands)
			COOLDOWN_START(src, wheelchair_move_delay, 0.5 SECONDS)
			return FALSE // No hands to drive your chair? Tough luck!

		for(var/organ_name in list(BODY_ZONE_L_ARM, BODY_ZONE_R_ARM, BODY_ZONE_PRECISE_L_HAND, BODY_ZONE_PRECISE_R_HAND))
			var/obj/item/organ/external/bodypart = driver.get_organ(organ_name)
			if(!bodypart)
				calculated_move_delay += 4
			else if(bodypart.is_splinted())
				calculated_move_delay += 0.5
			else if(bodypart.has_fracture())
				calculated_move_delay += 1.5

	if(lowest_move_delay && calculated_move_delay < lowest_move_delay)
		calculated_move_delay = lowest_move_delay //no racecarts

	. = Move(next_step, direction)
	if(ISDIAGONALDIR(direction) && loc == next_step)
		calculated_move_delay *= sqrt(2)

	set_glide_size(DELAY_TO_GLIDE_SIZE(calculated_move_delay))
	COOLDOWN_START(src, wheelchair_move_delay, calculated_move_delay)

	for(var/mob/living/buckled_mob as anything in buckled_mobs)
		buckled_mob.setDir(direction)


/obj/structure/chair/wheelchair/Bump(atom/bumped_atom)
	. = ..()
	if(!has_buckled_mobs())
		return .

	var/mob/living/buckled_mob = buckled_mobs[1]
	if(istype(bumped_atom, /obj/machinery/door))
		bumped_atom.Bumped(buckled_mob)

	if(!propelled)
		return .

	var/mob/living/occupant = buckled_mob
	unbuckle_mob(occupant)

	occupant.throw_at(bumped_atom, 3, propelled)

	occupant.Weaken(12 SECONDS)
	occupant.Stuttering(12 SECONDS)
	playsound(src.loc, 'sound/weapons/punch1.ogg', 50, TRUE, -1)
	if(isliving(bumped_atom))
		var/mob/living/victim = bumped_atom
		victim.Weaken(12 SECONDS)
		victim.Stuttering(12 SECONDS)
		victim.take_organ_damage(10)

	occupant.visible_message(span_danger("[occupant] crashed into [bumped_atom]!"))

