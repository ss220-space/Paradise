/obj/projectile/organ
	name = "organ"
	damage = 0
	hitsound = 'sound/effects/attackblob.ogg'
	hitsound_wall = 'sound/effects/attackblob.ogg'
	ricochet_chance = 0
	/// A reference to the organ we "are".
	var/obj/item/organ/internal/organ

/obj/projectile/organ/Initialize(mapload, obj/item/stored_organ)
	. = ..()
	if(!stored_organ)
		return INITIALIZE_HINT_QDEL
	appearance = stored_organ.appearance
	stored_organ.forceMove(src)
	organ = stored_organ
	ru_names = organ.get_ru_names()

/obj/projectile/organ/Destroy()
	organ = null
	return ..()

/obj/projectile/organ/on_hit(atom/target, blocked = 0, pierce_hit)
	. = ..()
	if(!isliving(target))
		organ.forceMove(drop_location())
		organ = null
		return
	var/mob/living/carbon/human/organ_receiver = target
	var/succeed = FALSE
	if(organ_receiver.surgeries.len)
		for(var/datum/surgery/organ_manipulation/procedure in organ_receiver.surgeries)
			if(procedure.location != organ.parent_organ_zone)
				continue
			if(!ispath(procedure.steps[procedure.step_number], /datum/surgery_step/proxy/manipulate_organs))
				continue
			succeed = TRUE
			break

	if(!succeed)
		organ.forceMove(drop_location())
		organ = null
		return

	var/list/organs_to_boot_out = organ_receiver.get_organ_slot(organ.parent_organ_zone)
	for(var/obj/item/organ/internal/organ_evacced as anything in organs_to_boot_out)
		organ_evacced.remove(target)
		organ_evacced.forceMove(get_turf(target))

	organ.insert(target)
	organ = null
