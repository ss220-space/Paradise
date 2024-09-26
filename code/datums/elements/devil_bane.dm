/// Important note: check banes in the procs
/datum/element/devil_bane
	element_flags = ELEMENT_DETACH_ON_HOST_DESTROY|ELEMENT_BESPOKE
	id_arg_index = 2

/datum/element/devil_bane/Attach(datum/target)
    . = ..()
    var/mob/living/carbon/human/human = target

    if(!istype(human) && !human.mind?.has_antag_datum(/datum/antagonist/devil))
        return ELEMENT_INCOMPATIBLE

    RegisterSignal(human, COMSIG_LIVING_EARLY_FLASH_EYES, PROC_REF(flash_eyes))
    RegisterSignal(human, COMSIG_REAGENT_ADDED, PROC_REF(check_reagents))
    RegisterSignal(human, COMSIG_PARENT_ATTACKBY, PROC_REF(attackedby))
    
/datum/element/devil_bane/Detach(datum/target)
    . = ..()
    var/mob/living/carbon/human/human = target

    if(!istype(human))
        return

    UnregisterSignal(human, COMSIG_LIVING_EARLY_FLASH_EYES)
    UnregisterSignal(human, COMSIG_REAGENT_ADDED)
    UnregisterSignal(human, COMSIG_PARENT_ATTACKBY)

/datum/element/devil_bane/proc/flash_eyes(datum/source, intensity, override_blindness_check, affect_silicon, visual, type)
    var/mob/living/carbon/human/human = source
    if(!istype(human))
        return

    var/datum/antagonist/devil/devil = human.mind?.has_antag_datum(/datum/antagonist/devil)
    if(!devil)
        return

    var/damage = intensity - check_eye_prot()
    
    if(devil.bane != BANE_LIGHT)
        return STOP_FLASHING_EYES

    if(!damage && devil.bane == BANE_LIGHT)
		human.mind?.disrupt_spells(0)
        return

    human.mind?.disrupt_spells(-500)

/datum/element/devil_bane/proc/check_reagents(datum/source, datum/reagent, method, volume)
    var/mob/living/carbon/human/human = source
    if(!istype(human))
        return

    var/datum/antagonist/devil/devil = human.mind?.has_antag_datum(/datum/antagonist/devil)
    if(!devil)
        return
    
    if(devil.bane == BANE_SILVER && reagent.id == "silver")
        human.reagents?.add_reagent("toxin", volume)
        
/datum/element/devil_bane/proc/attackedby(datum/source, obj/item/item, mob/attacker, params)
    var/mob/living/carbon/human/human = source
    var/datum/antagonist/devil/devil = human.mind?.has_antag_datum(/datum/antagonist/devil)

    if(!devil)
        return

    switch(devil.bane)
		if(BANE_WHITECLOTHES)
			if(!ishuman(attacker))
				return

			var/mob/living/carbon/human/hunter = attacker
			if(!istype(hunter.w_uniform, /obj/item/clothing/under))
                return

			var/obj/item/clothing/under/uniform = hunter.w_uniform
			if(GLOB.whiteness[uniform.type])
                human.apply_damage(item.force * (GLOB.whiteness[uniform.type] + 1))
				visible_message(span_warning("[human] seems to have been harmed by the purity of [attacker]'s clothes."), span_notice("Unsullied white clothing is disrupting [human] form.")
				return

		if(BANE_TOOLBOX)
			if(istype(item, /obj/item/storage/toolbox))
                human.apply_damage(item.force * BANE_TOOLBOX_DAMAGE_MODIFIER))
				visible_message(span_warning("The [item] seems unusually robust this time."), span_notice("The [item] is [human] unmaking!"))
				return

		if(BANE_HARVEST)
			if(istype(item, /obj/item/reagent_containers/food/snacks/grown/) || istype(item, /obj/item/grown))
                human.apply_damage(item.force * BANE_HARVEST_DAMAGE_MULTIPLIER)
				visible_message(span_warning("The spirits of the harvest aid in the exorcism."), span_notice("The harvest spirits are harming [human]."))
				human.Weaken(4 SECONDS)
				qdel(item)
				return
