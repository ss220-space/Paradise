GLOBAL_LIST_EMPTY(asays)
GLOBAL_LIST_EMPTY(msays)
GLOBAL_LIST_EMPTY(devsays)

/**
 * # Special says datum
 * Used to store the history of special chat messages (achat, mchat, devchat) within a round
 */
/datum/say
	var/ckey
	var/rank
	var/message
	var/time

/datum/say/New(ckey = "", rank = "", message = "", time = 0)
	src.ckey = ckey
	src.rank = rank
	src.message = message
	src.time = time

ADMIN_VERB(view_msays, R_ADMIN|R_MENTOR, "Msays", "View current round Msays.", ADMIN_CATEGORY_MAIN)
	user.display_says(GLOB.msays, "msay")

ADMIN_VERB(view_devsays, R_ADMIN|R_VIEWRUNTIMES, "Devsays", "View current round Devsays.", ADMIN_CATEGORY_MAIN)
	user.display_says(GLOB.devsays, "devsay")

ADMIN_VERB(view_asays, R_ADMIN|R_MOD, "Asays", "View current round Asays.", ADMIN_CATEGORY_MAIN)
	user.display_says(GLOB.asays, "asay")

/client/proc/display_says(list/say_list, title)
	var/list/output = list({"
	<style>
		td, th
		{
			border: 1px solid #425c6e;
			padding: 3px;
		}

		thead
		{
			color: #517087;
			font-weight: bold;
			table-layout: fixed;
		}
	</style>
	<a href='byond://?src=[holder.UID()];[title]s=1'>Refresh</a>
	<table style='width: 100%; border-collapse: collapse; table-layout: auto; margin-top: 3px;'>
	"})

	// Header & body start
	output += {"
		<thead>
			<tr>
				<th width="5%">Time</th>
				<th width="10%">Ckey</th>
				<th width="85%">Message</th>
			</tr>
		</thead>
		<tbody>
	"}

	for(var/datum/say/say in say_list)
		var/timestr = time2text(say.time, "hh:mm:ss")
		output += {"
			<tr>
				<td width="5%">[timestr]</td>
				<td width="10%"><b>[say.ckey] ([say.rank])</b></td>
				<td width="85%">[say.message]</td>
			</tr>
		"}

	output += {"
		</tbody>
	</table>"}

	var/datum/browser/popup = new(usr, title, "<div align='center'>Current Round [capitalize(title)]s</div>", 1200, 825)
	popup.set_content(output.Join())
	popup.open(0)
