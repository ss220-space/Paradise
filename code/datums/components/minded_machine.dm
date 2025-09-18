/datum/component/minded_machine
	dupe_mode = COMPONENT_DUPE_ALLOWED


/datum/component/minded_machine/Initialize(mob/living/target)
	if(!istype(target))
		return COMPONENT_INCOMPATIBLE

	if(!ismachinery(parent))
		return COMPONENT_INCOMPATIBLE

	var/mob/living/machinery_mind/machinery_mind = new(parent)
	target.mind.transfer_to(machinery_mind)


/mob/living/machinery_mind

/mob/living/machinery_mind/Initialize(obj/machinery/machinery)
	. = ..()
	name = machinery.name
	desc = machinery.desc
	icon = machinery.icon // For correct ghost image.
	icon_state = machinery.icon_state
	maxHealth = machinery.max_integrity
	health = maxHealth

/mob/living/machinery_mind/ClickOn(atom/target, params)
	if(target != loc)
		return ..()

	var/obj/machinery/+
