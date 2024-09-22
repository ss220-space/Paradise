/datum/component/ritual_object
	/// if defined and you attacking parent without that item - UI will not be shown.
	var/list/attacking_item_type
	/// Pre-defined rituals list
	var/list/rituals = list()
	/// We define rituals from this.
	var/list/allowed_categories
	/// Required species to activate ritual object
	var/list/allowed_species
	/// Required special role to activate ritual object
	var/list/allowed_special_role
	/// Prevents from multiple uses
	var/active_ui = FALSE

/datum/component/ritual_object/Initialize(
	list/attacking_item_type, 
	allowed_categories = /datum/ritual,
	list/allowed_species,
	list/allowed_special_role
)

	if(!isobj(parent))
		return COMPONENT_INCOMPATIBLE
	src.attacking_item_type = attacking_item_type
	src.allowed_categories = allowed_categories
	src.allowed_species = allowed_species
	src.allowed_special_role = allowed_special_role
	get_rituals()

/datum/component/ritual_object/RegisterWithParent()
	RegisterSignal(parent, COMSIG_PARENT_ATTACKBY, PROC_REF(attackby))

/datum/component/ritual_object/UnregisterFromParent()
	UnregisterSignal(parent, COMSIG_PARENT_ATTACKBY)

/datum/component/ritual_object/proc/get_rituals() // We'll get all rituals for flexibility. 
	LAZYCLEARLIST(rituals)
	for(var/datum/ritual/ritual as anything in typecacheof(allowed_categories))
		if(ritual.name)
			rituals += new ritual
			ritual.link_object(parent)

	return

/datum/component/ritual_object/Destroy(force)
	LAZYNULL(rituals)
	return ..()
	
/datum/component/ritual_object/proc/attackby(obj/item/item, mob/user, params)
	SIGNAL_HANDLER
	
	if(active_ui)
		return

	if(!ishuman(user))
		return

	var/mob/living/carbon/human/human = user
	if(attacking_item_type && !istype(item, attacking_item_type))
		return

	if(allowed_species && !is_type_in_list(human.dna.species, allowed_species))
		return

	if(allowed_special_role && !is_type_in_list(human.mind?.special_role, allowed_special_role))
		return
		
	active_ui = TRUE
	INVOKE_ASYNC(src, PROC_REF(open_ritual_ui), item, human)
	
	return COMPONENT_CANCEL_ATTACK_CHAIN 

/datum/component/ritual_object/proc/open_ritual_ui(obj/item/item, mob/living/carbon/human/human)
	var/list/rituals_list = get_available_rituals(human)

	if(!LAZYLEN(rituals_list))
		to_chat(human, "Не имеется доступных для исполнения ритуалов.")
		return

	var/choosen_ritual = tgui_input_list(human, "Выберите ритуал", "Ритуалы", rituals_list)
	if(!choosen_ritual)
		active_ui = FALSE
		return
		
	for(var/datum/ritual/ritual as anything in rituals)
		if(choosen_ritual == ritual.name)
			if(ritual.pre_ritual_check(item, human))
				active_ui = FALSE
			break
			
	return

/datum/component/ritual_object/proc/get_available_rituals(mob/living/carbon/human/human)
	var/list/rituals_list = list()
	for(var/datum/ritual/ritual as anything in rituals)
		if(ritual.charges == 0)
			continue

		if(!COOLDOWN_FINISHED(ritual, ritual_cooldown))
			continue

		if(ritual.allowed_species && !is_type_in_list(human.dna.species, ritual.allowed_species))
			continue

		if(ritual.allowed_special_role && !is_type_in_list(human.mind?.special_role, ritual.allowed_special_role))
			continue

		LAZYADD(rituals_list, ritual.name)

	return rituals_list
