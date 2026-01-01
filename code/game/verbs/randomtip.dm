/client/verb/randomtip()
	set category = VERB_CATEGORY_OOC
	set name = "Случайный совет"
	set desc = "Shows you a random tip"

	var/m

	var/list/randomtips = world.file2list("strings/tips.txt")
	var/list/memetips = world.file2list("strings/sillytips.txt")
	if(length(randomtips) && prob(95))
		m = pick(randomtips)
	else if(length(memetips))
		m = pick(memetips)

	if(m)
		to_chat(src, chat_box_purple(span_purple("<b>Совет: </b>[html_encode(m)]")))
