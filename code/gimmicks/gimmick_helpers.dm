
GLOBAL_LIST_EMPTY(cached_fake_admins)

/proc/fake_admin_pm(target, msg = "Привет, есть минутка?", fake_admin_name = "Denchigo", fake_admin_rank = ADMIN, type_admin_help = ADMIN_PM, custom_link = "")
	var/msg_to_target = span_adminhelp3("-- Click the [fake_admin_rank]'s name to reply --</span>") + "\n"
	msg_to_target += chat_box_ahelp(span_adminhelp("[type_admin_help] from-<b>[fake_admin_rank] <a href='[custom_link]'>[fake_admin_name]</a></b>:<br><br>[span_emojienabled("[msg]")]<br>"))
	to_chat(target, msg_to_target, MESSAGE_TYPE_ADMINPM , confidential = TRUE)
	SEND_SOUND(target, sound('sound/effects/adminhelp.ogg'))

/proc/fake_mentor_pm(target, msg = "Как менять руки?", fake_mentor_name = "кружка", fake_admin_rank = MENTOR, type_admin_help = MENTOR_HELP, custom_link = "")
	var/msg_to_target = span_mentorhelp3("-- Click the [fake_admin_rank]'s name to reply --</span>") + "\n"
	msg_to_target += chat_box_mhelp(span_mentorhelp("[type_admin_help] from-<b>[fake_admin_rank] <a href='[custom_link]'>[fake_mentor_name]</a></b>:<br><br>[span_emojienabled("[msg]")]<br>"))
	to_chat(target, msg_to_target, MESSAGE_TYPE_MENTORPM, confidential = TRUE)
	SEND_SOUND(target, sound('sound/machines/notif1.ogg'))

/proc/send_random_fake_pm(target)
	var/datum/fake_administrator/admin = GLOB.cached_fake_admins[pick(GLOB.cached_fake_admins)]
	admin.send_random_msg(target)
