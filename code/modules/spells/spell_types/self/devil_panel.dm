/datum/action/cooldown/spell/devil_panel
	name = "Информация о дьяволе"
	desc = "Позволяет вам узнать о своих слабостях, а так же о вашем прогрессе в повышении ранга."

	button_icon = 'icons/obj/library.dmi'
	button_icon_state = "demonomicon"
	spell_requirements = SPELL_REQUIRES_NO_ANTIMAGIC


/datum/action/cooldown/spell/devil_panel/cast(atom/cast_on)
	. = ..()
	var/datum/antagonist/devil/devil = owner?.mind?.has_antag_datum(/datum/antagonist/devil)
	devil?.ui_interact(owner)
