/datum/action/cooldown/spell/view_range
	name = "Дальний взор"
	desc = "Ваша награда за продажу души."

	invocation_type = INVOCATION_WHISPER
	invocation = "Da mihi divinum aspectum"
	school = SCHOOL_PSYCHIC
	spell_requirements = SPELL_REQUIRES_NO_ANTIMAGIC
	cooldown_time = 5 SECONDS
	button_icon_state = "camera_jump"
	/// Currently selected view range
	var/selected_view = "default"
	/// View ranges to apply
	var/static/list/view_ranges = list(
		"default",
		"17x17",
		"19x19",
		"21x21",
	)

/datum/action/cooldown/spell/view_range/Destroy(force)
	UnregisterSignal(owner, COMSIG_LIVING_DEATH)
	if(selected_view == "default" || QDELETED(owner) || !owner.client)
		return ..()
	INVOKE_ASYNC(owner.client?.view_size, TYPE_PROC_REF(/datum/view_data, resetToDefault))
	return ..()

/datum/action/cooldown/spell/view_range/proc/make_view_normal(mob/user)
	SIGNAL_HANDLER
	if(!QDELETED(user) && user.client)
		INVOKE_ASYNC(user.client.view_size, TYPE_PROC_REF(/datum/view_data, resetToDefault))

/datum/action/cooldown/spell/view_range/can_cast_spell(feedback)
	if(!owner.client)
		return FALSE
	return ..()

/datum/action/cooldown/spell/view_range/Grant(mob/grant_to)
	. = ..()
	RegisterSignal(grant_to, COMSIG_LIVING_DEATH, PROC_REF(make_view_normal))

/datum/action/cooldown/spell/view_range/cast(atom/cast_on)
	. = ..()
	if(!ismob(cast_on))
		return
	var/mob/user = cast_on
	var/new_view = tgui_input_list(user, "Выберите область видимости:", "Видимость", view_ranges, "default")
	if(isnull(new_view) || !user.client)
		return
	if(new_view == "default")
		user.client.view_size.resetToDefault()
		return
	selected_view = new_view
	user.client.view_size.setTo(new_view)

/datum/action/cooldown/spell/view_range/genetic
	desc = "Позволяет вам выбрать, как далеко вы будете видеть."
	invocation = null
