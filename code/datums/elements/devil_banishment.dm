/datum/element/devil_banishment
	element_flags = ELEMENT_DETACH_ON_HOST_DESTROY|ELEMENT_BESPOKE
	id_arg_index = 2

	var/linked_timer    

/datum/element/devil_banishment/Attach(datum/target)
    . = ..()
    var/mob/living/carbon/human = target

    if(!istype(human) && !human.mind?.has_antag_datum(/datum/antagonist/devil))
        return ELEMENT_INCOMPATIBLE

    RegisterSignal(human, COMSIG_LIVING_DEATH, PROC_REF(on_death))

/datum/element/devil_banishment/Detach(datum/target)
    . = ..()
    var/mob/living/carbon/human = target

    if(!istype(human))
        return

    UnregisterSignal(human, COMSIG_LIVING_DEATH)

/datum/element/devil_banishment/proc/on_death(datum/source, gibbed)
    SIGNAL_HANDLER

    if(gibbed) // You're not immortal anymore.
        return

    var/mob/living/carbon/human = source
    var/datum/antagonist/devil/devil = human?.mind?.has_antag_datum(/datum/antagonist/devil)

    if(!devil)
        return
    
    playsound(get_turf(human), 'sound/magic/vampire_anabiosis.ogg', 50, 0, TRUE)
    linked_timer = addtimer(CALLBACK(src, PROC_REF(try_banishment), human, devil), devil.regen_threshold / 2, TIMER_LOOP | TIMER_STOPPABLE)

/datum/element/devil_banishment/proc/try_banishment(mob/living/carbon/human, datum/antagonist/devil/devil)
    if(human.stat != DEAD)
        deltimer(linked_timer)
        linked_timer = null
        return
        
    if(!check_banishment(human, devil))
        return

    human.dust()

/datum/element/devil_banishment/proc/check_banishment(mob/living/carbon/human, datum/antagonist/devil/devil)
	switch(devil.banish)
		if(BANISH_WATER)
			return human.reagents?.has_reagent("holy water")

		if(BANISH_COFFIN)
			return (istype(human?.loc, /obj/structure/closet/coffin))

		if(BANISH_FORMALDYHIDE)
			return human.reagents?.has_reagent("formaldehyde")

		if(BANISH_RUNES)
			for(var/obj/effect/decal/cleanable/crayon/R in range(0, human))
				return R.name == "rune"

		if(BANISH_CANDLES)
			var/count = 0

			for(var/obj/item/candle/candle in range(1, human))
				count += candle.lit

			return count >= 4

		if(BANISH_FUNERAL_GARB)
			if(!ishuman(human)) // can be true devil
				return FALSE

			var/mob/living/carbon/human/carbon = human 
			if(carbon.w_uniform && istype(carbon.w_uniform, /obj/item/clothing/under/burial))
				return TRUE
			
			for(var/obj/item/clothing/under/burial/burial in range(0, human))
				return burial.loc == get_turf(burial)

			return FALSE
