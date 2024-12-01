#define GENDER_NAME_UNKNOW list(MALE = "Незнакомец", FEMALE = "Незнакомка", NEUTER = "Неизвестный", PLURAL  = "Неизвестный")

//Новая система голоса
/datum/voice_model
	var/tts_seed_string = "Arthas"
	var/voice_gender = MALE
	var/voice_name = "Неизвестный"
	var/real_voice_name = "Неизвестный"

	var/list/famous_voices = list()
	//var/list/famous_faces = list()

/datum/voice_model/proc/CreateVoiceModel(var/atom/owner_voice)
	var/datum/voice_model/result = new()
	
	result.real_voice_name = owner_voice.GetVoice()
	result.voice_name = owner_voice.GetVoice()
	result.voice_gender = owner_voice.gender
	result.famous_voices[voice_name] = owner_voice.name
	result.tts_seed_string = owner_voice.tts_seed

	return result

/datum/voice_model/proc/VoiceUpdate(var/atom/owner_voice)
	 voice_name = owner_voice.GetVoice() //:badguy:

/datum/voice_model/proc/get_gender_unknown_name(gender_string)
	var/result = (GENDER_NAME_UNKNOW)?[gender_string]
	if(result)
		return result
	return "Неизвестный"

/datum/voice_model/proc/CopyInVoice(datum/voice_model/voice_to_copy)
	tts_seed_string = voice_to_copy.tts_seed_string
	voice_gender = voice_to_copy.voice_gender
	voice_name = voice_to_copy.voice_name

/datum/voice_model/proc/FullCopyInVoice(datum/voice_model/voice_to_copy)
	CopyInVoice(voice_to_copy)
	real_voice_name = voice_to_copy.real_voice_name
	famous_voices = voice_to_copy.famous_voices

//было две бутылки, словарь или два прока. Я сел на вторую
/datum/voice_model/proc/GetManifestKnowVoice()
	for(var/datum/data/record/t in GLOB.data_core.general)
		if(t)
			if(t.fields["voice"] == voice_name)
				return t.fields["name"]
	return "IDENTIFICATION VOICE ERROR"
//Технически name это представление твоего ебала
/* BYOND...
/datum/voice_model/proc/GetManifestKnowFace(mob/face_target)
	for(var/datum/data/record/t in GLOB.data_core.general)
		if(t)
			if(t.fields["name"] == face_target.name)
				return t.fields["name"]
	return "IDENTIFICATION FACE ERROR"
*/

/datum/voice_model/proc/TryStore(mob/target)
	if(src == target.adv_voice)
		return TRUE
	. = FALSE
	if(!ishuman(target)) //Нахуя мне знать как зовут мышей :badguy:
		return target.name
	var/mob/living/carbon/human/target_H = target
	var/obj/item/card/id/prov_wear_id = null

	if(isIdCard(target_H.wear_id)) //Fuck
		prov_wear_id = target_H.wear_id
	if(isWallet(target_H.wear_id)) //Мфпмфпф
		var/obj/item/storage/wallet/prom = target_H.wear_id
		prov_wear_id = prom.front_id

	if(!((target_H.wear_mask?.flags_inv & HIDENAME) || (target_H.head?.flags_inv & HIDENAME)) && prov_wear_id)

		//famous_faces[target_H.name] = prov_wear_id.registered_name //FUCK BYOND
		famous_voices[target_H.adv_voice.voice_name] = prov_wear_id.registered_name
		. = TRUE
	else if(prov_wear_id)
		famous_voices[target_H.adv_voice.voice_name] = prov_wear_id.registered_name
		. = TRUE
	return

//For examie
/* FUCKING BYOND
/datum/voice_model/proc/TryRecollectFace(mob/target)
	if(src == target.adv_voice)
		return target.name
	if(!ishuman(target)) //:Roflcat: Чтобы имена мышей знать сразу
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
/datum/voice_model/proc/TryRecollectVoice(mob/target)
	if(src == target.adv_voice)
		return target.adv_voice.voice_name
	if(!ishuman(target))
		return target.adv_voice.voice_name
	var/mob/living/carbon/human/target_H = target

	. = famous_voices?[target_H.name]
	if(.)
		return

	return get_gender_unknown_name(target_H.adv_voice.voice_gender)

#undef GENDER_NAME_UNKNOW
