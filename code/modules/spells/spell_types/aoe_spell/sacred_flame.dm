/datum/action/cooldown/spell/aoe/sacred_flame
	name = "Sacred Flame"
	desc = "Makes everyone around you more flammable, and lights yourself on fire."
	cooldown_time = 6 SECONDS
	spell_requirements = SPELL_REQUIRES_NO_ANTIMAGIC
	invocation = "FI'RAN DADISKO"
	invocation_type = INVOCATION_SHOUT
	button_icon_state = "sacredflame"
	sound = 'sound/magic/fireball.ogg'
	targeting_type = /datum/aoe_targeting/living

/datum/action/cooldown/spell/aoe/sacred_flame/cast_on_thing_in_aoe(mob/living/victim, atom/caster)
	victim.adjust_fire_stacks(20)
	victim.IgniteMob()
	if(isliving(caster))
		if(!HAS_TRAIT(caster, TRAIT_RESIST_HEAT))
			ADD_TRAIT(caster, TRAIT_RESIST_HEAT, MAGIC_TRAIT)
			to_chat(caster, span_notice("Ты стал огнестойким."))
		var/mob/living/ign_caster = caster
		ign_caster.IgniteMob()
