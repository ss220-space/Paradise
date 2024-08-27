///////////////////////////////////
// POWERS
///////////////////////////////////

/datum/dna/gene/basic/nobreath
	name = "No Breathing"
	activation_messages = list("You feel no need to breathe.")
	deactivation_messages = list("You feel the need to breathe, once more.")
	instability = GENE_INSTABILITY_MODERATE
	activation_prob = 25
	traits_to_add = list(TRAIT_NO_BREATH)


/datum/dna/gene/basic/nobreath/New()
	..()
	block = GLOB.breathlessblock


/datum/dna/gene/basic/regenerate
	name = "Regenerate"
	activation_messages = list("Your wounds start healing.")
	deactivation_messages = list("Your regenerative powers feel like they've vanished.")
	instability = GENE_INSTABILITY_MODERATE


/datum/dna/gene/basic/regenerate/New()
	..()
	block = GLOB.regenerateblock


/datum/dna/gene/basic/regenerate/OnMobLife(mob/living/carbon/human/H)
	H.heal_overall_damage(2.5, 2.5)


/datum/dna/gene/basic/increaserun
	name = "Super Speed"
	activation_messages = list("You feel swift and unencumbered.")
	deactivation_messages = list("You feel slow.")
	instability = GENE_INSTABILITY_MINOR


/datum/dna/gene/basic/increaserun/New()
	..()
	block = GLOB.increaserunblock


/datum/dna/gene/basic/increaserun/can_activate(mob/living/mutant, flags)
	. = ..()
	if(mutant.dna.species.speed_mod && !(flags & MUTCHK_FORCED))
		return FALSE


/datum/dna/gene/basic/increaserun/activate(mob/living/mutant, flags)
	. = ..()
	mutant.ignore_slowdown(DNA_TRAIT)


/datum/dna/gene/basic/increaserun/deactivate(mob/living/mutant, flags)
	. = ..()
	mutant.unignore_slowdown(DNA_TRAIT)


/datum/dna/gene/basic/heat_resist
	name = "Heat Resistance"
	activation_messages = list("Your skin is icy to the touch.")
	deactivation_messages = list("Your skin no longer feels icy to the touch.")
	instability = GENE_INSTABILITY_MODERATE
	traits_to_add = list(TRAIT_RESIST_HEAT)


/datum/dna/gene/basic/heat_resist/New()
	..()
	block = GLOB.coldblock


/datum/dna/gene/basic/heat_resist/OnDrawUnderlays(mob/M, g)
	return "cold_s"


/datum/dna/gene/basic/cold_resist
	name = "Cold Resistance"
	activation_messages = list("Your body is filled with warmth.")
	deactivation_messages = list("Your body is no longer filled with warmth.")
	instability = GENE_INSTABILITY_MODERATE
	traits_to_add = list(TRAIT_RESIST_COLD)


/datum/dna/gene/basic/cold_resist/New()
	..()
	block = GLOB.fireblock


/datum/dna/gene/basic/cold_resist/OnDrawUnderlays(mob/M, g)
	return "fire_s"


/datum/dna/gene/basic/noprints
	name = "No Prints"
	activation_messages = list("Your fingers feel numb.")
	deactivation_messages = list("your fingers no longer feel numb.")
	instability = GENE_INSTABILITY_MINOR
	traits_to_add = list(TRAIT_NO_FINGERPRINTS)


/datum/dna/gene/basic/noprints/New()
	..()
	block = GLOB.noprintsblock


/datum/dna/gene/basic/noshock
	name = "Shock Immunity"
	activation_messages = list("Your skin feels dry and unreactive.")
	deactivation_messages = list("Your skin no longer feels dry and unreactive.")
	instability = GENE_INSTABILITY_MODERATE
	traits_to_add = list(TRAIT_SHOCKIMMUNE)


/datum/dna/gene/basic/noshock/New()
	..()
	block = GLOB.shockimmunityblock


