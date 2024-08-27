#define DEFAULT_TITLE_SCREEN_HTML_PATH 'html/title_screen.html'
#define TITLE_SCREENS_LOCATION "config/title_screens/images/"

SUBSYSTEM_DEF(title)
	name = "Title Screen"
	flags = SS_NO_FIRE
	init_order = INIT_ORDER_TITLE
	init_stage = INITSTAGE_EARLY
	ss_id = "title_screen"
	/// Basic html that includes styles. Can be customised by host
	var/base_html
	/// Currently set title screen
	var/datum/title_screen/current_title_screen
	/// The list of image files available to be picked for title screen
	var/list/title_images_pool = list()

/datum/controller/subsystem/title/Initialize()
	import_html()
	fill_title_images_pool()
	current_title_screen = new(title_html = base_html, screen_image_file = pick_title_image())
	show_title_screen_to_all_new_players(TRUE)
	return SS_INIT_SUCCESS

/datum/controller/subsystem/title/Recover()
	current_title_screen = SStitle.current_title_screen
	title_images_pool = SStitle.title_images_pool

/datum/controller/subsystem/title/proc/import_html()
	base_html = file2text(DEFAULT_TITLE_SCREEN_HTML_PATH)

/**
 * Iterates over all files in `TITLE_SCREENS_LOCATION` and loads all valid title screens to `title_screens` var.
 */
/datum/controller/subsystem/title/proc/fill_title_images_pool()
	for(var/file_name in flist(TITLE_SCREENS_LOCATION))
		if(validate_filename(file_name))
			var/file_path = "[TITLE_SCREENS_LOCATION][file_name]"
			title_images_pool += fcopy_rsc(file_path)

/**
 * Checks wheter passed title is valid
 * Currently validates extension and checks whether it's special image like default title screen etc.
 */
/datum/controller/subsystem/title/proc/validate_filename(filename)
	var/static/list/title_screens_to_ignore = list("blank.png")
	if(filename in title_screens_to_ignore)
		return FALSE

	var/static/list/supported_extensions = list("gif", "jpg", "jpeg", "png", "svg")
	var/extstart = findlasttext(filename, ".")
	if(!extstart)
		return FALSE

	var/extension = copytext(filename, extstart + 1)
	return (extension in supported_extensions)

/**
 * Show the title screen to all new players.
 */
/datum/controller/subsystem/title/proc/show_title_screen_to_all_new_players(update_character = FALSE)
	if(!current_title_screen)
		return

	for(var/mob/new_player/viewer in GLOB.player_list)
		show_title_screen_to(viewer.client, update_character)

/**
 * Show the title screen to specific client.
 */
/datum/controller/subsystem/title/proc/show_title_screen_to(client/viewer, update_character = FALSE)
	if(!viewer || !current_title_screen)
		return

	INVOKE_ASYNC(current_title_screen, TYPE_PROC_REF(/datum/title_screen, show_to), viewer, update_character)

/**
 * Hide the title screen from specific client.
 */
/datum/controller/subsystem/title/proc/hide_title_screen_from(client/viewer)
	if(!viewer || !current_title_screen)
		return

	INVOKE_ASYNC(current_title_screen, TYPE_PROC_REF(/datum/title_screen, hide_from), viewer)

/**
 * Adds a notice to the main title screen in the form of big red text!
 */
/datum/controller/subsystem/title/proc/set_notice(new_notice)
	new_notice = new_notice ? sanitize_text(new_notice) : null

	if(!current_title_screen)
		if(!new_notice)
			return

		current_title_screen = new(notice = new_notice)
	else
		current_title_screen.notice = new_notice

	show_title_screen_to_all_new_players()

/**
 * Replaces html of title screen
 */
/datum/controller/subsystem/title/proc/set_title_html(new_html)
	if(!new_html)
		return

	if(!current_title_screen)
		current_title_screen = new(title_html = new_html)
	else
		current_title_screen.title_html = new_html

	show_title_screen_to_all_new_players()

