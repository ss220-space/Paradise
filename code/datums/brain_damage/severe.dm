/datum/brain_trauma/severe
	abstract_type = /datum/brain_trauma/severe
	resilience = TRAUMA_RESILIENCE_SURGERY

//This one is for "The First Desire" or /obj/structure/sign/painting/eldritch/desire
/datum/brain_trauma/severe/flesh_desire
	name = "Расстройство Бина"
	desc = "У пациента наблюдается зацикленность на потреблении сырого мяса, особенно того же вида. Пациент также страдает от психосоматических приступов голода."
	scan_desc = "умеренное расстройство пищевого поведения"
	gain_text = span_warning("Вам сильно хочется есть... Есть органы и сырое мясо...")
	lose_text = span_notice("Ваши вкусовые предпочтения вернулись в норму.")
	random_gain = FALSE
	/// How much faster we loose hunger
	var/hunger_rate = 15

/datum/brain_trauma/severe/flesh_desire/on_gain()
	// Allows them to eat faster, mainly for flavor
	ADD_TRAIT(owner, TRAIT_FLESH_DESIRE, UID())
	return ..()

/datum/brain_trauma/severe/flesh_desire/on_life(seconds_per_tick, times_fired)
	// Causes them to need to eat at 10x the normal rate
	owner.adjust_nutrition(-hunger_rate * HUNGER_FACTOR)
	if(SPT_PROB(10, seconds_per_tick))
		to_chat(owner, span_notice(pick("Вы не можете перестать думать о сыром мясе...", "Вам **НУЖНО** съесть кого-нибудь.", "Муки голода вернулись...", "Вы жаждете плоти.", "Вы голодны!")))

	owner.overeatduration = max(owner.overeatduration - 200 SECONDS, 0)

/datum/brain_trauma/severe/flesh_desire/on_lose()
	REMOVE_TRAIT(owner, TRAIT_FLESH_DESIRE, UID())
	return ..()
