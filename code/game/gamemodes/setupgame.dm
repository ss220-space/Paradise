/proc/getAssignedBlock(name, list/blocksLeft, activity_bounds = DNA_DEFAULT_BOUNDS, good = FALSE)
	if(!length(blocksLeft))
		warning("[name]: No more blocks left to assign!")
		return 0
	var/assigned = pick(blocksLeft)
	blocksLeft.Remove(assigned)
	if(good)
		GLOB.good_blocks += assigned
	else
		GLOB.bad_blocks += assigned
	GLOB.assigned_blocks[assigned] = name
	GLOB.dna_activity_bounds[assigned] = activity_bounds
	return assigned


/proc/setupgenetics()

	if(prob(50))
		GLOB.blockadd = rand(-300,300)
	if(prob(75))
		GLOB.diffmut = rand(0,20)

	// SE blocks to assign.
	var/list/numsToAssign= list()
	for(var/i in 1 to DNA_SE_LENGTH - 1) //Because it's inclusive
		numsToAssign += i

	// Standard muts
	GLOB.blindblock				= getAssignedBlock("BLINDNESS", numsToAssign)
	GLOB.colourblindblock		= getAssignedBlock("COLOURBLIND", numsToAssign)
	GLOB.deafblock				= getAssignedBlock("DEAF", numsToAssign)
	GLOB.hulkblock				= getAssignedBlock("HULK", numsToAssign,			DNA_HARD_BOUNDS,		good = TRUE)
	GLOB.teleblock				= getAssignedBlock("TELE", numsToAssign,			DNA_HARD_BOUNDS,		good = TRUE)
	GLOB.fireblock				= getAssignedBlock("FIRE", numsToAssign,			DNA_HARDER_BOUNDS,		good = TRUE)
	GLOB.xrayblock				= getAssignedBlock("XRAY", numsToAssign,			DNA_HARDER_BOUNDS,		good = TRUE)
	GLOB.farvisionblock			= getAssignedBlock("FARVISION", numsToAssign,		DNA_HARD_BOUNDS,		good = TRUE)
	GLOB.clumsyblock			= getAssignedBlock("CLUMSY", numsToAssign)
	GLOB.coughblock				= getAssignedBlock("COUGH", numsToAssign)
	GLOB.glassesblock			= getAssignedBlock("GLASSES", numsToAssign)
	GLOB.epilepsyblock			= getAssignedBlock("EPILEPSY", numsToAssign)
	GLOB.twitchblock			= getAssignedBlock("TWITCH", numsToAssign)
	GLOB.nervousblock			= getAssignedBlock("NERVOUS", numsToAssign)
	GLOB.wingdingsblock			= getAssignedBlock("WINGDINGS", numsToAssign)

	// fake empty genes
	GLOB.fakeblock1				= getAssignedBlock("", numsToAssign)
	GLOB.fakeblock2				= getAssignedBlock("", numsToAssign)
	GLOB.fakeblock3				= getAssignedBlock("", numsToAssign)
	GLOB.fakeblock4				= getAssignedBlock("", numsToAssign)

	// Bay muts
	GLOB.breathlessblock		= getAssignedBlock("BREATHLESS", numsToAssign,		DNA_HARD_BOUNDS,		good = TRUE)
	GLOB.remoteviewblock		= getAssignedBlock("REMOTEVIEW", numsToAssign,		DNA_HARDER_BOUNDS,		good = TRUE)
	GLOB.regenerateblock		= getAssignedBlock("REGENERATE", numsToAssign,		DNA_HARDER_BOUNDS,		good = TRUE)
	GLOB.increaserunblock		= getAssignedBlock("INCREASERUN", numsToAssign,		DNA_HARDER_BOUNDS,		good = TRUE)
	GLOB.remotetalkblock		= getAssignedBlock("REMOTETALK", numsToAssign,		DNA_HARDER_BOUNDS,		good = TRUE)
	GLOB.morphblock				= getAssignedBlock("MORPH", numsToAssign,			DNA_HARDER_BOUNDS,		good = TRUE)
	GLOB.coldblock				= getAssignedBlock("COLD", numsToAssign,									good = TRUE)
	GLOB.hallucinationblock		= getAssignedBlock("HALLUCINATION", numsToAssign)
	GLOB.noprintsblock			= getAssignedBlock("NOPRINTS", numsToAssign,		DNA_HARD_BOUNDS,		good = TRUE)
	GLOB.shockimmunityblock		= getAssignedBlock("SHOCKIMMUNITY", numsToAssign,							good = TRUE)
	GLOB.smallsizeblock			= getAssignedBlock("SMALLSIZE", numsToAssign,		DNA_HARD_BOUNDS,		good = TRUE)

	//
	// Goon muts
	/////////////////////////////////////////////

	// Disabilities
	GLOB.lispblock				= getAssignedBlock("LISP", numsToAssign)
	GLOB.muteblock				= getAssignedBlock("MUTE", numsToAssign)
	GLOB.radblock				= getAssignedBlock("RAD", numsToAssign)
	GLOB.obesityblock			= getAssignedBlock("OBESITY", numsToAssign)
	GLOB.swedeblock				= getAssignedBlock("SWEDE", numsToAssign)
	GLOB.scrambleblock			= getAssignedBlock("SCRAMBLE", numsToAssign)
	GLOB.weakblock				= getAssignedBlock("WEAK", numsToAssign)
	GLOB.hornsblock				= getAssignedBlock("HORNS", numsToAssign)
	GLOB.comicblock				= getAssignedBlock("COMIC", numsToAssign)

	// Powers
	GLOB.soberblock				= getAssignedBlock("SOBER", numsToAssign,									good = TRUE)
	GLOB.psyresistblock			= getAssignedBlock("PSYRESIST", numsToAssign,		DNA_HARD_BOUNDS,		good = TRUE)
	GLOB.shadowblock			= getAssignedBlock("SHADOW", numsToAssign,			DNA_HARDER_BOUNDS,		good = TRUE)
	GLOB.chameleonblock			= getAssignedBlock("CHAMELEON", numsToAssign,		DNA_HARDER_BOUNDS,		good = TRUE)
	GLOB.cryoblock				= getAssignedBlock("CRYO", numsToAssign,			DNA_HARD_BOUNDS,		good = TRUE)
	GLOB.eatblock				= getAssignedBlock("EAT", numsToAssign,				DNA_HARD_BOUNDS,		good = TRUE)
	GLOB.jumpblock				= getAssignedBlock("JUMP", numsToAssign,			DNA_HARD_BOUNDS,		good = TRUE)
	GLOB.immolateblock			= getAssignedBlock("IMMOLATE", numsToAssign)
	GLOB.empathblock			= getAssignedBlock("EMPATH", numsToAssign,			DNA_HARD_BOUNDS,		good = TRUE)
	GLOB.polymorphblock			= getAssignedBlock("POLYMORPH", numsToAssign,		DNA_HARDER_BOUNDS,		good = TRUE)
	GLOB.strongblock			= getAssignedBlock("STRONG", numsToAssign,			DNA_HARDER_BOUNDS,		good = TRUE)

	//
	// /vg/ Blocks
	/////////////////////////////////////////////

	// Disabilities
	GLOB.loudblock				= getAssignedBlock("LOUD", numsToAssign)
	GLOB.dizzyblock				= getAssignedBlock("DIZZY", numsToAssign)

	// Paradise1984 Disabilities
	GLOB.auld_imperial_block	= getAssignedBlock("AULD_IMPERIAL", numsToAssign)
	GLOB.paraplegiablock		= getAssignedBlock("PARAPLEGIA", numsToAssign)

	//
	// Static Blocks
	/////////////////////////////////////////////.

	// Monkeyblock is always last.
	GLOB.monkeyblock = DNA_SE_LENGTH
	GLOB.assigned_blocks[DNA_SE_LENGTH] = ""

	// And the genes that actually do the work. (domutcheck improvements)
	var/list/blocks_assigned[DNA_SE_LENGTH]
	for(var/gene_type in typesof(/datum/dna/gene))
		var/datum/dna/gene/gene_instance = new gene_type
		if(isnull(gene_instance.block))
			continue
		if(blocks_assigned[gene_instance.block])
			warning("DNA2: Gene [gene_instance.name] trying to use already-assigned block [gene_instance.block] (used by [english_list(blocks_assigned[gene_instance.block])])")
		GLOB.dna_genes += gene_instance
		if(!blocks_assigned[gene_instance.block])
			blocks_assigned[gene_instance.block] = list()
		blocks_assigned[gene_instance.block] += gene_instance.name

	for(var/datum/dna/gene/gene as anything in GLOB.dna_genes)
		GLOB.assigned_gene_blocks[gene.block] = gene


/proc/setupcult()
	var/static/datum/cult_info/picked_cult // Only needs to get picked once

	if(picked_cult)
		return picked_cult

	var/random_cult = pick(typesof(/datum/cult_info))
	picked_cult = new random_cult()

	if(!picked_cult)
		log_runtime(EXCEPTION("Cult datum creation failed"))
	//todo:add adminonly datum var, check for said var here...
	return picked_cult
