/datum/action/changeling/chemical_synthesis
	name = "Химический синтез"
	desc = "Мы оптимизируем наши внутренние химические процессы для ускоренного производства реагентов."
	helptext = "Постоянно увеличивает скорость химического синтеза на 50%."
	button_icon_state = "chemical_synthesis"
	power_type = CHANGELING_PURCHASABLE_POWER
	dna_cost = 2
	var/recharge_bonus = 0.5

/datum/action/changeling/chemical_synthesis/on_purchase(mob/user)
	. = ..()
	var/datum/antagonist/changeling/changeling = user.mind?.has_antag_datum(/datum/antagonist/changeling)
	if(changeling)
		changeling.chem_recharge_rate += recharge_bonus

/datum/action/changeling/chemical_synthesis/Remove(mob/user)
	var/datum/antagonist/changeling/changeling = user.mind?.has_antag_datum(/datum/antagonist/changeling)
	if(changeling)
		changeling.chem_recharge_rate -= recharge_bonus
	return ..()

