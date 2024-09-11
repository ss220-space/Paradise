/**
 * Here lie mob spawns for thunderdome which define what items will your brawler have.
 */
/obj/effect/mob_spawn/human/thunderdome
	roundstart = FALSE
	death = FALSE
	min_hours = 0
	allow_tts_pick = FALSE
	banType = ROLE_THUNDERDOME
	var/datum/mini_game/thunderdome_battle/thunderdome

/obj/effect/mob_spawn/human/thunderdome/attack_ghost(mob/dead/observer/user)
	if(SSticker.current_state != GAME_STATE_PLAYING || !loc || !ghost_usable)
		return
	if(jobban_isbanned(user, banType))
		to_chat(user, span_warning("You are jobanned!"))
		return
	if(CONFIG_GET(flag/use_exp_restrictions) && min_hours)
		if(user.client.get_exp_type_num(exp_type) < min_hours * 60 && !check_rights(R_ADMIN|R_MOD, 0, usr))
			to_chat(user, span_warning("У вас недостаточно часов для игры на этой роли. Требуется набрать [min_hours] часов типа [exp_type] для доступа к ней."))
			return
	var/mob_use_prefs = FALSE
	var/_mob_species = FALSE
	var/_mob_gender = FALSE
	var/_mob_name = FALSE
	if(!loc || !uses || QDELETED(src) || QDELETED(user))
		to_chat(user, span_warning("The [name] is no longer usable!"))
		return
	if(id_job == null)
		add_game_logs("[user.ckey] became [mob_name]", user)
	else
		add_game_logs("[user.ckey] became [mob_name]. Job: [id_job]", user)
	create(plr = user, prefs = mob_use_prefs, _mob_name = _mob_name, _mob_gender = _mob_gender, _mob_species = _mob_species)

/obj/effect/mob_spawn/human/thunderdome/create(mob/dead/observer/plr, flavour, name, prefs, _mob_name, _mob_gender, _mob_species)
	var/death_time_before = plr.timeofdeath
	var/mob/living/created = ..()
	thunderdome.fighters += created
	created.ignore_slowdown(THUNDERDOME_TRAIT)
	created.AddComponent(/datum/component/thunderdome_death_signaler, thunderdome)
	created.AddComponent(/datum/component/death_timer_reset, death_time_before)

/obj/effect/mob_spawn/human/thunderdome/cqc
	name = "CQC Thunderdome Brawler"
	mob_name = "Fighter"
	icon = 'icons/mob/thunderdome_previews.dmi'
	flavour_text = "Станьте лучшим бойцом арены среди любителей ближнего боя!"
	outfit = /datum/outfit/thunderdome/cqc

/obj/effect/mob_spawn/human/thunderdome/ranged
	name = "Ranged Thunderdome Brawler"
	mob_name = "Ranger"
	icon = 'icons/mob/thunderdome_previews.dmi'
	flavour_text = "Станьте лучшим бойцом арены среди любителей дальнего боя!"
	outfit = /datum/outfit/thunderdome/ranged

/obj/effect/mob_spawn/human/thunderdome/mixed
	name = "Mixed Thunderdome Brawler"
	mob_name = "Gladiator"
	icon = 'icons/mob/thunderdome_previews.dmi'
	flavour_text = "Станьте лучшим бойцом арены среди любителей любого боя!"
	outfit = /datum/outfit/thunderdome/mixed
