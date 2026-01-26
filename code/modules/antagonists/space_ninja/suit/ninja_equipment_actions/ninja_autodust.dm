//Automatically dusts ninja if enabled!

/datum/action/item_action/advanced/ninja/ninja_autodust
	name = "Автосжигание"
	desc = "Автоматически превращает вас в пыль при смерти."
	check_flags = NONE
	charge_type = ADV_ACTION_TYPE_TOGGLE
	button_icon_state = "dust"
	button_icon = 'icons/mob/actions/actions_ninja.dmi'
	background_icon_state = "background_green"
	action_initialisation_text = "Auto-Dust"

/**
 * Proc called to enable/disable autodust.
 */
/obj/item/clothing/suit/space/space_ninja/proc/ninja_toggle_autodust()
	var/mob/living/carbon/human/user = src.loc
	if(s_busy)
		return
	s_busy = TRUE
	if(!auto_dust)
		auto_dust = TRUE
		user.show_message("Вы включили программу [span_warning("\"Автосжигания\"")] текущий режим \
						[health_threshold==-90 ? span_green("\"Обнаружение смерти\"") : span_green("\"Обнаружение критического состояния\"") ]")
		var/choise = tgui_alert(user, "Переключить режим?", "Режимы автосжигания", list("Да", "Нет"))
		if(choise == "Да")
			if(health_threshold == 0 && auto_dust)
				health_threshold = -90
				user.show_message("Вы переключили программу [span_warning("\"Автосжигания\"")]  в режим [span_green("\"Обнаружение смерти\"")]")
			else if(health_threshold == -90 && auto_dust)
				health_threshold = 0
				user.show_message("Вы переключили программу [span_warning("\"Автосжигания\"")] в режим [span_green("\"Обнаружение критического состояния\"")]")
	else if(auto_dust)
		auto_dust = FALSE
		user.show_message("Вы выключили программу [span_warning("\"Автосжигания\"")]")
	for(var/datum/action/item_action/advanced/ninja/ninja_autodust/ninja_action in actions)
		ninja_action.use_action()
	s_busy = FALSE
/**
 * Proc called to dust the ninja!
 */
/obj/item/clothing/suit/space/space_ninja/proc/ninja_autodust()
	if(!affecting)	//safety check
		return
	var/mob/living/carbon/human/ninja = affecting
	add_attack_logs(ninja, ninja, "Self-dusted")
	ninja.visible_message(
		span_warning("[ninja] мгновенно сгорает в ослепительной вспышке!"),
		span_reallybig(
			"Программа [span_warning("\"Автосжигания\"")] активирована!</span>\n\
			[span_revenwarning("Стихли все звуки,\n\
								Исчезли раздумия.\n\
								Мир прощай бренный...\n")]")
	)

	ninja.drop_ungibbable_items()

	ninja.dust()
