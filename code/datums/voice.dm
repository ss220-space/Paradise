#define GENDER_NAME_UNKNOW list(MALE = "Незнакомец", FEMALE = "Незнакомка", NEUTER = "Неизвестный", PLURAL  = "Неизвестный")
//Новая система голоса
/datum/voice_model
	var/mob/host = null //Носитель этой хуеты
	var/tts_seed_string = "Arthas"
	var/voice_gender = MALE
	var/voice_name = "Неизвестный"
	var/real_voice_name = "Неизвестный"

	var/list/lust_debug = list()

	var/list/famous_voices = list()
	//var/list/famous_faces = list()

/proc/isZlevel(var/mob/analiz)
	var/result = analiz?.loc?.z
	return (result == 3)


/datum/voice_model/New(var/mob/owner_voice)
	if(owner_voice != null) 
		host = owner_voice
		real_voice_name = owner_voice.GetVoice()
		voice_name = owner_voice.GetVoice()
		voice_gender = owner_voice.gender
		famous_voices[voice_name] = owner_voice.name
		tts_seed_string = owner_voice.tts_seed

/datum/voice_model/proc/RegSignals()
		to_chat(world, "Успешно регистрирую сигнал [host.name]")
		RegisterSignal(SSdcs, COMSIG_SPECIAL_MASS_STORE_VOICE, PROC_REF(SpecialMassAddVoice))

//Специфическая функция которая добавляет что нужно короче
/datum/voice_model/proc/SpecialMassAddVoice(suka, list/list_voice)
	SIGNAL_HANDLER
	lust_debug = list_voice
	to_chat(world, "Глобальный сигнал!!")

	var/list/prom_fuck = list_voice?[SSjobs.GetJob(host.job).department]
	if(list_voice?["AbsolutePomny"])
		famous_voices |= list_voice["AbsolutePomny"]

	if(prom_fuck)
		famous_voices |= prom_fuck

/datum/voice_model/proc/JustListAddVoice(list_voice)
	SIGNAL_HANDLER
	famous_voices |= list_voice

/datum/voice_model/proc/VoiceUpdate()
	 voice_name = host.GetVoice() //:badguy:
	 voice_gender = host.gender
	 tts_seed_string = host.tts_seed

/datum/voice_model/proc/get_gender_unknown_name(gender_string)
	var/result = (GENDER_NAME_UNKNOW)?[gender_string]
	if(result)
		return result
	return "Неизвестный"
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
//было две бутылки, словарь или два прока. Я сел на вторую
/datum/voice_model/proc/GetManifestKnowVoice()
	for(var/datum/data/record/t in GLOB.data_core.general)
		if(t)
			if(t.fields["voice"] == voice_name)
				return t.fields["name"]
	return "IDENTIFICATION ERROR"
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

	. = famous_voices?[target.adv_voice.voice_name]
	if(.)
		return

	return get_gender_unknown_name(target.adv_voice.voice_gender)

/datum/voice_model/proc/I_do_remember(mob/target)
	. = famous_voices?[target.adv_voice.voice_name]
	if(.)
		return TRUE
	return FALSE

#undef GENDER_NAME_UNKNOW
