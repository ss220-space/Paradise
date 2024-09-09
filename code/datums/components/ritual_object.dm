/datum/component/ritual_object
	/// if defined and you attacking parent without that item - UI will not be shown.
	var/attacking_item_type
	/// Pre-defined rituals list
	var/list/rituals = list()

/datum/component/ritual_object/Initialize(attacking_item_type)
	if(!isobj(parent))
		return COMPONENT_INCOMPATIBLE
	src.attacking_item_type = attacking_item_type
	get_rituals()

/datum/component/ritual_object/RegisterWithParent()
	RegisterSignal(parent, COMSIG_PARENT_ATTACKBY, PROC_REF(attackby))

/datum/component/ritual_object/UnregisterFromParent()
	UnregisterSignal(parent, COMSIG_PARENT_ATTACKBY)

/datum/component/ritual_object/proc/get_rituals()
	LAZYCLEARLIST(rituals)
	for(var/datum/ritual/ritual as anything in subtypesof(/datum/ritual))
		rituals += new ritual
		ritual.link_object(parent)
	return

/datum/component/ritual_object/Destroy(force)
	LAZYNULL(rituals)
	return ..()
	
/datum/component/ritual_object/proc/attackby(obj/obj, mob/user, params)
	SIGNAL_HANDLER
	
	INVOKE_ASYNC(src, PROC_REF(pre_open_ritual_ui), obj, user)
	return COMPONENT_CANCEL_ATTACK_CHAIN // The reason not to give that datum to every object.

/datum/component/ritual_object/proc/open_ritual_ui(obj/obj, mob/living/carbon/human/human)
	var/list/rituals_list = list()
	for(var/datum/ritual/ritual as anything in rituals)
		if(ritual.ritual_completed)
			continue
		if(!COOLDOWN_FINISHED(ritual, ritual_cooldown))
			continue
		if(ritual.allowed_species && !is_type_in_typecache(human.dna.species, ritual.allowed_species))
			continue
		LAZYADD(rituals_list, ritual.name)

	if(!LAZYLEN(rituals_list))
		to_chat(human, "Не имеется доступных для исполнения ритуалов.")
		return

	var/tgui_menu = tgui_input_list(src, "выберите ритуал", "Ритуалы", rituals_list)
	if(!tgui_menu)
		return
		
	for(var/datum/ritual/ritual as anything in rituals)
		if(tgui_menu == ritual.name)
			ritual.pre_ritual_check(obj, human)
			break
	return

/datum/component/ritual_object/proc/pre_open_ritual_ui(obj/obj, mob/user)
	if(!ishuman(user))
		return
	var/mob/living/carbon/human/human = user
	if(attacking_item_type && !istype(obj, attacking_item_type))
		return
	if(open_ritual_ui_check(obj, human))
		open_ritual_ui(obj, human)
	return

/datum/component/ritual_object/proc/open_ritual_ui_check(obj/obj, mob/living/carbon/human/human) // Your custom checks are going here
	return TRUE

