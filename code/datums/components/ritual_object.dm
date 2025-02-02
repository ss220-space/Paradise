/datum/component/ritual_object
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
	/// Temporary lists of invokers/Used things in rituals.
	var/list/used_things
	var/list/invokers
	/// Cached selected ritual.
	var/datum/ritual/ritual

/datum/component/ritual_object/Destroy(force)
	LAZYNULL(rituals)
	LAZYNULL(allowed_categories)
	LAZYNULL(allowed_species)
	LAZYNULL(allowed_special_role)
	LAZYNULL(invokers)
	LAZYNULL(used_things)
	ritual = null

	return ..()

/datum/component/ritual_object/Initialize(
	allowed_categories = /datum/ritual,
	list/allowed_species,
	list/allowed_special_role
)

	if(!isobj(parent))
		return COMPONENT_INCOMPATIBLE

	src.allowed_categories = allowed_categories
	src.allowed_species = allowed_species
	src.allowed_special_role = allowed_special_role

	get_rituals()

/datum/component/ritual_object/RegisterWithParent()
	RegisterSignal(parent, COMSIG_ATOM_ATTACK_HAND, PROC_REF(attackby))

/datum/component/ritual_object/UnregisterFromParent()
	UnregisterSignal(parent, COMSIG_ATOM_ATTACK_HAND)

/datum/component/ritual_object/proc/get_rituals() // We'll get all rituals for flexibility.
	LAZYCLEARLIST(rituals)

	for(var/datum/ritual/ritual as anything in typecacheof(allowed_categories))
		if(!ritual.name)
			continue

		rituals += new ritual

	for(var/datum/ritual/ritual as anything in rituals)
		ritual.ritual_object = parent

	return

/datum/component/ritual_object/proc/attackby(datum/source, mob/living/carbon/human/human)
	SIGNAL_HANDLER

	if(active_ui)
		return

	if(!istype(human))
		return

	if(allowed_species && !is_type_in_list(human.dna.species, allowed_species))
		return

	if(allowed_special_role && !LAZYIN(allowed_special_role, human.mind?.special_role))
		return

	active_ui = TRUE
	INVOKE_ASYNC(src, PROC_REF(open_ritual_ui), human)

	return COMPONENT_CANCEL_ATTACK_CHAIN

/datum/component/ritual_object/proc/open_ritual_ui(mob/living/carbon/human/human)
	var/list/rituals_list = get_available_rituals(human)

	if(!LAZYLEN(rituals_list))
		active_ui = FALSE
		to_chat(human, "Не имеется доступных для выполнения ритуалов.")
		return

	ui_interact(human)
	return


/datum/component/ritual_object/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		// Open UI
		ui = new(user, src, "RitualMenu")
		ui.open()

/datum/component/ritual_object/ui_data(mob/user)
	var/list/data = list()
	data["rituals"] = get_available_rituals(user)
	data["selected_ritual"] = ritual?.name
	if(ritual)
		if(ritual.description)
			data["description"] = ritual.description
		var/list/params = ritual.get_ui_params()
		if(params?.len)
			data["params"] = params
		var/list/things = ritual.get_ui_things()
		if(things?.len)
			data["things"] = things
		data["ritual_available"] = COOLDOWN_FINISHED(ritual, ritual_cooldown)
		data["time_left"] = round(COOLDOWN_TIMELEFT(ritual, ritual_cooldown) / (1 SECONDS))

	return data

/datum/component/ritual_object/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	. = ..()
	if(.)
		return
	switch(action)
		if("select_ritual")
			handle_ritual_selection(ui.user, params["selected_ritual"])
			. = TRUE

		if("start_ritual")
			var/ritual_status = pre_ritual_check(ui.user)
			if(ritual_status)
				active_ui = FALSE
			. = TRUE

/datum/component/ritual_object/ui_close(mob/user)
	. = ..()
	active_ui = FALSE

/datum/component/ritual_object/proc/handle_ritual_selection(mob/living/carbon/human/human, choosen_ritual)
	if(!choosen_ritual)
		active_ui = FALSE
		return

	for(var/datum/ritual/ritual as anything in rituals)
		if(choosen_ritual != ritual.name)
			continue
		src.ritual = ritual
		break

	return TRUE

