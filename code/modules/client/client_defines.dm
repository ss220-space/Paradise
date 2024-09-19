/client
		//////////////////////
		//BLACK MAGIC THINGS//
		//////////////////////
	parent_type = /datum
		////////////////
		//ADMIN THINGS//
		////////////////
	/// hides the byond verb panel as we use our own custom version
	show_verb_panel = FALSE
	var/datum/admins/holder = null

	var/last_message	= "" //contains the last message sent by this client - used to protect against copy-paste spamming.
	var/last_message_count = 0 //contains a number of how many times a message identical to last_message was sent.
	var/last_message_time = 0 //holds the last time (based on world.time) a message was sent
	var/datum/pm_tracker/pm_tracker = new()

		/////////
		//OTHER//
		/////////
	var/datum/preferences/prefs = null

	///Move delay of controlled mob, any keypresses inside this period will persist until the next proper move
	var/move_delay = 0
	///The visual delay to use for the current client.Move(), mostly used for making a client based move look like it came from some other slower source
	var/visual_delay = 0

	var/area			= null
	var/time_joined_as_mouse = null //when the client last spawned as a mouse

	var/typing = FALSE // Prevents typing window stacking

	var/adminhelped = 0

		///////////////
		//SOUND STUFF//
		///////////////

	var/white_noise_playing = FALSE

		////////////
		//SECURITY//
		////////////

	///Used for limiting the rate of topic sends by the client to avoid abuse
	var/list/topiclimiter
	///Used for limiting the rate of clicks sends by the client to avoid abuse
	var/list/clicklimiter

	// comment out the line below when debugging locally to enable the options & messages menu
	control_freak = CONTROL_FREAK_ALL

	var/ssd_warning_acknowledged = FALSE

		////////////////////////////////////
		//things that require the database//
		////////////////////////////////////
	var/player_age = "--"	//So admins know why it isn't working - Used to determine how old the account is - in days.
	var/list/related_accounts_ip = list()	//So admins know why it isn't working - Used to determine what other accounts previously logged in from this ip
	var/list/related_accounts_cid = list()	//So admins know why it isn't working - Used to determine what other accounts previously logged in from this computer id

	preload_rsc = PRELOAD_RSC

	/**
	 * Assoc list with all the active maps - when a screen obj is added to
	 * a map, it's put in here as well.
	 *
	 * Format: list(<mapname> = list(/atom/movable/screen))
	 */
	var/list/screen_maps = list()

	var/atom/movable/screen/click_catcher/void

	var/karma = 0
	var/karma_spent = 0
	var/karma_tab = 0


	var/ip_intel = "Disabled"

	var/datum/click_intercept/click_intercept = null

	///Time when the click was intercepted
	var/click_intercept_time = 0

	/// Overlay for showing debug info
	var/atom/movable/screen/debugtextholder/debug_text_overlay

	var/datum/geoip_data/geoip = null

	//datum that controls the displaying and hiding of tooltips
	var/datum/tooltip/tooltips

	// Donator stuff.
	var/donator_level = 0

	// If set to true, this client can interact with atoms such as buttons and doors on top of regular machinery interaction
	var/advanced_admin_interaction = FALSE

	var/client_keysend_amount = 0
	var/next_keysend_reset = 0
	var/next_keysend_trip_reset = 0
	var/keysend_tripped = FALSE

	/// Messages currently seen by this client
	var/list/seen_messages

	/// list of tabs containing spells and abilities
	var/list/spell_tabs = list()

	/// our current tab
	var/stat_tab

	/// list of all tabs
	var/list/panel_tabs = list()

	var/fullscreen = FALSE

	// Last world.time that the player tried to request their resources.
	var/last_ui_resource_send = 0

	/// If true, client cannot ready up, late join, or observe. Used for players with EXTREMELY old byond versions.
	var/version_blocked = FALSE

	/// Date the client registered their BYOND account on
	var/byondacc_date
	/// Days since the client's BYOND account was created
	var/byondacc_age = 0

	///Last ping of the client
	var/lastping = 0
	///Average ping of the client
	var/avgping = 0
	///world.time they connected
	var/connection_time
	///world.realtime they connected
	var/connection_realtime
	///world.timeofday they connected
	var/connection_timeofday

	// Do not attempt to merge these vars together. They are for different things
	/// Last world.time that a PM was send to discord by a player
	var/last_discord_pm_time = 0

	/// Last world/time that a PM was sent to the player by an admin
	var/received_discord_pm = -99999 // Yes this super low number is intentional

	/// Has the client accepted the TOS about data collection and other stuff
	var/tos_consent = FALSE

	var/url

	/// The client's active keybindings, depending on their active mob.
	var/list/active_keybindings = list()	// will be removed later

	/// A buffer of currently held keys.
	var/list/keys_held = list()
	/// A buffer for combinations such of modifiers + keys (ex: CtrlD, AltE, ShiftT). Format: `"key"` -> `"combo"` (ex: `"D"` -> `"CtrlD"`)
	var/list/key_combos_held = list()
	///custom movement keys for this client
	var/list/movement_keys = list()
	/// The direction we WANT to move, based off our keybinds
	/// Will be udpated to be the actual direction later on
	var/intended_direction = NONE
	///Are we locking our movement input?
	var/movement_locked = FALSE
	/*
	** These next two vars are to apply movement for keypresses and releases made while move delayed.
	** Because discarding that input makes the game less responsive.
	*/
	/// On next move, add this dir to the move that would otherwise be done
	var/next_move_dir_add
	/// On next move, subtract this dir from the move that would otherwise be done
	var/next_move_dir_sub

	/// When to next alert admins that mouse macro use was attempted
	var/next_mouse_macro_warning

	/// Assigned say modal of the client
	var/datum/tgui_say/tgui_say

	///used to make a special mouse cursor, this one for mouse up icon
	var/mouse_up_icon = null
	///used to make a special mouse cursor, this one for mouse up icon
	var/mouse_down_icon = null
	///used to override the mouse cursor so it doesnt get reset
	var/mouse_override_icon = null

	///Autoclick list of two elements, first being the clicked thing, second being the parameters.
	var/list/atom/selected_target[2]
	///Used in MouseDrag to preserve the original mouse click parameters
	var/mouseParams = ""
	///Used in MouseDrag to preserve the last mouse-entered location.
	var/mouse_location_UID
	///Used in MouseDrag to preserve the last mouse-entered object.
	var/mouse_object_UID
	///When we started the currently active drag
	var/drag_start = 0
	//The params we were passed at the start of the drag, in list form
	var/list/drag_details

	/// List of all asset filenames sent to this client by the asset cache, along with their assoicated md5s
	var/list/sent_assets = list()
	/// List of all completed blocking send jobs awaiting acknowledgement by send_asset
	var/list/completed_asset_jobs = list()

	/*
	ASSET SENDING
	*/
	/// The ID of the last asset job
	var/last_asset_job = 0
	/// The ID of the last asset job that was properly finished
	var/last_completed_asset_job = 0

	/// Our object window datum. It stores info about and handles behavior for the object tab
	var/datum/object_window_info/obj_window

/client/vv_edit_var(var_name, var_value)
	if(var_name == NAMEOF(src, tos_consent))
		// I know we will never be in a world where admins are editing client vars to let people bypass TOS
		// But guess what, if I have the ability to overengineer something, I am going to do it
		return FALSE
	return ..()
