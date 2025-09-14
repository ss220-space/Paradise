#define DEFAULT_TITLE_SCREEN_HTML_PATH 'html/title_screen.html'
#define TITLE_SCREENS_LOCATION "config/title_screens/images/"

SUBSYSTEM_DEF(title)
	name = "Title Screen"
	wait = 300
	init_order = INIT_ORDER_TITLE
	init_stage = INITSTAGE_EARLY
	ss_id = "title_screen"
	/// Basic html that includes styles. Can be customised by host
	var/base_html
	/// Currently set title screen
	var/datum/title_screen/current_title_screen
	/// The list of image files available to be picked for title screen
	var/list/title_images_pool = list()
	// Servers` info for lobby switch
	var/list/formatted_servers = list()

/datum/controller/subsystem/title/Initialize()
	import_html()
	fill_title_images_pool()

	if(!CONFIG_GET(flag/enable_multi_instance))
		flags |= SS_NO_FIRE
	else
		update_servers_info()

	current_title_screen = new(title_html = base_html, screen_image_file = pick_title_image())
	if(!CONFIG_GET(flag/enable_titlescreen_lateload))
		show_title_screen_to_all_new_players()

	return SS_INIT_SUCCESS

/datum/controller/subsystem/title/fire(resumed = 0)
	update_servers_info()
	for(var/mob/new_player/viewer in GLOB.player_list)
		update_servers_list(viewer.client)

