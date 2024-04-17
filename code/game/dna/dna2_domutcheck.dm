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
	if(!istype(gene) || !gene.block || gene.block < 0 || !istype(mutant) || !mutant.dna || (NO_DNA in mutant.dna.species.species_traits))
		return FALSE

	// Is our gene in activation bounds?
	var/gene_in_bounds = mutant.dna.GetSEState(gene.block)
	// Is our gene currently active?
	var/gene_is_active = gene.is_active(mutant)

	// Do not mutate inherent species abilities
	if(gene_in_bounds && gene_is_active && LAZYIN(mutant.dna.species.default_genes, gene.type))
		return FALSE

	// Gene is in bounds but not active currently
	if(gene_in_bounds && !gene_is_active)
		// If our gene can be activated, we should check for conditions
		if(!gene.can_activate(mutant, flags))
			return FALSE
		gene.activate(mutant, connected, flags)
		return TRUE

	// Gene is active, we should remove it
	if(!gene_in_bounds && gene_is_active)
		// If our gene should be deactivated, we should check for conditions
		if(!gene.can_deactivate(mutant, flags))
			return FALSE
		gene.deactivate(mutant, connected, flags)
		return TRUE