/**
 * Changes title image to desired
 */
/datum/controller/subsystem/title/proc/set_title_image(desired_image_file)
	if(desired_image_file)
		if(!isfile(desired_image_file))
			CRASH("Not a file passed to `/datum/controller/subsystem/title/proc/set_title_image`")
	else
		desired_image_file = pick_title_image()

	if(!current_title_screen)
		current_title_screen = new(screen_image_file = desired_image_file)
	else
		current_title_screen.set_screen_image(desired_image_file)

	show_title_screen_to_all_new_players()

/**
 * Picks title image from `title_images_pool` list. If the list is empty, `DEFAULT_TITLE_HTML` is returned
 */
/datum/controller/subsystem/title/proc/pick_title_image()
	return pick(title_images_pool)


/datum/title_screen
	/// The preamble html that includes all styling and layout.
	var/title_html
	/// The current notice text, or null.
	var/notice
	/// The current title screen being displayed, as `/datum/asset_cache_item`
	var/datum/asset_cache_item/screen_image

/datum/title_screen/New(title_html, notice, screen_image_file)
	src.title_html = title_html
	src.notice = notice
	set_screen_image(screen_image_file)

/datum/title_screen/proc/set_screen_image(screen_image_file)
	if(!screen_image_file)
		return

	if(!isfile(screen_image_file))
		screen_image_file = fcopy_rsc(screen_image_file)

	screen_image = SSassets.transport.register_asset("[screen_image_file]", screen_image_file)

/datum/title_screen/proc/update_character(client/viewer)
	set waitfor = FALSE
	UNTIL(viewer.prefs)

	viewer.prefs.update_preview_icon()
	viewer << browse_rsc(viewer.prefs.preview_icon_front, "previewicon.png")

	send_byjax(viewer, "title_browser.browser", "charPreview", "previewicon.png", update_type="src")

/datum/title_screen/proc/show_to(client/viewer, update_character = FALSE)
	if(!viewer)
		return

	winset(viewer, "title_browser", "is-disabled=false;is-visible=true")
	winset(viewer, "paramapwindow.status_bar", "is-visible=false")

	var/datum/asset/lobby_asset = get_asset_datum(/datum/asset/simple/lobby)
	var/datum/asset/fontawesome = get_asset_datum(/datum/asset/simple/namespaced/fontawesome)
	lobby_asset.send(viewer)
	fontawesome.send(viewer)

	SSassets.transport.send_assets(viewer, screen_image.name)

	if(update_character)
		update_character(viewer)

	viewer << browse(get_title_html(viewer, viewer.mob), "window=title_browser")

/datum/title_screen/proc/hide_from(client/viewer)
	if(viewer?.mob)
		winset(viewer, "title_browser", "is-disabled=true;is-visible=false")
		winset(viewer, "paramapwindow.status_bar", "is-visible=true;focus=true")

/**
 * Get the HTML of title screen.
 */
