/datum/action/cooldown/spell/conjure/floor
	name = "Summon Cult Floor"
	desc = "This spell constructs a cult floor"
	button_icon_state = "floorconstruct"
	background_icon_state = "bg_cult"
	background_icon_state_active = "bg_cult"
	cooldown_time = 2 SECONDS
	spell_requirements = SPELL_REQUIRES_NO_ANTIMAGIC
	summon_type = list(/turf/simulated/floor/engine/cult)
	summon_radius = 0

/datum/action/cooldown/spell/conjure/floor/can_cast_spell(feedback)
	var/turf/caster_t = get_turf(owner)
	if(is_admin_level(caster_t.z)) //Stop crashing the server by spawning turfs on transit tiles
		return FALSE
	return ..()

/datum/action/cooldown/spell/conjure/floor/holy
	name = "Summon Holy Floor"
	desc = "Это заклинание создаст святой пол."
	button_icon_state = "holyfloorconstruct"
	background_icon_state = "bg_spell"
	background_icon_state_active = "bg_spell"
	summon_type = list(/turf/simulated/floor/engine/cult/holy)

/datum/action/cooldown/spell/conjure/wall
	name = "Summon Cult Wall"
	desc = "This spell constructs a cult wall"
	button_icon_state = "cultforcewall"
	background_icon_state = "bg_cult"
	background_icon_state_active = "bg_cult"
	spell_requirements = SPELL_REQUIRES_NO_ANTIMAGIC
	//holy_area_cancast = FALSE //Stops cult magic from working on holy ground eg: chapel
	summon_type = list(/turf/simulated/wall/cult/artificer) //we don't want artificer-based runed metal farms
	summon_radius = 0
	cooldown_time = 10 SECONDS

/datum/action/cooldown/spell/conjure/wall/holy
	name = "Summon Holy Wall"
	desc = "Это заклинание создаст святую стену, способную сдержать врагов. Впрочем, вы можете легко её разрушить."
	button_icon_state = "holyforcewall"
	background_icon_state = "bg_spell"
	background_icon_state_active = "bg_spell"
	summon_type = list(/turf/simulated/wall/cult/artificer/holy)

/datum/action/cooldown/spell/conjure/wall/reinforced
	name = "Greater Construction"
	desc = "This spell constructs a reinforced metal wall"
	cooldown_time = 30 SECONDS
	create_summon_timer = 5 SECONDS
	//holy_area_cancast = FALSE //Stops cult magic from working on holy ground eg: chapel
	summon_type = list(/turf/simulated/wall/r_wall)

/datum/action/cooldown/spell/conjure/pylon
	name = "Cult Pylon"
	desc = "This spell conjures a fragile crystal from Redspace. Makes for a convenient light source."
	button_icon_state = "pylon"
	background_icon_state = "bg_cult"
	background_icon_state_active = "bg_cult"
	cooldown_time = 20 SECONDS
	spell_requirements = SPELL_REQUIRES_NO_ANTIMAGIC
	//holy_area_cancast = FALSE //Stops cult magic from working on holy ground eg: chapel
	summon_type = list(/obj/structure/cult/functional/pylon)
	summon_radius = 0

/datum/action/cooldown/spell/conjure/pylon/holy
	name = "Holy Pylon"
	desc = "Это заклинание создаст уязвимый к повреждениям кристалл, что будет немного лечить иных коснтруктов"
	button_icon_state = "holy_pylon"
	background_icon_state = "bg_spell"
	background_icon_state_active = "bg_spell"
	summon_type = list(/obj/structure/cult/functional/pylon/holy)

/datum/action/cooldown/spell/conjure/lesserforcewall
	name = "Shield"
	desc = "This spell creates a temporary forcefield to shield yourself and allies from incoming fire"
	button_icon_state = "cultforcewall"
	background_icon_state = "bg_cult"
	background_icon_state_active = "bg_cult"
	school = SCHOOL_TRANSMUTATION
	cooldown_time = 30 SECONDS
	spell_requirements = SPELL_REQUIRES_NO_ANTIMAGIC
	//holy_area_cancast = FALSE //Stops cult magic from working on holy ground eg: chapel
	summon_lifespan = 20 SECONDS
	summon_type = list(/obj/effect/forcefield/cult)
	summon_radius = 0

/datum/action/cooldown/spell/conjure/lesserforcewall/holy
	button_icon_state = "holyforcewall"
	background_icon_state = "bg_spell"
	background_icon_state_active = "bg_spell"
	summon_type = list(/obj/effect/forcefield/holy)

/obj/effect/forcefield/cult
	desc = "That eerie looking obstacle seems to have been pulled from another dimension through sheer force"
	name = "eldritch wall"
	icon = 'icons/effects/cult_effects.dmi'
	icon_state = "m_shield_cult"
	light_color = LIGHT_COLOR_INTENSE_RED

/obj/effect/forcefield/holy
	desc = "Этот щит так и светится! Не похоже что его можно будет убрать так просто."
	name = "holy field"
	icon = 'icons/effects/cult_effects.dmi'
	icon_state = "holy_field"
	light_color = LIGHT_COLOR_DARK_BLUE
