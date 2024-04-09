#define NUTRITION_SUCK_RATE 1
#define BLOOD_SUCK_RATE 2
#define SPLIT_BORDER_BLOOD 300

/mob/living/simple_animal/hostile/living_limb_flesh
	name = "living flesh"
	desc = "A vaguely leg or arm shaped flesh abomination. It pulses, like a heart."
	icon = 'icons/mob/mob.dmi'
	icon_state = "limb"
	icon_living = "limb"
	melee_damage_lower = 10
	melee_damage_upper = 10
	health = 20
	maxHealth = 20
	attack_sound = 'sound/weapons/bite.ogg'
	attacktext = "try to attach to"
	del_on_death = TRUE
	/// The meat bodypart we are currently inside, used to like drain nutrition and dismember and shit
	var/obj/item/organ/external/current_bodypart
	/// The amount of accumulated blood
	var/collect_blood = 0


/mob/living/simple_animal/hostile/living_limb_flesh/Initialize(mapload, obj/item/organ/external/limb)
	. = ..()
	AddComponent(/datum/component/swarming, max_x = 8, max_y = 8)
	// AddElement(/datum/element/death_drops, string_list(list(/obj/effect/gibspawner/generic)))
	if(!isnull(limb))
		register_to_limb(limb)

/mob/living/simple_animal/hostile/living_limb_flesh/Destroy(force)
	. = ..()
	QDEL_NULL(current_bodypart)

/mob/living/simple_animal/hostile/living_limb_flesh/Life(seconds = 2, times_fired)
	. = ..()
	if(stat == DEAD)
		return
	if(collect_blood >= SPLIT_BORDER_BLOOD)
		split_flesh()
	if(isnull(current_bodypart) || isnull(current_bodypart.owner))
		return
	var/mob/living/carbon/human/victim = current_bodypart.owner
	if(SPT_PROB(3, seconds))
		to_chat(victim, span_warning("The thing posing as your limb makes you feel funny...")) //warn em
	//firstly as a sideeffect we drain nutrition from our host
	victim.adjust_nutrition(-NUTRITION_SUCK_RATE)
	if(victim.nutrition == 0)
		detach_self()
		return
	victim.blood_volume = max(victim.blood_volume - BLOOD_SUCK_RATE, 0)
	collect_blood += BLOOD_SUCK_RATE

	if(!SPT_PROB(3, seconds))
		return

	victim.adjustCloneLoss(1)

	if(istype(current_bodypart, /obj/item/organ/external/arm))
		var/list/candidates = list()
		for(var/atom/movable/movable in orange(victim, 1))
			if(movable.anchored)
				continue
			if(movable == victim)
				continue
			if(!victim.Adjacent(movable))
				continue
			candidates += movable
		var/atom/movable/candidate = pick(candidates)
		if(isnull(candidate))
			return
		victim.start_pulling(candidate)
		victim.visible_message(span_warning("[victim][victim.p_s()] [current_bodypart] instinctually starts feeling [candidate]!"))
		return

	if(victim.IsImmobilized())
		return
	step(victim, pick(NORTH, SOUTH, EAST, WEST))
	to_chat(victim, span_warning("Your [current_bodypart] moves on its own!"))

/mob/living/simple_animal/hostile/living_limb_flesh/AttackingTarget()
	. = ..()
	var/mob/living/carbon/human/victim = target
	if(!istype(victim))
		return
	if(!victim.dna || (NO_BLOOD in victim.dna.species.species_traits))
		return
	var/list/available_zones = list(BODY_ZONE_L_ARM, BODY_ZONE_L_LEG, BODY_ZONE_R_ARM, BODY_ZONE_R_LEG)
	var/list/zone_candidates = list()
	for(var/bodypart in available_zones)
		if(!get_location_accessible(victim, bodypart))
			continue
		var/obj/item/organ/external/ext_organ = victim.bodyparts_by_name[bodypart]
		if(ext_organ)
			if(HAS_TRAIT(ext_organ, TRAIT_IGNORED_BY_LIVING_FLESH))
				continue
			if(ext_organ.brute_dam < 10)
				continue
		zone_candidates.Add(bodypart)

	if(!length(zone_candidates))
		return

	var/victim_zone = pick(zone_candidates)
	var/obj/item/organ/external/victim_part = victim.bodyparts_by_name[victim_zone]
	if(isnull(victim_part))
		if(victim.has_pain())
			victim.emote("scream") // dismember already makes them scream so only do this if we aren't doing that
	else
		victim_part.remove()

	var/part_type
	switch(victim_zone)
		if(BODY_ZONE_L_ARM)
			part_type = /obj/item/organ/external/arm/flesh
		if(BODY_ZONE_R_ARM)
			part_type = /obj/item/organ/external/arm/right/flesh
		if(BODY_ZONE_L_LEG)
			part_type = /obj/item/organ/external/leg/flesh
		if(BODY_ZONE_R_LEG)
			part_type = /obj/item/organ/external/leg/right/flesh

	victim.visible_message(span_danger("[src] [victim_part ? "tears off and attaches itself" : "attaches itself"] to where [target][target.p_s()] limb used to be!"))
	current_bodypart = new part_type
	current_bodypart.replaced(victim)
	for(var/children in current_bodypart.convertable_children)
		var/obj/item/organ/external/child = new children
		child.replaced(victim)
	current_bodypart.owner?.update_body()
	current_bodypart.owner?.updatehealth()
	current_bodypart.owner?.UpdateDamageIcon()
	forceMove(current_bodypart)
	register_to_limb(current_bodypart)