/datum/title_screen/proc/get_title_html(client/viewer, mob/user)
	var/list/html = list(title_html)
	var/mob/new_player/player = user

	html +={"<script language='javascript' type='text/javascript'>
				[JS_BYJAX]
			</script>"}

	html += {"<input type="checkbox" id="hide_menu">"}

	var/screen_image_url = SSassets.transport.get_asset_url(asset_cache_item = screen_image)
	if(screen_image_url)
		html += {"<img src="[screen_image_url]" class="bg" alt="">"}

	if(notice)
		html += {"
		<div class="container_notice">
			<p class="menu_notice">[notice]</p>
		</div>
	"}

	html += {"<div class="container_menu">"}
	html += {"
		<div class="container_logo">
		<img class="logo" src="[SSassets.transport.get_asset_url(asset_name = "logo.png")]">
			<div class="character_info">
			<span class="character">На смену прибывает...</span>
			<span class="character" id="character_slot">[viewer.prefs.real_name]</span>
			</div>
		</div>

	"}

	html += {"<div class="container_buttons">"}

	html += "<img src='' alt='Загрузка...' id='charPreview' class='charPreview'>"

	if(!SSticker || SSticker.current_state <= GAME_STATE_PREGAME)
		html += {"<a class="menu_button bad" id="ready" href='byond://?src=[player.UID()];ready=1'>[player.ready ? "Готов" : "Не готов"]</a>"}
	else
		html += {"
			<a class="menu_button" href='byond://?src=[player.UID()];late_join=1'>Присоединиться</a>
			<a class="menu_button" href='byond://?src=[player.UID()];manifest=1'>Список экипажа</a>
		"}

	html += {"<a class="menu_button" href='byond://?src=[player.UID()];observe=1'>Наблюдать</a>"}
	html += {"
		<hr>
		<a class="menu_button good" id="be_antag" href='byond://?src=[player.UID()];skip_antag=1'>[viewer.prefs.skip_antag ? "Антагонисты: Выкл." : "Антагонисты: Вкл."]</a>
		<a class="menu_button" href='byond://?src=[player.UID()];show_preferences=1'>Настройка персонажа</a>
		<a class="menu_button" href='byond://?src=[player.UID()];game_preferences=1'>Настройки игры</a>
		<hr>
		<a class="menu_button" href='byond://?src=[player.UID()];swap_server=1'>Сменить сервер</a>
	"}
	html += {"</div>"}
	html += {"
		<div class="container_links">
			<a class="link_button" href='byond://?src=[player.UID()];wiki=1'><i class="fab fa-wikipedia-w"></i></a>
			<a class="link_button" href='byond://?src=[player.UID()];discord=1'><i class="fab fa-discord"></i></a>
			<a class="link_button" title="Чейнджлог" href='byond://?src=[player.UID()];changelog=1'><i class="fas fa-newspaper"></i></a>
		</div>
	"}
	html += {"</div>"}
	html += {"<label class="hide_button" for="hide_menu"><i class="fas fa-angles-left"></i></label>"}
	html += {"
		<script language="JavaScript">
			let ready_int = 0;
			const readyID = document.getElementById("ready");
			const ready_marks = \[ "Не готов", "Готов" \];
			const ready_class = \[ "bad", "good" \];
			function ready(setReady) {
				if(setReady) {
					ready_int = setReady;
					readyID.innerHTML = ready_marks\[ready_int\];
					readyID.classList.add(ready_class\[ready_int\]);
					readyID.classList.remove(ready_class\[1 - ready_int\]);
				} else {
					ready_int++;
					if(ready_int === ready_marks.length)
						ready_int = 0;
					readyID.innerHTML = ready_marks\[ready_int\];
					readyID.classList.add("good");
					readyID.classList.remove("bad");
				}
			}
			let antag_int = 0;
			const antagID = document.getElementById("be_antag");
			const antag_marks = \[ "Антагонисты: Вкл.", "Антагонисты: Выкл."\];
			const antag_class = \[ "good", "bad" \];
			function skip_antag(setAntag) {
				if(setAntag) {
					antag_int = setAntag;
					antagID.innerHTML = antag_marks\[antag_int\];
					antagID.classList.add(antag_class\[antag_int\]);
					antagID.classList.remove(antag_class\[1 - antag_int\]);
				} else {
					antag_int++;
					if(antag_int === antag_marks.length)
						antag_int = 0;
					antagID.innerHTML = antag_marks\[antag_int\];
					antagID.classList.add("good");
					antagID.classList.remove("bad");
				}
			}

			const character_name_slot = document.getElementById("character_slot");
			function update_current_character(name) {
				character_name_slot.textContent = name;
			}
		</script>
		"}

	html += "</body></html>"

	return html.Join()
