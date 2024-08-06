///////////////////////////////////
// POWERS
///////////////////////////////////

/datum/dna/gene/basic/nobreath
	name = "No Breathing"
	activation_messages = list("Вы не чувствуете необходимости дышать.")
	deactivation_messages = list("Вы снова чувствуете необходимость дышать.")
	instability = GENE_INSTABILITY_MODERATE
	mutation = BREATHLESS
	activation_prob = 25

/datum/dna/gene/basic/nobreath/New()
	..()
	block = GLOB.breathlessblock


/datum/dna/gene/basic/regenerate
	name = "Regenerate"
	activation_messages = list("Ваши раны начинают заживать.")
	deactivation_messages = list("Кажется, что ваши регенеративные способности исчезли.")
	instability = GENE_INSTABILITY_MINOR
	mutation = REGEN

/datum/dna/gene/basic/regenerate/New()
	..()
	block = GLOB.regenerateblock


/datum/dna/gene/basic/regenerate/OnMobLife(mob/living/carbon/human/H)
	H.heal_overall_damage(0.1, 0.1)


/datum/dna/gene/basic/increaserun
	name = "Super Speed"
	activation_messages = list("Вы чувствуете себя быстрым и незамедлимым.")
	deactivation_messages = list("Вы чувствуете себя медленным.")
	instability = GENE_INSTABILITY_MINOR
	mutation = RUN

/datum/dna/gene/basic/increaserun/New()
	..()
	block = GLOB.increaserunblock


/datum/dna/gene/basic/increaserun/can_activate(mob/living/mutant, flags)
	. = ..()
	if(mutant.dna.species.speed_mod && !(flags & MUTCHK_FORCED))
		return FALSE


/datum/dna/gene/basic/increaserun/activate(mob/living/mutant, flags)
	. = ..()
	mutant.ignore_slowdown(RUN)


/datum/dna/gene/basic/increaserun/deactivate(mob/living/mutant, flags)
	. = ..()
	mutant.unignore_slowdown(RUN)


/datum/dna/gene/basic/heat_resist
	name = "Heat Resistance"
	activation_messages = list("Ваша кожа ледяная на ощупь.")
	deactivation_messages = list("Ваша кожа больше не ледяная на ощупь.")
	instability = GENE_INSTABILITY_MODERATE
	mutation = HEATRES

/datum/dna/gene/basic/heat_resist/New()
	..()
	block = GLOB.coldblock

/datum/dna/gene/basic/heat_resist/OnDrawUnderlays(mob/M, g)
	return "cold_s"

/datum/dna/gene/basic/cold_resist
	name = "Cold Resistance"
	activation_messages = list("Ваше тело наполняется теплом.")
	deactivation_messages = list("Ваше тело больше не наполненно теплом.")
	instability = GENE_INSTABILITY_MODERATE
	mutation = COLDRES

/datum/dna/gene/basic/cold_resist/New()
	..()
	block = GLOB.fireblock

/datum/dna/gene/basic/cold_resist/OnDrawUnderlays(mob/M, g)
	return "fire_s"

/datum/dna/gene/basic/noprints
	name = "No Prints"
	activation_messages = list("Ваши пальцы немеют.")
	deactivation_messages = list("Ваши пальцы больше не чувствуются онемевшими.")
	instability = GENE_INSTABILITY_MINOR
	mutation = FINGERPRINTS

/datum/dna/gene/basic/noprints/New()
	..()
	block = GLOB.noprintsblock

/datum/dna/gene/basic/noshock
	name = "Shock Immunity"
	activation_messages = list("Ваша кожа становится сухой и инертной.")
	deactivation_messages = list("Ваша кожа больше не чувствует себя сухой и инертной.")
	instability = GENE_INSTABILITY_MODERATE
	mutation = NO_SHOCK
	traits_to_add = list(TRAIT_SHOCKIMMUNE)

/datum/dna/gene/basic/noshock/New()
	..()
	block = GLOB.shockimmunityblock

/datum/dna/gene/basic/midget
	name = "Midget"
	activation_messages = list("Теперь все вокруг вас кажется больше...")
	deactivation_messages = list("Кажется, что все вокруг вас сжимается...")
	instability = GENE_INSTABILITY_MINOR
	mutation = DWARF

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
	activation_messages = list("Ваши мышци болят.")
	deactivation_messages = list("Ваши мышцы сжимаются.")
	instability = GENE_INSTABILITY_MAJOR
	mutation = HULK
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
	activation_messages = list("Стены внезапно исчезли.")
	deactivation_messages = list("Стены вокруг вас снова появляются.")
	instability = GENE_INSTABILITY_MAJOR
	mutation = XRAY
	activation_prob = 15

/datum/dna/gene/basic/xray/New()
	..()
	block = GLOB.xrayblock


/datum/dna/gene/basic/xray/activate(mob/living/mutant, flags)
	. = ..()
	mutant.update_sight()
	mutant.update_icons() //Apply eyeshine as needed.


/datum/dna/gene/basic/xray/deactivate(mob/living/mutant, flags)
	. = ..()
	mutant.update_sight()
	mutant.update_icons() //Remove eyeshine as needed.


/datum/dna/gene/basic/tk
	name = "Telekenesis"
	activation_messages = list("Вы чувствуете себя умнее.")
	deactivation_messages = list("Вы чувствуете себя глупее.")
	instability = GENE_INSTABILITY_MAJOR
	mutation = TK
	activation_prob = 15

/datum/dna/gene/basic/tk/New()
	..()
	block = GLOB.teleblock

/datum/dna/gene/basic/tk/OnDrawUnderlays(mob/M, g)
	return "telekinesishead_s"
