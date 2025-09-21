#define STECK_SWAP_LIMIT 10


#define DNA_HEX_IF_OPERATOR 1


#define DEFAULT_ADD_GENE_ACTION (0 << 1)

/datum/dna_block_action
	var/hex_code = NULL_GENE
	
	var/block_flags = NONE
	//var/allowed_target = /mob/living/carbon

//Возвращаемое цисло это куда переместить стек
/datum/dna_block_action/proc/custom_action(datum/genetic_block/parent_block, number_in = 1)
	return number_in

/datum/dna_block_action/if_operator
	block_flags = DEFAULT_ADD_GENE_ACTION


/datum/dna_gene_container
	var/flags = NONE

	//var/list/internal_global_vars = list() // Hex code = var

	var/list/unique_hex_codes = list()
	var/list/datum/genetic_block/blocks = list() //Hex adress = block datum

/datum/dna_gene_container/New()
	hex_codes_syn()

/datum/dna_gene_container/proc/get_local_unq_code()
	return pick_n_take(unique_hex_codes)

/datum/dna_gene_container/proc/hex_codes_syn()
	unique_hex_codes = LAZYCOPY(SSGeneProcessor.all_hex_codes)
	for(var/list/datum/genetic_block/block in blocks)
		for(var/hex_code in block.hex_codes)
			LAZYREMOVE(unique_hex_codes, hex_code)
			
	for(var/list/datum/genetic_block/block in blocks)
		block.hex_code = get_local_unq_code()
		blocks[block.hex_code] = block



/datum/dna_gene_container/proc/add_genetic_block(datum/genetic_block/block_to_add)
	for(var/hex_code in block_to_add.hex_codes)
		LAZYREMOVE(unique_hex_codes, hex_code)
	block_to_add.hex_code = get_local_unq_code()
	block_to_add[block_to_add.hex_code] = block_to_add

/datum/genetic_block
	var/name = "Имя генетического блока"
	var/desc = "Описание генетического блока"

	var/hex_code = NONE

	var/datum/dna_gene_container/curret_container

	var/list/dna_hex = list() //ДНК блока

	var/list/local_stack = list()
	var/list/hex_codes = list() //Структура данных: Код = Тип исполняемого атомарного действия
	//var/list/unique_local_hes_codes = list()

	var/dna_flags = NONE
	var/dna_processed_status = FALSE

/datum/genetic_block/New(datum/dna_gene_container/container)
	curret_container = container

/datum/genetic_block/proc/execute(list/stack = list())


SUBSYSTEM_DEF(GeneProcessor)
	name = "Gene processor"
	ss_id = "gene_process"

	priority = FIRE_PRIORITY_VIRUS
	init_order = INIT_ORDER_VIRUS_PROCESS
	runlevels = RUNLEVEL_GAME

	var/static/list/all_hex_codes = list()

	var/static/list/all_gene_actions = list()
	var/static/list/force_add_actions = list()

	var/list/datum/genetic_block/registered_blocks = list()

	var/queue/queue_to_process = new()

/datum/controller/subsystem/GeneProcessor/Initialize()
	for(var/i; i <= 255; i++)
		all_hex_codes += i

	for(var/datum/dna_block_action/sct in subtypesof(/datum/dna_block_action))
		sct = new()
		all_gene_actions[sct] = sct

		if(sct.block_flags & DEFAULT_ADD_GENE_ACTION)
			force_add_actions[sct] = sct

/datum/controller/subsystem/GeneProcessor/fire(resumed)
	if(!queue_to_process.is_empty() && !queue_process())
		return

	for(var/datum/genetic_block/temp in registered_blocks)
		if(!genetic_block.check_need_process())
			continue
		queue_to_process.enqueue(temp)

/datum/controller/subsystem/GeneProcessor/proc/queue_process()
	while(!queue_to_process.is_empty())
		dna_block_process(queue_to_process.dequeue())
		if(MC_TICK_CHECK)
			return FALSE
	return TRUE

/datum/controller/subsystem/GeneProcessor/proc/register_dna_block

/datum/controller/subsystem/GeneProcessor/proc/dna_block_process(datum/genetic_block/block_to_process)
	var/count = 1
	var/steck_swap_count = 0
	for(var/hex_code in block_to_process)


