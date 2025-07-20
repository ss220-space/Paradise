/datum/heretic_knowledge_tree_column/cosmic_to_ash
	neighbour_type_left = /datum/heretic_knowledge_tree_column/main/cosmic
	neighbour_type_right = /datum/heretic_knowledge_tree_column/main/ash

	route = PATH_SIDE

	tier1 = /datum/heretic_knowledge/summon/fire_shark
	tier2 = /datum/heretic_knowledge/spell/space_phase
	tier3 = /datum/heretic_knowledge/eldritch_coin


// Sidepaths for knowledge between Cosmos and Ash.

/datum/heretic_knowledge/summon/fire_shark
	name = "Scorching Shark"
	desc = "Allows you to transmute a pool of ash, a liver, and a sheet of plasma into a Fire Shark. \
		Fire Sharks are fast and strong in groups, but die quickly. They are also highly resistant against fire attacks. \
		Fire Sharks inject phlogiston into its victims and spawn plasma once they die."
	gain_text = "The cradle of the nebula was cold, but not dead. Light and heat flits even through the deepest darkness, and is hunted by its own predators."

	required_atoms = list(
		/obj/effect/decal/cleanable/ash = 1,
		/obj/item/organ/internal/liver = 1,
		/obj/item/stack/sheet/mineral/plasma = 1,
	)
	mob_to_summon = /mob/living/simple_animal/hostile/heretic_summon/fire_shark
	cost = 1

	poll_ignore_define = POLL_IGNORE_FIRE_SHARK

	research_tree_icon_dir = EAST

/datum/heretic_knowledge/spell/space_phase
	name = "Space Phase"
	desc = "Grants you Space Phase, a spell that allows you to move freely through space. \
		You can only phase in and out when you are on a space or misc turf."
	gain_text = "You feel like your body can move through space as if you where dust."

	spell_to_add = /obj/effect/proc_holder/spell/jaunt/space_crawl
	cost = 1


	research_tree_icon_frame = 6

/datum/heretic_knowledge/eldritch_coin
	name = "Eldritch Coin"
	desc = "Allows you to transmute a sheet of plasma and a diamond to create an Eldritch Coin. \
		The coin will open or close nearby doors when landing on heads and toggle their bolts \
		when landing on tails. If you insert the coin into an airlock, it will be consumed \
		to fry its electronics, opening the airlock permanently unless bolted. "
	gain_text = "The Mansus is a place of all sorts of sins. But greed held a special role."

	required_atoms = list(
		/obj/item/stack/sheet/mineral/diamond = 1,
		/obj/item/stack/sheet/mineral/plasma = 1,
	)
	result_atoms = list(/obj/item/coin/eldritch)
	cost = 1

	research_tree_icon_path = 'icons/obj/economy.dmi'
	research_tree_icon_state = "coin_heretic"


/obj/item/coin/eldritch
	name = "eldritch coin"
	desc = "A surprisingly heavy, ornate coin. Its sides seem to depict a different image each time you look."
	icon_state = "coin_heretic"
	//custom_materials = list(/datum/material/diamond =HALF_SHEET_MATERIAL_AMOUNT, /datum/material/plasma =HALF_SHEET_MATERIAL_AMOUNT)
	sideslist = list("heretic", "blade")
	//heads_name = "heretic"
	//has_action = TRUE
	//material_flags = NONE
	/// The range at which airlocks are effected.
	var/airlock_range = 5

/obj/item/coin/eldritch/attack_self(mob/user)
	var/mob/living/living_user = user
	if(!isheretic(user))
		living_user.adjustBruteLoss(5)
		return

	for(var/obj/machinery/door/airlock/target_airlock in range(airlock_range, user))
		if(target_airlock.density)
			target_airlock.open()
			continue

		target_airlock.close()

/*
/obj/item/coin/eldritch/tails_action(mob/user)
	var/mob/living/living_user = user
	if(!isheretic(user))
		living_user.adjustFireLoss(5)
		return

	for(var/obj/machinery/door/airlock/target_airlock in range(airlock_range, user))
		if(target_airlock.locked)
			target_airlock.unlock()
			continue

		target_airlock.lock()
*/

/obj/item/coin/eldritch/afterattack(atom/interacting_with, mob/living/user, proximity, params, status)
	if(!istype(interacting_with, /obj/machinery/door/airlock))
		return

	if(!isheretic(user))
		user.adjustBruteLoss(5)
		user.adjustFireLoss(5)
		user.drop_from_active_hand()
		return

	var/obj/machinery/door/airlock/target_airlock = interacting_with
	to_chat(user, span_warning("You insert [src] into the airlock."))
	target_airlock.emag_act(user, src)
	qdel(src)
	return
