/// The max amount of options someone can have in a custom vote.
#define MAX_CUSTOM_VOTE_OPTIONS 10

/datum/vote/custom_vote
	name = "Своё"
	default_message = "Нажмите здесь, чтобы создать своё голосование."

// Custom votes ares always accessible.
/datum/vote/custom_vote/is_accessible_vote()
	return TRUE

/datum/vote/custom_vote/reset()
	default_choices = null
	override_question = null
	count_method = VOTE_COUNT_METHOD_SINGLE
	return ..()

/datum/vote/custom_vote/can_be_initiated(forced)
	. = ..()
	if(. != VOTE_AVAILABLE)
		return .
	if(forced)
		return .

	// Custom votes can only be created if they're forced to be made.
	// (Either an admin makes it, or otherwise.)
	return "Только администраторы могут создавать такие голосования."

/datum/vote/custom_vote/create_vote(mob/vote_creator)
	var/custom_count_method = tgui_input_list(
		user = vote_creator,
		message = "Один вариант или несколько?",
		title = "Способ подсчёта",
		items = list("Один", "Несколько"),
		default = "Один",
	)
	switch(custom_count_method)
		if("Один")
			count_method = VOTE_COUNT_METHOD_SINGLE
		if("Несколько")
			count_method = VOTE_COUNT_METHOD_MULTI
		if(null)
			return FALSE
		else
			stack_trace("Got '[custom_count_method]' in create_vote() for custom voting.")
			to_chat(vote_creator, span_boldwarning("Неизвестный способ подсчёта. Сообщите кодеру."))
			return FALSE

	var/custom_win_method = tgui_input_list(
		user = vote_creator,
		message = "Как определить победителя?",
		title = "Способ определения победителя",
		items = list(VOTE_WINNER_METHOD_SIMPLE, VOTE_WINNER_METHOD_WEIGHTED_RANDOM, VOTE_WINNER_METHOD_NONE),
		default = VOTE_WINNER_METHOD_SIMPLE,
	)
	switch(custom_win_method)
		if(VOTE_WINNER_METHOD_SIMPLE)
			winner_method = VOTE_WINNER_METHOD_SIMPLE
		if(VOTE_WINNER_METHOD_WEIGHTED_RANDOM)
			winner_method = VOTE_WINNER_METHOD_WEIGHTED_RANDOM
		if(VOTE_WINNER_METHOD_NONE)
			winner_method = VOTE_WINNER_METHOD_NONE
		if(null)
			return FALSE
		else
			stack_trace("Got '[custom_win_method]' in create_vote() for custom voting.")
			to_chat(vote_creator, span_boldwarning("Неизвестный способ определения победителя. Сообщите кодеру."))
			return FALSE

	var/display_stats = tgui_alert(
		vote_creator,
		"Показывать статистику голосования?",
		"Статистика голосования",
		list("Да", "Нет"),
	)

	if(isnull(display_stats))
		return FALSE
	display_statistics = display_stats == "Да"

	if(!display_statistics)
		var/set_print_result = tgui_alert(
			vote_creator,
			"Показать итоги после окончания голосования?",
			"Итоги после голосования",
			list("Да", "Нет"),
		)

		if(isnull(set_print_result))
			return FALSE

		print_results = set_print_result == "Да"

	override_question = tgui_input_text(vote_creator, "За что голосование?", "Своё голосование")
	if(!override_question)
		return FALSE

	default_choices = list()
	for(var/i in 1 to MAX_CUSTOM_VOTE_OPTIONS)
		var/option = tgui_input_text(vote_creator, "Введите вариант или нажмите отмена, чтобы завершить. Максимум [MAX_CUSTOM_VOTE_OPTIONS].", "Варианты", max_length = MAX_NAME_LEN)
		if(!vote_creator?.client)
			return FALSE
		if(!option)
			break

		default_choices += option

	if(!length(default_choices))
		return FALSE
	// Sanity for all the tgui input stalling we are doing
	if(isnull(vote_creator.client?.holder))
		return FALSE

	return ..()

/datum/vote/custom_vote/initiate_vote(initiator, duration)
	. = ..()
	. += "\n[override_question]"

#undef MAX_CUSTOM_VOTE_OPTIONS
