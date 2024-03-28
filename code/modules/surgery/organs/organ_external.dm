/// Threshold needed to have a chance of hurting internal bits with something sharp
#define LIMB_SHARP_THRESH_INT_DMG 5
/// Threshold needed to have a chance of hurting internal bits
#define LIMB_THRESH_INT_DMG 10
/// Probability of taking internal damage from sufficient force, while otherwise healthy
#define LIMB_DMG_PROB 5
/// Threshold needed to have a chance of inflicting fracture
#define LIMB_FRACTURE_MIN_DMG 15
/// Threshold needed to have a chance of inflicting internal bleeding
#define LIMB_INT_BLEEDING_MIN_DMG 15


/****************************************************
				EXTERNAL ORGANS
****************************************************/
/obj/item/organ/external
	name = "external"
	min_broken_damage = 30
	max_damage = 0
	dir = SOUTH
	blocks_emissive = FALSE
	/// External body part zone
	var/limb_zone
	/// Used to calculate protection from armor
	var/limb_body_flag = NONE
	/// Bodypart parent
	var/obj/item/organ/external/parent
	/// Lazy list of bodypart children
	var/list/children
	/// Child bodyparts in this list will be robotized with the parent
	var/list/convertable_children
	/// Lazy list of internal organs of this bodypart.
	var/list/internal_organs

	/// Bitflag for icon position (LEFT or RIGHT), used to correctly render bodyparts position
	var/icon_position = NONE
	/// Icon state used to render bodypart
	var/icon_name
	/// Bodypart model, used for robotic parts visualization
	var/model
	/// Icon override used for wings/tails
	var/force_icon
	/// Default organ icons set
	var/icobase = 'icons/mob/human_races/r_human.dmi'
	/// Mutated organ icons set
	var/deform = 'icons/mob/human_races/r_def_human.dmi'
	/// String code used to apply and check bodypart visual damage
	var/damage_state = "00"
	/// Default icon used by dismembered bodypart
	var/icon/mob_icon
	/// If set to `TRUE` bodypart will use genderized bodypart icon if available
	var/gendered_icon = FALSE
	/// Visual bodypart color tone
	var/s_tone
	/// Visual bodypart color override. If this is instantiated, it should be a hex value
	var/s_col
	/// Lazy list of children bodyparts icons
	var/list/child_icons

	/// Brute modifier allpied to received damage
	var/brute_mod = 1
	/// Burn modifier allpied to received damage
	var/burn_mod = 1
	/// Curent bodypart brute damage
	var/brute_dam = 0
	/// Curent bodypart burn damage
	var/burn_dam = 0
	/// Damage equal to brute damage after bodypart breaks. Used to calculate bodypart overall damage
	var/perma_injury = 0

	/// Whether bodypart can be amputated
	var/cannot_amputate = FALSE
	/// Whether bodypart can be broken
	var/cannot_break = FALSE
	/// Whether bodypart can have internal bleeding
	var/cannot_internal_bleed = FALSE
	/// Whether bodypart will drop if maximum damage is reached
	var/dismember_at_max_damage = FALSE
	// Does the organ take reduce damage from EMPs? IPC limbs get this by default
	var/emp_resistant = FALSE
	/// Whether this bodypart can be used for grasping
	var/can_grasp = FALSE

	/// If `TRUE` you cannot be identified by examine (used for head bodypart only)
	var/disfigured = FALSE
	/// Whether prosthetic bodypart is emagged, it will detonate when it fails
	var/sabotaged = FALSE
	/// Time when this organ was last splinted
	var/splinted_count = 0
	/// Lazy list of all embedded objects inside the bodypart
	var/list/embedded_objects

	/// Whether bodypart has an open incision from surgery
	var/open = 0
	/// Whether bodypart needs to be opened with a saw to access the internal organs. Can be a string with encasing description
	var/encased = FALSE
	/// Reference to item hidden in this bodypart after cavity surgery
	var/obj/item/hidden
	/// Fluff fracture description
	var/broken_description
	/// Descriptive string used in amputation
	var/amputation_point


/obj/item/organ/external/New(mob/living/carbon/holder)
	..()

	if(dna?.species)
		icobase = dna.species.icobase
		deform = dna.species.deform
	if(ishuman(holder))
		replaced(holder)
		sync_colour_to_human(holder)
	get_icon()


/obj/item/organ/external/Destroy()
	if(parent)
		LAZYREMOVE(parent.children, src)
		parent = null

	for(var/obj/item/organ/internal/organ as anything in internal_organs)
		if(owner)
			var/atom/movable/thing = organ.remove(owner, ORGAN_MANIPULATION_NOEFFECT)
			if(!QDELETED(thing))
				qdel(thing)
		else
			LAZYREMOVE(internal_organs, organ)
			qdel(organ)

	for(var/obj/item/organ/external/childpart as anything in children)
		if(owner)
			var/atom/movable/thing = childpart.remove(owner, ORGAN_MANIPULATION_NOEFFECT)
			if(!QDELETED(thing))
				qdel(thing)
		else
			qdel(childpart)

	if(owner)
		owner.bodyparts_by_name[limb_zone] = null
		LAZYREMOVE(owner.splinted_limbs, src)

	QDEL_LIST(embedded_objects)
	QDEL_NULL(hidden)

	if(owner && !owner.has_embedded_objects())
		owner.clear_alert("embeddedobject")

	return ..()


