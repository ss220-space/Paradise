/client/proc/aooc(msg as text)
	set category = STATPANEL_ADMIN_ADMIN
	set name = "AOOC"
	set desc = "Antagonist OOC"

	if(!check_rights(R_ADMIN))	return

	msg = sanitize(msg)
	if(!msg)	return

	var/display_name = src.key
	if(holder?.fakekey)
		display_name = holder.fakekey

	for(var/mob/M in GLOB.mob_list)
		if((M.mind && M.mind.special_role && M.client) || (M.client && M.client.holder && (M.client.holder.rights & R_ADMIN)))
			to_chat(M, "<font color='#960018'>[span_ooc("<span class='prefix'>AOOC:")] <em>[display_name]:</em> [span_message("[msg]")]</span></font>")

	log_aooc(msg, src)
