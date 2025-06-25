/client/verb/randomtip()
	set category = STATPANEL_OOC
	set name = "Случайный совет"
	set desc = "Shows you a random tip"

	var/m

	var/list/randomtips = file2list("strings/tips.txt")
	var/list/memetips = file2list("strings/sillytips.txt")
	if(randomtips.len && prob(95))
		m = pick(randomtips)
	else if(memetips.len)
		m = pick(memetips)

	if(m)
		to_chat(src, chat_box_purple(span_purple("<b>Совет: </b>[html_encode(m)]")))
