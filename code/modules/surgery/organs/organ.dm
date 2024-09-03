/obj/item/organ
	name = "organ"
	icon = 'icons/obj/surgery.dmi'
	pickup_sound = 'sound/items/handling/flesh_pickup.ogg'
	drop_sound = 'sound/items/handling/flesh_drop.ogg'
	germ_level = 0
	var/dead_icon
	/// Current organ holder
	var/mob/living/carbon/human/owner
	/// Bitflags of organ status
	var/status = NONE
	/// Lose a vital organ, die immediately.
	var/vital = FALSE

	/// Amount of damage to the organ.
	var/damage = 0
	/// Minimal threshold after which various bad effects can happen (lung rupture, eyes temporary blindness etc.)
	var/min_bruised_damage = 10
	/// Minimal threshold for fracture to occure
	var/min_broken_damage = 30
	/// Minimal threshold for internal bleeding to occure
	var/min_internal_bleeding_damage = 30
	/// Basically organ max health.
	var/max_damage

	/// Defined body zone of parent organ.
	var/parent_organ_zone = BODY_ZONE_CHEST
	/// Data saved for autopsy scanner
	var/list/datum/autopsy_data/autopsy_data
	/// Traces of chemicals in the organ, links chemical IDs to number of ticks for which they'll stay in the blood
	var/list/trace_chemicals

	/// DNA organ obtains from its holder
	var/datum/dna/dna
	/// Species datum typepath, assumed to be a /datum/species/human if null
	var/species_type

	/// Stuff for tracking if this is on a tile with an open freezer or not
	var/last_freezer_update_time = 0
	/// How much time we can survive before start decay without open freezer on our turf
	var/freezer_update_period = 10 SECONDS

	/// Can the organ be infected by germs?
	var/sterile = FALSE
	/// Can organ be easily damaged?
	var/tough = FALSE
	/// Is the organ immune to EMPs?
	var/emp_proof = FALSE
	/// Will it skip pain messages?
	var/hidden_pain = FALSE


/obj/item/organ/New(mob/living/carbon/human/holder)
	..(holder)

	if(!max_damage)
		max_damage = min_broken_damage * 2

	if(ishuman(holder))
		update_DNA(holder.dna)
		return

	update_DNA(update_blood = FALSE, randomize = TRUE)


/obj/item/organ/Destroy()
	STOP_PROCESSING(SSobj, src)
	if(owner)
		remove(owner, ORGAN_MANIPULATION_NOEFFECT)
	QDEL_LIST_ASSOC_VAL(autopsy_data)
	if(dna)
		QDEL_NULL(dna)
	return ..()


/obj/item/organ/proc/update_DNA(datum/dna/new_dna, update_blood = TRUE, use_species_type = TRUE, randomize = FALSE)
	if(dna)
		QDEL_NULL(dna)

	if(istype(new_dna))
		dna = new_dna.Clone()

	if(!dna && !randomize)
		return

	if(is_robotic() && !species_type)	// no DNA for cybernetics, except IPC parts
		if(update_blood)
			update_blood()
		return

	if(!dna)
		dna = new

	if(use_species_type && species_type && dna.species.type != species_type)
		dna.species = new species_type

	if(randomize)
		if(dna.species.language)
			var/datum/language/species_language = GLOB.all_languages[dna.species.language]
			if(species_language)
				dna.real_name = species_language.get_random_name(MALE)
			else
				dna.real_name = "Неизвестный-[rand(999)]"
		else
			dna.real_name = "Неизвестный-[rand(999)]"

		dna.unique_enzymes = md5(dna.real_name)
		dna.ResetSE()
		dna.SE_original = dna.SE
		dna.struc_enzymes_original = dna.struc_enzymes
		dna.ResetUI()

	if(update_blood)
		update_blood()


/obj/item/organ/proc/update_blood()
	if(!dna || (TRAIT_NO_BLOOD in dna.species.inherent_traits))
		return
	LAZYSET(blood_DNA, dna.unique_enzymes, dna.blood_type)


/obj/item/organ/proc/update_health()
	return


/obj/item/organ/proc/necrotize(silent = FALSE)
	if(status & (ORGAN_ROBOT|ORGAN_DEAD))
		return FALSE
	damage = max_damage
	status |= ORGAN_DEAD
	STOP_PROCESSING(SSobj, src)
	if(dead_icon && !is_robotic())
		icon_state = dead_icon
	if(owner && vital)
		owner.death()
	return TRUE


/obj/item/organ/proc/is_dead()
	return (status & ORGAN_DEAD)


/obj/item/organ/proc/unnecrotize()
	if(!is_dead())
		return FALSE
	status &= ~ORGAN_DEAD
	return TRUE


