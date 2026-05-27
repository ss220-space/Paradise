/datum/action/cooldown/spell/conjure/construct
	name = "Artificer"
	desc = "This spell conjures a construct which may be controlled by Shades"

	school = SCHOOL_CONJURATION
	cooldown_time = 60 SECONDS
	spell_requirements = SPELL_REQUIRES_NO_ANTIMAGIC

	summon_type = list(/obj/structure/constructshell)

	button_icon_state = "artificer"
	sound = 'sound/magic/summonitems_generic.ogg'
	summon_radius = 0
