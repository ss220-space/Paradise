// IPC limbs.
/obj/item/organ/external/head/ipc
	species_type = /datum/species/machine
	can_intake_reagents = 0
	max_damage = 50 //made same as arm, since it is not vital
	min_broken_damage = 30
	encased = null
	status = ORGAN_ROBOT
	emp_resistant = TRUE
	pickup_sound = 'sound/items/handling/component_pickup.ogg'
	drop_sound = 'sound/items/handling/component_drop.ogg'

/obj/item/organ/external/head/ipc/New()
	..()
	robotize(company = "Morpheus Cyberkinetics")

/obj/item/organ/external/chest/ipc
	species_type = /datum/species/machine
	encased = null
	status = ORGAN_ROBOT
	emp_resistant = TRUE
	pickup_sound = 'sound/items/handling/component_pickup.ogg'
	drop_sound = 'sound/items/handling/component_drop.ogg'

/obj/item/organ/external/chest/ipc/New()
	..()
	robotize(company = "Morpheus Cyberkinetics")

/obj/item/organ/external/groin/ipc
	species_type = /datum/species/machine
	encased = null
	status = ORGAN_ROBOT
	emp_resistant = TRUE
	pickup_sound = 'sound/items/handling/component_pickup.ogg'
	drop_sound = 'sound/items/handling/component_drop.ogg'

/obj/item/organ/external/groin/ipc/New()
	..()
	robotize(company = "Morpheus Cyberkinetics")

/obj/item/organ/external/arm/ipc
	species_type = /datum/species/machine
	encased = null
	status = ORGAN_ROBOT
	emp_resistant = TRUE
	pickup_sound = 'sound/items/handling/component_pickup.ogg'
	drop_sound = 'sound/items/handling/component_drop.ogg'

/obj/item/organ/external/arm/ipc/New()
	..()
	robotize(company = "Morpheus Cyberkinetics")

/obj/item/organ/external/arm/right/ipc
	species_type = /datum/species/machine
	encased = null
	status = ORGAN_ROBOT
	emp_resistant = TRUE

/obj/item/organ/external/arm/right/ipc/New()
	..()
	robotize(company = "Morpheus Cyberkinetics")

/obj/item/organ/external/leg/ipc
	species_type = /datum/species/machine
	encased = null
	status = ORGAN_ROBOT
	emp_resistant = TRUE
	pickup_sound = 'sound/items/handling/component_pickup.ogg'
	drop_sound = 'sound/items/handling/component_drop.ogg'

/obj/item/organ/external/leg/ipc/New()
	..()
	robotize(company = "Morpheus Cyberkinetics")

/obj/item/organ/external/leg/right/ipc
	species_type = /datum/species/machine
	encased = null
	status = ORGAN_ROBOT
	emp_resistant = TRUE

/obj/item/organ/external/leg/right/ipc/New()
	..()
	robotize(company = "Morpheus Cyberkinetics")

/obj/item/organ/external/foot/ipc
	species_type = /datum/species/machine
	encased = null
	status = ORGAN_ROBOT
	emp_resistant = TRUE
	pickup_sound = 'sound/items/handling/component_pickup.ogg'
	drop_sound = 'sound/items/handling/component_drop.ogg'

/obj/item/organ/external/foot/ipc/New()
	..()
	robotize(company = "Morpheus Cyberkinetics")

/obj/item/organ/external/foot/right/ipc
	species_type = /datum/species/machine
	encased = null
	status = ORGAN_ROBOT
	emp_resistant = TRUE

/obj/item/organ/external/foot/right/ipc/New()
	..()
	robotize(company = "Morpheus Cyberkinetics")

/obj/item/organ/external/hand/ipc
	species_type = /datum/species/machine
	encased = null
	status = ORGAN_ROBOT
	emp_resistant = TRUE
	pickup_sound = 'sound/items/handling/component_pickup.ogg'
	drop_sound = 'sound/items/handling/component_drop.ogg'

/obj/item/organ/external/hand/ipc/New()
	..()
	robotize(company = "Morpheus Cyberkinetics")

/obj/item/organ/external/hand/right/ipc
	species_type = /datum/species/machine
	encased = null
	status = ORGAN_ROBOT
	emp_resistant = TRUE

/obj/item/organ/external/hand/right/ipc/New()
	..()
	robotize(company = "Morpheus Cyberkinetics")

/obj/item/organ/internal/cell
	species_type = /datum/species/machine
	name = "microbattery"
	desc = "A small, powerful cell for use in fully prosthetic bodies."
	icon = 'icons/obj/engines_and_power/power.dmi'
	icon_state = "scell"
	parent_organ_zone = BODY_ZONE_CHEST
	slot = INTERNAL_ORGAN_HEART
	vital = TRUE
	status = ORGAN_ROBOT
	pickup_sound = 'sound/items/handling/component_pickup.ogg'
	drop_sound = 'sound/items/handling/component_drop.ogg'

/obj/item/organ/internal/eyes/optical_sensor
	species_type = /datum/species/machine
	name = "optical sensor"
	icon = 'icons/obj/robot_component.dmi'
	icon_state = "camera"
	status = ORGAN_ROBOT
//	dead_icon = "camera_broken"
	weld_proof = 1
	pickup_sound = 'sound/items/handling/component_pickup.ogg'
	drop_sound = 'sound/items/handling/component_drop.ogg'

/obj/item/organ/internal/eyes/optical_sensor/remove(mob/living/user, special = ORGAN_MANIPULATION_DEFAULT)
	if(!special)
		to_chat(owner, "Error 404:Optical Sensors not found.")

	. = ..()

/obj/item/organ/internal/brain/mmi_holder/posibrain
	species_type = /datum/species/machine
	name = "positronic brain"
	pickup_sound = 'sound/items/handling/component_pickup.ogg'
	drop_sound = 'sound/items/handling/component_drop.ogg'

/obj/item/organ/internal/brain/mmi_holder/posibrain/New()
	..()
	stored_mmi = new /obj/item/mmi/robotic_brain/positronic(src)
	if(!owner)
		stored_mmi.forceMove(get_turf(src))
		qdel(src)

/obj/item/organ/internal/brain/mmi_holder/posibrain/remove(mob/living/user, special = ORGAN_MANIPULATION_DEFAULT)
	if(stored_mmi && dna)
		stored_mmi.name = "[initial(name)] ([dna.real_name])"
		stored_mmi.brainmob.real_name = dna.real_name
		stored_mmi.brainmob.name = stored_mmi.brainmob.real_name
		stored_mmi.icon_state = "posibrain-occupied"
		if(!stored_mmi.brainmob.dna)
			stored_mmi.brainmob.dna = dna.Clone()
	. = ..()

/obj/item/organ/internal/ears/microphone
	species_type = /datum/species/machine
	name = "microphone"
	icon = 'icons/obj/device.dmi'
	icon_state = "taperecorder_idle"
	status = ORGAN_ROBOT
	dead_icon = "taperecorder_empty"
	pickup_sound = 'sound/items/handling/component_pickup.ogg'
	drop_sound = 'sound/items/handling/component_drop.ogg'

/obj/item/organ/internal/ears/microphone/remove(mob/living/user, special = ORGAN_MANIPULATION_DEFAULT)
	if(!special)
		to_chat(owner, span_userdanger("BZZZZZZZZZZZZZZT! Microphone error!"))
	. = ..()