/datum/dna/gene/basic/midget
	name = "Midget"
	activation_messages = list("Everything around you seems bigger now...")
	deactivation_messages = list("Everything around you seems to shrink...")
	instability = GENE_INSTABILITY_MINOR
	traits_to_add = list(TRAIT_DWARF)


/datum/dna/gene/basic/midget/New()
	..()
	block = GLOB.smallsizeblock


/datum/dna/gene/basic/midget/activate(mob/living/mutant, flags)
	. = ..()
	mutant.pass_flags |= PASSTABLE
	mutant.update_transform(0.8)


/datum/dna/gene/basic/midget/deactivate(mob/living/mutant, flags)
	. = ..()
	mutant.pass_flags &= ~PASSTABLE
	mutant.update_transform(1.25)


// OLD HULK BEHAVIOR
/datum/dna/gene/basic/hulk
	name = "Hulk"
	activation_messages = list("Your muscles hurt.")
	deactivation_messages = list("Your muscles shrink.")
	instability = GENE_INSTABILITY_MAJOR
	traits_to_add = list(TRAIT_HULK)
	activation_prob = 15


/datum/dna/gene/basic/hulk/New()
	..()
	block = GLOB.hulkblock


/datum/dna/gene/basic/hulk/activate(mob/living/carbon/human/mutant, flags)
	. = ..()
	mutant.AddSpell(new /obj/effect/proc_holder/spell/hulk_transform)
	mutant.update_body(TRUE)


/datum/dna/gene/basic/hulk/deactivate(mob/living/carbon/human/mutant, flags)
	. = ..()
	mutant.RemoveSpell(/obj/effect/proc_holder/spell/hulk_transform)
	mutant.update_body(TRUE)


/datum/dna/gene/basic/hulk/OnDrawUnderlays(mob/M, g)
	return "hulk_[g]_s"


/datum/dna/gene/basic/xray
	name = "X-Ray Vision"
	activation_messages = list("The walls suddenly disappear.")
	deactivation_messages = list("the walls around you re-appear.")
	instability = GENE_INSTABILITY_MAJOR
	traits_to_add = list(TRAIT_XRAY)
	activation_prob = 15


/datum/dna/gene/basic/xray/New()
	..()
	block = GLOB.xrayblock


/datum/dna/gene/basic/xray/activate(mob/living/mutant, flags)
	. = ..()
	mutant.update_sight()
	mutant.update_misc_effects() //Apply eyeshine as needed.


/datum/dna/gene/basic/xray/deactivate(mob/living/mutant, flags)
	. = ..()
	mutant.update_sight()
	mutant.update_misc_effects() //Remove eyeshine as needed.


/datum/dna/gene/basic/tk
	name = "Telekenesis"
	activation_messages = list("You feel smarter.")
	deactivation_messages = list("You feel dumber.")
	instability = GENE_INSTABILITY_MAJOR
	traits_to_add = list(TRAIT_TELEKINESIS)
	activation_prob = 15


/datum/dna/gene/basic/tk/New()
	..()
	block = GLOB.teleblock


/datum/dna/gene/basic/tk/OnDrawUnderlays(mob/M, g)
	return "telekinesishead_s"


/datum/dna/gene/basic/farvision
	name = "Far vision"
	activation_messages = list("Вы можете видеть дальше чем раньше.")
	deactivation_messages = list("Дальность вашего взора вернулась к нормальному состоянию")
	instability = GENE_INSTABILITY_MODERATE


/datum/dna/gene/basic/farvision/New()
	..()
	block = GLOB.farvisionblock


/datum/dna/gene/basic/farvision/activate(mob/living/mutant, flags)
	. = ..()
	mutant.AddSpell(new /obj/effect/proc_holder/spell/view_range/genetic)


/datum/dna/gene/basic/farvision/deactivate(mob/living/mutant, flags)
	. = ..()
	mutant.RemoveSpell(/obj/effect/proc_holder/spell/view_range/genetic)

