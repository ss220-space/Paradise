/datum/devil_bane
	var/name
	 
	var/desc
	var/law    

	var/mob/living/carbon/owner
	var/datum/antagonist/devil/devil

	var/bonus_damage = 1	

/datum/devil_bane/Destroy(force)
	remove_bane()
    
	owner = null
	devil = null

	return ..()

/datum/devil_bane/proc/remove_bane()
    return

/datum/devil_bane/proc/link_bane(mob/living/carbon/carbon)
	owner = carbon
	devil = owner.mind?.has_antag_datum(/datum/antagonist/devil)

/datum/devil_bane/proc/init_bane()
	return

/datum/devil_bane/toolbox
    name = BANE_TOOLBOX

    law = "Toolboxes are bad news for you, for some reason."
    desc = "That which holds the means of creation also holds the means of the devil's undoing."

    bonus_damage = BANE_TOOLBOX_DAMAGE_MODIFIER

/datum/devil_bane/toolbox/init_bane()
	RegisterSignal(owner, COMSIG_PARENT_ATTACKBY, PROC_REF(toolbox_attack))

/datum/devil_bane/toolbox/remove_bane()
	UnregisterSignal(owner, COMSIG_PARENT_ATTACKBY)

/datum/devil_bane/toolbox/proc/toolbox_attack(datum/source, obj/item/item, mob/attacker, params)
	SIGNAL_HANDLER

	if(!istype(item, /obj/item/storage/toolbox))
		return

	owner.apply_damage(item.force * bonus_damage)
	item.visible_message(
		span_warning("The [item] seems unusually robust this time."), 
		span_notice("The [item] is [owner] unmaking!"))

/datum/devil_bane/whiteclothes
    name = BANE_WHITECLOTHES

    desc = "Wearing clean white clothing will help ward off this devil."
    law = "Those clad in pristine white garments will strike you true."

/datum/devil_bane/whiteclothes/init_bane()
	RegisterSignal(owner, COMSIG_PARENT_ATTACKBY, PROC_REF(whiteclothes_attack))

/datum/devil_bane/whiteclothes/remove_bane()
	UnregisterSignal(owner, COMSIG_PARENT_ATTACKBY)

/datum/devil_bane/whiteclothes/proc/whiteclothes_attack(datum/source, obj/item/item, mob/attacker, params)
	SIGNAL_HANDLER

	if(!ishuman(attacker))
		return

	var/mob/living/carbon/human/hunter = attacker
	if(!istype(hunter.w_uniform, /obj/item/clothing/under))
		return

	var/obj/item/clothing/under/uniform = hunter.w_uniform
	if(!GLOB.whiteness[uniform.type])
		return

	owner.apply_damage(bonus_damage * (item.force * (GLOB.whiteness[uniform.type] + 1)))
	item.visible_message(span_warning("[owner] seems to have been harmed by the purity of [attacker]'s clothes."), 
	span_notice("Unsullied white clothing is disrupting [owner] form."))

/datum/devil_bane/harvest
    name = BANE_HARVEST

    law = "The fruits of the harvest shall be your downfall."
    desc = "Presenting the labors of a harvest will disrupt the devil."

    bonus_damage = BANE_HARVEST_DAMAGE_MULTIPLIER

/datum/devil_bane/harvest/init_bane()
	RegisterSignal(owner, COMSIG_PARENT_ATTACKBY, PROC_REF(harvest_attack))

/datum/devil_bane/harvest/remove_bane()
	UnregisterSignal(owner, COMSIG_PARENT_ATTACKBY)

/datum/devil_bane/harvest/proc/harvest_attack(datum/source, obj/item/item, mob/attacker, params)
	SIGNAL_HANDLER

	if(!istype(item, /obj/item/reagent_containers/food/snacks/grown) || !istype(item, /obj/item/grown))
		return

	owner.apply_damage(item.force * bonus_damage)               
	item.visible_message(
		span_warning("The spirits of the harvest aid in the exorcism."), 
		span_notice("The harvest spirits are harming [owner]."))

	qdel(item)

/datum/devil_bane/light
    name = BANE_LIGHT

    desc = "Bright flashes will disorient the devil, likely causing him to flee."
    law = "Blinding lights will prevent you from using offensive powers for a time."

/datum/devil_bane/light/init_bane()
	RegisterSignal(owner, COMSIG_LIVING_EARLY_FLASH_EYES, PROC_REF(flash_eyes))

/datum/devil_bane/light/remove_bane()
	UnregisterSignal(owner, COMSIG_LIVING_EARLY_FLASH_EYES)

/datum/devil_bane/light/proc/flash_eyes(datum/source, intensity, override_blindness_check, affect_silicon, visual, type)
    SIGNAL_HANDLER
    
    var/damage = intensity - owner.check_eye_prot()

    if(!damage)
        owner.mind?.disrupt_spells(0)
        return

    owner.mind?.disrupt_spells(-500)

/datum/devil_bane/silver
    name = BANE_SILVER

    desc = "Silver seems to gravely injure this devil."
    law = "Silver, in all of its forms shall be your downfall."

/datum/devil_bane/silver/init_bane()
	RegisterSignal(owner, COMSIG_REAGENT_ADDED, PROC_REF(check_reagents))

/datum/devil_bane/silver/remove_bane()
	UnregisterSignal(owner, COMSIG_REAGENT_ADDED)

/datum/devil_bane/silver/proc/check_reagents(datum/source, datum/reagent/reagent, method, volume)
    SIGNAL_HANDLER

    if(reagent.id != "silver")
        return

    owner.reagents?.add_reagent("toxin", volume * bonus_damage)

/datum/devil_bane/iron
    name = BANE_IRON

    desc = "Cold iron will slowly injure him, until he can purge it from his system."
    law = "Cold wrought iron shall act as poison to you."

    bonus_damage = 1

/datum/devil_bane/iron/init_bane()
	RegisterSignal(owner, COMSIG_REAGENT_ADDED, PROC_REF(check_reagents))

/datum/devil_bane/iron/remove_bane()
	UnregisterSignal(owner, COMSIG_REAGENT_ADDED)

/datum/devil_bane/iron/proc/check_reagents(datum/source, datum/reagent/reagent, method, volume)
    SIGNAL_HANDLER

    if(reagent.id != "iron")
        return
            
    owner.reagents?.add_reagent("toxin", volume * bonus_damage)
