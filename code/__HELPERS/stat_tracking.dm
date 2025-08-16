// For use with the stopwatch defines
/proc/render_stats(list/stats, user, sort = GLOBAL_PROC_REF(cmp_generic_stat_item_time))
	sortTim(stats, sort, TRUE)

	var/list/lines = list()

	for(var/entry in stats)
		var/list/data = stats[entry]
		lines += "[entry] => [num2text(data[STAT_ENTRY_TIME], 10)]ms ([data[STAT_ENTRY_COUNT]]) (avg:[num2text(data[STAT_ENTRY_TIME]/(data[STAT_ENTRY_COUNT] || 1), 99)])"

	if(user)
		var/datum/browser/popup = new(user, "[url_encode("stats:[ref(stats)]")]", "Stats")
		popup.set_content("<ol><li>[lines.Join("</li><li>")]</li></ol>")
		popup.open(FALSE)

	. = lines.Join("\n")

