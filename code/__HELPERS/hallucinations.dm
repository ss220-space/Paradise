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
		// Skip the madness-immune (and the blind), affect everyone else - matching the doc above. This used
		// to (wrongly) check TRAIT_MESON_VISION, so the pulse affected only people WITH meson vision (i.e.
		// almost nobody), which is why the moon ascension aura did nothing.
		if(HAS_TRAIT(nearby_living, TRAIT_MADNESS_IMMUNE))
			continue

		if(nearby_living.is_blind())
			continue

		// Everyone else gets hallucinations.
		var/dist = sqrt(1 / max(1, get_dist(nearby_living, center)))
		nearby_living.AdjustHallucinate(hallucination_duration * dist, bound_upper = hallucination_max_duration)
		if(length(optional_messages))
			to_chat(nearby_living, pick(optional_messages))
