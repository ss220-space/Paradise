/obj/effect/proc_holder/spell/pointed/eldritch_telepathy
	name = "Жуткая Телепатия"
	desc = "Телепатически передаёт сообщение цели."
	action_icon = 'icons/mob/actions/actions_ecult.dmi'
	action_icon_state = "mansus_link"
	action_background_icon = 'icons/mob/actions/backgrounds.dmi'
	action_background_icon_state = "bg_heretic"
	overlay_icon_state = "bg_heretic_border"
	ranged_mousepointer = 'icons/effects/mouse_pointers/throw_target.dmi'

	school = SCHOOL_FORBIDDEN
	human_req = FALSE
	clothes_req = FALSE
	base_cooldown = 5 SECONDS

	spell_requirements = NONE
	antimagic_flags = MAGIC_RESISTANCE|MAGIC_RESISTANCE_MIND

	active_msg = "Вы готовитесь прошептать кому-то в голову..."

	/// The span surrounding the telepathy message.
	var/telepathy_span = "notice"
	/// The bolded span surrounding the telepathy message.
	var/bold_telepathy_span = "boldnotice"


/obj/effect/proc_holder/spell/pointed/eldritch_telepathy/valid_target(atom/cast_on)
	. = ..()
	if(!.)
		return FALSE
	return isliving(cast_on)


/obj/effect/proc_holder/spell/pointed/eldritch_telepathy/cast(list/targets, mob/user = usr)
	. = ..()
	var/mob/living/cast_on = targets[1]
	if(!istype(cast_on))
		return FALSE

	var/message = tgui_input_text(user, "Что вы хотите прошептать [cast_on.declent_ru(DATIVE)]?", "[name]", max_length = MAX_MESSAGE_LEN)
	if(!message || QDELETED(src) || QDELETED(user) || QDELETED(cast_on))
		return FALSE

	var/formatted_message = "[span_notice(message)]"

	to_chat(user, "[span_boldnotice("Вы передаёте [cast_on.declent_ru(DATIVE)]:")] [formatted_message]")
	if(!cast_on.can_block_magic(antimagic_flags, charge_cost = 0)) // hear no evil
		cast_on.balloon_alert(cast_on, "вы слышите голос")
		to_chat(cast_on, "[span_boldnotice("Вы слышите голос в своей голове...")] [formatted_message]")
	else
		user.balloon_alert(user, "передача заблокирована!")
		to_chat(user, span_warning("Что-то заблокировало вашу передачу!"))

	for(var/mob/dead/observer/ghost in GLOB.dead_mob_list)
		to_chat(ghost, "[ghost_follow_link(user, ghost)] [span_boldnotice("[user] [name] [cast_on]:")] [formatted_message]")

	log_say("(ELDRITCH TPATH to [key_name(cast_on)]) [message]", user)
	return TRUE
