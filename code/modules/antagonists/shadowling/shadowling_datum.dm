/datum/antagonist/shadowling
	name = "Shadowling"
	roundend_category = "Тенеморфами"
	show_in_roundend = FALSE
	job_rank = ROLE_SHADOWLING
	special_role = SPECIAL_ROLE_SHADOWLING
	antag_hud_type = ANTAG_HUD_SHADOW
	antag_hud_name = "hudshadowling"
	antag_menu_name = "Тенеморф"
	clown_gain_text = "Твоя натура позволяет тебе преодолеть твою клоунаду."
	wiki_page_name = "Shadowling"
	russian_wiki_name = "Тенеморф"
	default_team_type = /datum/team/shadowling

/datum/antagonist/shadowling/Destroy(force)
	if(owner?.current)
		for(var/datum/action/cooldown/spell/spell as anything in owner.spell_list.Copy())
			owner.RemoveSpell(spell)
		owner.current.remove_language(LANGUAGE_HIVE_SHADOWLING)
	return ..()

/datum/antagonist/shadowling/give_objectives()
	add_objective(/datum/objective/enthrall)

/datum/antagonist/shadowling/greet()
	var/list/messages = list()
	messages += span_deadsay(span_fontsize3(span_bold("You are a shadowling!")))
	messages += SSticker.mode.greet_shadow(owner)
	return messages

/datum/antagonist/shadowling/finalize_antag()
	SSticker.mode.finalize_shadowling(owner)


/datum/antagonist/shadowling_thrall
	name = "Shadowling Thrall"
	roundend_category = "Тенеморфами"
	show_in_roundend = FALSE
	job_rank = ROLE_SHADOWLING
	special_role = SPECIAL_ROLE_SHADOWLING_THRALL
	antag_hud_type = ANTAG_HUD_SHADOW
	antag_hud_name = "hudshadowlingthrall"
	antag_menu_name = "Раб тенеморфа"
	default_team_type = /datum/team/shadowling

/datum/antagonist/shadowling_thrall/Destroy(force)
	if(owner?.current)
		owner.RemoveSpell(/datum/action/cooldown/spell/shadowling_guise)
		owner.RemoveSpell(/datum/action/cooldown/spell/shadowling_vision/thrall)
		owner.current.remove_language(LANGUAGE_HIVE_SHADOWLING)
	return ..()

/datum/antagonist/shadowling_thrall/greet()
	var/list/messages = list()
	messages += span_shadowling("><b>Ты видишь правду. Ты понимаешь, каким дураком ты был..</b>")
	messages += span_shadowling("<b>Тенелинги — твои хозяева.</b> Служи им превыше всего и следите за тем, чтобы они достигли своих целей.")
	messages += span_shadowling("Ты не должен причинять вред другим рабам или тенелингам. Однако ты не должен подчиняться другим рабам.")
	messages += span_shadowling("Твоё тело необратимо изменилось. Внимательный может это увидеть — ты можешь скрыть это, надев маску.")
	messages += span_shadowling("Хотя ты и не так силён, как твои хозяева, но ты обладаешь некоторыми способностями.")
	messages += span_shadowling("Ты можешь общаться со своими союзниками, используя Телепатическую сеть тенелингов. '[get_language_prefix(LANGUAGE_HIVE_SHADOWLING)]'.")
	return messages

/datum/antagonist/shadowling_thrall/finalize_antag()
	owner.AddSpell(new /datum/action/cooldown/spell/shadowling_guise)
	owner.AddSpell(new /datum/action/cooldown/spell/shadowling_vision/thrall)
	owner.current.add_language(LANGUAGE_HIVE_SHADOWLING)

/proc/is_shadow(mob/living/user)
	return istype(user) && user.mind?.has_antag_datum(/datum/antagonist/shadowling)

/proc/is_thrall(mob/living/user)
	return istype(user) && user.mind?.has_antag_datum(/datum/antagonist/shadowling_thrall)

/proc/is_shadow_or_thrall(mob/living/user)
	return is_shadow(user) || is_thrall(user)
