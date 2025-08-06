
//very shitcode
/proc/fake_admin_pm(target, msg = "Привет, есть минутка?", fake_admin_name = "Denchigo", fake_admin_rank = "Админ", type_admin_help = "PM", custom_link = "")
	. += "<span class='adminhelp' size='3'>-- Click the [fake_admin_rank]'s name to reply --</span>\n"
	. += chat_box_ahelp(span_adminhelp("<span class='adminhelp'>[type_admin_help] from-<b>[fake_admin_rank] <a href='[custom_link]'>[fake_admin_name]</a></b>:<br><br>[span_emojienabled("[msg]")]<br></span>"))
	to_chat(target,. , MESSAGE_TYPE_ADMINPM, confidential = TRUE)
	SEND_SOUND(target, sound('sound/effects/adminhelp.ogg'))

/proc/send_random_fake_pm(target)
	var/random_admin = pick(subtypesof(/datum/fake_administrator))
	var/datum/fake_administrator/admin = new random_admin
	admin.send_random_msg(target)
