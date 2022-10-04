#define TTS_CATEGORY_ANY 0

#define TTS_GENDER_ANY 0
#define TTS_GENDER_MALE 1
#define TTS_GENDER_FEMALE 2

/datum/tts_seed
	var/name = "STUB"
	var/value = "STUB"
	var/category = TTS_CATEGORY_ANY
	var/gender = TTS_GENDER_ANY
	var/datum/tts_provider/provider = new /datum/tts_provider

/datum/tts_seed/vv_edit_var(var_name, var_value)
	return FALSE
