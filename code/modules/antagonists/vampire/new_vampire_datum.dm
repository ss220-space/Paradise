/datum/antagonist/vampire/new_vampire
	name = "Vampire"
	nullification = NEW_NULLIFICATION
	is_garlic_affected = FALSE
	dust_in_space = TRUE
	antag_datum_blacklist = list(/datum/antagonist/vampire/goon_vampire)
	upgrade_tiers = list(/obj/effect/proc_holder/spell/vampire/self/rejuvenate = 0,
									/obj/effect/proc_holder/spell/vampire/glare = 0,
									/datum/vampire_passive/vision = 100,
									/obj/effect/proc_holder/spell/vampire/self/specialize = 150,
									/datum/vampire_passive/regen = 200)

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
		user.mind?.RemoveSpell(/obj/effect/proc_holder/spell/vampire/thrall_commune)
	return user

/datum/antagonist/mindslave/thrall/new_thrall/apply_innate_effects(mob/living/mob_override)
	var/mob/living/user = ..()
	if(!mob_override)
		user.mind?.AddSpell(new /obj/effect/proc_holder/spell/vampire/thrall_commune)
	return user
