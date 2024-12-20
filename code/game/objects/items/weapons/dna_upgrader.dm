/obj/item/dna_upgrader
	name = "dna upgrader"
	desc = "Говорят, что такое великое изменение генома может быть достигнуто только при выполнении цели станции... Глупцы."

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
	icon_state = "initial(icon_state)[used ? "0" : ""]"

/obj/item/dna_upgrader/update_name(updates = ALL)
	. = ..()
	name = used ? "used [initial(name)]" : initial(name)

/obj/item/dna_upgrader/attack_self(mob/user)
	if(can_choose_genes(user))
		choose_genes(user)

/obj/item/dna_upgrader/proc/can_choose_genes(mob/living/carbon/human/human)
	if(!istype(human))
		return FALSE

	if(used)
		balloon_alert(human, "инъектор пуст!")
		return FALSE

	if(HAS_TRAIT(human, TRAIT_NO_DNA))
		balloon_alert(human, "ДНК не обнаружено!")
		return FALSE

	return TRUE

/obj/item/dna_upgrader/proc/get_vault_genes_names(mob/user)
	var/list/vault_genes_names

	for(var/datum/dna/gene/basic/vault/gene as anything in subtypesof(/datum/dna/gene/basic/vault))
		if(!initial(gene.name))
			continue

		if(!gene.can_activate(user))
			continue

		LAZYADD(vault_genes_names, initial(gene.name))

	return vault_genes_names

/obj/item/dna_upgrader/proc/choose_genes(mob/living/carbon/human/user)
	var/choosen_gene = tgui_input_list(
		user, 
		"Choose a modification", 
		name, 
		get_vault_genes_names(user), 
		ui_state = GLOB.not_incapacitated_state
		)

	if(!choosen_gene || !can_choose_genes(user))
		return FALSE

	for(var/datum/dna/gene/basic/vault/gene as anything in subtypesof(/datum/dna/gene/basic/vault))
		if(initial(gene.name) != choosen_gene)
			continue

		if(!gene.can_activate(user))
			return FALSE

		gene.activate(user)
		break

	finalize_dna_upgrade(user)

	return TRUE
	
/obj/item/dna_upgrader/proc/finalize_dna_upgrade(mob/living/carbon/human/user)
	user.gene_stability += 25

	to_chat(user, span_notice("Вы чувствуете, как ваше тело меняется."))

	used = TRUE
	update_appearance(UPDATE_ICON_STATE | UPDATE_NAME)