/datum/controller/subsystem/title/proc/update_servers_info()
	formatted_servers = list()
	// First get our peers
	var/datum/db_query/dbq1 = SSdbcore.NewQuery({"
		SELECT server_id, key_name, key_value FROM instance_data_cache WHERE server_id IN
		(SELECT server_id FROM instance_data_cache WHERE
		key_name='heartbeat' AND last_updated BETWEEN NOW() - INTERVAL 60 SECOND AND NOW())
		AND key_name IN ("playercount", "server_port", "server_name", "round_time")"})
	if(!dbq1.warn_execute())
		qdel(dbq1)
		return

	var/servers_outer = list()
	while(dbq1.NextRow())
		if(!servers_outer[dbq1.item[1]])
			servers_outer[dbq1.item[1]] = list()

		servers_outer[dbq1.item[1]][dbq1.item[2]] = dbq1.item[3] // This should assoc load our data

	qdel(dbq1) //clear our query
	// Format the server names into an assoc list of K: name V: port
	for(var/server in servers_outer)
		var/server_data = servers_outer[server]
		formatted_servers.Add(list2params(list("name" = server_data["server_name"], "players" = server_data["playercount"], \
		"port" = server_data["server_port"], "round_time" = server_data["round_time"])))

/datum/controller/subsystem/title/OnMasterLoad()
	if(CONFIG_GET(flag/enable_titlescreen_lateload))
		show_title_screen_to_all_new_players()

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
/datum/controller/subsystem/title/proc/show_title_screen_to_all_new_players()
	if(!current_title_screen)
		return

	for(var/mob/new_player/viewer in GLOB.player_list)
		show_title_screen_to(viewer.client)

/**
 * Show the title screen to specific client.
 */
/datum/controller/subsystem/title/proc/show_title_screen_to(client/viewer)
	if(!viewer || !current_title_screen)
		return

	INVOKE_ASYNC(current_title_screen, TYPE_PROC_REF(/datum/title_screen, show_to), viewer)

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

	if(!current_title_screen)
		return

	for(var/mob/new_player/viewer in GLOB.player_list)
		viewer << output("[new_notice]", "title_browser:update_notice")

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

/datum/controller/subsystem/title/proc/update_preview(client/viewer)
	if(!viewer)
		return
	if(viewer.byond_version < 516)
		viewer << output("", "title_browser:update_preview_515")
	else
		viewer << output("", "title_browser:update_preview")

/datum/controller/subsystem/title/proc/update_servers_list(client/viewer)
	if(!viewer)
		return

	viewer << output(list2params(formatted_servers), "title_browser:update_servers_list")

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


/************************
 *  Title screen datum  *
 ************************/
/datum/title_screen
	/// The preamble html that includes all styling and layout.
	var/title_html
	/// The current notice text, or null.
	var/notice = ""
	/// The current title screen being displayed, as `/datum/asset_cache_item`
	var/datum/asset_cache_item/screen_image
	/// Randow phrase for this round
	var/random_phrase = "О нет, моя фраза!"
	var/current_icon = "ss1984.gif"

	var/list/color2tguitheme = list("#202020" = "dark", "#EEEEEE" = "light", "#1b2633" = "ntos", "#4d0202" = "syndicate", "#800448" = "paradise")

/datum/title_screen/New(title_html, notice, screen_image_file)
	src.title_html = title_html
	src.notice = notice
	var/list/phrases = file2list("strings/lobby_phrases.txt")
	if(LAZYLEN(phrases))
		random_phrase = pick(phrases)
	set_screen_image(screen_image_file)

/datum/title_screen/proc/set_screen_image(screen_image_file)
	if(!screen_image_file)
		return

	if(!isfile(screen_image_file))
		screen_image_file = fcopy_rsc(screen_image_file)

	screen_image = SSassets.transport.register_asset("[screen_image_file]", screen_image_file)

/// this proc updates character icon and lobby list
/datum/title_screen/proc/update_lateinfo(client/viewer)
	if(!viewer)
		return

	UNTIL(viewer.prefs)

	if(viewer?.prefs?.toggles2 & PREFTOGGLE_2_PIXELATED_MENU)
		viewer << output("", "title_browser:set_pixelated")
	viewer.prefs.update_preview_icon()
	viewer << browse_rsc(viewer.prefs.preview_icon_front, "previewicon.png")

	sleep(1 SECONDS)

	// here we hope that our browser already updated. :pepepray:
	SStitle.update_preview(viewer)
	SStitle.update_servers_list(viewer)
	viewer << output((viewer?.tgui_panel_theme)? viewer.tgui_panel_theme : "dark", "title_browser:set_theme")

/datum/title_screen/proc/show_to(client/viewer)
	if(!viewer)
		return

	winset(viewer, "title_browser", "is-disabled=false;is-visible=true")

	var/datum/asset/lobby_asset = get_asset_datum(/datum/asset/simple/lobby)
	var/datum/asset/fontawesome = get_asset_datum(/datum/asset/simple/namespaced/fontawesome)
	lobby_asset.send(viewer)
	fontawesome.send(viewer)

	SSassets.transport.send_assets(viewer, screen_image.name)

	viewer << browse(get_title_html(viewer, viewer.mob), "window=title_browser")

	INVOKE_ASYNC(src, PROC_REF(update_lateinfo), viewer)

/datum/title_screen/proc/hide_from(client/viewer)
	if(!viewer)
		return

	if(viewer.mob)
		winset(viewer, "title_browser", "is-disabled=true;is-visible=false")

/**
 * Get the HTML of title screen.
 */
/datum/title_screen/proc/get_title_html(client/viewer, mob/user)
	if(!viewer)
		return

	var/current_theme = color2tguitheme[winget(viewer, "mainwindow", "background-color")]// we sleep here and can loose client
	if(!viewer)
		return

	var/list/html = list(title_html)
	var/mob/new_player/player = user
	var/screen_image_url = SSassets.transport.get_asset_url(asset_cache_item = screen_image)
	var/icon_url = SSassets.transport.get_asset_url(asset_name = current_icon)

	//hope that client won`t use custom theme
	html += {"<body class="[current_theme][viewer?.prefs?.toggles2 & PREFTOGGLE_2_PIXELATED_MENU ? " pixelated" : ""]" style="background-image: [screen_image_url ? "url([screen_image_url])" : "" ];">"}

	html += {"<input type="checkbox" id="hide_menu">"}
	html += {"<input type="checkbox" id="hide_lobby">"}

	if(notice)
		html += {"
		<div id="notice_place" class="container_notice">
			<p id="notice" class="menu_notice">[notice]</p>
		</div>
		"}
	else
		html += {"<div id="notice_place"></div>"}

	html += {"<div class="container_menu">"}
	html += {"
		<div class="container_logo">
			<div class="random_title_message">[random_phrase]</div>
			<div class="logo_and_preview">
				<img class="logo" src="[icon_url]">
				<div class="preview">
					<img src="" alt="" id="preview" onerror="this.src='data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAQAAAC1HAwCAAAAC0lEQVR42mP8/wcAAgAB/IsDkAAAAABJRU5ErkJggg=='">
				</div>
			</div>
			<div class="character_info">
				<span class="character" id="character_slot">[viewer.prefs.real_name]</span>
				<span class="character" id="arrival_message">[(player.ready || SSticker.current_state == GAME_STATE_PLAYING) ? "...отправляется на станцию" : "...остается дома"].</span>
			</div>
		</div>
	"}

	html += {"<div class="container_buttons">"}

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
		<a class="menu_button good" id="be_antag" href='byond://?src=[player.UID()];skip_antag=1'>[viewer?.prefs.skip_antag ? "Антагонисты: Выкл." : "Антагонисты: Вкл."]</a>
		<a class="menu_button" href='byond://?src=[player.UID()];show_preferences=1'>Настройка персонажа</a>
		<a class="menu_button" href='byond://?src=[player.UID()];job_preferences=1'>Выбор профессии</a>
		<a class="menu_button" href='byond://?src=[player.UID()];game_preferences=1'>Настройки игры</a>
		<hr>
		<a class="menu_button" href='byond://?src=[player.UID()];sound_options=1'>Настройки громкости</a>
		<a class="menu_button" href='byond://?src=[player.UID()];poll_panel=1'>Открыть голосование</a>
	"}
	if(!viewer?.prefs.discord_id || (viewer?.prefs.discord_id && length(viewer?.prefs.discord_id) == 32))
		html += {"<a class="menu_button" href='byond://?src=[player.UID()];connect_discord=1'>Привязка Discord</a>"}
	if(GLOB.join_tos && !viewer.tos_consent)
		html += {"<a class="menu_button" href='byond://?src=[player.UID()];tos=1'>Политика конфидициальности</a>"}

	if(check_rights(R_EVENT, FALSE, player))
		html += {"
			<hr>
			<a class="menu_button admin" href='byond://?src=[player.UID()];change_picture=1'>Изменить изображение</a>
			<a class="menu_button admin" href='byond://?src=[player.UID()];leave_notice=1'>Оставить уведомление</a>
		"}

	html += {"</div>"}
	html += {"</div>"}

	html += {"<label class="hide_button" for="hide_menu"><i class="fas fa-angles-left"></i></label>"}
	html += {"
		<div class="container_links">
			<a class="link_button" href='byond://?src=[player.UID()];wiki=1'><i class="fab fa-wikipedia-w"></i></a>
			<a class="link_button" href='byond://?src=[player.UID()];discord=1'><i class="fab fa-discord"></i></a>
			<a class="link_button" title="Чейнджлог" href='byond://?src=[player.UID()];changelog=1'><i class="fas fa-newspaper"></i></a>
		</div>
	"}
	html += {"</div>"}
	html += {"<div class="status-box">
			<div class="status-item">Режим: <span id="game-mode">extended</span></div>
			<div class="status-item">До начала раунда: <div class="countdown" id="countdown-timer">00:00</div></div>
			<div class="status-item">Игроков: <span id="players-count">0</span></div>
			<div class="status-item">Готовых игроков: <span id="ready-players">0/0</span></div>
	</div>"}
	html += {"<label class="hide_button hide_lobby" for="hide_lobby">Лобби</label>"}
	html += {"<div class="lobby-box"><div class="lobby-flex-box"></div></div>"}
	html += {"
		<script language="JavaScript">
			let ready_int = 0;
			const readyID = document.getElementById("ready");
			const arrival_message = document.getElementById("arrival_message");
			const ready_marks = \[ "Не готов", "Готов" \];
			const arrival_marks = \[ "...остается дома.", "...отправляется на станцию."\];
			const ready_class = \[ "bad", "good" \];
			function ready(setReady) {
				if(setReady) {
					ready_int = setReady;
					readyID.innerHTML = ready_marks\[ready_int\];;
					arrival_message.innerHTML = arrival_marks\[ready_int\];
					readyID.classList.add(ready_class\[ready_int\]);
					readyID.classList.remove(ready_class\[1 - ready_int\]);
				} else {
					ready_int++;
					if(ready_int === ready_marks.length)
						ready_int = 0;
					readyID.innerHTML = ready_marks\[ready_int\];
					arrival_message.innerHTML = arrival_marks\[ready_int\];
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

			function set_pixelated() {
				document.body.classList.add('pixelated');
				document.documentElement.classList.add('pixelated');
			}

			const charPreview = document.getElementById("preview");

			function update_preview() {
				charPreview.src = "previewicon.png";
			}

			function update_preview_515() {
				charPreview.src = "";
				setTimeout(update_preview, 100); // TODO: change after 516
			}

			function update_servers_list() {
				const args = Array.from(arguments);
				const servers = \[];

				for (const queryString of args) {
					const server = Object.fromEntries(
							queryString.split('&').map(item => item.split('='))
						);

					servers.push(server);
				}

				const lobbyBox = document.querySelector('.lobby-flex-box');
				lobbyBox.innerHTML = '';

				servers.forEach(game => {
					console.log(game.name)
					const gameHTML = `
						<div class="game-item">
							<div class="game-name">${decodeURI(game.name).replaceAll("+", " ")}</div>
							<div class="game-players"><i class="fas fa-users icon"></i> Игроки: ${game.players}</div>
							<div class="game-state"><i class="fas fa-clock icon"></i> Время: ${game.round_time.replaceAll("%3a", ":")}</div>
							<a class="game-button" href='byond://?src=[player.UID()];switch_server=${game.port}'><i class="fas fa-plug icon"></i> Подключиться</a>
						</div>`;
					lobbyBox.innerHTML += gameHTML;
				});
			}

			const gameMode = document.getElementById('game-mode');
			const countdown = document.getElementById('countdown-timer');
			const playersCount = document.getElementById('players-count');
			const readyPlayers = document.getElementById('ready-players');

			function update_newplayer_info(){
				const args = Object.fromEntries(
										Array.from(arguments).map(item => item.split('='))
									);
				const time = args.time_remaining;
				const players = args.players;
				const ready = args.total_players_ready;
				const mode = args.game_mode;
				gameMode.textContent = mode;
				countdown.textContent = time;
				playersCount.textContent = players;
				const readyExist = (ready !== undefined && ready !== null);
				readyPlayers.parentElement.style.display = readyExist? 'block' : 'none';
				readyPlayers.textContent = (!readyExist || ready <= 0)? 'НЕТ' : ready + '/' + players;
			}

			const character_name_slot = document.getElementById("character_slot");
			function update_current_character(name) {
				character_name_slot.textContent = name;
			}

			const notice_place = document.getElementById("notice_place");
			function update_notice(notice) {
				let noticeid = document.getElementById("notice");
				if(noticeid != null){
					noticeid.textContent = notice;
				}
				else{
					notice_place.classList.add("container_notice");
					var new_notice = document.createElement("p");
					new_notice.setAttribute("id", "notice");
					new_notice.textContent = notice;
					new_notice.classList.add("menu_notice");
					notice_place.appendChild(new_notice);
				}
			}

			let pixel_check;
			function set_theme(which) {
				pixel_check = document.body.className.indexOf("pixelated") != -1
				if (which == 'light') {
					document.body.className = '';
					document.documentElement.className = 'light';
				} else if (which == 'dark') {
					document.body.className = 'dark';
					document.documentElement.className = 'dark';
				} else if (which == 'ntos') {
					document.body.className = 'ntos';
					document.documentElement.className = 'ntos';
				} else if (which == 'paradise') {
					document.body.className = 'paradise';
					document.documentElement.className = 'paradise';
				} else if (which == 'syndicate') {
					document.body.className = 'syndicate';
					document.documentElement.className = 'syndicate';
				}
				if (pixel_check) set_pixelated();
			}

			/* Return focus to Byond after click */
			function reFocus() {
				location.href = 'byond://?src=[player.UID()];focus=1'
			}

			document.addEventListener('mouseup', reFocus);
			document.addEventListener('keyup', reFocus);

		</script>
		"}

	html += "</body></html>"

	return html.Join()

#undef DEFAULT_TITLE_SCREEN_HTML_PATH
#undef TITLE_SCREENS_LOCATION
