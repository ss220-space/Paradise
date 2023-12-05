#define DISCORD_EMOJI_URL(id, size) "https://cdn.discordapp.com/emojis/[id]?size=[size]&quality=lossless"
#define DISCORD_EMOJI_IMAGE(id, size, imgsize) "<img src=\"[DISCORD_EMOJI_URL(id, size)]\" style=\"height: [imgsize]px; width: [imgsize]px;\" />"

var/list/discordEmojis = list()
var/emojiTableShownToUsers = null

/proc/loadDiscordEmojis()
	discordEmojis.Cut()
	emojiTableShownToUsers = null

	var/list/Lines = file2list("config/emojis.txt")
	for(var/line in Lines)
		if(findtext(line, "#"))
			continue

		var/list/splitline = splittext(line, " = ")
		if(length(splitline) != 2)
			continue

		var/emojiName = ":[lowertext(splitline[1])]:"
		var/emojiImage = lowertext(splitline[2])

		if (!emojiName || !emojiImage)
			continue

		if (discordEmojis.Find(emojiName))
			continue

		discordEmojis[emojiName] = emojiImage

/proc/handleDiscordEmojis(msg)
	var/list/newMsg = list()
	var/list/listmsg = splittext_char(msg, " ")
	for (var/i = 1, i <= length(listmsg), i++)
		var/word = listmsg[i]
		// Весь этот костыль с length и copytext_char нужен только потому что
		// lowertext(word) == lowertext(emojiName) не работает вообще по какой-то причине
		for (var/emojiName in discordEmojis)
			if (length(emojiName) != length(word))
				continue
			var/emojiId = discordEmojis[emojiName]
			word = replacetext_char(word, emojiName, DISCORD_EMOJI_IMAGE(emojiId, 32, 32))
			if (copytext_char(word, 1, 2) == "<")
				word = lowertext(word)
		newMsg += word
	return jointext(newMsg, " ")

/proc/generateDiscordEmojiTable()
	var/const/itemsInRow = 7
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

	if (isnull(emojiTableShownToUsers))
		emojiTableShownToUsers = generateDiscordEmojiTable()

	var/datum/browser/popup = new(usr, "discord_emoji", "Discord emojis", 800, 460)
	popup.set_content(emojiTableShownToUsers)
	popup.open()

#undef DISCORD_EMOJI_IMAGE
#undef DISCORD_EMOJI_URL
