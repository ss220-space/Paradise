/obj/effect/proc_holder/spell/chaplain_bless
	name = "Bless"
	desc = "Благословляет единственного человека."

	school = "transmutation"
	base_cooldown = 6 SECONDS
	clothes_req = FALSE
	selection_activated_message = "<span class='notice'>Вы готовите благословение. Нажмите на цель, чтобы благословить её.</span>"
	selection_deactivated_message = "<span class='notice'>Вы решили благословить экипаж в другой раз.</span>"
	cooldown_min = 2 SECONDS
	action_icon_state = "shield"
	need_active_overlay = TRUE


/obj/effect/proc_holder/spell/chaplain_bless/create_new_targeting()
	var/datum/spell_targeting/click/T = new()
	T.range = 1
	T.click_radius = -1
	return T


/obj/effect/proc_holder/spell/chaplain_bless/valid_target(mob/living/carbon/human/target, mob/user)
	return target.mind && target.ckey && !target.stat


/obj/effect/proc_holder/spell/chaplain_bless/cast(list/targets, mob/living/user = usr)
	if(!istype(user))
		to_chat(user, "По какой-то причине, вы не являетесь живым существом. Такого не должно было случиться. Сообщите об этой ошибке.")
		revert_cast()
		return

	if(!user.mind)
		to_chat(user, "По какой-то причине, вы неразумны. Этого не должно было случиться. Сообщите об этой ошибке.")
		revert_cast()
		return

	if(!user.mind.isholy)
		to_chat(user, "По какой-то причине вы недостаточно святы для использования этой способности. Этого не должно было случиться. Сообщите об этой ошибке.")
		revert_cast()
		return

	var/mob/living/carbon/human/target = targets[1]

	spawn(0) // allows cast to complete even if recipient ignores the prompt
		if(alert(target, "[user] хочет благословить вас во имя религии [user.p_their()]. Принять?", "Принять благословение?", "Да", "Нет") == "Да") // prevents forced conversions
			user.visible_message("[user] начинает благословлять [target] во имя [SSticker.Bible_deity_name].", "<span class='notice'>Вы начинаете благословлять [target] во имя [SSticker.Bible_deity_name].</span>")
			if(do_after(user, 15 SECONDS, target))
				user.visible_message("[user] благословил [target] во имя [SSticker.Bible_deity_name].", "<span class='notice'>Вы благословили [target] во имя [SSticker.Bible_deity_name].</span>")
				if(!target.mind.isblessed)
					target.mind.isblessed = TRUE
					user.mind.num_blessed++
					ADD_TRAIT(target, TRAIT_HEALS_FROM_HOLY_PYLONS, INNATE_TRAIT)

