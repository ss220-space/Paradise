SUBSYSTEM_DEF(radio)
	name = "Radio"
	flags = SS_NO_INIT | SS_NO_FIRE
	ss_id = "radio"

	var/list/radiochannels = list(
	"Общий"					= PUB_FREQ,
	"Наука"					= SCI_FREQ,
	"Командование"			= COMM_FREQ,
	"Юриспруденция"			= PROC_FREQ,
	"Медицина"				= MED_FREQ,
	"Инженерия"				= ENG_FREQ,
	"Безопасность" 			= SEC_FREQ,
	"ОБР" 					= ERT_FREQ,
	"ССО" 					= DTH_FREQ,
	"Синдикат"	 			= SYND_FREQ,
	"СиндиТайпан" 			= SYND_TAIPAN_FREQ,
	"СиндиДОС" 				= SYNDTEAM_FREQ,
	"СССП"					= SOV_FREQ,
	"Снабжение" 			= SUP_FREQ,
	"Обслуживание" 			= SRV_FREQ,
	"ИИ"					= AI_FREQ,
	"Медицина (ИТК)"		= MED_I_FREQ,
	"Безопасность (ИТК)"	= SEC_I_FREQ,
	"Жучок"					= SPY_SPIDER_FREQ,
	"Клан Паука"			= NINJA_FREQ,
	"Альфа частота"			= EVENT_ALPHA_FREQ,
	"Бета частота"			= EVENT_BETA_FREQ,
	"Гамма частота"			= EVENT_GAMMA_FREQ
	)
	var/list/CENT_FREQS = list(ERT_FREQ, DTH_FREQ)
	var/list/ANTAG_FREQS = list(SYND_FREQ, SYNDTEAM_FREQ, SYND_TAIPAN_FREQ)
	var/list/DEPT_FREQS = list(AI_FREQ, COMM_FREQ, ENG_FREQ, MED_FREQ, SEC_FREQ, SCI_FREQ, SRV_FREQ, SUP_FREQ, PROC_FREQ)
	var/list/syndicate_blacklist = list(SPY_SPIDER_FREQ, EVENT_ALPHA_FREQ, EVENT_BETA_FREQ, EVENT_GAMMA_FREQ)	//list of frequencies syndicate headset can't hear
	var/list/datum/radio_frequency/frequencies = list()


// This is a disgusting hack to stop this tripping CI when this thing needs to FUCKING DIE
///datum/controller/subsystem/radio/Initialize()
//	return


// This is fucking disgusting and needs to die
/datum/controller/subsystem/radio/proc/frequency_span_class(frequency)
	// Taipan!
	if(frequency == SYND_TAIPAN_FREQ)
		return "taipan"
	// Antags!
	if(frequency in ANTAG_FREQS)
		return "syndradio"
	// centcomm channels (deathsquid and ert)
	if(frequency in CENT_FREQS)
		return "centradio"
	// This switch used to be a shit tonne of if statements. I am gonna find who made this and give them a kind talking to
	switch(frequency)
		if(COMM_FREQ)
			return "comradio"
		if(AI_FREQ)
			return "airadio"
		if(SEC_FREQ)
			return "secradio"
		if(ENG_FREQ)
			return "engradio"
		if(SCI_FREQ)
			return "sciradio"
		if(MED_FREQ)
			return "medradio"
		if(SUP_FREQ)
			return "supradio"
		if(SRV_FREQ)
			return "srvradio"
		if(PROC_FREQ)
			return "proradio"
		if(SOV_FREQ)
			return "sovradio"
		if(SPY_SPIDER_FREQ)
			return "spyradio"
		if(NINJA_FREQ)
			return "spider_clan"
		if(EVENT_ALPHA_FREQ)
			return "event_alpha"
		if(EVENT_BETA_FREQ)
			return "event_beta"
		if(EVENT_GAMMA_FREQ)
			return "event_gamma"

	// If the above switch somehow failed. And it needs the SSradio. part otherwise it fails to compile
	if(frequency in DEPT_FREQS)
		return "deptradio"

	// If its none of the others
	return "radio"


/datum/controller/subsystem/radio/proc/add_object(obj/device as obj, var/new_frequency as num, var/filter = null as text|null)
	var/f_text = num2text(new_frequency)
	var/datum/radio_frequency/frequency = frequencies[f_text]

	if(!frequency)
		frequency = new
		frequency.frequency = new_frequency
		frequencies[f_text] = frequency

	frequency.add_listener(device, filter)
	return frequency

/datum/controller/subsystem/radio/proc/remove_object(obj/device, old_frequency)
	var/f_text = num2text(old_frequency)
	var/datum/radio_frequency/frequency = frequencies[f_text]

	if(frequency)
		frequency.remove_listener(device)

		if(frequency.devices.len == 0)
			qdel(frequency)
			frequencies -= f_text

	return 1

/datum/controller/subsystem/radio/proc/return_frequency(var/new_frequency as num)
	var/f_text = num2text(new_frequency)
	var/datum/radio_frequency/frequency = frequencies[f_text]

	if(!frequency)
		frequency = new
		frequency.frequency = new_frequency
		frequencies[f_text] = frequency

	return frequency


// ALL THE SHIT BELOW THIS LINE ISNT PART OF THE SUBSYSTEM AND REALLY NEEDS ITS OWN FILE
