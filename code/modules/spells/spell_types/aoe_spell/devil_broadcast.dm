/datum/action/cooldown/spell/aoe/devil_broadcast
	name = "Сказать всем"
	desc = "Скажите что-нибудь миру, который собираетесь разрушить."

	button_icon = 'icons/mob/actions/actions_cult.dmi'
	button_icon_state = "cult_comms"
	spell_requirements = SPELL_REQUIRES_NO_ANTIMAGIC
	var/text
	var/message

/datum/action/cooldown/spell/aoe/devil_broadcast/cast(atom/cast_on)
	text = tgui_input_text(cast_on, "Что вы хотите сказать?", "Сказать")
	message = span_danger(span_fontsize5(text))
	. = ..()

/datum/action/cooldown/spell/aoe/devil_broadcast/get_things_to_cast_on(atom/center)
	var/all_players = list()
	for(var/mob/player_mob in GLOB.player_list)
		if(isnewplayer(player_mob) || !player_mob.client)
			continue
		all_players += player_mob
	return all_players

/datum/action/cooldown/spell/aoe/devil_broadcast/cast_on_thing_in_aoe(atom/victim, atom/caster)
	to_chat(victim, message)
	INVOKE_ASYNC(GLOBAL_PROC, /proc/tts_cast, caster, victim, message, caster.tts_seed, TRUE)

