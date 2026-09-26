ADMIN_VERB(toggle_vote_dead, R_ADMIN, "Toggle Dead Vote", "Toggle the vote for dead players on or off.", ADMIN_CATEGORY_SERVER)
	SSvote.toggle_dead_voting(user)

// Mob level verb that allows players to vote on the current vote.
GAME_VERB(/mob, vote, "Голосования", VERB_CATEGORY_OOC)
	if(!SSvote.initialized)
		to_chat(usr, span_notice("<i>Voting is not set up yet!</i>"))
		return
	SSvote.ui_interact(usr)
