/datum/action/cooldown/spell/pointed/projectile/neurotoxin_spit
	name = "Neurotoxin spit"
	desc = "This ability allows you to fire some neurotoxin. Knocks down anyone you hit, applies a small amount of stamina damage as well."
	cooldown_time = 1 SECONDS
	spell_requirements = NONE
	check_flags = AB_CHECK_CONSCIOUS
	active_msg = span_noticealien_alt("<b>Your prepare some neurotoxin!</b>")
	deactive_msg = span_noticealien_alt("<b>You swallow your prepared neurotoxin.</b>")
	projectile_type = /obj/projectile/bullet/neurotoxin
	button_icon_state = "alien_neurotoxin_0"
	background_icon_state = "bg_alien"
	sound = 'sound/creatures/terrorspiders/spit2.ogg'
	var/plasma_cost = 50

/datum/action/cooldown/spell/pointed/projectile/neurotoxin_spit/create_new_handler()
	var/datum/spell_handler/alien/H = new
	H.plasma_cost = plasma_cost
	var/new_name = "[name] ([plasma_cost])"
	name = new_name
	build_all_button_icons()
	return H

/datum/action/cooldown/spell/pointed/projectile/neurotoxin_spit/sentinel
	cooldown_time = 0.5 SECONDS
