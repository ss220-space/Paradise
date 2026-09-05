/datum/action/cooldown/spell/pointed/goliath_tentacles
	name = "Summon Tentacles"
	desc = "Summons a goliath tentacle attack on clicked tile"
	school = SCHOOL_LAVALAND
	cooldown_time = 15 SECONDS
	invocation = "SOGESE DE RAGET'RE!"
	invocation_type = INVOCATION_SHOUT
	button_icon_state = "goliath_tentacles"
	spell_requirements = SPELL_REQUIRES_NO_ANTIMAGIC

/datum/action/cooldown/spell/pointed/goliath_tentacles/cast(atom/cast_on)
	. = ..()
	var/turf/target_turf = get_turf(cast_on)
	new /obj/effect/temp_visual/goliath_tentacle/full_cross(target_turf, owner)
