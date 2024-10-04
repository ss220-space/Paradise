/datum/antagonist/vampire/goon_vampire
	name = "Goon-Vampire"
	nullification = OLD_NULLIFICATION
	is_garlic_affected = TRUE
	dust_in_space = FALSE
	antag_datum_blacklist = list(/datum/antagonist/vampire/new_vampire)
	upgrade_tiers = list(
		/obj/effect/proc_holder/spell/vampire/goon/self/rejuvenate = 0,
		/obj/effect/proc_holder/spell/vampire/goon/targetted/hypnotise = 0,
		/obj/effect/proc_holder/spell/vampire/goon/glare = 0,
		/datum/vampire_passive/vision = 100,
		/obj/effect/proc_holder/spell/vampire/goon/self/shapeshift = 100,
		/obj/effect/proc_holder/spell/vampire/goon/self/cloak = 150,
		/obj/effect/proc_holder/spell/vampire/goon/targetted/disease = 150,
		/obj/effect/proc_holder/spell/vampire/goon/bats = 200,
		/obj/effect/proc_holder/spell/vampire/goon/self/screech = 200,
		/datum/vampire_passive/regen = 200,
		/obj/effect/proc_holder/spell/vampire/goon/shadowstep = 250,
		/obj/effect/proc_holder/spell/vampire/goon/self/jaunt = 300,
		/obj/effect/proc_holder/spell/vampire/goon/targetted/enthrall = 300,
		/datum/vampire_passive/xray = 500,
		/datum/vampire_passive/full = 500)


/datum/antagonist/vampire/goon_vampire/add_owner_to_gamemode()
	SSticker.mode.goon_vampires += owner


/datum/antagonist/vampire/goon_vampire/remove_owner_from_gamemode()
	SSticker.mode.goon_vampires -= owner



/datum/antagonist/mindslave/thrall/goon_thrall/add_owner_to_gamemode()
	SSticker.mode.goon_vampire_enthralled += owner


/datum/antagonist/mindslave/thrall/goon_thrall/remove_owner_from_gamemode()
	SSticker.mode.goon_vampire_enthralled -= owner


/proc/is_goon_vampire(datum/source)
	if(!source)
		return FALSE

	if(istype(source, /datum/mind))
		var/datum/mind/our_mind = source
		return our_mind.has_antag_datum(/datum/antagonist/vampire/goon_vampire)

	if(!ismob(source))
		return FALSE

	var/mob/mind_holder = source
	if(!mind_holder.mind)
		return FALSE

	return mind_holder.mind.has_antag_datum(/datum/antagonist/vampire/goon_vampire)