/mob/living/simple_animal/hostile/living_limb_flesh/proc/register_to_limb(obj/item/organ/external/part)
	RegisterSignal(part, COMSIG_EXTERNAL_ORGAN_REMOVED, PROC_REF(on_limb_lost))
	RegisterSignal(part.owner, COMSIG_LIVING_DEATH, PROC_REF(owner_died))
	RegisterSignal(part.owner, COMSIG_LIVING_ELECTROCUTE_ACT, PROC_REF(owner_shocked)) //detach if we are shocked, not beneficial for the host but hey its a sideeffect

/mob/living/simple_animal/hostile/living_limb_flesh/proc/owner_shocked(datum/source, shock_damage)
	if(shock_damage < 10)
		return
	var/mob/living/carbon/human/part_owner = current_bodypart.owner
	if(!detach_self())
		return
	var/turf/our_location = get_turf(src)
	our_location.visible_message(span_warning("[part_owner][part_owner.p_s()] [current_bodypart] begins to convulse wildly!"))

/mob/living/simple_animal/hostile/living_limb_flesh/proc/owner_died(datum/source, gibbed)
	SIGNAL_HANDLER
	if(gibbed)
		return
	addtimer(CALLBACK(src, PROC_REF(detach_self)), 1 SECONDS) //we need new hosts, dead people suck!

/mob/living/simple_animal/hostile/living_limb_flesh/proc/detach_self()
	if(isnull(current_bodypart))
		return FALSE
	var/mob/living/carbon/human/victim = current_bodypart.owner
	current_bodypart.remove()
	victim.update_body()
	victim.updatehealth()
	victim.UpdateDamageIcon()
	return TRUE//on_limb_lost should be called after that

/mob/living/simple_animal/hostile/living_limb_flesh/proc/on_limb_lost(source, organ , mob/living/carbon/old_owner)
	SIGNAL_HANDLER
	UnregisterSignal(organ, COMSIG_EXTERNAL_ORGAN_REMOVED)
	UnregisterSignal(old_owner, COMSIG_LIVING_ELECTROCUTE_ACT)
	UnregisterSignal(old_owner, COMSIG_LIVING_DEATH)
	addtimer(CALLBACK(src, PROC_REF(wake_up), organ), 2 SECONDS)

/mob/living/simple_animal/hostile/living_limb_flesh/proc/wake_up(obj/item/organ/external/limb)
	forceMove(limb.drop_location())
	current_bodypart = null
	qdel(limb)
	visible_message(span_warning("[src] begins flailing around!"))
	Shake(6, 6, 0.5 SECONDS)

/mob/living/simple_animal/hostile/living_limb_flesh/proc/split_flesh()
	if(current_bodypart?.owner)
		new /mob/living/simple_animal/hostile/living_limb_flesh(get_turf(current_bodypart.owner))
	else
		new /mob/living/simple_animal/hostile/living_limb_flesh(get_turf(src))

///flesh

/obj/item/organ/external/arm/flesh

/obj/item/organ/external/arm/flesh/Initialize(mapload)
	. = ..()
	ADD_TRAIT(src, TRAIT_IGNORED_BY_LIVING_FLESH, "bodypart")


/obj/item/organ/external/arm/right/flesh

/obj/item/organ/external/arm/right/flesh/Initialize(mapload)
	. = ..()
	ADD_TRAIT(src, TRAIT_IGNORED_BY_LIVING_FLESH, "bodypart")

/obj/item/organ/external/leg/flesh

/obj/item/organ/external/leg/flesh/Initialize(mapload)
	. = ..()
	ADD_TRAIT(src, TRAIT_IGNORED_BY_LIVING_FLESH, "bodypart")

/obj/item/organ/external/leg/right/flesh

/obj/item/organ/external/leg/right/flesh/Initialize(mapload)
	. = ..()
	ADD_TRAIT(src, TRAIT_IGNORED_BY_LIVING_FLESH, "bodypart")

#undef NUTRITION_SUCK_RATE
#undef BLOOD_SUCK_RATE
#undef SPLIT_BORDER_BLOOD
