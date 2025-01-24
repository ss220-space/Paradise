/datum/antagonist/blob_minion
	name = "\improper Blob Minion"
	roundend_category = "blobs"
	job_rank = ROLE_BLOB
	special_role = SPECIAL_ROLE_BLOB_MINION
	wiki_page_name = "Blob"
	russian_wiki_name = "Блоб"
	show_in_roundend = FALSE
	show_in_orbit = FALSE
	antag_menu_name = "Миньон блоба"
	/// The blob core that this minion is attached to
	var/datum/weakref/overmind
	/// Action to talk with nearby mobs
	var/datum/action/innate/blob/minion_talk/mob_talk

/datum/antagonist/blob_minion/can_be_owned(datum/mind/new_owner)
	. = ..() && isminion(new_owner?.current)

/datum/antagonist/blob_minion/New(mob/camera/blob/overmind)
	. = ..()
	src.overmind = WEAKREF(overmind)

/datum/antagonist/blob_minion/add_owner_to_gamemode()
	var/datum/game_mode/mode = SSticker.mode
	if(mode)
		mode.blobs["minions"] |= owner

/datum/antagonist/blob_minion/remove_owner_from_gamemode()
	var/datum/game_mode/mode = SSticker.mode
	if(mode)
		mode.blobs["minions"] -= owner


/datum/antagonist/blob_minion/apply_innate_effects(mob/living/mob_override)
	var/mob/living/user = ..(mob_override)
	if(!user)
		return
	if(!mob_talk)
		mob_talk = new
	mob_talk.Grant(user)
	return user


/datum/antagonist/blob_minion/remove_innate_effects(mob/living/mob_override)
	var/mob/living/user = ..(mob_override)
	if(!user)
		return
	mob_talk?.Remove(user)
	return user

/datum/antagonist/blob_minion/roundend_report_header()
	return


/datum/antagonist/blob_minion/on_gain()
	. = ..()
	give_objectives()

/datum/antagonist/blob_minion/give_objectives()
	var/datum/objective/blob_minion/objective = new
	objective.owner = owner
	objective.overmind = overmind?.resolve()
	objectives |= objective

/datum/antagonist/blob_minion/blobernaut
	name = "\improper Blobernaut"


/datum/antagonist/blob_minion/blobernaut/greet()
	. = ..()
	var/mob/camera/blob/blob = overmind?.resolve()
	var/datum/blobstrain/blobstrain = blob.blobstrain
	. += span_dangerbigger("Вы блобернаут! Вы должны помогать всем формам блоба в их миссии по уничтожению всего!")
	. += span_info("Вы сильны, крепки, и медленно регенерируете в пределах плиток блоба, [span_cultlarge("но вы будете медленно умирать, если их рядом нету")] или если фабрика, создавшая вас, будет разрушена.")
	. += span_info("Вы можете общаться с другими бернаутами, миньенами, зараженными и надразумами <b>телепатически</b> заместо обычного общения.")
	. += span_info("Штамм вашего надразума: <b><font color=\"[blobstrain.color]\">[blobstrain.name]</b></font>!")
	. += span_info("Штамм <b><font color=\"[blobstrain.color]\">[blobstrain.name]</b></font> [blobstrain.shortdesc ? "[blobstrain.shortdesc]" : "[blobstrain.description]"]")

/**
 * Takes any datum `source` and checks it for blob_minion datum.
 */
/proc/isblobminion(datum/source)
	if(!source)
		return FALSE

	if(istype(source, /datum/mind))
		var/datum/mind/our_mind = source
		return our_mind.has_antag_datum(/datum/antagonist/blob_minion)

	if(!ismob(source))
		return FALSE

	var/mob/mind_holder = source
	if(!mind_holder.mind)
		return FALSE

	return mind_holder.mind.has_antag_datum(/datum/antagonist/blob_minion)
