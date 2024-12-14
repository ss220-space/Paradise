/datum/vault_gene
    var/name

/datum/vault_gene/proc/apply(mob/living/carbon/human/human, source)
    return

/datum/vault_gene/proc/remove(mob/living/carbon/human/human, source)
    return

/datum/vault_gene/toxin
	name = "Toxin Adaptation"
    
	var/cached_tox_breath_dam_min
	var/cached_tox_breath_dam_max

/datum/vault_gene/toxin/apply(mob/living/carbon/human/human, source)
	to_chat(human, span_notice("Ваше тело стало невоспримчиво к токсинам в воздухе."))
    
	var/obj/item/organ/internal/lungs/lungs = human.get_int_organ(/obj/item/organ/internal/lungs)

	if(lungs)
		cached_tox_breath_dam_min = lungs.tox_breath_dam_min
		cached_tox_breath_dam_max = lungs.tox_breath_dam_max

		lungs.tox_breath_dam_min = 0
		lungs.tox_breath_dam_max = 0

	ADD_TRAIT(human, TRAIT_VIRUSIMMUNE, source)

/datum/vault_gene/toxin/remove(mob/living/carbon/human/human, source)
	var/obj/item/organ/internal/lungs/lungs = human.get_int_organ(/obj/item/organ/internal/lungs)

	if(lungs)
		lungs.tox_breath_dam_min = cached_tox_breath_dam_min || initial(lungs.tox_breath_dam_min)
		lungs.tox_breath_dam_max = cached_tox_breath_dam_max || initial(lungs.tox_breath_dam_max)

	REMOVE_TRAIT(human, TRAIT_VIRUSIMMUNE, source)

/datum/vault_gene/nobreath
    name = "Lung Enhancement"

/datum/vault_gene/nobreath/apply(mob/living/carbon/human/human, source)
	to_chat(human, span_notice("Вы чувствуете, как нужда в дыхании пропадает."))
    
	ADD_TRAIT(human, TRAIT_NO_BREATH, source)

/datum/vault_gene/nobreath/remove(mob/living/carbon/human/human, source)
    REMOVE_TRAIT(human, TRAIT_NO_BREATH, source)

/datum/vault_gene/fireproof
    name = "Thermal Regulation"

/datum/vault_gene/fireproof/apply(mob/living/carbon/human/human, source)
	to_chat(human, span_notice("Вы чувствуете, как ваше тело стало более огнеупорным."))
	human.physiology.burn_mod *= 0.5

	ADD_TRAIT(human, TRAIT_RESIST_HEAT, source)

/datum/vault_gene/fireproof/remove(mob/living/carbon/human/human, source)
	human.physiology.burn_mod /= 0.5

	REMOVE_TRAIT(human, TRAIT_RESIST_HEAT, source)

/datum/vault_gene/stuntime
    name = "Neural Repathing"

/datum/vault_gene/stuntime/apply(mob/living/carbon/human/human, source)
	to_chat(human, span_notice("Ничто не может долго сдерживать вас."))

	human.physiology.stun_mod *= 0.5
	human.physiology.stamina_mod *= 0.5
	human.stam_regen_start_modifier *= 0.5

/datum/vault_gene/stuntime/remove(mob/living/carbon/human/human, source)
	human.physiology.stun_mod /= 0.5
	human.physiology.stamina_mod /= 0.5
	human.stam_regen_start_modifier /= 0.5

/datum/vault_gene/armour
    name = "Hardened Skin"

/datum/vault_gene/armour/apply(mob/living/carbon/human/human, source)
	to_chat(human, span_notice("Вы чувствуете себя крепче."))

	human.physiology.brute_mod *= 0.7
	human.physiology.burn_mod *= 0.7
	human.physiology.tox_mod *= 0.7
	human.physiology.oxy_mod *= 0.7
	human.physiology.clone_mod *= 0.7
	human.physiology.brain_mod *= 0.7
	human.physiology.stamina_mod *= 0.7

	ADD_TRAIT(human, TRAIT_PIERCEIMMUNE, source)

/datum/vault_gene/armour/remove(mob/living/carbon/human/human, source)
	human.physiology.brute_mod /= 0.7
	human.physiology.burn_mod /= 0.7
	human.physiology.tox_mod /= 0.7
	human.physiology.oxy_mod /= 0.7
	human.physiology.clone_mod /= 0.7
	human.physiology.brain_mod /= 0.7
	human.physiology.stamina_mod /= 0.7

	REMOVE_TRAIT(human, TRAIT_PIERCEIMMUNE, source)

/datum/vault_gene/speedlegs
    name = "Leg Muscle Stimulus"

/datum/vault_gene/speedlegs/apply(mob/living/carbon/human/human, source)
	to_chat(human, span_notice("Вы чувствуете себя быстрее и ловче."))
	human.add_movespeed_modifier(/datum/movespeed_modifier/dna_vault_speedup)

/datum/vault_gene/speedlegs/remove(mob/living/carbon/human/human, source)
    human.remove_movespeed_modifier(/datum/movespeed_modifier/dna_vault_speedup)

/datum/vault_gene/quickarms
    name = "Arm Muscle Stimulus"

/datum/vault_gene/quickarms/apply(mob/living/carbon/human/human, source)
    to_chat(human, span_notice("Ваши руки двигаются также быстро, как и молния."))
    human.next_move_modifier *= 0.5

/datum/vault_gene/proc/remove(mob/living/carbon/human/human, source)
    human.next_move_modifier /= 0.5
