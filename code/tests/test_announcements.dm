/// This test exists largely to ensure that no runtimes occur when announcements
/// are made, so there are no explicit Fail calls. It either works or runtimes.
/datum/game_test/announcements

/datum/game_test/announcements/Run()
	GLOB.major_announcement.announce("Figments from an eldritch god are being summoned into the NSS Cyberiad from an unknown dimension. Disrupt the ritual at all costs, before the station is destroyed! Space Law and SOP are suspended. The entire crew must kill cultists on sight.", "Central Command Higher Dimensional Affairs", 'sound/AI/cult_summon.ogg')

	GLOB.major_announcement.announce(
		message = "We have removed all access requirements on your station's airlocks. You can thank us later!",
		new_title = "Space Wizard Federation Message",
		new_subtitle = "Greetings!",
		new_sound = 'sound/misc/notice2.ogg'
	)

	var/datum/announcer/requests_console = new(config_type = /datum/announcement_configuration/requests_console)
	requests_console.config.default_title = "Science announcement"
	requests_console.announce("Request console announcement")

	var/datum/announcer/comms_console = new(config_type = /datum/announcement_configuration/comms_console)

	comms_console.author = "Foo Bar"
	comms_console.announce("This is a test of the communications console announcement.")

	var/title = "Nanotrasen Update"
	var/message = "This is an admin report."
	var/subtitle = "NAS Trurl Update"
	GLOB.major_announcement.announce(
		message,
		new_title = title,
		new_subtitle = subtitle,
		new_sound = 'sound/misc/notice2.ogg'
	)

	GLOB.minor_announcement.announce(
		message = "Bioscans indicate that lizards have been breeding in the kitchen. Clear them out, before this starts to affect productivity.",
		new_title = "Lifesign Alert"
	)

	var/datum/announcer/ai_announcer = new(config_type = /datum/announcement_configuration/ai)
	ai_announcer.author = "AI-NAME-0345"
	ai_announcer.announce("AI only get one input box so here ya go")

	SSsecurity_level.set_level(SEC_LEVEL_RED)
	SSsecurity_level.set_level(SEC_LEVEL_GAMMA)
	SSsecurity_level.set_level(SEC_LEVEL_EPSILON)
	SSsecurity_level.set_level(SEC_LEVEL_RED)
	SSsecurity_level.set_level(SEC_LEVEL_BLUE)
	SSsecurity_level.set_level(SEC_LEVEL_GREEN)

	var/reason = "We're getting the fuck out of here"
	var/redAlert = TRUE
	GLOB.major_announcement.announce(
		message = "The emergency shuttle has been called. [redAlert ? "Red Alert state confirmed: Dispatching priority shuttle. " : "" ]It will arrive in 10 minutes.[reason]",
		new_title = "Priority announcement",
		new_sound = sound('sound/AI/eshuttle_call.ogg')
	)

