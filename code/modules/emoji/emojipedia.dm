/// A tablet app that lets anyone see all the valid emoji they can send via a PDA message (and even OOC!)
GAME_VERB_DESC(/client, emojipedia, "Emojipedia", "Literally an emojipedia, a list of all the emoji available for OOC use.", VERB_CATEGORY_OOC)

	var/datum/ui_module/emojipedia/emojipedia = new()
	emojipedia.ui_interact(usr)

/datum/ui_module/emojipedia
	name = "Emojipedia"
	/// Store the list of potential emojis here.
	var/static/list/emoji_list = icon_states(icon(EMOJI_SET))

/datum/ui_module/emojipedia/ui_state(mob/user)
	return GLOB.always_state

/datum/ui_module/emojipedia/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "NtosEmojipedia", name)
		ui.autoupdate = FALSE
		ui.open()

/datum/ui_module/emojipedia/ui_static_data(mob_user)
	var/list/data = list()
	for(var/emoji in emoji_list)
		data["emoji_list"] += list(list(
			"name" = emoji,
		))

	return data

/datum/ui_module/emojipedia/ui_assets(mob/user)
	return list(
		get_asset_datum(/datum/asset/spritesheet_batched/emojipedia),
	)
