/mob/living/carbon/human/register_init_signals()
	. = ..()

	RegisterSignal(src, list(SIGNAL_ADDTRAIT(TRAIT_FAT), SIGNAL_REMOVETRAIT(TRAIT_FAT)), PROC_REF(on_fat))

	RegisterSignal(src, SIGNAL_ADDTRAIT(TRAIT_NO_DNA), PROC_REF(on_no_dna_trait_gain))

	RegisterSignal(src, SIGNAL_ADDTRAIT(TRAIT_VIRUSIMMUNE), PROC_REF(on_virusimmune_trait_gain))

	RegisterSignal(src, SIGNAL_ADDTRAIT(TRAIT_NO_HUNGER), PROC_REF(on_no_hunger_trait_gain))

	RegisterSignal(src, SIGNAL_ADDTRAIT(TRAIT_EMBEDIMMUNE), PROC_REF(on_embedimmune_trait_gain))


/// Called when [TRAIT_FAT] is gained or lost
/mob/living/carbon/human/proc/on_fat(datum/source)
	SIGNAL_HANDLER

	if(HAS_TRAIT(src, TRAIT_FAT))
		if(COUNT_TRAIT_SOURCES(src, TRAIT_FAT) == 1)	// the first time's the charm
			to_chat(src, span_alert("Вы вдруг чувствуеете себя пухлым!"))
		add_movespeed_modifier(/datum/movespeed_modifier/obesity)
		add_movespeed_modifier(/datum/movespeed_modifier/obesity_flying)
	else
		to_chat(src, span_notice("Вы снова чувствуете себя в форме!"))
		remove_movespeed_modifier(/datum/movespeed_modifier/obesity)
		remove_movespeed_modifier(/datum/movespeed_modifier/obesity_flying)


/// Called when [TRAIT_NO_DNA] is gained
/mob/living/carbon/human/proc/on_no_dna_trait_gain(datum/source)
	SIGNAL_HANDLER

	for(var/datum/dna/gene/gene as anything in GLOB.dna_genes)
		force_gene_block(gene.block, FALSE)


/// Called when [TRAIT_VIRUSIMMUNE] is gained
/mob/living/carbon/proc/on_virusimmune_trait_gain(datum/source)
	SIGNAL_HANDLER

	if(!LAZYLEN(diseases))
		return

	for(var/datum/disease/disease as anything in diseases)
		if(!disease.ignore_immunity)
			disease.cure()


/// Called when [TRAIT_NO_HUNGER] is gained
/mob/living/carbon/human/proc/on_no_hunger_trait_gain(datum/source)
	SIGNAL_HANDLER

	// When gaining NOHUNGER, we restore nutrition to normal levels, since we no longer interact with the hunger system
	set_nutrition(NUTRITION_LEVEL_FED, forced = TRUE)
	handle_nutrition_alerts()
	satiety = 0
	overeatduration = 0
	REMOVE_TRAIT(src, TRAIT_FAT, FATNESS_TRAIT)


/// Called when [TRAIT_EMBEDIMMUNE] is gained
/mob/living/carbon/human/proc/on_embedimmune_trait_gain(datum/source)
	SIGNAL_HANDLER

	remove_all_embedded_objects(drop_location())

