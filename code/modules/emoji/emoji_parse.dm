/proc/handleDiscordEmojis(msg, client/target, size = 32)
	if(!target)
		return msg

	var/list/message_words = splittext_char(msg, " ")
	var/list/new_message = list()

	var/list/emoji_names = emoji_cache_get_emoji_names()

	var/list/emoji_names_assoc = list()
	for(var/name in emoji_names)
		emoji_names_assoc[lowertext(name)] = TRUE

	for(var/word in message_words)
		var/emoji_name = lowertext(word)
		if(!emoji_names_assoc[emoji_name])
			new_message += word
			continue

		var/icon/emoji_icon = emoji_cache_get_icon(emoji_name, size)
		if(!emoji_icon)
			new_message += word
			continue

		if(SSassets)
			var/asset_name = "emoji_[emoji_name]_[size].png"
			if(!SSassets.cache[asset_name])
				SSassets.transport.register_asset(asset_name, emoji_icon)
			SSassets.transport.send_assets(target, asset_name)
			var/url = SSassets.transport.get_asset_url(asset_name)
			new_message += "<img src=\"[url]\" style=\"height: [size]px; width: [size]px; vertical-align: middle;\">"

	return jointext(new_message, " ")

/proc/generateDiscordEmojiTable()
	// Fallback для старого browser popup
	var/list/emoji_names = emoji_cache_get_emoji_names()
	var/const/itemsInRow = 7
	var/emojisListLength = length(emoji_names)

	if(!emojisListLength)
		return "<p>Emoji list is empty</p>"

	var/html = "<table><tbody style=\"text-align:center;vertical-align:middle;border-spacing:12px;\">"
	for(var/i = 0, i < (emojisListLength / itemsInRow), i++)
		var/index = (i * itemsInRow)+1
		var/rowString = "<tr>"
		for(var/j = 0, j < itemsInRow, j++)
			if((index+j) <= emojisListLength)
				var/emojiName = emoji_names[index+j]
				var/icon/emoji_icon = emoji_cache_get_icon(emojiName, 48)
				if(emoji_icon)
					rowString += "<td>[icon2html(emoji_icon, usr)]<div>[html_encode(emojiName)]</div></td>"
				else
					rowString += "<td>[html_encode(emojiName)]</td>"
			else
				rowString += "<td></td>"
		rowString += "</tr>"
		html += rowString
	html += "</tbody></table>"
	return html

/client/verb/show_all_emojis()
	set name = "Эмодзи"
	set desc = "Shows all the emojis available in OOC/LOOC/DSAY"
	set category = VERB_CATEGORY_OOC

	var/datum/browser/popup = new(usr, "discord_emoji", "Discord emojis", 800, 460)
	popup.set_content(generateDiscordEmojiTable())
	popup.open()
