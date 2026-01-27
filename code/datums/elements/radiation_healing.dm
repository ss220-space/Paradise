#define BRUTE_HEAL_AMOUNT 3
#define BRUTE_HEAL_COST 2

#define BURN_HEAL_AMOUNT 3
#define BURN_HEAL_COST 1

#define INTERNAL_HEAL_AMOUNT 3
#define INTERNAL_HEAL_COST 3

#define FRACTURE_HEAL_COST 10

#define PASSIVE_RAD_DRAIN 1


/datum/element/radiation_healing
	element_flags = ELEMENT_DETACH_ON_HOST_DESTROY

/datum/element/radiation_healing/Attach(datum/target)
	. = ..()

	if(!ishuman(target))
		return ELEMENT_INCOMPATIBLE

	RegisterSignal(target, COMSIG_LIVING_LIFE, PROC_REF(try_healing))

/datum/element/radiation_healing/Detach(datum/source)
	. = ..()
	UnregisterSignal(source, COMSIG_LIVING_LIFE)

/datum/element/radiation_healing/proc/try_healing(mob/living/carbon/human/human, deltatime, times_fired)
	SIGNAL_HANDLER

	if(isnull(human) || QDELETED(human))
		return

	if(human.radiation <= 0)
		return

	process_radiation_healing(human)


/datum/element/radiation_healing/proc/process_radiation_healing(mob/living/carbon/human/human)
	human.radiation = clamp(human.radiation, 0, human.max_radiation)

	//external healing in high priority
	var/heal_cost = 0
	var/heal_brute = 0
	var/heal_burn = 0

	if(human.getBruteLoss() > 0)
		heal_cost += BRUTE_HEAL_COST
		heal_brute = BRUTE_HEAL_AMOUNT

	if(human.getFireLoss() > 0)
		heal_cost += BURN_HEAL_COST
		heal_burn = BURN_HEAL_AMOUNT

	var/heal_mod = 1

	if(human.isInCrit() && human.radiation >= heal_cost * 2)
		heal_mod = 2

	if(human.radiation >= heal_cost * heal_mod)
		human.radiation = human.radiation - heal_cost * heal_mod
		human.heal_overall_damage(heal_brute * heal_mod, heal_burn * heal_mod)

	//internal healing in medium priority. Using radium won't heal internal damage while healing external damage
	var/list/obj/item/organ/internal/int_damaged_organs = human.get_damaged_organs(flags = AFFECT_ORGANIC_INTERNAL_PARTS)
	var/int_damaged_organs_amount = length(int_damaged_organs)

	if(int_damaged_organs_amount && human.radiation >= INTERNAL_HEAL_COST)
		var/obj/item/organ/internal/organ = pick(int_damaged_organs)
		organ.unnecrotize()
		organ.heal_internal_damage(INTERNAL_HEAL_AMOUNT)
		human.radiation = human.radiation - INTERNAL_HEAL_COST

	//healing fractures in low priotiry. Won't heal fractures while healing internal or external damage with radium
	var/list/obj/item/organ/external/fractured_limbs = human.check_fractures()

	if(human.radiation >= FRACTURE_HEAL_COST && length(fractured_limbs))
		var/obj/item/organ/external/limb = pick(fractured_limbs)
		limb.mend_fracture()
		human.radiation = human.radiation - FRACTURE_HEAL_COST

	if(HAS_TRAIT(human, TRAIT_NO_RADIATION_EFFECTS)) // TRAIT_NO_RADIATION_EFFECTS stops radiation effects including passive radiation drain, so we drain it passively here
		human.radiation = max(human.radiation - PASSIVE_RAD_DRAIN, 0)


#undef BRUTE_HEAL_AMOUNT
#undef BRUTE_HEAL_COST
#undef BURN_HEAL_AMOUNT
#undef BURN_HEAL_COST
#undef INTERNAL_HEAL_AMOUNT
#undef INTERNAL_HEAL_COST
#undef FRACTURE_HEAL_COST
#undef PASSIVE_RAD_DRAIN
