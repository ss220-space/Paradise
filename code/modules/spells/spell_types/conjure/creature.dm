/datum/action/cooldown/spell/conjure/creature
	name = "Summon Creature Swarm"
	desc = "This spell tears the fabric of reality, allowing horrific daemons to spill forth"

	cooldown_time = 2 MINUTES
	spell_requirements = SPELL_REQUIRES_NO_ANTIMAGIC
	invocation = "IA IA"
	invocation_type = INVOCATION_SHOUT
	summon_amount = 10

	summon_type = list(/mob/living/simple_animal/hostile/creature)
	sound = 'sound/magic/summonitems_generic.ogg'
	summon_radius = 3
