/datum/secspear_mode
	var/name
	var/overlay_prefix
	var/damage_type = BRUTE
	var/damage
	var/damage_weided
	var/armour_penetration
	/// How much power does it cost to hit someone.
	var/power_cost = 500
	var/hit_sound = SFX_ENERGY_SWORD_SWING
	var/next_mode
	var/on_sound = 'sound/weapons/saberon.ogg'

	// Cleave params
	var/arc_size = 90
	var/arc_size_weided = 270
	var/swing_speed_mod = 1.5
	var/swing_speed_mod_weided = 1.75
	var/afterswing_slowdown = 0.2
	var/slowdown_duration = 0.5 SECONDS
	var/cleave_sound = SFX_DOUBLE_ENERGY_SWING

/datum/secspear_mode/proc/on_activate(obj/item/twohanded/spear/secspear/spear)
	SHOULD_CALL_PARENT(TRUE)
	RegisterSignal(spear, COMSIG_ITEM_AFTERATTACK, PROC_REF(on_item_afterattack))
	spear.damtype = damage_type
	spear.update_damage(damage_weided, damage)
	spear.armour_penetration = armour_penetration
	spear.hitsound = hit_sound
	spear.update_cleave_component()

/datum/secspear_mode/proc/on_deactivate(obj/item/twohanded/spear/secspear/spear)
	SHOULD_CALL_PARENT(TRUE)
	UnregisterSignal(spear, COMSIG_ITEM_AFTERATTACK)

/datum/secspear_mode/proc/on_item_afterattack(obj/item/twohanded/spear/secspear/spear, atom/target, mob/user, proximity, params, status)
	return

/datum/secspear_mode/off
	name = "выключен"
	hit_sound = SFX_SWING_HIT
	on_sound = 'sound/weapons/saberoff.ogg'
	cleave_sound = SFX_BLUNT_SWING_HEAVY
	next_mode = /datum/secspear_mode/stunner
	damage = 7
	damage_weided = 10
	armour_penetration = 0
	power_cost = 0
	afterswing_slowdown = 0
	slowdown_duration = 0
	swing_speed_mod = 1.1
	swing_speed_mod_weided = 1.2

/datum/secspear_mode/stunner
	name = "станнер"
	next_mode = /datum/secspear_mode/burning_blade
	damage_type = STAMINA
	damage = 45
	damage_weided = 50
	overlay_prefix = "_disabler"

/datum/secspear_mode/burning_blade
	name = "огненный клинок"
	next_mode = /datum/secspear_mode/energy_blade
	damage_type = BURN
	damage = 25
	damage_weided = 27
	armour_penetration = 30
	power_cost = 650
	overlay_prefix = "_taser"

/datum/secspear_mode/energy_blade
	name = "энергетический клинок"
	next_mode = /datum/secspear_mode/off
	power_cost = 800
	damage = 21
	damage_weided = 24
	armour_penetration = 10
	overlay_prefix = "_lethal"

/datum/secspear_mode/energy_blade/on_activate(obj/item/twohanded/spear/secspear/spear)
	. = ..()
	spear.sharp = TRUE

/datum/secspear_mode/energy_blade/on_deactivate(obj/item/twohanded/spear/secspear/spear)
	. = ..()
	spear.sharp = FALSE
