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
	unset_after_click = FALSE
	var/plasma_cost = 50

/datum/action/cooldown/spell/pointed/projectile/neurotoxin_spit/after_cast(atom/cast_on)
	. = ..()
	var/mob/living/carbon/user = owner
	if(user.get_plasma() < plasma_cost)
		unset_click_ability(user, FALSE)


/datum/action/cooldown/spell/pointed/projectile/neurotoxin_spit/create_new_handler()
	var/datum/spell_handler/alien/handler = new(src, plasma_cost)
	return handler

/datum/action/cooldown/spell/pointed/projectile/neurotoxin_spit/sentinel
	cooldown_time = 0.5 SECONDS
