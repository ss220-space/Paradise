/datum/action/cooldown/spell/conjure/construct
	name = "Artificer"
	desc = "This spell conjures a construct which may be controlled by Shades"

	cooldown_time = 60 SECONDS
	spell_requirements = SPELL_REQUIRES_NO_ANTIMAGIC

	summon_type = list(/obj/structure/constructshell)

	button_icon_state = "artificer"
	sound = 'sound/magic/summonitems_generic.ogg'
	summon_radius = 0

/datum/action/cooldown/spell/conjure/construct/lesser
	cooldown_time = 3 MINUTES
	background_icon_state = "bg_cult"
	background_icon_state_active = "bg_cult"

/datum/action/cooldown/spell/conjure/construct/lesser/holy
	button_icon_state = "artificer_holy"
	background_icon_state = "bg_spell"
	background_icon_state_active = "bg_spell"
	summon_type = list(/obj/structure/constructshell/holy)