/obj/item/organ/external/replaced(mob/living/carbon/human/target)
	owner = target

	forceMove(owner)

	if(LAZYLEN(embedded_objects))
		owner.throw_alert("embeddedobject", /obj/screen/alert/embeddedobject)

	if(!ishuman(owner))
		return

	var/obj/item/organ/external/replaced = owner.bodyparts_by_name[limb_zone]
	if(!isnull(replaced))
		replaced.remove(target, ORGAN_MANIPULATION_NOEFFECT)
	owner.bodyparts_by_name[limb_zone] = src
	owner.bodyparts |= src

	for(var/atom/movable/thing in src)
		thing.attempt_become_organ(src, owner)

	if(parent_organ_zone)
		parent = owner.bodyparts_by_name[parent_organ_zone]
		if(parent)
			LAZYADDOR(parent.children, src)


/obj/item/organ/external/remove(mob/living/user, special = ORGAN_MANIPULATION_DEFAULT, ignore_children = FALSE)
	if(!owner)
		return

	var/mob/living/carbon/human/organ_owner = owner	// we need to have a reference since its nullified in parent proc

	remove_splint(silent = TRUE)
	remove_all_embedded_objects()

	. = ..()

	// Attached organs also fly off.
	if(!ignore_children)
		for(var/obj/item/organ/external/childpart as anything in children)
			var/atom/movable/thing = childpart.remove(organ_owner, special)
			if(!QDELETED(thing))
				thing.forceMove(src)
		organ_owner.updatehealth("limb remove")

	// Grab all the internal giblets too.
	for(var/obj/item/organ/internal/organ as anything in internal_organs)
		var/atom/movable/thing = organ.remove(organ_owner, special)
		if(!QDELETED(thing))
			thing.forceMove(src)

	release_restraints(organ_owner)
	organ_owner.bodyparts -= src
	organ_owner.bodyparts_by_name[limb_zone] = null	// Remove from owner's vars.

	//Robotic limbs explode if sabotaged.
	if(is_robotic() && sabotaged && !special)
		organ_owner.visible_message(
			span_danger("[organ_owner]'s [name] explodes violently!"),
			span_danger("Your [name] explodes!"),
			span_danger("You hear an explosion!"),
		)
		explosion(get_turf(organ_owner), -1, -1, 2, 3, cause = "Organ Sabotage")
		do_sparks(5, FALSE, organ_owner)
		qdel(src)


/obj/item/organ/external/attempt_become_organ(obj/item/organ/external/parent, mob/living/carbon/human/target)
	if(parent_organ_zone != parent.limb_zone)
		return FALSE
	replaced(target)
	return TRUE


/obj/item/organ/external/update_health()
	damage = min(max_damage, (brute_dam + burn_dam))


/****************************************************
			   DAMAGE PROCS
****************************************************/

