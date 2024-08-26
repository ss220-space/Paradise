/**
 * Checks all mob genes and activates/deactivates them
 * depending on current block bounds.
 *
 * Arguments:
 * * flags - flags to consider
 */
/mob/proc/check_genes(flags = NONE)
	return


/mob/living/carbon/human/check_genes(flags = NONE)	// only humans have the DNA now, subject to change later
	for(var/datum/dna/gene/gene as anything in GLOB.dna_genes)
		update_gene_status(gene, flags)


/**
 * Checks provided DNA block and activates/deactivates it
 * depending on current block bounds.
 *
 * Arguments:
 * * block - block to check
 * * flags - flags to consider
 *
 * Returns TRUE if any changes were made, FALSE otherwise
 */
/mob/proc/check_gene_block(block, flags = NONE)
	return FALSE


/mob/living/carbon/human/check_gene_block(block, flags = NONE)
	return update_gene_status(GLOB.assigned_gene_blocks[block], flags)


/**
 * Actual meat of gene buisness
 *
 * Arguments:
 * * gene - passed gene to check
 * * flags - flags to consider
 *
 * Returns TRUE if any changes were made, FALSE otherwise
 */
/mob/living/carbon/human/proc/update_gene_status(datum/dna/gene/gene, flags = NONE)
	// If human mob has no DNA its better runtime to tell us,
	// since its involves some hacky code elsewhere
	if(!dna)
		CRASH("Mob [real_name] has no DNA assigned.")

	var/datum/species/our_species = dna.species
	// Another stuff that should never happen
	if(!our_species)
		CRASH("Mob [real_name] somehow has a DNA, but no species assigned.")

	if(HAS_TRAIT(src, TRAIT_NO_DNA))
		return FALSE

	// Is our gene in activation bounds?
	var/gene_in_bounds = dna.GetSEState(gene.block)
	// Is our gene currently active?
	var/gene_is_active = gene.is_active(src)

	// Stops mutating inherent species abilities,
	// but allows us to activate them in the first place
	if(gene_is_active && !(flags & MUTCHK_IGNORE_DEFAULT) && LAZYIN(our_species.default_genes, gene.type))
		return FALSE

	// Gene is in bounds but not active currently
	if(gene_in_bounds && !gene_is_active)
		// If our gene should be activated, we need to check for conditions
		if(!gene.can_activate(src, flags))
			return FALSE
		// Some procs have sleeps in them, like monkafication
		INVOKE_ASYNC(gene, TYPE_PROC_REF(/datum/dna/gene, activate), src, flags)
		return TRUE

	// Same with deactivation stuff
	if(!gene_in_bounds && gene_is_active)
		if(!gene.can_deactivate(src, flags))
			return FALSE
		INVOKE_ASYNC(gene, TYPE_PROC_REF(/datum/dna/gene, deactivate), src, flags)
		return TRUE

	return FALSE


/**
 * Helper for the most used case of activation/deactivation of the single gene.
 * Gene variable (`/datum/dna/var/default_genes`) is NOT the same as species variable (`/datum/species/var/default_genes`).
 * Gene variable is used to mark roundstart genes, and its function is to prevent mutadone from reseting this gene currently.
 * Species variable is used to prevent gene deactivation, unless MUTCHK_IGNORE_DEFAULT flag is present.
 *
 * Arguments:
 * * block - block to manipulate with.
 * * activate - `TRUE` for activate, `FALSE` for deactivate.
 * * update_default_status - whether to add/remove this block in/from `gene default_genes` variable.
 * * ignore_species_default - if `TRUE` gene will be always removed, even if it belongs to `species default_genes` variable.
 *
 * Returns `TRUE` if a gene was changed, `FALSE` otherwise.
 */
/mob/proc/force_gene_block(block, activate = FALSE, update_default_status = FALSE, ignore_species_default = FALSE)
	return


/mob/living/carbon/human/force_gene_block(block, activate = FALSE, update_default_status = FALSE, ignore_species_default = FALSE)
	var/force_flags = MUTCHK_FORCED
	if(ignore_species_default)
		force_flags |= MUTCHK_IGNORE_DEFAULT
	dna.SetSEState(block, activate)
	. = check_gene_block(block, force_flags)
	if(. && update_default_status)
		if(activate)
			LAZYOR(dna.default_blocks, block)
		else
			LAZYREMOVE(dna.default_blocks, block)

