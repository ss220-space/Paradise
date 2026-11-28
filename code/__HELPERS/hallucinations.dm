/// A global list of all ongoing hallucinations, primarily for easy access to be able to stop (delete) hallucinations.
GLOBAL_LIST_EMPTY(all_ongoing_hallucinations)

// Hallucination tiers
/// Very common hallucinations, minor stuff that'll make you double-take but is otherwise very subtle.
#define HALLUCINATION_TIER_COMMON 1
/// Uncommon hallucinations, more noticeable and potentially more impactful (causing temporary stuns or stamina damage).
#define HALLUCINATION_TIER_UNCOMMON 2
/// Rarer hallucinations which are usually pretty obvious, but also pretty impactful.
#define HALLUCINATION_TIER_RARE 3
/// Hallucinations which are generally just for laughs and are obviously fake
#define HALLUCINATION_TIER_VERYSPECIAL 4
/// Hallucinations which are never picked, only forced
#define HALLUCINATION_TIER_NEVER 5

/// What typepath of the hallucination
#define HALLUCINATION_ARG_TYPE 1
/// Where the hallucination came from, for logging
#define HALLUCINATION_ARG_SOURCE 2

/// Onwards from this index, it's the arglist that gets passed into the hallucination created.
#define HALLUCINATION_ARGLIST 3

// Macro wrapper for _cause_hallucination so we can cheat in named arguments, like AddComponent.
/**
 * Causes a hallucination of a certain type to the mob.
 *
 * First argument is always the type of hallucination, a /datum/hallucination, required.
 * second argument is always the key source of the hallucination, used for admin logging, required.
 *
 * Additionally, named arguments are supported for passing them forward to the created hallucination's new().
 */
#define cause_hallucination(arguments...) _cause_hallucination(list(##arguments))

/// Unless you need this for an explicit reason, use the cause_hallucination wrapper.
/mob/living/proc/_cause_hallucination(list/raw_args)
	if(!length(raw_args))
		CRASH("cause_hallucination called with no arguments.")

	var/datum/hallucination/hallucination_type = raw_args[HALLUCINATION_ARG_TYPE] // first arg is the type always
	if(!ispath(hallucination_type, /datum/hallucination))
		CRASH("cause_hallucination was given a non-hallucination type. (Got: [hallucination_type || "null"])")

	var/hallucination_source = raw_args[HALLUCINATION_ARG_SOURCE] // and second arg, the source
	var/datum/hallucination/new_hallucination

	if(length(raw_args) >= HALLUCINATION_ARGLIST)
		var/list/passed_args = raw_args.Copy(HALLUCINATION_ARGLIST)
		passed_args.Insert(HALLUCINATION_ARG_TYPE, src)

		new_hallucination = new hallucination_type(arglist(passed_args))
	else
		new_hallucination = new hallucination_type(src)

	// For some reason, we qdel'd in New, maybe something went wrong.
	if(QDELETED(new_hallucination))
		return
	// It's not guaranteed that the hallucination passed can successfully be initiated.
	// This means there may be cases where someone should have a hallucination but nothing happens,
	// notably if you pass a randomly picked hallucination type into this.
	// Maybe there should be a separate proc to reroll on failure?
	if(!new_hallucination.start())
		qdel(new_hallucination)
		return

	SEND_SIGNAL(src, COMSIG_LIVING_HALLUCINATING, new_hallucination)
	investigate_log("was afflicted with a hallucination of type [hallucination_type] by: [hallucination_source]. \
		([new_hallucination.feedback_details])", INVESTIGATE_HALLUCINATIONS)
	return new_hallucination

/**
 * Emits a hallucinating pulse around the passed atom.
 * Affects everyone in the passed radius who can view the center,
 * except for those with TRAIT_MADNESS_IMMUNE, or those who are blind.
 *
 * center - required, the center of the pulse
 * radius - the radius around that the pulse reaches
 * hallucination_duration - how much hallucination is added by the pulse. reduced based on distance to the center.
 * hallucination_max_duration - a cap on how much hallucination can be added
 * optional_messages - optional list of messages passed. Those affected by pulses will be given one of the messages in said list.
 */