/obj/item/organ/external/receive_damage(brute, burn, sharp, used_weapon = null, list/forbidden_limbs = list(), ignore_resists = FALSE, updating_health = TRUE, silent = FALSE)
	if(owner?.status_flags & GODMODE)
		return FALSE

	if(tough && !ignore_resists)
		brute = max(0, brute - 5)
		burn = max(0, burn - 4)

	if(brute <= 0 && burn <= 0)
		return FALSE

	if(!ignore_resists)
		brute *= brute_mod
		burn *= burn_mod

	// High brute damage or sharp objects may damage internal organs; distributed damage doesn't inflict it
	if(!ignore_resists && LAZYLEN(internal_organs) && (brute_dam >= max_damage || (((sharp && brute >= LIMB_SHARP_THRESH_INT_DMG) || brute >= LIMB_THRESH_INT_DMG) && prob(LIMB_DMG_PROB))))
		var/obj/item/organ/internal/internal_organ = pick(internal_organs)
		// Pass full damage if an internal organ is dead
		var/internal_damage = min(internal_organ.max_damage - internal_organ.damage, brute * 0.5)
		if(internal_damage)
			internal_organ.receive_damage(internal_damage)
			brute -= internal_damage

	if(!silent && brute && has_fracture() && owner?.has_pain() && prob(40))
		owner.emote("scream")	// Getting hit on broken hand hurts
	else if(brute && prob((brute + burn) * 4))
		remove_splint(splint_break = TRUE, silent = silent)	// Taking damage to splinted limbs removes the splints

	if(used_weapon)
		add_autopsy_data("[used_weapon]", brute + burn)
	else
		add_autopsy_data(null, brute + burn)

	if(!ignore_resists)
		// See if internal bleeding/fracture has place; distributed damage doesn't inflict it
		try_internal_bleeding(brute, silent)
		try_fracture(brute, silent)

	// Need to update health, but need a reference in case the below checks cuts off a limb.
	var/mob/living/carbon/organ_owner = owner

	// Make sure we don't exceed the maximum damage a limb can take before dismembering
	if((brute_dam + burn_dam + brute + burn) < max_damage)
		brute_dam += brute
		burn_dam += burn
	else
		// If we can't inflict the full amount of damage, spread the damage in other ways
		// How much damage can we actually cause?
		var/remaining_health = max_damage - (brute_dam + burn_dam)
		if(remaining_health)
			if(brute > 0)
				// Inflict all brute damage we can
				brute_dam = min(brute_dam + brute, brute_dam + remaining_health)
				var/temp = remaining_health
				// How much more damage can we inflict
				remaining_health = max(0, remaining_health - brute)
				// How much brute damage is left to inflict
				brute = max(0, brute - temp)

			if(burn > 0 && remaining_health)
				// Inflict all burn damage we can
				burn_dam = min(burn_dam + burn, burn_dam + remaining_health)
				// How much burn damage is left to inflict
				burn = max(0, burn - remaining_health)

		// If there are still hurties to dispense
		if(burn || brute)
			// List organs we can pass it to
			var/list/obj/item/organ/external/possible_points = list()
			if(parent)
				possible_points += parent

			if(LAZYLEN(children))
				var/all_children_forbidden = TRUE
				for(var/obj/item/organ/external/childpart as anything in children)
					if(!(childpart in forbidden_limbs))
						all_children_forbidden = FALSE
						possible_points += childpart
				if(all_children_forbidden)
					forbidden_limbs |= src
			else
				forbidden_limbs |= src

			if(length(forbidden_limbs))
				possible_points -= forbidden_limbs

			// If everything is damaged, no damage
			var/can_distribute = TRUE
			if(owner && length(forbidden_limbs) == length(owner.bodyparts_by_name))
				can_distribute = FALSE

			// Return damage to upper body if nothing is available
			if(parent && !length(possible_points))
				possible_points += parent

			if(can_distribute && length(possible_points))
				// And pass the pain around
				var/obj/item/organ/external/picked_part = pick(possible_points)
				// If the damage was reduced before, don't reduce it again
				picked_part.receive_damage(brute, burn, sharp, used_weapon, forbidden_limbs, ignore_resists = TRUE, updating_health = FALSE, silent = silent)

			// We've ensured all damage to the mob is retained, now let's drop it, if necessary
			var/limb_dropped = FALSE
			if(dismember_at_max_damage && limb_zone != BODY_ZONE_CHEST && limb_zone != BODY_ZONE_PRECISE_GROIN)
				// Clean loss, just drop the limb and be done
				droplimb(clean = TRUE, silent = silent)
				limb_dropped = TRUE

			// If limb took enough damage, try to cut or tear it off.
			if(!limb_dropped && sharp && owner && loc == owner && !cannot_amputate && prob(brute / 2))
				droplimb(silent = silent)

	if(updating_health)
		organ_owner?.updatehealth("limb receive damage")

	return update_state()


/obj/item/organ/external/proc/heal_damage(brute, burn, internal = FALSE, robo_repair = FALSE, updating_health = TRUE)
	if(is_robotic() && !robo_repair)
		return

	brute_dam = max(brute_dam - brute, 0)
	burn_dam  = max(burn_dam - burn, 0)

	if(internal)
		status &= ~ORGAN_BROKEN
		perma_injury = 0

	if(updating_health)
		owner.updatehealth("limb heal damage")

	return update_state()


/obj/item/organ/external/emp_act(severity)
	if(!is_robotic() || emp_proof)
		return
	if(tough) // Augmented limbs (remember they take -5 brute/-4 burn damage flat so any value below is compensated)
		switch(severity)
			if(1)
				// 44 total burn damage with 11 augmented limbs
				receive_damage(0, 8)
			if(2)
				// 22 total burn damage with 11 augmented limbs
				receive_damage(0, 6)
	else if(emp_resistant) // IPC limbs
		switch(severity)
			if(1)
				// 5.28 (9 * 0.66 burn_mod) burn damage, 65.34 damage with 11 limbs.
				receive_damage(0, 9)
			if(2)
				// 3.63 (5 * 0.66 burn_mod) burn damage, 39.93 damage with 11 limbs.
				receive_damage(0, 5.5)
	else // Basic prosthetic limbs
		switch(severity)
			if(1)
				receive_damage(0, 20)
			if(2)
				receive_damage(0, 7)


/*
This function completely restores a damaged organ to perfect condition.
*/
/obj/item/organ/external/rejuvenate()
	damage_state = "00"
	surgeryize()
	if(is_robotic())	//Robotic organs stay robotic.
		status = ORGAN_ROBOT
	else
		status = NONE
	germ_level = 0
	perma_injury = 0
	brute_dam = 0
	burn_dam = 0
	open = 0 //Closing all wounds.
	disfigured = FALSE

	// handle internal organs
	for(var/obj/item/organ/internal/organ as anything in internal_organs)
		organ.rejuvenate()

	for(var/obj/item/organ/external/childpart as anything in children)
		childpart.rejuvenate()

	if(owner)
		owner.updatehealth("limb rejuvenate")
	update_state()
	if(!owner)
		START_PROCESSING(SSobj, src)


