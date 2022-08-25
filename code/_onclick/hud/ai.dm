/obj/screen/ai
	icon = 'icons/mob/screen_ai.dmi'

/obj/screen/ai/aicore
	name = "AI core"
	icon_state = "ai_core"

/obj/screen/ai/aicore/Click()
	if(isAI(usr))
		var/mob/living/silicon/ai/AI = usr
		AI.view_core()

/obj/screen/ai/camera_list
	name = "Show Camera List"
	icon_state = "camera"

/obj/screen/ai/camera_list/Click()
	var/mob/living/silicon/ai/AI = usr
	var/camera = input(AI, "Choose which camera you want to view", "Cameras") as null|anything in AI.get_camera_list()
	AI.ai_camera_list(camera)

/obj/screen/ai/camera_track
	name = "Track With Camera"
	icon_state = "track"

/obj/screen/ai/camera_track/Click()
	if(isAI(usr))
		var/mob/living/silicon/ai/AI = usr
		var/target_name = input(AI) as null|anything in AI.trackable_mobs()
		if(target_name)
			AI.ai_camera_track(target_name)

/obj/screen/ai/camera_light
	name = "Toggle Camera Light"
	icon_state = "camera_light"

/obj/screen/ai/camera_light/Click()
	if(isAI(usr))
		var/mob/living/silicon/ai/AI = usr
		AI.toggle_camera_light()

/obj/screen/ai/crew_monitor
	name = "Crew Monitoring Console"
	icon_state = "crew_monitor"

/obj/screen/ai/crew_monitor/Click()
	if(isAI(usr))
		var/mob/living/silicon/ai/AI = usr
		AI.subsystem_crew_monitor()

/obj/screen/ai/crew_manifest
	name = "Crew Manifest"
	icon_state = "manifest"

/obj/screen/ai/crew_manifest/Click()
	if(isAI(usr))
		var/mob/living/silicon/ai/AI = usr
		AI.ai_roster()

/obj/screen/ai/alerts
	name = "Show Alerts"
	icon_state = "alerts"

/obj/screen/ai/alerts/Click()
	if(isAI(usr))
		var/mob/living/silicon/ai/AI = usr
		AI.ai_alerts()

/obj/screen/ai/announcement
	name = "Make Announcement"
	icon_state = "announcement"

/obj/screen/ai/announcement/Click()
	var/mob/living/silicon/ai/AI = usr
	AI.announcement()

/obj/screen/ai/call_shuttle
	name = "Call Emergency Shuttle"
	icon_state = "call_shuttle"

/obj/screen/ai/call_shuttle/Click()
	if(isAI(usr))
		var/mob/living/silicon/ai/AI = usr
		AI.ai_call_shuttle()

/obj/screen/ai/state_laws
	name = "Law Manager"
	icon_state = "state_laws"

/obj/screen/ai/state_laws/Click()
	if(isAI(usr))
		var/mob/living/silicon/ai/AI = usr
		AI.subsystem_law_manager()

/obj/screen/ai/pda_msg_send
	name = "PDA - Send Message"
	icon_state = "pda_send"

/obj/screen/ai/pda_msg_send/Click()
	if(isAI(usr))
		var/mob/living/silicon/ai/AI = usr
		AI.aiPDA.cmd_send_pdamesg()

/obj/screen/ai/pda_msg_show
	name = "PDA - Show Message Log"
	icon_state = "pda_receive"

/obj/screen/ai/pda_msg_show/Click()
	if(isAI(usr))
		var/mob/living/silicon/ai/AI = usr
		AI.aiPDA.cmd_show_message_log()

/obj/screen/ai/image_take
	name = "Take Image"
	icon_state = "take_picture"

/obj/screen/ai/image_take/Click()
	if(isAI(usr))
		var/mob/living/silicon/ai/AI = usr
		if(AI.aiCamera.in_camera_mode && !AI.add_heat(AI_TAKE_IMAGE_HEAT))
			return
		AI.aiCamera.toggle_camera_mode()

/obj/screen/ai/image_view
	name = "View Images"
	icon_state = "view_images"

/obj/screen/ai/image_view/Click()
	if(isAI(usr))
		var/mob/living/silicon/ai/AI = usr
		AI.aiCamera.viewpictures()

/obj/screen/ai/sensors
	name = "Toggle Sensor Augmentation"
	icon_state = "ai_sensor"

/obj/screen/ai/sensors/Click()
	if(isAI(usr))
		var/mob/living/silicon/ai/AI = usr
		AI.sensor_mode()
	else if(isrobot(usr))
		var/mob/living/silicon/robot/borg = usr
		borg.sensor_mode()

/mob/living/silicon/ai/create_mob_hud()
	if(client && !hud_used)
		hud_used = new /datum/hud/ai(src)