/proc/visible_hallucination_pulse(atom/center, radius = 7, hallucination_duration = 50 SECONDS, hallucination_max_duration, list/optional_messages)
	for(var/mob/living/nearby_living in view(center, radius))
		if(!HAS_TRAIT(nearby_living, TRAIT_MESON_VISION))
			continue

		if(nearby_living.is_blind())
			continue

		// Everyone else gets hallucinations.
		var/dist = sqrt(1 / max(1, get_dist(nearby_living, center)))
		nearby_living.AdjustHallucinate(hallucination_duration * dist, bound_upper = hallucination_max_duration)
		if(length(optional_messages))
			to_chat(nearby_living, pick(optional_messages))

/**
 * Emits a hallucinating pulse around the passed atom.
 * Affects everyone in the passed radius except for those with TRAIT_MADNESS_IMMUNE. This affects blind players.
 *
 * center - required, the center of the pulse
 * radius - the radius around that the pulse reaches
 * hallucination_duration - how much hallucination is added by the pulse. reduced based on distance to the center.
 * hallucination_max_duration - a cap on how much hallucination can be added
 * optional_messages - optional list of messages passed. Those affected by pulses will be given one of the messages in said list.
 */
/proc/hallucination_pulse(atom/center, radius = 7, hallucination_duration = 50 SECONDS, hallucination_max_duration, list/optional_messages)
	for(var/mob/living/nearby_living in range(center, radius))
		if(!HAS_TRAIT(nearby_living, TRAIT_MESON_VISION))
			continue

		// Everyone else gets hallucinations.
		var/dist = sqrt(1 / max(1, get_dist(nearby_living, center)))
		nearby_living.AdjustHallucinate(hallucination_duration * dist, bound_upper = hallucination_max_duration)
		if(length(optional_messages))
			to_chat(nearby_living, pick(optional_messages))

/// Global weighted list of all hallucinations that can show up randomly.
GLOBAL_LIST_INIT_TYPED(random_hallucination_weighted_list, /list, generate_hallucination_weighted_list())

/// Generates the global weighted list of random hallucinations.
/proc/generate_hallucination_weighted_list()
	var/list/weighted_list = list()

	for(var/datum/hallucination/hallucination_type as anything in typesof(/datum/hallucination))
		if(hallucination_type == initial(hallucination_type.abstract_hallucination_parent))
			continue
		var/weight = initial(hallucination_type.random_hallucination_weight)
		if(weight <= 0)
			continue

		LAZYSET(weighted_list["[initial(hallucination_type.hallucination_tier)]"], hallucination_type, weight)

	return weighted_list

/// Select a random hallucination from the hallucination pool
///
/// * tier - the tier of hallucination to select from
/// * strict - if true, only select from the passed tier. If false, select from the passed tier and all tiers below it.
/proc/get_random_hallucination(tier = HALLUCINATION_TIER_COMMON, strict = FALSE)
	if(!GLOB.random_hallucination_weighted_list[tier])
		CRASH("get_random_hallucination - No hallucinations in tier \[[tier]\].")

	var/list/pool = GLOB.random_hallucination_weighted_list["[tier]"].Copy()
	if(!strict)
		tier -= 1
		while(tier >= HALLUCINATION_TIER_COMMON)
			pool += GLOB.random_hallucination_weighted_list["[tier]"]
			tier -= 1

	return pickweight(pool)

/// Gets a random subtype of the passed hallucination type that has a random_hallucination_weight > 0.
/// If no subtype is passed, it will get any random hallucination subtype that is not abstract and has weight > 0.
/// This can be used instead of picking from the global weighted list to just get a random valid hallucination.
/proc/get_random_valid_hallucination_subtype(passed_type = /datum/hallucination)
	if(!ispath(passed_type, /datum/hallucination))
		CRASH("get_random_valid_hallucination_subtype - get_random_valid_hallucination_subtype passed not a hallucination subtype.")

	for(var/datum/hallucination/hallucination_type as anything in shuffle(subtypesof(passed_type)))
		if(initial(hallucination_type.abstract_hallucination_parent) == hallucination_type)
			continue
		if(initial(hallucination_type.random_hallucination_weight) <= 0)
			continue

		return hallucination_type

	return null
