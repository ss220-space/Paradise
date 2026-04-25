/**
 * # Geoip admin panel
 *
 * TGUI report of every connected client's ping and GeoIP data.
 * Read-only; lazily triggers a GeoIP refresh on any row whose status is not `"updated"`.
 *
 * Can be opened in two modes:
 * * Full list — every connected client. Used by the `View Geoip` admin verb.
 * * Single-client — one ckey only. Used by the `GeoIP` link on the player panel.
 */
/datum/ui_module/admin/geoip
	name = "Pingstat Report"
	/// Per-viewer ckey filters. Keyed by viewer ckey, value is the target ckey to pin the view to.
	var/list/target_filters

/**
 * Opens (or re-focuses) the panel for `user`. Passing `target_ckey` restricts the view to that
 * single client and renames the window accordingly; passing `null` shows every connected client.
 */
/datum/ui_module/admin/geoip/ui_interact(mob/user, datum/tgui/ui, target_ckey = null)
	var/old_target = LAZYACCESS(target_filters, user.ckey)
	if(target_ckey)
		LAZYSET(target_filters, user.ckey, target_ckey)
	else
		LAZYREMOVE(target_filters, user.ckey)

	// Rebuild UI if view mode changed
	if(old_target != target_ckey)
		SStgui.close_user_uis(user, src)
		ui = null

	ui = SStgui.try_update_ui(user, src, ui)
	if(ui)
		return
	ui = new(user, src, "AdminGeoIP", name)
	ui.open()

/datum/ui_module/admin/geoip/ui_close(mob/user)
	LAZYREMOVE(target_filters, user.ckey)
	return ..()

/datum/ui_module/admin/geoip/ui_data(mob/user)
	var/target_ckey = LAZYACCESS(target_filters, user.ckey)

	var/list/rows = list()
	for(var/client/player as anything in GLOB.clients)
		if(target_ckey && player.ckey != target_ckey)
			continue

		var/datum/geoip_data/geo = player.geoip
		if(geo.status != "updated")
			geo.try_update_geoip(player, player.address)

		rows += list(list(
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
			"player_html" = player.mob ? key_name_admin(player.mob) : player.ckey
		))

	return list(
		"clients" = rows,
		"target_ckey" = target_ckey,
	)

ADMIN_VERB(geoip, R_ADMIN, "View GeoIP", "Open the GeoIP Report.", ADMIN_CATEGORY_BAN, target_ckey as null|text)
	var/datum/ui_module/admin/geoip/panel = get_admin_ui_module(/datum/ui_module/admin/geoip)
	panel.ui_interact(user.mob, target_ckey = target_ckey)
	log_admin("[key_name(user)] used GeoIP[target_ckey ? " for [target_ckey]" : ""].")
	message_admins(span_adminnotice("[key_name_admin(user)] uses GeoIP[target_ckey ? " for [target_ckey]" : ""]."))
	BLACKBOX_LOG_ADMIN_VERB("View GeoIP")
