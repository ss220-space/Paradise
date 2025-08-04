/// Ensure the frequency is within bounds of what it should be sending/receiving at
/proc/sanitize_frequency(frequency, low = PUBLIC_LOW_FREQ, high = PUBLIC_HIGH_FREQ)
	frequency = round(frequency)
	frequency = max(low, frequency)
	frequency = min(high, frequency)
	if(ISEVEN(frequency)) //Ensure the last digit is an odd number
		frequency += 1
	return frequency

/// Format frequency by moving the decimal.
/proc/format_frequency(frequency)
	return "[round(frequency / 10)].[frequency % 10]"

/**
  * Returns the clean name of an audio channel.
  *
  * Arguments:
  * * channel - The channel number.
  */
/proc/get_channel_name(channel)
	switch(channel)
		if(CHANNEL_GENERAL)
			return "Основные звуки"
		if(CHANNEL_LOBBYMUSIC)
			return "Музыка в лобби"
		if(CHANNEL_ADMIN)
			return "Админские MIDI"
		if(CHANNEL_VOX)
			return "Оповещения ИИ"
		if(CHANNEL_JUKEBOX)
			return "Танцевальные машины"
		if(CHANNEL_HEARTBEAT)
			return "Сердцебиение"
		if(CHANNEL_BUZZ)
			return "Белый шум"
		if(CHANNEL_AMBIENCE)
			return "Эмбиент"
		if(CHANNEL_TTS_LOCAL)
			return "TTS рядом"
		if(CHANNEL_TTS_RADIO)
			return "TTS в радиосвязи"
		if(CHANNEL_RADIO_NOISE)
			return "Звуки радиосвязи"
		if(CHANNEL_INTERACTION_SOUNDS)
			return "Звуки взаимодействия с предметами"
		if(CHANNEL_BOSS_MUSIC)
			return "Музыка боссов"
