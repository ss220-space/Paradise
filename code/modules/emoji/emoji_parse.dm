#define DISCORD_EMOJI_URL(id, size) "https://cdn.discordapp.com/emojis/[id]?size=[size]&quality=lossless"
#define DISCORD_EMOJI_IMAGE(id, size, imgsize) "<img src=\"[DISCORD_EMOJI_URL(id, size)]\" style=\"height: [imgsize]px; width: [imgsize]px;\" />"

/proc/loadDiscordEmojis()
	GLOB.discordEmojis.Cut()
	GLOB.emojiTableShownToUsers = null

	GLOB.discordEmojis = CONFIG_GET(keyed_list/emoji)

/proc/handleDiscordEmojis(msg)
	var/list/newMsg = list()
	var/list/listmsg = splittext_char(msg, " ")
	for (var/i = 1, i <= length(listmsg), i++)
		var/word = listmsg[i]
		// Весь этот костыль с length и copytext_char нужен только потому что
		// lowertext(word) == lowertext(emojiName) не работает вообще по какой-то причине
		for (var/emojiName in GLOB.discordEmojis)
			if (length(emojiName) != length(word))
				continue
			var/emojiId = GLOB.discordEmojis[emojiName]
			word = replacetext_char(word, emojiName, DISCORD_EMOJI_IMAGE(emojiId, 32, 32))
			if (copytext_char(word, 1, 2) == "<")
				word = lowertext(word)
		newMsg += word
	return jointext(newMsg, " ")

/proc/generateDiscordEmojiTable()
	var/const/itemsInRow = 7
	var/emojisListLength = length(GLOB.discordEmojis)
	var/html = "<table><tbody style=\"text-align:center;vertical-align:middle;border-spacing:12px;\">"
	for (var/i = 0, i < (emojisListLength / itemsInRow), i++)
		var/index = (i * itemsInRow)+1
		var/rowString = "<tr>"
		for (var/j = 0, j < itemsInRow, j++)
			if ((index+j) <= emojisListLength)
				var/emojiName = GLOB.discordEmojis[index+j]
				var/emojiId = GLOB.discordEmojis[emojiName]
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

	if (isnull(GLOB.emojiTableShownToUsers))
		GLOB.emojiTableShownToUsers = generateDiscordEmojiTable()

	var/datum/browser/popup = new(usr, "discord_emoji", "Discord emojis", 800, 460)
	popup.set_content(GLOB.emojiTableShownToUsers)
	popup.open()

#undef DISCORD_EMOJI_IMAGE
#undef DISCORD_EMOJI_URL
