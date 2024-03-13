/mob/living/silicon/ai/Logout()
	..()
	for(var/obj/machinery/ai_status_display/display as anything in GLOB.ai_displays) //change status
		display.mode = AI_DISPLAY_MODE_BLANK
	src.view_core()
	return
