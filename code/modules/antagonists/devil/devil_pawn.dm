/// Devil's allies/creations should be marked with this datum
/datum/antagonist/mindslave/devil_pawn
	name = "Devil's pawn"
	job_rank = ROLE_DEVIL
	antag_menu_name = "Пешка дьявола"
	special_role = SPECIAL_ROLE_DEVIL_PAWN
	give_objectives = FALSE
	silent = TRUE
	show_in_roundend = FALSE
	job_rank = SPECIAL_ROLE_TRAITOR
	special_role = SPECIAL_ROLE_TRAITOR
	antag_hud_type = ANTAG_HUD_DEVIL
	antag_hud_name = "mindslave"	// This isn't named "hudmindslave" because `add_serve_hud()` adds "hud" to the beginning.
	clown_gain_text = "Дьявольская сила помогает вам побороть свою клоунскую натуру, позволяя использовать оружие без вреда для себя."
	clown_removal_text = "Дьявольская сила покинула вас и к вам вернулась клоунская неуклюжесть, клоуничайте на здоровье."
	master_hud_icon = "devil"

/datum/antagonist/mindslave/devil_pawn/greet()
	var/datum/antagonist/devil/devil = master.has_antag_datum(/datum/antagonist/devil)

	var/greet_text = span_bold("Вы подверглись дьявольскому воздействию [master.current.real_name], известному в аду как [devil.info.truename]. Следуйте каждому [genderize_ru(master.current.gender, "его", "её", "его", "их")] приказу.")
	return span_biggerdanger(greet_text)

/datum/antagonist/mindslave/devil_pawn/farewell()
	if(issilicon(owner.current))
		to_chat(owner.current, span_userdanger("Вы превратились в робота! Вы больше не подвержены дьявольскому воздействию."))
	else
		to_chat(owner.current, span_userdanger("Ваш разум очищен! Вы больше не подвержены дьявольскому воздействию."))

/datum/antagonist/mindslave/devil_pawn/apply_innate_effects(mob/living/mob_override)
	var/mob/living/user = ..()
	user.faction |= "hell"
	return user


/datum/antagonist/mindslave/devil_pawn/remove_innate_effects(mob/living/mob_override)
	var/mob/living/user = ..()
	user.faction -= "hell"
	return user
