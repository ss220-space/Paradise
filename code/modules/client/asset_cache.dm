/*
Asset cache quick users guide:

Make a datum at the bottom of this file with your assets for your thing.
The simple subsystem will most like be of use for most cases.
Then call get_asset_datum() with the type of the datum you created and store the return
Then call .send(client) on that stored return value.

You can set verify to TRUE if you want send() to sleep until the client has the assets.
*/


// Amount of time(ds) MAX to send per asset, if this get exceeded we cancel the sleeping.
// This is doubled for the first asset, then added per asset after
#define ASSET_CACHE_SEND_TIMEOUT 7

//When sending mutiple assets, how many before we give the client a quaint little sending resources message
#define ASSET_CACHE_TELL_CLIENT_AMOUNT 8

//When passively preloading assets, how many to send at once? Too high creates noticable lag where as too low can flood the client's cache with "verify" files
#define ASSET_CACHE_PRELOAD_CONCURRENT 3

/client
	var/list/cache = list() // List of all assets sent to this client by the asset cache.
	var/list/completed_asset_jobs = list() // List of all completed jobs, awaiting acknowledgement.
	var/list/sending = list()
	var/last_asset_job = 0 // Last job done.

//This proc sends the asset to the client, but only if it needs it.
//This proc blocks(sleeps) unless verify is set to false
/proc/send_asset(var/client/client, var/asset_name, var/verify = TRUE)
	if(!istype(client))
		if(ismob(client))
			var/mob/M = client
			if(M.client)
				client = M.client

			else
				return 0

		else
			return 0

	if(client.cache.Find(asset_name) || client.sending.Find(asset_name))
		return 0

	log_asset("Sending asset [asset_name] to client [client]")
	client << browse_rsc(SSassets.cache[asset_name], asset_name)
	if(!verify) // Can't access the asset cache browser, rip.
		client.cache += asset_name
		return 1

	client.sending |= asset_name
	var/job = ++client.last_asset_job

	client << browse({"
	<script>
		window.location.href="?asset_cache_confirm_arrival=[job]"
	</script>
	"}, "window=asset_cache_browser")

	var/t = 0
	var/timeout_time = (ASSET_CACHE_SEND_TIMEOUT * client.sending.len) + ASSET_CACHE_SEND_TIMEOUT
	while(client && !client.completed_asset_jobs.Find(job) && t < timeout_time) // Reception is handled in Topic()
		sleep(1) // Lock up the caller until this is received.
		t++

	if(client)
		client.sending -= asset_name
		client.cache |= asset_name
		client.completed_asset_jobs -= job

	return 1

//This proc blocks(sleeps) unless verify is set to false
/proc/send_asset_list(var/client/client, var/list/asset_list, var/verify = TRUE)
	if(!istype(client))
		if(ismob(client))
			var/mob/M = client
			if(M.client)
				client = M.client

			else
				return 0

		else
			return 0

	var/list/unreceived = asset_list - (client.cache + client.sending)
	if(!unreceived || !unreceived.len)
		return 0
	if(unreceived.len >= ASSET_CACHE_TELL_CLIENT_AMOUNT)
		to_chat(client, "Sending Resources...")
	for(var/asset in unreceived)
		if(asset in SSassets.cache)
			log_asset("Sending asset [asset] to client [client]")
			client << browse_rsc(SSassets.cache[asset], asset)

	if(!verify) // Can't access the asset cache browser, rip.
		client.cache += unreceived
		return 1

	client.sending |= unreceived
	var/job = ++client.last_asset_job

	client << browse({"
	<script>
		window.location.href="?asset_cache_confirm_arrival=[job]"
	</script>
	"}, "window=asset_cache_browser")

	var/t = 0
	var/timeout_time = ASSET_CACHE_SEND_TIMEOUT * client.sending.len
	while(client && !client.completed_asset_jobs.Find(job) && t < timeout_time) // Reception is handled in Topic()
		sleep(1) // Lock up the caller until this is received.
		t++

	if(client)
		client.sending -= unreceived
		client.cache |= unreceived
		client.completed_asset_jobs -= job

	return 1

//This proc will download the files without clogging up the browse() queue, used for passively sending files on connection start.
//The proc calls procs that sleep for long times.
/proc/getFilesSlow(var/client/client, var/list/files, var/register_asset = TRUE)
	var/concurrent_tracker = 1
	for(var/file in files)
		if(!client)
			break
		if(register_asset)
			register_asset(file, files[file])
		if(concurrent_tracker >= ASSET_CACHE_PRELOAD_CONCURRENT)
			concurrent_tracker = 1
			send_asset(client, file)
		else
			concurrent_tracker++
			send_asset(client, file, verify = FALSE)
		sleep(0) //queuing calls like this too quickly can cause issues in some client versions

//This proc "registers" an asset, it adds it to the cache for further use, you cannot touch it from this point on or you'll fuck things up.
//if it's an icon or something be careful, you'll have to copy it before further use.
/proc/register_asset(var/asset_name, var/asset)
	SSassets.cache[asset_name] = asset

//These datums are used to populate the asset cache, the proc "register()" does this.

//all of our asset datums, used for referring to these later
GLOBAL_LIST_EMPTY(asset_datums)

//get a assetdatum or make a new one
/proc/get_asset_datum(var/type)
	if(!(type in GLOB.asset_datums))
		return new type()
	return GLOB.asset_datums[type]

/datum/asset/New()
	GLOB.asset_datums[type] = src

/datum/asset/proc/register()
	return

/datum/asset/proc/send(client)
	return

//If you don't need anything complicated.
/datum/asset/simple
	var/assets = list()
	var/verify = FALSE

/datum/asset/simple/register()
	for(var/asset_name in assets)
		register_asset(asset_name, assets[asset_name])
/datum/asset/simple/send(client)
	send_asset_list(client,assets,verify)


//DEFINITIONS FOR ASSET DATUMS START HERE.
/datum/asset/simple/tgui
	assets = list(
		"tgui.bundle.js" = 'tgui/packages/tgui/public/tgui.bundle.js',
		"tgui.bundle.css" = 'tgui/packages/tgui/public/tgui.bundle.css'
)

/datum/asset/simple/paper
	assets = list(
		"large_stamp-clown.png"     = 'icons/misc/paper_icons/large_stamp-clown.png',
		"large_stamp-deny.png"      = 'icons/misc/paper_icons/large_stamp-deny.png',
		"large_stamp-ok.png"        = 'icons/misc/paper_icons/large_stamp-ok.png',
		"large_stamp-hop.png"       = 'icons/misc/paper_icons/large_stamp-hop.png',
		"large_stamp-cmo.png"       = 'icons/misc/paper_icons/large_stamp-cmo.png',
		"large_stamp-ce.png"        = 'icons/misc/paper_icons/large_stamp-ce.png',
		"large_stamp-hos.png"       = 'icons/misc/paper_icons/large_stamp-hos.png',
		"large_stamp-rd.png"        = 'icons/misc/paper_icons/large_stamp-rd.png',
		"large_stamp-cap.png"       = 'icons/misc/paper_icons/large_stamp-cap.png',
		"large_stamp-qm.png"        = 'icons/misc/paper_icons/large_stamp-qm.png',
		"large_stamp-law.png"       = 'icons/misc/paper_icons/large_stamp-law.png',
		"large_stamp-cent.png"      = 'icons/misc/paper_icons/large_stamp-cent.png',
		"large_stamp-syndicate.png" = 'icons/misc/paper_icons/large_stamp-syndicate.png',
		"large_stamp-taipan.png" 	= 'icons/misc/paper_icons/large_stamp-taipan.png',
		"large_stamp-rep.png"	    = 'icons/misc/paper_icons/large_stamp-rep.png',
		"large_stamp-magistrate.png"= 'icons/misc/paper_icons/large_stamp-magistrate.png',
		"large_stamp-ward.png"      = 'icons/misc/paper_icons/large_stamp-ward.png',
		"talisman.png"              = 'icons/misc/paper_icons/talisman.png',
		"ntlogo.png"                = 'icons/misc/paper_icons/ntlogo.png',
		"syndielogo.png"		    = 'icons/misc/paper_icons/syndielogo.png',
		"large_stamp-mime.png"      = 'icons/misc/paper_icons/large_stamp-mime.png',
		"thieflogo.png"		    	= 'icons/misc/paper_icons/thieflogo.png',
		"large_stamp-ploho.png"		= 'icons/misc/paper_icons/large_stamp-ploho.png',
		"large_stamp-BIGdeny.png"	= 'icons/misc/paper_icons/large_stamp-BIGdeny.png',
		"large_stamp-navcom.png"	= 'icons/misc/paper_icons/large_stamp-navcom.png',
		"large_stamp-ussp.png"		= 'icons/misc/paper_icons/large_stamp-ussp.png',
		"ussplogo.png"			= 'icons/misc/paper_icons/ussplogo.png'
	)

/datum/asset/simple/chess
	assets = list(
		"bishop_black.png"			= 'icons/misc/chess_pieces/bishop_black.png',
		"bishop_white.png"			= 'icons/misc/chess_pieces/bishop_white.png',
		"king_black.png"			= 'icons/misc/chess_pieces/king_black.png',
		"king_white.png"			= 'icons/misc/chess_pieces/king_white.png',
		"knight_black.png"			= 'icons/misc/chess_pieces/knight_black.png',
		"knight_white.png"			= 'icons/misc/chess_pieces/knight_white.png',
		"pawn_black.png"			= 'icons/misc/chess_pieces/pawn_black.png',
		"pawn_white.png"			= 'icons/misc/chess_pieces/pawn_white.png',
		"queen_black.png"			= 'icons/misc/chess_pieces/queen_black.png',
		"queen_white.png"			= 'icons/misc/chess_pieces/queen_white.png',
		"rook_black.png"			= 'icons/misc/chess_pieces/rook_black.png',
		"rook_white.png"			= 'icons/misc/chess_pieces/rook_white.png',
		"sprites.png"			    = 'icons/misc/chess_pieces/sprites.png',
		"blank.gif"                 = 'icons/misc/chess_pieces/blank.gif',
		"garbochess.js"             = 'html/browser/garbochess.js',
		"boardui.js"                = 'html/browser/boardui.js'
	)

//Pill sprites for UIs
/datum/asset/chem_master
	var/assets = list()
	var/verify = FALSE

/datum/asset/chem_master/register()
	for(var/i = 1 to 20)
		assets["pill[i].png"] = icon('icons/obj/chemical.dmi', "pill[i]")
	for(var/i in list("bottle", "small_bottle", "wide_bottle", "round_bottle", "reagent_bottle"))
		assets["[i].png"] = icon('icons/obj/chemical.dmi', "[i]")
	for(var/i in list("bandaid_med", "bandaid_brute", "bandaid_burn", "bandaid", "bandaid_clown", "bandaid_custom1", "bandaid_custom2", "bandaid_custom3",
						"bandaid_custom4", "bandaid_custom5", "bandaid_custom6", "bandaid_custom7", "bandaid_custom8", "bandaid_big_brute", "bandaid_big_burn",
						"bandaid_oxygen", "bandaid_toxin", "bandaid_emergency", "bandaid_acid", "bandaid_heart"))
		assets["[i].png"] = icon('icons/obj/chemical.dmi', "[i]")
	for(var/asset_name in assets)
		register_asset(asset_name, assets[asset_name])

/datum/asset/chem_master/send(client)
	send_asset_list(client, assets, verify)

//Cloning pod sprites for UIs
/datum/asset/cloning
	var/assets = list()
	var/verify = FALSE

/datum/asset/cloning/register()
	assets["pod_idle.gif"] = icon('icons/obj/machines/cloning.dmi', "pod_idle")
	assets["pod_cloning.gif"] = icon('icons/obj/machines/cloning.dmi', "pod_cloning")
	assets["pod_mess.gif"] = icon('icons/obj/machines/cloning.dmi', "pod_mess")
	for(var/asset_name in assets)
		register_asset(asset_name, assets[asset_name])

/datum/asset/cloning/send(client)
	send_asset_list(client, assets, verify)

//Pipe sprites for UIs
/datum/asset/rpd
	var/assets = list()
	var/verify = FALSE

/datum/asset/rpd/register()
	for(var/state in icon_states('icons/obj/pipes_and_stuff/atmospherics/pipe-item.dmi'))
		if(!(state in list("cap", "connector", "dtvalve", "dual-port vent", "dvalve", "filter", "he", "heunary", "injector", "junction", "manifold", "mixer", "tvalve", "mvalve", "passive vent", "passivegate", "pump", "scrubber", "simple", "universal", "uvent", "volumepump"))) //Basically all the pipes we want sprites for
			continue
		if(state in list("he", "simple"))
			for(var/D in GLOB.alldirs)
				assets["[state]-[dir2text(D)].png"] = icon('icons/obj/pipes_and_stuff/atmospherics/pipe-item.dmi', state, D)
		for(var/D in GLOB.cardinal)
			assets["[state]-[dir2text(D)].png"] = icon('icons/obj/pipes_and_stuff/atmospherics/pipe-item.dmi', state, D)
	for(var/state in icon_states('icons/obj/pipes_and_stuff/not_atmos/disposal.dmi'))
		if(!(state in list("pipe-c", "pipe-j1", "pipe-s", "pipe-t", "pipe-y", "intake", "outlet", "pipe-j1s"))) //Pipes we want sprites for
			continue
		for(var/D in GLOB.cardinal)
			assets["[state]-[dir2text(D)].png"] = icon('icons/obj/pipes_and_stuff/not_atmos/disposal.dmi', state, D)
	for(var/asset_name in assets)
		register_asset(asset_name, assets[asset_name])

/datum/asset/rpd/send(client)
	send_asset_list(client, assets, verify)

//Mob Hunt sprites for UIs
/datum/asset/mob_hunt
	var/assets = list()
	var/verify = FALSE

/datum/asset/mob_hunt/register()
	for(var/state in icon_states('icons/effects/mob_hunt.dmi'))
		if(state == "Placeholder")
			continue
		assets["[state].png"] = icon('icons/effects/mob_hunt.dmi', state)
	for(var/asset_name in assets)
		register_asset(asset_name, assets[asset_name])

/datum/asset/mob_hunt/send(client)
	send_asset_list(client, assets, verify)

// Fontawesome
/datum/asset/simple/fontawesome
	verify = FALSE
	assets = list(
		"fa-regular-400.eot"  = 'html/font-awesome/webfonts/fa-regular-400.eot',
		"fa-regular-400.woff" = 'html/font-awesome/webfonts/fa-regular-400.woff',
		"fa-solid-900.eot"    = 'html/font-awesome/webfonts/fa-solid-900.eot',
		"fa-solid-900.woff"   = 'html/font-awesome/webfonts/fa-solid-900.woff',
		"font-awesome.css"    = 'html/font-awesome/css/all.min.css',
		"v4shim.css"          = 'html/font-awesome/css/v4-shims.min.css'
	)

// Nanomaps
/datum/asset/simple/nanomaps
	// It REALLY doesnt matter too much if these arent up to date
	// They are relatively big
	verify = FALSE
	assets = list(
		"Cyberiad_nanomap_z1.png"		= 'icons/_nanomaps/Cyberiad_nanomap_z1.png',
		"Delta_nanomap_z1.png"			= 'icons/_nanomaps/Delta_nanomap_z1.png',
		"MetaStation_nanomap_z1.png"	= 'icons/_nanomaps/MetaStation_nanomap_z1.png',
		"Cerestation_nanomap_z1.png"		= 'icons/_nanomaps/Cerestation_nanomap_z1.png',
	)

/datum/asset/simple/safe
	verify = FALSE
	assets = list(
		"safe_dial.png" = 'icons/obj/safe_dial.png'
	)

// Materials (metal, glass...)
/datum/asset/simple/materials
	verify = FALSE

/datum/asset/simple/materials/register()
	for(var/n in list("metal", "glass", "silver", "gold", "diamond", "uranium", "plasma", "clown", "mime", "titanium", "plastic"))
		assets["sheet-[n].png"] = icon('icons/obj/items.dmi', "sheet-[n]")
	assets["sheet-bluespace.png"] = icon('icons/obj/telescience.dmi', "polycrystal")
	..()

/datum/asset/changelog_item
	var/item_filename

/datum/asset/changelog_item/New(date)
	item_filename = sanitize_filename("[date].yml")
	register_asset(item_filename, file("html/changelogs/archive/" + item_filename))

/datum/asset/changelog_item/send(client)
	if (!item_filename)
		return
	. = send_asset(client, item_filename)
