//Preset for action that call specific procs (consider innate)
/datum/action/generic
	var/procname

/datum/action/generic/Trigger(mob/clicker, trigger_flags)
	if(!..())
		return FALSE
	if(target && procname)
		call(target,procname)(usr)
	return TRUE

/datum/action/generic/configure_mmi_radio
	name = "Настроить радио MMI"
	desc = "Настроить радио, установленное в вашем MMI."
	check_flags = AB_CHECK_CONSCIOUS
	procname = "ui_interact"
	var/obj/item/mmi = null


/datum/action/generic/configure_mmi_radio/New(Target, obj/item/mmi/M)
	. = ..()
	mmi = M


/datum/action/generic/configure_mmi_radio/Destroy()
	mmi = null
	return ..()


/datum/action/generic/configure_mmi_radio/UpdateButtonIcon()
	if(!mmi)
		return
	..()
