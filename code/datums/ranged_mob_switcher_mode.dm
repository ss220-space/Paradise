/**
 * Datum used in datum/element/ranged_mob_switcher
 *
 * Stores everything ranged related a simple hostile mob can have, plus extras for the element
 */
/datum/ranged_mob_switcher_mode
	/// Name of the mode
	var/name = "Какой-то выстрел"
	/// Cooldown of projectiles in this mode
	var/cooldown = 1 SECONDS
	/// Amount of projectiles in this mode
	var/amount = 1
	/// Rapid fire delay in this mode
	var/rapid_fire_delay
	/// Rapid fire spread
	var/rapid_fire_spread
	/// Type of projectile in this mode
	var/proj_type
	/// Sound of shooting projectiles in this mode
	var/sound
	/// Icon file used for radial menu
	var/icon
	/// Icon state used for radial menu
	var/icon_state

// MARK: Combat swarmer modes
/datum/ranged_mob_switcher_mode/combat_swarmer_double
	name = "Двойной выстрел"
	cooldown = 2 SECONDS
	proj_type = /obj/projectile/beam/disabler/swarmer/double
	amount = 2
	rapid_fire_delay = 0.2 SECONDS
	rapid_fire_spread = 5
	icon = 'icons/mob/actions/actions_swarmer.dmi'
	icon_state = "double"
	sound = 'sound/weapons/taser2.ogg'

/datum/ranged_mob_switcher_mode/combat_swarmer_strong
	name = "Сильный выстрел"
	cooldown = 2.5 SECONDS
	proj_type = /obj/projectile/beam/disabler/swarmer/empowered
	icon = 'icons/mob/actions/actions_swarmer.dmi'
	icon_state = "power"
	sound = 'sound/weapons/taser2.ogg'

/datum/ranged_mob_switcher_mode/combat_swarmer_sabotage
	name = "Саботажный выстрел"
	cooldown = 3 SECONDS
	proj_type = /obj/projectile/beam/disabler/swarmer/sabotage
	icon = 'icons/mob/actions/actions_swarmer.dmi'
	icon_state = "sabotage"
	sound = 'sound/weapons/taser2.ogg'
