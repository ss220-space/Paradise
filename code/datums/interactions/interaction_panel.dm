GLOBAL_DATUM_INIT(interaction_panel, /datum/interaction_panel, new)

/datum/interaction_panel
	var/list/possible_interactions = list()

/datum/interaction_panel/New()
	for(var/type in valid_subtypesof(/datum/interaction))
		var/datum/interaction/interaction = new type
		possible_interactions[interaction.action] = interaction

/datum/interaction_panel/proc/register_mob(mob/target)
	if(!ishuman(target))
		return
	RegisterSignal(target, COMSIG_MOUSEDROP_ONTO, PROC_REF(on_mousedrop_onto))

/datum/interaction_panel/proc/unregister_mob(mob/target)
	UnregisterSignal(target, COMSIG_MOUSEDROP_ONTO)

/datum/interaction_panel/proc/on_mousedrop_onto(atom/source, atom/over, mob/living/carbon/human/user)
	SIGNAL_HANDLER
	if(over == user)
		return
	if(source != user)
		return
	if(!ishuman(over))
		return
	var/datum/weakref/over_ref = WEAKREF(over)
	if(user.partner == over_ref)
		return
	ui_close(user)
	user.partner = over_ref
	INVOKE_ASYNC(src, TYPE_PROC_REF(/datum, ui_interact), user)
	return COMPONENT_CANCEL_MOUSEDROP_ONTO

/datum/interaction_panel/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "Interactions")
		ui.open()

/datum/interaction_panel/ui_close(mob/living/carbon/human/user)
	user.partner = null
	return ..()

/datum/interaction_panel/ui_host(mob/living/carbon/human/user)
	return user.partner?.resolve()

/datum/interaction_panel/ui_state(mob/user)
	return GLOB.interaction_state

/datum/interaction_panel/ui_data(mob/user)
	var/list/data = list()
	var/mob/living/carbon/human/human_user = user
	var/mob/living/carbon/human/partner = human_user.partner?.resolve()

	if(!partner)
		data["partner"] = "Никто"
		data["interactions"] = list()
		return data

	var/list/cached_checks = new/list(2)
	cached_checks[1] = NONE
	cached_checks[2] = NONE

	data["partner"] = DECLENT_RU_CAP(partner, NOMINATIVE)
	var/list/interactions = list()
	for(var/key, value in possible_interactions)
		var/datum/interaction/interaction = value
		if(interaction.is_available(user, partner, cached_checks))
			interactions += list(list(
				"category" = interaction.category,
				"action" = interaction.action,
				"danger" = interaction.danger
			))
	data["interactions"] = interactions
	return data

/datum/interaction_panel/ui_act(action, params, datum/tgui/ui)
	if(..())
		return

	if(action != "interact")
		return

	var/key = params["interaction"]
	var/datum/interaction/interaction = possible_interactions[key]
	if(!interaction)
		return

	var/mob/living/carbon/human/user = ui.user
	var/mob/living/carbon/human/partner = user.partner?.resolve()

	if(!COOLDOWN_FINISHED(user, last_interract))
		return

	COOLDOWN_START(user, last_interract, 1 SECONDS)
	if(!interaction.is_available(user, partner))
		return

	interaction.execute(user, partner)
	return TRUE

