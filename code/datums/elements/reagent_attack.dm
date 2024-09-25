/datum/element/reagent_attack
	element_flags = ELEMENT_BESPOKE|ELEMENT_DETACH_ON_HOST_DESTROY
	id_arg_index = 2
	/// Which reagent we will inject
	var/reagent_id
	/// How much reagent we will inject
	var/reagent_amount
	/// Will we inject anyway or check can_inject
	var/piercing
	/// Limitation of our reagent in target
	var/reagent_limit
	/// Override attacking zones
	var/allowed_zones

/datum/element/reagent_attack/Attach(
	atom/source, 
	reagent_id, 
	reagent_amount, 
	piercing, 
	reagent_limit, 
	list/allowed_zones
)
	. = ..()
	if(!isliving(source))
		return ELEMENT_INCOMPATIBLE

	src.reagent_id = reagent_id
	src.reagent_amount = reagent_amount
	src.piercing = piercing
	src.reagent_limit = reagent_limit
	src.allowed_zones = allowed_zones

	RegisterSignal(source, COMSIG_LIVING_UNARMED_ATTACK, PROC_REF(mob_attack))

/datum/element/reagent_attack/Detach(atom/source)
	. = ..()
	UnregisterSignal(source, COMSIG_LIVING_UNARMED_ATTACK)

/datum/element/reagent_attack/proc/mob_attack(datum/source, mob/target, proximity_flag)
	SIGNAL_HANDLER

	var/mob/mob = source
	if(!proximity_flag && mob.a_intent != INTENT_HARM)
		return
		
	var/picked_zone = allowed_zones ? pick(allowed_zones) : mob.zone_selected
	if(!can_inject(target, picked_zone))
		return

	INVOKE_ASYNC(src, PROC_REF(pre_inject), mob, target, picked_zone)

/datum/element/reagent_attack/proc/can_inject(mob/living/carbon/target, target_zone)
	if(!istype(target)) 
		return FALSE

	if(!target.reagents)
		return FALSE

	if(reagent_limit && target.reagents?.has_reagent(reagent_id, reagent_limit))
		return FALSE

	if(!piercing && !target.can_inject(null, FALSE, target_zone, FALSE))
		return FALSE

	return TRUE

/datum/element/reagent_attack/proc/pre_inject(mob/source, mob/living/carbon/target, target_zone)

	if(!inject(source, target))
		return

	SEND_SIGNAL(source, COMSIG_REAGENT_INJECTED, target, reagent_id, reagent_amount, target_zone)
	return

/datum/element/reagent_attack/proc/inject(mob/source, mob/living/carbon/target)
	if(target.reagents.add_reagent(reagent_id, reagent_amount))
		return TRUE

	return FALSE

/datum/element/reagent_attack/bee
	reagent_id = "beetoxin"
	reagent_amount = 5

/datum/element/reagent_attack/bee/inject(mob/source, mob/living/carbon/target)
	var/mob/living/simple_animal/hostile/poison/bees/bee = source
	if(!bee.beegent)
		return ..()

	if(target.reagents.add_reagent(bee.beegent.id, rand(1,5)))
		bee.beegent.reaction_mob(target, REAGENT_INGEST)
		return TRUE

	return FALSE

/datum/element/reagent_attack/widow
	reagent_id = "terror_black_toxin"
	reagent_limit = 100
	reagent_amount = 20
	allowed_zones = list(BODY_ZONE_CHEST, BODY_ZONE_HEAD)

/datum/element/reagent_attack/widow/inject(mob/source, mob/living/carbon/target)
	if(!HAS_TRAIT(target, TRAIT_INCAPACITATED))
		visible_message(span_danger("[src] pierces armour and buries its long fangs deep into the [target_zone] of [target]!"))
		return ..()

	if(target.reagents.add_reagent(reagent_id, 33)) // inject our special poison
		visible_message(span_danger("[src] buries its long fangs deep into the [target_zone] of [target]!"))
		return TRUE

	return FALSE