/****************************************************
			   PROCESSING & UPDATING
****************************************************/

//Determines if we even need to process this organ.

/obj/item/organ/external/process()
	if(owner)
		//Chem traces slowly vanish
		if(owner.life_tick % 10 == 0)
			for(var/chemID in trace_chemicals)
				trace_chemicals[chemID] = trace_chemicals[chemID] - 1
				if(trace_chemicals[chemID] <= 0)
					trace_chemicals.Remove(chemID)

		if(!has_fracture())
			perma_injury = 0

	if(..())
		if(owner.germ_level > germ_level && infection_check())
			//Open wounds can become infected
			germ_level++


//Updating germ levels. Handles organ germ levels and necrosis.
/*
The INFECTION_LEVEL values defined in setup.dm control the time it takes to reach the different
infection levels. Since infection growth is exponential, you can adjust the time it takes to get
from one germ_level to another using the rough formula:

desired_germ_level = initial_germ_level*e^(desired_time_in_seconds/1000)

So if I wanted it to take an average of 15 minutes to get from level one (100) to level two
I would set INFECTION_LEVEL_TWO to 100*e^(15*60/1000) = 245. Note that this is the average time,
the actual time is dependent on RNG.

INFECTION_LEVEL_ONE		below this germ level nothing happens, and the infection doesn't grow
INFECTION_LEVEL_TWO		above this germ level the infection will start to spread to internal and adjacent organs
INFECTION_LEVEL_THREE	above this germ level the player will take additional toxin damage per second, and will die in minutes without
						antitox..

Note that amputating the affected organ does in fact remove the infection from the player's body.
*/
/obj/item/organ/external/handle_germs()

	if(germ_level < INFECTION_LEVEL_TWO)
		return ..()

	if(germ_level >= INFECTION_LEVEL_TWO)
		//spread the infection to internal organs
		var/obj/item/organ/internal/target_organ = null	//make internal organs become infected one at a time instead of all at once
		for(var/obj/item/organ/internal/organ as anything in internal_organs)
			if(organ.germ_level > 0 && organ.germ_level < min(germ_level, INFECTION_LEVEL_TWO) && (!target_organ || organ.germ_level > target_organ.germ_level))	//once the organ reaches whatever we can give it, or level two, switch to a different one, choosing the organ with the highest germ_level
				target_organ = organ

		if(!target_organ)
			//figure out which organs we can spread germs to and pick one at random
			var/list/candidate_organs = list()
			for(var/obj/item/organ/internal/organ as anything in internal_organs)
				if(organ.germ_level < germ_level)
					candidate_organs += organ

			target_organ = safepick(candidate_organs)

		if(target_organ)
			target_organ.germ_level += owner.dna.species.germs_growth_rate

		//spread the infection to child and parent organs
		for(var/obj/item/organ/external/childpart as anything in children)
			if(childpart.germ_level < germ_level && !childpart.is_robotic() && (childpart.germ_level < INFECTION_LEVEL_ONE * 2 || prob(30)))
				childpart.germ_level += owner.dna.species.germs_growth_rate

		if(parent && parent.germ_level < germ_level && !parent.is_robotic() && (parent.germ_level < INFECTION_LEVEL_ONE * 2 || prob(30)))
			parent.germ_level += owner.dna.species.germs_growth_rate

	if(germ_level >= INFECTION_LEVEL_THREE)
		necrotize()
		germ_level += owner.dna.species.germs_growth_rate
		owner.adjustToxLoss(1)


/obj/item/organ/external/proc/try_fracture(inflicted_damage, silent = FALSE)
	if(inflicted_damage <= LIMB_FRACTURE_MIN_DMG)
		return FALSE
	if(brute_dam + burn_dam + inflicted_damage <= min_broken_damage)
		return FALSE
	if(!prob(inflicted_damage * FRAGILITY(owner)))
		return FALSE
	if(fracture(silent))
		add_attack_logs(owner, null, "Suffered fracture to [src](Damage: [inflicted_damage], Organ HP: [max_damage - (brute_dam + burn_dam) ])")
		return TRUE
	return FALSE


/obj/item/organ/external/proc/try_internal_bleeding(inflicted_damage, silent = FALSE)
	if(inflicted_damage <= LIMB_INT_BLEEDING_MIN_DMG)
		return FALSE
	if(brute_dam + burn_dam + inflicted_damage <= min_internal_bleeding_damage)
		return FALSE
	if(!prob(inflicted_damage))
		return FALSE
	if(internal_bleeding(silent))
		add_attack_logs(owner, null, "Suffered internal bleeding to [src](Damage: [inflicted_damage], Organ HP: [max_damage - (brute_dam + burn_dam) ])")
		return TRUE
	return FALSE


