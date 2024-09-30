/datum/devil_banish
    var/name
    
    var/desc
    var/law

    var/mob/living/carbon/owner
    var/datum/antagonist/devil/devil

/datum/devil_banish/proc/link_banish(mob/living/carbon/carbon)
    owner = carbon
    devil = carbon.mind?.has_antag_datum(/datum/antagonist/devil)

/datum/devil_banish/proc/remove_banish()
    owner = null
    devil = null

/datum/devil_banish/Destroy(force)
    remove_banish()

    return ..()

/datum/devil_banish/proc/check_banishment()
    return

/datum/devil_banish/water
    name = BANISH_WATER

    desc = "To banish the devil, you must infuse its body with holy water."
    law = "If your corpse is filled with holy water, you will be unable to resurrect."

/datum/devil_banish/water/check_banishment()
    return owner.reagents?.has_reagent("holy water")

/datum/devil_banish/coffin
    name = BANISH_COFFIN

    desc = "This devil will return to life if its remains are not placed within a coffin."
    law = "If your corpse is in a coffin, you will be unable to resurrect."

/datum/devil_banish/coffin/check_banishment()
    return (istype(owner.loc, /obj/structure/closet/coffin))

/datum/devil_banish/formaldehyde
    name = BANISH_FORMALDYHIDE

    desc = "To banish the devil, you must inject its lifeless body with embalming fluid."
    law = "If your corpse is embalmed, you will be unable to resurrect."

/datum/devil_banish/formaldehyde/check_banishment()
    return owner.reagents?.has_reagent("formaldehyde")

/datum/devil_banish/rune
    name = BANISH_RUNES

    desc = "This devil will resurrect after death, unless its remains are within a rune."
    law = "If your corpse is placed within a rune, you will be unable to resurrect."

/datum/devil_banish/rune/check_banishment()
	for(var/obj/effect/decal/cleanable/crayon/rune in range(0, owner))
		return rune.name == "rune"

/datum/devil_banish/candle
    name = BANISH_CANDLES

    desc = "A large number of nearby lit candles will prevent it from resurrecting."
    law = "If your corpse is near lit candles, you will be unable to resurrect."

/datum/devil_banish/candle/check_banishment()
	var/count = 0

	for(var/obj/item/candle/candle in range(1, owner))
		count += candle.lit

	return count >= 4

/datum/devil_banish/funeral
    name = BANISH_FUNERAL_GARB

    desc = "If clad in funeral garments, this devil will be unable to resurrect. Should the clothes not fit, lay them gently on top of the devil's corpse."
    law = "If your corpse is clad in funeral garments, you will be unable to resurrect."

/datum/devil_banish/funeral/check_banishment()
	if(!ishuman(owner)) // can be true devil
		return FALSE

	var/mob/living/carbon/human/human = owner
	if(human.w_uniform && istype(human.w_uniform, /obj/item/clothing/under/burial))
		return TRUE
			
	for(var/obj/item/clothing/under/burial/burial in range(0, human))
		return burial.loc == get_turf(burial)
