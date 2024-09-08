#define DEFAULT_RITUAL_RANGE_FIND 1

#define RITUAL_SUCCESSFUL						(1<<0)
/// Invocation checks, should not be used in extra checks.
#define RITUAL_FAILED_INVALID_SPECIES			(1<<1)
#define RITUAL_FAILED_REQUIRED_SHAMAN_INVOKE	(1<<2)
#define RITUAL_FAILED_REQUIRED_EXTRA_SHAMAN		(1<<3)
#define RITUAL_FAILED_EXTRA_INVOKERS			(1<<4)

/datum/ritual
	/// Linked object
	var/obj/ritual_object
	/// Name of our ritual
	var/name = "Hello, I'm useless ritual"
	/// If ritual can be invoked only by shaman
	var/shaman_only = FALSE
	/// If ritual requires more than one ashwalker
	var/extra_invokers = 0
	/// If ritual requires extra shaman invokers
	var/extra_shaman_invokers = 0
	/// We search for ashwalkers in that radius
	var/finding_range = DEFAULT_RITUAL_RANGE_FIND
	/// Single rituals. If true - it cannot be choosen.
	var/ritual_completed = FALSE
	/// If type != attacking item type it will not open UI
	var/attacking_item_type
	/// Messages on failed invocation.
	var/invalid_species_message = "Вы не можете понять, как с этим работать."
	var/shaman_required_message = "Данный ритуал должен выполнять шаман."
	var/extra_shaman_required_message = "Для выполнения данного ритуала требуется больше шаманов."
	var/extra_invokers_message = "Для выполнения данного ритуала требуется больше участников."
	/// Messages on failed open UI
	var/invalid_attacking_item_type_message
	
/datum/ritual/proc/link_object(obj/obj)
	src.ritual_object = obj
	init_obj_signals()
	
/datum/ritual/proc/init_obj_signals()
	if(!ritual_object)
		return
	RegisterSignal(ritual_object, COMSIG_PARENT_ATTACKBY, PROC_REF(attackby))
	
/datum/ritual/Destroy(force)
	UnregisterSignal(ritual_object, COMSIG_PARENT_ATTACKBY)
	ritual_object = null
	return ..()
	
/datum/ritual/proc/attackby(obj/obj, mob/user, params)
	SIGNAL_HANDLER
	
	INVOKE_ASYNC(src, PROC_REF(pre_open_ritual_ui), obj, user)
	return COMPONENT_CANCEL_ATTACK_CHAIN // The reason not to give that datum to every object.
	
/datum/ritual/proc/open_ritual_ui(obj/obj, mob/living/carbon/human/human)
	var/list/rituals_list = list()
	for(var/datum/ritual/ritual as anything in subtypesof(/datum/ritual))
		if(!ritual.ritual_completed)
			rituals_list += ritual.name
	if(!LAZYLEN(rituals_list))
		to_chat(human, "Не имеется доступных для исполнения ритуалов.")
		
	var/tgui_menu = tgui_input_list(src, "выберите ритуал", "Ритуалы", rituals_list)
	if(!tgui_menu)
		return
		
	for(var/datum/ritual/ritual as anything in subtypesof(/datum/ritual))
		if(tgui_menu == ritual.name)
			ritual.pre_ritual_check(obj, human)
			break

/datum/ritual/proc/pre_open_ritual_ui(obj/obj, mob/user)
	var/message
	if(!ishuman(user))
		return
	var/mob/living/carbon/human/human = user
	if(!isashwalker(human))
		message = invalid_species_message
	if(attacking_item_type && !istype(obj, attacking_item_type))
		message = invalid_attacking_item_type_message
		
	if(message)
		to_chat(human, message)
		return

	if(open_ritual_ui_check(obj, human))
		open_ritual_ui(obj, human)

	return

/datum/ritual/proc/open_ritual_ui_check(obj/obj, mob/living/carbon/human/invoker) // Your custom checks are going here
	return TRUE
		
/datum/ritual/proc/pre_ritual_check(obj/obj, mob/living/carbon/human/invoker)
	var/message
	switch(ritual_invoke_check(obj, invoker))
		if(RITUAL_FAILED_INVALID_SPECIES)
			message = invalid_species_message
		if(RITUAL_FAILED_REQUIRED_SHAMAN_INVOKE)
			message = shaman_required_message
		if(RITUAL_FAILED_EXTRA_INVOKERS)
			message = extra_invokers_message
		if(RITUAL_FAILED_REQUIRED_EXTRA_SHAMAN)
			message = extra_shaman_required_message
		if(RITUAL_SUCCESSFUL)
			do_ritual(obj, invoker)
			
	if(message)
		to_chat(invoker, message)

	return
		
/datum/ritual/proc/ritual_invoke_check(obj/obj, mob/living/carbon/human/invoker)
	if(!isashwalker(invoker)) // double check to avoid funny situations
		return RITUAL_FAILED_INVALID_SPECIES
	if(shaman_only && !isashwalkershaman(invoker))
		return RITUAL_FAILED_REQUIRED_SHAMAN_INVOKE
	if(extra_invokers || extra_shaman_invokers)
		var/list/invokers = list()
		var/list/shaman_invokers = list()
		for(var/mob/living/carbon/human/human in range(finding_range, obj))
			if(isashwalker(human))
				invokers += human
			if(isashwalkershaman(human))
				shaman_invokers += human
				
		if(LAZYLEN(invokers) < extra_invokers)
			return RITUAL_FAILED_EXTRA_INVOKERS
		if(LAZYLEN(shaman_invokers) < extra_shaman_invokers)
			return RITUAL_FAILED_REQUIRED_EXTRA_SHAMAN
			
	return ritual_check(obj, invoker)
	
/datum/ritual/proc/ritual_check(obj/obj, mob/living/carbon/human/invoker) // After extra checks we should return RITUAL_SUCCESSFUL.
	return RITUAL_SUCCESSFUL

/datum/ritual/proc/do_ritual(obj/obj, mob/living/carbon/human/invoker) // Do ritual stuff.
	return
	