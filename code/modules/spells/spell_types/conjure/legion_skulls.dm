/datum/action/cooldown/spell/conjure/legion_skulls
	name = "Summon Skulls"
	desc = "This spell summons three friendly to you legion's skulls."
	school = SCHOOL_LAVALAND
	cooldown_time = 15 SECONDS
	invocation = "TRAKI SUMON!"
	invocation_type = INVOCATION_SHOUT
	button_icon_state = "sumon_skulls"
	summon_type = list(/mob/living/simple_animal/hostile/asteroid/hivelordbrood/legion/magic)
	summon_amount = 3
	summon_radius  = 1
	sound = 'sound/magic/forcewall.ogg'

/datum/action/cooldown/spell/conjure/legion_skulls/post_summon(atom/summoned_object, atom/cast_on)
	var/mob/skull = summoned_object
	var/mob/caster = cast_on
	skull.faction += caster.faction
