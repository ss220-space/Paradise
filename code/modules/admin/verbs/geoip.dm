/**
 * # GeoIP Admin Panel
 *
 * TGUI report of every connected client's ping and GeoIP data.
 * Read-only; lazily triggers a GeoIP refresh on any row whose status is not `"updated"`.
 *
 * Two independent ui_modules so the views never share window or state:
 * * `/datum/ui_module/admin/geoip` — full list of every connected client. Used by the `View GeoIP` admin verb.
 * * `/datum/ui_module/admin/geoip/focused` — one ckey only. Used by the `GeoIP` link on the player panel.
 */

// MARK: full list view
/datum/ui_module/admin/geoip
	name = "GeoIP Report"

/datum/ui_module/admin/geoip/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(ui)
		return
	ui = new(user, src, "AdminGeoIP", name)
	ui.open()

/datum/ui_module/admin/geoip/ui_data(mob/user)
	var/list/rows = list()
	for(var/client/player as anything in GLOB.clients)
		if(!player?.geoip)
			continue
		rows += list(geoip_build_row(player))
	return list(
		"clients" = rows,
		"target_ckey" = null,
	)

// MARK: focused client view
/// Per-viewer ckey filter. Keyed by viewer ckey, value is the target ckey to display.
/// One singleton instance is shared between admins; each admin's window reads its own slot.
/datum/ui_module/admin/geoip/focused
	name = "GeoIP Focused Report"
	var/list/target_filters

/datum/ui_module/admin/geoip/focused/ui_interact(mob/user, datum/tgui/ui, target_ckey)
	if(target_ckey)
		LAZYSET(target_filters, user.ckey, target_ckey)

	ui = SStgui.try_update_ui(user, src, ui)
	if(ui)
		return
	ui = new(user, src, "AdminGeoIP", name)
	ui.open()

/datum/ui_module/admin/geoip/focused/ui_close(mob/user)
	LAZYREMOVE(target_filters, user.ckey)
	return ..()

/datum/ui_module/admin/geoip/focused/ui_data(mob/user)
	var/target_ckey = LAZYACCESS(target_filters, user.ckey)
	var/list/rows = list()
	for(var/client/player as anything in GLOB.clients)
		if(!player?.geoip || player.ckey != target_ckey)
			continue
		rows += list(geoip_build_row(player))
	return list(
		"clients" = rows,
		"target_ckey" = target_ckey,
	)

/// Build a single row of GeoIP data for `player`. Triggers a lazy refresh if the cached lookup hasn't completed.
/proc/geoip_build_row(client/player)
	var/datum/geoip_data/geo = player.geoip
	if(geo.status != "updated")
		geo.try_update_geoip(player, player.address)

	return list(
		"ckey" = player.ckey,
		"name" = player.mob?.real_name || "[player.mob]",
		"ping" = player.lastping,
		"avg_ping" = round(player.avgping, 1),
		"url" = player.url,
		"ip" = geo.ip,
		"country" = geo.country,
		"countryCode" = geo.countryCode,
		"region" = geo.region,
		"regionName" = geo.regionName,
		"city" = geo.city,
		"timezone" = geo.timezone,
		"isp" = geo.isp,
		"mobile" = geo.mobile,
		"proxy" = geo.proxy,
		"status" = geo.status,
		"player_html" = player.mob ? key_name_admin(player.mob) : player.ckey,
	)

// MARK: verb
ADMIN_VERB(geoip, R_ADMIN, "View GeoIP", "Open the GeoIP Report.", ADMIN_CATEGORY_BAN, target_ckey as null|text)
	if(target_ckey)
		var/datum/ui_module/admin/geoip/focused/panel = get_admin_ui_module(/datum/ui_module/admin/geoip/focused)
		panel.ui_interact(user.mob, target_ckey = target_ckey)
	else
		var/datum/ui_module/admin/geoip/panel = get_admin_ui_module(/datum/ui_module/admin/geoip)
		panel.ui_interact(user.mob)
	log_admin("[key_name(user)] used GeoIP[target_ckey ? " for [target_ckey]" : ""].")
	message_admins(span_adminnotice("[key_name_admin(user)] uses GeoIP[target_ckey ? " for [target_ckey]" : ""]."))
	BLACKBOX_LOG_ADMIN_VERB("View GeoIP")
