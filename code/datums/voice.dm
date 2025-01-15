#define GENDER_NAME_UNKNOWN  list(MALE = "Неизвестный", FEMALE = "Неизвестная", NEUTER = "Неизвестное", PLURAL  = "Неизвестные")
#define MANIFEST_UNKNOWNS list("Неизвестный", "Неизвестная", "Неизвестное", "Неизвестные")
//Voice cumponent
/datum/component/voice_model
	var/mob/host = null
	var/tts_seed_string = "Arthas"
	var/voice_gender = MALE
	var/voice_name = "Неизвестный"
	var/real_voice_name = "Неизвестный"

	var/list/known_voices = list()
	var/list/known_faces = list()

/datum/component/voice_model/Initialize()
	if(!ismob(parent))
		return COMPONENT_INCOMPATIBLE //GET OUT

	var/mob/owner_voice = parent
	host = owner_voice
	real_voice_name = owner_voice.GetVoice()
	voice_name = owner_voice.GetVoice()
	voice_gender = owner_voice.gender
	known_voices[voice_name] = owner_voice.name
	tts_seed_string = owner_voice.tts_seed

/datum/component/voice_model/RegisterWithParent()
	RegisterSignal(SSdcs, COMSIG_SPECIAL_MASS_STORE_VOICE, PROC_REF(special_mass_add_voice))
	RegisterSignal(SSdcs, COMSIG_DATACORE_VOICE_COLLEAGUE_INJECT, PROC_REF(special_mass_add_voice))
	RegisterSignal(SSdcs, COMSIG_RENAME_VOICE_INJECT, PROC_REF(special_mass_add_voice))
		
	RegisterSignal(parent, COMSIG_MOB_RUN_EXAMINATE, PROC_REF(try_store))
	RegisterSignal(parent, COMSIG_VOICE_UPDATE, PROC_REF(voice_update))
	RegisterSignal(parent, COMSIG_GET_VOICE_NAME, PROC_REF(get_voice_name))
	RegisterSignal(parent, COMSIG_GET_VOICE_GENDER, PROC_REF(get_voice_gender))
	RegisterSignal(parent, COMSIG_TRY_RECOLLECT_VOICE, PROC_REF(try_recollect_voice))
	RegisterSignal(parent, COMSIG_CAN_REMEMBER_VOICE, PROC_REF(can_remember_voice))
	RegisterSignal(parent, COMSIG_GET_MANIFEST_KWON_VOICE, PROC_REF(get_manifest_know_voice))
	

/datum/component/voice_model/UnregisterFromParent()
	UnregisterSignal(SSdcs, COMSIG_SPECIAL_MASS_STORE_VOICE)
	UnregisterSignal(SSdcs, COMSIG_DATACORE_VOICE_COLLEAGUE_INJECT)
	UnregisterSignal(SSdcs, COMSIG_RENAME_VOICE_INJECT)
	UnregisterSignal(parent, COMSIG_MOB_RUN_EXAMINATE)
	UnregisterSignal(parent, COMSIG_VOICE_UPDATE)
	UnregisterSignal(parent, COMSIG_GET_VOICE_NAME)
	UnregisterSignal(parent, COMSIG_TRY_RECOLLECT_VOICE)
	UnregisterSignal(parent, COMSIG_GET_VOICE_GENDER)
	UnregisterSignal(parent, COMSIG_CAN_REMEMBER_VOICE)
	UnregisterSignal(parent, COMSIG_GET_MANIFEST_KWON_VOICE)

/datum/component/voice_model/proc/special_mass_add_voice(source, list/list_voice)
	SIGNAL_HANDLER
	UnregisterSignal(SSdcs, COMSIG_DATACORE_VOICE_COLLEAGUE_INJECT)
	var/datum/job/prom_job = SSjobs.GetJob(host.job)
	if(prom_job)
		var/list/prom_data = list_voice?[prom_job.department]

		if(prom_data)
			LAZYOR(known_voices, prom_data)  

/datum/component/voice_model/proc/voice_update(mob/source)
	SIGNAL_HANDLER
	voice_name = host.GetVoice()
	voice_gender = host.gender
	tts_seed_string = host.tts_seed

/* Not used
/datum/voice_model/proc/CopyInVoice(datum/voice_model/voice_to_copy)
	tts_seed_string = voice_to_copy.tts_seed_string
	voice_gender = voice_to_copy.voice_gender
	voice_name = voice_to_copy.voice_name

/datum/voice_model/proc/FullCopyInVoice(datum/voice_model/voice_to_copy)
	CopyInVoice(voice_to_copy)
	real_voice_name = voice_to_copy.real_voice_name
	famous_voices = voice_to_copy.famous_voices
*/

