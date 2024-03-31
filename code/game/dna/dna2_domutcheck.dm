// (Re-)Apply mutations.
// TODO: Turn into a /mob proc, change inj to a bitflag for various forms of differing behavior.
// mutant: Mob to mess with
// connected: Machine we're in, type unchecked so I doubt it's used beyond monkeying
// flags: See below, bitfield.
/proc/domutcheck(mob/living/mutant, connected, flags = NONE)
	for(var/datum/dna/gene/gene as anything in GLOB.dna_genes)
		domutation(gene, mutant, connected, flags)


// Use this to force a mut check on a single gene!
/proc/genemutcheck(mob/living/mutant, block, connected, flags = NONE)
	return domutation(GLOB.assigned_gene_blocks[block], mutant, connected, flags)


/proc/domutation(datum/dna/gene/gene, mob/living/mutant, connected, flags = NONE)
	if(!istype(gene) || !gene.block || gene.block < 0 || !istype(mutant) || !mutant.dna)
		return FALSE

	// Is our gene in activation bounds?
	var/gene_on = mutant.dna.GetSEState(gene.block)
	// Is our gene currently active?
	var/gene_active = gene.is_active(mutant)

	if(mutant.dna.species)
		// Do not mutate inherent species abilities
		if(gene_on && gene_active && LAZYIN(mutant.dna.species.default_genes, gene.type))
			return FALSE

		if(NO_DNA in mutant.dna.species.species_traits)
			return FALSE

	// Gene is in bounds but not active currently
	if(gene_on && !gene_active)
		// If our gene can be activated, we should check for conditions
		if(!gene.can_activate(mutant, flags))
			return FALSE
		INVOKE_ASYNC(gene, TYPE_PROC_REF(/datum/dna/gene, activate), mutant, connected, flags)
		LAZYADD(mutant.active_genes, gene.type)
		return TRUE

	// Gene is active, we should remove it
	if(gene_active)
		INVOKE_ASYNC(gene, TYPE_PROC_REF(/datum/dna/gene, deactivate), mutant, connected, flags)
		LAZYREMOVE(mutant.active_genes, gene.type)
		return TRUE