// new damage icon system
// returns just the brute/burn damage code
/obj/item/organ/external/proc/damage_state_text()
	var/tburn = 0
	var/tbrute = 0

	if(burn_dam ==0)
		tburn =0
	else if(burn_dam < (max_damage * 0.25 / 2))
		tburn = 1
	else if(burn_dam < (max_damage * 0.75 / 2))
		tburn = 2
	else
		tburn = 3

	if(brute_dam == 0)
		tbrute = 0
	else if(brute_dam < (max_damage * 0.25 / 2))
		tbrute = 1
	else if(brute_dam < (max_damage * 0.75 / 2))
		tbrute = 2
	else
		tbrute = 3
	return "[tbrute][tburn]"


/****************************************************
			   DISMEMBERMENT
****************************************************/
/obj/item/organ/external/proc/droplimb(clean = FALSE, disintegrate = DROPLIMB_SHARP, ignore_children = FALSE, nodamage = FALSE, silent = FALSE)
	if(!owner || cannot_amputate)
		return

	if(owner.status_flags & GODMODE)
		return

	if(!silent)
		switch(disintegrate)
			if(DROPLIMB_SHARP)
				if(!clean)
					var/gore_sound = "[is_robotic() ? "tortured metal" : "ripping tendons and flesh"]"
					owner.visible_message(
						span_danger("[owner]'s [name] flies off in an arc!"),
						span_userdanger("Your [name] goes flying off!"),
						span_italics("You hear a terrible sound of [gore_sound]."),
					)
			if(DROPLIMB_BURN)
				var/gore = "[is_robotic() ? "" : " of burning flesh"]"
				owner.visible_message(
					span_danger("[owner]'s [name] flashes away into ashes!"),
					span_userdanger("Your [name] flashes away into ashes!"),
					span_italics("You hear a crackling sound[gore]."),
				)
			if(DROPLIMB_BLUNT)
				var/gore = "[is_robotic() ? "": " in shower of gore"]"
				var/gore_sound = "[is_robotic() ? "rending sound of tortured metal" : "sickening splatter of gore"]"
				owner.visible_message(
					span_danger("[owner]'s [name] explodes[gore]!"),
					span_userdanger("Your [name] explodes[gore]!"),
					span_italics("You hear the [gore_sound].")
				)

	var/mob/living/carbon/human/victim = owner //Keep a reference for post-removed().
	// Let people make limbs become fun things when removed
	var/atom/movable/dropped_part = remove(ignore_children = ignore_children)

	if(!QDELETED(src) && parent)
		LAZYREMOVE(parent.children, src)
		if(!nodamage)
			var/total_brute = brute_dam
			var/total_burn = burn_dam
			for(var/obj/item/organ/external/childpart as anything in children) //Factor in the children's brute and burn into how much will transfer
				total_brute += childpart.brute_dam
				total_burn += childpart.burn_dam
			parent.receive_damage(total_brute, total_burn, ignore_resists = TRUE, silent = silent) //Transfer the full damage to the parent, bypass limb damage reduction.
		parent = null
		dir = SOUTH

	if(victim)
		victim.updatehealth("droplimb")
		victim.UpdateDamageIcon()
		victim.regenerate_icons()

	switch(disintegrate)
		if(DROPLIMB_SHARP)
			if(!QDELETED(src))
				compile_icon()
				brute_dam = 0
				burn_dam = 0  //Reset the damage on the limb; the damage should have transferred to the parent; we don't want extra damage being re-applied when then limb is re-attached

			if(!clean && !QDELETED(dropped_part))	// we need to separate this in case [remove()] returned smth else but our src
				dropped_part.add_mob_blood(victim)
				var/matrix/new_transform = matrix(dropped_part.transform)
				new_transform.Turn(rand(180))
				dropped_part.transform = new_transform
				// Throw limb around.
				if(isturf(dropped_part.loc))
					dropped_part.throw_at(get_edge_target_turf(dropped_part, pick(GLOB.alldirs)), rand(1, 3), 30)
				dropped_part.dir = SOUTH

			return dropped_part

		else
			if(!QDELETED(src))
				qdel(src) // If you flashed away to ashes, YOU FLASHED AWAY TO ASHES

			return null


/obj/item/organ/external/proc/disembowel(spillage_zone = BODY_ZONE_CHEST, silent = FALSE)
	if(!owner)
		return FALSE

	var/mob/living/carbon/human/organ_owner = owner

	if(!hasorgans(organ_owner))
		return FALSE

	var/organ_spilled = FALSE
	var/owner_turf = get_turf(organ_owner)
	if(!silent)
		organ_owner.add_splatter_floor(owner_turf)
		playsound(owner_turf, 'sound/effects/splat.ogg', 25, TRUE)

	for(var/obj/item/organ/organ as anything in organ_owner.internal_organs)
		var/organ_zone = check_zone(organ.parent_organ_zone)
		if(organ_zone == spillage_zone)
			var/atom/movable/thing = organ.remove(organ_owner)
			if(!QDELETED(thing))
				organ_spilled = TRUE
				thing.forceMove(drop_location())

	if(organ_spilled && !silent)
		organ_owner.visible_message(span_danger("[organ_owner]'s internal organs spill out onto the floor!"))

	return TRUE


