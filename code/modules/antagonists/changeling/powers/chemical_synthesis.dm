/datum/action/changeling/chemical_synthesis
	name = "Химический синтез"
	desc = "Мы оптимизируем наши внутренние химические процессы для ускоренного производства реагентов."
	helptext = "Постоянно увеличивает скорость химического синтеза на 50%."
	button_icon_state = "chemical_synthesis"
	power_type = CHANGELING_PURCHASABLE_POWER
	dna_cost = 2
	var/chemical_synthesis_modifier = 0.5

/datum/action/changeling/chemical_synthesis/on_purchase(mob/user)
	. = ..()
	var/datum/antagonist/changeling/changeling = user.mind?.has_antag_datum(/datum/antagonist/changeling)
	if(changeling)
		changeling.add_chem_rate_modifier(src, chemical_synthesis_modifier)

/datum/action/changeling/chemical_synthesis/Remove(mob/user)
	var/datum/antagonist/changeling/changeling = user.mind?.has_antag_datum(/datum/antagonist/changeling)
	if(changeling)
		changeling.remove_chem_rate_modifier(src)
	return ..()

