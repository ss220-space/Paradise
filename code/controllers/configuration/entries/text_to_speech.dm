/datum/config_entry/flag/tts_enabled
	protection = CONFIG_ENTRY_LOCKED | CONFIG_ENTRY_HIDDEN

/datum/config_entry/flag/tts_cache
	protection = CONFIG_ENTRY_LOCKED | CONFIG_ENTRY_HIDDEN

/datum/config_entry/string/tts_token_silero
	protection = CONFIG_ENTRY_LOCKED | CONFIG_ENTRY_HIDDEN

/datum/config_entry/string/tts_url_silero
	protection = CONFIG_ENTRY_LOCKED | CONFIG_ENTRY_HIDDEN

/// URL of the local TTS effects service (tools/tts_effects). Empty: effects run through a synchronous ffmpeg shell call.
/datum/config_entry/string/tts_effects_url
	protection = CONFIG_ENTRY_LOCKED | CONFIG_ENTRY_HIDDEN