/obj/item/organ/external/chest/droplimb(clean = FALSE, disintegrate = DROPLIMB_SHARP, ignore_children = FALSE, nodamage = FALSE, silent = FALSE)
	return disembowel(BODY_ZONE_CHEST, silent)


/obj/item/organ/external/groin/droplimb(clean = FALSE, disintegrate = DROPLIMB_SHARP, ignore_children = FALSE, nodamage = FALSE, silent = FALSE)
	return disembowel(BODY_ZONE_PRECISE_GROIN, silent)


/obj/item/organ/external/attackby(obj/item/I, mob/user, params)
	if(I.sharp)
		add_fingerprint(user)
		if(!length(contents))
			to_chat(user, span_warning("There is nothing left inside [src]!"))
			return

		playsound(loc, 'sound/weapons/slice.ogg', 50, TRUE, -1)
		user.visible_message(
			span_warning("[user] begins to cut open [src]."),
			span_notice("You begin to cut open [src]..."),
		)
		if(do_after(user, 5 SECONDS, target = src) && length(contents) && !QDELETED(src) && !QDELETED(user))
			drop_organs()
	else
		return ..()


/**
 * Empties the bodypart from its organs and other things inside it.
 */
/obj/item/organ/external/proc/drop_organs(atom/drop_loc, special = ORGAN_MANIPULATION_DEFAULT, ignore_children = FALSE, silent = FALSE)
	drop_loc = drop_loc ? drop_loc : drop_location()
	var/mob/living/carbon/human/organ_owner = owner

	var/need_compile = !ignore_children && LAZYLEN(children)

	remove_all_embedded_objects()

	for(var/obj/item/organ/internal/organ as anything in internal_organs)
		if(organ_owner)
			var/atom/movable/thing = organ.remove(organ_owner, special)
			if(!QDELETED(thing))
				thing.forceMove(drop_loc)
		else
			LAZYREMOVE(internal_organs, organ)
			organ.forceMove(drop_loc)

	if(!ignore_children)
		for(var/obj/item/organ/external/childpart as anything in children)
			if(organ_owner)
				if(childpart.limb_zone == BODY_ZONE_PRECISE_GROIN)
					for(var/obj/item/organ/external/groinpart as anything in childpart.children)
						groinpart.compile_icon()
						groinpart.brute_dam = 0
						groinpart.burn_dam = 0
						var/atom/movable/groin_thing = groinpart.remove(organ_owner, special)
						if(!QDELETED(groin_thing))
							groin_thing.forceMove(drop_loc)
					continue
				childpart.compile_icon()
				childpart.brute_dam = 0
				childpart.burn_dam = 0
				var/atom/movable/thing = childpart.remove(organ_owner, special)
				if(!QDELETED(thing))
					thing.forceMove(drop_loc)
			else
				childpart.compile_icon()
				LAZYREMOVE(children, childpart)
				childpart.parent = null
				childpart.forceMove(drop_loc)
				childpart.dir = SOUTH

	for(var/obj/item/thing in contents)
		if(isexternalorgan(thing))
			continue
		thing.forceMove(drop_loc)

	if(organ_owner)
		organ_owner.updatehealth("drop_organs")
		organ_owner.UpdateDamageIcon()
		organ_owner.regenerate_icons()

	if(!silent && !is_robotic())
		playsound(drop_loc, 'sound/effects/splat.ogg', 25, TRUE)

	if(need_compile)
		compile_icon()


/****************************************************
			   HELPERS
****************************************************/
/obj/item/organ/external/proc/release_restraints(mob/living/carbon/human/holder, silent = FALSE)
	if(!holder)
		holder = owner
	if(!holder)
		return
	if(holder.handcuffed && (limb_zone in list(BODY_ZONE_L_ARM, BODY_ZONE_R_ARM, BODY_ZONE_PRECISE_L_HAND, BODY_ZONE_PRECISE_R_HAND)))
		if(!silent)
			holder.visible_message(
				"[holder.handcuffed.name] falls off of [holder.name].",
				"[holder.handcuffed.name] falls off you.",
			)
		holder.drop_item_ground(holder.handcuffed)

	if(holder.legcuffed && (limb_zone in list(BODY_ZONE_L_LEG, BODY_ZONE_R_LEG, BODY_ZONE_PRECISE_L_FOOT, BODY_ZONE_PRECISE_R_FOOT)))
		if(!silent)
			holder.visible_message(
				"[holder.legcuffed.name] falls off of [holder.name].",
				"[holder.legcuffed.name] falls off you.",
			)
		holder.drop_item_ground(holder.legcuffed)


