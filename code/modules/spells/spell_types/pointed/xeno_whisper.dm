/datum/action/cooldown/spell/pointed/xeno_whisper
	name = "Шёпот"
	desc = "Прошептать в разум цели."
	button_icon_state = "alien_whisper"
	background_icon_state = "bg_alien"
	active_background_icon_state = "bg_alien"
	cast_range = 20
	spell_requirements = NONE
	check_flags = AB_CHECK_CONSCIOUS
	var/plasma_cost = 10

/datum/action/cooldown/spell/pointed/xeno_whisper/is_valid_target(atom/cast_on)
	return ..() && isliving(cast_on)

/datum/action/cooldown/spell/pointed/xeno_whisper/create_new_handler()
	var/datum/spell_handler/alien/handler = new(src, plasma_cost)
	return handler

/datum/action/cooldown/spell/pointed/xeno_whisper/cast(atom/cast_on)
	. = ..()
	var/mob/living/target = cast_on

	var/msg = tgui_input_text(owner, "Сообщение:", "Шёпот")
	if(!msg)
		reset_spell_cooldown()
		return
	log_say("(AWHISPER to [key_name(target)]) [msg]", owner)
	target.balloon_alert(target, "вы слышите голос в голове...")
	to_chat(target, "<span class='noticealien'>Вы слышите странный, чужеродный голос...<span class='noticealien'> [msg]")
	to_chat(owner, span_noticealien("You said: [msg] to [target]"))
	for(var/mob/dead/observer/ghosts in GLOB.player_list)
		ghosts.show_message("<i>Ксеноморф ([ghost_follow_link(owner, ghost = ghosts)]) <b>[owner.declent_ru(NOMINATIVE)]</b> говорит ([ghost_follow_link(target, ghost = ghosts)]) <b>[target.declent_ru(DATIVE)]</b>: [msg]</i>")

