/// How many chat payloads to keep in history
#define CHAT_RELIABILITY_HISTORY_SIZE 5
/// How many resends to allow before giving up
#define CHAT_RELIABILITY_MAX_RESENDS 3

#define MESSAGE_TYPE_SYSTEM "system"
#define MESSAGE_TYPE_LOCALCHAT "localchat"
#define MESSAGE_TYPE_RADIO "radio"
#define MESSAGE_TYPE_INFO "info"
#define MESSAGE_TYPE_WARNING "warning"
#define MESSAGE_TYPE_DEADCHAT "deadchat"
#define MESSAGE_TYPE_OOC "ooc"
#define MESSAGE_TYPE_ADMINPM "adminpm"
#define MESSAGE_TYPE_MENTORPM "mentorpm"
#define MESSAGE_TYPE_COMBAT "combat"
#define MESSAGE_TYPE_ADMINCHAT "adminchat"
#define MESSAGE_TYPE_MENTORCHAT "mentorchat"
#define MESSAGE_TYPE_DEVCHAT "devchat"
#define MESSAGE_TYPE_EVENTCHAT "eventchat"
#define MESSAGE_TYPE_ADMINLOG "adminlog"
#define MESSAGE_TYPE_ATTACKLOG "attacklog"
#define MESSAGE_TYPE_DEBUG "debug"

// Debug printing macros (for development and testing)
/// Used for debug messages to the world
#define debug_world(msg) if (GLOB.Debug2) to_chat(world, \
	type = MESSAGE_TYPE_DEBUG, \
	text = "DEBUG: [msg]")
/// Used for debug messages to the player
#define debug_usr(msg) if (GLOB.Debug2 && usr) to_chat(usr, \
	type = MESSAGE_TYPE_DEBUG, \
	text = "DEBUG: [msg]")
/// Used for debug messages to the admins
#define debug_admins(msg) if (GLOB.Debug2) to_chat(GLOB.admins, \
	type = MESSAGE_TYPE_DEBUG, \
	text = "DEBUG: [msg]")
/// Used for debug messages to the server
#define debug_world_log(msg) if (GLOB.Debug2) log_world("DEBUG: [msg]")

/// Wraps text in a standard boxed message container
#define chat_box_regular(str) ("<div class='boxed_message'>" + str + "</div>")
/// Formats text as left-aligned examination text in a boxed container
#define chat_box_examine(str) ("<div class='boxed_message left_align_text'>" + str + "</div>")
/// Creates a boxed message with red border for warning/alert messages
#define chat_box_red(str) ("<div class='boxed_message red_border'>" + str + "</div>")
/// Creates a boxed message with purple border for unique/special notifications
#define chat_box_purple(str) ("<div class='boxed_message purple_border'>" + str + "</div>")
/// Creates a boxed message with yellow border for cautionary messages
#define chat_box_yellow(str) ("<div class='boxed_message yellow_border'>" + str + "</div>")
/// Creates a boxed message with green border for positive/success notifications
#define chat_box_green(str) ("<div class='boxed_message green_border'>" + str + "</div>")
/// Creates a boxed message with standard notice border for important information
#define chat_box_notice(str) ("<div class='boxed_message notice_border'>" + str + "</div>")
/// Formats health scan results as left-aligned text in a notice-bordered box
#define chat_box_healthscan(str) ("<div class='boxed_message notice_border left_align_text'>" + str + "</div>")
/// Creates a prominent boxed notice with thick border for critical information
#define chat_box_notice_thick(str) ("<div class='boxed_message notice_border thick_border'>" + str + "</div>")
/// Creates an urgent red-bordered box for admin help messages (ahelp)
#define chat_box_ahelp(str) ("<div class='boxed_message red_border'>" + str + "</div>")
/// Creates a notice-bordered box for mentor help messages (mhelp)
#define chat_box_mhelp(str) ("<div class='boxed_message notice_border'>" + str + "</div>")
