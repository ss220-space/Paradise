/datum/action/changeling/chemical_synthesis
	name = "Chemical Synthesis"
	desc = "We optimize our internal chemistry to produce reagents at an accelerated rate."
	helptext = "Permanently increases chemical regeneration rate by 50%."
	button_icon_state = "pd_upgrade"
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

