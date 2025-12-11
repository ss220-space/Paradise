/datum/holotool_mode
	/// Display name of the mode
	var/name = "???"
	/// Icon state for this mode
	var/icon_id = null
	/// Sound played when using the tool in this mode
	var/sound
	/// Tool behavior type
	var/behavior
	/// Speed multiplier for work
	var/speed = 0.5

/datum/holotool_mode/proc/can_be_used(obj/item/holotool/tool)
	return TRUE

/datum/holotool_mode/proc/on_set(obj/item/holotool/tool)
	tool.usesound = sound ? sound : 'sound/items/pshoom.ogg'
	tool.toolspeed = speed ? speed : 1
	tool.tool_behaviour = behavior ? behavior : null

/datum/holotool_mode/proc/on_unset(obj/item/holotool/tool)
	tool.usesound = initial(tool.usesound)
	tool.toolspeed = initial(tool.toolspeed)
	tool.tool_behaviour = initial(tool.tool_behaviour)

/datum/holotool_mode/screwdriver
	name = "отвёртка"
	icon_id = "holo-screwdriver"
	sound = 'sound/items/pshoom.ogg'
	behavior = TOOL_SCREWDRIVER

/datum/holotool_mode/crowbar
	name = "монтировка"
	icon_id = "holo-crowbar"
	sound = 'sound/weapons/sonic_jackhammer.ogg'
	behavior = TOOL_CROWBAR

/datum/holotool_mode/multitool
	name = "мультиметр"
	icon_id = "holo-multitool"
	sound = 'sound/weapons/tap.ogg'
	behavior = TOOL_MULTITOOL

/datum/holotool_mode/wrench
	name = "гаечный ключ"
	icon_id = "holo-wrench"
	sound = 'sound/effects/empulse.ogg'
	behavior = TOOL_WRENCH

/datum/holotool_mode/wirecutters
	name = "кусачки"
	icon_id = "holo-wirecutters"
	sound = 'sound/items/jaws_cut.ogg'
	behavior = TOOL_WIRECUTTER

/datum/holotool_mode/welder
	name = "сварочный аппарат"
	icon_id = "holo-welder"
	sound = list('sound/items/welder.ogg', 'sound/items/welder2.ogg')
	behavior = TOOL_WELDER

/datum/holotool_mode/knife
	name = "нож"
	icon_id = "holo-knife"
	sound = 'sound/weapons/blade1.ogg'

/datum/holotool_mode/off
	name = "выключено"
	icon_id = "off"
	sound = 'sound/items/jaws_cut.ogg'

/datum/holotool_mode/knife/can_be_used(obj/item/holotool/tool)
	return tool.emagged

/datum/holotool_mode/knife/on_set(obj/item/holotool/tool)
	. = ..()
	tool.sharp = TRUE
	tool.force = 17
	tool.attack_verb = list("поранил", "порезал")
	tool.armour_penetration = 45
	tool.embed_chance = 40
	tool.embedded_fall_chance = 0
	tool.embedded_pain_multiplier = 5
	tool.hitsound = 'sound/weapons/blade1.ogg'

/datum/holotool_mode/knife/on_unset(obj/item/holotool/tool)
	. = ..()
	tool.sharp = initial(tool.sharp)
	tool.force = initial(tool.force)
	tool.attack_verb = initial(tool.attack_verb)
	tool.armour_penetration = initial(tool.armour_penetration)
	tool.embed_chance = initial(tool.embed_chance)
	tool.embedded_fall_chance = initial(tool.embedded_fall_chance)
	tool.embedded_pain_multiplier = initial(tool.embedded_pain_multiplier)
	tool.hitsound = initial(tool.hitsound)