/obj/item/organ/external/proc/internal_bleeding(silent = FALSE)
	if(owner?.status_flags & GODMODE)
		return FALSE
	if(is_robotic())
		return FALSE
	if(dna && (NO_BLOOD in dna.species.species_traits))
		return FALSE
	if(has_internal_bleeding() || cannot_internal_bleed)
		return FALSE

	status |= ORGAN_INT_BLEED

	if(owner && !silent)
		owner.custom_pain("You feel something rip in your [name]!")

	return TRUE


/obj/item/organ/external/proc/has_internal_bleeding()
	return (status & ORGAN_INT_BLEED)


/obj/item/organ/external/proc/stop_internal_bleeding()
	if(is_robotic())
		return FALSE
	if(dna && (NO_BLOOD in dna.species.species_traits))
		return FALSE
	if(!has_internal_bleeding())
		return FALSE

	status &= ~ORGAN_INT_BLEED

	return TRUE


/obj/item/organ/external/proc/fracture(silent = FALSE)
	if(!CONFIG_GET(flag/bones_can_break))
		return FALSE
	if(owner?.status_flags & GODMODE)
		return FALSE
	if(is_robotic())
		return FALSE
	if(has_fracture() || cannot_break)
		return FALSE

	if(owner && !silent)
		owner.visible_message(
			span_warning("You hear a loud cracking sound coming from \the [owner]."),
			span_danger("Something feels like it shattered in your [name]!"),
			span_italics("You hear a sickening crack."),
		)

		playsound(owner, "bonebreak", 150, TRUE)

		if(owner.has_pain())
			owner.emote("scream")

	status |= ORGAN_BROKEN
	broken_description = pick("broken", "fracture", "hairline fracture")
	perma_injury = brute_dam

	// Fractures have a chance of getting you out of restraints
	if(prob(25))
		release_restraints(silent = silent)

	return TRUE


/obj/item/organ/external/proc/has_fracture()
	return (status & ORGAN_BROKEN)


/obj/item/organ/external/proc/mend_fracture()
	if(is_robotic())
		return FALSE
	if(!has_fracture())
		return FALSE

	status &= ~ORGAN_BROKEN
	perma_injury = 0
	remove_splint()

	return TRUE


/obj/item/organ/external/proc/apply_splint()
	if(is_splinted())
		return FALSE
	if(!has_fracture())
		return FALSE

	status |= ORGAN_SPLINTED
	if(owner)
		LAZYADDOR(owner.splinted_limbs, src)
		splinted_count = owner.step_count

	return TRUE


/obj/item/organ/external/proc/is_splinted()
	return (status & ORGAN_SPLINTED)


/obj/item/organ/external/proc/remove_splint(splint_break = FALSE, silent = FALSE)
	if(!is_splinted())
		return FALSE

	status &= ~ORGAN_SPLINTED
	splinted_count = 0
	if(owner)
		LAZYREMOVE(owner.splinted_limbs, src)
		if(splint_break)
			owner.Stun(4 SECONDS)
			if(owner.has_pain() && !silent)
				owner.emote("scream")
				owner.visible_message(
					span_danger("[owner] screams in pain as [owner.p_their()] splint pops off their [name]!"),
					span_userdanger("You scream in pain as your splint pops off your [name]!"),
					span_italics("You hear a loud scream!")
				)
			else if(!silent)
				owner.visible_message(
					span_danger("The splint on [owner]'s [name] unravels!"),
					span_userdanger("The splint on your [name] unravels!"),
				)

	return TRUE


/obj/item/organ/external/proc/has_fracture_or_splint()
	return (status & (ORGAN_BROKEN|ORGAN_SPLINTED))


/obj/item/organ/external/robotize(make_tough = FALSE, company, convert_all = TRUE)
	..()
	remove_splint()

	//robot limbs take reduced damage
	if(make_tough)
		tough = TRUE
	else
		brute_mod = 0.66
		burn_mod = 0.66
		dismember_at_max_damage = TRUE

	// Robot parts also lack bones
	// This is so surgery isn't kaput, let's see how this does
	encased = null

	if(istext(company))
		set_company(company)

	cannot_break = TRUE
	get_icon()

	for(var/obj/item/organ/external/bodypart as anything in children)
		if(convert_all || (convertable_children && (bodypart.type in convertable_children)))
			bodypart.robotize(make_tough, company, convert_all)


/obj/item/organ/external/necrotize(silent = FALSE)
	if(status & (ORGAN_ROBOT|ORGAN_DEAD))
		return FALSE
	status |= ORGAN_DEAD
	if(dead_icon)
		icon_state = dead_icon
	if(owner)
		if(!silent)
			to_chat(owner, span_notice("You can't feel your [name] anymore..."))
		owner.update_body()
		if(vital)
			owner.death()
	return TRUE


/obj/item/organ/external/unnecrotize()
	if(!is_dead())
		return FALSE
	status &= ~ORGAN_DEAD
	owner?.update_body()
	return TRUE


/obj/item/organ/external/proc/mutate(silent = FALSE, update_body = TRUE)
	if(owner?.status_flags & GODMODE)
		return FALSE
	if(is_robotic())
		return FALSE
	if(is_mutated())
		return FALSE
	status |= ORGAN_MUTATED
	if(owner)
		if(update_body)
			owner.update_body(TRUE) //Forces all bodyparts to update in order to correctly render the deformed sprite.
		if(!silent)
			to_chat(owner, span_warning("Something is not right with your [name]..."))
	return TRUE


