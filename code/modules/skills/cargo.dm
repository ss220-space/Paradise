// Cargo skills
/datum/skill/cargo
	category = "Карго"

/datum/skill/cargo/carring
	id = "cargo.carrying"
	name = "Переноска"
	desc = "Влияет на переноски вещей."
	duration_mod_signals = list(COMSIG_GET_PULL_SLOWDOWN_MODIFIERS, COMSIG_GET_GRAB_SPEED_MODIFIERS)
