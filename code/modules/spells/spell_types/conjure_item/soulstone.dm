/datum/action/cooldown/spell/conjure_item/soulstone
	name = "Summon Soulstone"
	desc = "This spell reaches into Redspace, summoning one of the legendary fragments across time and space"
	button_icon_state = "summonsoulstone"
	background_icon_state = "bg_cult"
	school = SCHOOL_CONJURATION
	cooldown_time = 5 MINUTES
	spell_requirements = SPELL_REQUIRES_NO_ANTIMAGIC
	delete_old = FALSE
	item_type = /obj/item/soulstone
