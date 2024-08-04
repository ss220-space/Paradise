/obj/item/organ/internal/ears
	name = "ears"
	icon_state = "ears"
	gender = PLURAL
	parent_organ_zone = BODY_ZONE_HEAD
	slot = INTERNAL_ORGAN_EARS

/obj/item/organ/internal/ears/on_life()
	if(!iscarbon(owner))
		return
	var/mob/living/carbon/C = owner

	if(!istype(C))
		return

	// if we have non-damage related deafness like mutations, quirks or clothing (earmuffs), don't bother processing here. Ear healing from earmuffs or chems happen elsewhere
	if(HAS_TRAIT_NOT_FROM(C, TRAIT_DEAF, EAR_DAMAGE))
		return

	if(is_dead())
		C.Deaf(2 SECONDS)
	else
		if((damage > 10) && prob(damage / 30))
			C.Deaf(8 SECONDS)

	if(ishuman(C))
		var/mob/living/carbon/human/H = C
		if((H.l_ear && (H.l_ear.item_flags & HEALS_EARS)) || (H.r_ear && (H.r_ear.item_flags & HEALS_EARS)))
			H.AdjustDeaf(-1 SECONDS)
			heal_internal_damage(0.1)



/obj/item/organ/internal/ears/has_damage()
	. = ..()
	if(.)
		return .
	if(owner.AmountDeaf())
		return TRUE

/obj/item/organ/internal/ears/surgeryize()
	owner?.SetDeaf(0)
	heal_internal_damage(100)

/obj/item/organ/internal/ears/cybernetic
	name = "cybernetic ears"
	icon_state = "ears-c"
	desc = "a basic cybernetic designed to mimic the operation of ears."
	origin_tech = "biotech=4"
	status = ORGAN_ROBOT
	pickup_sound = 'sound/items/handling/component_pickup.ogg'
	drop_sound = 'sound/items/handling/component_drop.ogg'

/obj/item/organ/internal/ears/cybernetic/emp_act(severity)
	if(emp_proof)
		return
	..()
	internal_receive_damage(30)
	if(!iscarbon(owner))
		return
	var/mob/living/carbon/C = owner
	C.AdjustDeaf(120 SECONDS)
