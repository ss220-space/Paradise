/datum/component/caltrop
	dupe_mode = COMPONENT_DUPE_UNIQUE_PASSARGS
	///Minimum damage done when crossed
	var/min_damage
	///Maximum damage done when crossed
	var/max_damage
	///Probability of actually "firing", stunning and doing damage
	var/probability
	///Amount of time the spike will weaken
	var/weaken_duration
	///Miscelanous caltrop flags; shoe bypassing, walking interaction, silence
	var/flags
	///Species protected from caltrop effects
	var/list/protected_species
	///The sound that plays when a caltrop is triggered
	var/soundfile
	///Whether we should del parent on trigger
	var/del_on_trigger
	///given to connect_loc to listen for something moving over target
	var/static/list/crossed_connections = list(
		COMSIG_ATOM_ENTERED = PROC_REF(on_entered),
	)
	COOLDOWN_DECLARE(message_cooldown)


/datum/component/caltrop/Initialize(min_damage = 0, max_damage = 0, probability = 100, weaken_duration = 6 SECONDS, flags = NONE, list/protected_species, soundfile, del_on_trigger = FALSE)
	if(!isatom(parent))
		return COMPONENT_INCOMPATIBLE

	src.min_damage = min_damage
	src.max_damage = max(min_damage, max_damage)
	src.probability = probability
	src.weaken_duration = weaken_duration
	src.flags = flags
	src.protected_species = protected_species
	src.soundfile = soundfile
	src.del_on_trigger = del_on_trigger

	if(ismovable(parent))
		AddComponent(/datum/component/connect_loc_behalf, parent, crossed_connections)
	else
		RegisterSignal(get_turf(parent), COMSIG_ATOM_ENTERED, PROC_REF(on_entered))


/datum/component/caltrop/InheritComponent(datum/component/caltrop/new_comp, original, min_damage, max_damage, probability, weaken_duration, flags, list/protected_species, soundfile, del_on_trigger)
	if(!original)
		return
	if(!isnull(min_damage))
		src.min_damage = min_damage
	if(!isnull(max_damage))
		src.max_damage = max(min_damage, max_damage)
	if(!isnull(probability))
		src.probability = probability
	if(!isnull(flags))
		src.flags = flags
	if(!isnull(protected_species))
		src.protected_species = protected_species
	if(!isnull(soundfile))
		src.soundfile = soundfile
	if(!isnull(del_on_trigger))
		src.del_on_trigger = del_on_trigger


/datum/component/caltrop/UnregisterFromParent()
	if(ismovable(parent))
		qdel(GetComponent(/datum/component/connect_loc_behalf))


/datum/component/caltrop/proc/on_entered(datum/source, mob/living/carbon/human/arrived, atom/old_loc, list/atom/old_locs)
	SIGNAL_HANDLER

	if(!prob(probability))
		return

	if(!ishuman(arrived))
		return

	if(HAS_TRAIT(arrived, TRAIT_PIERCEIMMUNE))
		return

	if(LAZYIN(protected_species, arrived.dna.species.name))
		return

	if(arrived.movement_type & MOVETYPES_NOT_TOUCHING_GROUND) //check if they are able to pass over us
		//gravity checking only our parent would prevent us from triggering they're using magboots / other gravity assisting items that would cause them to still touch us.
		return

	if(arrived.buckled) //if they're buckled to something, that something should be checked instead.
		return

	if(!(flags & CALTROP_BYPASS_CRAWLING) && arrived.body_position == LYING_DOWN) //if we're not standing we cant step on the caltrop
		return

	if(!(flags & CALTROP_BYPASS_WALKERS) && arrived.m_intent == MOVE_INTENT_WALK)
		return

	var/picked_def_zone = pick(BODY_ZONE_PRECISE_R_FOOT, BODY_ZONE_PRECISE_L_FOOT)
	var/obj/item/organ/external/foot = arrived.get_organ(picked_def_zone)
	if(!foot)
		return

	if(!(flags & CALTROP_BYPASS_ROBOTIC_FOOTS) && foot.is_robotic())
		return

	if(!(flags & CALTROP_BYPASS_SHOES) && ((arrived.wear_suit?.body_parts_covered | arrived.w_uniform?.body_parts_covered | arrived.shoes?.body_parts_covered) & FEET))
		return

	add_attack_logs(arrived, parent, "stepped on [parent]")

	if(COOLDOWN_FINISHED(src, message_cooldown))
		COOLDOWN_START(src, message_cooldown, 1 SECONDS)
		if(arrived.body_position == LYING_DOWN)
			arrived.visible_message(
				span_danger("[arrived] slides on [parent]!"),
				span_userdanger("You slide on [parent]!"),
			)
		else
			arrived.visible_message(
				span_danger("[arrived] steps on [parent]."),
				span_userdanger("You step on [parent]!"),
			)

	if(soundfile)
		playsound(arrived, soundfile, 25, TRUE, -3)

	arrived.apply_damage(rand(min_damage, max_damage), BRUTE, picked_def_zone, sharp = TRUE, used_weapon = parent)
	arrived.Weaken(weaken_duration)

	if(del_on_trigger && !QDELETED(parent))
		qdel(parent)