/datum/component/ritual_object/proc/pre_ritual_check(mob/living/carbon/human/invoker)
	var/failed = FALSE
	var/cause_disaster = FALSE
	var/del_things = FALSE
	var/start_cooldown = FALSE
	var/remove_charge = FALSE
	var/message

	ritual.handle_ritual_object(RITUAL_STARTED)

	. = ritual_invoke_check(invoker)
	SEND_SIGNAL(ritual, COMSIG_RITUAL_ENDED, ., invoker, invokers, used_things)

	if(!(. & RITUAL_SUCCESSFUL))
		failed = TRUE
		message = "ритуал провален!"

	if(. & RITUAL_SUCCESSFUL)
		message = "ритуал проведён успешно!"
		addtimer(CALLBACK(ritual, TYPE_PROC_REF(/datum/ritual, handle_ritual_object), RITUAL_ENDED), 1 SECONDS)
		remove_charge = TRUE
		start_cooldown = TRUE

	if(. & RITUAL_FAILED_ON_PROCEED)
		cause_disaster = TRUE
		start_cooldown = TRUE

	if(start_cooldown)
		COOLDOWN_START(ritual, ritual_cooldown, ritual.cooldown_after_cast)

	if(cause_disaster && prob(ritual.disaster_prob))
		ritual.disaster(invoker, invokers, used_things)

	if((. & RITUAL_SUCCESSFUL) && (ritual.ritual_should_del_things))
		del_things = TRUE

	if((. & RITUAL_FAILED_ON_PROCEED) && (ritual.ritual_should_del_things_on_fail))
		del_things = TRUE

	if(del_things)
		ritual.del_things(used_things)

	if(remove_charge)
		ritual.charges--

	if(failed)
		addtimer(CALLBACK(ritual, TYPE_PROC_REF(/datum/ritual, handle_ritual_object), RITUAL_FAILED), 2 SECONDS)

	if(message)
		var/atom/atom = parent
		atom.balloon_alert(invoker, message)

	for(var/atom/movable/atom as anything in used_things)
		UnregisterSignal(atom, COMSIG_MOVABLE_MOVED)

	LAZYNULL(invokers)
	LAZYNULL(used_things)
	ritual = null

	return .

/datum/component/ritual_object/proc/ritual_invoke_check(mob/living/carbon/human/invoker)
	if(!check_invokers(invoker))
		return RITUAL_FAILED_MISSED_INVOKER_REQUIREMENTS

	if(!check_contents(invoker))
		return RITUAL_FAILED_MISSED_REQUIREMENTS

	if(prob(ritual.fail_chance))
		return RITUAL_FAILED_ON_PROCEED

	if(ritual.cast_time)
		for(var/atom/movable/atom as anything in used_things)
			RegisterSignal(atom, COMSIG_MOVABLE_MOVED, PROC_REF(track_atoms))

		if(!cast())
			return RITUAL_FAILED_ON_PROCEED

	return ritual.do_ritual(invoker, invokers, used_things)

/datum/component/ritual_object/proc/track_atoms(
	atom/source,
	atom/old_loc,
	movement_dir,
	forced,
	atom/old_locs,
	momentum_change
)
	SIGNAL_HANDLER

	INVOKE_ASYNC(src, PROC_REF(cast))
	UnregisterSignal(source, COMSIG_MOVABLE_MOVED)

/datum/component/ritual_object/proc/check_invokers(mob/living/carbon/human/invoker)
	if(!ritual.extra_invokers)
		return ritual.check_invokers(invoker, list(invoker)) // remember about checks on invoker in rituals

	for(var/atom/atom in range(ritual.finding_range, parent))
		if(!ritual.is_valid_invoker(atom))
			continue

		LAZYADD(invokers, atom)

	if(LAZYLEN(invokers) < (ritual.extra_invokers + 1))
		var/atom/atom = parent
		atom.balloon_alert(invoker, "требуется больше участников!")
		return FALSE

	return ritual.check_invokers(invoker, invokers)

/datum/component/ritual_object/proc/check_contents(mob/living/carbon/human/invoker)
	if(!ritual.required_things)
		return TRUE

	var/list/atom/movable/atoms = list()

	for(var/atom/movable/obj in range(ritual.finding_range, parent))
		if(isitem(obj))
			var/obj/item/close_item = obj
			if(close_item.item_flags & ABSTRACT)
				continue

		if(obj.invisibility)
			continue

		if(obj == parent)
			continue

		if(LAZYIN(invokers, obj))
			continue

		LAZYADD(atoms, obj)

	var/list/requirements = ritual.required_things.Copy()
	for(var/atom/atom as anything in atoms)
		for(var/req_type in requirements)
			if(requirements[req_type] <= 0)
				continue

			if(!istype(atom, req_type))
				continue

			LAZYADD(used_things, atom)

			if(isstack(atom))
				var/obj/item/stack/picked_stack = atom
				requirements[req_type] -= picked_stack.amount
			else
				requirements[req_type]--

	var/list/what_are_we_missing = list()
	for(var/req_type in requirements)
		var/number_of_things = requirements[req_type]

		if(number_of_things <= 0)
			continue

		LAZYADD(what_are_we_missing, req_type)

	if(LAZYLEN(what_are_we_missing))
		var/atom/atom = parent
		atom.balloon_alert(invoker, "требуется больше компонентов!")
		return FALSE

	return ritual.check_contents(invoker, used_things)

/datum/component/ritual_object/proc/cast()
	for(var/mob/living/carbon/human/human in invokers)
		if(!do_after(human, ritual.cast_time, parent, DA_IGNORE_HELD_ITEM, max_interact_count = 1))
			return FALSE

	return TRUE

/datum/component/ritual_object/proc/get_available_rituals(mob/living/carbon/human/human)
	var/list/rituals_list = list()

	for(var/datum/ritual/ritual as anything in rituals)
		if(ritual.charges == 0)
			continue

		if(!COOLDOWN_FINISHED(ritual, ritual_cooldown))
			continue

		if(ritual.allowed_species && !is_type_in_list(human.dna.species, ritual.allowed_species))
			continue

		if(ritual.allowed_special_role && !LAZYIN(ritual.allowed_special_role, human.mind?.special_role))
			continue

		LAZYADD(rituals_list, ritual.name)

	return rituals_list
