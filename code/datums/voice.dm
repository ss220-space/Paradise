#define GENDER_NAME_UNKNOWN  list(MALE = "Незнакомец", FEMALE = "Незнакомка", NEUTER = "Неизвестный", PLURAL  = "Неизвестный")
//Voice cumponent
/datum/component/voice_model
	var/mob/host = null
	var/tts_seed_string = "Arthas"
	var/voice_gender = MALE
	var/voice_name = "Неизвестный"
	var/real_voice_name = "Неизвестный"

	var/list/famous_voices = list()
	var/list/famous_faces = list()

/datum/component/voice_model/Initialize()
	if(!ismob(parent))
		return COMPONENT_INCOMPATIBLE //GET OUT

	var/mob/owner_voice = parent
	host = owner_voice
	real_voice_name = owner_voice.GetVoice()
	voice_name = owner_voice.GetVoice()
	voice_gender = owner_voice.gender
	famous_voices[voice_name] = owner_voice.name
	tts_seed_string = owner_voice.tts_seed

/datum/component/voice_model/RegisterWithParent()
	if(SSjobs.GetJob(host.job))
		RegisterSignal(SSdcs, COMSIG_SPECIAL_MASS_STORE_VOICE, PROC_REF(special_mass_add_voice))
		RegisterSignal(SSdcs, COMSIG_DATACORE_VOICE_COLLEAGUE_INJECT, PROC_REF(special_mass_add_voice))
		RegisterSignal(SSdcs, COMSIG_RENAME_VOICE_INJECT, PROC_REF(special_mass_add_voice))
		
	RegisterSignal(parent, COMSIG_MOB_RUN_EXAMINATE, PROC_REF(try_store))
	RegisterSignal(parent, COMSIG_VOICE_UPDATE, PROC_REF(voice_update))

/datum/component/voice_model/UnregisterFromParent()
	UnregisterSignal(SSdcs, COMSIG_SPECIAL_MASS_STORE_VOICE)
	UnregisterSignal(SSdcs, COMSIG_DATACORE_VOICE_COLLEAGUE_INJECT)
	UnregisterSignal(SSdcs, COMSIG_RENAME_VOICE_INJECT)
	UnregisterSignal(parent, COMSIG_MOB_RUN_EXAMINATE)
	UnregisterSignal(parent, COMSIG_VOICE_UPDATE)

/datum/component/voice_model/proc/special_mass_add_voice(suka, list/list_voice)
	SIGNAL_HANDLER
	UnregisterSignal(SSdcs, COMSIG_DATACORE_VOICE_COLLEAGUE_INJECT)

	var/datum/job/prom_job = SSjobs.GetJob(host.job) //WARNING. Fuking byond
	var/list/prom_data = list_voice?[prom_job.department]

	if(prom_data)
		LAZYOR(famous_voices, prom_data)  

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

/datum/component/voice_model/proc/get_manifest_know_voice()
	for(var/datum/data/record/t in GLOB.data_core.general)
		if(t)
			if(t.fields["voice"] == voice_name)
				return t.fields["name"]
	return "IDENTIFICATION ERROR"

/* not used
/datum/component/voice_model/proc/GetManifestKnowFace(mob/face_target)
	for(var/datum/data/record/t in GLOB.data_core.general)
		if(t)
			if(t.fields["name"] == face_target.name)
				return t.fields["name"]
	return "IDENTIFICATION FACE ERROR"
*/
/datum/component/voice_model/proc/try_store(mob/source, mob/target)
	SIGNAL_HANDLER
	if(target == source)
		return FALSE
	var/datum/component/voice_model/adv_voice = target.GetComponent(/datum/component/voice_model)
	if(isnull(adv_voice))
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
		//famous_faces[target_H.name] = prov_wear_id.registered_name
		famous_voices[adv_voice.voice_name] = prov_wear_id.registered_name
		. = TRUE
	else if(prov_wear_id)
		famous_voices[adv_voice.voice_name] = prov_wear_id.registered_name
		. = TRUE
	return

//For examie
// FUCKING BYOND
/* NOT USED
/datum/component/voice_model/proc/TryRecollectFace(mob/target)
	if(src == target.adv_voice)
		return target.name
	if(!ishuman(target)) //:Roflcat:
		return target.name
	var/mob/living/carbon/human/target_H = target

	if(!((target_H.wear_mask?.flags_inv & HIDENAME) || (target_H.head?.flags_inv & HIDENAME)))
		. = famous_faces?[target_H.name]

	if(.)
		return

	if((target_H.wear_suit?.flags_inv & HIDEJUMPSUIT) && (target_H.head?.flags_inv & HIDENAME))
		. = get_gender_unknown_name(NEUTER)
	else
		. = get_gender_unknown_name(target_H.gender)
	return
*/
//For hear
/datum/component/voice_model/proc/try_recollect_voice(mob/target)
	if(!ishuman(host))
		return target.name
	if(host.mind.special_role_meta_know && (target.mind.special_role == host.mind.special_role))
		return target.name
	
	if(host == target)
		return target.name
	if(!ishuman(target))
		return target.name
	var/datum/component/voice_model/adv_voice = target.GetComponent(/datum/component/voice_model)

	if(famous_voices?[adv_voice.voice_name])
		return

	return get_gender_unknown_name(adv_voice.voice_gender)
can_remember_voice
/datum/component/voice_model/proc/can_remember_voice(mob/target)
	var/datum/component/voice_model/adv_voice = target.GetComponent(/datum/component/voice_model)

	if(famous_voices?[adv_voice.voice_name])
		return TRUE
	return FALSE

//HELPERS 
/proc/GenDepartamentVoiceTree(mob/target, list/departments)
	var/list/result = list()
	
	for(var/dep_flag in departments)
		var/datum/component/voice_model/adv_voice = target.GetComponent(/datum/component/voice_model)
		result[dep_flag] = list(adv_voice.voice_name = target.name)
		
	return result

/proc/get_gender_unknown_name(gender_string)
	var/result = (GENDER_NAME_UNKNOWN)?[gender_string]
	if(result)
		return result
	return "Неизвестный"

#undef GENDER_NAME_UNKNOWN
