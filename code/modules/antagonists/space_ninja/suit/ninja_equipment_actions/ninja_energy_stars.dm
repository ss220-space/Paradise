

/datum/action/item_action/advanced/ninja/toggle_shuriken_fire_mode
	name = "Энергетический сюрикеномёт"
	desc = "Активирует генератор энергетических сюрикенов, которые замедляют и калечат врагов при попадании. Затраты энергии: 300 за залп."
	charge_type = ADV_ACTION_TYPE_TOGGLE
	button_icon_state = "shuriken"
	button_icon = 'icons/mob/actions/actions_ninja.dmi'
	background_icon_state = "background_green"
	action_initialisation_text = "Pure Energy Shuriken Emitter"

/obj/item/clothing/suit/space/space_ninja/proc/toggle_shuriken_fire_mode()
	var/mob/living/carbon/human/ninja = affecting
	if(shuriken_emitter)
		qdel(shuriken_emitter)
		shuriken_emitter = null
	else
		shuriken_emitter = new
		shuriken_emitter.my_suit = src
		for(var/datum/action/item_action/advanced/ninja/toggle_shuriken_fire_mode/ninja_action in actions)
			shuriken_emitter.my_action = ninja_action
			ninja_action.action_ready = TRUE
			ninja_action.use_action()
			break
		ninja.put_in_hands(shuriken_emitter)

/obj/effect/temp_visual/impact_effect/green_particles
	icon_state = "mech_toxin"
	duration = 2
