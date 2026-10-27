/datum/action/cooldown/spell/pointed/projectile/neurotoxin_spit
	name = "Плевок нейротоксином"
	desc = "Позволяет выпустить порцию нейротоксина. Сбивает с ног любого, в кого вы попадёте, и наносит немного урона выносливости и токсинами."
	cooldown_time = 1 SECONDS
	spell_requirements = NONE
	check_flags = AB_CHECK_CONSCIOUS
	active_msg = span_noticealien_alt("<b>Вы готовите порцию нейротоксина!</b>")
	deactive_msg = span_noticealien_alt("<b>Вы проглатываете приготовленный нейротоксин.</b>")
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
	if(istype(owner, /mob/living/carbon/alien/humanoid/queen))
		var/mob/living/carbon/alien/humanoid/queen/queen_owner = owner
		queen_owner.play_spit_overlay()


/datum/action/cooldown/spell/pointed/projectile/neurotoxin_spit/create_new_handler()
	var/datum/spell_handler/alien/handler = new(src, plasma_cost)
	return handler

/datum/action/cooldown/spell/pointed/projectile/neurotoxin_spit/sentinel
	cooldown_time = 0.5 SECONDS