/obj/item/organ/external/proc/unmutate(silent = FALSE, update_body = TRUE)
	if(!is_mutated())
		return FALSE
	if(is_robotic())
		return FALSE
	status &= ~ORGAN_MUTATED
	if(owner)
		if(update_body)
			owner.update_body(rebuild_base = TRUE) //Forces all bodyparts to update in order to correctly return them to normal.
		if(!silent)
			to_chat(owner, span_warning("Your [name] is shaped normally again."))
	return TRUE


/obj/item/organ/external/proc/is_mutated()
	return (status & ORGAN_MUTATED)


/obj/item/organ/external/proc/get_damage()	//returns total damage
	return max(brute_dam + burn_dam - perma_injury, perma_injury)	//could use health?


/obj/item/organ/external/proc/has_infected_wound()
	if(germ_level > INFECTION_LEVEL_ONE)
		return TRUE
	return FALSE


/obj/item/organ/external/proc/is_usable()
	if((is_robotic() && get_damage() >= max_damage) && !tough) //robot limbs just become inoperable at max damage
		return
	return !(status & (ORGAN_MUTATED|ORGAN_DEAD))


/obj/item/organ/external/proc/is_malfunctioning()
	return (is_robotic() && (brute_dam + burn_dam) >= 10 && prob(brute_dam + burn_dam) && !tough)


/obj/item/organ/external/proc/disfigure(silent = FALSE)
	if(is_disfigured())
		return FALSE

	if(owner)
		if(owner.status_flags & GODMODE)
			return FALSE

		if(!silent)
			owner.visible_message(
				span_warning("You hear a sickening sound coming from \the [owner]'s [name] as it turns into a mangled mess!"),
				span_userdanger("Your [name] becomes a mangled mess!"),
				span_italics("You hear a sickening sound.")
			)

	disfigured = TRUE
	return TRUE


/obj/item/organ/external/proc/is_disfigured()
	return disfigured


/obj/item/organ/external/proc/undisfigure()
	if(!is_disfigured())
		return FALSE

	disfigured = FALSE

	return TRUE


/obj/item/organ/external/proc/infection_check()
	if(owner?.status_flags & GODMODE)
		return FALSE
	var/total_damage = brute_dam + burn_dam
	if(total_damage)
		if(total_damage < 10) //small amounts of damage aren't infectable
			return FALSE

		if(owner && owner.bleedsuppress && total_damage < 25)
			return FALSE

		var/dam_coef = round(total_damage / 10)
		return prob(dam_coef * 10)
	return FALSE


/obj/item/organ/external/serialize()
	var/list/data = ..()
	if(is_robotic())
		data["company"] = model
	// If we wanted to store wound information, here is where it would go
	return data


/obj/item/organ/external/deserialize(list/data)
	var/company = data["company"]
	if(company && istext(company))
		set_company(company)
	..() // Parent call loads in the DNA
	if(data["dna"])
		sync_colour_to_dna()


/obj/item/organ/external/proc/set_company(company)
	model = company
	var/datum/robolimb/R = GLOB.all_robolimbs[company]
	if(R)
		force_icon = R.icon
		name = "[R.company] [initial(name)]"
		desc = "[R.desc]"


/obj/item/organ/external/proc/remove_all_embedded_objects(atom/drop_loc, clear_alert = TRUE)
	. = 0
	if(!LAZYLEN(embedded_objects))
		return .
	drop_loc = drop_loc ? drop_loc : drop_location()
	for(var/obj/item/thing as anything in embedded_objects)
		LAZYREMOVE(embedded_objects, thing)
		thing.forceMove(drop_loc)
		.++
	if(clear_alert && owner && !owner.has_embedded_objects())
		owner.clear_alert("embeddedobject")
	return .


/obj/item/organ/external/proc/remove_embedded_object(obj/item/thing, atom/drop_loc, clear_alert = TRUE)
	if(!LAZYIN(embedded_objects, thing))
		return FALSE
	LAZYREMOVE(embedded_objects, thing)
	thing.forceMove(drop_loc ? drop_loc : drop_location())
	if(clear_alert && owner && !owner.has_embedded_objects())
		owner.clear_alert("embeddedobject")
	return TRUE


/obj/item/organ/external/proc/add_embedded_object(obj/item/thing, throw_alert = TRUE)
	LAZYADDOR(embedded_objects, thing)
	thing.forceMove(src)
	if(throw_alert)
		owner?.throw_alert("embeddedobject", /obj/screen/alert/embeddedobject)


#undef LIMB_SHARP_THRESH_INT_DMG
#undef LIMB_THRESH_INT_DMG
#undef LIMB_DMG_PROB
#undef LIMB_FRACTURE_MIN_DMG
#undef LIMB_INT_BLEEDING_MIN_DMG

