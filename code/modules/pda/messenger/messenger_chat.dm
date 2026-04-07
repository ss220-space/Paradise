/* TODO LIST:
* 1. не забудь добавить потом что если овнер ливнет, то надо взять первого админа,
* а если их нет, то чат удаляется;
*/

/**
 * Chat log data type, stores information about the chat members,
 * the messages themselves and other metadata.
 */

// ну кароче тк тут не постгря будем вот его юзать для уникальный чатиков
/datum/messenger_chat
	var/chat_id
	/// group name
	var/name_chat = "Неизвестный чат"
	/// chat description
	var/description_chat = "Нет описания"
	/// The creator and main admin in the chat
	var/datum/messenger_account/owner_chat
	/// people who are designated as the chat creator and can interact
	/// as the chat creator except for deletion
	var/list/datum/messenger_account/chat_admins
	/// a list of all chat participants
	var/list/datum/messenger_account/chat_members
	/// list of all messages in this chat
	var/list/datum/messenger_message/messages = list()
	/// Used to determine if you can talk in a chat
	var/can_reply = TRUE
	/// A variable that indicates whether this is a group
	var/is_group = FALSE
	/// a variable that determines whether a group is private or public
	var/is_private = TRUE
	/// Saved draft of a message so the sender can leave and come back later
	var/message_draft = ""

/datum/messenger_chat/New(name_chat, description_chat, owner_chat, is_group, is_private)
	src.chat_id = src.UID()
	src.name_chat = name_chat
	src.description_chat = description_chat
	src.owner_chat = owner_chat
	src.chat_admins = list()
	src.chat_members = list()
	src.is_group = is_group
	src.is_private = is_private

/datum/messenger_chat/Destroy()
	for(var/datum/messenger_account/member as anything in chat_members)
		member.delete_chat(src)
	. = ..()

/**
 * Can update multiple fields at once.
 */
/datum/messenger_chat/proc/update_chat(
	name_chat = null, description_chat = null, owner_chat = null, is_private = null)
	if(name_chat)
		src.name_chat = name_chat
	if(description_chat)
		src.description_chat = description_chat
	if(owner_chat)
		src.owner_chat = owner_chat
	if(is_private)
		src.is_private = is_private

/**
 * Return FALSE if the account was not added.
 *		  TRUE  if it was.
 */
/datum/messenger_chat/proc/add_admin_in_chat(datum/messenger_account/added_member)
	if(!added_member)
		return FALSE
	// Checking if you are already a member of the chat.
	if(!check_account_in_list(added_member, chat_members))
		chat_members += added_member
	// Checking if you are already an admin
	if(check_account_in_list(added_member, chat_admins))
		return FALSE
	chat_admins += added_member
	return TRUE

/**
 * Return FALSE if the account was not added.
 *		  TRUE  if it was.
 */
/datum/messenger_chat/proc/add_member_in_chat(datum/messenger_account/added_member)
	if(!added_member)
		return FALSE
	// Checking if you are already a member of the chat.
	if(check_account_in_list(added_member, chat_members))
		return FALSE
	chat_members += added_member
	added_member.add_chat(src)
	return TRUE

/**
 * Adds a message to the chat log and optionally shows the chat in recents.
 * Call this instead of adding to messages directly.
 */
/datum/messenger_chat/proc/add_message(datum/messenger_message/added_message)
	messages += added_message
	return added_message

// сделать прок с инкрементом непрочитанных сообщений

/datum/messenger_chat/proc/get_ui_data(mob/user)
	var/list/data = list()
	data["chat_id"] = chat_id
	data["name_chat"] = name_chat
	data["description_chat"] = description_chat
	// booleans
	data["can_reply"] = can_reply
	data["is_group"] = is_group
	data["is_private"] = is_private
	data["message_draft"] = message_draft

	if(is_group)
		data["owner_chat"] = owner_chat.get_account_info()
		data["chat_admins"] = get_admins()

	data["chat_members"] = get_members()
	data["messages"] = get_messages(user)
	return data

/datum/messenger_chat/proc/get_admins()
	var/list/chat_admins_list = list()
	for(var/datum/messenger_account/checked_account as anything in chat_admins)
		chat_admins_list += list(checked_account.get_account_info())
	return chat_admins_list

/datum/messenger_chat/proc/get_members()
	var/list/chat_members_list = list()
	for(var/datum/messenger_account/checked_account as anything in chat_members)
		chat_members_list += list(checked_account.get_account_info())
	return	chat_members_list

/datum/messenger_chat/proc/get_messages(mob/user)
	var/list/messages_list = list()
	for(var/datum/messenger_message/message as anything in messages)
		messages_list += list(message.get_ui_data(user))
	return messages_list

// метод который позволяет узнать с каким аккаунтом уже есть приватный чат
/datum/messenger_chat/proc/get_created_private_chat_users(list/used_targets, var/datum/messenger_account/exclude_account)
	if(is_group)
		return

	for(var/datum/messenger_account/checked_acc as anything in chat_members)
		if(checked_acc != exclude_account)
			used_targets += checked_acc
