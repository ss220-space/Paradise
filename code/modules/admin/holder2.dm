GLOBAL_LIST_EMPTY(admin_datums)
/// This is protected because we dont want people making their own admin ranks, for obvious reasons
GLOBAL_PROTECT(admin_datums)

GLOBAL_VAR_INIT(href_token, GenerateToken())
GLOBAL_PROTECT(href_token)

/proc/GenerateToken()
	. = ""
	for(var/index in 1 to 32)
		. += "[rand(10)]"

/datum/admins
	var/rank = "No Rank"
	var/client/owner
	/// Bitflag containing the current rights this admin holder is assigned to
	var/rights = 0
	var/fakekey
	var/big_brother	= FALSE
	/// Was this auto-created for someone connecting from localhost?
	var/is_localhost_autoadmin = FALSE
	/// Unique-to-session randomly generated token given to each admin to help add detail to logs on admin interactions with hrefs
	var/href_token
	/// Our currently linked marked datum
	var/datum/marked_datum
	/// Tabs of secrets
	var/current_tab = 0

/datum/admins/New(initial_rank, initial_rights, ckey)
	if(IsAdminAdvancedProcCall())
		to_chat(usr, span_boldannounceooc("Admin rank creation blocked: Advanced ProcCall detected."))
		log_and_message_admins("attempted to edit feedback a new admin rank via advanced proc-call")
		return
	if(!ckey)
		error("Admin datum created without a ckey argument. Datum has been deleted")
		qdel(src)
		return
	if(initial_rank)
		rank = initial_rank
	if(initial_rights)
		rights = initial_rights
	href_token = GenerateToken()
	GLOB.admin_datums[ckey] = src

/datum/admins/Destroy()
	if(IsAdminAdvancedProcCall())
		to_chat(usr, span_boldannounceooc("Admin rank deletion blocked: Advanced ProcCall detected."))
		log_and_message_admins("attempted to delete an admin rank via advanced proc-call")
		return
	..()
	return QDEL_HINT_HARDDEL_NOW

/datum/admins/proc/associate(client/C)
	if(IsAdminAdvancedProcCall())
		to_chat(usr, span_boldannounceooc("Rank association blocked: Advanced ProcCall detected."))
		log_and_message_admins("attempted to associate an admin rank to a new client via advanced proc-call")
		return
	if(istype(C))
		owner = C
		owner.holder = src
		owner.add_admin_verbs()	//TODO
		remove_verb(owner, /client/proc/readmin)
		owner.init_verbs() //re-initialize the verb list
		GLOB.admins |= C

/datum/admins/proc/disassociate()
	if(IsAdminAdvancedProcCall())
		to_chat(usr, span_boldannounceooc("Rank disassociation blocked: Advanced ProcCall detected."))
		log_and_message_admins("attempted to disassociate an admin rank from a client via advanced proc-call")
		return
	if(owner)
		GLOB.admins -= owner
		owner.remove_admin_verbs()
		owner.init_verbs()
		owner.holder = null
		owner = null

/**
 * Check if the current user has admin rights
 *
 * Checks if usr is an admin with at least ONE of the flags in rights_required.
 * If rights_required == FALSE, simply checks if they are an admin. If the check fails
 * and show_msg is TRUE, prints a message explaining why.
 *
 * Note: This checks usr, not src. To check someone else's rank in a proc they didn't
 * call, use `if(client.holder.rights & R_ADMIN)` directly.
 *
 * Arguments:
 * * rights_required - Bitflags of required admin rights (FALSE for any admin)
 * * show_msg - If TRUE, shows a message to the user on failure
 * * user - The mob to check rights for(defaults to usr)
 * * all - If TRUE, requires ALL flags in rights_required instead of ANY
 */
/proc/check_rights(rights_required, show_msg = TRUE, mob/user = usr, all = FALSE)
	if(user?.client)
		return check_rights_ckey(rights_required, show_msg, user.ckey, all)
	return FALSE

/// Check if a /client has admin rights
/proc/check_rights_client(rights_required, show_msg, client/user_client, all = FALSE)
	if(user_client)
		return check_rights_ckey(rights_required, show_msg, user_client.ckey, all)
	return FALSE

/// Check if a ckey has admin rights
/proc/check_rights_ckey(rights_required, show_msg, ckey, all)
	var/datum/admins/holder = GLOB.admin_datums[ckey]
	if(!holder)
		if(show_msg)
			to_chat(GLOB.directory[ckey], span_red("Error: You are not an admin."), confidential = TRUE)
		return FALSE

	if(!rights_required)
		return TRUE

	if((rights_required & holder.rights) == rights_required)
		return TRUE
	else if(!all && (rights_required & holder.rights))
		return TRUE

	if(show_msg)
		if(all)
			to_chat(GLOB.directory[ckey], span_red("Error: You do not have sufficient rights to do that. You require ALL of the following flags:[rights2text(rights_required," ")]."), confidential = TRUE)
		else
			to_chat(GLOB.directory[ckey], span_red("Error: You do not have sufficient rights to do that. You require ONE of the following flags:[rights2text(rights_required," ")]."), confidential = TRUE)

	return FALSE

/client/proc/deadmin()
	if(IsAdminAdvancedProcCall())
		to_chat(usr, span_boldannounceooc("Deadmin blocked: Advanced ProcCall detected."))
		log_and_message_admins("attempted to de-admin a client via advanced proc-call")
		return
	GLOB.admin_datums -= ckey
	if(holder)
		holder.disassociate()
		qdel(holder)
	if(isobserver(mob))
		var/mob/dead/observer/observer = mob
		observer.update_admin_actions()
	return TRUE

//This proc checks whether subject has at least ONE of the rights specified in rights_required.
/proc/check_rights_for(client/subject, rights_required)
	if(subject?.holder)
		if(rights_required && !(rights_required & subject.holder.rights))
			return FALSE
		return TRUE
	return FALSE

/datum/admins/vv_edit_var(var_name, var_value)
	return FALSE // no admin abuse

/datum/admins/can_vv_delete()
	return FALSE // don't break shit either

/**
 * Requires the holder to have all the rights specified
 *
 * rights_required = R_ADMIN|R_EVENT means they must have both flags, or it will return false
 */
/proc/check_rights_all(rights_required, show_msg = TRUE, mob/user = usr)
	if(!user?.client)
		return FALSE

	if(!rights_required)
		if(user.client.holder)
			return TRUE

		if(show_msg)
			to_chat(user, span_red("Ошибка: Вы не админ."))

		return FALSE

	if(!user.client.holder)
		return FALSE

	if((user.client.holder.rights & rights_required) == rights_required)
		return TRUE

	if(show_msg)
		to_chat(user, span_red("Ошибка: У вас недостаточно прав для этого. Вам необходимы следующие флаги:[rights2text(rights_required, " ")]."))

	return FALSE