/obj/item/organ/attackby(obj/item/I, mob/user, params)
	if(istype(I, /obj/item/stack/nanopaste))
		add_fingerprint(user)
		var/obj/item/stack/nanopaste/nanopaste = I
		if(!is_robotic())
			to_chat(user, span_warning("The [nanopaste.name] can only be used on robotic bodyparts."))
			return ATTACK_CHAIN_PROCEED
		if(!nanopaste.use(1))
			to_chat(user, span_warning("You need at least one unit of [nanopaste] to proceed."))
			return ATTACK_CHAIN_PROCEED
		to_chat(user, span_notice("You have repaired the damage on [src]."))
		rejuvenate()
		return ATTACK_CHAIN_PROCEED_SUCCESS

	return ..()


/obj/item/organ/process()

	//dead already, no need for more processing
	if(is_dead())
		return

	if(is_preserved())
		return

	//Process infections
	if(is_robotic() || sterile || (owner && HAS_TRAIT(owner, TRAIT_NO_GERMS)))
		germ_level = 0
		return

	if(!owner)
		// Maybe scale it down a bit, have it REALLY kick in once past the basic infection threshold
		// Another mercy for surgeons preparing transplant organs
		germ_level++
		if(germ_level >= INFECTION_LEVEL_ONE)
			germ_level += rand(2,6)
		if(germ_level >= INFECTION_LEVEL_TWO)
			germ_level += rand(2,6)
		if(germ_level >= INFECTION_LEVEL_THREE)
			necrotize()

	else if(owner.bodytemperature >= 170)	//cryo stops germs from moving and doing their bad stuffs
		// Handle antibiotics and curing infections
		if(germ_level)
			handle_germs()
		return TRUE


/obj/item/organ/proc/is_preserved()
	var/static/list/preserved_holders = list(
		/obj/machinery/smartfridge/secure/medbay/organ,
		/obj/structure/closet/crate/freezer,
		/obj/machinery/clonepod,
	)

	if(owner)
		return TRUE

	for(var/typepath in preserved_holders)
		if(is_found_within(typepath))
			return TRUE
	if(istype(loc,/obj/item/mmi))	// So a brain can slowly recover from being left out of an MMI
		germ_level = max(0, germ_level - 1)
		return TRUE
	if(istype(loc, /mob/living/simple_animal/hostile/headslug) || istype(loc, /obj/item/organ/internal/body_egg/changeling_egg))
		germ_level = 0 // weird stuff might happen, best to be safe
		return TRUE
	if(isturf(loc))
		var/is_in_freezer = FALSE
		if(world.time - last_freezer_update_time > freezer_update_period)
			// I don't want to loop through everything in the tile constantly, especially since it'll be a pile of organs
			// if the virologist releases gibbingtons again or something
			// There's probably a much less silly way of doing this, but BYOND native algorithms are stupidly naive
			for(var/obj/structure/closet/crate/freezer/freezer in loc)
				if(freezer.opened)
					is_in_freezer = TRUE // on the same tile, close enough, should keep organs much fresher on avg
					break
			last_freezer_update_time = world.time
		return is_in_freezer // I'd like static varibles, please

	// You can do your cool location temperature organ preserving effects here!
	return FALSE


/obj/item/organ/examine(mob/user)
	. = ..()
	if(is_dead())
		if(!is_robotic())
			. += span_notice("The decay has set in.")
		else
			. += span_notice("It looks in need of repairs.")


/obj/item/organ/proc/handle_germs()
	if(germ_level > 0 && germ_level < INFECTION_LEVEL_ONE / 2 && prob(30))
		germ_level--

	if(!ishuman(owner))
		return

	var/germs_amount = 1 * (owner.dna.species.germs_growth_mod * owner.physiology.germs_growth_mod)

	if(germ_level >= INFECTION_LEVEL_ONE / 2)
		//aiming for germ level to go from ambient to INFECTION_LEVEL_TWO in an average of 15 minutes
		if(prob(round(germ_level / 6)))
			germ_level += germs_amount

	if(germ_level >= INFECTION_LEVEL_ONE)
		var/fever_temperature = (owner.dna.species.heat_level_1 - owner.dna.species.body_temperature - 5) * min(germ_level / INFECTION_LEVEL_TWO, 1) + owner.dna.species.body_temperature
		owner.adjust_bodytemperature(between(0, (fever_temperature - T20C) / BODYTEMP_COLD_DIVISOR + 1, fever_temperature - owner.bodytemperature))

	if(germ_level >= INFECTION_LEVEL_TWO)
		var/obj/item/organ/external/parent = owner.get_organ(parent_organ_zone)
		//spread germs
		if(parent.germ_level < germ_level && ( parent.germ_level < INFECTION_LEVEL_ONE * 2 || prob(30)))
			parent.germ_level += germs_amount


