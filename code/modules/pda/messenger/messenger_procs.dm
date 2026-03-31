/proc/create_private_chat(var/target_name, datum/messenger_account/chat_initiator)
	if(!target_name)
		to_chat(usr, span_warning("Человек, с которым вы хотели начать диалог, не найден."))
		CRASH("the name of the second participant was not transmitted, name: [target_name]")

	if(!chat_initiator)
		to_chat(usr, span_warning("Ваш аккаунт не найден или не существует."))
		CRASH("the name of the first participant was not transmitted")

	var/name_private_chat = "Личная переписка с " + target_name
	var/description_private_chat = "Защищённый канал связи c " + target_name
	var/datum/messenger_chat/created_new_private_chat = new /datum/messenger_chat(
		name_private_chat,
		description_private_chat,
		null,
		FALSE,
		TRUE
	)
	var/datum/money_account/interlocutor_money_account = get_account_with_name(target_name)
	var/datum/messenger_account/interlocutor_messenger_account = interlocutor_money_account.messenger_profile

	// добавляем обоим участникам чат в мессенджер акк
	created_new_private_chat.add_member_in_chat(chat_initiator)
	created_new_private_chat.add_member_in_chat(interlocutor_messenger_account)

	return
