/datum/brain_trauma
	abstract_type = /datum/brain_trauma
	var/name = "Brain Trauma"
	var/desc = "Повреждение мозга, вызывающее у пациента проблемы."
	var/scan_desc = "неопределённая травма мозга"
	var/mob/living/carbon/owner
	var/obj/item/organ/internal/brain/brain
	var/gain_text = span_notice_alt("Вы чувствуете себя травмированным.")
	var/lose_text = span_notice_alt("Травма больше не беспокоит вас.")
	var/can_gain = TRUE
	var/random_gain = TRUE
	var/resilience = TRAUMA_RESILIENCE_BASIC
	var/known_trauma = TRUE

/datum/brain_trauma/Destroy()
	brain?.remove_trauma_from_traumas(src)
	if(owner)
		log_game("[key_name(owner)] has lost the following brain trauma: [type]")
		on_lose()
		owner = null
	return ..()

/datum/brain_trauma/proc/on_gain()
	SHOULD_CALL_PARENT(TRUE)
	if(gain_text)
		to_chat(owner, gain_text)
	RegisterSignal(owner, COMSIG_MOB_SAY, PROC_REF(handle_speech))
	RegisterSignal(owner, COMSIG_MOVABLE_HEAR, PROC_REF(handle_hearing))
	return TRUE

/datum/brain_trauma/proc/on_lose(silent)
	SHOULD_CALL_PARENT(TRUE)
	if(!silent && lose_text)
		to_chat(owner, lose_text)
	UnregisterSignal(owner, list(COMSIG_MOB_SAY, COMSIG_MOVABLE_HEAR))

/datum/brain_trauma/proc/on_life(seconds)
	return

/datum/brain_trauma/proc/on_death()
	return

/datum/brain_trauma/proc/handle_speech(datum/source, list/speech_args)
	SIGNAL_HANDLER
	UnregisterSignal(owner, COMSIG_MOB_SAY)

/datum/brain_trauma/proc/handle_hearing(datum/source, mob/speaker, list/message_pieces)
	SIGNAL_HANDLER
	UnregisterSignal(owner, COMSIG_MOVABLE_HEAR)
