#ifdef TGS
/datum/asset/simple/tgui
	keep_local_name = FALSE
	assets = list(
		"tgui.bundle.js" = "tgui/public/tgui.bundle.js",
		"tgui.bundle.css" = "tgui/public/tgui.bundle.css",
	)

/datum/asset/simple/tgui_panel
	keep_local_name = FALSE
	assets = list(
		"tgui-panel.bundle.js" = "tgui/public/tgui-panel.bundle.js",
		"tgui-panel.bundle.css" = "tgui/public/tgui-panel.bundle.css",
	)

#else
/datum/asset/simple/tgui
	keep_local_name = TRUE
	assets = list(
		"tgui.bundle.js" = file("tgui/public/tgui.bundle.js"),
		"tgui.bundle.css" = file("tgui/public/tgui.bundle.css"),
	)

/datum/asset/simple/tgui_panel
	keep_local_name = TRUE
	assets = list(
		"tgui-panel.bundle.js" = file("tgui/public/tgui-panel.bundle.js"),
		"tgui-panel.bundle.css" = file("tgui/public/tgui-panel.bundle.css"),
	)

#endif

/datum/asset/simple/namespaced/fontawesome
	legacy = TRUE
	assets = list(
		"fa-brands-400.ttf" = 'html/font-awesome/webfonts/fa-brands-400.ttf',
		"fa-brands-400.woff2" = 'html/font-awesome/webfonts/fa-brands-400.woff2',
		"fa-solid-900.ttf" = 'html/font-awesome/webfonts/fa-solid-900.ttf',
		"fa-solid-900.woff2" = 'html/font-awesome/webfonts/fa-solid-900.woff2',
		"fa-regular-400.ttf" = 'html/font-awesome/webfonts/fa-regular-400.ttf',
		"fa-regular-400.woff2" = 'html/font-awesome/webfonts/fa-regular-400.woff2',
		"fa-v4compatibility.ttf" = 'html/font-awesome/webfonts/fa-v4compatibility.ttf',
		"fa-v4compatibility.woff2" = 'html/font-awesome/webfonts/fa-v4compatibility.woff2',
		"v4shim.css" = 'html/font-awesome/css/v4-shims.min.css',
	)
	parents = list(
		"font-awesome.css" = 'html/font-awesome/css/all.min.css',
	)

/datum/asset/simple/chat_dark
	assets = list(
		"tgui-chat-dark.bundle.css" = file("tgui/public/tgui-chat-dark.bundle.css"),
	)

/datum/asset/simple/namespaced/escape_menu_font
	assets = list(
		"Pixellari.ttf" = file("interface/fonts/Pixellari.ttf"),
		"Grand9K_Pixel.ttf" = file("interface/fonts/Grand9K_Pixel.ttf"),
	)
	parents = list(
		"fonts.css" = file("tgui/packages/tgui-escape-menu/styles/fonts.css"),
	)

/datum/asset/simple/namespaced/escape_menu_sounds
	assets = list(
		"esc_open.ogg" = file("sound/misc/escape_menu/esc_open.ogg"),
		"esc_middle.ogg" = file("sound/misc/escape_menu/esc_middle.ogg"),
		"esc_close.ogg" = file("sound/misc/escape_menu/esc_close.ogg"),
	)

/datum/asset/spritesheet_batched/escape_menu_icons
	name = "escape-menu-icons"

/datum/asset/spritesheet_batched/escape_menu_icons/create_spritesheets()
	var/icon/icons_small = 'icons/hud/escape_menu_icons.dmi'
	for(var/state in icon_states(icons_small))
		insert_icon(state, uni_icon(icons_small, icon_state = state))
	var/icon/icons_large = 'icons/hud/escape_menu_leave_body.dmi'
	for(var/state in icon_states(icons_large))
		insert_icon("leave-[state]", uni_icon(icons_large, icon_state = state))
