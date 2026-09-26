#define SPRITE_STATE_UPLOAD "Загрузить новый .dmi"

ADMIN_VERB_AND_CONTEXT_MENU(change_sprite_state, R_EVENT, "Change Sprite State", "Switch an atom's icon state or upload a new sprite sheet for it.", ADMIN_CATEGORY_EVENTS, /atom)
	VERB_ARG_TYPED(target, VERB_ARG_TYPE_ATOM, VERB_ARG_SOURCE_WORLD, /atom)
	var/list/choices = target.sprite_state_choices()
	choices[SPRITE_STATE_UPLOAD] = image(icon = 'icons/hud/radial.dmi', icon_state = "palette_add")
	var/choice = show_radial_menu(user.mob, target, choices, autopick_single_option = FALSE)
	if(!choice || QDELETED(target))
		return

	if(choice == SPRITE_STATE_UPLOAD)
		var/icon/new_icon = input(user, "Выберите .dmi со спрайтами", "Загрузка спрайта") as null|icon
		if(!new_icon || QDELETED(target))
			return
		target.icon = new_icon
		log_and_message_admins("uploaded sprite sheet [new_icon] to [target] ([target.type]).")
		if(ismob(target))
			var/mob/target_mob = target
			if(!(locate(/datum/action/innate/change_sprite_state) in target_mob.actions))
				var/datum/action/innate/change_sprite_state/switcher = new(target_mob)
				switcher.Grant(target_mob)
		choice = show_radial_menu(user.mob, target, target.sprite_state_choices(), autopick_single_option = FALSE)
		if(!choice || QDELETED(target))
			return

	target.set_sprite_state(choice)
	log_and_message_admins("changed icon state of [target] ([target.type]) to [choice].")
	BLACKBOX_LOG_ADMIN_VERB("Change Sprite State")

#undef SPRITE_STATE_UPLOAD

/atom/proc/sprite_state_choices()
	var/list/choices = list()
	for(var/state in icon_states(icon))
		if(!state)
			continue
		choices[state] = image(icon = icon, icon_state = state)
	return choices

/atom/proc/set_sprite_state(new_state)
	icon_state = new_state

/mob/living/simple_animal/set_sprite_state(new_state)
	icon_living = new_state
	return ..()

/mob/living/basic/set_sprite_state(new_state)
	icon_living = new_state
	return ..()

/datum/action/innate/change_sprite_state
	name = "Сменить спрайт"
	desc = "Переключиться на другое состояние своего спрайта."
	button_icon = 'icons/hud/radial.dmi'
	button_icon_state = "palette_element"

/datum/action/innate/change_sprite_state/Activate()
	var/choice = show_radial_menu(owner, owner, owner.sprite_state_choices(), autopick_single_option = FALSE)
	if(!choice)
		return
	owner.set_sprite_state(choice)
