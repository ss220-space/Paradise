/datum/action/item_action/advanced/ninja/ninja_emergency_blink
	name = "Экстренная телепортация"
	desc = "Телепортирует вас в случайное близлежащее место. Затраты энергии: 1500"
	check_flags = AB_CHECK_CONSCIOUS
	charge_max = 3 SECONDS
	button_icon_state = "emergency_blink"
	button_icon = 'icons/mob/actions/actions_ninja.dmi'
	background_icon_state = "background_green"
	action_initialisation_text = "Void-Shift - Emergency Blink System"

//Наглейший копипаст из кода блюспейс кристаллов ^v^
/obj/item/clothing/suit/space/space_ninja/proc/emergency_blink()
	var/mob/living/carbon/human/ninja = affecting
	if(!is_teleport_allowed(ninja.z))
		visible_message(span_warning("Костюм начинает светиться... Но потом останавливается!"))
		return
	if(!ninjacost(1500))
		var/turf/T = get_turf(ninja)
		if(auto_smoke)
			if(locate(/datum/action/item_action/advanced/ninja/ninja_smoke_bomb) in actions)
				prime_smoke(lowcost = TRUE)
		do_teleport(ninja, T, 8, asoundin = 'sound/effects/phasein.ogg', ignore_bluespace_interference = TRUE)
		add_attack_logs(ninja, null, "Emergency blinked from [COORD(T)] to [COORD(ninja)].")
		investigate_log("[key_name_log(ninja)] Emergency blinked from [COORD(T)] to [COORD(ninja)].", INVESTIGATE_TELEPORTATION)
		for(var/datum/action/item_action/advanced/ninja/ninja_emergency_blink/ninja_action in actions)
			ninja_action.use_action()
			break
