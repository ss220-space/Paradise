/datum/species/nucleation
	name = SPECIES_NUCLEATION
	name_plural = "Nucleations"
	icobase = 'icons/mob/human_races/r_nucleation.dmi'
	blacklisted = TRUE
	blurb = "A sub-race of unfortunates who have been exposed to too much supermatter radiation. As a result, \
	supermatter crystal clusters have begun to grow across their bodies. Research to find a cure for this ailment \
	has been slow, and so this is a common fate for veteran engineers. The supermatter crystals produce oxygen, \
	negating the need for the individual to breathe. Their massive change in biology, however, renders most medicines \
	obselete. Ionizing radiation seems to cause resonance in some of their crystals, which seems to encourage regeneration \
	and produces a calming effect on the individual. Nucleations are highly stigmatized, and are treated much in the same \
	way as lepers were back on Earth."
	language = LANGUAGE_SOL_COMMON
	blood_color = "#ada776"
	burn_mod = 4 // holy shite, poor guys wont survive half a second cooking smores
	brute_mod = 2 // damn, double wham, double dam

	inherent_traits = list(
		TRAIT_NO_BLOOD,
		TRAIT_HAS_LIPS,
		TRAIT_NO_BREATH,
		TRAIT_NO_SCAN,
		TRAIT_NO_PAIN,
		TRAIT_NO_PAIN_HUD,
		TRAIT_RADIMMUNE,
		TRAIT_VIRUSIMMUNE,
		TRAIT_NO_GERMS,
		TRAIT_IGNOREDAMAGESLOWDOWN,
	)
	dies_at_threshold = TRUE
	var/touched_supermatter = FALSE

	speciesbox = /obj/item/storage/box/survival_nucleation

	//Default styles for created mobs.
	default_hair = "Nucleation Crystals"

	reagent_tag = PROCESS_ORG
	has_organ = list(
		INTERNAL_ORGAN_HEART = /obj/item/organ/internal/heart,
		INTERNAL_ORGAN_BRAIN = /obj/item/organ/internal/brain/crystal,
		INTERNAL_ORGAN_EYES = /obj/item/organ/internal/eyes/luminescent_crystal, //Standard darksight of 2.
		INTERNAL_ORGAN_EARS = /obj/item/organ/internal/ears,
		INTERNAL_ORGAN_STRANGE_CRYSTAL = /obj/item/organ/internal/nucleation/strange_crystal,
		INTERNAL_ORGAN_RESONANT_CRYSTAL = /obj/item/organ/internal/nucleation/resonant_crystal,
	)


	meat_type = /obj/item/reagent_containers/food/snacks/meat/humanoid/nucleation


/datum/species/nucleation/on_species_gain(mob/living/carbon/human/H)
	. = ..()
	H.light_color = "#afaf21"
	H.set_light_range(2)


/datum/species/nucleation/on_species_loss(mob/living/carbon/human/H)
	. = ..()
	H.light_color = null
	H.set_light_on(FALSE)


/datum/species/nucleation/handle_reagents(mob/living/carbon/human/H, datum/reagent/R)
	if(R.id == "radium")
		if(R.volume >= 1)
			H.heal_overall_damage(3, 3)
			H.reagents.remove_reagent(R.id, 1)
			if(H.radiation < 80)
				H.apply_effect(4, IRRADIATE, negate_armor = 1)
			return FALSE //Что бы не выводилось больше одного, который уже вывелся за счет прока
	return ..()

/datum/species/nucleation/handle_death(gibbed, mob/living/carbon/human/H)
	if(H.health <= HEALTH_THRESHOLD_DEAD || !H.surgeries.len) // Needed to prevent brain gib on surgery debrain
		death_explosion(H)
		return
	H.adjustBruteLoss(15)
	H.do_jitter_animation(1000, 8)

/datum/species/nucleation/proc/death_explosion(mob/living/carbon/human/H)
	var/turf/T = get_turf(H)
	H.visible_message("<span class='warning'>Тело [H] взрывается, оставляя после себя множество микроскопических кристаллов!</span>")
	explosion(T, 0, 0, 3, 6, cause = H) // Create a small explosion burst upon death
	qdel(H)
