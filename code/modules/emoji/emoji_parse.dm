#define LOCAL_EMOJI_IMAGE(icon_state, size) "<img class='icon icon-[icon_state]' src='[SSassets.transport.get_asset_url("[icon_state].png")]'>"

/proc/handleDiscordEmojis(msg, client/C, size = 32)
	var/list/listmsg = splittext_char(msg, " ")
	var/list/newMsg = list()
	var/list/discordEmojis = CONFIG_GET(str_list/emoji)
	var/static/list/emoji_cache = list()

	for(var/word in listmsg)
		var/emoji_name = lowertext(word)
		if(emoji_name in discordEmojis)
			var/icon/byond = emoji_cache[emoji_name]
			if(isnull(byond))
				byond = icon('icons/emoji.dmi', emoji_name)
				if(byond)
					byond.Scale(size, size)
					emoji_cache[emoji_name] = byond
			if(byond)
				var/asset_name = "emoji_[emoji_name]_[size].png"
				if(!SSassets.cache[asset_name])
					SSassets.transport.register_asset(asset_name, byond)
				SSassets.transport.send_assets(C, asset_name)
				var/url = SSassets.transport.get_asset_url(asset_name)
				newMsg += "<img src=\"[url]\" style=\"height: [size]px; width: [size]px; vertical-align: middle;\">"
			else
				newMsg += word
		else
			newMsg += word
	return jointext(newMsg, " ")

/proc/generateDiscordEmojiTable()
	// Fallback для старого browser popup
	var/list/emoji_names = CONFIG_GET(str_list/emoji)
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
				var/icon/byond = icon('icons/emoji.dmi', emojiName)
				if(byond)
					rowString += "<td>[icon2html(byond, usr)]<div>[emojiName]</div></td>"
				else
					rowString += "<td>[emojiName]</td>"
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
