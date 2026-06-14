/**********************************
*******Interactions code by HONKERTRON feat TestUnit********
***********************************/

/mob/living/carbon/human/proc/interact_by_mouse_drop_dragged(mob/M, mob/user)
	if(ishuman(M) && user != M && src != M)
		partner = M
		var/datum/interactions/tgui = new /datum/interactions
		tgui.owner = src
		tgui.ui_interact(src)

/mob/living/carbon/human/mouse_drop_dragged(atom/over_object, mob/user, src_location, over_location, params)
	if(src != user)
		return
	interact_by_mouse_drop_dragged(over_object, user)

//Distant interactions
/mob/living/carbon/human/verb/interact()
	set name = "Взаимодействовать"
	set category = VERB_CATEGORY_IC

	var/list/targets = list()
	for(var/mob/living/carbon/human/human in view(src))
		if(human != src)
			targets[human.name] = human

	if(!length(targets))
		return

	var/choice = tgui_input_list(src, "Доступные цели:", "Выберите цель для взаимодействия", targets)
	var/mob/living/carbon/human/M = targets[choice]

	if(!M || QDELETED(M) || !(M in view(src)))
		return

	if(ishuman(M) && usr != M && src != M)
		partner = M
		var/datum/interactions/tgui = new /datum/interactions
		tgui.owner = src
		tgui.ui_interact(src)

/mob/living/carbon/human/proc/is_nude()
	return (!wear_suit && !w_uniform) ? TRUE : FALSE //TODO: Nudity check for underwear

/datum/interactions
	var/mob/living/carbon/human/owner

/datum/interactions/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "Interactions")
		ui.open()

/datum/interactions/ui_data(mob/user)
	var/list/data = list()
	var/mob/living/carbon/human/H = user
	var/mob/living/carbon/human/P = H.partner

	if(!P)
		data["partner"] = "Никто"
		data["interactions"] = list()
		return data

	data["partner"] = "[P]"

	var/list/interactions = list()
	for(var/datum/interaction/I in GLOB.interaction_entries)
		if(I.is_available(H, P))
			interactions += list(list(
				"category" = I.category,
				"action" = I.action,
				"label" = I.label,
				"danger" = I.danger
			))
	data["interactions"] = interactions
	return data

/datum/interactions/ui_act(action, params, datum/tgui/ui)
	if(..())
		return

	if(ui.user.incapacitated())
		return

	var/mob/living/carbon/human/H = ui.user
	var/mob/living/carbon/human/P = H.partner
	if(!(P in view(H.loc)))
		return

	if(world.time <= H.last_interact + 1 SECONDS)
		return

	H.last_interact = world.time

	for(var/datum/interaction/I in GLOB.interaction_entries)
		if(I.action == action && I.is_available(H, P))
			I.execute(H, P)
			H.update_icon()
			return TRUE


/datum/ui_state/interaction_state

/datum/ui_state/interaction_state/can_use_topic(src_object, mob/user, atom/ui_source)
	var/datum/interactions/inter_datum = src_object
	if(!istype(inter_datum))
		return UI_CLOSE

	var/mob/living/carbon/human/H = user
	if(!istype(H) || H != inter_datum.owner)
		return UI_CLOSE

	. = H.shared_ui_interaction()
	if(. <= UI_CLOSE)
		return .

	var/mob/living/carbon/human/P = H.partner
	if(QDELETED(P) || !(P in view(H.loc)))
		return UI_CLOSE

	// if(HAS_TRAIT(H, TRAIT_HANDS_BLOCKED))
	// 	return UI_UPDATE

	return UI_INTERACTIVE

GLOBAL_DATUM_INIT(interaction_state, /datum/ui_state/interaction_state, new)

/datum/interactions/ui_state(mob/user)
	return GLOB.interaction_state
