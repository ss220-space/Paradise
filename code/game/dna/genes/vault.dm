/datum/dna/gene/basic/vault

/datum/dna/gene/basic/vault/toxin
    name = "Toxin Adaptation"
    
    var/cached_tox_breath_dam_min
    var/cached_tox_breath_dam_max

    traits_to_add = list(TRAIT_VIRUSIMMUNE)

    activation_messages = list(
        span_notice("Ваше тело стало невоспримчивым к токсинам в воздухе.")
        )

/datum/dna/gene/basic/vault/toxin/New()
    ..()
    block = GLOB.vaulttoxinblock

/datum/dna/gene/basic/vault/toxin/activate(mob/living/carbon/human/human, flags)
    . = ..()
    
    var/obj/item/organ/internal/lungs/lungs = human.get_int_organ(/obj/item/organ/internal/lungs)

    if(lungs)
        cached_tox_breath_dam_min = lungs.tox_breath_dam_min
        cached_tox_breath_dam_max = lungs.tox_breath_dam_max

        lungs.tox_breath_dam_min = 0
        lungs.tox_breath_dam_max = 0

/datum/dna/gene/basic/vault/toxin/deactivate(mob/living/carbon/human/human, flags)
    . = ..()
    var/obj/item/organ/internal/lungs/lungs = human.get_int_organ(/obj/item/organ/internal/lungs)

    if(lungs)
        lungs.tox_breath_dam_min = cached_tox_breath_dam_min || initial(lungs.tox_breath_dam_min)
        lungs.tox_breath_dam_max = cached_tox_breath_dam_max || initial(lungs.tox_breath_dam_max)

/datum/dna/gene/basic/vault/nobreath
    name = "Lung Enhancement"

    traits_to_add = list(TRAIT_NO_BREATH)

/datum/dna/gene/basic/vault/nobreath/New()
    ..()
    block = GLOB.vaultnobreathblock

/datum/dna/gene/basic/vault/nobreath/activate(mob/living/carbon/human/human, flags)
    . = ..()
    to_chat(human, span_notice("Вы чувствуете, как нужда в дыхании пропадает."))

/datum/dna/gene/basic/vault/fireproof
    name = "Thermal Regulation"

    traits_to_add = list(TRAIT_RESIST_HEAT)

/datum/dna/gene/basic/vault/fireproof/New()
    ..()
    block = GLOB.vaultfireproofblock

/datum/dna/gene/basic/vault/fireproof/activate(mob/living/carbon/human/human, flags)
    . = ..()
    to_chat(human, span_notice("Вы чувствуете, как ваше тело стало более огнеупорным."))
    human.physiology.burn_mod *= 0.5

/datum/dna/gene/basic/vault/fireproof/deactivate(mob/living/carbon/human/human, flags)
    . = ..()
    human.physiology.burn_mod /= 0.5

/datum/dna/gene/basic/vault/stuntime
    name = "Neural Repathing"

/datum/dna/gene/basic/vault/stuntime/New()
    ..()
    block = GLOB.vaultstuntimeblock

/datum/dna/gene/basic/vault/stuntime/activate(mob/living/carbon/human/human, flags)
    . = ..()
    to_chat(human, span_notice("Ничто не может долго сдерживать вас."))

    human.physiology.stun_mod *= 0.5
    human.physiology.stamina_mod *= 0.5
    human.stam_regen_start_modifier *= 0.5

/datum/dna/gene/basic/vault/stuntime/deactivate(mob/living/carbon/human/human, flags)
    . = ..()
    human.physiology.stun_mod /= 0.5
    human.physiology.stamina_mod /= 0.5
    human.stam_regen_start_modifier /= 0.5

/datum/dna/gene/basic/vault/armour
    name = "Hardened Skin"

    traits_to_add = list(TRAIT_PIERCEIMMUNE)

/datum/dna/gene/basic/vault/armour/New()
    ..()
    block = GLOB.vaultarmourblock

/datum/dna/gene/basic/vault/armour/activate(mob/living/carbon/human/human, flags)
    . = ..()
    to_chat(human, span_notice("Вы чувствуете себя крепче."))

    human.physiology.brute_mod *= 0.7
    human.physiology.burn_mod *= 0.7
    human.physiology.tox_mod *= 0.7
    human.physiology.oxy_mod *= 0.7
    human.physiology.clone_mod *= 0.7
    human.physiology.brain_mod *= 0.7
    human.physiology.stamina_mod *= 0.7

/datum/dna/gene/basic/vault/armour/deactivate(mob/living/carbon/human/human, flags)
    . = ..()
    human.physiology.brute_mod /= 0.7
    human.physiology.burn_mod /= 0.7
    human.physiology.tox_mod /= 0.7
    human.physiology.oxy_mod /= 0.7
    human.physiology.clone_mod /= 0.7
    human.physiology.brain_mod /= 0.7
    human.physiology.stamina_mod /= 0.7

/datum/dna/gene/basic/vault/speedlegs
    name = "Leg Muscle Stimulus"

/datum/dna/gene/basic/vault/speedlegs/New()
    ..()
    block = GLOB.vaultspeedlegsblock

/datum/dna/gene/basic/vault/speedlegs/activate(mob/living/carbon/human/human, flags)
    . = ..()
    to_chat(human, span_notice("Вы чувствуете себя быстрее и ловче."))

    human.add_movespeed_modifier(/datum/movespeed_modifier/dna_vault_speedup)

/datum/dna/gene/basic/vault/speedlegs/deactivate(mob/living/carbon/human/human, flags)
    . = ..()
    human.remove_movespeed_modifier(/datum/movespeed_modifier/dna_vault_speedup)

/datum/dna/gene/basic/vault/quickarms
    name = "Arm Muscle Stimulus"

/datum/dna/gene/basic/vault/quickarms/New()
    ..()
    block = GLOB.vaultquickarmsblock

/datum/dna/gene/basic/vault/quickarms/activate(mob/living/carbon/human/human, flags)
    . = ..()
    to_chat(human, span_notice("Ваши руки двигаются также быстро, как и молния."))
    human.next_move_modifier *= 0.5

/datum/dna/gene/basic/vault/quickarms/deactivate(mob/living/carbon/human/human, flags)
    . = ..()
    human.next_move_modifier /= 0.5
