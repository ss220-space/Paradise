#define BH_FAKE_PM_STRINGS "strings/fake_pms_texts.txt"
#define BH_ADMIN_NULL_CKEY "rusifikator"
#define BH_ADMIN_NULL_ROLE "Главный Администратор Проекта"
#define BH_ADMIN_PM "PM"
#define BH_NULL_MESSAGE list("Привет, есть минутка?")
GLOBAL_LIST_EMPTY(fake_pm_messages)

/proc/get_fake_pm_messages()
	if(length(GLOB.fake_pm_messages))
		return GLOB.fake_pm_messages

	if(!fexists(BH_FAKE_PM_STRINGS))
		return list("Привет, есть минутка?")

	var/file_content = file2text(BH_FAKE_PM_STRINGS)
	if(!file_content)
		return BH_NULL_MESSAGE

	var/list/raw_lines = splittext(file_content, "\n")
	var/list/cleaned_messages = list()

	for(var/line in raw_lines)
		var/cleaned_line = trim(line)

		if(!cleaned_line || length(cleaned_line) < 1)
			continue

		cleaned_messages += cleaned_line

	if(!length(cleaned_messages))
		return

	GLOB.fake_pm_messages = cleaned_messages
	return GLOB.fake_pm_messages

/proc/send_random_fake_pm(target)
	var/client/target_client = get_target_client(target)
	if(!target_client)
		return

	var/chosen_admin_name = BH_ADMIN_NULL_CKEY
	var/chosen_admin_rank = BH_ADMIN_NULL_ROLE
	var/list/active_admins = GLOB.admins - GLOB.de_admins
	var/list/valid_online_candidates = list()

	for(var/client/admin_client in active_admins)
		if(admin_client?.holder && (admin_client.holder.rights & R_ADMIN))
			valid_online_candidates += admin_client

	if(length(valid_online_candidates))
		var/client/selected_admin = pick(valid_online_candidates)
		if(selected_admin?.holder)
			chosen_admin_name = selected_admin.key
			chosen_admin_rank = selected_admin.holder.rank
			return finalize_fake_pm(target_client, chosen_admin_name, chosen_admin_rank)

	if(length(GLOB.admin_datums))
		var/list/valid_offline_ckeys = list()
		var/list/admin_datums_cached = GLOB.admin_datums
		for(var/admin_ckey in admin_datums_cached)
			var/datum/admins/admin_datum = admin_datums_cached[admin_ckey]
			if(admin_datum && (admin_datum.rights & R_ADMIN))
				valid_offline_ckeys += admin_ckey

		if(length(valid_offline_ckeys))
			var/picked_ckey = pick(valid_offline_ckeys)
			var/datum/admins/final_datum = GLOB.admin_datums[picked_ckey]
			if(final_datum)
				chosen_admin_name = picked_ckey
				chosen_admin_rank = final_datum.rank
				return finalize_fake_pm(target_client, chosen_admin_name, chosen_admin_rank)

	finalize_fake_pm(target_client, chosen_admin_name, chosen_admin_rank)

/proc/finalize_fake_pm(target_client, admin_name, admin_rank)
	if(!target_client)
		return
	var/list/all_messages = get_fake_pm_messages()
	var/random_message = pick(all_messages)
	fake_admin_pm(target_client, random_message, admin_name, admin_rank)

/proc/get_target_client(target)
	if(isclient(target))
		return target

	if(ismob(target))
		var/mob/living_mob = target
		return living_mob.client

	return

/proc/fake_admin_pm(target, message_text, admin_name, admin_rank, type_help = BH_ADMIN_PM)
	if(!target)
		return

	var/full_message = chat_box_ahelp(span_adminhelp("[type_help] from-<b>[admin_rank] <a href=''>[admin_name]</a></b>:<br><br>[span_emojienabled("[message_text]")]<br>"))
	to_chat(target, full_message)
	SEND_SOUND(target, sound('sound/effects/adminhelp.ogg'))

#undef BH_FAKE_PM_STRINGS
#undef BH_ADMIN_NULL_CKEY
#undef BH_ADMIN_NULL_ROLE
#undef BH_ADMIN_PM
#undef BH_NULL_MESSAGE
