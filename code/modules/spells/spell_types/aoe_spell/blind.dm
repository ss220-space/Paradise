/datum/action/cooldown/spell/aoe/blind
	name = "Blind"
	desc = "This spell temporarily blinds people near you and does not require wizard garb."
	school = SCHOOL_TRANSMUTATION
	button_icon_state = "blind"
	spell_requirements = SPELL_REQUIRES_NO_ANTIMAGIC
	invocation = "STI KALY"
	invocation_type = INVOCATION_WHISPER
	cooldown_time = 30 SECONDS
	cooldown_reduction_per_rank = 1.2 SECONDS
	max_targets = 10
	aoe_radius = 10

/datum/action/cooldown/spell/aoe/blind/get_things_to_cast_on(atom/center)
	var/list/things = list()
	for(var/mob/living/nearby_mob in range(aoe_radius, center))
		if(nearby_mob == owner || nearby_mob == center)
			continue

		things += nearby_mob

	return things

/datum/action/cooldown/spell/aoe/blind/cast_on_thing_in_aoe(mob/living/victim, atom/caster)
	victim.AdjustEyeBlind(8 SECONDS)
	to_chat(victim, span_notice_alt("Your eyes cry out in pain!"))
