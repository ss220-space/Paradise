/obj/item/dna_upgrader
	name = "dna upgrader"
	desc = "Говорят, что такое великое изменение генома может быть только при выполнении цели станции... Дураки."

	icon = 'icons/obj/hypo.dmi'
	icon_state = "dnaupgrader"

	var/used = FALSE

	ru_names = list(
   		NOMINATIVE = "улучшатель ДНК",
    	GENITIVE = "улучшателя ДНК",
    	DATIVE = "улучшателю ДНК",
    	ACCUSATIVE = "улучшатель ДНК",
    	INSTRUMENTAL = "улучшателем ДНК",
    	PREPOSITIONAL = "улучшателе ДНК"
	)

/obj/item/dna_upgrader/update_icon_state()
	icon_state = "dnaupgrader[used ? false : ""]"

/obj/item/dna_upgrader/update_name(updates = ALL)
	. = ..()
	name = used ? "used [initial(name)]" : initial(name)

/obj/item/dna_upgrader/attack_self(mob/user)
	try_choose_genes(user)

/obj/item/dna_upgrader/proc/try_choose_genes(mob/living/carbon/human/human)
	if(!istype(human))
		return FALSE

	if(used)
		balloon_alert(human, "было использовано!")
		return FALSE

	if(HAS_TRAIT(human, TRAIT_NO_DNA))
		balloon_alert(human, "ДНК не обнаружено!")
		return FALSE
	
	choose_genes(human)

	return TRUE

/obj/item/dna_upgrader/proc/get_vault_genes_names()
	var/list/vault_genes_names = list()

	for(var/datum/vault_gene/gene in subtypesof(/datum/vault_gene))
		if(!initial(gene.name))
			continue

		LAZYADD(vault_genes_names, initial(gene.name))

	return vault_genes_names

/obj/item/dna_upgrader/proc/choose_genes(mob/living/carbon/human/user)
	var/choosen_gene = tgui_input_list(
		user, 
		"Choose a modification", 
		name, 
		get_vault_genes_names(), 
		ui_state = GLOB.not_incapacitated_state
		)

	if(used || !choosen_gene)
		return FALSE

	for(var/datum/vault_gene/gene in subtypesof(/datum/vault_gene))
		if(initial(gene.name) != choosen_gene)
			continue

		gene.apply(user, name)
		break

	finalize_dna_upgrade(user)

	return TRUE
	
/obj/item/dna_upgrader/proc/finalize_dna_upgrade(mob/living/carbon/human/user)
	user.gene_stability += 25

	to_chat(user, span_notice("Вы чувствуете, как ваше тело меняется."))

	used = TRUE
	update_appearance(UPDATE_ICON_STATE|UPDATE_NAME)
