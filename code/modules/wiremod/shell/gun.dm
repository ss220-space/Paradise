/**
 * # Circuit Gun
 *
 * A gun that lets you fire projectiles to enact circuitry.
 */
/obj/item/gun/energy/wiremod_gun
	name = "circuit gun"
	desc = "A gun that fires projectiles able to control circuitry. It can recharge using power from an attached circuit."
	icon = 'icons/obj/circuits.dmi'
	icon_state = "setup_gun"
	ammo_type = list(/obj/item/ammo_casing/energy/wiremod_gun)
	cell_type = /obj/item/stock_parts/cell/emproof/wiremod_gun
	item_flags = NONE
	light_system = MOVABLE_LIGHT_DIRECTIONAL
	light_on = FALSE
	trigger_guard = TRIGGER_GUARD_ALLOW_ALL
	clumsy_check = FALSE
	needs_permit = FALSE

/obj/item/ammo_casing/energy/wiremod_gun
	projectile_type = /obj/projectile/energy/wiremod_gun
	harmful = FALSE
	select_name = "circuit"
	fire_sound = 'sound/weapons/blaster.ogg'

/obj/projectile/energy/wiremod_gun
	name = "scanning beam"
	icon_state = "ion"
	damage = 0
	nodamage = TRUE
	range = 7

/obj/item/stock_parts/cell/emproof/wiremod_gun
	maxcharge = 2000

/obj/item/gun/energy/wiremod_gun/Initialize(mapload)
	. = ..()
	ADD_TRAIT(src, TRAIT_NO_CLONE_IN_EXPERIMENTATOR, INNATE_TRAIT)
	AddComponent(/datum/component/shell, list(
		new /obj/item/circuit_component/wiremod_gun()
	), SHELL_CAPACITY_MEDIUM)

/obj/item/circuit_component/wiremod_gun
	display_name = "Gun"
	desc = "Used to receive entities hit by projectiles from a gun."
	/// Called when a projectile hits
	var/datum/port/output/signal
	/// The shooter
	var/datum/port/output/shooter
	/// The entity being shot
	var/datum/port/output/shot

/obj/item/circuit_component/wiremod_gun/Initialize(mapload)
	. = ..()
	shooter = add_output_port("Shooter", PORT_TYPE_ATOM)
	shot = add_output_port("Shot Entity", PORT_TYPE_ATOM)
	signal = add_output_port("Shot", PORT_TYPE_SIGNAL)

/obj/item/circuit_component/wiremod_gun/register_shell(atom/movable/shell)
	RegisterSignal(shell, COMSIG_PROJECTILE_ON_HIT, PROC_REF(handle_shot))
	if(istype(shell, /obj/item/gun/energy))
		RegisterSignal(shell, COMSIG_GUN_CHAMBER_PROCESSED, PROC_REF(handle_chamber))

/obj/item/circuit_component/wiremod_gun/unregister_shell(atom/movable/shell)
	UnregisterSignal(shell, list(COMSIG_PROJECTILE_ON_HIT, COMSIG_GUN_CHAMBER_PROCESSED))

/**
 * Called when the shell item shoots something
 */
/obj/item/circuit_component/wiremod_gun/proc/handle_shot(atom/source, mob/firer, atom/target, angle)
	SIGNAL_HANDLER

	playsound(source, "terminal_type", 25, FALSE)
	shooter.set_output(firer)
	shot.set_output(target)
	signal.set_output(COMPONENT_SIGNAL)

#define ENERGY_PER_SHOT 100
/**
 * Called when the shell item processes a new chamber
 */
/obj/item/circuit_component/wiremod_gun/proc/handle_chamber(atom/source)
	SIGNAL_HANDLER

	if(!parent?.cell)
		return
	var/obj/item/gun/energy/fired_gun = source
	var/transferred = fired_gun.cell.give(min(ENERGY_PER_SHOT, parent.cell.charge))
	if(transferred)
		parent.cell.use(transferred)

#undef ENERGY_PER_SHOT
