/datum/action/item_action/ninja_emergency_blink
	name = "Emergency Blink"
	desc = "Teleports user to a random nearby location. Consumes a big amount of energy. Use wisely. Energy cost: 1500"
	use_itemicon = FALSE
	check_flags = NONE
	button_icon_state = "emergency_blink"
	icon_icon = 'icons/mob/actions/actions_ninja.dmi'
	button_icon = 'icons/mob/actions/actions_ninja.dmi'
	background_icon_state = "background_green"
	action_initialisation_text = "Void-Shift - Emergency Blink System"

//Наглейший копипаст из кода блюспейс кристаллов ^v^
/obj/item/clothing/suit/space/space_ninja/proc/emergency_blink()
	var/mob/living/carbon/human/ninja = affecting
	if(!is_teleport_allowed(ninja.z))
		src.visible_message(span_warning("[src] begins to glow... But then stops!"))
		return
	if(!ninjacost(150))
		do_teleport(ninja, get_turf(ninja), 8, asoundin = 'sound/effects/phasein.ogg')
		s_coold = 3 SECONDS
