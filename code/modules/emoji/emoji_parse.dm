#define DISCORD_EMOJI_URL(id, size) "https://cdn.discordapp.com/emojis/[id]?size=[size]&quality=lossless"
#define DISCORD_EMOJI_IMAGE(id, size, imgsize) "<img src=\"[DISCORD_EMOJI_URL(id, size)]\" style=\"height: [imgsize]px; width: [imgsize]px;\" />"

/proc/handleDiscordEmojis(msg)
	var/list/listmsg = splittext_char(msg, " ")
	var/list/newMsg = new/list(listmsg.len)
	var/list/discordEmojis = CONFIG_GET(keyed_list/emoji)
	for (var/word in listmsg)
		var/emoji = discordEmojis[lowertext(word)]
		if(emoji)
			newMsg += DISCORD_EMOJI_IMAGE(emoji, 32, 32)
		else
			newMsg += word
	return copytext_char(jointext(newMsg, " "), 2)

/proc/generateDiscordEmojiTable()
	var/const/itemsInRow = 7
	var/discordEmojis = CONFIG_GET(keyed_list/emoji)
	var/emojisListLength = length(discordEmojis)
	var/html = "<table><tbody style=\"text-align:center;vertical-align:middle;border-spacing:12px;\">"
	for (var/i = 0, i < (emojisListLength / itemsInRow), i++)
		var/index = (i * itemsInRow)+1
		var/rowString = "<tr>"
		for (var/j = 0, j < itemsInRow, j++)
			if ((index+j) <= emojisListLength)
				var/emojiName = discordEmojis[index+j]
				var/emojiId = discordEmojis[emojiName]
				rowString += "<td>[DISCORD_EMOJI_IMAGE(emojiId, 48, 48)]<div>[emojiName]</div></td>"
			else
				rowString += "<td></td>"
		rowString += "</tr>"
		html += rowString
	html += "</tbody></table>"
	return html

/client/verb/show_all_emojis()
	set name = "Show Emojis"
	set desc = "Shows all the emojis available in OOC/LOOC/DSAY"
	set category = "OOC"

	var/datum/browser/popup = new(usr, "discord_emoji", "Discord emojis", 800, 460)
	popup.set_content(generateDiscordEmojiTable())
	popup.open()

#undef DISCORD_EMOJI_IMAGE
#undef DISCORD_EMOJI_URL
