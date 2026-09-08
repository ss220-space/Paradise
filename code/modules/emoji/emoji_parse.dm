#define DISCORD_EMOJI_URL(id, size) "https://cdn.discordapp.com/emojis/[id]?size=[size]&quality=lossless"
#define DISCORD_EMOJI_IMAGE(id, size, imgsize) "<img src=\"[DISCORD_EMOJI_URL(id, size)]\" style=\"height: [imgsize]px; width: [imgsize]px;\" />"

/proc/handle_emojis(msg)
	msg = emoji_parse(msg)
	return handle_discord_emojis(msg)

/proc/emoji_parse(text) //turns :ai: into an emoji in text.
	if(!text)
		return text
	. = text
	if(!CONFIG_GET(flag/emojis))
		return
	var/static/list/emojis = icon_states(icon(EMOJI_SET))
	var/parsed = ""
	var/pos = 1
	var/search = 0
	var/emoji = ""
	while(TRUE)
		search = findtext(text, ":", pos)
		parsed += copytext(text, pos, search)
		if(search)
			pos = search
			search = findtext(text, ":", pos + length(text[pos]))
			if(search)
				emoji = LOWER_TEXT(copytext(text, pos + length(text[pos]), search))
				var/datum/asset/spritesheet_batched/sheet = get_asset_datum(/datum/asset/spritesheet_batched/chat)
				var/tag = sheet.icon_tag("emoji-[emoji]")
				if(tag)
					parsed += tag
					pos = search + length(text[pos])
				else
					parsed += copytext(text, pos, search)
					pos = search
				emoji = ""
				continue
			else
				parsed += copytext(text, pos, search)
		break
	return parsed

/proc/emoji_sanitize(text) //cuts any text that would not be parsed as an emoji
	. = text
	if(!CONFIG_GET(flag/emojis))
		return
	var/static/list/emojis = icon_states(icon(EMOJI_SET))
	var/final = "" //only tags are added to this
	var/pos = 1
	var/search = 0
	while(1)
		search = findtext(text, ":", pos)
		if(search)
			pos = search
			search = findtext(text, ":", pos + length(text[pos]))
			if(search)
				var/word = LOWER_TEXT(copytext(text, pos + length(text[pos]), search))
				if(word in emojis)
					final += LOWER_TEXT(copytext(text, pos, search + length(text[search])))
				pos = search + length(text[search])
				continue
		break
	return final

/proc/handle_discord_emojis(msg)
	var/list/listmsg = splittext_char(msg, " ")
	var/list/newMsg = list()
	var/list/discordEmojis = CONFIG_GET(keyed_list/emoji)
	for(var/word in listmsg)
		var/emoji = discordEmojis[lowertext(word)]
		if(emoji)
			newMsg += DISCORD_EMOJI_IMAGE(emoji, 32, 32)
		else
			newMsg += word
	return jointext(newMsg, " ")

/proc/generateDiscordEmojiTable()
	var/const/itemsInRow = 7
	var/discordEmojis = CONFIG_GET(keyed_list/emoji)
	var/emojisListLength = length(discordEmojis)
	var/html = "<table><tbody style=\"text-align:center;vertical-align:middle;border-spacing:12px;\">"
	for(var/i = 0, i < (emojisListLength / itemsInRow), i++)
		var/index = (i * itemsInRow)+1
		var/rowString = "<tr>"
		for(var/j = 0, j < itemsInRow, j++)
			if((index+j) <= emojisListLength)
				var/emojiName = discordEmojis[index+j]
				var/emojiId = discordEmojis[emojiName]
				rowString += "<td>[DISCORD_EMOJI_IMAGE(emojiId, 48, 48)]<div>[emojiName]</div></td>"
			else
				rowString += "<td></td>"
		rowString += "</tr>"
		html += rowString
	html += "</tbody></table>"
	return html

GAME_VERB_DESC(/client, show_all_emojis, "Discord Эмодзи", "Shows all discord the emojis available in OOC/LOOC/DSAY", VERB_CATEGORY_OOC)
	var/datum/browser/popup = new(usr, "discord_emoji", "Discord emojis", 800, 460)
	popup.set_content(generateDiscordEmojiTable())
	popup.open()

#undef DISCORD_EMOJI_IMAGE
#undef DISCORD_EMOJI_URL
