ADMIN_VERB(toggle_vote_dead, R_ADMIN, "Переключить голосование мёртвых", "Включить или выключить возможность голосования для призраков.", ADMIN_CATEGORY_SERVER)
	SSvote.toggle_dead_voting(user)

// Mob level verb that allows players to vote on the current vote.
GAME_VERB(/mob, vote, "Голосования", VERB_CATEGORY_OOC)
	if(!SSvote.initialized)
		to_chat(usr, span_notice("<i>Голосование ещё не настроено!</i>"))
		return
	SSvote.ui_interact(usr)
