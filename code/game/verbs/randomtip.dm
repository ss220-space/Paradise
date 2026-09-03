GAME_VERB_DESC(/client, randomtip, "Случайный совет", "Shows you a random tip", VERB_CATEGORY_OOC)

	var/tip

	var/list/randomtips = world.file2list("strings/tips.txt")
	var/list/memetips = world.file2list("strings/sillytips.txt")
	if(length(randomtips) && prob(95))
		tip = pick(randomtips)
	else if(length(memetips))
		tip = pick(memetips)

	if(tip)
		to_chat(src, custom_boxed_message("purple_box", span_purple("<b>Совет: </b>[html_encode(tip)]")))