/obj/screen/ai/heat_display
	icon = 'icons/mob/screen_ai_heat_panels.dmi'
	name = "Current Heat"
	icon_state = "heat_display"
	var/image/reserve_heat_display = null

	var/image/heat_indicator = null
	var/image/reserve_heat_indicator = null

/obj/screen/ai/heat_display/Initialize(mapload)
	. = ..()
	underlays += image(src.icon, null, "heat_display_background", src.layer - 1)
	reserve_heat_display = image(src.icon, null, "reserve_heat_display", src.layer)
	reserve_heat_display.underlays += image(src.icon, null, "reserve_heat_display_background", src.layer - 1)

	var/icon/indicator_icon = icon(src.icon)
	indicator_icon.Crop(1, 1, 1, indicator_icon.Height())

	heat_indicator = image(indicator_icon, null, "heat_display_indicator")
	heat_indicator.pixel_x = 20
	reserve_heat_indicator = image(indicator_icon, null, "reserve_heat_display_indicator")
	reserve_heat_indicator.pixel_x = 50

/obj/screen/ai/heat_display/proc/update_display_value(mob/living/silicon/ai/user, new_value)
	var/indicator_lenght = round(new_value / user.max_heat * 120)
	underlays -= heat_indicator
	
	var/matrix/M = matrix()
	M.Scale(indicator_lenght, 1)
	M.Translate(round(indicator_lenght/2), 0)
	heat_indicator.transform = M
	
	underlays += heat_indicator

/obj/screen/ai/heat_display/proc/update_reserve_display_value(mob/living/silicon/ai/user, new_value)
	if(GLOB.security_level < SEC_LEVEL_RED)
		if(LAZYLEN(overlays))
			overlays -= reserve_heat_display
			underlays -= reserve_heat_indicator
		return
	else if(!LAZYLEN(overlays))
		overlays += reserve_heat_display

	var/indicator_lenght = round(new_value / user.max_reserve_heat * 60)
	underlays -= reserve_heat_indicator

	var/matrix/M = matrix()
	M.Scale(indicator_lenght, 1)
	M.Translate(round(indicator_lenght/2), 0)
	reserve_heat_indicator.transform = M

	underlays += reserve_heat_indicator

/datum/hud/ai
	var/obj/screen/ai/heat_display/heat_display = null


/datum/hud/ai/New(mob/owner)
	..()

	var/obj/screen/using

	using = new /obj/screen/language_menu
	using.screen_loc = ui_borg_lanugage_menu
	static_inventory += using

//AI core
	using = new /obj/screen/ai/aicore()
	using.screen_loc = ui_ai_core
	static_inventory += using

//Camera list
	using = new /obj/screen/ai/camera_list()
	using.screen_loc = ui_ai_camera_list
	static_inventory += using

//Track
	using = new /obj/screen/ai/camera_track()
	using.screen_loc = ui_ai_track_with_camera
	static_inventory += using

//Camera light
	using = new /obj/screen/ai/camera_light()
	using.screen_loc = ui_ai_camera_light
	static_inventory += using

//Crew Monitorting
	using = new  /obj/screen/ai/crew_monitor()
	using.screen_loc = ui_ai_crew_monitor
	static_inventory += using

//Crew Manifest
	using = new /obj/screen/ai/crew_manifest()
	using.screen_loc = ui_ai_crew_manifest
	static_inventory += using

//Alerts
	using = new /obj/screen/ai/alerts()
	using.screen_loc = ui_ai_alerts
	static_inventory += using

//Announcement
	using = new /obj/screen/ai/announcement()
	using.screen_loc = ui_ai_announcement
	static_inventory += using

//Shuttle
	using = new /obj/screen/ai/call_shuttle()
	using.screen_loc = ui_ai_shuttle
	static_inventory += using

//Laws
	using = new /obj/screen/ai/state_laws()
	using.screen_loc = ui_ai_state_laws
	static_inventory += using

//PDA message
	using = new /obj/screen/ai/pda_msg_send()
	using.screen_loc = ui_ai_pda_send
	static_inventory += using

//PDA log
	using = new /obj/screen/ai/pda_msg_show()
	using.screen_loc = ui_ai_pda_log
	static_inventory += using

//Take image
	using = new /obj/screen/ai/image_take()
	using.screen_loc = ui_ai_take_picture
	static_inventory += using

//View images
	using = new /obj/screen/ai/image_view()
	using.screen_loc = ui_ai_view_images
	static_inventory += using

//Medical/Security sensors
	using = new /obj/screen/ai/sensors()
	using.screen_loc = ui_ai_sensor
	static_inventory += using

//Intent
	using = new /obj/screen/act_intent/robot/AI()
	using.icon_state = mymob.a_intent
	static_inventory += using
	action_intent = using

//Heat display
	using = new /obj/screen/ai/heat_display()
	using.screen_loc = ui_ai_heat_display
	heat_display = using
	static_inventory += using
