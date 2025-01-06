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

    desc = "Чтобы изгнать дьявола, вы должны наполнить его тело святой водой."
    law = "Если ваше тело наполнено святой водой, вы не сможете воскреснуть."

/datum/devil_banish/water/check_banishment()
    return owner.reagents?.has_reagent("holy water")

/datum/devil_banish/coffin
    name = BANISH_COFFIN

    desc = "Этот дьявол вернётся к жизни, если его останки не будут помещены в гроб."
    law = "Если ваше тело находится в гробу, вы не сможете воскреснуть."

/datum/devil_banish/coffin/check_banishment()
    return owner.loc && istype(owner.loc, /obj/structure/closet/coffin)

/datum/devil_banish/formaldehyde
    name = BANISH_FORMALDYHIDE

    desc = "Чтобы изгнать дьявола, вы должны ввести в его безжизненное тело бальзамирующую жидкость."
    law = "Если ваше тело забальзамировано, вы не сможете воскреснуть."

/datum/devil_banish/formaldehyde/check_banishment()
    return owner.reagents?.has_reagent("formaldehyde")

/datum/devil_banish/rune
    name = BANISH_RUNES

    desc = "Этот дьявол воскреснет после смерти, если его рядом не будет руны."
    law = "Если ваше тело находится возле руны, вы не сможете воскреснуть."

/datum/devil_banish/rune/check_banishment()
	return locate(/obj/effect/decal/cleanable/crayon) in range(1, owner)

/datum/devil_banish/candle
    name = BANISH_CANDLES

    desc = "Большое количество зажжённых поблизости свечей помешает дьяволу воскреснуть."
    law = "Если ваше тело находится рядом с зажжёнными свечами, вы не сможете воскреснуть."

/datum/devil_banish/candle/check_banishment()
	var/count = 0

	for(var/obj/item/candle/candle in range(1, owner))
		count += candle.lit

	return count >= 4

/datum/devil_banish/funeral
    name = BANISH_FUNERAL_GARB

    desc = "Если этот дьявол одет в траурные одежды, либо она лежит рядом с ним, то он не сможет воскреснуть."
    law = "Если ваше тело облачено в траурные одежды, вы не сможете воскреснуть."

/datum/devil_banish/funeral/check_banishment()
	if(!ishuman(owner)) // can be true devil
		return FALSE

	var/mob/living/carbon/human/human = owner
	if(human.w_uniform && istype(human.w_uniform, /obj/item/clothing/under/burial))
		return TRUE
			
	return locate(/obj/item/clothing/under/burial) in range(1, human)