/datum/component/voice_model/proc/get_manifest_know_voice(mob/source, returned)
	SIGNAL_HANDLER
	*returned = "IDENTIFICATION ERROR"
	for(var/datum/data/record/t in GLOB.data_core.general)
		if(t)
			if(t.fields["voice"] == voice_name)
				*returned = t.fields["name"]
				break

/* Not used
/datum/component/voice_model/proc/GetManifestKnowFace(mob/face_target)
	for(var/datum/data/record/t in GLOB.data_core.general)
		if(t)
			if(t.fields["name"] == face_target.name)
				return t.fields["name"]
	return "IDENTIFICATION FACE ERROR"
*/

/datum/component/voice_model/proc/get_voice_name(mob/source, name)
	SIGNAL_HANDLER
	*name = voice_name

/datum/component/voice_model/proc/get_voice_gender(mob/source, target_gender)
	SIGNAL_HANDLER
	*target_gender = voice_gender

/datum/component/voice_model/proc/try_store(mob/source, mob/target)
	SIGNAL_HANDLER
	if(target == source)
		return FALSE
	var/speaker_name = get_gender_unknown_name(target.gender)
	SEND_SIGNAL(target, COMSIG_GET_VOICE_NAME, &speaker_name)

	if(speaker_name in MANIFEST_UNKNOWNS)
		return FALSE
		
	. = FALSE
	if(!ishuman(target))
		return target.name
	var/mob/living/carbon/human/target_H = target
	var/obj/item/card/id/prov_wear_id = null

	if(isidcard(target_H.wear_id))
		prov_wear_id = target_H.wear_id
	if(iswallet(target_H.wear_id))
		var/obj/item/storage/wallet/prom = target_H.wear_id
		prov_wear_id = prom.front_id

	if(!((target_H.wear_mask?.flags_inv & HIDENAME) || (target_H.head?.flags_inv & HIDENAME)) && prov_wear_id)
		//known_faces[target_H.name] = prov_wear_id.registered_name
		known_voices[speaker_name] = prov_wear_id.registered_name
		. = TRUE
	else if(prov_wear_id)
		known_voices[speaker_name] = prov_wear_id.registered_name
		. = TRUE
	return

/* Not used
/datum/component/voice_model/proc/TryRecollectFace(mob/target)
	if(src == target.adv_voice)
		return target.name
	if(!ishuman(target)) //:Roflcat:
		return target.name
	var/mob/living/carbon/human/target_H = target

	if(!((target_H.wear_mask?.flags_inv & HIDENAME) || (target_H.head?.flags_inv & HIDENAME)))
		. = known_faces?[target_H.name]

	if(.)
		return

	if((target_H.wear_suit?.flags_inv & HIDEJUMPSUIT) && (target_H.head?.flags_inv & HIDENAME))
		. = get_gender_unknown_name(NEUTER)
	else
		. = get_gender_unknown_name(target_H.gender)
	return
*/

//For hear
/datum/component/voice_model/proc/try_recollect_voice(mob/source, mob/target, returned_name)
	SIGNAL_HANDLER
	var/target_gender = NEUTER
	SEND_SIGNAL(target, COMSIG_GET_VOICE_GENDER, &target_gender)
	*returned_name = get_gender_unknown_name(target_gender)

	if(!ishuman(host))
		*returned_name = target.name
		return
	if(host.mind.special_role_meta_know && ((target.mind.special_role) == (host.mind.special_role)))
		*returned_name =  target.name
		return
	
	if(host == target)
		*returned_name = target.name
		return
	if(!ishuman(target))
		*returned_name = target.name
		return
	var/speaker_name = get_gender_unknown_name(target.gender)
	SEND_SIGNAL(target, COMSIG_GET_VOICE_NAME, &speaker_name)
	. = known_voices?[speaker_name]
	if(.)
		*returned_name = .

/datum/component/voice_model/proc/can_remember_voice(mob/source, mob/target, returned_param)
	SIGNAL_HANDLER
	var/speaker_name = get_gender_unknown_name(target.gender)
	SEND_SIGNAL(target, COMSIG_GET_VOICE_NAME, &speaker_name)
	if(known_voices?[speaker_name])
		*returned_param = TRUE
	else
		*returned_param = FALSE

//HELPERS 
/proc/gen_departament_voice_tree(mob/target, list/departments)
	var/list/result = list()
	var/speaker_name
	speaker_name = get_gender_unknown_name(target.gender)
	SEND_SIGNAL(target, COMSIG_GET_VOICE_NAME, &(speaker_name))
	for(var/dep_flag in departments)
		result[dep_flag] = list((speaker_name) = (target.name))
		
	return result

/proc/get_gender_unknown_name(gender_string)
	var/result = (GENDER_NAME_UNKNOWN)?[gender_string]
	if(result)
		return result
	return "Неизвестный"

#undef GENDER_NAME_UNKNOWN
