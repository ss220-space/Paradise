/datum/antagonist/vampire/goon_vampire
	name = "Goon-Vampire"
	upgrade_tiers = list(
		/obj/effect/proc_holder/spell/goon_vampire/self/rejuvenate = 0,
		/obj/effect/proc_holder/spell/goon_vampire/targetted/hypnotise = 0,
		/obj/effect/proc_holder/spell/goon_vampire/glare = 0,
		/datum/vampire_passive/vision = 100,
		/obj/effect/proc_holder/spell/goon_vampire/self/shapeshift = 100,
		/obj/effect/proc_holder/spell/goon_vampire/self/cloak = 150,
		/obj/effect/proc_holder/spell/goon_vampire/targetted/disease = 150,
		/obj/effect/proc_holder/spell/goon_vampire/bats = 200,
		/obj/effect/proc_holder/spell/goon_vampire/self/screech = 200,
		/datum/vampire_passive/regen = 200,
		/obj/effect/proc_holder/spell/goon_vampire/shadowstep = 250,
		/obj/effect/proc_holder/spell/goon_vampire/self/jaunt = 300,
		/obj/effect/proc_holder/spell/goon_vampire/targetted/enthrall = 300,
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

