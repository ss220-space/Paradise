
GLOBAL_DATUM_INIT(fracture_type_crack, /datum/fracture_type, new /datum/fracture_type/crack())
GLOBAL_DATUM_INIT(fracture_type_closed, /datum/fracture_type, new /datum/fracture_type/closed())
GLOBAL_DATUM_INIT(fracture_type_open, /datum/fracture_type, new /datum/fracture_type/open())

/**
 * Bodypart fracture.
 */
/datum/fracture_type
	/// Power of fracture (greater override lesser)
	var/power
	var/description
	/// Is open fracture
	var/is_open = FALSE
	/// Drop chanfe if fracture in hands
	var/drop_chance = 0
	/// Bonus spread on shot if fracture in hands
	var/bonus_spread = 0
	/// Workspeed modifier if fracture in hands
	var/workspeed_mod = 0
	/// Fall chance with move if fracture in legs
	var/fall_chance = 0
	/// Fall damage with move if fracture in legs
	var/fall_damage = 0
	/// Movement slowdown modifier if fracture in legs
	var/slowdown_mod = 0
	/// Chance to reattach open fracture
	var/reattach_chance = 30
	/// Damage if reattach open fracture is failed
	var/reattach_fail_damage = 12
	/// Plasma dust amount with fracture
	var/plasma_dust = 0
	/// Pass damage to internal organs
	var/pass_internal_organ_damage = FALSE
	/// Can be splinted
	var/can_splint = TRUE
	/// Can be mend by aura healing (aura, core, medbeam, ...)
	var/can_mend_by_aura_heal = TRUE

/datum/fracture_type/crack
	power = 1
	description = "Микротрещина"
	bonus_spread = 12
	workspeed_mod = 0.2
	fall_chance = 1
	fall_damage = 5
	slowdown_mod = 0.5
	plasma_dust = 8

/datum/fracture_type/closed
	power = 2
	description = "Закрытый перелом"
	drop_chance = 5
	bonus_spread = 23
	workspeed_mod = 0.4
	fall_chance = 5
	fall_damage = 10
	slowdown_mod = 1
	plasma_dust = 15
	pass_internal_organ_damage = TRUE

/datum/fracture_type/open
	power = 3
	description = "Открытый перелом"
	is_open = TRUE
	drop_chance = 30
	bonus_spread = 45
	workspeed_mod = 0.8
	fall_chance = 10
	fall_damage = 10
	slowdown_mod = 2
	plasma_dust = 30
	pass_internal_organ_damage = TRUE
	can_splint = FALSE
	can_mend_by_aura_heal = FALSE