/obj/item/organ/proc/rejuvenate()
	damage = 0
	germ_level = 0
	surgeryize()
	if(is_robotic())	//Robotic organs stay robotic.
		status = ORGAN_ROBOT
	else
		status = NONE
	if(!owner)
		START_PROCESSING(SSobj, src)


/obj/item/organ/proc/is_damaged()
	return damage > 0


/obj/item/organ/proc/is_bruised()
	return damage >= min_bruised_damage


/obj/item/organ/proc/is_traumatized()
	return (damage >= min_broken_damage || ((status & ORGAN_BROKEN) && !(status & ORGAN_SPLINTED)))


//Adds autopsy data for used_weapon.
/obj/item/organ/proc/add_autopsy_data(used_weapon = "Unknown", damage)
	LAZYINITLIST(autopsy_data)

	var/datum/autopsy_data/weapon_data = autopsy_data[used_weapon]
	if(!weapon_data)
		weapon_data = new
		weapon_data.weapon = used_weapon
		LAZYSET(autopsy_data, used_weapon, weapon_data)

	weapon_data.hits++
	weapon_data.damage += damage
	weapon_data.time_inflicted = world.time


/**
 * Adjusts internal organ damage value.
 *
 * Arguments:
 * * amount - Amount of damage.
 * * silent - Stops custom pain messaged for organ owner.
 *
 * Returns `TRUE` on success
 */
/obj/item/organ/proc/internal_receive_damage(amount = 0, silent = FALSE)
	. = FALSE
	if(isexternalorgan(src))
		CRASH("internal_receive_damage() is called for external organ. Use external_receive_damage()")

	if(tough)
		return .

	. = TRUE

	damage = clamp(round(damage + amount, DAMAGE_PRECISION), 0, max_damage)

	//only show this if the organ is not robotic
	if(owner && parent_organ_zone && amount > 0)
		var/obj/item/organ/external/parent = owner.get_organ(parent_organ_zone)
		if(parent && !silent)
			owner.custom_pain("Something inside your [parent.name] hurts a lot.")

	//check if we've hit max_damage
	if(damage >= max_damage)
		necrotize(silent)


/obj/item/organ/proc/heal_internal_damage(amount, robo_repair = FALSE)
	if(is_robotic() && !robo_repair)
		return
	damage = max(damage - amount, 0)


/obj/item/organ/proc/robotize(make_tough = FALSE) //Being used to make robutt hearts, etc
	status &= ~ORGAN_BROKEN
	status |= ORGAN_ROBOT


/obj/item/organ/proc/shock_organ(intensity)
	return


/obj/item/organ/proc/remove(mob/living/user, special = ORGAN_MANIPULATION_DEFAULT)
	if(!istype(owner))
		return

	SEND_SIGNAL(owner, COMSIG_CARBON_LOSE_ORGAN, src)
	SEND_SIGNAL(src, COMSIG_ORGAN_REMOVED, owner)
	owner.internal_organs -= src

	var/obj/item/organ/external/affected = owner.get_organ(parent_organ_zone)
	if(affected)
		LAZYREMOVE(affected.internal_organs, src)

	loc = owner.drop_location()
	START_PROCESSING(SSobj, src)

	if(owner?.stat != DEAD && vital && !special)
		add_attack_logs(user, owner, "Removed vital organ ([src])")
		owner.death()
	owner = null
	return src


/obj/item/organ/proc/replaced(mob/living/carbon/human/target, special = ORGAN_MANIPULATION_DEFAULT)
	return // Nothing uses this, it is always overridden


// A version of `replaced` that "flattens" the process of insertion, making organs "Plug'n'play"
// (Particularly the heart, which stops beating when removed)
/obj/item/organ/proc/safe_replace(mob/living/carbon/human/target)
	replaced(target)


/obj/item/organ/proc/surgeryize()
	return

/**
 * Checks if organ has damage that can be cured in the "mend organs" operation.
 * Returns TRUE if there is damage, otherwise FALSE.
 */
/obj/item/organ/proc/has_damage()
	if(damage)
		return TRUE
	return FALSE

/obj/item/organ/proc/is_robotic()
	return (status & ORGAN_ROBOT)


/obj/item/organ/serialize()
	var/data = ..()
	if(status != 0)
		data["status"] = status

	// Save the DNA datum if: The owner doesn't exist, or the dna doesn't match
	// the owner
	if(!(owner && dna.unique_enzymes == owner.dna.unique_enzymes))
		data["dna"] = dna.serialize()
	return data


/obj/item/organ/deserialize(data)
	if(isnum(data["status"]))
		if(data["status"] & ORGAN_ROBOT)
			robotize()
		status = data["status"]
	if(islist(data["dna"]))
		// The only thing the official proc does is
	 	//instantiate the list and call this proc
		dna.deserialize(data["dna"])
		..()

