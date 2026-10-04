/datum/antagonist/vampire/new_vampire
	dust_in_space = TRUE
	antag_datum_blacklist = list(/datum/antagonist/vampire/goon_vampire)
	upgrade_tiers = list(
		/datum/action/cooldown/spell/vamp_rejuvenate = 0,
		/datum/action/cooldown/spell/aoe/glare = 0,
		/datum/vampire_passive/vision = 100,
		/datum/action/cooldown/spell/vamp_specialize = 100,
		/datum/vampire_passive/regen = 200,
	)

/datum/antagonist/vampire/new_vampire/add_owner_to_gamemode()
	SSticker.mode.vampires += owner

/datum/antagonist/vampire/new_vampire/remove_owner_from_gamemode()
	SSticker.mode.vampires -= owner

/datum/antagonist/mindslave/thrall/new_thrall/add_owner_to_gamemode()
	SSticker.mode.vampire_enthralled += owner

/datum/antagonist/mindslave/thrall/new_thrall/remove_owner_from_gamemode()
	SSticker.mode.vampire_enthralled -= owner

/datum/antagonist/mindslave/thrall/new_thrall/remove_innate_effects(mob/living/mob_override)
	var/mob/living/user = ..()
	if(!mob_override)
		user.mind.RemoveSpell(/datum/action/cooldown/spell/dantalion_thrall_commune)
	return user

/datum/antagonist/mindslave/thrall/new_thrall/apply_innate_effects(mob/living/mob_override)
	var/mob/living/user = ..()
	if(!mob_override)
		user.mind.AddSpell(new /datum/action/cooldown/spell/dantalion_thrall_commune)
	return user
