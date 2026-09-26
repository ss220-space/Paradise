/datum/action/cooldown/spell/aoe/sintouch
	name = "Прикосновение греха"
	desc = "Данное заклинание тонко подталкивает смертных к греху."

	cooldown_time  = 180 SECONDS

	spell_requirements = SPELL_REQUIRES_NO_ANTIMAGIC

	button_icon_state = "sintouch"
	background_icon_state = "bg_demon"

	invocation = "PERVENIRE ET THESAUROS REPERIRE!"
	invocation_type = INVOCATION_SHOUT
	aoe_radius = 2
	max_targets = 3
	targeting_type = /datum/aoe_targeting/human

/datum/action/cooldown/spell/aoe/sintouch/ascended
	name = "Великое прикосновение греха"
	cooldown_time = 10 SECONDS
	max_targets = 10

/datum/action/cooldown/spell/aoe/sintouch/cast_on_thing_in_aoe(atom/victim, atom/caster)
	var/mob/living/carbon/human/human = victim
	if(!human.mind)
		return

	if(!human.mind.hasSoul)
		return

	if(human.mind.has_antag_datum(/datum/antagonist/sintouched))
		return

	human.mind.add_antag_datum(/datum/antagonist/sintouched)
	human.Weaken(4 SECONDS)
