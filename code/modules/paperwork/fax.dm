// Fax datum - holds all faxes sent during the round
GLOBAL_LIST_EMPTY(faxes)
GLOBAL_LIST_EMPTY(adminfaxes)

/datum/fax
	var/name = "fax"
	var/from_department = null
	var/to_department = null
	var/origin = null
	var/message = null
	var/sent_by = null
	var/sent_at = null

/datum/fax/New()
	GLOB.faxes += src

/datum/fax/admin
	var/reply_to = null

/datum/fax/admin/New()
	GLOB.adminfaxes += src

ADMIN_VERB(fax_panel, R_ADMIN, "Fax Panel", "View and respond to faxes sent to CC.", ADMIN_CATEGORY_EVENTS)
	if(!user.holder)
		return
	user.holder.fax_panel(user.mob)
	BLACKBOX_LOG_ADMIN_VERB("Fax Panel")

/datum/admins/proc/fax_panel(mob/living/user)
	var/html = "<a align='right' href='byond://?src=[UID()];refreshfaxpanel=1'>Refresh</a>"
	html += "<a align='right' href='byond://?src=[UID()];AdminFaxCreate=1;faxtype=Administrator'>Create Fax</a>"

	html += "<div class='block'>"
	html += "<h2>Admin Faxes</h2>"
	html += "<table>"
	html += "<tr style='font-weight:bold;'><td width='150px'>Name</td><td width='150px'>From Department</td><td width='150px'>To Department</td><td width='75px'>Sent At</td><td width='150px'>Sent By</td><td width='50px'>View</td><td width='50px'>Reply</td><td width='75px'>Replied To</td></td></tr>"
	for(var/datum/fax/admin/admin in GLOB.adminfaxes)
		html += "<tr>"
		html += "<td>[admin.name]</td>"
		html += "<td>[admin.from_department]</td>"
		html += "<td>[admin.to_department]</td>"
		html += "<td>[station_time_timestamp("hh:mm:ss", admin.sent_at)]</td>"
		if(admin.sent_by)
			var/mob/living/living = admin.sent_by
			html += "<td>[ADMIN_PP(living,"[living.name]")]</td>"
		else
			html += "<td>Unknown</td>"
		html += "<td><a align='right' href='byond://?src=[UID()];AdminFaxView=[UID_of(admin.message)]'>View</a></td>"
		if(!admin.reply_to)
			if(admin.from_department == "Administrator")
				html += "<td>N/admin</td>"
			else
				html += "<td><a align='right' href='byond://?src=[UID()];AdminFaxCreate=[UID_of(admin.sent_by)];originfax=[UID_of(admin.origin)];faxtype=[admin.to_department];replyto=[UID_of(admin.message)]'>Reply</a>"
				if(admin.sent_by)
					html += "<br><a align='right' href='byond://?src=[UID()];AdminFaxNotify=[UID_of(admin.sent_by)]'>Notify</a>"
				html += "</td>"
			html += "<td>N/admin</td>"
		else
			html += "<td>N/admin</td>"
			html += "<td><a align='right' href='byond://?src=[UID()];AdminFaxView=[UID_of(admin.reply_to)]'>Original</a></td>"
		html += "</tr>"
	html += "</table>"
	html += "</div>"

	html += "<div class='block'>"
	html += "<h2>Departmental Faxes</h2>"
	html += "<table>"
	html += "<tr style='font-weight:bold;'><td width='150px'>Name</td><td width='150px'>From Department</td><td width='150px'>To Department</td><td width='75px'>Sent At</td><td width='150px'>Sent By</td><td width='175px'>View</td></td></tr>"
	for(var/datum/fax/fax in GLOB.faxes)
		html += "<tr>"
		html += "<td>[fax.name]</td>"
		html += "<td>[fax.from_department]</td>"
		html += "<td>[fax.to_department]</td>"
		html += "<td>[station_time_timestamp("hh:mm:ss", fax.sent_at)]</td>"
		if(fax.sent_by)
			var/mob/living/living = fax.sent_by
			html += "<td>[ADMIN_PP(living,"[living.name]")]</td>"
		else
			html += "<td>Unknown</td>"
		html += "<td><a align='right' href='byond://?src=[UID()];AdminFaxView=[UID_of(fax.message)]'>View</a></td>"
		html += "</tr>"
	html += "</table>"
	html += "</div>"

	var/datum/browser/popup = new(user, "fax_panel", "Fax Panel", 950, 450)
	popup.set_content(html)
	popup.open()
