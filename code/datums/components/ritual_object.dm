/datum/component/ritual_object
	/// if defined and you attacking parent without that item - UI will not be shown.
	var/attacking_item_type
	/// Pre-defined rituals list
	var/list/rituals = list()
	/// We define rituals from this.
	var/list/allowed_categories
	/// Prevents from multiple uses
	var/active_ui = FALSE

/datum/component/ritual_object/Initialize(attacking_item_type, allowed_categories = /datum/ritual)
	if(!isobj(parent))
		return COMPONENT_INCOMPATIBLE
	src.attacking_item_type = attacking_item_type
	src.allowed_categories = allowed_categories
	get_rituals()

/datum/component/ritual_object/RegisterWithParent()
	RegisterSignal(parent, COMSIG_PARENT_ATTACKBY, PROC_REF(attackby))

/datum/component/ritual_object/UnregisterFromParent()
	UnregisterSignal(parent, COMSIG_PARENT_ATTACKBY)

/datum/component/ritual_object/proc/get_rituals()
	LAZYCLEARLIST(rituals)
	for(var/datum/ritual/ritual as anything in typecacheof(allowed_categories))
		if(ritual.name)
			rituals += new ritual
			ritual.link_object(parent)
	return

/datum/component/ritual_object/Destroy(force)
	LAZYNULL(rituals)
	return ..()
	
/datum/component/ritual_object/proc/attackby(obj/obj, mob/user, params)
	SIGNAL_HANDLER
	
	if(active_ui)
		return
	if(!ishuman(user))
		return
	var/mob/living/carbon/human/human = user
	if(attacking_item_type && !istype(obj, attacking_item_type))
		return
		
	active_ui = TRUE
	INVOKE_ASYNC(src, PROC_REF(open_ritual_ui), obj, human)
	return COMPONENT_CANCEL_ATTACK_CHAIN 

/datum/component/ritual_object/proc/open_ritual_ui(obj/obj, mob/living/carbon/human/human)
	var/list/rituals_list = get_available_rituals()

	if(!LAZYLEN(rituals_list))
		to_chat(human, "Не имеется доступных для исполнения ритуалов.")
		return

	var/tgui_menu = tgui_input_list(human, "выберите ритуал", "Ритуалы", rituals_list)
	if(!tgui_menu)
		active_ui = FALSE
		return
		
	for(var/datum/ritual/ritual as anything in rituals)
		if(tgui_menu == ritual.name)
			ritual.pre_ritual_check(obj, human)
			break
			
	active_ui = FALSE
	return

/datum/component/ritual_object/proc/get_available_rituals()
	var/list/rituals_list = list()
	for(var/datum/ritual/ritual as anything in rituals)
		if(!ritual.charges && ritual.charges >= 0))
			continue
		if(!COOLDOWN_FINISHED(ritual, ritual_cooldown))
			continue
		if(ritual.allowed_species && !is_type_in_typecache(human.dna.species, ritual.allowed_species))
			continue
		LAZYADD(rituals_list, ritual.name)
	return rituals_list
